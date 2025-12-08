# Migration Guide - Azure Pricing MCP v2.0

## Overview

Version 2.0 restructures the project following Python best practices. This guide helps you migrate from the old structure to the new one.

## What Changed?

### 1. Project Structure
- Source code moved to `src/azure_pricing_mcp/`
- Tests organized in `tests/` directory
- Utility scripts moved to `scripts/`
- Documentation consolidated in `docs/`

### 2. Package Name
- **Old**: `azure_pricing_server`
- **New**: `azure_pricing_mcp`

### 3. Installation Method
- Now uses modern Python packaging (`pyproject.toml`)
- Installable via pip in development mode
- Can be distributed on PyPI

## Migration Steps

### Step 1: Update Your Environment

```bash
# Remove old virtual environment (optional but recommended)
rm -rf .venv  # On Windows: Remove-Item -Recurse -Force .venv

# Run the new installation script
python scripts/install.py

# Or install manually
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -e .[dev]
```

### Step 2: Update Import Statements

If you have any custom code importing the package:

**Before:**
```python
from azure_pricing_server import AzurePricingServer
import azure_pricing_server
```

**After:**
```python
from azure_pricing_mcp import AzurePricingServer
import azure_pricing_mcp
```

### Step 3: Update Run Commands

**Before:**
```bash
python -m azure_pricing_server
python azure_pricing_server.py
```

**After:**
```bash
python -m azure_pricing_mcp
# Or use the console script:
azure-pricing-mcp
# Or use the runner script:
python scripts/run_server.py
```

### Step 4: Update MCP Configuration

Update your MCP client configuration files:

#### VS Code (`.vscode/mcp.json`)

**Before:**
```json
{
  "servers": {
    "azure-pricing": {
      "type": "stdio",
      "command": "/path/to/.venv/bin/python",
      "args": ["-m", "azure_pricing_server"]
    }
  }
}
```

**After:**
```json
{
  "servers": {
    "azure-pricing": {
      "type": "stdio",
      "command": "/path/to/.venv/bin/python",
      "args": ["-m", "azure_pricing_mcp"]
    }
  }
}
```

Or use the console script:
```json
{
  "servers": {
    "azure-pricing": {
      "type": "stdio",
      "command": "azure-pricing-mcp"
    }
  }
}
```

#### Claude Desktop

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`  
**Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

**Before:**
```json
{
  "mcpServers": {
    "azure-pricing": {
      "command": "python",
      "args": ["-m", "azure_pricing_server"],
      "cwd": "/path/to/AzurePricingMCP"
    }
  }
}
```

**After:**
```json
{
  "mcpServers": {
    "azure-pricing": {
      "command": "python",
      "args": ["-m", "azure_pricing_mcp"],
      "cwd": "/path/to/AzurePricingMCP"
    }
  }
}
```

### Step 5: Restart MCP Server

After updating configuration:

1. **VS Code**: 
   - Open Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`)
   - Run: **MCP: List Servers**
   - Click restart button next to `azure-pricing`

2. **Claude Desktop**:
   - Restart Claude Desktop application

## Verification

Test that everything works:

```bash
# Activate environment
source .venv/bin/activate  # Windows: .venv\Scripts\activate

# Test import
python -c "import azure_pricing_mcp; print(azure_pricing_mcp.__version__)"

# Should print: 2.1.0

# Test server
python -m azure_pricing_mcp
# Should start without errors
```

## New Features in v2.0

### Development Tools

```bash
# Code formatting
black src/ tests/

# Linting
ruff check src/ tests/

# Type checking
mypy src/

# Run tests
pytest tests/
```

### Improved Scripts

- `scripts/install.py` - Automated setup and installation
- `scripts/run_server.py` - Quick server runner
- Debug utilities organized in `scripts/`

### Better Documentation

- `docs/PROJECT_STRUCTURE.md` - Detailed structure explanation
- `docs/QUICK_START.md` - Quick start guide
- `docs/USAGE_EXAMPLES.md` - Usage examples

## Troubleshooting

### "Module not found: azure_pricing_mcp"

**Solution**: Reinstall the package
```bash
cd /path/to/AzurePricingMCP
pip install -e .
```

### "Command 'azure-pricing-mcp' not found"

**Solution**: Ensure you've installed the package and are in the correct virtual environment
```bash
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -e .
```

### MCP Server Not Starting

1. Check your MCP configuration file for typos
2. Verify the Python path is correct
3. Ensure you're using `azure_pricing_mcp` (new name) not `azure_pricing_server` (old name)
4. Check server logs in your MCP client

### Import Errors

If you see import errors about missing modules:

```bash
pip install -r requirements.txt
# Or
pip install -e .[dev]
```

## Old Files Cleanup (Optional)

The old root-level files are no longer needed. You can safely remove:

```bash
# These are replaced by the new structure
rm __init__.py
rm __main__.py  
rm azure_pricing_server.py
```

**Note**: Keep these files temporarily if you want to compare or have active deployments using the old structure.

## Rollback (If Needed)

If you need to rollback to the old version:

1. Checkout the previous commit (before restructuring)
2. Reinstall dependencies
3. Update your MCP configs to use old module name

```bash
git checkout <previous-commit>
pip install -r requirements.txt
# Update configs to use azure_pricing_server
```

## Support

If you encounter issues:

1. Check [docs/PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)
2. Review [README.md](../README.md)
3. Open an issue on GitHub

## Summary

The v2.0 restructuring provides:

✅ **Professional structure** following Python best practices  
✅ **Better maintainability** with clear code organization  
✅ **Easier testing** with proper test isolation  
✅ **Improved development** with modern tooling  
✅ **PyPI ready** for easy distribution  

The migration is straightforward - mainly updating import names and run commands!
