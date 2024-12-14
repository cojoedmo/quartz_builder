#!/bin/bash
set -e

# Log file for monitoring
LOG_FILE="/var/log/cron.log"


run_build() {
    # Debug: Log start time
    echo "$(date): Starting Quartz build process..." >> $LOG_FILE

    # Navigate to the app directory
    cd /app

    # Clone or update Quartz
    if [ -d "/app/quartz/.git" ]; then
        echo "$(date): Pulling latest changes in Quartz repository..." >> $LOG_FILE
        cd quartz && git pull && cd ..
    else
        echo "$(date): Cloning Quartz repository..."
        git clone https://github.com/jackyzha0/quartz.git /app/quartz >> $LOG_FILE
    fi

    # Sync Obsidian vault with Quartz content
    if [ -d "$VAULT_DIR" ]; then
        echo "$(date): Syncing Obsidian vault..." >> $LOG_FILE
        cp -r $VAULT_DIR/* /app/quartz/content/
    else
        echo "$(date): Obsidian vault directory not found: $VAULT_DIR"
        exit 1
    fi

    # Build Quartz
    echo "$(date): Building Quartz..." >> $LOG_FILE
    cd /app/quartz 
    npm install
    npx quartz build

    # Copy built files to the output directory
    echo "$(date): Copying built files to output directory..." >> $LOG_FILE
    mkdir -p $OUTPUT_DIR
    cp -r /app/quartz/public/* $OUTPUT_DIR

    # Debug: Log completion
    echo "$(date): Quartz build process completed." >> $LOG_FILE
}



echo "Starting to watch for things" >> $LOG_FILE
# Monitor for changes in the Vault directory
inotifywait -m -r -e modify,create,move,delete $VAULT_DIR |
    while read -r directory event filename; do
        echo "$(date) - Change detected in $VAULT_DIR/$filename" >> $LOG_FILE
        
        # Reset the timer whenever a change is detected
        if [ ! "$TIMER_PID" ]; then
            # Start the 5-minute (300 seconds) timer to check for inactivity
            (sleep 10 && run_build) &
            TIMER_PID=$!
        else
            # If a change happens before the timer expires, kill the previous timer and start a new one
            kill $TIMER_PID
            (sleep 10 && run_build) &
            TIMER_PID=$!
        fi
    done