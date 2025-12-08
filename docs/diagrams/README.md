# Architecture Diagrams

This folder contains Python-generated architecture diagrams using the `diagrams` library.

## Generating Diagrams

Use the `diagram-generator` agent in Copilot:

1. Press `Ctrl+Shift+A` in VS Code
2. Select `diagram-generator`
3. Describe the architecture you want to visualize

## Prerequisites

```bash
# Python 3.8+
pip install diagrams

# Graphviz (required for PNG generation)
# Windows: choco install graphviz
# macOS: brew install graphviz
# Linux: apt-get install graphviz
```

## Example Usage

```python
from diagrams import Diagram, Cluster
from diagrams.azure.compute import AppServices
from diagrams.azure.database import SQLDatabases

with Diagram("My Architecture", show=False, direction="TB"):
    with Cluster("Azure"):
        app = AppServices("App Service")
        db = SQLDatabases("SQL Database")
        app >> db
```

Generate: `python architecture.py`
