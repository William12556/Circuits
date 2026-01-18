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
- KiCAD 9.0 or higher (confirmed: 9.0.7 installed)
- Node.js 18 or higher (confirmed: v22.21.0 installed)
- Python 3.11 or higher
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

Expected output: `v22.21.0` or higher

### Verify Python Installation

```bash
python3 --version
```

Expected output: `Python 3.11.x` or higher

### Verify KiCAD Python Module

```bash
python3 -c "import pcbnew; print(pcbnew.GetBuildVersion())"
```

Expected output: KiCAD version string (e.g., `9.0.7`)

### Verify KiCAD Installation Path

```bash
ls /Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/
```

Note the Python version directory (typically `3.11` or `3.12`)

### Install uv (if not installed)

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

#### Verify TypeCAD Installation

```bash
npx @typecad/typecad-mcp --help
```

#### TypeCAD Claude Desktop Configuration

Edit Claude Desktop configuration file:

```bash
mkdir -p ~/Library/Application\ Support/Claude
vim ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Add TypeCAD MCP server configuration:

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

This server enables full PCB design automation through natural language commands.

#### Clone Repository

```bash
cd ~/Documents/GitHub
git clone https://github.com/mixelpixx/KiCAD-MCP-Server.git
cd KiCAD-MCP-Server
```

#### Install Dependencies

```bash
npm install
pip3 install -r requirements.txt
```

#### Build Server

```bash
npm run build
```

#### Configure PYTHONPATH

Determine KiCAD Python path:

```bash
ls /Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/
```

Use the version directory (e.g., `3.11`) in the PYTHONPATH configuration below.

#### Add to Claude Desktop Configuration

Edit configuration file:

```bash
vim ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Add mixelpixx server (merge with existing TypeCAD configuration):

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
        "PYTHONPATH": "/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/3.11/lib/python3.11/site-packages",
        "LOG_LEVEL": "info"
      }
    }
  }
}
```

**Note:** Adjust PYTHONPATH Python version (`3.11` or `3.12`) based on system verification results.

[Return to Table of Contents](<#table of contents>)

### lamaalrajih KiCAD MCP Server

This server provides analysis, validation and design rule checking capabilities.

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

This creates a virtual environment in `.venv/` directory.

#### Configure Project Search Paths

```bash
cp .env.example .env
vim .env
```

Add KiCAD project directories:

```bash
# Add paths to KiCAD projects (comma-separated)
KICAD_SEARCH_PATHS=~/Documents/GitHub/KiCAD,~/Documents/PCB,~/Electronics
```

#### Add to Claude Desktop Configuration

Edit configuration file:

```bash
vim ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Add lamaalrajih server (merge with existing configuration):

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
        "PYTHONPATH": "/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/3.11/lib/python3.11/site-packages",
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

[Return to Table of Contents](<#table of contents>)

## Claude Desktop Configuration

### Complete Configuration Example

Final `claude_desktop_config.json` with all three servers:

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
        "PYTHONPATH": "/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/3.11/lib/python3.11/site-packages",
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

Close and reopen Claude Desktop to load MCP server configurations.

[Return to Table of Contents](<#table of contents>)

## Verification

### Verify TypeCAD MCP Server

In Claude Desktop, ask:

```
Create a new typeCAD project called 'test-circuit'
```

Expected: Project creation confirmation

### Verify mixelpixx KiCAD MCP Server

In Claude Desktop, ask:

```
Create a new KiCAD project named 'TestProject' in my Documents folder
```

Expected: Project creation confirmation and file paths

### Verify lamaalrajih KiCAD MCP Server

In Claude Desktop, ask:

```
List my KiCAD projects
```

Expected: List of projects found in configured search paths

### Check MCP Server Status

In Claude Desktop:
1. Click the MCP icon (if visible in interface)
2. Verify three servers appear: `typecad-mcp`, `kicad-design`, `kicad-analysis`
3. Confirm status shows "connected" or "active"

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

### MCP Servers Not Appearing in Claude Desktop

**Solution 1:** Verify configuration file location and syntax

```bash
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Ensure valid JSON syntax with no trailing commas.

**Solution 2:** Check absolute paths are correct

```bash
ls -l /Users/williamwatson/Documents/GitHub/KiCAD-MCP-Server/dist/index.js
ls -l /Users/williamwatson/Documents/GitHub/kicad-mcp/.venv/bin/python
```

**Solution 3:** Restart Claude Desktop completely (Quit and reopen)

### Python Module Import Errors

**Error:** `ModuleNotFoundError: No module named 'pcbnew'`

**Solution:** Verify PYTHONPATH matches KiCAD installation:

```bash
python3 -c "import sys; print('\n'.join(sys.path))"
```

Ensure path includes KiCAD's Python site-packages directory.

**Alternative:** Set PYTHONPATH explicitly in shell profile:

```bash
export PYTHONPATH="/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/3.11/lib/python3.11/site-packages:$PYTHONPATH"
```

### mixelpixx Build Failures

**Error:** `npm run build` fails

**Solution 1:** Clear node modules and reinstall:

```bash
cd ~/Documents/GitHub/KiCAD-MCP-Server
rm -rf node_modules package-lock.json
npm install
npm run build
```

**Solution 2:** Check Node.js version compatibility:

```bash
node --version
```

Ensure v18 or higher.

### lamaalrajih Installation Issues

**Error:** uv installation fails

**Solution:** Install uv via alternative method:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Or use pip:

```bash
pip3 install uv
```

### TypeCAD Command Not Found

**Solution:** Reinstall globally with explicit path:

```bash
npm install -g @typecad/typecad-mcp
which npx
```

Verify npm global bin directory is in PATH:

```bash
npm config get prefix
```

Add to PATH if needed:

```bash
export PATH="$(npm config get prefix)/bin:$PATH"
```

### KiCAD Project Not Found

**Error:** lamaalrajih server cannot find projects

**Solution:** Verify `.env` configuration:

```bash
cd ~/Documents/GitHub/kicad-mcp
cat .env
```

Ensure KICAD_SEARCH_PATHS contains valid directories with KiCAD projects.

### IPC API Not Working (mixelpixx)

**Note:** IPC features are experimental in mixelpixx server.

**Solution:** Enable IPC in KiCAD:

1. Open KiCAD
2. Navigate to Preferences → Plugins
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
| 1.0 | 2026-01-18 | William Watson | Initial installation guide created for TypeCAD and KiCAD MCP servers on macOS M4 |

[Return to Table of Contents](<#table of contents>)

---

Copyright (c) 2025 William Watson. This work is licensed under the MIT License.