<div align="center">
  <img src="./assets/m5stack-arduino-cli-icon.svg" alt="M5Stack Arduino CLI icon" width="140" height="140">
  <h1>M5Stack Arduino CLI Skill</h1>
  <p><strong>A focused skill for Claude and Codex to set up, flash, diagnose, and support M5Stack development with Arduino CLI on Windows and macOS.</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Platform-Windows_10%2B-0A7E8C?style=flat-square" alt="Windows badge">
    <img src="https://img.shields.io/badge/Platform-macOS_11%2B-000000?style=flat-square" alt="macOS badge">
    <img src="https://img.shields.io/badge/Agents-Claude_%26_Codex-6C4AB6?style=flat-square" alt="Claude and Codex badge">
    <img src="https://img.shields.io/badge/Tool-Arduino_CLI-1B5E20?style=flat-square" alt="Arduino CLI badge">
    <img src="https://img.shields.io/badge/Target-M5Stack_%2F_ESP32-37474F?style=flat-square" alt="M5Stack ESP32 badge">
    <img src="https://img.shields.io/badge/License-MIT-E65100?style=flat-square" alt="MIT license badge">
  </p>
  <p><a href="./README.md">English</a> | <a href="./README.ja.md">日本語</a></p>
</div>

## Docs

- Browse the docs site: [Sunwood-ai-labs.github.io/m5stack-arduino-cli-skill](https://sunwood-ai-labs.github.io/m5stack-arduino-cli-skill/)
- English quick start: [`docs/guide/quickstart.md`](./docs/guide/quickstart.md)
- Japanese quick start: [`docs/ja/guide/quickstart.md`](./docs/ja/guide/quickstart.md)

## Overview

This repository packages a reusable skill — usable by both Claude and Codex — for a stubborn but common workflow: getting an M5Stack board working from `arduino-cli` on Windows or macOS when the board shows up as `Unknown`, the serial bridge is generic, or the right ESP32 FQBN is not attached yet.

The skill is optimized for practical troubleshooting and day-to-day development. It prioritizes proving device health, finding the correct serial port (`COM*` on Windows, `/dev/cu.*` on macOS), attaching the right board profile, installing common libraries, and getting back to a successful compile or upload without unnecessary driver churn.

## Install As A Claude Code Skill

Claude Code discovers skills under `.claude/skills/`. Place this repository there using the directory name `m5stack-arduino-cli`.

Clone it into your project:

```bash
git clone https://github.com/Sunwood-ai-labs/m5stack-arduino-cli-skill \
  .claude/skills/m5stack-arduino-cli
```

Or add it as a submodule so the version is pinned with your project:

```bash
git submodule add https://github.com/Sunwood-ai-labs/m5stack-arduino-cli-skill \
  .claude/skills/m5stack-arduino-cli
```

The result should look like:

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

### How paths resolve

Claude Code's working directory is **your project root**, not the skill folder, so the bundled files cannot be reached with a path relative to the current directory. `SKILL.md` refers to its own files as `${CLAUDE_SKILL_DIR}/...` (for example `${CLAUDE_SKILL_DIR}/scripts/setup-m5core2.sh`), where `${CLAUDE_SKILL_DIR}` is the skill's install directory above. Your own files — your sketch folder and any animation assets — stay as ordinary paths in your project.

**Using this repository directly with Codex:** `${CLAUDE_SKILL_DIR}` is a Claude Code convention that Codex does not expand. When you have opened or cloned this repository as the repo itself, read `${CLAUDE_SKILL_DIR}` as the repository root.

## Why This Skill

- Explains why `arduino-cli board list` can show a valid serial port but still report `Unknown`
- Covers Windows and macOS diagnosis for common USB-serial bridges such as `CH9102` and `CP210x`
- Guides the agent to use `arduino-cli`, `esptool`, and OS device information in the right order
- Includes board defaults for M5Core2 and common supporting libraries such as `M5GFX` and `M5Unified`
- Ships both PowerShell (Windows) and bash (macOS/Linux) helpers plus a starter M5Core2 sketch for setup, upload, and development support

## Quick Start

Ask the agent to use the skill explicitly.

In Claude Code:

```text
Use the m5stack-arduino-cli skill to set up my M5Core2 on macOS, attach the correct FQBN, and upload a sample sketch from Arduino CLI.
```

In Codex:

```text
Use $m5stack-arduino-cli to set up my M5Core2 on Windows, attach the correct FQBN, and upload a sample sketch from Arduino CLI.
```

The skill will steer the agent through this workflow:

1. Confirm the OS sees the device as a serial port (`COM*` on Windows, `/dev/cu.*` on macOS).
2. Find `arduino-cli`, including Homebrew or the Arduino IDE bundled binary if needed.
3. Ensure `esp32:esp32` board support is installed.
4. Identify the correct port with OS tools and `arduino-cli board list`.
5. Treat `Unknown` as an identification gap unless the OS or `esptool` also fails.
6. Install `M5GFX` and `M5Unified` when the sketch needs M5 device helpers.
7. Attach the right FQBN and port to the sketch before compiling or uploading.
8. Reuse the bundled scripts and examples for repeatable setup and development.

## Sample Scripts And Example Sketch

Use the included helpers when you want repeatable setup or upload commands.

On Windows (PowerShell):

```powershell
.\scripts\setup-m5core2.ps1 -SketchPath .\examples\m5core2\hello -Port COM11
.\scripts\upload-m5core2.ps1 -SketchPath .\examples\m5core2\hello -Port COM11
```

On macOS (bash) — the scripts auto-detect a likely `/dev/cu.*` port when `--port` is omitted:

```bash
./scripts/setup-m5core2.sh --sketch ./examples/m5core2/hello
./scripts/upload-m5core2.sh --sketch ./examples/m5core2/hello
```

Use the bundled starter sketch when you need a first flash check or a clean development base:

```text
examples/m5core2/hello/hello.ino
```

Use the SD card validation sample when you want to confirm that a microSD card can be mounted, written, read back, and checked for remaining capacity:

```powershell
.\scripts\setup-m5core2.ps1 -SketchPath .\examples\m5core2\sd_text_write -Port COM11
.\scripts\upload-m5core2.ps1 -SketchPath .\examples\m5core2\sd_text_write -Port COM11
```

```bash
./scripts/setup-m5core2.sh --sketch ./examples/m5core2/sd_text_write
./scripts/upload-m5core2.sh --sketch ./examples/m5core2/sd_text_write
```

```text
examples/m5core2/sd_text_write/sd_text_write.ino
```

That sample demonstrates:

- SD card mount with `SD.begin(GPIO_NUM_4, SPI, 25000000)`
- creating and appending a text log file on the card
- reading the file back to the display and serial monitor
- showing free and total SD card capacity on screen

Use the pixel pet sample when you want a playful display demo that stays inside one Arduino sketch:

```powershell
.\scripts\setup-m5core2.ps1 -SketchPath .\examples\m5core2\pixel_pet -Port COM11
.\scripts\upload-m5core2.ps1 -SketchPath .\examples\m5core2\pixel_pet -Port COM11
```

```bash
./scripts/setup-m5core2.sh --sketch ./examples/m5core2/pixel_pet
./scripts/upload-m5core2.sh --sketch ./examples/m5core2/pixel_pet
```

```text
examples/m5core2/pixel_pet/pixel_pet.ino
```

That sample demonstrates:

- converting a transparent animated WebP into an RGB565 animation header for M5Core2
- preserving the full-frame aspect ratio while fitting each frame into a square canvas
- inserting blended loop-transition frames so the last frame returns to the first more naturally
- generating optional preview-strip and sprite-sheet PNGs during conversion
- replaying the imported animation directly instead of adding extra bobbing motion in code
- using Buttons A, B, and C to pet, feed, or put the character to sleep

Preview strip generated from the sampled frames:

![Animated cat preview strip](./docs/public/examples/pixel_pet/generated_cat_animation_preview.png)

Sprite sheet generated from the full sampled animation:

![Animated cat sprite sheet](./docs/public/examples/pixel_pet/generated_cat_animation_sheet.png)

When you want to regenerate the animation assets from an animated WebP with `uv`, run:

```powershell
uv run .\scripts\generate_sprite_animation.py --input 'D:\path\to\cat.webp' --output .\examples\m5core2\pixel_pet\generated_cat_animation.h --preview .\docs\public\examples\pixel_pet\generated_cat_animation_preview.png --sheet .\docs\public\examples\pixel_pet\generated_cat_animation_sheet.png --size 112 --frame-step 4 --sheet-columns 8 --loop-blend-frames 3
```

That command leaves behind:

- `examples/m5core2/pixel_pet/generated_cat_animation.h` for the Arduino sketch
- `docs/public/examples/pixel_pet/generated_cat_animation_preview.png` for a quick frame sanity check
- `docs/public/examples/pixel_pet/generated_cat_animation_sheet.png` for reviewing the sampled frames as a sprite sheet
- a smoother loop by blending the tail of the animation back into the first frame

## Direct Arduino CLI Commands

Use these commands when you want to show the exact `arduino-cli` flow instead of the helper scripts.

On Windows (PowerShell):

```powershell
$cli = "C:\Users\<User>\AppData\Local\Programs\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe"

& $cli board attach -p COM11 -b esp32:esp32:m5stack_core2 .\examples\m5core2\hello
& $cli compile .\examples\m5core2\hello
& $cli upload -p COM11 .\examples\m5core2\hello
```

On macOS (bash):

```bash
port=/dev/cu.wchusbserial53240012345   # from: arduino-cli board list

arduino-cli board attach -p "$port" -b esp32:esp32:m5stack_core2 ./examples/m5core2/hello
arduino-cli compile ./examples/m5core2/hello
arduino-cli upload -p "$port" ./examples/m5core2/hello
```

If you want each command to be explicit and not rely on `sketch.yaml`, add `--fqbn esp32:esp32:m5stack_core2` to the `compile` and `upload` calls.

## Included Files

| Path | Purpose |
| --- | --- |
| [`SKILL.md`](./SKILL.md) | Main skill instructions, rules, and default workflow (read directly by Claude Code) |
| [`agents/openai.yaml`](./agents/openai.yaml) | Codex-facing metadata such as display name and default prompt |
| [`agents/claude.yaml`](./agents/claude.yaml) | Claude-facing interface metadata (parity with `openai.yaml`) |
| [`scripts/setup-m5core2.ps1`](./scripts/setup-m5core2.ps1) | Windows PowerShell helper for CLI discovery, ESP32 setup, library install, and board attach |
| [`scripts/upload-m5core2.ps1`](./scripts/upload-m5core2.ps1) | Windows PowerShell helper for compile and upload |
| [`scripts/setup-m5core2.sh`](./scripts/setup-m5core2.sh) | macOS/Linux bash helper for CLI discovery, ESP32 setup, library install, and board attach |
| [`scripts/upload-m5core2.sh`](./scripts/upload-m5core2.sh) | macOS/Linux bash helper for compile and upload |
| [`scripts/generate_sprite_animation.py`](./scripts/generate_sprite_animation.py) | `uv`-driven converter from transparent animated WebP to RGB565 animation frames plus optional preview artifacts |
| [`examples/m5core2/hello/hello.ino`](./examples/m5core2/hello/hello.ino) | Sample M5Core2 sketch for first flash and development |
| [`examples/m5core2/sd_text_write/sd_text_write.ino`](./examples/m5core2/sd_text_write/sd_text_write.ino) | Sample M5Core2 sketch for SD card text write, readback, and free-space checks |
| [`examples/m5core2/pixel_pet/pixel_pet.ino`](./examples/m5core2/pixel_pet/pixel_pet.ino) | Sample M5Core2 sketch for transparent WebP-driven cat animation and button-driven reactions |
| [`docs/`](./docs/) | Bilingual VitePress docs for browsing the workflow as a site |
| [`references/windows-setup-and-diagnosis.md`](./references/windows-setup-and-diagnosis.md) | Windows commands, setup flow, and `Unknown` troubleshooting |
| [`references/macos-setup-and-diagnosis.md`](./references/macos-setup-and-diagnosis.md) | macOS commands, `/dev/cu.*` port handling, `esptool` checks, and driver guidance |
| [`references/m5-board-notes.md`](./references/m5-board-notes.md) | M5-specific board notes, bridge-chip context, and FQBN defaults |
| [`references/development-and-examples.md`](./references/development-and-examples.md) | Development workflow, sample commands, and example usage |

## Workflow Highlights

### Treat `Unknown` correctly

The skill distinguishes between:

- port detection
- board identification

That difference matters because many healthy M5Stack boards expose only a generic USB-serial bridge to the OS. In that situation, a `COM*` or `/dev/cu.*` port can be completely valid while Arduino CLI still cannot infer the exact board model automatically.

### Prefer proof over guesswork

The guidance intentionally avoids random driver reinstalls. It asks the agent to confirm:

- OS device status
- serial port visibility
- ESP32 package installation
- `esptool` reachability when needed
- the intended board profile and port attachment

### Support real development work

The repository is not limited to one-time setup. It also helps the agent:

- bootstrap a new M5Core2 sketch
- install the common M5 libraries
- keep board and port attachment reproducible
- compile and upload during iterative development
- leave behind runnable CLI commands instead of IDE-only instructions

### Scale to more samples cleanly

The repository now uses a growth-friendly structure:

- board samples live under `examples/<board>/<sample>/`
- shared PowerShell and bash logic lives under `scripts/common/`
- board setup flows live under `scripts/setup/`
- generic upload flows live under `scripts/upload/`
- user-facing wrapper commands stay short at the top level, with `.ps1` (Windows) and `.sh` (macOS/Linux) side by side

## Repository Layout

```text
.
|-- SKILL.md
|-- README.md
|-- README.ja.md
|-- agents/
|   |-- claude.yaml
|   `-- openai.yaml
|-- assets/
|   `-- m5stack-arduino-cli-icon.svg
|-- docs/
|   |-- .vitepress/
|   |-- guide/
|   `-- ja/
|-- examples/
|   `-- m5core2/
|       |-- hello/
|       |-- pixel_pet/
|       `-- sd_text_write/
|-- scripts/
|   |-- common/
|   |   |-- arduino-cli-common.ps1
|   |   `-- arduino-cli-common.sh
|   |-- setup/
|   |-- upload/
|   |-- setup-m5core2.ps1
|   |-- setup-m5core2.sh
|   |-- upload-m5core2.ps1
|   `-- upload-m5core2.sh
`-- references/
    |-- development-and-examples.md
    |-- m5-board-notes.md
    |-- macos-setup-and-diagnosis.md
    `-- windows-setup-and-diagnosis.md
```

## When To Reach For It

Use this repository when you want a repeatable, repo-local skill that helps Claude or Codex:

- set up an M5Stack board on Windows or macOS
- explain why `arduino-cli board list` says `Unknown`
- attach `esp32:esp32:m5stack_core2` or another intended FQBN
- install the libraries an M5 sketch usually needs
- compile and upload sketches with less trial and error
- seed or support an M5Core2 development workflow from CLI only

## License

This repository is available under the [MIT License](./LICENSE).
