<#
.SYNOPSIS
    Validates that all prerequisites for Agentic InfraOps workshops are met.

.DESCRIPTION
    This script checks for required tools, extensions, and configurations needed
    to run Agentic InfraOps scenarios and workshops. It provides clear pass/fail
    feedback and remediation guidance.

.PARAMETER Verbose
    Shows detailed information about each check.

.EXAMPLE
    ./check-prerequisites.ps1
    Basic check with summary output.

.EXAMPLE
    ./check-prerequisites.ps1 -Verbose
    Detailed check with version information.

.NOTES
    Version: 3.2.0
    Part of: Agentic InfraOps - Azure infrastructure engineered by agents
#>

[CmdletBinding()]
param()

# Colors and formatting
$script:PassColor = 'Green'
$script:FailColor = 'Red'
$script:WarnColor = 'Yellow'
$script:InfoColor = 'Cyan'

function Write-CheckHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor $InfoColor
    Write-Host "  $Title" -ForegroundColor $InfoColor
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor $InfoColor
}

function Write-CheckResult {
    param(
        [string]$Name,
        [bool]$Passed,
        [string]$Details = "",
        [string]$Remediation = ""
    )
    
    $icon = if ($Passed) { "✅" } else { "❌" }
    $color = if ($Passed) { $PassColor } else { $FailColor }
    
    Write-Host "  $icon " -NoNewline
    Write-Host "$Name" -ForegroundColor $color -NoNewline
    
    if ($Details) {
        Write-Host " - $Details" -ForegroundColor Gray
    } else {
        Write-Host ""
    }
    
    if (-not $Passed -and $Remediation) {
        Write-Host "     └─ " -ForegroundColor $WarnColor -NoNewline
        Write-Host "$Remediation" -ForegroundColor $WarnColor
    }
    
    return $Passed
}

