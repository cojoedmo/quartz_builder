#!/bin/bash

set -e

# Debug: Log start time
echo "$(date): Starting Quartz build process..."

# Navigate to the app directory
cd /app

# Clone or update Quartz
if [ -d "/app/quartz/.git" ]; then
    echo "$(date): Pulling latest changes in Quartz repository..."
    cd quartz && git pull && cd ..
else
    echo "$(date): Cloning Quartz repository..."
    git clone https://github.com/jackyzha0/quartz.git /app/quartz
fi

# Sync Obsidian vault with Quartz content
if [ -d "$VAULT_DIR" ]; then
    echo "$(date): Syncing Obsidian vault..."
    cp -r $VAULT_DIR/* /app/quartz/content/
else
    echo "$(date): Obsidian vault directory not found: $VAULT_DIR"
    exit 1
fi

# Build Quartz
echo "$(date): Building Quartz..."
cd /app/quartz
npm install
npx quartz build

# Copy built files to the output directory
echo "$(date): Copying built files to output directory..."
mkdir -p $OUTPUT_DIR
cp -r /app/quartz/public/* $OUTPUT_DIR

# Debug: Log completion
echo "$(date): Quartz build process completed."