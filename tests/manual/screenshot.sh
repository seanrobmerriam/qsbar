#!/usr/bin/env bash
# tests/manual/screenshot.sh
#
# Grab a 1920×60 region of the running Hyprland session for visual
# evidence in PRs (per constitution Principle III — Test-First for
# Logic & Contracts).
#
# Usage: tests/manual/screenshot.sh <output.png>

set -euo pipefail

out="${1:-/tmp/qsbar-screenshot.png}"

if ! command -v grim >/dev/null; then
    echo "grim not found — install grim first." >&2
    exit 1
fi

# Capture the top 60 pixels across all monitors, then concatenate.
grim -g "0,0 1920x60" "$out"
echo "screenshot saved to $out"
