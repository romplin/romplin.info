#!/bin/bash

# Install dependencies if needed
sudo apt-get update
sudo apt-get install -y nginx golang

# Setup systemd service
sudo tee /etc/systemd/system/romplin.service << EOF
[Unit]
Description=Romplin Web Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/var/www/romplin.info
ExecStart=/var/www/romplin.info/romplin
Restart=always
Environment="TEMPLATES_DIR=/var/www/romplin.info/templates"
Environment="STATIC_DIR=/var/www/romplin.info/static"

[Install]
WantedBy=multi-user.target
EOF

# Start services
sudo systemctl daemon-reload
sudo systemctl enable romplin
sudo systemctl restart romplin
