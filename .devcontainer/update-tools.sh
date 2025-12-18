#!/bin/bash
set -e

echo "🔄 Updating development tools..."
echo ""

# Track failures
FAILURES=()

# Update Azure CLI
echo "📦 Checking Azure CLI..."
CURRENT_AZ=$(az version --query '"azure-cli"' -o tsv 2>/dev/null || echo "unknown")
echo "   ℹ️  Current version: $CURRENT_AZ (managed by devcontainer feature, auto-upgrade disabled)"

# Update Bicep
echo "📦 Updating Bicep..."
if az bicep upgrade --only-show-errors 2>/dev/null; then
    echo "   ✅ Bicep updated"
else
    echo "   ⚠️  Bicep update skipped or failed"
    FAILURES+=("Bicep")
fi

# Update Terraform (informational - managed by devcontainer feature)
echo "📦 Checking Terraform version..."
CURRENT_TF=$(terraform version -json 2>/dev/null | jq -r '.terraform_version' || echo "unknown")
echo "   ℹ️  Current version: $CURRENT_TF (managed by devcontainer feature)"

# Update tfsec
echo "📦 Updating tfsec..."
if command -v tfsec &> /dev/null; then
    CURRENT_TFSEC=$(tfsec --version 2>/dev/null || echo "unknown")
    echo "   ℹ️  Current version: $CURRENT_TFSEC (managed by devcontainer feature)"
fi

# Update PowerShell modules (PowerShell itself managed by devcontainer feature)
echo "📦 Updating PowerShell modules..."
if command -v pwsh &> /dev/null && pwsh -NoProfile -Command "
    \$ErrorActionPreference = 'SilentlyContinue'
    \$modules = @('Az.Accounts', 'Az.Resources', 'Az.Storage', 'Az.Network', 'Az.KeyVault', 'Az.Websites')
    foreach (\$module in \$modules) {
        Write-Host \"   Updating \$module...\"
        Update-Module -Name \$module -Force -ErrorAction SilentlyContinue
    }
    Write-Host '   ✅ PowerShell modules updated'
" 2>/dev/null; then
    :
else
    echo "   ⚠️  PowerShell module updates had issues"
    FAILURES+=("PowerShell modules")
fi

# Update Python packages
echo "📦 Updating Python packages..."
if pip3 install --upgrade --quiet --break-system-packages checkov diagrams 2>/dev/null; then
    echo "   ✅ Python packages updated (checkov, diagrams)"
else
    echo "   ⚠️  Python package updates had issues"
    FAILURES+=("Python packages")
fi

# Update markdownlint
echo "📦 Updating markdownlint-cli..."
if sudo npm update -g markdownlint-cli --silent 2>/dev/null; then
    echo "   ✅ markdownlint-cli updated"
else
    echo "   ⚠️  markdownlint-cli update had issues"
    FAILURES+=("markdownlint-cli")
fi

# Update Go modules
echo "📦 Updating Go modules..."
if command -v go &> /dev/null; then
    if go install github.com/gruntwork-io/terratest/modules/terraform@latest 2>/dev/null; then
        echo "   ✅ Terratest updated"
    else
        echo "   ⚠️  Terratest update had issues"
        FAILURES+=("Terratest")
    fi
else
    echo "   ⚠️  Go not available, skipping Terratest"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ ${#FAILURES[@]} -eq 0 ]; then
    echo "✅ All tool updates completed successfully!"
else
    echo "⚠️  Updates completed with some issues:"
    for fail in "${FAILURES[@]}"; do
        echo "   - $fail"
    done
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Show current versions
echo "📊 Current tool versions:"
printf "   %-15s %s\n" "Azure CLI:" "$(az version --query '\"azure-cli\"' -o tsv 2>/dev/null || echo 'unknown')"
printf "   %-15s %s\n" "Bicep:" "$(az bicep version 2>/dev/null || echo 'unknown')"
printf "   %-15s %s\n" "Terraform:" "$(terraform version 2>/dev/null | head -n1 | awk '{print $2}' || echo 'unknown')"
printf "   %-15s %s\n" "tfsec:" "$(tfsec --version 2>/dev/null || echo 'unknown')"
printf "   %-15s %s\n" "Checkov:" "$(checkov --version 2>/dev/null || echo 'unknown')"
printf "   %-15s %s\n" "markdownlint:" "$(markdownlint --version 2>/dev/null || echo 'unknown')"
echo ""
