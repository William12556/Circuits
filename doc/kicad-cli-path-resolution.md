# KiCAD CLI PATH Resolution Issue

Created: 2026 January 22

## Table of Contents

- [Problem Description](#problem-description)
- [Root Cause](#root-cause)
- [Error Symptoms](#error-symptoms)
- [Resolution](#resolution)
- [Verification](#verification)
- [Prevention](#prevention)
- [Related Documentation](#related-documentation)
- [Version History](#version-history)

[Return to Table of Contents](#table-of-contents)

---

## Problem Description

TypeCAD build process failed when attempting to upgrade footprints, resulting in a `kicad-cli: command not found` error. The build successfully generated PCB and netlist files but crashed during the footprint upgrade phase.

### Affected System

- **OS**: macOS (Apple Silicon M4 Mac Mini)
- **KiCAD Version**: 9.0.7
- **TypeCAD Version**: Latest (via npm)
- **Installation Path**: `/Applications/KiCad/KiCad.app`

[Return to Table of Contents](#table-of-contents)

---

## Root Cause

The `kicad-cli` executable was not available in the system PATH environment variable. While KiCAD 9.0.7 was properly installed, the command-line interface tools located at `/Applications/KiCad/KiCad.app/Contents/MacOS/` were not accessible to shell processes.

TypeCAD's build process requires `kicad-cli` to:
1. Upgrade footprint files to current KiCAD format
2. Execute DRC checks
3. Export PCB files in various formats

[Return to Table of Contents](#table-of-contents)

---

## Error Symptoms

### Terminal Output

```
Error: KiCAD command failed: kicad-cli fp upgrade ./build/lib/footprints/
Error: Command failed: kicad-cli fp upgrade ./build/lib/footprints/
/bin/sh: kicad-cli: command not found

    at executeKiCADCommand (file:///Users/williamwatson/Documents/GitHub/Circuits/led-test-circuit/node_modules/@typecad/typecad/dist/kicad_commands.js:1:3371)
```

### Build Success Before Failure

The build process successfully completed:
- PCB file generation (`led-test-circuit.kicad_pcb`)
- Netlist generation (`led-test-circuit.net`)
- Component placement and grouping

The failure occurred specifically at the footprint upgrade stage.

[Return to Table of Contents](#table-of-contents)

---

## Resolution

### Solution 1: System-Wide PATH Configuration (Recommended)

Add KiCAD CLI to your shell profile for permanent access:

#### For zsh users (default on macOS):

```bash
echo 'export PATH="/Applications/KiCad/KiCad.app/Contents/MacOS:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### For bash users:

```bash
echo 'export PATH="/Applications/KiCad/KiCad.app/Contents/MacOS:$PATH"' >> ~/.bash_profile
source ~/.bash_profile
```

### Solution 2: Project-Specific Configuration

Created `kicad-env.sh` in project root:

```bash
# KiCAD Configuration for typeCAD
export PATH="/Applications/KiCad/KiCad.app/Contents/MacOS:$PATH"
export KICAD_CLI_PATH="/Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli"
```

Source before running builds:

```bash
source ~/Documents/GitHub/Circuits/kicad-env.sh
```

### Solution 3: Symbolic Link

Create system-wide symlink:

```bash
sudo ln -s /Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli /usr/local/bin/kicad-cli
```

[Return to Table of Contents](#table-of-contents)

---

## Verification

After implementing the solution, verify functionality:

```bash
# Check PATH contains KiCAD
echo $PATH | grep -i kicad

# Verify kicad-cli is accessible
which kicad-cli

# Test kicad-cli execution
kicad-cli --version
```

Expected output:
```
/usr/local/bin/kicad-cli
Version: 9.0.7
```

Then rebuild the project:

```bash
cd ~/Documents/GitHub/Circuits/led-test-circuit
npm run build
```

[Return to Table of Contents](#table-of-contents)

---

## Prevention

### For New Projects

1. Add KiCAD CLI to PATH during initial system setup
2. Document PATH requirements in project README
3. Include environment verification in setup scripts

### Updated setup-typecad.sh

The setup script was updated to include PATH configuration:

```bash
#!/bin/bash
# TypeCAD Setup - Configure KiCAD paths and flatten footprints

# Add KiCAD CLI to PATH
export PATH="/Applications/KiCad/KiCad.app/Contents/MacOS:$PATH"

# ... rest of script
```

### Project Documentation

Ensure all typeCAD projects include:
- Environment prerequisites
- KiCAD CLI PATH requirements
- Verification steps

[Return to Table of Contents](#table-of-contents)

---

## Related Documentation

- [[typecad-and-kicad-mcp-installation-guide|TypeCAD and KiCAD MCP Installation Guide]]
- [KiCAD Official Documentation](https://docs.kicad.org/)
- [TypeCAD Documentation](https://typecad.net/docs)

[Return to Table of Contents](#table-of-contents)

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-22 | William Watson | Initial documentation of KiCAD CLI PATH resolution issue |

[Return to Table of Contents](#table-of-contents)

---

## References

1. KiCAD Project (2026). *KiCAD EDA Software Suite* [Computer software]. Available at: https://www.kicad.org/ (Accessed: 22 January 2026).

2. TypeCAD Project (2026). *TypeCAD Documentation*. Available at: https://typecad.net/docs (Accessed: 22 January 2026).

---

Copyright (c) 2025 William Watson. This work is licensed under the MIT License.
