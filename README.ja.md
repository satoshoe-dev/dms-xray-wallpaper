# Xray Wallpaper

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · [Português](README.pt.md) · [Русский](README.ru.md) · **日本語** · [简体中文](README.zh_CN.md)

壁紙の裏にもう 1 枚の画像を置いておく [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) 用のプラグインです。ポインターのまわりで壁紙に柔らかい穴が開き、そこからその画像が見えます。

![Xray Wallpaper](assets/screenshot.png)

画像つきの手順: [インストールと設定の手引き](docs/GUIDE.md)。

## できること

DMS の壁紙はそのままです。プラグインは選んだ画像を、その上に重ねた透明なサーフェスへ描きます。描くのはポインターのまわりの穴の中だけで、ほかには何も描きません。描かれないところは透けたままなので、壁紙の切り替えやデスクトップウィジェット、ほかの背景プラグインはそのまま動きます。

デスクトップでは穴がポインターを追い、ポインターをデスクトップから外すと穴は閉じます。

ウィンドウの上ではポインターはそのウィンドウのものなので、もう一つの入り口があります。peek モードです。画像の丸い窓をすべてのウィンドウの上に開き、どこでもポインターを追い、クリックか数秒で、あるいは押していたキーを放すと終わります。

「上のレイヤーの不透明度」を下げると、画像は穴の中だけでなく全体に透けます。こうすると、ポインターのまわりだけがはっきりした 2 枚の画像の重なりになります。「2 枚目の画像を上に」では逆に画像が壁紙を覆い、穴から壁紙が見えます。穴の大きさ、ふちのぼかし具合、任意の光の輪、追従の速さはどれも設定できます。

画像は DMS の壁紙と同じようにマッピングされるので、stretch、fit、crop の見え方は壁紙と変わりません。

## 必要なもの

DankMaterialShell 1.6.1 以降。

niri では、背景のサーフェスは backdrop に置かないとワークスペースと一緒に動きます。次を niri の設定に足してください。足さないと、ワークスペースを切り替えたときに画像が流れていきます。

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

## インストール

```sh
git clone https://github.com/21Rebel/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
dms ipc call plugins enable xrayWallpaper
```

そのあと 設定 → プラグイン → Xray Wallpaper で 2 枚目の画像を選びます。選ぶまで画面は何も変わりません。

## 設定

設定 → プラグイン → Xray Wallpaper

| 設定 | 初期値 |
|---|---|
| 2 枚目の画像 | なし |
| 2 枚目の画像を上に | オフ |
| 穴の大きさ | 260 px |
| ふちのぼかし | 90 px |
| 光るリング | 0 px (オフ) |
| リングの色 | アクセント |
| 上のレイヤーの不透明度 | 100 % |
| 上 / 下のレイヤーを暗くする | 0 % / 0 % |
| 追従の速さ | 4000 px/s |
| デスクトップで追従する | オン |
| 押している間: キーのあとの余韻 | 800 ms |
| peek モードを終える時間 | 20 s |

## IPC

```sh
dms ipc call xray peek toggle     # round view above the windows, also on|off
dms ipc call xray hold            # the same, but only while a key is held
dms ipc call xray at 1280 800     # put the hole at a fixed spot
dms ipc call xray close           # close it again
dms ipc call xray status
dms ipc call xray set radius 400  # any setting from the table above
```

niri のキー割り当て。切り替え用と、押している間だけ用の 2 つです。

```kdl
binds {
    Mod+Shift+X { spawn "dms" "ipc" "call" "xray" "peek" "toggle"; }
    Mod+Alt+X cooldown-ms=150 { spawn "dms" "ipc" "call" "xray" "hold"; }
}
```

押している間のほうはキーリピートに乗っています。リピートのたびに終わりが少しずつ先へ延び、キーを放すとすぐに窓は閉じます。押している間にちらつくときは「押している間: キーのあとの余韻」を大きくしてください。

## 翻訳

設定ページはドイツ語、スペイン語、フランス語、イタリア語、ポルトガル語、ロシア語、日本語、簡体中国語で使えて、DMS で設定した言語に従います。訳がおかしいときは pull request を歓迎します。

## 補足

このプラグインは Claude (Anthropic) の助けを借りて書き、変更はすべて自分の niri デスクトップで試しました。

## ライセンス

MIT
