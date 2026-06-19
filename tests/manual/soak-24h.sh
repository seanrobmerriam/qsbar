#!/usr/bin/env bash
# tests/manual/soak-24h.sh
#
# 24-hour memory-leak soak harness (per SC-011). Launches the bar
# against the starter config, samples resident memory every 60 seconds
# for 24 hours, and asserts RSS drift ≤ ±5 % at the end.
#
# Produces tests/manual/soak-24h.log. Exits non-zero on regression.
#
# Run before v1.0.0 tag — manual gate.

set -euo pipefail

log="tests/manual/soak-24h.log"
samples=1440                # 24 * 60
interval=60                # seconds
quickshell_path="${QUICKSHELL_PATH:-/home/sean/qsbar}"
quickshell_bin="${QUICKSHELL_BIN:-quickshell}"

# Launch.
"$quickshell_bin" --path "$quickshell_path" >/dev/null 2>&1 &
pid=$!
trap 'kill "$pid" 2>/dev/null || true' EXIT

# Warm-up: give the bar 60 seconds to settle.
sleep "$interval"

declare -a rss_samples=()
for i in $(seq 1 "$samples"); do
    if ! kill -0 "$pid" 2>/dev/null; then
        echo "$(date -Iseconds) FAIL: quickshell exited prematurely" | tee -a "$log"
        exit 1
    fi
    rss=$(ps -o rss= -p "$pid" | tr -d ' ')
    rss_samples+=("$rss")
    echo "$(date -Iseconds) sample=$i rss=${rss}KB" >>"$log"
    sleep "$interval"
done

# Compute drift between first and last 10 samples.
head_avg=$(printf '%s\n' "${rss_samples[@]:0:10}" | awk '{s+=$1} END {print s/NR}')
tail_avg=$(printf '%s\n' "${rss_samples[@]: -10}" | awk '{s+=$1} END {print s/NR}')

if [ "$head_avg" -le 0 ]; then
    echo "soak: head_avg is 0 — process never started?" | tee -a "$log"
    exit 1
fi

drift=$(awk -v h="$head_avg" -v t="$tail_avg" 'BEGIN { printf "%.4f", (t-h)/h }')
echo "head_avg=${head_avg}KB tail_avg=${tail_avg}KB drift=${drift}" | tee -a "$log"

abs_drift=$(awk -v d="$drift" 'BEGIN { if (d<0) d=-d; printf "%.4f", d }')
limit=0.05
if awk -v a="$abs_drift" -v l="$limit" 'BEGIN { exit !(a > l) }'; then
    echo "soak: drift ${abs_drift} exceeds ±${limit} limit — REGRESSION" | tee -a "$log"
    exit 1
fi

echo "soak: drift ${abs_drift} within ±${limit} limit — OK" | tee -a "$log"
