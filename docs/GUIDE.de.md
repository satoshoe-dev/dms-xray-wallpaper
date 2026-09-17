# Xray Wallpaper: Schritt für Schritt

[English](GUIDE.md) · **Deutsch** · [Español](GUIDE.es.md) · [Français](GUIDE.fr.md) · [Italiano](GUIDE.it.md) · [Português](GUIDE.pt.md) · [Русский](GUIDE.ru.md) · [日本語](GUIDE.ja.md) · [简体中文](GUIDE.zh_CN.md)

## 1. Plugin einbauen

Klone das Repository in deinen DMS-Plugin-Ordner:

```sh
git clone https://github.com/21Rebel/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
```

## 2. Einschalten

Öffne Einstellungen → Plugins. Xray Wallpaper steht in der Liste. Schalte es ein.

![Plugin-Liste mit Xray Wallpaper](images/01-plugin-list.png)

Wenn es nicht auftaucht, klick auf dieser Seite auf „Scan“ oder starte die Shell mit `dms restart` neu.

## 3. Unter niri: die Schichten im Backdrop halten

Hintergrundflächen wandern unter niri mit den Arbeitsflächen mit. Trag das in `~/.config/niri/config.kdl` ein, damit das Bild liegen bleibt:

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

niri übernimmt die Änderung, sobald du die Datei speicherst.

## 4. Das zweite Bild wählen

Klapp Xray Wallpaper in der Plugin-Liste auf und klick auf „Bild wählen“. Der Dateibrowser öffnet sich in deinem Bilderordner.

![Die Einstellungsseite mit dem Dateibrowser](images/02-choose-image.png)

Dein Wallpaper bleibt, wo es ist; das Bild, das du wählst, zeigt sich im Loch. Bis du eines wählst, ändert sich auf dem Bildschirm nichts.

## 5. Den Zeiger über den Schreibtisch bewegen

Bewege den Zeiger auf eine freie Stelle des Schreibtischs. Das Loch öffnet sich dort, wo der Zeiger ist, und folgt ihm.

![Das Loch auf dem Schreibtisch](images/03-hole.png)

Bewege den Zeiger auf ein Fenster, und das Loch schließt sich wieder.

## 6. Größe und Kante einstellen

„Größe des Lochs“ ist der Radius in Pixel, „Weiche Kante“ die Breite, über die die beiden Schichten ineinander übergehen. Eine breite weiche Kante sieht aus wie eine Lampe, die durchscheint, eine schmale wie ein Ausschnitt.

![Größe des Lochs und weiche Kante](images/04-size.png)

„Nachlauf“ bestimmt, wie eng das Loch am Zeiger klebt. Bei 4000 px/s kommt es mit, bei 800 px/s gleitet es hinterher.

## 7. Einen Lichtring hinzufügen (nach Wunsch)

„Leuchtender Ring“ zeichnet Licht an der Kante des Lochs, in deiner Akzentfarbe oder in der Schriftfarbe.

![Das Loch mit Ring](images/05-ring.png)

## 8. Das Bild überall durchlassen (nach Wunsch)

„Deckkraft der oberen Schicht“ bestimmt, wie viel vom Wallpaper bleibt. Bei 100 % zeigt sich das Bild nur im Loch. Stell den Wert kleiner, und das Bild kommt über den ganzen Bildschirm durch, mit dem Loch als der einen Stelle, an der es ganz da ist.

![Deckkraft der oberen Schicht bei 60 Prozent](images/07-opacity.png)

Beide Schichten lassen sich außerdem getrennt abdunkeln. Dunkelst du die obere ab, tritt das Loch hervor; dunkelst du die untere ab, bleibt das Bild ruhig hinter deinen Symbolen.

## 9. Durch die Fenster schauen

Über einem Fenster gehört der Zeiger diesem Fenster, der Fühler auf dem Schreibtisch sieht ihn also nicht. Der Peek-Modus legt stattdessen eine runde Ansicht des unteren Bildes über alle Fenster:

```sh
dms ipc call xray peek toggle
```

![Die runde Ansicht über den Fenstern](images/06-peek.png)

Ein Klick beendet sie, und ebenso der Zeitgeber unter „Peek-Modus beenden nach“. Leg ihn auf eine Taste, unter niri:

```kdl
binds {
    Mod+Shift+X hotkey-overlay-title="Xray: look through the wallpaper" { spawn "dms" "ipc" "call" "xray" "peek" "toggle"; }
}
```

Wenn du lieber nur schaust, solange du eine Taste hältst, nimm den zweiten Befehl:

```kdl
binds {
    Mod+Alt+X cooldown-ms=150 hotkey-overlay-title="Xray: look while held" { spawn "dms" "ipc" "call" "xray" "hold"; }
}
```

Der arbeitet über die Tastenwiederholung: jede Wiederholung schiebt das Ende ein Stück weiter, und kurz nachdem du loslässt, schließt sich die Ansicht. Wenn es beim Halten flackert, stell „Halten: Nachlaufzeit nach der Taste“ in den Einstellungen höher.

## 10. Die Schichten tauschen

Mit „Zweites Bild oben“ wird dein Bild die obere Schicht und das Loch zeigt das DMS-Wallpaper. Nützlich, wenn das zweite Bild das ist, das du die meiste Zeit sehen willst, zum Beispiel eine dunkle Fassung deines Wallpapers mit dem hellen Original darunter.

## 11. Per Skript steuern

```sh
dms ipc call xray at 1280 800     # hole at a fixed spot
dms ipc call xray close           # close it again
dms ipc call xray set radius 400  # change any setting
dms ipc call xray status
```

## Fehlersuche

**Die Schichten scrollen weg, wenn ich die Arbeitsfläche wechsle.** Die niri-Layer-Regel aus Schritt 3 fehlt.

**Das Loch folgt auf dem Schreibtisch nicht.** „Auf dem Schreibtisch folgen“ ist aus, oder ein Fenster deckt die Stelle ab. Der Fühler sieht den Zeiger nur dort, wo der Schreibtisch frei ist.

**Es ändert sich überhaupt nichts.** Es ist noch kein zweites Bild gesetzt, oder die Datei ist weg; die Einstellungsseite zeigt den Pfad, den sie benutzt.

**Ein Schreibtisch-Widget reagiert nicht mehr.** Der Fühler liegt unter den Widgets, das sollte also nicht passieren. Wenn doch, schalte „Auf dem Schreibtisch folgen“ aus und nimm stattdessen den Peek-Modus.

**Die Haltetaste flackert.** Die Tastenwiederholung ist langsamer als die Zeit unter „Halten: Nachlaufzeit nach der Taste“. Stell sie höher, oder verkürze die Verzögerung der Tastenwiederholung deiner Tastatur.
