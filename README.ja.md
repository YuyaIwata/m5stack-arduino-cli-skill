<div align="center">
  <img src="./assets/m5stack-arduino-cli-icon.svg" alt="M5Stack Arduino CLI icon" width="140" height="140">
  <h1>M5Stack Arduino CLI Skill</h1>
  <p><strong>Windows / macOS 上で M5Stack を Arduino CLI だけでセットアップ、書き込み、診断、開発支援するための Claude / Codex 向けスキルです。</strong></p>
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

## ドキュメント

- ドキュメントサイト: [Sunwood-ai-labs.github.io/m5stack-arduino-cli-skill](https://sunwood-ai-labs.github.io/m5stack-arduino-cli-skill/)
- 英語クイックスタート: [`docs/guide/quickstart.md`](./docs/guide/quickstart.md)
- 日本語クイックスタート: [`docs/ja/guide/quickstart.md`](./docs/ja/guide/quickstart.md)

## 概要

このリポジトリは、Windows / macOS 上で `arduino-cli` を使って M5Stack を扱うための再利用可能なスキルで、Claude と Codex の両方から使えます。特に次のような場面を狙っています。

- `arduino-cli board list` で `Unknown` と出る
- USB シリアルブリッジが `CH9102` や `CP210x` として見えている
- 正しい ESP32 の FQBN がまだスケッチに紐づいていない
- セットアップから書き込み、開発の初期化まで一気に進めたい

このスキルは単発のトラブルシュートだけでなく、日常的な開発支援も前提にしています。シリアルポート（Windows は `COM*`、macOS は `/dev/cu.*`）の切り分け、ESP32 コア導入、M5 系ライブラリの導入、`board attach`、コンパイル、アップロードまでを CLI ベースで再現可能な流れにまとめています。

## Claude Code スキルとしての配置

Claude Code は `.claude/skills/` 配下のスキルを認識します。このリポジトリをディレクトリ名 `m5stack-arduino-cli` で配置してください。

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

配置後は次のようになります:

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

### パスの解決について

Claude Code の作業ディレクトリ（cwd）は**利用者のプロジェクトルート**であり、スキルのフォルダではありません。そのため同梱ファイルは cwd からの相対パスでは解決できません。`SKILL.md` では同梱ファイルを `${CLAUDE_SKILL_DIR}/...`（例: `${CLAUDE_SKILL_DIR}/scripts/setup-m5core2.sh`）として参照します。`${CLAUDE_SKILL_DIR}` は上記のスキル配置先ディレクトリを指します。利用者自身のファイル（スケッチやアニメーション素材など）は、これまでどおりプロジェクト内の通常の相対パスのままにします。

**このリポジトリを Codex で直接使う場合:** `${CLAUDE_SKILL_DIR}` は Claude Code 独自の記法で、Codex では展開されません。リポジトリ自体を開いて（または clone して）使う場合は、`${CLAUDE_SKILL_DIR}` をリポジトリルートと読み替えてください。

## このスキルでできること

- `Unknown` の意味を正しく切り分ける
- OS 側でシリアルポートとドライバ状態を確認する（Windows / macOS 両対応）
- `arduino-cli`、Homebrew 版、Arduino IDE 同梱版 CLI に対応する
- `esp32:esp32:m5stack_core2` などの FQBN を明示的に付与する
- `M5Unified` と `M5GFX` を導入する
- サンプルスケッチを使って最初の書き込み確認を行う
- CLI だけで M5Stack 開発フローを回せる形に整える

## サンプルスクリプトとサンプルスケッチ

セットアップと書き込みには、同梱のスクリプトを使えます。

Windows（PowerShell）:

```powershell
.\scripts\setup-m5core2.ps1 -SketchPath .\examples\m5core2\hello -Port COM11
.\scripts\upload-m5core2.ps1 -SketchPath .\examples\m5core2\hello -Port COM11
```

macOS（bash）— `--port` を省略すると `/dev/cu.*` を自動検出します:

```bash
./scripts/setup-m5core2.sh --sketch ./examples/m5core2/hello
./scripts/upload-m5core2.sh --sketch ./examples/m5core2/hello
```

最小の確認用スケッチはここにあります。

```text
examples/m5core2/hello/hello.ino
```

SD カード確認用サンプル:

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

- microSD のマウント
- テキストファイルの作成と追記
- 画面とシリアルでの読み戻し
- 空き容量と総容量の表示

このスケッチは `M5Unified` を使って画面表示とシリアル出力を行い、ボタン A を押したときの状態変化も確認できます。

透過アニメーション WebP を使った猫アニメの例:

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

- 透過アニメーション WebP を M5Core2 用の RGB565 フレーム列へ変換
- 元の縦横比を保ったまま正方形キャンバスに収める
- 最後のフレームから最初のフレームへ戻る部分に補間フレームを足してループをなじませる
- プレビュー画像とスプライトシートを同時に生成して確認できる
- 元アニメーションをそのまま再生し、ボタン A / B / C で反応だけを切り替える

サンプリングしたフレームから生成したプレビュー:

![猫アニメのプレビュー](./docs/public/examples/pixel_pet/generated_cat_animation_preview.png)

サンプリングしたアニメーション全体のスプライトシート:

![猫アニメのスプライトシート](./docs/public/examples/pixel_pet/generated_cat_animation_sheet.png)

変換アセットを `uv` で再生成する例:

```powershell
uv run .\scripts\generate_sprite_animation.py --input 'D:\path\to\cat.webp' --output .\examples\m5core2\pixel_pet\generated_cat_animation.h --preview .\docs\public\examples\pixel_pet\generated_cat_animation_preview.png --sheet .\docs\public\examples\pixel_pet\generated_cat_animation_sheet.png --size 112 --frame-step 4 --sheet-columns 8 --loop-blend-frames 3
```

```bash
uv run ./scripts/generate_sprite_animation.py --input ~/path/to/cat.webp --output ./examples/m5core2/pixel_pet/generated_cat_animation.h --preview ./docs/public/examples/pixel_pet/generated_cat_animation_preview.png --sheet ./docs/public/examples/pixel_pet/generated_cat_animation_sheet.png --size 112 --frame-step 4 --sheet-columns 8 --loop-blend-frames 3
```

## クイックスタート

エージェントに明示的にスキルを使わせるなら、たとえばこう依頼できます。

Claude Code:

```text
Use the m5stack-arduino-cli skill to set up my M5Core2 on macOS, attach the correct FQBN, and upload a sample sketch from Arduino CLI.
```

Codex:

```text
Use $m5stack-arduino-cli to set up my M5Core2 on Windows, attach the correct FQBN, and upload a sample sketch from Arduino CLI.
```

スキルは次の順で進めます。

1. OS がシリアルデバイスとして認識しているか確認する（`COM*` / `/dev/cu.*`）
2. `arduino-cli` を見つける（Homebrew や Arduino IDE 同梱版も含む）
3. ESP32 コアを導入する
4. 正しいポートを見つける
5. `Unknown` を自動識別の限界として扱うべきか判定する
6. `M5GFX` と `M5Unified` を必要に応じて導入する
7. スケッチに FQBN とポートを `board attach` する
8. コンパイルとアップロードを行う

## 主なファイル

| パス | 役割 |
| --- | --- |
| [`SKILL.md`](./SKILL.md) | スキル本体。発火条件、実行ルール、参照先（Claude Code はこれを直接読み込みます） |
| [`agents/openai.yaml`](./agents/openai.yaml) | Codex 向けメタデータ |
| [`agents/claude.yaml`](./agents/claude.yaml) | Claude 向けインターフェースメタデータ（`openai.yaml` と対） |
| [`scripts/setup-m5core2.ps1`](./scripts/setup-m5core2.ps1) | Windows: セットアップ、ライブラリ導入、`board attach` を補助 |
| [`scripts/upload-m5core2.ps1`](./scripts/upload-m5core2.ps1) | Windows: コンパイルとアップロードを補助 |
| [`scripts/setup-m5core2.sh`](./scripts/setup-m5core2.sh) | macOS/Linux: セットアップ、ライブラリ導入、`board attach` を補助 |
| [`scripts/upload-m5core2.sh`](./scripts/upload-m5core2.sh) | macOS/Linux: コンパイルとアップロードを補助 |
| [`scripts/generate_sprite_animation.py`](./scripts/generate_sprite_animation.py) | 透過アニメーション WebP を RGB565 フレーム列と確認用画像へ変換 |
| [`examples/m5core2/hello/hello.ino`](./examples/m5core2/hello/hello.ino) | M5Core2 向けサンプルスケッチ |
| [`examples/m5core2/sd_text_write/sd_text_write.ino`](./examples/m5core2/sd_text_write/sd_text_write.ino) | SD カード書き込み確認用サンプルスケッチ |
| [`examples/m5core2/pixel_pet/pixel_pet.ino`](./examples/m5core2/pixel_pet/pixel_pet.ino) | 透過 WebP ベースの猫アニメ用サンプルスケッチ |
| [`docs/`](./docs/) | 英日対応の VitePress ドキュメント |
| [`references/windows-setup-and-diagnosis.md`](./references/windows-setup-and-diagnosis.md) | Windows / Arduino CLI のセットアップと切り分け |
| [`references/macos-setup-and-diagnosis.md`](./references/macos-setup-and-diagnosis.md) | macOS のセットアップ、`/dev/cu.*` の扱い、`esptool` 確認、ドライバ方針 |
| [`references/m5-board-notes.md`](./references/m5-board-notes.md) | M5 固有のボードメモ |
| [`references/development-and-examples.md`](./references/development-and-examples.md) | 開発支援とサンプル利用の流れ |

## 今後の拡張方針

今後サンプルを増やしやすいように、構成を次のルールへ寄せました。

- ボード別サンプルは `examples/<board>/<sample>/`
- 共通処理（PowerShell / bash）は `scripts/common/`
- ボード別セットアップは `scripts/setup/`
- 汎用アップロードは `scripts/upload/`
- ユーザーが直接使う短い入口はトップレベルのラッパー（`.ps1` と `.sh` を併置）

## こんなときに使う

- Windows / macOS で M5Stack を CLI 中心で扱いたい
- `arduino-cli board list` の `Unknown` を正しく説明したい
- M5Core2 用の CLI セットアップを自動化したい
- 書き込み確認用のサンプルスケッチが欲しい
- 開発のたびに同じコマンドを組み直したくない

## ライセンス

このリポジトリは [MIT License](./LICENSE) で公開しています。
