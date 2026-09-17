# Xray Wallpaper

[English](README.md) · [Deutsch](README.de.md) · **Español** · [Français](README.fr.md) · [Italiano](README.it.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh_CN.md)

Un plugin para [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) que mantiene una segunda imagen detrás de tu fondo de pantalla. Alrededor del puntero el fondo tiene un agujero suave, y por él se ve la imagen.

![Xray Wallpaper](assets/screenshot.png)

Paso a paso y con imágenes: [guía de instalación y ajustes](docs/GUIDE.md).

## Qué hace

Tu fondo de DMS se queda donde está. El plugin dibuja la imagen que elijas sobre una superficie transparente por encima: dentro del agujero alrededor del puntero, y en ningún sitio más. Todo lo que no dibuja queda despejado, así que las transiciones del fondo, los widgets del escritorio y otros plugins de fondo siguen funcionando.

En el escritorio el agujero sigue al puntero; aparta el puntero del escritorio y el agujero se cierra.

Sobre una ventana el puntero pertenece a esa ventana, así que hay una segunda vía: el modo peek. Abre una vista redonda de la imagen por encima de todas las ventanas, sigue al puntero en cualquier sitio y termina con un clic, a los pocos segundos, o cuando sueltas la tecla que mantienes pulsada.

En niri hay una tercera vía, si tu niri entrega la posición del puntero por su socket IPC: entonces «Seguir detrás de las ventanas» toma la posición de ahí y el agujero sigue corriendo detrás de las ventanas, visible allí donde son translúcidas. Donde eso falta, el ajuste no hace nada y quedan las dos vías de arriba.

«Opacidad de la capa superior» deja pasar la imagen por todas partes, no solo por el agujero, con lo que el conjunto se convierte en una mezcla de dos imágenes con un punto despejado alrededor del puntero. Con «Segunda imagen arriba» la imagen tapa el fondo y el agujero muestra el fondo. El tamaño del agujero, la suavidad de su borde, un anillo de luz opcional y la rapidez con la que el agujero sigue al puntero se pueden ajustar.

La imagen se mapea igual que el fondo de DMS, así que estirar, ajustar y recortar se ven como en tu fondo.

## Requisitos

DankMaterialShell 1.6.1 o más reciente.

En niri, las superficies de fondo se mueven con los espacios de trabajo si no están en el backdrop. Añade esto a tu configuración de niri; si no, la imagen se desplaza cuando cambias de espacio de trabajo:

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

## Instalación

```sh
git clone https://github.com/21Rebel/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
dms ipc call plugins enable xrayWallpaper
```

Después elige la segunda imagen en Ajustes → Plugins → Xray Wallpaper. Hasta que esté puesta, en la pantalla no cambia nada.

## Ajustes

Ajustes → Plugins → Xray Wallpaper

| Ajuste | Predeterminado |
|---|---|
| Segunda imagen | ninguna |
| Segunda imagen arriba | desactivado |
| Tamaño del agujero | 260 px |
| Borde suave | 90 px |
| Anillo luminoso | 0 px (desactivado) |
| Color del anillo | acento |
| Opacidad de la capa superior | 100 % |
| Oscurecer la capa superior / inferior | 0 % / 0 % |
| Velocidad de seguimiento | 4000 px/s |
| Seguir en el escritorio | activado |
| Seguir detrás de las ventanas | desactivado |
| Mantener: tiempo tras soltar la tecla | 800 ms |
| Terminar el modo peek tras | 20 s |

## IPC

```sh
dms ipc call xray peek toggle     # round view above the windows, also on|off
dms ipc call xray hold            # the same, but only while a key is held
dms ipc call xray at 1280 800     # put the hole at a fixed spot
dms ipc call xray close           # close it again
dms ipc call xray status
dms ipc call xray set radius 400  # any setting from the table above
```

Combinaciones de teclas en niri, una como interruptor y otra para mantener pulsada:

```kdl
binds {
    Mod+Shift+X { spawn "dms" "ipc" "call" "xray" "peek" "toggle"; }
    Mod+Alt+X cooldown-ms=150 { spawn "dms" "ipc" "call" "xray" "hold"; }
}
```

La combinación de mantener pulsada se apoya en la repetición de tecla: cada repetición empuja el final un poco más allá, y poco después de soltar, la vista se cierra. Si parpadea mientras mantienes la tecla, sube «Mantener: tiempo tras soltar la tecla».

## Seguir detrás de las ventanas

Wayland entrega el movimiento del puntero solo a la superficie que está debajo de él, así que ningún cliente puede seguirlo en cuanto hay una ventana por medio. niri conoce la posición, pero no la publica.

El parche que sí la publica es pequeño y se queda en el IPC: una petición `PointerStream` aparte que envía eventos `PointerMoved`, de modo que los clientes que no la piden nunca los ven. Se envió a niri como pull request; si entra, «Seguir detrás de las ventanas» empieza a funcionar por sí solo. Hasta entonces el interruptor está ahí para quien use un niri que lo lleve.

## Traducciones

La página de ajustes está disponible en alemán, español, francés, italiano, portugués, ruso, japonés y chino simplificado, y sigue el idioma configurado en DMS. Si una traducción suena mal, se agradece un pull request.

## Nota

Escribí este plugin con ayuda de Claude (Anthropic) y probé cada cambio en mi propio escritorio niri.

## Licencia

MIT
