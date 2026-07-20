#!/bin/bash
set -e
echo "==> MT5 Quant Server Setup =="

# System deps
apt-get update
apt-get install -y wget dos2unix python3-pip xvfb netcat-openbsd gnupg software-properties-common
pip3 install --upgrade pip

# Wine
wget -q https://dl.winehq.org/wine-builds/winehq.key
apt-key add winehq.key && rm winehq.key
add-apt-repository 'deb https://dl.winehq.org/wine-builds/debian/ bullseye main'
dpkg --add-architecture i386
apt-get update
apt-get install --install-recommends -y winehq-stable
apt-get clean && rm -rf /var/lib/apt/lists/*

# Setup scripts and app
dos2unix backend/mt5/scripts/*.sh 2>/dev/null || true
chmod +x backend/mt5/scripts/*.sh
cp -r backend/mt5/app /app
cp -r backend/mt5/scripts /scripts

# Start virtual display
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x16 &
sleep 2

# Install MT5 + Python
cd /scripts
bash 03-install-mono.sh
bash 04-install-mt5.sh
bash 05-install-python.sh
bash 06-install-libraries.sh

# Start Flask API
echo "==> Starting MT5 Flask API on port 5001..."
bash 07-start-wine-flask.sh

# Keep alive
tail -f /dev/null
