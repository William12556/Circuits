# TypeCAD and KiCAD MCP Server Installation Guide

Created: 2026 January 18

## Table of Contents

- [Overview](<#overview>)
- [Prerequisites](<#prerequisites>)
- [System Verification](<#system verification>)
- [Installation Steps](<#installation steps>)
  - [TypeCAD Installation](<#typecad installation>)
  - [mixelpixx KiCAD MCP Server](<#mixelpixx kicad mcp server>)
  - [lamaalrajih KiCAD MCP Server](<#lamaalrajih kicad mcp server>)
- [Claude Desktop Configuration](<#claude desktop configuration>)
- [Verification](<#verification>)
- [Usage Examples](<#usage examples>)
- [Troubleshooting](<#troubleshooting>)
- [References](<#references>)
- [Version History](<#version history>)

## Overview

This document provides installation instructions for TypeCAD and two complementary KiCAD MCP servers on Apple Silicon (M4) Mac Mini running KiCAD 9.0.7.

**MCP Server Selection:**
- **mixelpixx/KiCAD-MCP-Server**: Full design automation for agentic circuit creation
- **lamaalrajih/kicad-mcp**: Analysis and validation for design review
- **@typecad/typecad-mcp**: TypeScript-based hardware design automation

[Return to Table of Contents](<#table of contents>)

## Prerequisites

**Required Software:**
- KiCAD 9.0 or higher (confirmed: 9.0.7 with bundled Python 3.9)
- Node.js 18 or higher (confirmed: v22.14.0)
- Python 3.11+ system installation (confirmed: 3.11.14)
- Claude Desktop application
- uv (Python package installer) for lamaalrajih server
- Git

**System Requirements:**
- macOS (Apple Silicon M4 tested)
- 4GB RAM minimum
- 2GB disk space for MCP servers and dependencies

[Return to Table of Contents](<#table of contents>)

## System Verification

### Verify Node.js Installation

```bash
node --version
```

Expected: `v22.14.0` or higher

### Verify Python Installation

```bash
python3 --version
```

Expected: `Python 3.11.14` or higher

### Verify KiCAD Python Module

**CRITICAL:** Use KiCAD's bundled Python 3.9, not system Python.

```bash
/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/3.9/bin/python3 -c "import pcbnew; print(pcbnew.GetBuildVersion())"
```

Expected: `9.0.7`

### Verify KiCAD Python Path

```bash
ls /Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/3.9/bin/
```

Confirm `python3` executable exists.

### Install uv

```bash
brew install uv
```

Or:

```bash
pipx install uv
```

[Return to Table of Contents](<#table of contents>)

## Installation Steps

### TypeCAD Installation

#### Install TypeCAD Globally

```bash
npm install -g @typecad/typecad-mcp
```

#### Verify Installation

```bash
npx @typecad/typecad-mcp --help
```

#### Claude Desktop Configuration

```bash
mkdir -p ~/Library/Application\ Support/Claude
vim ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Add configuration:

```json
{
  "mcpServers": {
    "typecad-mcp": {
      "command": "npx",
      "args": ["-y", "@typecad/typecad-mcp"],
      "env": {}
    }
  }
}
```

[Return to Table of Contents](<#table of contents>)

### mixelpixx KiCAD MCP Server

#### Clone Repository

```bash
cd ~/Documents/GitHub
git clone https://github.com/mixelpixx/KiCAD-MCP-Server.git
cd KiCAD-MCP-Server
```

#### Install Dependencies

```bash
npm install
/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/3.9/bin/pip3 install -r requirements.txt
```

**Note:** Using KiCAD's pip to install Python dependencies in KiCAD's environment.

#### Build Server

```bash
npm run build
```

#### Configure KiCAD Library Tables

**CRITICAL:** KiCAD MCP requires library tables to access footprint and symbol libraries.

**Check if library tables exist:**

```bash
ls ~/Library/Preferences/kicad/9.0/fp-lib-table
ls ~/Library/Preferences/kicad/9.0/sym-lib-table
```

**If files do not exist, copy templates:**

```bash
cp /Applications/KiCad/KiCad.app/Contents/SharedSupport/template/fp-lib-table ~/Library/Preferences/kicad/9.0/
cp /Applications/KiCad/KiCad.app/Contents/SharedSupport/template/sym-lib-table ~/Library/Preferences/kicad/9.0/
```

#### Add to Claude Desktop Configuration

```bash
vim ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Add server (merge with TypeCAD):

```json
{
  "mcpServers": {
    "typecad-mcp": {
      "command": "npx",
      "args": ["-y", "@typecad/typecad-mcp"],
      "env": {}
    },
    "kicad-design": {
      "command": "node",
      "args": ["/Users/williamwatson/Documents/GitHub/KiCAD-MCP-Server/dist/index.js"],
      "env": {
        "PYTHON_PATH": "/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/3.9/bin/python3",
        "LOG_LEVEL": "info",
        "KICAD_CONFIG_HOME": "/Users/williamwatson/Library/Preferences/kicad/9.0",
        "KICAD9_FOOTPRINT_DIR": "/Applications/KiCad/KiCad.app/Contents/SharedSupport/footprints",
        "KICAD9_SYMBOL_DIR": "/Applications/KiCad/KiCad.app/Contents/SharedSupport/symbols"
      }
    }
  }
}
```

**CRITICAL:** 
- MCP server uses `PYTHON_PATH` to specify KiCAD's Python interpreter
- `KICAD_CONFIG_HOME` points to version-specific configuration directory
- `KICAD9_FOOTPRINT_DIR` and `KICAD9_SYMBOL_DIR` resolve library table paths

[Return to Table of Contents](<#table of contents>)

### lamaalrajih KiCAD MCP Server

#### Clone Repository

```bash
cd ~/Documents/GitHub
git clone https://github.com/lamaalrajih/kicad-mcp.git
cd kicad-mcp
```

#### Install Dependencies with uv

```bash
make install
```

Creates virtual environment in `.venv/`.

#### Configure Project Search Paths

```bash
cp .env.example .env
vim .env
```

Add project directories:

```bash
KICAD_SEARCH_PATHS=~/Documents/GitHub/KiCAD,~/Documents/PCB,~/Electronics
```

#### Add to Claude Desktop Configuration

```bash
vim ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Add server (merge with existing):

```json
{
  "mcpServers": {
    "typecad-mcp": {
      "command": "npx",
      "args": ["-y", "@typecad/typecad-mcp"],
      "env": {}
    },
    "kicad-design": {
      "command": "node",
      "args": ["/Users/williamwatson/Documents/GitHub/KiCAD-MCP-Server/dist/index.js"],
      "env": {
        "PYTHON_PATH": "/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/3.9/bin/python3",
        "LOG_LEVEL": "info",
        "KICAD_CONFIG_HOME": "/Users/williamwatson/Library/Preferences/kicad/9.0",
        "KICAD9_FOOTPRINT_DIR": "/Applications/KiCad/KiCad.app/Contents/SharedSupport/footprints",
        "KICAD9_SYMBOL_DIR": "/Applications/KiCad/KiCad.app/Contents/SharedSupport/symbols"
      }
    },
    "kicad-analysis": {
      "command": "/Users/williamwatson/Documents/GitHub/kicad-mcp/.venv/bin/python",
      "args": ["/Users/williamwatson/Documents/GitHub/kicad-mcp/main.py"]
    }
  }
}
```

[Return to Table of Contents](<#table of contents>)

## Claude Desktop Configuration

### Complete Configuration

Final `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "typecad-mcp": {
      "command": "npx",
      "args": ["-y", "@typecad/typecad-mcp"],
      "env": {}
    },
    "kicad-design": {
      "command": "node",
      "args": ["/Users/williamwatson/Documents/GitHub/KiCAD-MCP-Server/dist/index.js"],
      "env": {
        "PYTHON_PATH": "/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/3.9/bin/python3",
        "LOG_LEVEL": "info"
      }
    },
    "kicad-analysis": {
      "command": "/Users/williamwatson/Documents/GitHub/kicad-mcp/.venv/bin/python",
      "args": ["/Users/williamwatson/Documents/GitHub/kicad-mcp/main.py"]
    }
  }
}
```

### Restart Claude Desktop

Quit and reopen Claude Desktop.

[Return to Table of Contents](<#table of contents>)

## Verification

### Verify TypeCAD

```
Create a new typeCAD project called 'test-circuit'
```

### Verify mixelpixx KiCAD MCP

```
Create a new KiCAD project named 'TestProject' in my Documents folder
```

### Verify lamaalrajih KiCAD MCP

```
List my KiCAD projects
```

### Check MCP Status

In Claude Desktop, verify three servers show as connected: `typecad-mcp`, `kicad-design`, `kicad-analysis`.

[Return to Table of Contents](<#table of contents>)

## Usage Examples

### TypeCAD Workflow

```
Create a new typeCAD project called 'sensor-board'
Add an ESP32-S3 microcontroller
Add a 10k resistor and 0.1uF capacitor
Connect them to form a voltage divider
Build the project
```

### mixelpixx KiCAD Design Workflow

```
Create a new KiCAD project named 'LEDBoard' in ~/Documents/GitHub/KiCAD
Set the board size to 50mm x 50mm
Add a rectangular board outline
Place mounting holes at each corner, 3mm from edges, 3mm diameter
Place an LED at x=10mm, y=10mm using footprint LED_SMD:LED_0805_2012Metric
Create a grid of 4 resistors starting at x=20mm, y=20mm with 5mm spacing
```

### lamaalrajih KiCAD Analysis Workflow

```
List my KiCAD projects
Run a DRC check on project 'LEDBoard'
Show me the schematic components in 'LEDBoard'
Generate a BOM for 'LEDBoard'
Analyze the PCB design statistics
```

### Combined Workflow

```
1. Create design with mixelpixx: "Create a power supply circuit with LM7805"
2. Validate with lamaalrajih: "Run DRC check on the power supply project"
3. Export with mixelpixx: "Export Gerber files for manufacturing"
```

[Return to Table of Contents](<#table of contents>)

## Troubleshooting

### MCP Servers Not Appearing

**Verify configuration syntax:**

```bash
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

**Check paths:**

```bash
ls -l /Users/williamwatson/Documents/GitHub/KiCAD-MCP-Server/dist/index.js
ls -l /Users/williamwatson/Documents/GitHub/kicad-mcp/.venv/bin/python
```

**Restart Claude Desktop** completely.

### Python Module Import Errors

**Error:** `ModuleNotFoundError: No module named 'pcbnew'`

**Solution:** Verify KiCAD Python interpreter:

```bash
/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/3.9/bin/python3 -c "import pcbnew; print(pcbnew.GetBuildVersion())"
```

Should output: `9.0.7`

**Error:** `ImportError: Library not loaded: libwx_osx_cocoau_gl-3.2.0.dylib`

**Cause:** Using system Python instead of KiCAD's bundled Python.

**Solution:** MCP servers must use KiCAD's Python via `PYTHON_PATH` environment variable or direct interpreter path.

### Library Loading Errors

**Symptom:** Server logs show:
```
[WARNING] Global fp-lib-table not found
[INFO] Loaded 0 footprint libraries
[INFO] Loaded 0 symbol libraries
```

**Cause:** Missing library table files in user configuration directory.

**Solution:** Copy template library tables:

```bash
cp /Applications/KiCad/KiCad.app/Contents/SharedSupport/template/fp-lib-table ~/Library/Preferences/kicad/9.0/
cp /Applications/KiCad/KiCad.app/Contents/SharedSupport/template/sym-lib-table ~/Library/Preferences/kicad/9.0/
```

**Verify environment variables in MCP config:**

```json
"env": {
  "KICAD_CONFIG_HOME": "/Users/williamwatson/Library/Preferences/kicad/9.0",
  "KICAD9_FOOTPRINT_DIR": "/Applications/KiCad/KiCad.app/Contents/SharedSupport/footprints",
  "KICAD9_SYMBOL_DIR": "/Applications/KiCad/KiCad.app/Contents/SharedSupport/symbols"
}
```

**Verify successful loading in logs:**

```bash
tail -50 ~/Library/Logs/Claude/mcp-server-kicad-design.log | grep "Loaded.*libraries"
```

Expected output:
```
[INFO] Loaded 155 footprint libraries
[INFO] Loaded 223 symbol libraries
```

### mixelpixx Build Failures

```bash
cd ~/Documents/GitHub/KiCAD-MCP-Server
rm -rf node_modules package-lock.json
npm install
npm run build
```

### lamaalrajih Installation Issues

Install uv via alternative:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### TypeCAD Command Not Found

```bash
npm install -g @typecad/typecad-mcp
npm config get prefix
```

Add npm bin to PATH:

```bash
export PATH="$(npm config get prefix)/bin:$PATH"
```

### KiCAD Project Not Found

Verify `.env`:

```bash
cd ~/Documents/GitHub/kicad-mcp
cat .env
```

### IPC API Not Working

Enable in KiCAD:
1. Open KiCAD
2. Preferences → Plugins
3. Enable "IPC API Server"
4. Restart KiCAD

[Return to Table of Contents](<#table of contents>)

## References

1. TypeCAD Official Documentation. Available at: https://typecad.net/getting-started [Accessed: 2026-01-18]

2. TypeCAD MCP Server npm Package. Available at: https://www.npmjs.com/package/@typecad/typecad-mcp [Accessed: 2026-01-18]

3. mixelpixx. KiCAD-MCP-Server GitHub Repository. Available at: https://github.com/mixelpixx/KiCAD-MCP-Server [Accessed: 2026-01-18]

4. lamaalrajih. kicad-mcp GitHub Repository. Available at: https://github.com/lamaalrajih/kicad-mcp [Accessed: 2026-01-18]

5. Anthropic. Model Context Protocol Documentation. Available at: https://modelcontextprotocol.io [Accessed: 2026-01-18]

6. KiCAD Project. KiCAD EDA Official Website. Available at: https://www.kicad.org [Accessed: 2026-01-18]

[Return to Table of Contents](<#table of contents>)

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-18 | William Watson | Initial installation guide |
| 1.1 | 2026-01-18 | William Watson | Corrected Python paths for KiCAD 9.0.7 Python 3.9 |
| 1.2 | 2026-01-18 | William Watson | Updated to use KiCAD bundled Python interpreter directly, resolved library loading issues |
| 1.3 | 2026-01-18 | William Watson | Added library table configuration and environment variables for KICAD9 library resolution |

[Return to Table of Contents](<#table of contents>)

---

Copyright (c) 2025 William Watson. This work is licensed under the MIT License.