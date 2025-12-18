<#
.SYNOPSIS
    Deploys the E-Commerce Platform infrastructure to Azure.

.DESCRIPTION
    This script deploys the PCI-DSS compliant e-commerce platform infrastructure
    using Azure Bicep templates. It supports what-if analysis, validation, and
    incremental deployment.

.PARAMETER ResourceGroupName
    The name of the resource group to deploy to.

.PARAMETER Location
    The Azure region for deployment. Defaults to 'swedencentral'.

.PARAMETER Environment
    The environment name (dev, staging, prod). Defaults to 'prod'.

.PARAMETER SqlAdminGroupObjectId
    The Azure AD group object ID for SQL Server administration.
    If not provided, the script will use the current signed-in user's object ID.

.PARAMETER SqlAdminGroupName
    The Azure AD group name for SQL Server administration.
    If not provided and using current user, defaults to the user's display name.

.PARAMETER UseCurrentUser
    Use the current signed-in user as the SQL admin instead of a group.
    This is the default behavior when SqlAdminGroupObjectId is not provided.

.PARAMETER SkipValidation
    Skip Bicep validation before deployment.

.EXAMPLE
    ./deploy.ps1 -ResourceGroupName "rg-ecommerce-prod-swc"
    # Uses current signed-in user as SQL admin

.EXAMPLE
    ./deploy.ps1 -ResourceGroupName "rg-ecommerce-prod-swc" -SqlAdminGroupObjectId "12345678-1234-1234-1234-123456789012"

.EXAMPLE
    ./deploy.ps1 -ResourceGroupName "rg-ecommerce-dev-swc" -Environment "dev" -WhatIf
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [ValidateSet('swedencentral', 'germanywestcentral', 'westeurope', 'northeurope')]
    [string]$Location = 'swedencentral',

    [Parameter(Mandatory = $false)]
    [ValidateSet('dev', 'staging', 'prod')]
    [string]$Environment = 'prod',

    [Parameter(Mandatory = $false)]
    [string]$SqlAdminGroupObjectId,

    [Parameter(Mandatory = $false)]
    [string]$SqlAdminGroupName,

    [Parameter(Mandatory = $false)]
    [switch]$UseCurrentUser,

    [Parameter(Mandatory = $false)]
    [switch]$SkipValidation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ============================================================================
# Configuration
# ============================================================================

$ScriptRoot = $PSScriptRoot
$TemplateFile = Join-Path $ScriptRoot 'main.bicep'
$DeploymentName = "ecommerce-$Environment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Banner {
    $banner = @"

    ╔═══════════════════════════════════════════════════════════════════════╗
    ║                                                                       ║
    ║   ███████╗       ██████╗ ██████╗ ███╗   ███╗███╗   ███╗███████╗       ║
    ║   ██╔════╝      ██╔════╝██╔═══██╗████╗ ████║████╗ ████║██╔════╝       ║
    ║   █████╗  █████╗██║     ██║   ██║██╔████╔██║██╔████╔██║█████╗         ║
    ║   ██╔══╝  ╚════╝██║     ██║   ██║██║╚██╔╝██║██║╚██╔╝██║██╔══╝         ║
    ║   ███████╗      ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║ ╚═╝ ██║███████╗       ║
    ║   ╚══════╝       ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝╚══════╝       ║
    ║                                                                       ║
    ║          Azure Infrastructure Deployment                              ║
    ║          PCI-DSS Compliant E-Commerce Platform                        ║
    ║                                                                       ║
    ╚═══════════════════════════════════════════════════════════════════════╝

"@
    Write-Host $banner -ForegroundColor Cyan
}

function Write-Header {
    param([string]$Message)
    $width = 70
    $padding = [math]::Max(0, ($width - $Message.Length - 4) / 2)
    $leftPad = " " * [math]::Floor($padding)
    $rightPad = " " * [math]::Ceiling($padding)
    
    Write-Host ""
    Write-Host "  ┌$('─' * ($width - 2))┐" -ForegroundColor DarkCyan
    Write-Host "  │$leftPad  $Message  $rightPad│" -ForegroundColor DarkCyan
    Write-Host "  └$('─' * ($width - 2))┘" -ForegroundColor DarkCyan
    Write-Host ""
}

