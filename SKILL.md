---
name: m5stack-arduino-cli
description: Set up, diagnose, flash, and support development for M5Stack boards with Arduino CLI on Windows or macOS. Use when you need to install ESP32 board support, detect the correct serial port (COM* on Windows, /dev/cu.* on macOS), explain why `arduino-cli board list` shows `Unknown`, attach a board/FQBN to a sketch, compile or upload to M5Stack devices such as M5Core2, prepare supporting libraries, add or update sample sketches, or troubleshoot CH9102/CP210x USB-serial behavior.
---

# M5Stack Arduino CLI

Use this skill to work with M5Stack boards from Arduino CLI on Windows or macOS, especially when the board appears as `Unknown` in `arduino-cli board list`.

## Detect the platform first

Pick the toolset that matches the user's OS before running commands:

- **Windows** → PowerShell helpers (`scripts/*.ps1`), `COM*` ports, `Get-PnpDevice`. See [references/windows-setup-and-diagnosis.md](./references/windows-setup-and-diagnosis.md).
- **macOS / Linux** → bash helpers (`scripts/*.sh`), `/dev/cu.*` (macOS) or `/dev/ttyUSB*` (Linux) devices, `system_profiler`. See [references/macos-setup-and-diagnosis.md](./references/macos-setup-and-diagnosis.md).

The Arduino CLI subcommands themselves (`core`, `lib`, `board attach`, `compile`, `upload`) are identical across platforms — only binary discovery, port naming, and shell syntax differ.

## Follow this workflow

1. Confirm that the OS sees the device as a serial port (`COM*` on Windows, `/dev/cu.*` on macOS).
2. Confirm that `arduino-cli` exists. If it is not on `PATH`, look for Homebrew (`brew install arduino-cli`) or the Arduino IDE bundled binary.
3. Ensure the ESP32 package index is configured and `esp32:esp32` is installed.
4. Identify the correct port with `arduino-cli board list`, OS device info, and, if needed, `esptool`.
5. Treat `Unknown` as a board auto-detection limitation unless the OS or `esptool` also fails.
6. Install common M5 libraries when the sketch touches display, input, or device helpers.
7. Attach the intended FQBN and port to the sketch with `arduino-cli board attach`.
8. Compile and upload using the attached settings or explicit `--fqbn` and `-p`.
9. When the user needs a starting point, reuse the sample sketch and helper scripts from this repository.
10. When supporting ongoing development, keep the workflow focused on reproducible CLI commands, attached board metadata, and concrete sketch paths.

## Key rules

- Do not assume `Unknown` means a missing driver.
- Prefer proving device health with OS device status and `esptool` before changing drivers.
- For M5Core2, expect the device to appear as a generic USB-serial bridge such as `CH9102` or `CP210x` (`/dev/cu.wchusbserial*` or `/dev/cu.SLAB_USBtoUART` on macOS).
- Explain the difference between port detection and board identification: Arduino CLI may know the port while still not knowing the exact board model.
- If upload already works, do not recommend random driver reinstalls.
- On macOS 11+, both the CH34x/CH9102 and CP210x bridges are supported in-kernel — do not install third-party kexts by default.
- If a sketch folder does not exist, create a minimal one and attach the board there.
- Prefer using the bundled sample scripts before rewriting the same PowerShell or bash every time.
- Prefer updating or cloning the included example sketch before inventing a brand-new starter from scratch.

## M5Core2 defaults

- FQBN: `esp32:esp32:m5stack_core2`
- Common USB bridge identities:
  - Windows: `USB-Enhanced-SERIAL CH9102`, `Silicon Labs CP210x USB to UART Bridge`
  - macOS: `/dev/cu.wchusbserial*` (CH9102), `/dev/cu.SLAB_USBtoUART` (CP210x)
- Common supporting libraries:
  - `M5GFX`
  - `M5Unified`

## Reusable resources

Windows (PowerShell):

- Use [scripts/setup-m5core2.ps1](./scripts/setup-m5core2.ps1) to locate Arduino CLI, ensure ESP32 support is configured, install common libraries, and optionally attach a sketch to a board/port.
- Use [scripts/upload-m5core2.ps1](./scripts/upload-m5core2.ps1) to compile and upload a sketch with attached settings or an explicit board and port.

macOS / Linux (bash):

- Use [scripts/setup-m5core2.sh](./scripts/setup-m5core2.sh) for the same setup flow. It auto-detects a likely `/dev/cu.*` port when `--port` is omitted.
- Use [scripts/upload-m5core2.sh](./scripts/upload-m5core2.sh) to compile and upload. Add `--dry-run` to preview commands.

