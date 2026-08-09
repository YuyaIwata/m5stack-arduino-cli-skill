#!/usr/bin/env bash
# Compile and upload a sketch on macOS or Linux.
#
# Usage:
#   scripts/upload/sketch.sh --sketch PATH [--port PORT] [--fqbn FQBN] [--dry-run]
#
# When --port is omitted the script tries to auto-detect a likely M5 port.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/arduino-cli-common.sh
source "$SCRIPT_DIR/../common/arduino-cli-common.sh"

SKETCH_PATH=""
PORT=""
FQBN=""
DRY_RUN=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --sketch) SKETCH_PATH="$2"; shift 2 ;;
        --port) PORT="$2"; shift 2 ;;
        --fqbn) FQBN="$2"; shift 2 ;;
        --dry-run) DRY_RUN=1; shift ;;
        -h|--help)
            grep '^#' "${BASH_SOURCE[0]}" | grep -v -e '^#!' -e 'shellcheck' | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

if [[ -z "$SKETCH_PATH" ]]; then
    echo "--sketch PATH is required." >&2
    exit 1
fi

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
RESOLVED_SKETCH="$(cd "$SKETCH_PATH" && pwd)"

compile_args=(compile)
if [[ -n "$FQBN" ]]; then
    compile_args+=(--fqbn "$FQBN")
fi
compile_args+=("$RESOLVED_SKETCH")
run "$CLI" "${compile_args[@]}"

if [[ -z "$PORT" ]]; then
    PORT="$(detect_serial_port)"
fi

upload_args=(upload)
if [[ -n "$PORT" ]]; then
    upload_args+=(-p "$PORT")
else
    echo "No serial port detected; pass --port /dev/cu.* to upload." >&2
    exit 1
fi
if [[ -n "$FQBN" ]]; then
    upload_args+=(--fqbn "$FQBN")
fi
upload_args+=("$RESOLVED_SKETCH")
run "$CLI" "${upload_args[@]}"
