#!/usr/bin/env bash
# Shared helpers for the macOS/Linux Arduino CLI flow.
# Source this file from the setup and upload scripts:
#   source "$(dirname "$0")/../common/arduino-cli-common.sh"

set -euo pipefail

ESP32_PACKAGE_URL="https://espressif.github.io/arduino-esp32/package_esp32_index.json"

# Print the path to a usable arduino-cli binary or exit with an error.
# Order: PATH, Homebrew, the Arduino IDE bundled binary (macOS then Linux).
find_arduino_cli() {
    if command -v arduino-cli >/dev/null 2>&1; then
        command -v arduino-cli
        return 0
    fi

    local candidates=(
        "/opt/homebrew/bin/arduino-cli"
        "/usr/local/bin/arduino-cli"
        "/Applications/Arduino IDE.app/Contents/Resources/app/lib/backend/resources/arduino-cli"
        "$HOME/.local/bin/arduino-cli"
    )

    local candidate
    for candidate in "${candidates[@]}"; do
        if [[ -x "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    echo "arduino-cli was not found on PATH, via Homebrew, or in the Arduino IDE app bundle." >&2
    echo "Install it with 'brew install arduino-cli' or from https://arduino.github.io/arduino-cli/latest/installation/" >&2
    return 1
}

# Make sure the ESP32 board-manager URL is present in the arduino-cli config.
# Uses 'config' subcommands instead of hand-editing YAML so it works the same
# on macOS and Linux regardless of where the config file lives.
ensure_esp32_url() {
    local cli="$1"

    if ! "$cli" config dump >/dev/null 2>&1; then
        "$cli" config init >/dev/null
    fi

    if "$cli" config dump 2>/dev/null | grep -qF "$ESP32_PACKAGE_URL"; then
        return 0
    fi

    "$cli" config add board_manager.additional_urls "$ESP32_PACKAGE_URL"
}

# Best-effort detection of a likely M5Stack serial port on macOS/Linux.
# Prints the first match, or nothing if none is found.
detect_serial_port() {
    local pattern
    # macOS callout devices for the common M5 USB-serial bridges, then Linux.
    for pattern in \
        /dev/cu.wchusbserial* \
        /dev/cu.usbserial* \
        /dev/cu.SLAB_USBtoUART* \
        /dev/cu.usbmodem* \
        /dev/ttyUSB* \
        /dev/ttyACM*; do
        local match
        for match in $pattern; do
            if [[ -e "$match" ]]; then
                printf '%s\n' "$match"
                return 0
            fi
        done
    done
    return 0
}