Shared:

- Use [examples/m5core2/hello/hello.ino](./examples/m5core2/hello/hello.ino) as the default sample sketch for setup checks and first-flash validation.
- Use [scripts/generate_sprite_animation.py](./scripts/generate_sprite_animation.py) when a user wants to turn a transparent animated WebP into RGB565 frames and preview artifacts for M5Core2.
- Add future examples under `examples/<board>/<sample>/`, future board setup flows under `scripts/setup/`, and shared logic under `scripts/common/`.

## Canonical command examples

### Windows (PowerShell)

```powershell
$cli = "C:\Users\<User>\AppData\Local\Programs\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe"

& $cli board attach -p COM11 -b esp32:esp32:m5stack_core2 .\examples\m5core2\hello
& $cli compile .\examples\m5core2\hello
& $cli upload -p COM11 .\examples\m5core2\hello
```

With explicit board selection on each command:

```powershell
& $cli compile --fqbn esp32:esp32:m5stack_core2 .\examples\m5core2\hello
& $cli upload -p COM11 --fqbn esp32:esp32:m5stack_core2 .\examples\m5core2\hello
```

Helper scripts:

```powershell
.\scripts\setup-m5core2.ps1 -SketchPath .\examples\m5core2\hello -Port COM11
.\scripts\upload-m5core2.ps1 -SketchPath .\examples\m5core2\hello -Port COM11
```

### macOS (bash)

```bash
port=/dev/cu.wchusbserial53240012345   # from: arduino-cli board list

arduino-cli board attach -p "$port" -b esp32:esp32:m5stack_core2 ./examples/m5core2/hello
arduino-cli compile ./examples/m5core2/hello
arduino-cli upload -p "$port" ./examples/m5core2/hello
```

With explicit board selection on each command:

```bash
arduino-cli compile --fqbn esp32:esp32:m5stack_core2 ./examples/m5core2/hello
arduino-cli upload -p "$port" --fqbn esp32:esp32:m5stack_core2 ./examples/m5core2/hello
```

Helper scripts (auto-detect the port when `--port` is omitted):

```bash
./scripts/setup-m5core2.sh --sketch ./examples/m5core2/hello
./scripts/upload-m5core2.sh --sketch ./examples/m5core2/hello
```

### Animation asset conversion (either platform)

Windows:

```powershell
uv run .\scripts\generate_sprite_animation.py --input 'D:\path\to\cat.webp' --output .\examples\m5core2\pixel_pet\generated_cat_animation.h --preview .\docs\public\examples\pixel_pet\generated_cat_animation_preview.png --sheet .\docs\public\examples\pixel_pet\generated_cat_animation_sheet.png --size 112 --frame-step 4 --sheet-columns 8 --loop-blend-frames 3
.\scripts\upload-m5core2.ps1 -SketchPath .\examples\m5core2\pixel_pet -Port COM11
```

macOS:

```bash
uv run ./scripts/generate_sprite_animation.py --input ~/path/to/cat.webp --output ./examples/m5core2/pixel_pet/generated_cat_animation.h --preview ./docs/public/examples/pixel_pet/generated_cat_animation_preview.png --sheet ./docs/public/examples/pixel_pet/generated_cat_animation_sheet.png --size 112 --frame-step 4 --sheet-columns 8 --loop-blend-frames 3
./scripts/upload-m5core2.sh --sketch ./examples/m5core2/pixel_pet
```

Prefer this flow when the user already has rendered or background-removed animation frames and wants to keep the original motion instead of redrawing a hand-made sprite. The default loop blend makes the wrap from the last frame back to the first less abrupt.

## Read references as needed

- Read [references/windows-setup-and-diagnosis.md](./references/windows-setup-and-diagnosis.md) for the Windows and Arduino CLI workflow, command checklist, and explanation of `Unknown`.
- Read [references/macos-setup-and-diagnosis.md](./references/macos-setup-and-diagnosis.md) for the macOS workflow, `/dev/cu.*` port handling, `esptool` verification, and macOS driver guidance.
- Read [references/m5-board-notes.md](./references/m5-board-notes.md) when you need board mappings, M5-specific package/library guidance, or a concise explanation of why M5 boards often stay `Unknown` in `board list`.
- Read [references/development-and-examples.md](./references/development-and-examples.md) when you need setup, flash, and development examples you can adapt quickly.
