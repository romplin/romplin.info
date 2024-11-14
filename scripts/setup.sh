#!/bin/bash

# Extract the deployment package
cd ~
tar -xzf deploy.tar.gz

# Setup application directory
mkdir -p ~/romplin.info
mv romplin ~/romplin.info/
cd ~/romplin.info

# Install dependencies if needed
if ! command -v nginx &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y nginx golang
fi

# Setup Nginx config
sudo cp nginx/romplin.conf /etc/nginx/conf.d/
sudo systemctl enable nginx
sudo systemctl restart nginx

# Setup systemd service
sudo tee /etc/systemd/system/romplin.service << EOF
[Unit]
Description=Romplin Web Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/romplin.info
ExecStart=/home/ubuntu/romplin.info/romplin
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start services
sudo systemctl daemon-reload
sudo systemctl enable romplin
sudo systemctl restart romplin

# Cleanup
rm ~/deploy.tar.gz
