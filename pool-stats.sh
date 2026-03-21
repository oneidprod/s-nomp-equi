#!/bin/bash
# ZER Pool Stats — queries Redis directly
REDIS="docker exec s-nomp-equi-redis-1 redis-cli"

echo "==============================="
echo " ZER POOL STATS"
echo "==============================="

# Blocks pending (all of them, sorted by height)
echo ""
echo "--- All Blocks (pending confirmation) ---"
echo "  Height   Worker                                              Time (CT)"
echo "  -------- -------------------------------------------------- -------------------------"
$REDIS smembers zero:blocksPending | while IFS=: read -r bhash txhash height worker ts; do
  # convert ms epoch to human readable in CT
  ts_sec=$((ts / 1000))
  dt=$(TZ="America/Chicago" date -d "@${ts_sec}" "+%Y-%m-%d %H:%M:%S CT" 2>/dev/null || date -r "${ts_sec}" "+%Y-%m-%d %H:%M:%S CT")
  printf "  %-8s %-50s %s\n" "$height" "$worker" "$dt"
done | sort -k1 -n

echo ""
echo "==============================="

# Current round shares by worker
echo ""
echo "--- Current Round Shares (by worker) ---"
$REDIS hgetall zero:shares:roundCurrent | paste - - | sort -k2 -rn | \
  awk '{printf "  %-55s %s\n", $1, $2}'

echo ""
echo "==============================="

# Overall stats
valid_blocks=$($REDIS hget zero:stats validBlocks)
valid_shares=$($REDIS hget zero:stats validShares)
invalid_shares=$($REDIS hget zero:stats invalidShares)
echo ""
echo "  Blocks found : ${valid_blocks:-0}"
echo "  Valid shares : ${valid_shares:-0}"
echo "  Invalid shares: ${invalid_shares:-0}"

echo ""
echo "==============================="
