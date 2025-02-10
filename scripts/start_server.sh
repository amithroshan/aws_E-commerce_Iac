#!/bin/bash

# Navigate to the app directory
cd /var/www/html/  || { echo "Failed to navigate to /home/ubuntu/app"; exit 1; }

# Install Node.js if not already installed
if ! which node > /dev/null 2>&1; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install PM2 globally if not already installed
if ! which pm2 > /dev/null 2>&1; then
    echo "Installing PM2..."
    npm install -g pm2
fi

# Install dependencies
echo "Installing dependencies..."
npm install

# Start or restart the application using PM2
echo "Starting the application..."
pm2 restart app || pm2 start app.js --name app

echo "Application started successfully."
