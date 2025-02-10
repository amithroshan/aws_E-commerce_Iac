#!/bin/bash

echo "Navigating to the application directory..."
cd /var/www/html/ || { echo "Failed to navigate to /home/ubuntu/app"; exit 1; }

echo "Installing dependencies..."
npm install

echo "Restarting the application..."
pm2 restart app || pm2 start app.js --name app

echo "Deployment completed successfully."


sudo mv public/index.html .
sudo mv public/electronic.html .
sudo mv public/fashion.html .
sudo mv public/jewellery.html .
sudo mv public/js/ .
sudo mv public/css/ .
sudo mv public/images/ .
sudo mv public/fonts/ .

sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
