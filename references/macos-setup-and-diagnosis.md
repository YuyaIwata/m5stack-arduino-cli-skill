# macOS Setup And Diagnosis

## Goal

Use Arduino CLI on macOS to set up an M5Stack board, identify its serial device,
attach the intended board profile, and upload sketches reliably.

## Checklist

1. Find `arduino-cli`.
2. Confirm the serial device exists in macOS.
3. Install the ESP32 core.
4. Install M5 libraries if needed.
5. Detect the port.
6. Verify the device with `esptool` if board auto-detection is `Unknown`.
7. Attach board + port to the sketch.
8. Compile and upload.
9. Reuse helper scripts when the user needs a repeatable local workflow.

## Typical macOS commands

### Find Arduino CLI

```bash
command -v arduino-cli
```

If that fails, try Homebrew or the Arduino IDE bundled binary:

```bash
brew install arduino-cli
# or, if only the Arduino IDE app is installed:
cli="/Applications/Arduino IDE.app/Contents/Resources/app/lib/backend/resources/arduino-cli"
"$cli" version
```

### Inspect ports

On macOS, an M5Stack board appears as a `/dev/cu.*` callout device. The common
USB-serial bridges show up as:

- `/dev/cu.wchusbserial*` — CH9102 / CH340 bridge
- `/dev/cu.SLAB_USBtoUART` — Silicon Labs CP210x bridge
- `/dev/cu.usbserial-*` — generic USB-serial

```bash
ls /dev/cu.*
arduino-cli board list
arduino-cli board list --format json
# See the USB device tree, including the bridge chip vendor/product:
system_profiler SPUSBDataType
```

Prefer the `/dev/cu.*` (callout) device over the matching `/dev/tty.*` (dial-in)
device when uploading — `cu.*` does not block waiting for carrier detect.

### Configure ESP32 support

If the ESP32 package URL is missing, add it (this edits the arduino-cli config
regardless of where it lives on disk):

```bash
arduino-cli config add board_manager.additional_urls \
  https://espressif.github.io/arduino-esp32/package_esp32_index.json
```

Then run:

```bash
arduino-cli core update-index
arduino-cli core install esp32:esp32
```

### Install common M5 libraries

```bash
arduino-cli lib install M5GFX
arduino-cli lib install M5Unified
```

### Verify an ESP32 serial device with esptool

Use this when `board list` shows `Unknown` but macOS exposes a `/dev/cu.*`
device. The ESP32 core ships `esptool` under `~/Library/Arduino15`:

```bash
esptool_dir=$(ls -d ~/Library/Arduino15/packages/esp32/tools/esptool_py/* 2>/dev/null | tail -n 1)
"$esptool_dir/esptool" --chip auto --port /dev/cu.wchusbserial* chip-id
```

If `esptool` is installed via pip instead, use `esptool.py --chip auto --port /dev/cu.* chip-id`.

Healthy output proves the port is an ESP32-class device even if Arduino CLI
cannot map it to a board name.

### Attach board and port to a sketch

```bash
arduino-cli board attach -p /dev/cu.wchusbserial53240012345 \
  -b esp32:esp32:m5stack_core2 ./examples/m5core2/hello
```

This writes `sketch.yaml` and makes later compile/upload commands simpler.

### Compile and upload

```bash
arduino-cli compile ./examples/m5core2/hello
arduino-cli upload -p /dev/cu.wchusbserial53240012345 ./examples/m5core2/hello
```

If the sketch is already attached, `compile` can use the stored FQBN automatically.

## Helper scripts in this repository

When the skill is used from this repository, prefer these reusable entry points
on macOS:

```bash
./scripts/setup-m5core2.sh --sketch ./examples/m5core2/hello
./scripts/upload-m5core2.sh --sketch ./examples/m5core2/hello
```

Both scripts auto-detect a likely `/dev/cu.*` port when `--port` is omitted.
Pass `--port /dev/cu.wchusbserial...` to pin an explicit device, and `--dry-run`
to print the commands without running them.

## Interpret `Unknown` correctly

`arduino-cli board list` has two separate jobs:

1. Discover the port.
2. Map that port to a known board profile.

It is common for step 1 to succeed while step 2 fails. That yields a valid
`/dev/cu.*` port with `Unknown` in the board column.

Treat `Unknown` as a missing board identity match when:

- the `/dev/cu.*` device is present
- the port opens
- `esptool` can talk to the device
- `arduino-cli upload` succeeds when FQBN is set manually

Treat `Unknown` as a real connection or driver problem only when one of those
checks also fails.

## Driver guidance on macOS

Modern macOS (11+) ships in-kernel drivers for both the CH34x/CH9102 and CP210x
bridges, so most M5Stack boards enumerate without any manual driver install.

- If `/dev/cu.wchusbserial*` or `/dev/cu.SLAB_USBtoUART` appears after plugging
  in the board, the driver is already working — do not install a third-party kext.
- If no `/dev/cu.*` device appears at all, first try a different USB-C cable
  (many are power-only) and a direct port rather than a hub.
- Only if the device still never enumerates on macOS 10.x should you consider
  the vendor driver from WCH (CH9102) or Silicon Labs (CP210x).
- Vendor kexts can conflict with the built-in driver on recent macOS; prefer the
  Apple-provided driver unless you have a concrete reason not to.
