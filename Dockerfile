# Stage 1: Build Go tools
FROM golang:1.22 AS go-builder

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
  libpcap-dev python3-netaddr \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Go tools individually to avoid module conflicts
RUN go install -v github.com/jaeles-project/gospider@latest
RUN go install -v github.com/tomnomnom/gf@latest
RUN go install -v github.com/tomnomnom/unfurl@latest
RUN go install -v github.com/tomnomnom/waybackurls@latest
RUN go install -v github.com/tomnomnom/meg@latest
RUN go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
RUN go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
RUN go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
RUN go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
RUN go install -v github.com/hakluke/hakrawler@latest
RUN go install -v github.com/lc/gau/v2/cmd/gau@latest
RUN go install -v github.com/owasp-amass/amass/v4/...@latest
RUN go install -v github.com/ffuf/ffuf@latest
RUN go install -v github.com/projectdiscovery/tlsx/cmd/tlsx@latest
RUN go install -v github.com/hahwul/dalfox/v2@latest
RUN go install -v github.com/projectdiscovery/katana/cmd/katana@latest
RUN go install -v github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest
RUN go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
RUN go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
RUN go install -v github.com/projectdiscovery/cloudlist/cmd/cloudlist@latest
RUN go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest
RUN go install -v github.com/projectdiscovery/uncover/cmd/uncover@latest
RUN go install -v github.com/projectdiscovery/alterx/cmd/alterx@latest
RUN go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest
RUN go install -v github.com/projectdiscovery/cvemap/cmd/cvemap@latest
RUN go install -v github.com/OJ/gobuster/v3@latest

# Stage 2: Builder
FROM dunglas/frankenphp:php8.4 AS builder

# Create directories
RUN mkdir -p /usr/src/wordlist /usr/src/github

# System packages installation
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
  build-essential cmake gcc git wget curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Download wordlists
WORKDIR /usr/src/wordlist
RUN wget https://raw.githubusercontent.com/maurosoria/dirsearch/master/db/dicc.txt
RUN wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/deepmagic.com-prefixes-top50000.txt
RUN wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-20000.txt
RUN wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt
RUN wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/api/api-endpoints.txt
RUN wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/Common-DB-Backups.txt
RUN wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common-and-portuguese.txt
RUN wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/directory-list-2.3-medium.txt
RUN wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/raft-medium-files.txt
RUN wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Fuzzing/fuzz-Bo0oM.txt
RUN wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/darkweb2017-top10000.txt
RUN wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/xato-net-10-million-passwords-10000.txt

# Clone and install security tools
WORKDIR /usr/src/github
RUN git clone --depth 1 https://github.com/aboul3la/Sublist3r /usr/src/github/Sublist3r
RUN git clone --depth 1 https://github.com/shmilylty/OneForAll /usr/src/github/OneForAll
RUN git clone --depth 1 https://github.com/FortyNorthSecurity/EyeWitness /usr/src/github/EyeWitness
RUN git clone --depth 1 https://github.com/laramies/theHarvester /usr/src/github/theHarvester
RUN git clone --depth 1 https://github.com/scipag/vulscan /usr/src/github/scipag_vulscan
RUN git clone --depth 1 https://github.com/Tuhinshubhra/CMSeeK /usr/src/github/CMSeeK
RUN git clone --depth 1 https://github.com/The404Hacking/Infoga /usr/src/github/Infoga
RUN git clone --depth 1 https://github.com/UnaPibaGeek/ctfr /usr/src/github/ctfr
RUN git clone --depth 1 https://github.com/m3n0sd0n4ld/GooFuzz.git /usr/src/github/goofuzz
RUN git clone --depth 1 https://github.com/grabowskiadrian/whatsmyname-client.git /usr/src/github/WhatsMyName-Client
RUN git clone --depth 1 https://github.com/darkoperator/dnsrecon.git /usr/src/github/dnsrecon
RUN git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git /usr/src/github/sqlmap-dev
RUN git clone --depth 1 https://github.com/s0md3v/XSStrike.git /usr/src/github/XSStrike
RUN git clone --depth 1 https://github.com/devanshbatham/paramspider.git /usr/src/github/paramspider

# Stage 3: Main image
FROM jftecnologia/frankenphp:8.4

