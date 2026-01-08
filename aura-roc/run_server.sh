#!/bin/bash

# Find Roc binary in home dir
ROC_PATH=$(find ~ -maxdepth 1 -name "roc_nightly*" -type d | head -n 1)/roc

if [ -z "$ROC_PATH" ]; then
	echo "Error: Roc compiler not found in ~/"
	exit 1
fi

echo "Using Roc at: $ROC_PATH"
ROC_DIR=$(dirname "$ROC_PATH")
export PATH="$ROC_DIR:$PATH"

# Load environment from .env if it exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
	echo "Loading environment from .env..."
	set -a
	source "$SCRIPT_DIR/.env"
	set +a
fi

# Run Server
echo "Starting Aura-Roc Server..."
# Ensure API Key is passed
if [ -z "$GOOGLE_API_KEY" ]; then
	echo "Warning: GOOGLE_API_KEY is not set. Create .env file with your key."
fi

roc run server.roc 2>&1 | tee -a ../logs/server.log
