# setup.sh
#!/bin/bash

# Install required packages if not present
if ! command -v nginx &> /dev/null; then
    sudo yum update -y
    sudo yum install -y nginx
fi

if ! command -v go &> /dev/null; then
    sudo yum install -y golang
fi

# Setup application
APP_DIR="/home/ec2-user/romplin.info"
sudo mkdir -p $APP_DIR
sudo cp romplin $APP_DIR/
sudo chown -R ec2-user:ec2-user $APP_DIR

# Setup systemd service
sudo cat > /etc/systemd/system/romplin.service << 'EOL'
[Unit]
Description=Romplin Web Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/romplin.info
ExecStart=/home/ec2-user/romplin.info/romplin
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Setup Nginx
sudo cp nginx/romplin.conf /etc/nginx/conf.d/
sudo systemctl enable nginx
sudo systemctl restart nginx

# Start application
sudo systemctl enable romplin
sudo systemctl restart romplin

# Setup SSL if not already configured
if [ ! -f /etc/letsencrypt/live/romplin.info/fullchain.pem ]; then
    sudo dnf install -y python3-pip
    sudo pip3 install certbot certbot-nginx
    sudo certbot --nginx -d romplin.info -d www.romplin.info --non-interactive --agree-tos --email ${CERTBOT_EMAIL:-"your-email@example.com"}
fi
