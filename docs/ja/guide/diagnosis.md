# 診断プレイブック

## まず押さえる解釈

`arduino-cli board list` は次の 2 つを別々に行います。

1. ポートを見つける
2. ボード型番を推定する

M5Stack は OS から見ると汎用の USB シリアルブリッジとして見えることが多く、その場合はポート検出が正常でもボード名は `Unknown` のままになります。

## 切り分けの流れ

### 1. OS は正常なポートとして見ているか

Windows:

```powershell
Get-PnpDevice -PresentOnly | Where-Object { $_.Class -in @('Ports','USB') } |
  Select-Object Class,FriendlyName,Status,InstanceId
```

対象デバイスが存在し、`Status` が `OK` なら、USB 輸送層は概ね正常です。

macOS:

```bash
ls /dev/cu.*
system_profiler SPUSBDataType
```

`/dev/cu.wchusbserial*` や `/dev/cu.SLAB_USBtoUART` が現れれば USB 輸送層は概ね正常です。何も現れないときは、まずデータ通信対応の USB-C ケーブルと直挿しを試してからドライバを疑います。

### 2. `arduino-cli` はポートを見つけられるか

```powershell
arduino-cli board list
arduino-cli board list --format json
```

ポート（Windows は `COM*`、macOS は `/dev/cu.*`）は見えているのにボード名だけ出ない場合は、まず自動識別の不足として扱います。

### 3. ESP32 コアは入っているか

```powershell
arduino-cli core update-index
arduino-cli core install esp32:esp32
```

ESP32 コアがないと、`attach`、コンパイル、アップロードは揃いません。

### 4. `esptool` で ESP32 と会話できるか

Windows:

```powershell
& "C:\Users\<User>\AppData\Local\Arduino15\packages\esp32\tools\esptool_py\5.1.0\esptool.exe" --chip auto --port COM11 chip-id
```

macOS:

```bash
esptool_dir=$(ls -d ~/Library/Arduino15/packages/esp32/tools/esptool_py/* 2>/dev/null | tail -n 1)
"$esptool_dir/esptool" --chip auto --port /dev/cu.wchusbserial* chip-id
```

ここで ESP32 として応答すれば、`Unknown` でも実機との通信は取れています。

### 5. 想定ボードを明示的に `attach` する

```powershell
arduino-cli board attach -p COM11 -b esp32:esp32:m5stack_core2 D:\Prj\M5\VerifyCore2
```

```bash
arduino-cli board attach -p /dev/cu.wchusbserial53240012345 -b esp32:esp32:m5stack_core2 ./examples/m5core2/hello
```

これで汎用 USB シリアルブリッジと、実際に使いたいボード設定の間を橋渡しできます。

## 最初にやらないこと

- OS が正常にポートを出しているのに、いきなりドライバ再インストールを勧めない
- macOS 11 以降では CH34x/CP210x のサードパーティ kext を既定で入れない（標準ドライバで両ブリッジに対応済み）
- `Unknown` だけを根拠にケーブル不良やドライバ不足と断定しない
- ボードが分かっているのに `attach` を飛ばさない

## 開発フェーズへ進む

診断が安定したら、[開発支援](/ja/guide/development) に進み、サンプルスケッチと補助スクリプトを使って再現可能な CLI フローへ移ります。
