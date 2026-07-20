#!/bin/bash
set -e

echo "==> Installing system packages..."
apt-get update
apt-get install -y dos2unix wget python3-pip netcat xvfb
pip3 install --upgrade pip

echo "==> Installing Wine..."
wget -q https://dl.winehq.org/wine-builds/winehq.key
apt-key add winehq.key && rm winehq.key
add-apt-repository 'deb https://dl.winehq.org/wine-builds/debian/ bullseye main'
dpkg --add-architecture i386
apt-get update
apt-get install --install-recommends -y winehq-stable
apt-get clean

echo "==> Setting up scripts..."
dos2unix backend/mt5/scripts/*.sh
chmod +x backend/mt5/scripts/*.sh
cp -r backend/mt5/app /app
cp -r backend/mt5/scripts /scripts
cp -r backend/mt5/root /

echo "==> Installing MT5 + Python dependencies..."
cd /scripts
bash 03-install-mono.sh
bash 04-install-mt5.sh
bash 05-install-python.sh
bash 06-install-libraries.sh

echo "==> Starting Flask API..."
bash 07-start-wine-flask.sh

echo "==> Setup complete. Keeping alive..."
tail -f /dev/null
