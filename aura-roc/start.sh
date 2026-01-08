#!/bin/bash
# Aura-Roc Unified Launcher
clear
echo "╔══════════════════════════════════════╗"
echo "║       AURA-ROC CONTENT FACTORY       ║"
echo "╚══════════════════════════════════════╝"

# Find Roc
ROC_DIR=$(find ~ -maxdepth 1 -name "roc_nightly*" -type d | head -n 1)
if [ -z "$ROC_DIR" ]; then
	echo "[ERROR] Roc not found in ~/"
	exit 1
fi
export PATH="$ROC_DIR:$PATH"
echo "[OK] Roc: $ROC_DIR"

# Load .env file if exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
	echo "[...] Loading .env..."
	set -a
	source "$SCRIPT_DIR/.env"
	set +a
	echo "[OK] Environment loaded"
else
	echo "[WARN] No .env file found. Copy .env.example to .env and add your API key."
fi

# Check API Key
if [ -z "$GOOGLE_API_KEY" ]; then
	echo "[ERROR] GOOGLE_API_KEY not set. Cannot start server."
	exit 1
fi
echo "[OK] API Key configured"

# Launch Server in background
echo "[...] Starting Server..."
roc run server.roc >../logs/server.log 2>&1 &
SERVER_PID=$!
sleep 2
echo "[OK] Server PID: $SERVER_PID"

# Run single Cron cycle (dry run)
echo "[...] Running Cron (Dry Run)..."
roc run main.roc -- --prompt "Analyze latest 13F filings" >../logs/cron.log 2>&1
echo "[OK] Cron complete. See logs/cron.log"

# Interactive mode
echo ""
echo "══════════════════════════════════════"
echo "  Type queries below. 'exit' to quit."
echo "══════════════════════════════════════"
roc run main.roc
