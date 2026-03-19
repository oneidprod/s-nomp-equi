#!/bin/sh
# Remove verushash (x86-only, not needed for ZER) from stratum-pool deps
if [ -f node_modules/stratum-pool/package.json ]; then
    echo "Removing verushash from stratum-pool/package.json"
    node -e "var fs=require('fs'),p='node_modules/stratum-pool/package.json',j=JSON.parse(fs.readFileSync(p));delete j.dependencies.verushash;fs.writeFileSync(p,JSON.stringify(j,null,2))"
    rm -rf node_modules/stratum-pool/node_modules/verushash node_modules/verushash
fi

# Patch equihashverify.cc to compile with Node 14+ v8 API
# Only patches files that still use the old API (idempotent)
for f in \
    node_modules/equihashverify/equihashverify.cc \
    node_modules/stratum-pool/node_modules/equihashverify/equihashverify.cc; do
    [ -f "$f" ] || continue

    # Only patch if Handle<Object> is present (old API marker)
    if grep -q 'Handle<Object>' "$f"; then
        echo "Patching (old API) $f"
        sed -i 's/String::NewFromUtf8(\(isolate, "[^"]*"\))/String::NewFromUtf8(\1).ToLocalChecked()/g' "$f"
        sed -i 's/args\[\([0-9]*\)\]->ToObject()/args[\1]->ToObject(isolate->GetCurrentContext()).ToLocalChecked()/g' "$f"
        sed -i 's/String::Utf8Value str(args\[2\])/String::Utf8Value str(isolate, args[2])/' "$f"
        sed -i 's/void Init(Handle<Object>/void Init(Local<Object>/' "$f"
    else
        echo "Skipping (already modern API) $f"
    fi
done
