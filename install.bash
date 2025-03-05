#!/bin/bash
# To be bundled in client.tar.gz

set -e  # Exit on error

# Download and extract Nebula
wget https://github.com/slackhq/nebula/releases/download/v1.9.5/nebula-linux-amd64.tar.gz -O /tmp/nebula.tar.gz
tar -xf /tmp/nebula.tar.gz -C /usr/local/bin
rm /tmp/nebula.tar.gz

# Create necessary directories
mkdir -p /etc/nebula

# Move configuration files
mv ca.crt /etc/nebula/
mv client.yml /etc/nebula/
mv client.crt /etc/nebula/
mv client.key /etc/nebula/

# Prompt user for systemd service installation
read -p "Do you want to install and enable the Nebula systemd service? (yes/no): " choice
if [[ "$choice" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    cat <<EOF | tee /etc/systemd/system/nebula.service
[Unit]
Description=Nebula VPN
After=network.target

[Service]
ExecStart=/usr/local/bin/nebula -config /etc/nebula/client.yml
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd and enable the service
    systemctl daemon-reload
    systemctl enable --now nebula.service

    echo "Nebula systemd service installed and started."
else
    echo "Skipping systemd service installation."
fi

echo "Installation complete!"
