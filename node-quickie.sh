#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    # Run apt update
    sudo apt update

    # Install Docker
    curl -fsSL https://get.docker.com | sh
fi

# Clone Marzban-node repository
git clone https://github.com/Gozargah/Marzban-node

# Create a directory for geosite files and download into it
mkdir -p /var/lib/marzban/assets/
wget -O /var/lib/marzban/assets/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat
wget -O /var/lib/marzban/assets/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat
wget -O /var/lib/marzban/assets/iran.dat https://github.com/bootmortis/iran-hosted-domains/releases/latest/download/iran.dat

# Enter custom service and API port
read -p $'\e[34mPlease Enter Service Port (Default: 62050): \e[0m' SERVICE_PORT
SERVICE_PORT=${SERVICE_PORT:-62050}

read -p $'\e[34mPlease Enter XRAY API Port (Default: 62051): \e[0m' XRAY_API_PORT
XRAY_API_PORT=${XRAY_API_PORT:-62051}

# Replace docker-compose.yml content
echo "services:
  marzban-node:
    image: gozargah/marzban-node:latest
    restart: always
    network_mode: host

    environment:
      SERVICE_PORT: $SERVICE_PORT
      XRAY_API_PORT: $XRAY_API_PORT
      SSL_CERT_FILE: \"/var/lib/marzban-node/ssl_cert.pem\"
      SSL_KEY_FILE: \"/var/lib/marzban-node/ssl_key.pem\"
      SSL_CLIENT_CERT_FILE: \"/var/lib/marzban-node/ssl_client_cert.pem\"

    volumes:
      - /var/lib/marzban-node:/var/lib/marzban-node
      - /var/lib/marzban/assets:/usr/local/share/xray" > Marzban-node/docker-compose.yml

# Run Docker compose up
cd Marzban-node && docker compose down && docker compose up -d

# Enter SSL certificate details
echo -e $'\e[36mPlease Enter SSL certificate from Marzban Master\e[0m'
echo -e $'\e[93mPaste and press Ctrl+D when done\e[0m:'
SSL_CERT_DETAILS=$(</dev/stdin)

# Save SSL certificate details to ssl_client_cert file
echo -e "$SSL_CERT_DETAILS" > /var/lib/marzban-node/ssl_client_cert.pem

# Print completion message
echo -e $'\e[32mMarzban Node is Up and Running successfully.\e[0m'
echo -e $'\e[34mService Port: \e[0m'$SERVICE_PORT
echo -e $'\e[34mXRAY API Port: \e[0m'$XRAY_API_PORT
