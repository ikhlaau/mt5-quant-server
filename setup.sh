#!/bin/bash
# Start HTTP server immediately
python3 -m http.server 8000 --directory /tmp &
echo "HTTP server started on 8000"

# Now install MT5 in background
(
  apt-get update -qq && apt-get install -y -qq wget python3-pip xvfb gnupg software-properties-common
  pip3 install -q --upgrade pip
  cd /tmp
  wget -qO- https://github.com/ikhlaau/mt5-quant-server/archive/refs/heads/main.tar.gz | tar xz
  cd mt5-quant-server-main
  wget -q https://dl.winehq.org/wine-builds/winehq.key
  apt-key add winehq.key && rm winehq.key
  add-apt-repository -y 'deb https://dl.winehq.org/wine-builds/debian/ bullseye main'
  dpkg --add-architecture i386 && apt-get update -qq
  apt-get install --install-recommends -y -qq winehq-stable && apt-get clean
  dos2unix backend/mt5/scripts/*.sh 2>/dev/null; chmod +x backend/mt5/scripts/*.sh
  cp -r backend/mt5/app /app; cp -r backend/mt5/scripts /scripts
  export DISPLAY=:99; Xvfb :99 -screen 0 1024x768x16 & sleep 2
  cd /scripts
  bash 03-install-mono.sh; bash 04-install-mt5.sh; bash 05-install-python.sh
  bash 06-install-libraries.sh; bash 07-start-wine-flask.sh
  echo "MT5 setup done"
) &

# Keep container alive
exec tail -f /dev/null
