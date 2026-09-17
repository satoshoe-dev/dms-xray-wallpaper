# Xray Wallpaper : pas à pas

[English](GUIDE.md) · [Deutsch](GUIDE.de.md) · [Español](GUIDE.es.md) · **Français** · [Italiano](GUIDE.it.md) · [Português](GUIDE.pt.md) · [Русский](GUIDE.ru.md) · [日本語](GUIDE.ja.md) · [简体中文](GUIDE.zh_CN.md)

## 1. Installer le plugin

Clone le dépôt dans ton dossier de plugins DMS :

```sh
git clone https://github.com/21Rebel/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
```

## 2. L'activer

Ouvre Paramètres → Plugins. Xray Wallpaper apparaît dans la liste. Active-le.

![Liste des plugins avec Xray Wallpaper](images/01-plugin-list.png)

S'il n'apparaît pas, clique sur « Scan » sur cette page ou redémarre le shell avec `dms restart`.

## 3. Sous niri : garder les couches dans le backdrop

Sous niri, les surfaces d'arrière-plan se déplacent avec les espaces de travail. Ajoute ceci à `~/.config/niri/config.kdl` pour que l'image reste en place :

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

niri prend le changement en compte dès que tu enregistres le fichier.

## 4. Choisir la deuxième image

Déplie Xray Wallpaper dans la liste des plugins et clique sur « Choisir une image ». Le navigateur de fichiers s'ouvre dans ton dossier d'images.

![La page de paramètres avec le navigateur de fichiers](images/02-choose-image.png)

Ton fond d'écran reste où il est ; l'image que tu choisis se montre dans le trou. Tant que tu n'en as pas choisi une, rien ne change à l'écran.

## 5. Passer le pointeur sur le bureau

Amène le pointeur sur un endroit libre du bureau. Le trou s'ouvre là où est le pointeur et le suit.

![Le trou sur le bureau](images/03-hole.png)

Amène le pointeur sur une fenêtre et le trou se referme.

## 6. Régler la taille et le bord

« Taille du trou » est le rayon en pixels, « Bord adouci » la largeur sur laquelle les deux couches se mêlent. Un bord adouci large donne l'impression d'une lampe qui traverse, un bord étroit celle d'une découpe.

![Taille du trou et bord adouci](images/04-size.png)

« Vitesse de suivi » décide à quel point le trou colle au pointeur. À 4000 px/s il tient le rythme, à 800 px/s il glisse derrière lui.

## 7. Ajouter un anneau de lumière (facultatif)

« Anneau lumineux » dessine de la lumière au bord du trou, dans ta couleur d'accent ou dans la couleur du texte.

![Le trou avec un anneau](images/05-ring.png)

## 8. Laisser passer l'image partout (facultatif)

« Opacité de la couche du dessus » décide de ce qu'il reste du fond d'écran. À 100 %, l'image n'apparaît que dans le trou. Baisse la valeur et l'image passe sur tout l'écran, le trou restant le seul endroit où elle est entière.

![Opacité de la couche du dessus à 60 pour cent](images/07-opacity.png)

Les deux couches peuvent aussi être assombries séparément. Assombrir celle du dessus fait ressortir le trou ; assombrir celle du dessous garde l'image calme derrière tes icônes.

## 9. Voir à travers les fenêtres

Au-dessus d'une fenêtre, le pointeur appartient à cette fenêtre, le capteur du bureau ne le voit donc pas. Le mode peek place à la place une vue ronde de l'image du dessous au-dessus de toutes les fenêtres :

```sh
dms ipc call xray peek toggle
```

![La vue ronde au-dessus des fenêtres](images/06-peek.png)

Un clic y met fin, et le minuteur sous « Terminer le mode peek après » aussi. Mets-le sur une touche, sous niri :

```kdl
binds {
    Mod+Shift+X hotkey-overlay-title="Xray: look through the wallpaper" { spawn "dms" "ipc" "call" "xray" "peek" "toggle"; }
}
```

Si tu préfères ne regarder que tant que tu tiens une touche, prends la deuxième commande :

```kdl
binds {
    Mod+Alt+X cooldown-ms=150 hotkey-overlay-title="Xray: look while held" { spawn "dms" "ipc" "call" "xray" "hold"; }
}
```

Celle-ci s'appuie sur la répétition de touche : chaque répétition repousse un peu la fin, et peu après que tu relâches, la vue se referme. Si ça scintille pendant que tu tiens la touche, augmente « Maintien : délai après la touche » dans les paramètres.

## 10. Suivre derrière les fenêtres (niri avec le flux du pointeur)

Wayland ne transmet les mouvements du pointeur qu'à la surface sous le pointeur, et c'est pour ça que les étapes 5 et 9 existent. Si ton niri publie la position du pointeur par son socket IPC, le plugin peut la prendre de là :

```sh
niri msg pointer-stream      # prints positions while you move the mouse
```

Si des positions s'affichent, active « Suivre derrière les fenêtres ». Le trou court alors partout, aussi derrière les fenêtres, et se montre là où une fenêtre est translucide. Si la commande est inconnue, ton niri n'a pas le flux et l'interrupteur reste sans effet.

![Le trou derrière une fenêtre translucide](images/08-behind.png)

## 11. Échanger les couches

Avec « Deuxième image au-dessus », ton image devient la couche du dessus et le trou montre le fond d'écran DMS. Pratique si la deuxième image est celle que tu veux voir la plupart du temps, par exemple une version sombre de ton fond d'écran avec l'original clair en dessous.

## 12. Le piloter par script

```sh
dms ipc call xray at 1280 800     # hole at a fixed spot
dms ipc call xray close           # close it again
dms ipc call xray set radius 400  # change any setting
dms ipc call xray status
```

## Dépannage

**Les couches défilent quand je change d'espace de travail.** La règle de layer niri de l'étape 3 manque.

**Le trou ne suit pas sur le bureau.** « Suivre sur le bureau » est désactivé, ou une fenêtre couvre l'endroit. Le capteur ne voit le pointeur que là où le bureau est libre.

**Rien ne change du tout.** Aucune deuxième image n'est encore définie, ou le fichier a disparu ; la page de paramètres affiche le chemin qu'elle utilise.

**Un widget du bureau ne réagit plus.** Le capteur est sous les widgets, cela ne devrait donc pas arriver. Si ça arrive, désactive « Suivre sur le bureau » et utilise le mode peek à la place.

**« Suivre derrière les fenêtres » ne change rien.** Le niri qui tourne ne publie pas la position du pointeur. `dms ipc call xray status` dit alors `"stream":"refused"`, et le plugin s'en tient au capteur et au mode peek.

**La touche maintenue scintille.** La répétition de touche est plus lente que le temps sous « Maintien : délai après la touche ». Augmente-le, ou réduis le délai de répétition de ton clavier.