# Labels and Credits
LABEL \
  name="Vulnerability Scanner" \
  author="Junior Fontenele <dockerfile+vulnscan@juniorfontenele.com.br>" \
  description="Image with set of security tools for vulnerability scanning"

# Install NodeJS repository
RUN curl -fsSL https://deb.nodesource.com/setup_21.x | bash -

# System packages installation
RUN apt-get update && apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
  nmap nodejs python3 python3-dev python3-pip gconf-service \
  build-essential cmake geoip-bin geoip-database gcc git wget curl \
  host dnsutils whois netcat-openbsd libpq-dev libpango-1.0-0 \
  libpangoft2-1.0-0 libpcap-dev python3-netaddr \
  # Browsershot dependencies
  libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 \
  libexpat1 libfontconfig1 libgbm1 libgcc1 libgconf-2-4 \
  libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 \
  libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 \
  libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 \
  libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 \
  libxtst6 ca-certificates fonts-liberation libappindicator1 \
  libnss3 lsb-release xdg-utils libgbm-dev libxshmfence-dev && \
  npm install --location=global --unsafe-perm puppeteer@^17 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1 \
  GOROOT="/usr/local/go" \
  GOPATH=/root/go \
  PATH="/usr/local/go/bin:/root/go/bin:/go/bin:${PATH}"

# Create directories
RUN mkdir -p /usr/src/app /usr/src/wordlist /usr/src/scan_results ~/.gf

# Copy Go binaries from builder
COPY --from=go-builder /go/bin /go/bin

# Install and configure tools
COPY ./requirements.txt /tmp/requirements.txt
RUN pip install --break-system-packages -r /tmp/requirements.txt && \
  # Configure httpx alias
  echo 'alias httpx="/go/bin/httpx"' >> ~/.bashrc && \
  # Install GF patterns
  git clone https://github.com/tomnomnom/gf ~/Gf-tomnomnom && \
  mv ~/Gf-tomnomnom/examples/*.json ~/.gf && \
  git clone https://github.com/1ndianl33t/Gf-Patterns ~/Gf-Patterns && \
  mv ~/Gf-Patterns/*.json ~/.gf

# Copy Wordlists
COPY --from=builder /usr/src/wordlist /usr/src/wordlist

# Copy security tools from builder
COPY --from=builder /usr/src/github /usr/src/github

RUN ln -s /usr/src/github/scipag_vulscan /usr/share/nmap/scripts/vulscan && \
  ln -s /usr/src/github/sqlmap-dev/sqlmap.py /usr/local/bin/sqlmap && \
  chmod +x /usr/src/github/goofuzz/GooFuzz

# Install Python dependencies for cloned tools
RUN pip install --break-system-packages -r /usr/src/github/Sublist3r/requirements.txt
RUN pip install --break-system-packages -r /usr/src/github/OneForAll/requirements.txt
RUN pip install --break-system-packages -r /usr/src/github/theHarvester/requirements/base.txt
RUN pip install --break-system-packages -r /usr/src/github/CMSeeK/requirements.txt
RUN pip install --break-system-packages -r /usr/src/github/WhatsMyName-Client/requirements.txt
RUN pip install --break-system-packages -r /usr/src/github/dnsrecon/requirements.txt
RUN pip install --break-system-packages -r /usr/src/github/XSStrike/requirements.txt

# Update and configure tools
RUN nuclei -update && \
  nuclei -update-templates && \
  httpx -up && \
  naabu -up && \
  subfinder -up && \
  tlsx -up && \
  katana -up && \
  python3 /usr/src/github/WhatsMyName-Client/wmnc.py update

# Install proxychains4
RUN wget https://github.com/haad/proxychains/archive/refs/tags/proxychains-4.4.0.tar.gz -O /tmp/proxychains.tar.gz && \
  tar -xf /tmp/proxychains.tar.gz -C /tmp && \
  cd /tmp/proxychains-proxychains-4.4.0 && \
  ./configure && \
  USER_CFLAGS="-Wno-stringop-truncation" make && \
  make install && \
  cp src/proxychains.conf /etc/proxychains.conf && \
  cd / && \
  rm -rf /tmp/proxychains*

# Copy supervisor configuration
COPY ./supervisord.conf /etc/supervisor/supervisord.conf

# Set working directory
WORKDIR /app