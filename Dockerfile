FROM node:14-bullseye-slim

RUN apt-get update && \
    apt-get -yqq install --no-install-recommends \
        libboost-dev \
        libboost-system-dev \
        libsodium-dev \
        build-essential \
        python3 \
        nano \
        git \
        curl \
        screen \
        ca-certificates && \
    npm install -g pm2 && \
    rm -rf /var/lib/apt/lists/*

RUN git config --global url."https://github.com/".insteadOf "git@github.com:" && \
    git config --global url."https://github.com/".insteadOf "ssh://git@github.com/"

ENV NPM_CONFIG_LOGLEVEL warn

CMD ["pm2-runtime", "start", "ecosystem.config.js", "--only", "site"]
