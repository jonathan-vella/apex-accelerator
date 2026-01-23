#!/bin/bash
set -e

echo "🚀 Running post-create setup for Agentic InfraOps..."

# Log output to file for debugging
exec 1> >(tee -a ~/.devcontainer-install.log)
exec 2>&1

# Create directories
echo "📂 Creating cache directories..."
mkdir -p "${HOME}/.cache"
# Fix ownership if needed (may be owned by root from previous installs)
sudo chown -R vscode:vscode "${HOME}/.cache" 2>/dev/null || true
chmod 755 "${HOME}/.cache" 2>/dev/null || true

# Configure Git safe directory (for mounted volumes)
echo "🔐 Configuring Git..."
git config --global --add safe.directory "${PWD}"
git config --global core.autocrlf input
# Note: lefthook setup moved to postStartCommand (runs every container start)

# Ensure uv is on PATH (installed via onCreateCommand)
export PATH="${HOME}/.local/bin:${PATH}"

# Install Python packages using uv (10-100x faster than pip)
echo "🐍 Installing Python packages with uv..."
if command -v uv &> /dev/null; then
    # Create uv cache directory with proper permissions
    mkdir -p "${HOME}/.cache/uv" 2>/dev/null || true
    chmod -R 755 "${HOME}/.cache/uv" 2>/dev/null || true
    uv pip install --system --quiet diagrams matplotlib pillow checkov 2>&1 || echo "  ⚠️  Installation had issues, continuing..."
    echo "  ✅ Python packages installed (diagrams, matplotlib, pillow, checkov)"
else
    echo "  ⚠️  uv not found, falling back to pip..."
    pip3 install --quiet --user diagrams matplotlib pillow checkov 2>&1 | tail -1 || true
fi

# Verify markdownlint-cli2 (installed globally via postCreateCommand)
echo "📝 Verifying markdownlint-cli2..."
if npm list -g markdownlint-cli2 --depth=0 2>/dev/null | grep -q markdownlint-cli2; then
    MDLINT_VERSION=$(npm list -g markdownlint-cli2 --depth=0 2>/dev/null | grep markdownlint-cli2 | sed 's/.*@//')
    echo "  ✅ markdownlint-cli2 v${MDLINT_VERSION} installed globally"
elif [ -f "${PWD}/node_modules/.bin/markdownlint-cli2" ]; then
    echo "  ✅ markdownlint-cli2 installed locally"
else
    echo "  ⚠️  markdownlint-cli2 not found (should have been installed via postCreateCommand)"
fi

# Install Azure PowerShell modules (parallel install using Start-Job)
echo "🔧 Installing Azure PowerShell modules..."
pwsh -NoProfile -Command "
    \$ErrorActionPreference = 'SilentlyContinue'
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    
    # Define modules to install
    \$modules = @('Az.Accounts', 'Az.Resources', 'Az.Storage', 'Az.Network', 'Az.KeyVault', 'Az.Websites')
    
    # Filter to only modules not already installed
    \$toInstall = \$modules | Where-Object { -not (Get-Module -ListAvailable -Name \$_) }
    
    if (\$toInstall.Count -eq 0) {
        Write-Host '  ✅ All PowerShell modules already installed'
        exit 0
    }
    
    Write-Host \"  Installing \$(\$toInstall.Count) modules: \$(\$toInstall -join ', ')...\"
    
    # Install modules in parallel using background jobs
    \$jobs = \$toInstall | ForEach-Object {
        Start-Job -ScriptBlock {
            param(\$m)
            Install-Module -Name \$m -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck -ErrorAction SilentlyContinue
        } -ArgumentList \$_
    }
    
    # Wait for all jobs with timeout (90 seconds)
    \$completed = \$jobs | Wait-Job -Timeout 90
    \$jobs | Remove-Job -Force
    
    Write-Host '  ✅ PowerShell modules installed'
" || echo "⚠️  Warning: PowerShell module installation incomplete"

# Verify utilities (installed via devcontainer features and onCreateCommand)
echo "🛠️  Verifying utilities..."
command -v gh &> /dev/null && echo "  ✅ GitHub CLI available" || echo "  ⚠️  GitHub CLI not found"
command -v dot &> /dev/null && echo "  ✅ graphviz available" || echo "  ⚠️  graphviz not found (required for diagrams)"
command -v dos2unix &> /dev/null && echo "  ✅ dos2unix available" || echo "  ⚠️  dos2unix not found"

# Setup Azure Pricing MCP Server
echo "💰 Setting up Azure Pricing MCP Server..."
MCP_DIR="${PWD}/mcp/azure-pricing-mcp"
if [ -d "$MCP_DIR" ]; then
    if [ ! -d "$MCP_DIR/.venv" ]; then
        echo "  Creating virtual environment..."
        python3 -m venv "$MCP_DIR/.venv"
    fi
    
    # Always install/upgrade package in editable mode for proper entry points
    echo "  Installing MCP server package..."
    cd "$MCP_DIR"
    # Use pip for editable installs to avoid uv symlink issues
    "$MCP_DIR/.venv/bin/pip" install --quiet -e . 2>&1 | tail -1 || true
    cd - > /dev/null
    echo "  ✅ Azure Pricing MCP installed"
    
    # Health check - verify module imports correctly
    echo "  Running health check..."
    if "$MCP_DIR/.venv/bin/python" -c "from azure_pricing_mcp import server; print('OK')" 2>/dev/null; then
        echo "  ✅ MCP server health check passed"
    else
        echo "  ⚠️  MCP server health check failed (may need manual setup)"
    fi
else
    echo "  ⚠️  MCP directory not found at $MCP_DIR"
fi

# Configure Azure CLI defaults (Azure CLI installed via devcontainer feature)
echo "☁️  Configuring Azure CLI defaults..."
if az config set defaults.location=australiaeast --only-show-errors 2>/dev/null; then
    echo "  ✅ Default location set to australiaeast"
fi
az config set auto-upgrade.enable=no --only-show-errors 2>/dev/null || true

# Verify installations
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Verifying tool installations..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  %-15s %s\n" "Azure CLI:" "$(az version --query '\"azure-cli\"' -o tsv 2>/dev/null || az --version 2>/dev/null | head -n1 || echo '❌ not installed')"
printf "  %-15s %s\n" "Bicep:" "$(az bicep version 2>/dev/null | head -n1 || echo '❌ not installed')"
printf "  %-15s %s\n" "PowerShell:" "$(pwsh --version 2>/dev/null || echo '❌ not installed')"
printf "  %-15s %s\n" "Python:" "$(python3 --version 2>/dev/null || echo '❌ not installed')"
printf "  %-15s %s\n" "Node.js:" "$(node --version 2>/dev/null || echo '❌ not installed')"
printf "  %-15s %s\n" "GitHub CLI:" "$(gh --version 2>/dev/null | head -n1 || echo '❌ not installed')"
printf "  %-15s %s\n" "uv:" "$(uv --version 2>/dev/null || echo '❌ not installed')"
printf "  %-15s %s\n" "Checkov:" "$(checkov --version 2>/dev/null || echo '❌ not installed')"
printf "  %-15s %s\n" "markdownlint:" "$(markdownlint-cli2 --version 2>/dev/null || echo '❌ not installed')"

echo ""
echo "🎉 Post-create setup completed!"
echo ""
echo "📝 Next steps:"
echo "   1. Authenticate: az login"
echo "   2. Set subscription: az account set --subscription <id>"
echo "   3. Explore: cd scenarios/ && tree -L 2"
echo ""
