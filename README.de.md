# Xray Wallpaper

[English](README.md) · **Deutsch** · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh_CN.md)

Ein Plugin für [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell), das ein zweites Bild hinter deinem Wallpaper hält. Um den Zeiger herum hat das Wallpaper ein weiches Loch, und darin zeigt sich das Bild.

![Xray Wallpaper](assets/screenshot.png)

Schritt für Schritt mit Bildern: [Anleitung zu Einbau und Einstellung](docs/GUIDE.de.md).

## Was es macht

Dein DMS-Wallpaper bleibt, wo es ist. Das Plugin zeichnet das Bild, das du wählst, auf eine durchsichtige Fläche darüber: innerhalb des Lochs um den Zeiger und sonst nirgends. Alles, was es nicht zeichnet, bleibt frei, Wallpaper-Übergänge, Schreibtisch-Widgets und andere Hintergrund-Plugins arbeiten also weiter.

Auf dem Schreibtisch folgt das Loch dem Zeiger; nimmst du den Zeiger vom Schreibtisch weg, schließt sich das Loch.

Über einem Fenster gehört der Zeiger diesem Fenster, darum gibt es einen zweiten Weg hinein: den Peek-Modus. Er öffnet eine runde Ansicht des Bildes über allen Fenstern, folgt dem Zeiger überall und endet mit einem Klick, nach einigen Sekunden oder wenn du die gehaltene Taste loslässt.

Unter niri gibt es einen dritten Weg: „Hinter den Fenstern folgen“ liest die Zeigerposition aus dem IPC-Socket von niri, und das Loch läuft hinter den Fenstern weiter mit, zu sehen überall dort, wo sie durchscheinend sind. Von sich aus gibt niri die Zeigerposition nicht heraus, dafür braucht es ein niri mit einem Patch von mir (siehe unten). Mit einem normalen niri bleibt der Schalter ausgeblendet, und die beiden Wege oben arbeiten wie gewohnt.

„Deckkraft der oberen Schicht“ unter 100 % lässt das Bild über den ganzen Bildschirm durch; daraus wird eine Mischung aus zwei Bildern mit einer klaren Stelle um den Zeiger. Mit „Zweites Bild oben“ deckt das Bild stattdessen das Wallpaper ab und das Loch zeigt das Wallpaper. Die Größe des Lochs, die Weichheit seiner Kante, ein Lichtring nach Wunsch und wie schnell das Loch folgt lassen sich alle einstellen.

Das Bild wird abgebildet wie das DMS-Wallpaper, Strecken, Einpassen und Beschneiden sehen also aus wie bei deinem Wallpaper.

## Voraussetzungen

DankMaterialShell 1.6.1 oder neuer. Ich nutze es unter niri. Mit einem normalen niri funktioniert alles außer „Hinter den Fenstern folgen“; dafür braucht es ein gepatchtes niri, siehe den Abschnitt „Hinter den Fenstern folgen“ weiter unten.

Unter niri wandern Hintergrundflächen mit den Arbeitsflächen mit, solange sie nicht im Backdrop liegen. Trag das in deine niri-Konfiguration ein, sonst scrollt das Bild weg, wenn du die Arbeitsfläche wechselst:

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

## Installation

Aus der Plugin-Registry:

```sh
dms plugins install xrayWallpaper
dms ipc call plugins enable xrayWallpaper
```

Das Plugin steht auch in DMS unter Einstellungen → Plugins → Durchsuchen. Oder direkt aus dem Repository:

```sh
git clone https://github.com/satoshoe-dev/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
dms ipc call plugins enable xrayWallpaper
```

Wähle dann das zweite Bild unter Einstellungen → Plugins → Xray Wallpaper. Bis es gesetzt ist, ändert sich auf dem Bildschirm nichts.

## Einstellungen

Einstellungen → Plugins → Xray Wallpaper

| Einstellung | Standard |
|---|---|
| Zweites Bild | keins |
| Zweites Bild oben | aus |
| Größe des Lochs | 260 px |
| Weiche Kante | 90 px |
| Leuchtender Ring | 0 px (aus) |
| Ringfarbe | Akzent |
| Deckkraft der oberen Schicht | 100 % |
| Obere / untere Schicht abdunkeln | 0 % / 0 % |
| Nachlauf | 4000 px/s |
| Auf dem Schreibtisch folgen | ein |
| Hinter den Fenstern folgen | aus |
| Halten: Nachlaufzeit nach der Taste | 800 ms |
| Peek-Modus beenden nach | 20 s |

## IPC

```sh
dms ipc call xray peek toggle     # round view above the windows, also on|off
dms ipc call xray hold            # the same, but only while a key is held
dms ipc call xray at 1280 800     # put the hole at a fixed spot
dms ipc call xray close           # close it again
dms ipc call xray status
dms ipc call xray set radius 400  # any setting from the table above
```

Tastenbindungen unter niri, eine als Schalter und eine zum Halten:

```kdl
binds {
    Mod+Shift+X { spawn "dms" "ipc" "call" "xray" "peek" "toggle"; }
    Mod+Alt+X cooldown-ms=150 { spawn "dms" "ipc" "call" "xray" "hold"; }
}
```

Die Haltebindung arbeitet über die Tastenwiederholung: jede Wiederholung schiebt das Ende ein Stück weiter, und kurz nachdem du loslässt, schließt sich die Ansicht. Wenn es beim Halten flackert, stell „Halten: Nachlaufzeit nach der Taste“ höher.

## Hinter den Fenstern folgen

Wayland liefert Zeigerbewegungen nur an die Fläche unter dem Zeiger, kein Programm kann ihm also folgen, sobald ein Fenster dazwischen liegt. niri kennt die Position, gibt sie aber nicht heraus.

Der Zeigerstrom ist ein Patch von mir für niri und nicht Teil von niri. Er ergänzt das IPC um eine eigene `PointerStream`-Anfrage, die `PointerMoved`-Ereignisse schickt; Programme, die nicht danach fragen, bekommen sie nie zu sehen. Mit einem niri, das mit diesem Patch gebaut ist, funktioniert der Schalter. Ein normales niri beantwortet die Anfrage mit einem Fehler, das Plugin merkt sich das und bleibt beim Fühler auf dem Schreibtisch und beim Peek-Modus. Die Einstellungsseite blendet den Schalter dann aus, alles andere funktioniert wie oben beschrieben.

Der Patch für niri 26.04 liegt im Zweig [pointer-stream-v26.04](https://github.com/satoshoe-dev/niri/tree/pointer-stream-v26.04) meines niri-Forks. Gebaut wird er wie niri selbst, siehe dessen README.

## Übersetzungen

Die Einstellungsseite gibt es auf Deutsch, Spanisch, Französisch, Italienisch, Portugiesisch, Russisch, Japanisch und Chinesisch (vereinfacht) und sie folgt der in DMS eingestellten Sprache. Wenn eine Übersetzung falsch klingt, ist ein Pull Request willkommen.

## Hinweis

Dieses Plugin habe ich mit Hilfe von Claude (Anthropic) geschrieben und jede Änderung auf meinem eigenen niri-Schreibtisch getestet.

## Lizenz

MIT
