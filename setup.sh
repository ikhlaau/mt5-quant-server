#!/bin/bash
# Phase 1: Start HTTP server immediately to prove container is alive
python3 -m http.server 8000 --directory /tmp &
echo "HTTP server started on port 8000"

# Phase 2: Download and install in background
(
  echo "==> MT5 Setup starting..."
  apt-get update -qq
  apt-get install -y -qq wget dos2unix python3-pip xvfb gnupg software-properties-common
  pip3 install --upgrade pip -q

  cd /tmp
  wget -qO- https://github.com/ikhlaau/mt5-quant-server/archive/refs/heads/main.tar.gz | tar xz
  cd mt5-quant-server-main

  wget -q https://dl.winehq.org/wine-builds/winehq.key
  apt-key add winehq.key && rm winehq.key
  add-apt-repository -y 'deb https://dl.winehq.org/wine-builds/debian/ bullseye main'
  dpkg --add-architecture i386
  apt-get update -qq
  apt-get install --install-recommends -y -qq winehq-stable
  apt-get clean

  dos2unix backend/mt5/scripts/*.sh 2>/dev/null || true
  chmod +x backend/mt5/scripts/*.sh
  cp -r backend/mt5/app /app
  cp -r backend/mt5/scripts /scripts

  export DISPLAY=:99
  Xvfb :99 -screen 0 1024x768x16 &
  sleep 2

  cd /scripts
  bash 03-install-mono.sh || true
  bash 04-install-mt5.sh || true
  bash 05-install-python.sh || true
  bash 06-install-libraries.sh || true
  bash 07-start-wine-flask.sh || true

  echo "==> Setup complete!"
) &

# Keep container alive
tail -f /dev/null
