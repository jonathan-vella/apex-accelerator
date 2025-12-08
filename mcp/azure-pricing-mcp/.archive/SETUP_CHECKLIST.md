# Azure Pricing MCP - Setup Checklist

Use this checklist to ensure everything is configured correctly.

## Installation

### Option A: Python Installation
- [ ] Python 3.10+ installed (`python --version`)
- [ ] Repository cloned to local machine
- [ ] Virtual environment created (`.venv` folder exists)
- [ ] Dependencies installed (`pip list | grep mcp` shows mcp package)
- [ ] Server starts without errors (`python -m azure_pricing_mcp`)

### Option B: Docker Installation 🐳
- [ ] Docker installed and running (`docker --version`)
- [ ] Repository cloned to local machine
- [ ] Docker image built (`docker build -t azure-pricing-mcp .`)
- [ ] Container runs without errors (`docker run -i --rm azure-pricing-mcp:latest`)
- [ ] Image shows in docker images list (`docker images | grep azure-pricing-mcp`)

## VS Code Configuration

- [ ] GitHub Copilot extension installed
- [ ] Created `.vscode/mcp.json` file

**If using Python:**
- [ ] Updated Python path to absolute path of `.venv/Scripts/python.exe` (Windows) or `.venv/bin/python` (Linux/Mac)

**If using Docker:** 🐳
- [ ] Docker is installed and running
- [ ] Config uses `"command": "docker"` with proper args

**For both:**
- [ ] Restarted MCP server from Command Palette (MCP: List Servers → Restart)
- [ ] Verified 6 tools are loaded in MCP server list

## OR Claude Desktop Configuration

- [ ] Found Claude Desktop config file location
  - Windows: `%APPDATA%\Claude\claude_desktop_config.json`
  - Mac: `~/Library/Application Support/Claude/claude_desktop_config.json`
  - Linux: `~/.config/Claude/claude_desktop_config.json`
- [ ] Added `azure-pricing` server configuration with correct `cwd` path
- [ ] Restarted Claude Desktop completely
- [ ] MCP server appears in Claude Desktop tools

## Testing

- [ ] Asked a simple pricing question: "What's the price of a D4s_v3 VM in East US?"
- [ ] Verified MCP tools are being invoked
- [ ] Received pricing data from Azure API
- [ ] Tested with discount: "Apply 10% discount to prices"

## Common Issues

### Tools not showing up?
- Check Python path is **absolute** not relative
- Check Python version is 3.10+
- Try restarting VS Code or Claude Desktop completely
- Check server logs for errors

### Import errors?
- Activate virtual environment first
- Run `pip install -r requirements.txt`
- Check you're using the virtual environment Python

### Connection errors?
- Check internet connection
- Azure Pricing API is public, no auth needed
- Try running tests: `pytest tests/`

## Success! 🎉

If all checkboxes are checked, you're ready to use the Azure Pricing MCP Server!

Try these example queries:
- "What's the price of Standard_D32s_v6 in East US 2?"
- "Compare VM prices between East US and West Europe"
- "Estimate monthly cost for D8s_v5 running 12 hours per day"
- "What App Service plans are available?"
- "Show me GPU VM pricing"

## Need Help?

- 📖 [README.md](README.md) - Full documentation
- 🚀 [QUICK_START.md](QUICK_START.md) - Setup guide- 🐳 [DOCKER.md](DOCKER.md) - Docker guide- 📚 [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md) - Example queries
- 💾 [INSTALL.md](INSTALL.md) - Detailed installation
- 🐛 [GitHub Issues](https://github.com/msftnadavbh/AzurePricingMCP/issues) - Report problems
