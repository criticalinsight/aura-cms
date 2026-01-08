#!/bin/bash
# Build optimized Roc binaries for production

set -e

echo "╔══════════════════════════════════════╗"
echo "║     Aura-Roc Build Script            ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Find Roc binary
ROC_PATH=$(find ~ -maxdepth 1 -name "roc_nightly*" -type d | head -n 1)/roc

if [ -z "$ROC_PATH" ] || [ ! -f "$ROC_PATH" ]; then
	echo "Error: Roc compiler not found. Run install_roc.sh first."
	exit 1
fi

ROC_DIR=$(dirname "$ROC_PATH")
export PATH="$ROC_DIR:$PATH"

echo "Using Roc at: $ROC_PATH"
echo ""

# Create output directory
mkdir -p ./bin

echo "→ Building main.roc (CLI)..."
roc build main.roc --optimize --output ./bin/aura-cli
echo "  ✓ bin/aura-cli"

echo "→ Building server.roc (HTTP Server)..."
roc build server.roc --optimize --output ./bin/aura-server
echo "  ✓ bin/aura-server"

echo "→ Building cron.roc (Scheduler)..."
roc build cron.roc --optimize --output ./bin/aura-cron
echo "  ✓ bin/aura-cron"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║     Build Complete!                  ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Binaries available in ./bin/"
ls -la ./bin/
