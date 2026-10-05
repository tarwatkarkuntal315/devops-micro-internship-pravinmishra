#!/bin/bash
# Author: Kuntal Tarwatkar
# Installs EpicBook prerequisites only (no DB credentials or app configuration)
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

# Update packages
apt-get update -y
apt-get upgrade -y

# Git, Nginx, MySQL client and curl
apt-get install -y git nginx mysql-client curl ca-certificates

# Node.js LTS (22.x) and npm from NodeSource
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs

# Start and enable Nginx
systemctl enable --now nginx

node --version
npm --version
echo "EpicBook prerequisites installed successfully"
