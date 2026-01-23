# Quick Start Guide 🚀

Get the Azure Pricing MCP Server running in under 5 minutes.

---

## Prerequisites

- **Python 3.10+** ([Download](https://www.python.org/downloads/))
- **VS Code** with [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) extension  
  *— OR —*  
- **Claude Desktop** app

---

## Step 1: Clone & Setup

```bash
# Clone the repository
git clone https://github.com/msftnadavbh/AzurePricingMCP.git
cd AzurePricingMCP

# Create virtual environment
python -m venv .venv

# Activate virtual environment
source .venv/bin/activate    # Linux/Mac
.venv\Scripts\activate       # Windows

# Install dependencies
pip install -r requirements.txt
```

**Or use the automated setup:**
```bash
python scripts/install.py    # Cross-platform
.\scripts\setup.ps1          # Windows PowerShell
```

---

## Step 2: Verify Installation

```bash
# Test the server starts without errors
python -m azure_pricing_mcp
```

Press `Ctrl+C` to stop. If it starts without errors, you're ready!

---

## Step 3: Configure Your AI Assistant

### Option A: VS Code + GitHub Copilot

#### Method 1: stdio with Python

1. Create `.vscode/mcp.json` in your workspace (or this repo):

```jsonc
{
  "servers": {
    "azure-pricing": {
      "type": "stdio",
      "command": "/absolute/path/to/AzurePricingMCP/.venv/bin/python",
      "args": ["-m", "azure_pricing_mcp"]
    }
  }
}
```

> ⚠️ **Important**: Use the **absolute path** to your Python executable!

**Find your Python path:**
```bash
# Linux/Mac
which python
# or after activating venv:
echo $VIRTUAL_ENV/bin/python

# Windows
where python
# or after activating venv:
echo %VIRTUAL_ENV%\Scripts\python.exe
```

#### Method 2: SSE with Docker 🐳

1. Build and run the Docker container:

```bash
# Build the image
docker build -t azure-pricing-mcp .

# Run with port mapping
docker run -d -p 8080:8080 --name azure-pricing azure-pricing-mcp

# Verify it's running
docker ps
```

2. Create `.vscode/mcp.json` or add to VS Code User settings:

```json
{
  "servers": {
    "azure-pricing": {
      "type": "sse",
      "url": "http://localhost:8080/sse"
    }
  }
}
```

> 💡 **Tip**: SSE transport provides better isolation and allows multiple clients to connect to the same server instance.

2. Restart the MCP server:
   - Open Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`)
   - Run: **MCP: List Servers**
   - Click refresh/restart next to `azure-pricing`

3. Verify tools are loaded:
   - You should see **6 tools** available

---

### Option B: Claude Desktop

1. Find your config file:
   - **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
   - **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
   - **Linux**: `~/.config/Claude/claude_desktop_config.json`

2. Add the server configuration:

```json
{
  "mcpServers": {
    "azure-pricing": {
      "command": "python",
      "args": ["-m", "azure_pricing_mcp"],
      "cwd": "/absolute/path/to/AzurePricingMCP"
    }
  }
}
```

3. Restart Claude Desktop completely (quit and reopen)

---

## Step 4: Test It Out! 🎉

Open Copilot Chat (VS Code) or Claude Desktop and try:

```
What's the price of a Standard_D4s_v3 VM in East US?
```

You should see the MCP tools being invoked and real Azure pricing data returned!

### More Example Queries

| Query | What It Does |
|-------|--------------|
| "Price for 20 D32s_v6 nodes in eastus2" | Get VM pricing with node calculation |
| "Compare storage prices: eastus vs westeurope" | Cross-region comparison |
| "Estimate monthly cost for D8s_v5 running 12hr/day" | Usage-based cost estimation |
| "What App Service plans are available?" | SKU discovery with fuzzy matching |
| "Show me GPU VM pricing" | Search specific VM types |

---

## Available Tools

| Tool | Description |
|------|-------------|
| `azure_price_search` | Search prices with filters (service, region, SKU) |
| `azure_price_compare` | Compare prices across regions or SKUs |
| `azure_cost_estimate` | Estimate costs based on usage hours |
| `azure_region_recommend` | Find cheapest regions for a SKU with savings percentages |
| `azure_discover_skus` | List available SKUs for a service |
| `azure_sku_discovery` | Smart SKU discovery with fuzzy matching |
| `get_customer_discount` | Get customer discount information |

---

## Troubleshooting

### Tools not appearing in VS Code

1. **Check the path**: Must be absolute, not relative
2. **Check Python version**: Needs 3.10+
3. **Restart MCP**: Command Palette → MCP: List Servers → Restart
4. **Check for syntax errors**: Run `python -m azure_pricing_server` manually

### "No module named 'mcp'"

```bash
# Make sure you're in the virtual environment
source .venv/bin/activate
pip install -r requirements.txt
```

### Server crashes on startup

Check for Python syntax errors:
```bash
python -c "import azure_pricing_mcp"
```

### No results returned

- Service names are case-sensitive: use `Virtual Machines` not `virtual machines`
- Region names use Azure format: `eastus`, `westeurope`, `eastus2`
- Try broader searches first, then narrow down

---

## Next Steps

- 📖 Read [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md) for detailed query patterns
- 🔧 Check [README.md](README.md) for full documentation
- 🤝 [Contribute](README.md#-contributing) to the project!

---

## Quick Reference

```bash
# Start server manually (for testing)
python -m azure_pricing_mcp

# Run tests
pytest tests/

# Check Python path (Linux/Mac)
echo $VIRTUAL_ENV/bin/python

# Check Python path (Windows)
echo %VIRTUAL_ENV%\Scripts\python.exe
```

---

<p align="center">
  <b>Need help?</b> Open an <a href="https://github.com/msftnadavbh/AzurePricingMCP/issues">issue</a> on GitHub!
</p>
