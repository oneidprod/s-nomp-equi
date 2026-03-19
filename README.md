# s-nomp: Some New Open Mining Portal

> *NOTE*:
> We're working on putting together an "official" s-nomp which can be supported by many coins and pools instead of so many running their own flavors. More to come!

This is a Equihash mining pool based off Node Open Mining Portal.

#### Production Usage Notice
This is beta software. All of the following are things that can change and break an existing s-nomp setup: functionality of any feature, structure of configuration files and structure of redis data. If you use this software in production then *DO NOT* pull new code straight into production usage because it can and often will break your setup and require you to tweak things like config files or redis data. *Only tagged releases are considered stable.*

#### Paid Solution
Usage of this software requires abilities with sysadmin, database admin, coin daemons, and sometimes a bit of programming. Running a production pool can literally be more work than a full-time job. 

### Community / Support

Please join our Discord to follow development. Any support questions can be answered here quickly as well.

https://discord.gg/4mVaTsH

# Docker Usage (ARM64 / amd64)

This repo includes a Docker setup tested on both **ARM64 (aarch64)** and **amd64** hosts.

#### Requirements
* Docker and Docker Compose
* A running coin daemon (e.g. `zerod`) on the host machine

#### 0) Setting up the coin daemon

Your coin's `.conf` file should include:
```
rpcuser=yourrpcuser
rpcpassword=yourrpcpassword
rpcbind=127.0.0.1
rpcport=8499
rpcallowip=127.0.0.1
server=1
daemon=1
```

The pool container runs with `network_mode: host` so it connects to the daemon on `127.0.0.1` directly — no need to change `rpcbind`.

#### 1) Configuration

Copy and edit the pool config:
```bash
cp pool_configs/examples/zer.json pool_configs/zer.json
```

Edit `pool_configs/zer.json` and set:
* `address` — your transparent t-address for coinbase rewards
* `tAddress` — your t-address for payments (can be the same)
* `daemons[].host/port/user/password` — your daemon RPC details
* `ports` — stratum port and difficulty settings

Copy and edit the main config:
```bash
cp config_example.json config.json
```

Key settings in `config.json`:
* `redis.host` — set to `127.0.0.1` (host networking)
* `website.enabled` — set to `false` if you don't need the web UI

**Note:** `config.json` and `pool_configs/*.json` are gitignored — they will never be committed as they contain RPC credentials.

#### 2) Difficulty tuning

In `pool_configs/zer.json`, adjust the `ports` section to match your miner's hashrate:
```json
"ports": {
    "3092": {
        "diff": 0.001,
        "varDiff": {
            "minDiff": 0.001,
            "maxDiff": 0.5,
            "targetTime": 15,
            "retargetTime": 60,
            "variancePercent": 30
        }
    }
}
```
VarDiff will auto-tune within the min/max range. For low-hashrate miners (e.g. ~5 sol/s) use `minDiff: 0.001`.

#### 3) Start the pool

```bash
docker compose up -d
docker compose logs -f site
```

On first start, `npm install` will run inside the container and compile native addons (`equihashverify`, etc.). This takes a few minutes. Subsequent restarts skip this and start immediately.

#### 4) Applying config changes

For changes to `pool_configs/zer.json` or `config.json` — no rebuild needed:
```bash
docker compose restart site
```

#### 5) Forcing a fresh npm install

Only needed after changing `Dockerfile` or `package.json`:
```bash
docker run --rm -v $(pwd):/site node:14-bullseye-slim rm -rf /site/node_modules
docker compose restart site
```

#### 6) Monitor logs
```bash
docker compose logs -f site
```

#### Notes on ARM64 compatibility

The original codebase targeted Node 8 / Debian Stretch (x86 only). The following changes were made to support modern ARM64 hosts:

* Base image changed to `node:14-bullseye-slim` (native ARM64, non-archived repos)
* `patch-equihash.sh` patches `equihashverify` C++ source at startup to compile against Node 14's v8 API
* `verushash` (x86-only SSE4/AVX addon) is stubbed out — it is not needed for equihash/ZER mining
* Git SSH dependencies rewritten to HTTPS so no SSH key is needed inside the container
* `network_mode: host` used so the pool can reach the coin daemon on `127.0.0.1` without modifying `rpcbind`

---

#### Legacy (non-Docker) Usage

##### Requirements
* Coin daemon(s)
* [Node.js](http://nodejs.org/) v8.11
* [Redis](http://redis.io/) key-value store v2.6+

```bash
sudo apt-get install build-essential libsodium-dev npm libboost-all-dev
sudo npm install n -g
sudo n stable
git clone https://github.com/s-nomp/s-nomp.git s-nomp
cd s-nomp
npm install
npm start
```


Credits
-------
### s-nomp
* [egyptianbman](https://github.com/egyptianbman)
* [nettts](https://github.com/nettts)
* [potato](https://github.com/zzzpotato)
* You belong here. Join us!

### z-nomp
* [Joshua Yabut / movrcx](https://github.com/joshuayabut)
* [Aayan L / anarch3](https://github.com/aayanl)
* [hellcatz](https://github.com/hellcatz)

### NOMP
* [Matthew Little / zone117x](https://github.com/zone117x) - developer of NOMP
* [Jerry Brady / mintyfresh68](https://github.com/bluecircle) - got coin-switching fully working and developed proxy-per-algo feature
* [Tony Dobbs](http://anthonydobbs.com) - designs for front-end and created the NOMP logo
* [LucasJones](//github.com/LucasJones) - got p2p block notify working and implemented additional hashing algos
* [vekexasia](//github.com/vekexasia) - co-developer & great tester
* [TheSeven](//github.com/TheSeven) - answering an absurd amount of my questions and being a very helpful gentleman
* [UdjinM6](//github.com/UdjinM6) - helped implement fee withdrawal in payment processing
* [Alex Petrov / sysmanalex](https://github.com/sysmanalex) - contributed the pure C block notify script
* [svirusxxx](//github.com/svirusxxx) - sponsored development of MPOS mode
* [icecube45](//github.com/icecube45) - helping out with the repo wiki
* [Fcases](//github.com/Fcases) - ordered me a pizza <3
* Those that contributed to [node-stratum-pool](//github.com/zone117x/node-stratum-pool#credits)

License
-------
Released under the MIT License. See LICENSE file.
