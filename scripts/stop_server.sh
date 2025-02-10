#!/bin/bash

echo "Stopping Node.js application..."

# Find process running on port 3000
if command -v lsof > /dev/null 2>&1; then
    APP_PID=$(lsof -t -i:3000)
elif command -v ss > /dev/null 2>&1; then
    APP_PID=$(ss -tulpn | grep ':3000' | awk '{print $7}' | cut -d',' -f2 | cut -d'=' -f2)
else
    APP_PID=$(netstat -tulpn 2>/dev/null | grep ':3000' | awk '{print $7}' | cut -d'/' -f1)
fi

# Terminate the process
if [ -n "$APP_PID" ]; then
    echo "Killing process $APP_PID..."
    kill -TERM "$APP_PID"
    sleep 3
    if ps -p "$APP_PID" > /dev/null; then
        echo "Force killing process $APP_PID..."
        kill -9 "$APP_PID"
    fi
    echo "Application stopped successfully."
else
    echo "No process found running on port 3000."
fi

# Stop PM2 processes (if used)
if command -v pm2 > /dev/null 2>&1; then
    echo "Stopping PM2 processes..."
    pm2 stop app || echo "No PM2 processes running."
    pm2 delete app || echo "No PM2 processes to delete."
fi

echo "Shutdown script completed."
