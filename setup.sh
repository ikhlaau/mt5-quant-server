#!/bin/bash
echo "==> MT5 Quant Server Setup =="

# System deps
apt-get update
apt-get install -y wget dos2unix python3-pip xvfb netcat-openbsd gnupg software-properties-common 2>&1
pip3 install --upgrade pip 2>&1

# Download full repo
echo "==> Downloading MT5 source..."
wget -qO- https://github.com/ikhlaau/mt5-quant-server/archive/refs/heads/main.tar.gz | tar xz
cd mt5-quant-server-main

# Wine
echo "==> Installing Wine..."
wget -q https://dl.winehq.org/wine-builds/winehq.key
apt-key add winehq.key && rm winehq.key
add-apt-repository -y 'deb https://dl.winehq.org/wine-builds/debian/ bullseye main'
dpkg --add-architecture i386
apt-get update
apt-get install --install-recommends -y winehq-stable 2>&1
apt-get clean 2>&1

# Setup scripts
echo "==> Setting up app..."
dos2unix backend/mt5/scripts/*.sh 2>/dev/null || true
chmod +x backend/mt5/scripts/*.sh
cp -r backend/mt5/app /app
cp -r backend/mt5/scripts /scripts

# Virtual display
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x16 &
sleep 2

# Install MT5 + Python
echo "==> Installing MT5 + Python..."
cd /scripts
bash 03-install-mono.sh 2>&1 || echo "WARN: mono install had issues"
bash 04-install-mt5.sh 2>&1 || echo "WARN: mt5 install had issues"
bash 05-install-python.sh 2>&1 || echo "WARN: python install had issues"
bash 06-install-libraries.sh 2>&1 || echo "WARN: libs install had issues"

# Start Flask API
echo "==> Starting MT5 Flask API on port 5001..."
bash 07-start-wine-flask.sh 2>&1 || echo "WARN: flask start had issues"

# Keep alive
echo "==> Setup complete!"
tail -f /dev/null