function Write-Step {
    param(
        [string]$Message,
        [int]$StepNumber = 0,
        [int]$TotalSteps = 0
    )
    if ($StepNumber -gt 0 -and $TotalSteps -gt 0) {
        $progress = "[$StepNumber/$TotalSteps]"
        Write-Host "  $progress " -ForegroundColor DarkGray -NoNewline
    } else {
        Write-Host "  ► " -ForegroundColor DarkYellow -NoNewline
    }
    Write-Host $Message -ForegroundColor Yellow
}

function Write-SubStep {
    param([string]$Message)
    Write-Host "      └─ " -ForegroundColor DarkGray -NoNewline
    Write-Host $Message -ForegroundColor Gray
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ " -ForegroundColor Green -NoNewline
    Write-Host $Message -ForegroundColor Green
}

function Write-Info {
    param([string]$Label, [string]$Value)
    Write-Host "      • " -ForegroundColor DarkGray -NoNewline
    Write-Host "$Label`: " -ForegroundColor Gray -NoNewline
    Write-Host $Value -ForegroundColor White
}

function Write-ErrorMessage {
    param([string]$Message)
    Write-Host "  ✗ " -ForegroundColor Red -NoNewline
    Write-Host $Message -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "  ⚠ " -ForegroundColor Yellow -NoNewline
    Write-Host $Message -ForegroundColor Yellow
}

function Show-ProgressBar {
    param(
        [string]$Activity,
        [int]$PercentComplete,
        [string]$Status = ""
    )
    $width = 40
    $complete = [math]::Floor($width * $PercentComplete / 100)
    $remaining = $width - $complete
    $bar = "█" * $complete + "░" * $remaining
    
    Write-Host "`r  [$bar] $PercentComplete% $Status" -ForegroundColor Cyan -NoNewline
    if ($PercentComplete -eq 100) {
        Write-Host ""
    }
}

function Write-DeploymentSummary {
    param(
        [string]$ResourceGroup,
        [string]$Location,
        [string]$Environment,
        [string]$DeploymentName
    )
    
    $envColors = @{
        'dev' = 'Green'
        'staging' = 'Yellow'
        'prod' = 'Red'
    }
    $envColor = $envColors[$Environment]
    
    Write-Host ""
    Write-Host "  ┌────────────────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "  │  " -ForegroundColor DarkGray -NoNewline
    Write-Host "DEPLOYMENT CONFIGURATION" -ForegroundColor White -NoNewline
    Write-Host "                                          │" -ForegroundColor DarkGray
    Write-Host "  ├────────────────────────────────────────────────────────────────────┤" -ForegroundColor DarkGray
    Write-Host "  │  Resource Group   : " -ForegroundColor DarkGray -NoNewline
    Write-Host ("{0,-47}" -f $ResourceGroup) -ForegroundColor Cyan -NoNewline
    Write-Host "│" -ForegroundColor DarkGray
    Write-Host "  │  Location         : " -ForegroundColor DarkGray -NoNewline
    Write-Host ("{0,-47}" -f $Location) -ForegroundColor Cyan -NoNewline
    Write-Host "│" -ForegroundColor DarkGray
    Write-Host "  │  Environment      : " -ForegroundColor DarkGray -NoNewline
    Write-Host ("{0,-47}" -f $Environment.ToUpper()) -ForegroundColor $envColor -NoNewline
    Write-Host "│" -ForegroundColor DarkGray
    Write-Host "  │  Deployment Name  : " -ForegroundColor DarkGray -NoNewline
    Write-Host ("{0,-47}" -f $DeploymentName) -ForegroundColor Cyan -NoNewline
    Write-Host "│" -ForegroundColor DarkGray
    Write-Host "  └────────────────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
    Write-Host ""
}

# ============================================================================
# Pre-flight Checks
# ============================================================================

