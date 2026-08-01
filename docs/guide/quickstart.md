# Quick Start

## What This Skill Solves

Use this skill when an M5Stack board is connected to Windows or macOS but `arduino-cli board list` still reports the board as `Unknown`, or when you want the agent to set up, attach, and flash the correct board profile before development starts.

## Install As A Claude Code Skill

Claude Code loads skills from `.claude/skills/`. Place this repository there under the directory name `m5stack-arduino-cli`.

Clone it into your project:

```bash
git clone https://github.com/Sunwood-ai-labs/m5stack-arduino-cli-skill \
  .claude/skills/m5stack-arduino-cli
```

Or pin it to your project as a submodule:

```bash
git submodule add https://github.com/Sunwood-ai-labs/m5stack-arduino-cli-skill \
  .claude/skills/m5stack-arduino-cli
```

The layout should be:

```text
your-project/
└── .claude/
    └── skills/
        └── m5stack-arduino-cli/
            ├── SKILL.md
            ├── scripts/
            ├── references/
            └── examples/
```

**How paths resolve:** Claude Code's working directory is your project root, not the skill folder, so bundled files cannot be reached with a path relative to the current directory. `SKILL.md` refers to its own files as `${CLAUDE_SKILL_DIR}/...` (the skill's install directory above), while your own sketch and assets stay as ordinary paths in your project. `${CLAUDE_SKILL_DIR}` is a Claude Code convention that Codex does not expand — when using this repository directly with Codex, read it as the repository root.

## Recommended Prompt

In Claude Code:

```text
Use the m5stack-arduino-cli skill to set up my M5Core2 on macOS, attach the correct FQBN, and upload a sample sketch from Arduino CLI.
```

In Codex:

```text
Use $m5stack-arduino-cli to set up my M5Core2 on Windows, attach the correct FQBN, and upload a sample sketch from Arduino CLI.
```

## Default Workflow

1. Confirm that the OS sees the board as a serial device (`COM*` on Windows, `/dev/cu.*` on macOS).
2. Locate `arduino-cli`, including Homebrew or the Arduino IDE bundled binary if it is not on `PATH`.
3. Ensure the ESP32 core is configured and installed.
4. Identify the current port from OS tools and `arduino-cli board list`.
5. Treat `Unknown` as an auto-identification limit unless transport checks fail too.
6. Install `M5GFX` and `M5Unified` when the sketch uses M5 libraries.
7. Attach the intended FQBN and port to the sketch.
8. Compile and upload with the attached configuration.

## High-Value Commands

On Windows:

```powershell
where.exe arduino-cli
Get-CimInstance Win32_SerialPort | Select-Object DeviceID,Name,Description,PNPDeviceID
Get-PnpDevice -PresentOnly | Where-Object { $_.Class -in @('Ports','USB') } |
  Select-Object Class,FriendlyName,Status,InstanceId
arduino-cli board list
arduino-cli core update-index
arduino-cli core install esp32:esp32
arduino-cli lib install M5GFX
arduino-cli lib install M5Unified
arduino-cli board attach -p COM11 -b esp32:esp32:m5stack_core2 .\examples\m5core2\hello
arduino-cli compile .\examples\m5core2\hello
arduino-cli upload -p COM11 .\examples\m5core2\hello
```

On macOS:

```bash
command -v arduino-cli
ls /dev/cu.*
system_profiler SPUSBDataType
arduino-cli board list
arduino-cli core update-index
arduino-cli core install esp32:esp32
arduino-cli lib install M5GFX
arduino-cli lib install M5Unified
port=/dev/cu.wchusbserial53240012345   # from: arduino-cli board list
arduino-cli board attach -p "$port" -b esp32:esp32:m5stack_core2 ./examples/m5core2/hello
arduino-cli compile ./examples/m5core2/hello
arduino-cli upload -p "$port" ./examples/m5core2/hello
```

## Bundled Helpers

On Windows:

```powershell
.\scripts\setup-m5core2.ps1 -SketchPath .\examples\m5core2\hello -Port COM11
.\scripts\upload-m5core2.ps1 -SketchPath .\examples\m5core2\hello -Port COM11
```

On macOS (auto-detects a `/dev/cu.*` port when `--port` is omitted):

```bash
./scripts/setup-m5core2.sh --sketch ./examples/m5core2/hello
./scripts/upload-m5core2.sh --sketch ./examples/m5core2/hello
```

For an SD card check that writes a text file and shows remaining capacity:

```powershell
.\scripts\setup-m5core2.ps1 -SketchPath .\examples\m5core2\sd_text_write -Port COM11
.\scripts\upload-m5core2.ps1 -SketchPath .\examples\m5core2\sd_text_write -Port COM11
```

```bash
./scripts/setup-m5core2.sh --sketch ./examples/m5core2/sd_text_write
./scripts/upload-m5core2.sh --sketch ./examples/m5core2/sd_text_write
```

For the animated cat example that replays frames imported from an animated WebP:

```powershell
.\scripts\setup-m5core2.ps1 -SketchPath .\examples\m5core2\pixel_pet -Port COM11
.\scripts\upload-m5core2.ps1 -SketchPath .\examples\m5core2\pixel_pet -Port COM11
```

```bash
./scripts/setup-m5core2.sh --sketch ./examples/m5core2/pixel_pet
./scripts/upload-m5core2.sh --sketch ./examples/m5core2/pixel_pet
```

## Direct Compile And Upload

On Windows:

```powershell
$cli = "C:\Users\<User>\AppData\Local\Programs\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe"

& $cli board attach -p COM11 -b esp32:esp32:m5stack_core2 .\examples\m5core2\hello
& $cli compile .\examples\m5core2\hello
& $cli upload -p COM11 .\examples\m5core2\hello
```

On macOS:

```bash
port=/dev/cu.wchusbserial53240012345

arduino-cli board attach -p "$port" -b esp32:esp32:m5stack_core2 ./examples/m5core2/hello
arduino-cli compile ./examples/m5core2/hello
arduino-cli upload -p "$port" ./examples/m5core2/hello
```

## Good Defaults

- M5Core2 FQBN: `esp32:esp32:m5stack_core2`
- Common bridge identities: `CH9102` (`/dev/cu.wchusbserial*`), `CP210x` (`/dev/cu.SLAB_USBtoUART`)
- Common libraries: `M5Unified`, `M5GFX`
- Default example sketch: `examples/m5core2/hello/hello.ino`
- SD card check sketch: `examples/m5core2/sd_text_write/sd_text_write.ino`
- Animated cat sketch: `examples/m5core2/pixel_pet/pixel_pet.ino`

## Next Step

Move to [Diagnosis Playbook](/guide/diagnosis) when you need a more detailed decision tree, or to [Development Support](/guide/development) when you want sample sketches and repeatable helper scripts.
