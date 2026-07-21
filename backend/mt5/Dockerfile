FROM debian:bullseye-slim

ENV WINEARCH=win64
ENV WINEPREFIX=/root/.wine
ENV DISPLAY=:99
ENV MT5_API_PORT=5001

RUN apt-get update && apt-get install -y --no-install-recommends \
    dos2unix python3-pip wget python3 python3-venv \
    xvfb gnupg software-properties-common netcat curl \
    && pip3 install --upgrade pip \
    && rm -rf /var/lib/apt/lists/*

# WineHQ
RUN wget -q https://dl.winehq.org/wine-builds/winehq.key \
    && apt-key add winehq.key && rm winehq.key \
    && add-apt-repository 'deb https://dl.winehq.org/wine-builds/debian/ bullseye main' \
    && dpkg --add-architecture i386 && apt-get update \
    && apt-get install --install-recommends -y winehq-stable \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# App code
COPY app /app
COPY scripts /scripts
RUN dos2unix /scripts/*.sh && chmod +x /scripts/*.sh

# Virtual display for Wine
RUN echo 'Xvfb :99 -screen 0 1024x768x16 &' > /start-xvfb.sh && chmod +x /start-xvfb.sh

# Install MT5 + Python for Wine
RUN bash /scripts/02-common.sh || true \
    && bash /scripts/03-install-mono.sh || true \
    && bash /scripts/04-install-mt5.sh || true \
    && bash /scripts/05-install-python.sh || true \
    && bash /scripts/06-install-libraries.sh || true

EXPOSE 3000 5000 5001 8001

# Start script
RUN echo '#!/bin/bash\n/start-xvfb.sh\nsleep 2\nbash /scripts/07-start-wine-flask.sh\ntail -f /dev/null' > /start.sh && chmod +x /start.sh

CMD ["/start.sh"]
