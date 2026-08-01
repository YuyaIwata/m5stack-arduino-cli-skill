# Diagnosis Playbook

## The Core Interpretation

`arduino-cli board list` does two separate things:

1. Discover the port.
2. Try to identify the board model.

Many M5Stack devices expose only a generic USB-serial bridge to the OS. That means port discovery can be healthy while board identification stays `Unknown`.

## Decision Flow

### 1. Does the OS see a healthy port?

On Windows:

```powershell
Get-PnpDevice -PresentOnly | Where-Object { $_.Class -in @('Ports','USB') } |
  Select-Object Class,FriendlyName,Status,InstanceId
```

If the target device is present and `Status` is `OK`, the USB transport is usually healthy.

On macOS:

```bash
ls /dev/cu.*
system_profiler SPUSBDataType
```

If a `/dev/cu.wchusbserial*` or `/dev/cu.SLAB_USBtoUART` device appears after plugging in the board, the USB transport is usually healthy. If nothing appears, try a data-capable USB-C cable and a direct port before touching drivers.

### 2. Can `arduino-cli` find the port?

```powershell
arduino-cli board list
arduino-cli board list --format json
```

If the port appears (`COM*` on Windows or `/dev/cu.*` on macOS) but the board name is missing, treat that as a board identity gap, not an automatic driver failure.

### 3. Is the ESP32 core installed?

```powershell
arduino-cli core update-index
arduino-cli core install esp32:esp32
```

Without the ESP32 core, compile, attach, and upload steps will all be incomplete.

### 4. Can `esptool` talk to the chip?

On Windows:

```powershell
& "C:\Users\<User>\AppData\Local\Arduino15\packages\esp32\tools\esptool_py\5.1.0\esptool.exe" --chip auto --port COM11 chip-id
```

On macOS:

```bash
esptool_dir=$(ls -d ~/Library/Arduino15/packages/esp32/tools/esptool_py/* 2>/dev/null | tail -n 1)
"$esptool_dir/esptool" --chip auto --port /dev/cu.wchusbserial* chip-id
```

If `esptool` can identify the chip, you have strong proof that the port is real even if the board model remains `Unknown`.

### 5. Attach the intended FQBN explicitly

```powershell
arduino-cli board attach -p COM11 -b esp32:esp32:m5stack_core2 D:\Prj\M5\VerifyCore2
```

```bash
arduino-cli board attach -p /dev/cu.wchusbserial53240012345 -b esp32:esp32:m5stack_core2 ./examples/m5core2/hello
```

This bridges the gap between a generic serial bridge and the actual board you intend to use.

## What Not To Do First

- Do not recommend random driver reinstalls if the OS already shows the port as healthy.
- On macOS 11+, do not install third-party CH34x/CP210x kexts by default — the in-kernel drivers already cover both bridges.
- Do not treat `Unknown` by itself as proof of a broken cable or missing driver.
- Do not skip the attach step when the project already has a clear intended board.

## Move On To Development

Once the diagnosis is stable, switch to [Development Support](/guide/development) and use the bundled sample sketch and helper scripts instead of repeating one-off commands by hand.
