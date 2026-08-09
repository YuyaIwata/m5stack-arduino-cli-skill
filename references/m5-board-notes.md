# M5 Board Notes

## Why M5 boards often show `Unknown`

Many M5Stack boards expose USB through a generic USB-serial bridge rather than a board-specific USB identity. On Windows, that often looks like:

- `USB-Enhanced-SERIAL CH9102`
- `Silicon Labs CP210x USB to UART Bridge`

On macOS, the same bridges appear as `/dev/cu.*` callout devices:

- `/dev/cu.wchusbserial*` — CH9102 / CH340 bridge
- `/dev/cu.SLAB_USBtoUART` — Silicon Labs CP210x bridge
- `/dev/cu.usbserial-*` — generic USB-serial

Arduino CLI can usually discover the port, but it may not label the exact board model because the visible USB identity belongs to the bridge chip, not the M5 board family itself.

## Practical implication

This is the normal workflow:

1. Discover the COM port.
2. Identify the board model from user context or project intent.
3. Set the FQBN manually.
4. Attach the board to the sketch.
5. Upload.
6. Keep the sketch and helper scripts around for later development work.

## M5Core2

- FQBN: `esp32:esp32:m5stack_core2`
- Typical libraries:
  - `M5Unified`
  - `M5GFX`
- Useful attach command on Windows:

```powershell
& $cli board attach -p COM11 -b esp32:esp32:m5stack_core2 D:\Prj\M5\VerifyCore2
```

- Useful attach command on macOS:

```bash
arduino-cli board attach -p /dev/cu.wchusbserial53240012345 -b esp32:esp32:m5stack_core2 ./examples/m5core2/hello
```

## Recommended explanation to users

When a user is worried about `Unknown`, explain:

- the serial port itself is detected (a `COM*` port on Windows or a `/dev/cu.*` device on macOS)
- the OS has a working USB-serial driver
- the board name is missing because the bridge chip is generic
- manual FQBN selection is the normal fix

## High-confidence signs the setup is already healthy

- the port shows a healthy status (Windows `Get-PnpDevice` reports `OK`, or the macOS `/dev/cu.*` device is present)
- `arduino-cli upload` completes
- `esptool` identifies an ESP32 on the port
- a test sketch compiles and uploads
