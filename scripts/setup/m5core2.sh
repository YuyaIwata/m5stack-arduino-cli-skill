#!/usr/bin/env bash
# Set up ESP32 board support, install common M5 libraries, and optionally
# attach a sketch to a board/port on macOS or Linux.
#
# Usage:
#   scripts/setup/m5core2.sh [--sketch PATH] [--port PORT] [--fqbn FQBN]
#                            [--skip-libraries] [--dry-run]
#
# When --port is omitted the script tries to auto-detect a likely M5 port.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/arduino-cli-common.sh
source "$SCRIPT_DIR/../common/arduino-cli-common.sh"

SKETCH_PATH=""
PORT=""
FQBN="esp32:esp32:m5stack_core2"
SKIP_LIBRARIES=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --sketch) SKETCH_PATH="$2"; shift 2 ;;
        --port) PORT="$2"; shift 2 ;;
        --fqbn) FQBN="$2"; shift 2 ;;
        --skip-libraries) SKIP_LIBRARIES=1; shift ;;
        --dry-run) DRY_RUN=1; shift ;;
        -h|--help)
            grep '^#' "${BASH_SOURCE[0]}" | grep -v -e '^#!' -e 'shellcheck' | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

run() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        printf 'DRY-RUN:'
        printf ' %q' "$@"
        printf '\n'
    else
        "$@"
    fi
}

CLI="$(find_arduino_cli)"
echo "Using arduino-cli: $CLI"

ensure_esp32_url "$CLI"

run "$CLI" core update-index
run "$CLI" core install esp32:esp32

if [[ "$SKIP_LIBRARIES" -eq 0 ]]; then
    run "$CLI" lib install M5GFX
    run "$CLI" lib install M5Unified
fi

if [[ -n "$SKETCH_PATH" ]]; then
    RESOLVED_SKETCH="$(cd "$SKETCH_PATH" && pwd)"
    if [[ -z "$PORT" ]]; then
        PORT="$(detect_serial_port)"
    fi
    if [[ -n "$PORT" ]]; then
        run "$CLI" board attach -p "$PORT" -b "$FQBN" "$RESOLVED_SKETCH"
    else
        echo "No serial port detected; skipping board attach. Pass --port /dev/cu.* to attach." >&2
    fi
fi

"$CLI" board list
