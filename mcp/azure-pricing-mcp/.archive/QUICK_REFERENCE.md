# Quick Reference - Restructured Project

## What Changed?

✅ **Source code** moved to `src/azure_pricing_mcp/`  
✅ **Package renamed** from `azure_pricing_server` to `azure_pricing_mcp`  
✅ **Modern packaging** with `pyproject.toml`  
✅ **Better organization** - tests, scripts, docs separated  
✅ **New tools** - black, ruff, mypy configured  

## Quick Start (New Way)

```bash
# Install
python scripts/install.py

# Run
python -m azure_pricing_mcp
# or
azure-pricing-mcp
```

## MCP Configuration Update

Change your `.vscode/mcp.json` or Claude config:

```json
{
  "command": "python",
  "args": ["-m", "azure_pricing_mcp"]  // Changed from azure_pricing_server
}
```

## Full Documentation

📁 **`docs/MIGRATION_GUIDE.md`** - Step-by-step migration  
📁 **`docs/PROJECT_STRUCTURE.md`** - New structure explained  
📁 **`docs/DEVELOPMENT.md`** - Development workflow  
📁 **`docs/RESTRUCTURING_SUMMARY.md`** - Complete change list  

## Need Help?

1. Read the migration guide
2. Check the project structure docs
3. Open a GitHub issue
