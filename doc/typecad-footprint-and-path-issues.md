# TypeCAD Footprint and PATH Configuration Issues

Created: 2026 January 22

## Table of Contents

- [Executive Summary](#executive-summary)
- [Problem Overview](#problem-overview)
- [Root Causes Identified](#root-causes-identified)
- [Issues Encountered](#issues-encountered)
- [Solutions Implemented](#solutions-implemented)
- [Project Structure](#project-structure)
- [Setup Process](#setup-process)
- [Verification Steps](#verification-steps)
- [Lessons Learned](#lessons-learned)
- [Related Documentation](#related-documentation)
- [Version History](#version-history)

[Return to Table of Contents](#table-of-contents)

---

## Executive Summary

TypeCAD project setup encountered two critical issues preventing successful builds:

1. **Footprint Resolution Failure**: TypeCAD could not load KiCAD footprints due to directory structure mismatch
2. **kicad-cli PATH Issue**: Command-line tools were inaccessible, causing build failures during footprint upgrade

Both issues were resolved through directory flattening and PATH configuration.

**Impact**: Complete build failure preventing PCB generation  
**Resolution Time**: Multiple iterations over session  
**Severity**: Critical - blocks all TypeCAD functionality

[Return to Table of Contents](#table-of-contents)

---

## Problem Overview

### Initial Setup Attempt

Created LED test circuit project at `/Users/williamwatson/Documents/GitHub/Circuits/led-test-circuit/` with:
- 330Ω resistor (0805 SMD)
- Red LED (0805 SMD)
- Shared build directory at `/Users/williamwatson/Documents/GitHub/Circuits/build/`

### Build Failures

1. **Import errors**: Initial code used incorrect package paths
2. **Footprint loading**: TypeCAD could not find footprints despite files being present
3. **CLI execution**: kicad-cli commands failed during footprint upgrade

[Return to Table of Contents](#table-of-contents)

---

## Root Causes Identified

### Issue 1: Directory Structure Mismatch

**KiCAD's Structure** (hierarchical):
```
footprints/
├── Resistor_SMD.pretty/
│   ├── R_0805_2012Metric.kicad_mod
│   └── ...
├── LED_SMD.pretty/
│   ├── LED_0805_2012Metric.kicad_mod
│   └── ...
```

**TypeCAD's Expected Structure** (flattened):
```
footprints/
├── R_0805_2012Metric.kicad_mod
├── LED_0805_2012Metric.kicad_mod
└── ...
```

**Diagnosis**:
- TypeCAD references footprints as `Resistor_SMD:R_0805_2012Metric`
- Parser expects `build/footprints/R_0805_2012Metric.kicad_mod`
- Files were located at `build/footprints/Resistor_SMD.pretty/R_0805_2012Metric.kicad_mod`
- Result: "Cannot create footprint node" error

### Issue 2: PATH Environment Variable

**Symptom**:
```
/bin/sh: kicad-cli: command not found
```

**Analysis**:
- KiCAD 9.0.7 installed at `/Applications/KiCad/KiCad.app`
- CLI tools located at `Contents/MacOS/kicad-cli`
- Shell processes could not locate executable
- TypeCAD requires kicad-cli for footprint upgrades and DRC

[Return to Table of Contents](#table-of-contents)

---

## Issues Encountered

### Phase 1: Import and API Errors

**Error**: Module import failures
```typescript
// Incorrect
import { Resistor, LED } from '@typecad/passives';

// Correct
import { Resistor, LED } from '@typecad/passives/0805';
```

**Resolution**: Package requires size specification (0805, 0603, etc.)

**Error**: Pin access methods
```typescript
// Incorrect (Component-specific method)
led.anode
led.cathode

// Correct (Generic Pin access)
led.pin(1)  // anode
led.pin(2)  // cathode
```

**Resolution**: Passives use numeric pin indexing, not named properties

### Phase 2: Build Directory Requirements

**Error**: Build fails with missing directory
```
Error: ENOENT: no such file or directory, open './build/led-test-circuit.kicad_pcb'
```

**Resolution**: TypeCAD requires `./build/` directory to exist before execution

### Phase 3: Footprint Resolution

**Attempt 1**: Direct copy of `.pretty` directories
- Files accessible via filesystem
- TypeCAD parser could not create footprint nodes
- Error: Path resolution mismatch

**Attempt 2**: Symlink from `build/footprints` to `lib/footprints`
- Maintained hierarchical structure
- Same error persisted
- Confirmed issue was structural, not path-related

**Attempt 3**: Flatten footprint hierarchy
- Copy all `.kicad_mod` files to single directory
- Remove `.pretty` subdirectories
- **Success**: TypeCAD successfully loaded footprints

### Phase 4: kicad-cli Execution

**Error**:
```
Error: Command failed: kicad-cli fp upgrade ./build/lib/footprints/
/bin/sh: kicad-cli: command not found
```

**Context**:
- Occurred after successful PCB/netlist generation
- Failed during footprint upgrade stage
- Prevented build completion

**Diagnosis**:
```bash
$ which kicad-cli
# (no output - not in PATH)

$ ls /Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli
# /Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli (exists)
```

**Resolution**: Add KiCAD CLI to PATH

[Return to Table of Contents](#table-of-contents)

---

## Solutions Implemented

### Solution 1: Footprint Flattening

Updated `setup-typecad.sh` to copy footprints without directory hierarchy:

```bash
# Source structure (KiCAD default)
/Applications/KiCad/KiCad.app/Contents/SharedSupport/footprints/Resistor_SMD.pretty/*.kicad_mod

# Target structure (TypeCAD requirement)
~/Documents/GitHub/Circuits/build/footprints/*.kicad_mod
```

**Libraries copied**:
- Resistor_SMD
- LED_SMD
- Capacitor_SMD
- Diode_SMD
- Inductor_SMD
- Fuse
- Connector_PinHeader_2.54mm
- Connector_JST
- Package_SO
- Package_QFP
- Package_DFN_QFN

### Solution 2: PATH Configuration

**Temporary** (per-session):
```bash
export PATH="/Applications/KiCad/KiCad.app/Contents/MacOS:$PATH"
```

**Permanent** (zsh):
```bash
echo 'export PATH="/Applications/KiCad/KiCad.app/Contents/MacOS:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Verification**:
```bash
which kicad-cli
kicad-cli --version
```

### Solution 3: Environment File

Created `kicad-env.sh` for project-specific configuration:

```bash
#!/bin/bash
export PATH="/Applications/KiCad/KiCad.app/Contents/MacOS:$PATH"
export KICAD_CLI_PATH="/Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli"
export KICAD_FOOTPRINTS="~/Documents/GitHub/Circuits/build/footprints"
export KICAD_SYMBOLS="~/Documents/GitHub/Circuits/build/lib"
```

Usage:
```bash
source ~/Documents/GitHub/Circuits/kicad-env.sh
cd led-test-circuit
npm run build
```

### Solution 4: Automated Setup Script

Enhanced `setup-typecad.sh` with:
- KiCAD installation verification
- PATH configuration
- Directory structure creation
- Footprint flattening
- Footprint upgrade via kicad-cli
- Environment file generation
- Error handling and logging

[Return to Table of Contents](#table-of-contents)

---

## Project Structure

### Shared Build Directory

```
~/Documents/GitHub/Circuits/
├── build/                          # Shared across all projects
│   ├── footprints/                 # Flattened KiCAD footprints
│   │   ├── R_0805_2012Metric.kicad_mod
│   │   ├── LED_0805_2012Metric.kicad_mod
│   │   └── ...
│   └── lib/                        # Symbols and 3D models
├── led-test-circuit/               # Example project
│   ├── build -> ../build           # Symlink to shared build
│   ├── node_modules/
│   ├── index.ts                    # Circuit definition
│   ├── package.json
│   ├── tsconfig.json
│   └── README.md
├── kicad-env.sh                    # Environment configuration
├── setup-typecad.sh                # Setup automation
└── .gitignore                      # TypeCAD patterns
```

### Symlink Strategy

Each project links to shared build directory:
```bash
cd ~/Documents/GitHub/Circuits/your-project
ln -s ../build build
```

**Advantages**:
- Single footprint/symbol cache
- Consistent environment across projects
- Reduced disk usage
- Simplified maintenance

[Return to Table of Contents](#table-of-contents)

---

## Setup Process

### Initial System Setup

1. **Install KiCAD 9.0.7+**
   - Download from https://www.kicad.org/
   - Verify installation at `/Applications/KiCad/KiCad.app`

2. **Configure PATH** (choose one):

   **Option A: System-wide** (recommended)
   ```bash
   echo 'export PATH="/Applications/KiCad/KiCad.app/Contents/MacOS:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

   **Option B: Per-session**
   ```bash
   source ~/Documents/GitHub/Circuits/kicad-env.sh
   ```

3. **Run setup script**:
   ```bash
   cd ~/Documents/GitHub/Circuits
   chmod +x setup-typecad.sh
   ./setup-typecad.sh
   ```

### New Project Creation

1. **Create project directory**:
   ```bash
   cd ~/Documents/GitHub/Circuits
   mkdir my-project
   cd my-project
   ```

2. **Initialize npm**:
   ```bash
   npm init -y
   ```

3. **Install dependencies**:
   ```bash
   npm install @typecad/typecad @typecad/passives
   ```

4. **Create TypeScript config**:
   ```json
   {
     "compilerOptions": {
       "target": "ES2020",
       "module": "ESNext",
       "moduleResolution": "node",
       "esModuleInterop": true,
       "skipLibCheck": true,
       "strict": true
     }
   }
   ```

5. **Create build symlink**:
   ```bash
   ln -s ../build build
   ```

6. **Create circuit definition** (`index.ts`):
   ```typescript
   import { PCB } from '@typecad/typecad';
   import { Resistor, LED } from '@typecad/passives/0805';

   const pcb = new PCB('my-project');
   
   const r1 = new Resistor({ 
     value: '330ohm', 
     pcb: { x: 140, y: 100, rotation: 0 } 
   });
   
   const led1 = new LED({ 
     pcb: { x: 150, y: 100, rotation: 0 } 
   });

   pcb.net(r1.pin(2), led1.pin(1));
   pcb.outline(130, 90, 60, 40, 2);
   pcb.create(r1, led1);
   ```

7. **Add build script** (package.json):
   ```json
   {
     "scripts": {
       "build": "tsx index.ts"
     }
   }
   ```

8. **Build project**:
   ```bash
   npm run build
   ```

[Return to Table of Contents](#table-of-contents)

---

## Verification Steps

### System Verification

```bash
# Verify KiCAD installation
ls -la /Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli

# Verify PATH configuration
echo $PATH | grep -i kicad
which kicad-cli
kicad-cli --version

# Verify footprint directory
ls ~/Documents/GitHub/Circuits/build/footprints/ | head -5
```

### Project Verification

```bash
# Check directory structure
ls -la build  # Should show symlink -> ../build

# Verify TypeScript installation
npx tsx --version

# Test build
npm run build

# Check outputs
ls build/*.kicad_pcb
ls build/*.net
```

### Footprint Verification

```bash
# Count available footprints
find ~/Documents/GitHub/Circuits/build/footprints -name "*.kicad_mod" | wc -l

# Verify specific footprint
ls ~/Documents/GitHub/Circuits/build/footprints/R_0805_2012Metric.kicad_mod
ls ~/Documents/GitHub/Circuits/build/footprints/LED_0805_2012Metric.kicad_mod
```

[Return to Table of Contents](#table-of-contents)

---

## Lessons Learned

### TypeCAD Specific

1. **Directory structure matters**: TypeCAD expects flat footprint directory
2. **Package imports require size**: `@typecad/passives/0805` not `@typecad/passives`
3. **Pin access is generic**: Use `.pin(n)` for passives, not component-specific names
4. **Build directory required**: Must exist before TypeCAD execution
5. **kicad-cli dependency**: Required for footprint upgrades and DRC

### KiCAD Integration

1. **CLI tools location**: Not in standard PATH by default on macOS
2. **Footprint format**: KiCAD uses `.pretty` directories, TypeCAD expects flat
3. **Version compatibility**: KiCAD 9.x format differs from earlier versions
4. **SharedSupport location**: Varies by platform (macOS app bundle structure)

### Development Workflow

1. **Shared build strategy**: Reduces duplication across projects
2. **Environment configuration**: Critical for reproducible builds
3. **Symlink approach**: Simplifies project structure maintenance
4. **Setup automation**: Essential for consistent environment
5. **Verification steps**: Prevent debugging false issues

### Documentation

1. **Root cause analysis**: Essential for understanding solutions
2. **Step-by-step resolution**: Aids future troubleshooting
3. **Project structure diagram**: Clarifies file relationships
4. **Verification procedures**: Confirms successful setup

[Return to Table of Contents](#table-of-contents)

---

## Related Documentation

- [[kicad-cli-path-resolution|KiCAD CLI PATH Resolution Issue]]
- [[typecad-and-kicad-mcp-installation-guide|TypeCAD and KiCAD MCP Installation Guide]]
- [TypeCAD Documentation](https://typecad.net/docs)
- [KiCAD Documentation](https://docs.kicad.org/)

[Return to Table of Contents](#table-of-contents)

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-22 | William Watson | Initial documentation of footprint and PATH issues |

[Return to Table of Contents](#table-of-contents)

---

## References

1. KiCAD Project (2026). *KiCAD EDA Software Suite* [Computer software]. Available at: https://www.kicad.org/ (Accessed: 22 January 2026).

2. TypeCAD Project (2026). *TypeCAD Documentation*. Available at: https://typecad.net/docs (Accessed: 22 January 2026).

3. npm, Inc. (2026). *npm package manager* [Computer software]. Available at: https://www.npmjs.com/ (Accessed: 22 January 2026).

---

Copyright (c) 2025 William Watson. This work is licensed under the MIT License.
