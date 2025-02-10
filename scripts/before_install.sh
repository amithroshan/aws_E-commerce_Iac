#!/bin/bash

echo "Updating packages..."
sudo apt update -y
sudo apt upgrade -y

echo "Installing required dependencies..."
sudo apt install -y curl unzip git

echo "Ensuring Node.js and PM2 are installed..."
if ! which node > /dev/null 2>&1; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

if ! which pm2 > /dev/null 2>&1; then
    echo "Installing PM2..."
    npm install -g pm2
fi

echo "Server ready for application deployment."
