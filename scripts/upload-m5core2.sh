#!/usr/bin/env bash
# Convenience wrapper for the M5Core2 compile-and-upload flow on macOS or Linux.
#
# Usage:
#   scripts/upload-m5core2.sh --sketch PATH [--port PORT] [--fqbn FQBN] [--dry-run]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/upload/sketch.sh" "$@"
