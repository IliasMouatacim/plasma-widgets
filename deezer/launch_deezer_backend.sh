#!/bin/bash
cd "$(dirname "$0")"

# Check if it's already running to prevent multiple instances
if pgrep -f "deezer_backend.py" > /dev/null
then
    echo "Backend already running."
else
    python backend/deezer_backend.py &
fi
