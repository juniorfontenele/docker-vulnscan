FROM jftecnologia/frankenphp:8.3

# Install dependencies (nodejs, puppeteer, browsershot, nmap)
RUN curl -fsSL https://deb.nodesource.com/setup_21.x | bash - \
    && apt-get update \
    && apt-get install -y \
    nmap \
    nodejs \
    gconf-service \
    libasound2 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    ca-certificates \
    fonts-liberation \
    libappindicator1 \
    libnss3 \
    lsb-release \
    xdg-utils \
    wget \
    libgbm-dev \
    libxshmfence-dev \
    && npm install --location=global --unsafe-perm puppeteer@^17 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install golang
RUN curl -fsSL https://go.dev/dl/go1.22.2.linux-amd64.tar.gz -o go1.22.2.linux-amd64.tar.gz \
    && rm -rf /usr/local/go \
    && tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz \
    && rm go1.22.2.linux-amd64.tar.gz \
    && echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile