#!/bin/bash
set -e

echo "🚀 Running post-create setup..."

# Log output to file for debugging
exec 1> >(tee -a ~/.devcontainer-install.log)
exec 2>&1

# Create directories
echo "📂 Creating cache directories..."
mkdir -p "${HOME}/.terraform-cache"
chmod 755 "${HOME}/.terraform-cache"

# Configure Git safe directory (for mounted volumes)
echo "🔐 Configuring Git..."
git config --global --add safe.directory "${PWD}"
git config --global core.autocrlf input

# Configure Husky git hooks
echo "🪝 Setting up Git hooks (Husky)..."
git config core.hooksPath .husky
if [ -f ".husky/pre-commit" ]; then
    # Try to set executable permission, but don't fail if it doesn't work
    chmod +x .husky/pre-commit 2>/dev/null || true
    if [ -x ".husky/pre-commit" ]; then
        echo "  ✅ Pre-commit hook enabled"
    else
        echo "  ⚠️  Pre-commit hook exists but couldn't set executable (may already be executable)"
    fi
else
    echo "  ⚠️  Pre-commit hook not found"
fi

# Verify Python packages
echo "🐍 Verifying Python packages..."
python3 -c "import checkov; import diagrams" 2>/dev/null && echo "  ✅ checkov and diagrams available" || {
    echo "  Installing checkov and diagrams..."
    pip3 install --quiet --user checkov diagrams 2>&1 | tail -1 || echo "  ⚠️  Installation had issues, continuing..."
}

# Verify markdownlint-cli2
echo "📝 Verifying markdownlint-cli2..."
if command -v markdownlint-cli2 &> /dev/null; then
    echo "  ✅ markdownlint-cli2 already installed"
elif command -v markdownlint &> /dev/null; then
    echo "  ✅ markdownlint already installed"
else
    echo "  ⚠️  markdownlint not found (should have been installed via postCreateCommand)"
fi

# Install Azure PowerShell modules
echo "🔧 Installing Azure PowerShell modules..."
pwsh -NoProfile -Command "
    \$ErrorActionPreference = 'SilentlyContinue'
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    
    \$modules = @('Az.Accounts', 'Az.Resources', 'Az.Storage', 'Az.Network', 'Az.KeyVault', 'Az.Websites')
    
    foreach (\$module in \$modules) {
        if (-not (Get-Module -ListAvailable -Name \$module)) {
            Write-Host \"  Installing \$module...\"
            Install-Module -Name \$module -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck
        } else {
            Write-Host \"  \$module already installed\"
        }
    }
    
    Write-Host '✅ PowerShell modules installed'
" || echo "⚠️  Warning: PowerShell module installation incomplete"

# Install GitHub CLI
echo "📦 Installing GitHub CLI..."
if ! command -v gh &> /dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update && sudo apt-get install -y gh 2>&1 | tail -3
else
    echo "  ✅ GitHub CLI already installed"
fi

# Verify utilities
echo "🛠️  Verifying utilities..."
command -v dot &> /dev/null && echo "  ✅ graphviz available" || echo "  ⚠️  graphviz not found"
command -v dos2unix &> /dev/null && echo "  ✅ dos2unix available" || echo "  ⚠️  dos2unix not found"

# Configure Azure CLI defaults
echo "☁️  Configuring Azure CLI defaults..."
if az config set defaults.location=swedencentral --only-show-errors 2>/dev/null; then
    echo "  ✅ Default location set to swedencentral"
fi
az config set auto-upgrade.enable=no --only-show-errors 2>/dev/null || true

# Verify installations
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Verifying tool installations..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  %-15s %s\n" "Terraform:" "$(terraform version 2>/dev/null | head -n1 || echo '❌ not installed')"
printf "  %-15s %s\n" "Azure CLI:" "$(az version --query '\"azure-cli\"' -o tsv 2>/dev/null || echo '❌ not installed')"
printf "  %-15s %s\n" "Bicep:" "$(az bicep version 2>/dev/null | head -n1 || echo '❌ not installed')"
printf "  %-15s %s\n" "PowerShell:" "$(pwsh --version 2>/dev/null || echo '❌ not installed')"
printf "  %-15s %s\n" "Python:" "$(python3 --version 2>/dev/null || echo '❌ not installed')"
printf "  %-15s %s\n" "Go:" "$(go version 2>/dev/null | awk '{print $3}' || echo '❌ not installed')"
printf "  %-15s %s\n" "Node.js:" "$(node --version 2>/dev/null || echo '❌ not installed')"
printf "  %-15s %s\n" "GitHub CLI:" "$(gh --version 2>/dev/null | head -n1 || echo '❌ not installed')"
printf "  %-15s %s\n" "tfsec:" "$(tfsec --version 2>/dev/null || echo '❌ not installed')"
printf "  %-15s %s\n" "Checkov:" "$(checkov --version 2>/dev/null || echo '❌ not installed')"
printf "  %-15s %s\n" "markdownlint:" "$(markdownlint-cli2 --version 2>/dev/null || echo '❌ not installed')"

echo ""
echo "🎉 Post-create setup completed!"
echo ""
echo "📝 Next steps:"
echo "   1. Authenticate: az login"
echo "   2. Set subscription: az account set --subscription <id>"
echo "   3. Start using agents: Ctrl+Shift+A"
echo ""
