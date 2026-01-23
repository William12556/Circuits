#!/bin/bash
# TypeCAD Setup - Configure KiCAD paths and flatten footprints
# Version: 2.0
# Updated: 2026-01-22
# Purpose: Resolve footprint loading and kicad-cli PATH issues

set -e  # Exit on error

# Configuration
KICAD_APP="/Applications/KiCad/KiCad.app"
KICAD_FOOTPRINTS="$KICAD_APP/Contents/SharedSupport/footprints"
KICAD_CLI="$KICAD_APP/Contents/MacOS"
SHARED_BUILD="/Users/williamwatson/Documents/GitHub/Circuits/build"
SHARED_FOOTPRINTS="$SHARED_BUILD/footprints"
SHARED_SYMBOLS="$SHARED_BUILD/lib"

# Logging
log_info() { echo "[INFO] $1"; }
log_success() { echo "[SUCCESS] ✓ $1"; }
log_error() { echo "[ERROR] ✗ $1" >&2; }
log_warn() { echo "[WARN] ⚠ $1"; }

# Verify KiCAD installation
verify_kicad() {
    log_info "Verifying KiCAD installation..."
    
    if [ ! -d "$KICAD_APP" ]; then
        log_error "KiCAD not found at $KICAD_APP"
        exit 1
    fi
    
    if [ ! -f "$KICAD_CLI/kicad-cli" ]; then
        log_error "kicad-cli not found at $KICAD_CLI/kicad-cli"
        exit 1
    fi
    
    if [ ! -d "$KICAD_FOOTPRINTS" ]; then
        log_error "KiCAD footprints not found at $KICAD_FOOTPRINTS"
        exit 1
    fi
    
    log_success "KiCAD installation verified"
}

# Add KiCAD CLI to PATH
configure_path() {
    log_info "Configuring PATH for kicad-cli..."
    
    # Add to current session
    export PATH="$KICAD_CLI:$PATH"
    
    # Verify kicad-cli is accessible
    if command -v kicad-cli >/dev/null 2>&1; then
        log_success "kicad-cli accessible in PATH"
        kicad-cli --version | head -1
    else
        log_error "kicad-cli still not accessible after PATH configuration"
        exit 1
    fi
}

# Create shared build directory structure
create_build_structure() {
    log_info "Creating shared build directory structure..."
    
    mkdir -p "$SHARED_FOOTPRINTS"
    mkdir -p "$SHARED_SYMBOLS"
    
    log_success "Build directories created"
}

# Flatten KiCAD footprints
flatten_footprints() {
    log_info "Flattening KiCAD footprints..."
    
    # List of footprint libraries to copy
    local LIBRARIES=(
        "Resistor_SMD"
        "LED_SMD"
        "Capacitor_SMD"
        "Diode_SMD"
        "Inductor_SMD"
        "Fuse"
        "Connector_PinHeader_2.54mm"
        "Connector_JST"
        "Package_SO"
        "Package_QFP"
        "Package_DFN_QFN"
    )
    
    local copied=0
    local failed=0
    
    for lib in "${LIBRARIES[@]}"; do
        local source="$KICAD_FOOTPRINTS/${lib}.pretty"
        
        if [ -d "$source" ]; then
            log_info "Copying $lib..."
            if cp "$source"/*.kicad_mod "$SHARED_FOOTPRINTS/" 2>/dev/null; then
                ((copied++))
            else
                log_warn "No footprints found in $lib or copy failed"
                ((failed++))
            fi
        else
            log_warn "Library not found: $lib"
            ((failed++))
        fi
    done
    
    log_success "Copied $copied libraries ($failed warnings)"
    
    # Count total footprints
    local count=$(find "$SHARED_FOOTPRINTS" -name "*.kicad_mod" | wc -l)
    log_info "Total footprints: $count"
}

# Upgrade footprints to current KiCAD format
upgrade_footprints() {
    log_info "Upgrading footprints to KiCAD 9.x format..."
    
    if kicad-cli fp upgrade "$SHARED_FOOTPRINTS/" 2>&1 | grep -v "Warning"; then
        log_success "Footprints upgraded"
    else
        log_warn "Footprint upgrade completed with warnings"
    fi
}

# Create environment file
create_env_file() {
    log_info "Creating kicad-env.sh..."
    
    cat > "$SHARED_BUILD/../kicad-env.sh" << 'EOF'
#!/bin/bash
# KiCAD Environment Configuration for TypeCAD
# Source this file before running TypeCAD builds: source ~/Documents/GitHub/Circuits/kicad-env.sh

export PATH="/Applications/KiCad/KiCad.app/Contents/MacOS:$PATH"
export KICAD_CLI_PATH="/Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli"
export KICAD_FOOTPRINTS="/Users/williamwatson/Documents/GitHub/Circuits/build/footprints"
export KICAD_SYMBOLS="/Users/williamwatson/Documents/GitHub/Circuits/build/lib"

# Verify configuration
if command -v kicad-cli >/dev/null 2>&1; then
    echo "[OK] kicad-cli accessible"
else
    echo "[ERROR] kicad-cli not found in PATH"
    return 1
fi

if [ -d "$KICAD_FOOTPRINTS" ]; then
    echo "[OK] Footprints directory exists"
else
    echo "[ERROR] Footprints directory not found"
    return 1
fi

echo "[OK] KiCAD environment configured"
EOF
    
    chmod +x "$SHARED_BUILD/../kicad-env.sh"
    log_success "Environment file created"
}

# Main execution
main() {
    log_info "Starting TypeCAD setup..."
    log_info "Target: $SHARED_BUILD"
    
    verify_kicad
    configure_path
    create_build_structure
    flatten_footprints
    upgrade_footprints
    create_env_file
    
    echo ""
    log_success "TypeCAD setup complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Source environment: source ~/Documents/GitHub/Circuits/kicad-env.sh"
    echo "  2. Add to shell profile for persistence:"
    echo "     echo 'export PATH=\"$KICAD_CLI:\$PATH\"' >> ~/.zshrc"
    echo "  3. Create project symlinks:"
    echo "     cd your-project && ln -s ../build build"
    echo ""
}

main "$@"