Write-Banner
Write-DeploymentSummary -ResourceGroup $ResourceGroupName -Location $Location -Environment $Environment -DeploymentName $DeploymentName

Write-Header "Pre-flight Checks"

$totalSteps = 3
$currentStep = 0

$currentStep++
Write-Step "Checking Azure CLI installation..." -StepNumber $currentStep -TotalSteps $totalSteps

# Check Azure CLI
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-ErrorMessage "Azure CLI is not installed. Please install it first."
    exit 1
}
Write-SubStep "Azure CLI found"

# Check Bicep CLI
$bicepVersion = az bicep version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-SubStep "Installing Bicep CLI..."
    az bicep install
}
Write-SubStep "Bicep CLI ready"

$currentStep++
Write-Step "Verifying Azure authentication..." -StepNumber $currentStep -TotalSteps $totalSteps

# Check Azure login
$account = az account show 2>&1 | ConvertFrom-Json -ErrorAction SilentlyContinue
if (-not $account) {
    Write-ErrorMessage "Not logged in to Azure. Please run 'az login' first."
    exit 1
}
Write-SubStep "Authenticated to Azure"
Write-Info "Subscription" $account.name
Write-Info "User" $account.user.name

$currentStep++
Write-Step "Resolving SQL admin identity..." -StepNumber $currentStep -TotalSteps $totalSteps

# ============================================================================
# Resolve SQL Admin Identity
# ============================================================================

if (-not $SqlAdminGroupObjectId) {
    # Get current signed-in user's object ID
    $signedInUser = az ad signed-in-user show 2>&1 | ConvertFrom-Json -ErrorAction SilentlyContinue
    
    if ($signedInUser) {
        $SqlAdminGroupObjectId = $signedInUser.id
        if (-not $SqlAdminGroupName) {
            $SqlAdminGroupName = $signedInUser.displayName
        }
        Write-SubStep "Using current user as SQL admin"
        Write-Info "Name" $signedInUser.displayName
        Write-Info "Object ID" $SqlAdminGroupObjectId
    } else {
        Write-ErrorMessage "Could not determine current user. Please provide -SqlAdminGroupObjectId parameter."
        exit 1
    }
} else {
    Write-SubStep "Using provided SQL admin identity"
    Write-Info "Object ID" $SqlAdminGroupObjectId
    if (-not $SqlAdminGroupName) {
        # Try to resolve the name from the object ID
        $adObject = az ad group show --group $SqlAdminGroupObjectId 2>&1 | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($adObject) {
            $SqlAdminGroupName = $adObject.displayName
            Write-Info "Group Name" $SqlAdminGroupName
        } else {
            # Try as user
            $adObject = az ad user show --id $SqlAdminGroupObjectId 2>&1 | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($adObject) {
                $SqlAdminGroupName = $adObject.displayName
                Write-Info "User Name" $SqlAdminGroupName
            } else {
                $SqlAdminGroupName = "sql-admin"
                Write-Info "Name" "$SqlAdminGroupName (default)"
            }
        }
    }
}

Write-Success "Pre-flight checks completed"

# ============================================================================
# Validate Bicep Templates
# ============================================================================

if (-not $SkipValidation) {
    Write-Header "Template Validation"

    Write-Step "Running Bicep build validation..."
    $buildResult = az bicep build --file $TemplateFile 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorMessage "Bicep build failed:"
        Write-Host $buildResult -ForegroundColor Red
        exit 1
    }
    Write-Success "Bicep syntax validation passed"

    Write-Step "Running Bicep linter..."
    $lintResult = az bicep lint --file $TemplateFile 2>&1
    # Lint warnings are acceptable, only fail on errors
    if ($lintResult -match "Error") {
        Write-ErrorMessage "Bicep lint found errors:"
        Write-Host $lintResult -ForegroundColor Red
        exit 1
    }
    if ($lintResult -match "Warning") {
        Write-Warning "Bicep lint found warnings (non-blocking)"
        $lintResult -split "`n" | ForEach-Object { Write-SubStep $_ }
    } else {
        Write-Success "Bicep linter passed"
    }

    # Clean up generated ARM template
    $armFile = $TemplateFile -replace '\.bicep$', '.json'
    if (Test-Path $armFile) {
        Remove-Item $armFile -Force
    }
}

