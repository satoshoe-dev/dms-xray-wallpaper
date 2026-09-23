# Xray Wallpaper: 分步说明

[English](GUIDE.md) · [Deutsch](GUIDE.de.md) · [Español](GUIDE.es.md) · [Français](GUIDE.fr.md) · [Italiano](GUIDE.it.md) · [Português](GUIDE.pt.md) · [Русский](GUIDE.ru.md) · [日本語](GUIDE.ja.md) · **简体中文**

## 1. 安装插件

从插件注册表安装:

```sh
dms plugins install xrayWallpaper
```

或者把仓库克隆到 DMS 的插件目录:

```sh
git clone https://github.com/satoshoe-dev/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
```

## 2. 打开它

打开 设置 → 插件。列表里会有 Xray Wallpaper，把它打开。

![插件列表里的 Xray Wallpaper](images/01-plugin-list.png)

如果没出现，点这个页面上的“扫描”，或者用 `dms restart` 重启 shell。

## 3. 在 niri 上: 把两层放进 backdrop

在 niri 上，背景表面会跟着工作区移动。把下面这段加到 `~/.config/niri/config.kdl`，图片就不会动:

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

保存文件后 niri 立刻生效。

## 4. 选第二张图片

在插件列表里展开 Xray Wallpaper，点“选择图片”。文件选择器会在你的图片目录打开。

![打开了文件选择器的设置页面](images/02-choose-image.png)

你的壁纸原样不动，你选的图片从孔里透出来。在选好之前，屏幕上不会有变化。

## 5. 把指针移到桌面上

把指针移到桌面空着的地方。孔会在指针所在的位置打开，并跟着走。

![桌面上的孔](images/03-hole.png)

把指针移到窗口上，孔又会关上。

## 6. 调大小和边缘

“孔的大小”是半径，单位是像素；“柔和边缘”是两层互相融合的宽度。柔和边缘宽的时候像一盏灯透过来，窄的时候像剪出来的。

![孔的大小和柔和边缘](images/04-size.png)

“跟随速度”决定孔跟指针贴得有多紧。4000 px/s 跟得上，800 px/s 会慢慢滑过来。

## 7. 加一圈光 (可选)

“发光圆环”在孔的边缘画上光，用你的强调色或文字颜色。

![带圆环的孔](images/05-ring.png)

## 8. 让图片在整块屏幕上透出来 (可选)

“上层的不透明度”决定壁纸留下多少。100 % 的时候图片只在孔里露出。调低以后，图片会在整块屏幕上透出来，孔则是它唯一完整显示的地方。

“孔的强度”的作用正好相反。壁纸保持原样，孔只打开一部分：60 % 时，图片在指针周围透出 60 %。普通壁纸后面放一张电路板，指针移到哪里，电路板就在哪里隐约透出来。

![上层的不透明度调到 60 %](images/07-opacity.png)

两层也可以分别压暗。压暗上面那层，孔会更显眼；压暗下面那层，图标后面的图片会安静一些。

## 9. 看穿窗口

在窗口上方，指针属于那个窗口，桌面上的感应面看不到它。peek 模式改为在所有窗口之上开一个圆窗，显示下面那张图片:

```sh
dms ipc call xray peek toggle
```

![窗口之上的圆窗](images/06-peek.png)

点击会结束它，“peek 模式在多久后结束”里的计时也会。可以绑到一个按键上，在 niri 里:

```kdl
binds {
    Mod+Shift+X hotkey-overlay-title="Xray: look through the wallpaper" { spawn "dms" "ipc" "call" "xray" "peek" "toggle"; }
}
```

如果你更想只在按住按键的时候看，就用第二个命令:

```kdl
binds {
    Mod+Alt+X cooldown-ms=150 hotkey-overlay-title="Xray: look while held" { spawn "dms" "ipc" "call" "xray" "hold"; }
}
```

这个靠按键重复来维持: 每重复一次就把结束时间往后推一点，松开后不久圆窗就关上。如果按住时会闪，就把设置里的“按住模式: 松键后再留多久”调大。

## 10. 在窗口后面也跟随 (仅限打过补丁的 niri)

Wayland 只把指针的移动交给指针下面的那个表面，第 5 步和第 9 步就是因为这个才有的。niri 知道指针位置，但不往外发。我写的一个补丁 (不属于 niri 本身) 给 niri 的 IPC 套接字加上指针流，插件就能从那里取位置。用普通的 niri 就跳过这一步；本指南的其他部分不需要这个补丁。用下面的命令看看你的 niri 是哪一种:

```sh
niri msg pointer-stream      # prints positions while you move the mouse
```

如果它打印出坐标，就打开“在窗口后面也跟随”。这样孔到处都能走，窗口后面也能走，在窗口透明的地方就会露出来。如果 niri 不认识这个命令，说明你的 niri 没有指针流，开关也就不会出现。

![透明窗口后面的孔](images/08-behind.png)

## 11. 交换两层

打开“第二张图片在上”，你的图片就成了上层，孔里露出 DMS 壁纸。如果你平时更想看第二张图片，这样比较合适，比如上面放壁纸的暗色版本，下面放明亮的原图。

## 12. 用脚本控制

```sh
dms ipc call xray at 1280 800     # hole at a fixed spot
dms ipc call xray close           # close it again
dms ipc call xray set radius 400  # change any setting
dms ipc call xray status
```

## 排查

### 切换工作区时两层滑走了

缺了第 3 步里的 niri 图层规则。

### 孔在桌面上不跟随

“在桌面上跟随”是关的，或者那个位置被窗口盖住了。只有桌面空着的地方，感应面才看得到指针。

### 完全没有变化

还没设置第二张图片，或者文件不在了；设置页面上会显示它用的路径。

### 桌面小组件不响应了

感应面在小组件下方，所以不该发生这种事。如果真的发生了，把“在桌面上跟随”关掉，改用 peek 模式。

### 打开“在窗口后面也跟随”却没有变化

正在运行的 niri 编译时没有打指针流补丁。这时 `dms ipc call xray status` 会给出 `"stream":"refused"`，插件仍旧用感应面和 peek 模式。

### 按住的键会闪

按键重复比“按住模式: 松键后再留多久”的时间还慢。把这个值调大，或者把键盘的重复延迟调短。
