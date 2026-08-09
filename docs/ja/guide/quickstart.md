# クイックスタート

## このスキルが解決すること

Windows / macOS に M5Stack を接続したのに `arduino-cli board list` で `Unknown` と出るときや、開発を始める前に正しいボード設定・書き込みフローを CLI だけで整えたいときに使います。

## Claude Code スキルとしての配置

Claude Code は `.claude/skills/` 配下のスキルを読み込みます。このリポジトリをディレクトリ名 `m5stack-arduino-cli` で配置してください。

プロジェクトに clone する場合:

```bash
git clone https://github.com/YuyaIwata/m5stack-arduino-cli-skill \
  .claude/skills/m5stack-arduino-cli
```

バージョンをプロジェクトに固定したい場合は submodule として追加します:

```bash
git submodule add https://github.com/YuyaIwata/m5stack-arduino-cli-skill \
  .claude/skills/m5stack-arduino-cli
```

配置後のレイアウト:

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

**パスの解決について:** Claude Code の作業ディレクトリ（cwd）は利用者のプロジェクトルートで、スキルのフォルダではありません。そのため同梱ファイルは cwd からの相対パスでは解決できません。`SKILL.md` では同梱ファイルを `${CLAUDE_SKILL_DIR}/...`（上記のスキル配置先ディレクトリ）として参照し、利用者自身のスケッチや素材はプロジェクト内の通常の相対パスのままにします。`${CLAUDE_SKILL_DIR}` は Claude Code 独自の記法で Codex では展開されないため、Codex でリポジトリを直接使う場合はリポジトリルートと読み替えてください。

## 推奨プロンプト

Claude Code:

```text
Use the m5stack-arduino-cli skill to set up my M5Core2 on macOS, attach the correct FQBN, and upload a sample sketch from Arduino CLI.
```

Codex:

```text
Use $m5stack-arduino-cli to set up my M5Core2 on Windows, attach the correct FQBN, and upload a sample sketch from Arduino CLI.
```

## 基本フロー

1. OS がシリアルデバイスとして認識しているか確認する（Windows は `COM*`、macOS は `/dev/cu.*`）
2. `arduino-cli` を探す（Homebrew や Arduino IDE 同梱版も含む）
3. ESP32 コアを導入する
4. 現在のポートを確認する
5. `Unknown` を自動識別の限界として扱うべきか判定する
6. `M5GFX` と `M5Unified` を必要に応じて導入する
7. スケッチに FQBN とポートを `board attach` する
8. コンパイルして書き込む

## 重要コマンド

Windows:

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

macOS:

```bash
command -v arduino-cli
ls /dev/cu.*
system_profiler SPUSBDataType
arduino-cli board list
arduino-cli core update-index
arduino-cli core install esp32:esp32
arduino-cli lib install M5GFX
arduino-cli lib install M5Unified
port=/dev/cu.wchusbserial53240012345   # arduino-cli board list で確認
arduino-cli board attach -p "$port" -b esp32:esp32:m5stack_core2 ./examples/m5core2/hello
arduino-cli compile ./examples/m5core2/hello
arduino-cli upload -p "$port" ./examples/m5core2/hello
```

## 同梱ヘルパー

Windows:

```powershell
.\scripts\setup-m5core2.ps1 -SketchPath .\examples\m5core2\hello -Port COM11
.\scripts\upload-m5core2.ps1 -SketchPath .\examples\m5core2\hello -Port COM11
```

macOS（`--port` を省略すると `/dev/cu.*` を自動検出）:

```bash
./scripts/setup-m5core2.sh --sketch ./examples/m5core2/hello
./scripts/upload-m5core2.sh --sketch ./examples/m5core2/hello
```

SD カード確認用:

```powershell
.\scripts\setup-m5core2.ps1 -SketchPath .\examples\m5core2\sd_text_write -Port COM11
.\scripts\upload-m5core2.ps1 -SketchPath .\examples\m5core2\sd_text_write -Port COM11
```

```bash
./scripts/setup-m5core2.sh --sketch ./examples/m5core2/sd_text_write
./scripts/upload-m5core2.sh --sketch ./examples/m5core2/sd_text_write
```

透過アニメーション WebP から取り込んだ猫アニメの例:

```powershell
.\scripts\setup-m5core2.ps1 -SketchPath .\examples\m5core2\pixel_pet -Port COM11
.\scripts\upload-m5core2.ps1 -SketchPath .\examples\m5core2\pixel_pet -Port COM11
```

```bash
./scripts/setup-m5core2.sh --sketch ./examples/m5core2/pixel_pet
./scripts/upload-m5core2.sh --sketch ./examples/m5core2/pixel_pet
```

## 既定値

- M5Core2 の FQBN: `esp32:esp32:m5stack_core2`
- よくある USB ブリッジ: `CH9102`（`/dev/cu.wchusbserial*`）、`CP210x`（`/dev/cu.SLAB_USBtoUART`）
- よく使うライブラリ: `M5Unified`, `M5GFX`
- 既定のサンプルスケッチ: `examples/m5core2/hello/hello.ino`
- SD カード確認用スケッチ: `examples/m5core2/sd_text_write/sd_text_write.ino`
- 猫アニメ用スケッチ: `examples/m5core2/pixel_pet/pixel_pet.ino`

## 次に読む場所

詳しい切り分けは [診断プレイブック](/ja/guide/diagnosis)、サンプルスケッチや補助スクリプトを使った継続開発は [開発支援](/ja/guide/development) を見てください。
