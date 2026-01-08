#!/bin/bash

# Find Roc binary in home dir
ROC_PATH=$(find ~ -maxdepth 1 -name "roc_nightly*" -type d | head -n 1)/roc

if [ -z "$ROC_PATH" ]; then
	echo "Error: Roc compiler not found in ~/"
	exit 1
fi

ROC_DIR=$(dirname "$ROC_PATH")
export PATH="$ROC_DIR:$PATH"

# Run Cron Job
echo "Starting Aura-Roc Cron Service..."
roc run cron.roc 2>&1 | tee -a ../logs/cron.log
