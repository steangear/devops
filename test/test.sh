#!/bin/bash

LOG_FILE="/var/log/monitoring.log"
API_URL="https://test.com/monitoring/test/api"
PROCESS_NAME="test"
STATE_FILE="/var/run/test_last_pid"

PID=$(pgrep -x "$PROCESS_NAME")

if [[ -n "$PID" ]]; then
    if [[ -f "$STATE_FILE" ]]; then
        LAST_PID=$(cat "$STATE_FILE")
        if [[ "$PID" != "$LAST_PID" ]]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') Process '$PROCESS_NAME' restarted (PID changed from $LAST_PID to $PID)" >> "$LOG_FILE"
        fi
    fi
    echo "$PID" > "$STATE_FILE"

    curl -s --max-time 5 "$API_URL" > /dev/null
    if [[ $? -ne 0 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') Monitoring server unavailable" >> "$LOG_FILE"
    fi
fi