# ============================================================================
# Create Resource Group
# ============================================================================

Write-Header "Resource Group Setup"

$rgExists = az group exists --name $ResourceGroupName 2>&1
if ($rgExists -eq 'false') {
    Write-Step "Creating resource group..."
    az group create --name $ResourceGroupName --location $Location --tags Environment=$Environment ManagedBy=Bicep Project=ecommerce-platform | Out-Null
    Write-Success "Resource group '$ResourceGroupName' created"
} else {
    Write-Success "Resource group '$ResourceGroupName' exists"
}

# ============================================================================
# What-If Analysis
# ============================================================================

Write-Header "Deployment Preview (What-If)"

$deploymentParams = @(
    '--resource-group', $ResourceGroupName
    '--template-file', $TemplateFile
    '--parameters', "location=$Location"
    '--parameters', "environment=$Environment"
    '--parameters', "sqlAdminGroupObjectId=$SqlAdminGroupObjectId"
    '--parameters', "sqlAdminGroupName=$SqlAdminGroupName"
)

Write-Step "Analyzing planned changes..."
Write-Host ""
$whatIfResult = az deployment group what-if @deploymentParams 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-ErrorMessage "What-if analysis failed:"
    Write-Host $whatIfResult -ForegroundColor Red
    exit 1
}

# Parse and display what-if results in a formatted way
$whatIfText = $whatIfResult -join "`n"
$createMatches = [regex]::Matches($whatIfText, "(?m)^\s*\+\s")
$modifyMatches = [regex]::Matches($whatIfText, "(?m)^\s*~\s")
$deleteMatches = [regex]::Matches($whatIfText, "(?m)^\s*-\s")
$noChangeMatches = [regex]::Matches($whatIfText, "(?m)^\s*=\s")

$createCount = $createMatches.Count
$modifyCount = $modifyMatches.Count
$deleteCount = $deleteMatches.Count
$noChangeCount = $noChangeMatches.Count

Write-Host "  ┌─────────────────────────────────────────┐" -ForegroundColor DarkGray
Write-Host "  │  " -ForegroundColor DarkGray -NoNewline
Write-Host "CHANGE SUMMARY" -ForegroundColor White -NoNewline
Write-Host "                          │" -ForegroundColor DarkGray
Write-Host "  ├─────────────────────────────────────────┤" -ForegroundColor DarkGray
Write-Host "  │  " -ForegroundColor DarkGray -NoNewline
Write-Host "+" -ForegroundColor Green -NoNewline
Write-Host " Create     : " -ForegroundColor DarkGray -NoNewline
Write-Host ("{0,-23}" -f "$createCount resources") -ForegroundColor Green -NoNewline
Write-Host "│" -ForegroundColor DarkGray
Write-Host "  │  " -ForegroundColor DarkGray -NoNewline
Write-Host "~" -ForegroundColor Yellow -NoNewline
Write-Host " Modify     : " -ForegroundColor DarkGray -NoNewline
Write-Host ("{0,-23}" -f "$modifyCount resources") -ForegroundColor Yellow -NoNewline
Write-Host "│" -ForegroundColor DarkGray
Write-Host "  │  " -ForegroundColor DarkGray -NoNewline
Write-Host "-" -ForegroundColor Red -NoNewline
Write-Host " Delete     : " -ForegroundColor DarkGray -NoNewline
Write-Host ("{0,-23}" -f "$deleteCount resources") -ForegroundColor Red -NoNewline
Write-Host "│" -ForegroundColor DarkGray
Write-Host "  │  " -ForegroundColor DarkGray -NoNewline
Write-Host "=" -ForegroundColor Cyan -NoNewline
Write-Host " No Change  : " -ForegroundColor DarkGray -NoNewline
Write-Host ("{0,-23}" -f "$noChangeCount resources") -ForegroundColor Cyan -NoNewline
Write-Host "│" -ForegroundColor DarkGray
Write-Host "  └─────────────────────────────────────────┘" -ForegroundColor DarkGray
Write-Host ""

