# Azure Pricing MCP - Project Structure

This document explains the new project structure following Python best practices.

## Directory Structure

```
AzurePricingMCP/
├── src/
│   └── azure_pricing_mcp/          # Main package
│       ├── __init__.py             # Package initialization
│       ├── __main__.py             # Module entry point
│       ├── server.py               # Main server implementation
│       └── handlers.py             # Tool call handlers
│
├── tests/                          # Test files
│   ├── test_mcp.py
│   ├── test_mcp_server.py
│   └── simulate_mcp_call.py
│
├── scripts/                        # Utility scripts
│   ├── install.py                 # Installation script
│   ├── run_server.py              # Server runner
│   ├── setup.ps1                  # PowerShell setup
│   ├── docker-build.sh            # Docker build script (Linux/Mac)
│   ├── docker-build.ps1           # Docker build script (Windows)
│   └── debug_*.py                 # Debug utilities
│
├── docs/                          # Documentation
│   ├── QUICK_START.md
│   ├── USAGE_EXAMPLES.md
│   ├── PROJECT_STRUCTURE.md
│   └── config_examples.json
│
├── .vscode/                       # VS Code configuration
│   └── mcp.json.example           # MCP config template
│
├── Dockerfile                     # Docker image definition
├── docker-compose.yml             # Docker Compose configuration
├── .dockerignore                  # Docker build exclusions
├── pyproject.toml                 # Modern Python packaging config
├── setup.py                       # Setup script (backward compatible)
├── requirements.txt               # Dependencies
├── README.md                      # Main documentation
├── INSTALL.md                     # Installation guide
├── DOCKER.md                      # Docker guide
├── SETUP_CHECKLIST.md             # Setup verification
├── MANIFEST.in                    # Package data inclusion
└── .gitignore                     # Git ignore patterns
```

## Key Improvements

### 1. **Src Layout**
- Source code is in `src/azure_pricing_mcp/` following the "src layout" pattern
- Prevents accidental imports from the project root
- Ensures tests run against the installed package

### 2. **Modern Packaging**
- `pyproject.toml` - PEP 518/517 compliant packaging configuration
- `setup.py` - Maintained for backward compatibility
- `MANIFEST.in` - Controls what files are included in distributions

### 3. **Clear Separation**
- **Source code**: `src/azure_pricing_mcp/`
- **Tests**: `tests/`
- **Scripts**: `scripts/` (utilities, debug tools)
- **Documentation**: `docs/` and root-level markdown files

### 4. **Package Organization**
- `server.py` - Core server logic and API client
- `handlers.py` - MCP tool call handlers (separated for clarity)
- `__init__.py` - Package exports and version
- `__main__.py` - Module execution entry point

## Installation

### Development Installation

```bash
# Run the installation script
python scripts/install.py

# Or manually:
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -e .[dev]
```

### Production Installation

```bash
pip install .
```

Or from PyPI (when published):
```bash
pip install azure-pricing-mcp
```

## Running the Server

### Method 1: Module execution
```bash
python -m azure_pricing_mcp
```

### Method 2: Console script (after installation)
```bash
azure-pricing-mcp
```

### Method 3: Use the run script
```bash
python scripts/run_server.py
```

## Development Workflow

### Setting up for development
```bash
# Install in editable mode with dev dependencies
pip install -e .[dev]
```

### Code formatting
```bash
# Format code with black
black src/ tests/

# Lint with ruff
ruff check src/ tests/
```

### Type checking
```bash
mypy src/
```

### Running tests
```bash
pytest tests/
```

## VS Code / MCP Client Configuration

Update your MCP configuration to use the new package name:

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

Or use the installed console script:

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

## Benefits of This Structure

1. **Professional**: Follows established Python packaging standards
2. **Testable**: Clear separation enables better testing practices
3. **Installable**: Can be installed via pip and distributed on PyPI
4. **Maintainable**: Logical organization makes code easier to navigate
5. **Extensible**: Easy to add new modules and features
6. **Modern**: Uses latest Python packaging tools and conventions

## Migration Notes

If you have existing installations:

1. **Old import**: `import azure_pricing_server` → **New import**: `import azure_pricing_mcp`
2. **Old command**: `python -m azure_pricing_server` → **New command**: `python -m azure_pricing_mcp`
3. **Update MCP configs** to reference the new module name
4. **Reinstall** using the new installation method

## Additional Resources

- [Python Packaging User Guide](https://packaging.python.org/)
- [PEP 517 - Backend Interface](https://peps.python.org/pep-0517/)
- [PEP 518 - Build System](https://peps.python.org/pep-0518/)
- [Src Layout vs Flat Layout](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/)
