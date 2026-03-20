#!/bin/sh
# Remove verushash (x86-only, not needed for ZER) from stratum-pool deps
if [ -f node_modules/stratum-pool/package.json ]; then
    echo "Removing verushash from stratum-pool/package.json"
    node -e "var fs=require('fs'),p='node_modules/stratum-pool/package.json',j=JSON.parse(fs.readFileSync(p));delete j.dependencies.verushash;fs.writeFileSync(p,JSON.stringify(j,null,2))"
    rm -rf node_modules/stratum-pool/node_modules/verushash node_modules/verushash
fi