# Show detailed what-if output
if ($VerbosePreference -eq 'Continue' -or $DebugPreference -eq 'Continue') {
    Write-Host "  Detailed changes:" -ForegroundColor DarkGray
    Write-Host $whatIfResult
}

# Check if running in WhatIf mode
if ($WhatIfPreference) {
    Write-Header "What-If Mode Complete"
    Write-Host "  No changes were made. Remove -WhatIf to deploy." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

# ============================================================================
# Confirm Deployment
# ============================================================================

Write-Host ""
Write-Host "  ┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Yellow
Write-Host "  │  " -ForegroundColor Yellow -NoNewline
Write-Host "⚡ READY TO DEPLOY" -ForegroundColor White -NoNewline
Write-Host "                                             │" -ForegroundColor Yellow
Write-Host "  │                                                                 │" -ForegroundColor Yellow
Write-Host "  │  This will create Azure resources that incur costs.            │" -ForegroundColor Yellow
Write-Host "  │  Estimated monthly cost: ~`$2,212 USD                           │" -ForegroundColor Yellow
Write-Host "  │                                                                 │" -ForegroundColor Yellow
Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "  Type 'yes' to proceed with deployment"
if ($confirm -ne 'yes') {
    Write-Host ""
    Write-Warning "Deployment cancelled by user"
    Write-Host ""
    exit 0
}

# ============================================================================
# Deploy
# ============================================================================

Write-Header "Deploying Infrastructure"

Write-Host ""
Write-Host "  🚀 Starting deployment..." -ForegroundColor Cyan
Write-Host "  ────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Info "Deployment ID" $DeploymentName
Write-Info "Started at" (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Write-Host "  ────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

$startTime = Get-Date

# Start a background job to show progress
$progressJob = Start-Job -ScriptBlock {
    param($totalMinutes)
    $elapsed = 0
    while ($elapsed -lt ($totalMinutes * 60)) {
        $percent = [math]::Min(95, [int]($elapsed / ($totalMinutes * 60) * 100))
        Write-Output $percent
        Start-Sleep -Seconds 10
        $elapsed += 10
    }
} -ArgumentList 20

# Deploy with real-time output
Write-Step "Provisioning Azure resources (this may take 15-20 minutes)..."
Write-Host ""

$deployResult = az deployment group create `
    --name $DeploymentName `
    @deploymentParams `
    2>&1

# Stop the progress job
Stop-Job -Job $progressJob -ErrorAction SilentlyContinue
Remove-Job -Job $progressJob -ErrorAction SilentlyContinue

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-ErrorMessage "Deployment failed!"
    Write-Host ""
    Write-Host "  Error details:" -ForegroundColor Red
    Write-Host $deployResult -ForegroundColor Red
    Write-Host ""
    
    Write-Step "Fetching detailed error information..."
    az deployment group show --name $DeploymentName --resource-group $ResourceGroupName --query 'properties.error' 2>&1
    exit 1
}

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host ""
Show-ProgressBar -Activity "Deployment" -PercentComplete 100 -Status "Complete!"
Write-Host ""

# ============================================================================
# Output Results
# ============================================================================

Write-Header "Deployment Complete! 🎉"

# Duration box
Write-Host "  ┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
Write-Host "  │  " -ForegroundColor Green -NoNewline
Write-Host "✓ DEPLOYMENT SUCCESSFUL" -ForegroundColor White -NoNewline
Write-Host "                                       │" -ForegroundColor Green
Write-Host "  │                                                                 │" -ForegroundColor Green
Write-Host "  │  Duration: " -ForegroundColor Green -NoNewline
Write-Host ("{0,-54}" -f $duration.ToString('hh\:mm\:ss')) -ForegroundColor Cyan -NoNewline
Write-Host "│" -ForegroundColor Green
Write-Host "  │  Finished: " -ForegroundColor Green -NoNewline
Write-Host ("{0,-54}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")) -ForegroundColor Cyan -NoNewline
Write-Host "│" -ForegroundColor Green
Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor Green
Write-Host ""

$outputs = az deployment group show `
    --name $DeploymentName `
    --resource-group $ResourceGroupName `
    --query 'properties.outputs' 2>&1 | ConvertFrom-Json

if ($outputs) {
    Write-Host "  ┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor DarkCyan
    Write-Host "  │  " -ForegroundColor DarkCyan -NoNewline
    Write-Host "RESOURCE ENDPOINTS" -ForegroundColor White -NoNewline
    Write-Host "                                            │" -ForegroundColor DarkCyan
    Write-Host "  ├─────────────────────────────────────────────────────────────────┤" -ForegroundColor DarkCyan
    Write-Host "  │                                                                 │" -ForegroundColor DarkCyan
    Write-Host "  │  🌐 Front Door      " -ForegroundColor DarkCyan -NoNewline
    Write-Host ("https://{0}" -f $outputs.frontDoorHostName.value).PadRight(46) -ForegroundColor Cyan -NoNewline
    Write-Host "│" -ForegroundColor DarkCyan
    Write-Host "  │  🔧 App Service     " -ForegroundColor DarkCyan -NoNewline
    Write-Host ("https://{0}" -f $outputs.appServiceHostName.value).PadRight(46) -ForegroundColor Cyan -NoNewline
    Write-Host "│" -ForegroundColor DarkCyan
    Write-Host "  │  📱 Static Web App  " -ForegroundColor DarkCyan -NoNewline
    Write-Host ("https://{0}" -f $outputs.staticWebAppHostName.value).PadRight(46) -ForegroundColor Cyan -NoNewline
    Write-Host "│" -ForegroundColor DarkCyan
    Write-Host "  │  🔐 Key Vault       " -ForegroundColor DarkCyan -NoNewline
    Write-Host $outputs.keyVaultUri.value.PadRight(46) -ForegroundColor Cyan -NoNewline
    Write-Host "│" -ForegroundColor DarkCyan
    Write-Host "  │  💾 SQL Server      " -ForegroundColor DarkCyan -NoNewline
    Write-Host $outputs.sqlServerFqdn.value.PadRight(46) -ForegroundColor Cyan -NoNewline
    Write-Host "│" -ForegroundColor DarkCyan
    Write-Host "  │                                                                 │" -ForegroundColor DarkCyan
    Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
}

Write-Header "Next Steps"

Write-Host @"
  ┌─────────────────────────────────────────────────────────────────────┐
  │  1. Configure Azure AD authentication for SQL Server               │
  │  2. Deploy application code to App Service                         │
  │  3. Deploy React SPA to Static Web App                              │
  │  4. Configure custom domain for Front Door                         │
  │  5. Review WAF logs in Log Analytics                                │
  └─────────────────────────────────────────────────────────────────────┘

"@ -ForegroundColor DarkGray

Write-Host "  📋 " -NoNewline -ForegroundColor DarkYellow
Write-Host "Useful Commands" -ForegroundColor Yellow
Write-Host ""
Write-Host "  # View deployment details" -ForegroundColor DarkGray
Write-Host "  az deployment group show --name $DeploymentName --resource-group $ResourceGroupName" -ForegroundColor Gray
Write-Host ""
Write-Host "  # List all resources" -ForegroundColor DarkGray
Write-Host "  az resource list --resource-group $ResourceGroupName --output table" -ForegroundColor Gray
Write-Host ""
Write-Host "  # Check Front Door health" -ForegroundColor DarkGray
Write-Host "  az afd endpoint show --profile-name afd-ecommerce-$Environment-001 --endpoint-name ecommerce-endpoint --resource-group $ResourceGroupName" -ForegroundColor Gray
Write-Host ""

Write-Host "  ═══════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "                    ✨ Deployment Complete! ✨                       " -ForegroundColor Green
Write-Host "  ═══════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
