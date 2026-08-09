#!/usr/bin/env bash
# Convenience wrapper for the M5Core2 setup flow on macOS or Linux.
#
# Usage:
#   scripts/setup-m5core2.sh [--sketch PATH] [--port PORT] [--fqbn FQBN]
#                            [--skip-libraries] [--dry-run]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/setup/m5core2.sh" "$@"
