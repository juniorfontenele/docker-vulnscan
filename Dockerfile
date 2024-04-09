FROM jftecnologia/frankenphp:8.3

# Labels and Credits
LABEL \
    name="Vulnerability Scanner" \
    author="Junior Fontenele <dockerfile+vulnscan@juniorfontenele.com.br>" \
    description="Image with set of security tools for vulnerability scanning"

# Install dependencies (nodejs, puppeteer, browsershot, nmap)
RUN curl -fsSL https://deb.nodesource.com/setup_21.x | bash - \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    nmap \
    nodejs \
    python3 \
    python3-dev \
    python3-pip \
    gconf-service \
    build-essential \
    cmake \
    geoip-bin \
    geoip-database \
    gcc \
    git \
    wget \
    curl \
    host \
    dnsutils \
    whois \
    netcat-openbsd \
    libpq-dev \
    libpango-1.0-0 \
    libpangoft2-1.0-0 \
    libpcap-dev \
    python3-netaddr \
# Browsershot
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
    && echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile \
    && export PATH=$PATH:/usr/local/go/bin

ENV GOROOT="/usr/local/go"
ENV GOPATH=$HOME/go
ENV PATH="${PATH}:${GOROOT}/bin:${GOPATH}/bin"

# Make directory for app
WORKDIR /usr/src/app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1    

# Download Go packages
RUN go install -v github.com/jaeles-project/gospider@latest
RUN go install -v github.com/tomnomnom/gf@latest
RUN go install -v github.com/tomnomnom/unfurl@latest
RUN go install -v github.com/tomnomnom/waybackurls@latest
RUN go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
RUN go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
RUN go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
RUN go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
RUN go install -v github.com/hakluke/hakrawler@latest
RUN go install -v github.com/lc/gau/v2/cmd/gau@latest
RUN go install -v github.com/jaeles-project/gospider@latest
RUN go install -v github.com/owasp-amass/amass/v3/...@latest
RUN go install -v github.com/ffuf/ffuf@latest
RUN go install -v github.com/projectdiscovery/tlsx/cmd/tlsx@latest
RUN go install -v github.com/hahwul/dalfox/v2@latest
RUN go install -v github.com/projectdiscovery/katana/cmd/katana@latest
RUN go install -v github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest
RUN go install -v github.com/sa7mon/s3scanner@latest
RUN go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
RUN go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
RUN go install -v github.com/projectdiscovery/cloudlist/cmd/cloudlist@latest
RUN go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest
RUN go install -v github.com/projectdiscovery/uncover/cmd/uncover@latest
RUN go install github.com/projectdiscovery/alterx/cmd/alterx@latest
RUN go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest
RUN go install github.com/projectdiscovery/cvemap/cmd/cvemap@latest
RUN go install github.com/OJ/gobuster/v3@latest

# Update Nuclei and Nuclei-Templates
RUN nuclei -update
RUN nuclei -update-templates

# Update project discovery tools
RUN httpx -up
RUN naabu -up
RUN subfinder -up
RUN tlsx -up
RUN katana -up

# Copy requirements
COPY ./requirements.txt /tmp/requirements.txt
RUN pip install --break-system-packages -r /tmp/requirements.txt

# httpx seems to have issue, use alias instead!!!
RUN echo 'alias httpx="/go/bin/httpx"' >> ~/.bashrc
RUN alias httpx="/go/bin/httpx"

# clone dirsearch default wordlist
RUN mkdir -p /usr/src/wordlist
RUN wget https://raw.githubusercontent.com/maurosoria/dirsearch/master/db/dicc.txt -O /usr/src/wordlist/dicc.txt
RUN wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/deepmagic.com-prefixes-top50000.txt -O /usr/src/wordlist/deepmagic.com-prefixes-top50000.txt

# clone Sublist3r
RUN git clone https://github.com/aboul3la/Sublist3r /usr/src/github/Sublist3r \
    && pip install --break-system-packages -r /usr/src/github/Sublist3r/requirements.txt

# clone OneForAll
RUN git clone https://github.com/shmilylty/OneForAll /usr/src/github/OneForAll \
    && pip install --break-system-packages -r /usr/src/github/OneForAll/requirements.txt

# clone eyewitness
RUN git clone https://github.com/FortyNorthSecurity/EyeWitness /usr/src/github/EyeWitness
    #&& pip install --break-system-packages -r /usr/src/github/Eyewitness/requirements.txt

# clone theHarvester
RUN git clone https://github.com/laramies/theHarvester /usr/src/github/theHarvester \
    && pip install --break-system-packages -r /usr/src/github/theHarvester/requirements/base.txt

# clone vulscan
RUN git clone https://github.com/scipag/vulscan /usr/src/github/scipag_vulscan \
    && ln -s /usr/src/github/scipag_vulscan /usr/share/nmap/scripts/vulscan \
    && echo "Usage in reNgine, set vulscan/vulscan.nse in nmap_script scanEngine port_scan config parameter"

# clone CMSeeK
RUN git clone https://github.com/Tuhinshubhra/CMSeeK /usr/src/github/CMSeeK \
    && pip install --break-system-packages -r /usr/src/github/CMSeeK/requirements.txt

# clone Infoga
RUN git clone https://github.com/GiJ03/Infoga /usr/src/github/Infoga

# clone ctfr
RUN git clone https://github.com/UnaPibaGeek/ctfr /usr/src/github/ctfr

# clone gooFuzz
RUN git clone https://github.com/m3n0sd0n4ld/GooFuzz.git /usr/src/github/goofuzz \
    && chmod +x /usr/src/github/goofuzz/GooFuzz

# clone WhatsMyName Client
RUN git clone https://github.com/grabowskiadrian/whatsmyname-client.git /usr/src/github/WhatsMyName-Client \
    && pip install --break-system-packages -r /usr/src/github/WhatsMyName-Client/requirements.txt \
    && python3 /usr/src/github/WhatsMyName-Client/wmnc.py update

# install h8mail
RUN pip install --break-system-packages h8mail

# install gf patterns
RUN mkdir ~/.gf \
    && git clone https://github.com/tomnomnom/gf ~/Gf-tomnomnom \
    && mv ~/Gf-tomnomnom/examples/*.json ~/.gf \
    && git clone https://github.com/1ndianl33t/Gf-Patterns ~/Gf-Patterns \
    && mv ~/Gf-Patterns/*.json ~/.gf

# store scan_results
RUN mkdir /usr/src/scan_results

# install nuclei templates
RUN rm -rf ~/nuclei-templates/geeknik_nuclei_templates \
    && git clone https://github.com/geeknik/the-nuclei-templates.git ~/nuclei-templates/geeknik_nuclei_templates \
    && wget https://raw.githubusercontent.com/NagliNagli/BountyTricks/main/ssrf.yaml -O ~/nuclei-templates/ssrf_nagli.yaml

# test tools, required for configuration
RUN naabu -hc
RUN subfinder
RUN amass
RUN nuclei

COPY ./supervisord.conf /etc/supervisor/supervisord.conf

WORKDIR /app