# Xray Wallpaper

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · **简体中文**

[DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) 的一个插件，在壁纸后面放上第二张图片。指针周围，壁纸上会开一个柔和的孔，图片从孔里透出来。

![Xray Wallpaper](assets/screenshot.png)

带图片的分步说明: [安装与设置指南](docs/GUIDE.zh_CN.md)。

## 它做什么

你的 DMS 壁纸原样不动。插件把你选的图片画在壁纸之上的一层透明表面里: 只画指针周围那个孔，别处一概不画。没画到的地方都是透的，所以壁纸切换、桌面小组件和别的背景插件都照常工作。

在桌面上，孔跟着指针走；把指针移开桌面，孔就关上。

在窗口上方，指针属于那个窗口，所以还有第二条路: peek 模式。它在所有窗口之上打开一个圆形视窗显示这张图片，在任何地方都跟着指针，点击一下、过几秒，或者松开按住的按键，就结束。

在 niri 上还有第三条路: “在窗口后面也跟随”从 niri 的 IPC 套接字读取指针位置，孔在窗口后面也继续走，在窗口透明的地方就能看到。niri 本身不交出指针位置，所以这需要打了我写的补丁的 niri (见下文)。用普通的 niri 时这个开关不会显示，上面两条路照常工作。

“上层的不透明度”低于 100 % 时，图片会在整块屏幕上透出来，这样整体就成了两张图片的叠合，只有指针周围那一块是干净的。用“第二张图片在上”则反过来，图片盖住壁纸，孔里露出壁纸。孔的大小、边缘的柔和程度、可选的一圈光，以及孔跟随的快慢，都可以设置。

图片的映射方式和 DMS 壁纸一样，所以拉伸、适应和裁切的效果和壁纸相同。

## 要求

DankMaterialShell 1.6.1 或更新版本。我自己在 niri 上用它。除了“在窗口后面也跟随”，其他功能在普通的 niri 上都能用；这个模式需要打过补丁的 niri，见下面的“在窗口后面跟随”一节。

在 niri 上，背景表面如果不放在 backdrop 里就会跟着工作区移动。把下面这段加到 niri 配置里，否则切换工作区时图片会跟着滑走:

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

## 安装

从插件注册表安装:

```sh
dms plugins install xrayWallpaper
dms ipc call plugins enable xrayWallpaper
```

也可以在 DMS 的 设置 → 插件 → 浏览 中找到它。若要从仓库安装:

```sh
git clone https://github.com/satoshoe-dev/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
dms ipc call plugins enable xrayWallpaper
```

然后在 设置 → 插件 → Xray Wallpaper 里选第二张图片。在选好之前，屏幕上不会有变化。

## 设置

设置 → 插件 → Xray Wallpaper

| 设置 | 默认值 |
|---|---|
| 第二张图片 | 无 |
| 第二张图片在上 | 关 |
| 孔的大小 | 260 px |
| 柔和边缘 | 90 px |
| 发光圆环 | 0 px (关) |
| 圆环颜色 | 强调色 |
| 上层的不透明度 | 100 % |
| 压暗上面 / 下面那一层 | 0 % / 0 % |
| 跟随速度 | 4000 px/s |
| 在桌面上跟随 | 开 |
| 在窗口后面也跟随 | 关 |
| 按住模式: 松键后再留多久 | 800 ms |
| peek 模式在多久后结束 | 20 s |

## IPC

```sh
dms ipc call xray peek toggle     # round view above the windows, also on|off
dms ipc call xray hold            # the same, but only while a key is held
dms ipc call xray at 1280 800     # put the hole at a fixed spot
dms ipc call xray close           # close it again
dms ipc call xray status
dms ipc call xray set radius 400  # any setting from the table above
```

在 niri 里绑两个按键，一个当开关，一个用来按住:

```kdl
binds {
    Mod+Shift+X { spawn "dms" "ipc" "call" "xray" "peek" "toggle"; }
    Mod+Alt+X cooldown-ms=150 { spawn "dms" "ipc" "call" "xray" "hold"; }
}
```

按住的那个靠按键重复来维持: 每重复一次就把结束时间往后推一点，松开后不久圆窗就关上。如果按住时会闪，就把“按住模式: 松键后再留多久”调大。

## 在窗口后面跟随

Wayland 只把指针的移动交给指针下面的那个表面，所以一旦有窗口挡着，任何客户端都跟不上它。niri 知道位置，但不往外发。

指针流是我给 niri 写的补丁，不属于 niri 本身。它在 IPC 里加一个单独的 `PointerStream` 请求，发送 `PointerMoved` 事件，没有请求的客户端一概收不到。用这个补丁编译的 niri 上，开关就能用。普通的 niri 会对这个请求返回错误，插件记下这一点，继续用桌面上的感应面和 peek 模式。这时设置页面不显示这个开关，其他功能照上面说的工作。

针对 niri 26.04 的补丁位于我的 niri 复刻仓库的 [pointer-stream-v26.04](https://github.com/satoshoe-dev/niri/tree/pointer-stream-v26.04) 分支。构建方式与 niri 本身相同，参见其 README。

## 翻译

设置页面有德语、西班牙语、法语、意大利语、葡萄牙语、俄语、日语和简体中文，跟随 DMS 里设置的语言。如果某处译得不对，欢迎提 pull request。

## 说明

这个插件是我在 Claude (Anthropic) 的帮助下写的，每一处改动都在我自己的 niri 桌面上测试过。

## 许可

MIT
