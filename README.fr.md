# Xray Wallpaper

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · **Français** · [Italiano](README.it.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh_CN.md)

Un plugin pour [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) qui garde une deuxième image derrière ton fond d'écran. Autour du pointeur, le fond d'écran a un trou adouci, et l'image s'y montre.

![Xray Wallpaper](assets/screenshot.png)

Pas à pas avec des images : [guide d'installation et de réglage](docs/GUIDE.md).

## Ce que ça fait

Ton fond d'écran DMS reste où il est. Le plugin dessine l'image que tu choisis sur une surface transparente au-dessus : à l'intérieur du trou autour du pointeur, et nulle part ailleurs. Tout ce qu'il ne dessine pas reste libre, donc les transitions de fond d'écran, les widgets du bureau et les autres plugins d'arrière-plan continuent de marcher.

Sur le bureau, le trou suit le pointeur ; éloigne le pointeur du bureau et le trou se referme.

Au-dessus d'une fenêtre, le pointeur appartient à cette fenêtre, il y a donc une deuxième entrée : le mode peek. Il ouvre une vue ronde de l'image par-dessus toutes les fenêtres, suit le pointeur partout et se termine sur un clic, après quelques secondes, ou quand tu relâches la touche que tu tiens.

Sous niri il y a une troisième entrée, si ton niri donne la position du pointeur par son socket IPC : « Suivre derrière les fenêtres » y prend alors la position et le trou continue de courir derrière les fenêtres, visible partout où elles sont translucides. Là où ça manque, le réglage ne fait rien et les deux entrées ci-dessus restent.

« Opacité de la couche du dessus » laisse passer l'image partout, pas seulement dans le trou, ce qui donne un mélange de deux images avec un endroit net autour du pointeur. Avec « Deuxième image au-dessus », c'est l'image qui recouvre le fond d'écran et le trou montre le fond d'écran. La taille du trou, la douceur de son bord, un anneau de lumière si tu en veux un et la vitesse de suivi du trou se règlent tous.

L'image est placée comme le fond d'écran DMS, l'étirement, l'ajustement et le recadrage ont donc la même allure que pour ton fond d'écran.

## Prérequis

DankMaterialShell 1.6.1 ou plus récent.

Sous niri, les surfaces d'arrière-plan se déplacent avec les espaces de travail tant qu'elles ne sont pas dans le backdrop. Ajoute ceci à ta configuration niri, sinon l'image défile avec toi quand tu changes d'espace de travail :

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

## Installation

```sh
git clone https://github.com/21Rebel/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
dms ipc call plugins enable xrayWallpaper
```

Choisis ensuite la deuxième image dans Paramètres → Plugins → Xray Wallpaper. Tant qu'elle n'est pas définie, rien ne change à l'écran.

## Paramètres

Paramètres → Plugins → Xray Wallpaper

| Paramètre | Par défaut |
|---|---|
| Deuxième image | aucune |
| Deuxième image au-dessus | désactivé |
| Taille du trou | 260 px |
| Bord adouci | 90 px |
| Anneau lumineux | 0 px (désactivé) |
| Couleur de l'anneau | Accent |
| Opacité de la couche du dessus | 100 % |
| Assombrir la couche du dessus / du dessous | 0 % / 0 % |
| Vitesse de suivi | 4000 px/s |
| Suivre sur le bureau | activé |
| Suivre derrière les fenêtres | désactivé |
| Maintien : délai après la touche | 800 ms |
| Terminer le mode peek après | 20 s |

## IPC

```sh
dms ipc call xray peek toggle     # round view above the windows, also on|off
dms ipc call xray hold            # the same, but only while a key is held
dms ipc call xray at 1280 800     # put the hole at a fixed spot
dms ipc call xray close           # close it again
dms ipc call xray status
dms ipc call xray set radius 400  # any setting from the table above
```

Des raccourcis clavier sous niri, un comme interrupteur et un à maintenir :

```kdl
binds {
    Mod+Shift+X { spawn "dms" "ipc" "call" "xray" "peek" "toggle"; }
    Mod+Alt+X cooldown-ms=150 { spawn "dms" "ipc" "call" "xray" "hold"; }
}
```

Le raccourci à maintenir passe par la répétition de touche : chaque répétition repousse un peu la fin, et peu après que tu relâches, la vue se referme. Si ça scintille pendant que tu tiens la touche, augmente « Maintien : délai après la touche ».

## Suivre derrière les fenêtres

Wayland ne livre les mouvements du pointeur qu'à la surface sous le pointeur, aucun client ne peut donc le suivre dès qu'une fenêtre est dans le chemin. niri connaît la position mais ne la publie pas.

Le patch qui la publie est petit et tient dans l'IPC seul : une requête `PointerStream` à part qui envoie des événements `PointerMoved`, si bien que les clients qui ne la demandent pas ne les voient jamais. Il est parti chez niri en pull request ; s'il est accepté, « Suivre derrière les fenêtres » se met à marcher tout seul. D'ici là, l'interrupteur est là pour ceux qui font tourner niri avec.

## Traductions

La page de paramètres existe en allemand, espagnol, français, italien, portugais, russe, japonais et chinois simplifié, et elle suit la langue réglée dans DMS. Si une traduction sonne faux, une pull request est bienvenue.

## Remarque

J'ai écrit ce plugin avec l'aide de Claude (Anthropic) et j'ai testé chaque changement sur mon propre bureau niri.

## Licence

MIT
