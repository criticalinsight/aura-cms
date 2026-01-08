#!/bin/bash
# Aura-Roc Install Script
# Installs the Roc compiler to the user's home directory

set -e

echo "╔══════════════════════════════════════╗"
echo "║     Aura-Roc Installer               ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Check OS
if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "linux" ]]; then
	PLATFORM="linux_x86_64"
elif [[ "$OSTYPE" == "darwin"* ]]; then
	PLATFORM="macos_apple_silicon"
else
	echo "Error: Unsupported platform. Use WSL on Windows."
	exit 1
fi

ROC_URL="https://github.com/roc-lang/roc/releases/download/nightly/roc_nightly-${PLATFORM}-latest.tar.gz"
INSTALL_DIR="$HOME"

echo "→ Downloading Roc compiler for $PLATFORM..."
cd "$INSTALL_DIR"

# Clean up old versions
rm -rf roc_nightly* 2>/dev/null || true

# Download and extract
curl -fsSL "$ROC_URL" -o roc.tar.gz
tar -xzf roc.tar.gz
rm roc.tar.gz

# Find extracted directory
ROC_DIR=$(find . -maxdepth 1 -name "roc_nightly*" -type d | head -n 1)

if [ -z "$ROC_DIR" ]; then
	echo "Error: Failed to extract Roc compiler."
	exit 1
fi

echo "→ Roc installed to: $INSTALL_DIR/$ROC_DIR"
echo ""
echo "✓ Installation complete!"
echo ""
echo "Add to your shell profile:"
echo "  export PATH=\"\$HOME/$ROC_DIR:\$PATH\""
echo ""
echo "Or run directly with:"
echo "  $INSTALL_DIR/$ROC_DIR/roc --version"
