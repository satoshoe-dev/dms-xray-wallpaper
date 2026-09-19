# Xray Wallpaper: step by step

**English** · [Deutsch](GUIDE.de.md) · [Español](GUIDE.es.md) · [Français](GUIDE.fr.md) · [Italiano](GUIDE.it.md) · [Português](GUIDE.pt.md) · [Русский](GUIDE.ru.md) · [日本語](GUIDE.ja.md) · [简体中文](GUIDE.zh_CN.md)

## 1. Install the plugin

From the plugin registry:

```sh
dms plugins install xrayWallpaper
```

Or clone the repository into your DMS plugin folder:

```sh
git clone https://github.com/satoshoe-dev/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
```

## 2. Enable it

Open Settings → Plugins. Xray Wallpaper shows up in the list. Switch it on.

![Plugin list with Xray Wallpaper](images/01-plugin-list.png)

If it does not appear, click "Scan" on that page or restart the shell with `dms restart`.

## 3. On niri: keep the layers in the backdrop

Background surfaces move with the workspaces on niri. Add this to `~/.config/niri/config.kdl` so the picture stays put:

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

niri picks the change up as soon as you save the file.

## 4. Pick the second picture

Expand Xray Wallpaper in the plugin list and click "Choose image". The file browser opens in your picture folder.

![The settings page with the file browser](images/02-choose-image.png)

Your wallpaper stays where it is; the picture you choose shows through the hole. Until you choose one, nothing changes on screen.

## 5. Move the pointer over the desktop

Move the pointer to a free spot on the desktop. The hole opens where the pointer is and follows it.

![The hole on the desktop](images/03-hole.png)

Move the pointer onto a window and the hole closes again.

## 6. Set the size and the edge

"Hole size" is the radius in pixels, "Soft edge" how wide the two layers blend into each other. A wide soft edge looks like a lamp shining through, a narrow one like a cut-out.

![Hole size and soft edge](images/04-size.png)

"Follow speed" decides how closely the hole sticks to the pointer. At 4000 px/s it keeps up, at 800 px/s it glides after it.

## 7. Add a ring of light (optional)

"Glowing ring" draws light along the edge of the hole, in your accent color or in the text color.

![The hole with a ring](images/05-ring.png)

## 8. Let the picture through everywhere (optional)

"Upper layer opacity" decides how much of the wallpaper stays. At 100 % the picture shows in the hole alone. Lower it and the picture comes through the whole screen, with the hole as the one spot where it is fully there.

![Upper layer opacity at 60 percent](images/07-opacity.png)

Both layers can also be darkened on their own. Darkening the upper one makes the hole stand out; darkening the lower one keeps the picture calm behind your icons.

## 9. Look through the windows

Over a window the pointer belongs to that window, so the desktop sensor does not see it. The peek mode puts a round view of the lower picture above all windows instead:

```sh
dms ipc call xray peek toggle
```

![The round view above the windows](images/06-peek.png)

A click ends it, and so does the timer under "End peek mode after". Put it on a key, in niri:

```kdl
binds {
    Mod+Shift+X hotkey-overlay-title="Xray: look through the wallpaper" { spawn "dms" "ipc" "call" "xray" "peek" "toggle"; }
}
```

If you would rather look only while you hold a key, use the second command:

```kdl
binds {
    Mod+Alt+X cooldown-ms=150 hotkey-overlay-title="Xray: look while held" { spawn "dms" "ipc" "call" "xray" "hold"; }
}
```

This one rides on the key repeat: every repeat pushes the end a little further, and shortly after you let go the view closes. If it flickers while you hold the key, raise "Hold mode: stay on after the key" in the settings.

## 10. Follow behind the windows (patched niri only)

Wayland hands pointer motion only to the surface under the pointer, which is why steps 5 and 9 exist at all. niri knows the position but does not hand it out. A patch of mine, which is not part of niri, adds a pointer stream to niri's IPC socket, and the plugin can take the position from there. With a normal niri, skip this step; everything else in this guide works without the patch. To check which niri you run:

```sh
niri msg pointer-stream      # prints positions while you move the mouse
```

If that prints positions, switch on "Follow behind the windows". The hole then runs everywhere, also behind windows, and shows up wherever a window is see-through. If niri does not know the command, your niri has no pointer stream and the switch stays without effect.

![The hole behind a see-through window](images/08-behind.png)

## 11. Swap the layers

With "Second image on top" your picture becomes the upper layer and the hole shows the DMS wallpaper. Useful if the second picture is the one you want to see most of the time, for example a dark version of your wallpaper with the bright original underneath.

## 12. Script it

```sh
dms ipc call xray at 1280 800     # hole at a fixed spot
dms ipc call xray close           # close it again
dms ipc call xray set radius 400  # change any setting
dms ipc call xray status
```

## Troubleshooting

### The layers scroll away when I switch workspaces

The niri layer rule from step 3 is missing.

### The hole does not follow on the desktop

"Follow on the desktop" is off, or a window covers the spot. The sensor only sees the pointer where the desktop is free.

### Nothing changes at all

No second picture is set yet, or the file is gone; the settings page shows the path it uses.

### A desktop widget stops reacting

The sensor sits below the widgets, so this should not happen. If it does, switch "Follow on the desktop" off and use the peek mode instead.

### "Follow behind the windows" changes nothing

The running niri is built without the pointer stream patch. `dms ipc call xray status` says `"stream":"refused"` in that case, and the plugin keeps to the sensor and the peek mode.

### The hold key flickers

The key repeat is slower than the time under "Hold mode: stay on after the key". Raise it, or lower the repeat delay of your keyboard.
