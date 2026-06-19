#!/usr/bin/env bash
# tests/manual/ipc-cleanup.sh
#
# Post-exit IPC audit (per SC-012). Launches qsbar, waits for it to
# register D-Bus names, captures snapshots, sends SIGTERM, then
# re-asserts no `qsbar`-owned D-Bus names remain.
#
# Run before v1.0.0 tag — manual gate.

set -euo pipefail

quickshell_path="${QUICKSHELL_PATH:-/home/sean/qsbar}"
quickshell_bin="${QUICKSHELL_BIN:-quickshell}"
log="tests/manual/ipc-cleanup.log"

echo "$(date -Iseconds) launching qsbar" | tee "$log"
"$quickshell_bin" --path "$quickshell_path" >/dev/null 2>&1 &
pid=$!
trap 'kill "$pid" 2>/dev/null || true' EXIT

# Wait for the bar to subscribe to D-Bus.
for i in $(seq 1 30); do
    sleep 1
    if busctl list 2>/dev/null | grep -qi qsbar; then break; fi
done

echo "before SIGTERM:" | tee -a "$log"
busctl list 2>/dev/null | grep -i qsbar | tee -a "$log" || true
lsof -p "$pid" 2>/dev/null | grep -E 'DBUS|unix' | tee -a "$log" || true

kill -TERM "$pid"
for i in $(seq 1 30); do
    sleep 1
    if ! kill -0 "$pid" 2>/dev/null; then break; fi
done

if kill -0 "$pid" 2>/dev/null; then
    echo "FAIL: quickshell did not exit on SIGTERM" | tee -a "$log"
    kill -KILL "$pid" 2>/dev/null || true
    exit 1
fi

# Re-check: no qsbar-owned D-Bus names should remain.
if busctl list 2>/dev/null | grep -qi qsbar; then
    echo "FAIL: qsbar D-Bus names still registered after exit:" | tee -a "$log"
    busctl list 2>/dev/null | grep -i qsbar | tee -a "$log"
    exit 1
fi

echo "OK: no qsbar D-Bus names remain after SIGTERM" | tee -a "$log"
