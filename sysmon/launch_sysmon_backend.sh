#!/bin/bash
cd "$(dirname "$0")"

# Check if it's already running to prevent multiple instances
if pgrep -f "sysmon_backend.py" > /dev/null
then
    echo "Backend already running."
else
    nohup python backend/sysmon_backend.py > /dev/null 2>&1 &
fi