function Test-Command {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

function Get-CommandVersion {
    param(
        [string]$Command,
        [string]$VersionArg = "--version"
    )
    try {
        $output = & $Command $VersionArg 2>&1
        return ($output | Select-Object -First 1) -replace '^\s+', ''
    } catch {
        return "unknown"
    }
}

# Banner
Write-Host ""
Write-Host @"
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║     █████╗  ██████╗ ███████╗███╗   ██╗████████╗██╗ ██████╗                    ║
║    ██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝██║██╔════╝                    ║
║    ███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║   ██║██║                         ║
║    ██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║   ██║██║                         ║
║    ██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║   ██║╚██████╗                    ║
║    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝ ╚═════╝                    ║
║                                                                               ║
║                    INFRAOPS PREREQUISITES CHECK                               ║
║                           Version 3.2.0                                       ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

$results = @{
    Required = @()
    Optional = @()
}

# ============================================================================
# REQUIRED TOOLS
# ============================================================================

Write-CheckHeader "Required Tools"

# Git
$gitInstalled = Test-Command "git"
$gitVersion = if ($gitInstalled) { Get-CommandVersion "git" } else { "" }
$results.Required += Write-CheckResult -Name "Git" -Passed $gitInstalled `
    -Details $gitVersion `
    -Remediation "Install from https://git-scm.com/downloads"

# Azure CLI
$azInstalled = Test-Command "az"
$azVersion = if ($azInstalled) { 
    $v = (az version 2>&1 | ConvertFrom-Json -ErrorAction SilentlyContinue)
    if ($v) { "v$($v.'azure-cli')" } else { "installed" }
} else { "" }
$results.Required += Write-CheckResult -Name "Azure CLI" -Passed $azInstalled `
    -Details $azVersion `
    -Remediation "Install from https://aka.ms/installazurecliwindows"

# Bicep CLI (via Azure CLI)
$bicepInstalled = $false
$bicepVersion = ""
if ($azInstalled) {
    try {
        # Use --only-show-errors to suppress warnings, capture just version output
        $bicepOutput = az bicep version --only-show-errors 2>&1 | Out-String
        if ($bicepOutput -match 'Bicep CLI version (\d+\.\d+\.\d+)') {
            $bicepInstalled = $true
            $bicepVersion = "v$($Matches[1])"
        } elseif ($bicepOutput -match '(\d+\.\d+\.\d+)') {
            $bicepInstalled = $true
            $bicepVersion = "v$($Matches[1])"
        }
    } catch { }
}
$results.Required += Write-CheckResult -Name "Bicep CLI" -Passed $bicepInstalled `
    -Details $bicepVersion `
    -Remediation "Run: az bicep install"

# PowerShell 7+
$pwshInstalled = $PSVersionTable.PSVersion.Major -ge 7
$pwshVersion = "v$($PSVersionTable.PSVersion)"
$results.Required += Write-CheckResult -Name "PowerShell 7+" -Passed $pwshInstalled `
    -Details $pwshVersion `
    -Remediation "Install from https://aka.ms/powershell"

# Node.js (for markdownlint)
$nodeInstalled = Test-Command "node"
$nodeVersion = if ($nodeInstalled) { Get-CommandVersion "node" } else { "" }
$results.Required += Write-CheckResult -Name "Node.js" -Passed $nodeInstalled `
    -Details $nodeVersion `
    -Remediation "Install from https://nodejs.org/"

# ============================================================================
# VS CODE & EXTENSIONS
# ============================================================================

Write-CheckHeader "VS Code Environment"

# VS Code
$codeInstalled = Test-Command "code"
$codeVersion = if ($codeInstalled) { 
    $v = Get-CommandVersion "code" "--version" 
    ($v -split "`n")[0]
} else { "" }
$results.Required += Write-CheckResult -Name "VS Code" -Passed $codeInstalled `
    -Details $codeVersion `
    -Remediation "Install from https://code.visualstudio.com/"

# Check for key extensions (if VS Code is installed)
if ($codeInstalled) {
    $extensions = code --list-extensions 2>&1
    
    $requiredExtensions = @(
        @{ Id = "github.copilot"; Name = "GitHub Copilot" },
        @{ Id = "github.copilot-chat"; Name = "GitHub Copilot Chat" },
        @{ Id = "ms-azuretools.vscode-bicep"; Name = "Bicep Extension" }
    )
    
    foreach ($ext in $requiredExtensions) {
        $installed = $extensions -contains $ext.Id
        $results.Required += Write-CheckResult -Name $ext.Name -Passed $installed `
            -Remediation "Run: code --install-extension $($ext.Id)"
    }
}

# ============================================================================
# OPTIONAL TOOLS
# ============================================================================

Write-CheckHeader "Optional Tools (Recommended)"

# Terraform
$tfInstalled = Test-Command "terraform"
$tfVersion = if ($tfInstalled) { Get-CommandVersion "terraform" } else { "" }
$results.Optional += Write-CheckResult -Name "Terraform" -Passed $tfInstalled `
    -Details $tfVersion `
    -Remediation "Install from https://terraform.io/downloads"

# Python (for diagram generation)
$pythonInstalled = Test-Command "python3" -or (Test-Command "python")
$pythonVersion = if ($pythonInstalled) { 
    if (Test-Command "python3") { Get-CommandVersion "python3" }
    else { Get-CommandVersion "python" }
} else { "" }
$results.Optional += Write-CheckResult -Name "Python 3" -Passed $pythonInstalled `
    -Details $pythonVersion `
    -Remediation "Install from https://python.org/downloads"

# Docker
$dockerInstalled = Test-Command "docker"
$dockerVersion = if ($dockerInstalled) { Get-CommandVersion "docker" } else { "" }
$results.Optional += Write-CheckResult -Name "Docker" -Passed $dockerInstalled `
    -Details $dockerVersion `
    -Remediation "Install Docker Desktop from https://docker.com/products/docker-desktop"

# markdownlint (check global, local binary, or npm script)
$mdlintInstalled = (Test-Command "markdownlint-cli2") -or 
    (Test-Command "markdownlint") -or 
    (Test-Path "node_modules/.bin/markdownlint-cli2") -or
    (Test-Path "node_modules/.bin/markdownlint") -or
    ((Test-Path "package.json") -and ((Get-Content "package.json" -Raw) -match '"lint:md"'))
$results.Optional += Write-CheckResult -Name "markdownlint-cli2" -Passed $mdlintInstalled `
    -Remediation "Run: npm install"

# ============================================================================
# AZURE AUTHENTICATION
# ============================================================================

Write-CheckHeader "Azure Authentication"

$azLoggedIn = $false
$azAccount = ""
if ($azInstalled) {
    try {
        $account = az account show 2>&1 | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($account) {
            $azLoggedIn = $true
            $azAccount = "$($account.user.name) ($($account.name))"
        }
    } catch { }
}
$results.Required += Write-CheckResult -Name "Azure Login" -Passed $azLoggedIn `
    -Details $azAccount `
    -Remediation "Run: az login"

# ============================================================================
# SUMMARY
# ============================================================================

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor $InfoColor
Write-Host "  SUMMARY" -ForegroundColor $InfoColor
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor $InfoColor

$requiredPassed = ($results.Required | Where-Object { $_ -eq $true }).Count
$requiredTotal = $results.Required.Count
$optionalPassed = ($results.Optional | Where-Object { $_ -eq $true }).Count
$optionalTotal = $results.Optional.Count

Write-Host ""
Write-Host "  Required: " -NoNewline
$reqColor = if ($requiredPassed -eq $requiredTotal) { $PassColor } else { $FailColor }
Write-Host "$requiredPassed/$requiredTotal passed" -ForegroundColor $reqColor

Write-Host "  Optional: " -NoNewline
$optColor = if ($optionalPassed -eq $optionalTotal) { $PassColor } else { $WarnColor }
Write-Host "$optionalPassed/$optionalTotal passed" -ForegroundColor $optColor

Write-Host ""

if ($requiredPassed -eq $requiredTotal) {
    Write-Host "  🎉 " -NoNewline
    Write-Host "All required prerequisites met! Ready for workshops." -ForegroundColor $PassColor
    $exitCode = 0
} else {
    Write-Host "  ⚠️  " -NoNewline
    Write-Host "Some required prerequisites are missing. Please install them before proceeding." -ForegroundColor $FailColor
    $exitCode = 1
}

Write-Host ""
Write-Host "  📚 Documentation: docs/getting-started/prerequisites.md" -ForegroundColor Gray
Write-Host "  🚀 Quick Start:   docs/getting-started/QUICKSTART.md" -ForegroundColor Gray
Write-Host ""

exit $exitCode
