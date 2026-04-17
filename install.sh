#!/usr/bin/env bash
#
# install.sh — Install voacap-swift
#
# Usage:
#   ./install.sh                    # install to /usr/local
#   ./install.sh --prefix ~/.local  # install to custom prefix
#   ./install.sh --uninstall        # remove voacap-swift
#
set -euo pipefail

PREFIX="/usr/local"
UNINSTALL=false
ITSHFBC_DIR="$HOME/itshfbc"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --prefix)    PREFIX="$2"; shift 2 ;;
        --uninstall) UNINSTALL=true; shift ;;
        --help|-h)
            echo "Usage: ./install.sh [--prefix <path>] [--uninstall]"
            echo ""
            echo "Options:"
            echo "  --prefix <path>   Install prefix (default: /usr/local)"
            echo "  --uninstall       Remove voacap-swift"
            exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

BIN_DIR="$PREFIX/bin"

if [ "$UNINSTALL" = true ]; then
    echo "Removing voacap-swift..."
    rm -f "$BIN_DIR/voacap-swift"
    echo "Binary removed from $BIN_DIR/voacap-swift"
    echo ""
    echo "Note: ~/itshfbc and ~/.voacaplrc were left in place."
    echo "Remove them manually if no longer needed:"
    echo "  rm -rf ~/itshfbc ~/.voacaplrc"
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check that the binary exists in this directory
if [ ! -f "$SCRIPT_DIR/voacap-swift" ]; then
    echo "Error: voacap-swift binary not found in $SCRIPT_DIR"
    echo "Run this script from the extracted release directory."
    exit 1
fi

echo "Installing voacap-swift..."
echo ""

# Install binary
mkdir -p "$BIN_DIR"
cp "$SCRIPT_DIR/voacap-swift" "$BIN_DIR/voacap-swift"
chmod +x "$BIN_DIR/voacap-swift"
echo "  Binary:  $BIN_DIR/voacap-swift"

# Install itshfbc data (skip if already exists)
if [ -d "$SCRIPT_DIR/itshfbc" ]; then
    if [ -d "$ITSHFBC_DIR" ]; then
        echo "  Data:    $ITSHFBC_DIR (already exists, skipped)"
    else
        cp -R "$SCRIPT_DIR/itshfbc" "$ITSHFBC_DIR"
        echo "  Data:    $ITSHFBC_DIR (installed)"
    fi
fi

# Create config file pointing to itshfbc
RC_FILE="$HOME/.voacaplrc"
if [ ! -f "$RC_FILE" ]; then
    echo "$ITSHFBC_DIR" > "$RC_FILE"
    echo "  Config:  $RC_FILE → $ITSHFBC_DIR"
else
    echo "  Config:  $RC_FILE (already exists, skipped)"
fi

echo ""
echo "Installation complete. Try:"
echo ""
echo "  voacap-swift --from EN19 --to IO91"
echo ""

# Check if bin dir is in PATH
if ! echo "$PATH" | tr ':' '\n' | grep -q "^${BIN_DIR}$"; then
    echo "Note: $BIN_DIR is not in your PATH."
    echo "Add it with:  export PATH=\"$BIN_DIR:\$PATH\""
fi
