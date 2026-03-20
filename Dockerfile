FROM node:8-slim

RUN echo 'deb http://archive.debian.org/debian stretch main' > /etc/apt/sources.list && \
    echo 'deb http://archive.debian.org/debian-security stretch/updates main' >> /etc/apt/sources.list

RUN apt-get -o Acquire::Check-Valid-Until=false update && \
    apt-get -yqq install --no-install-recommends \
        libboost-dev \
        libboost-system-dev \
        libsodium-dev \
        build-essential \
        python \
        nano \
        git \
        curl \
        screen \
        ca-certificates && \
    npm install -g pm2@4 && \
    rm -rf /var/lib/apt/lists/*

RUN git config --global url."https://github.com/".insteadOf "git@github.com:" && \
    git config --global url."https://github.com/".insteadOf "ssh://git@github.com/"

ENV NPM_CONFIG_LOGLEVEL warn

CMD ["pm2-runtime", "start", "ecosystem.config.js", "--only", "site"]
