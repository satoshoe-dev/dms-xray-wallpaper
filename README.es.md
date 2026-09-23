# Xray Wallpaper

[English](README.md) · [Deutsch](README.de.md) · **Español** · [Français](README.fr.md) · [Italiano](README.it.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh_CN.md)

Un plugin para [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) que mantiene una segunda imagen detrás de tu fondo de pantalla. Alrededor del puntero el fondo tiene un agujero suave, y por él se ve la imagen.

![Xray Wallpaper](assets/screenshot.png)

Paso a paso y con imágenes: [guía de instalación y ajustes](docs/GUIDE.es.md).

## Qué hace

Tu fondo de DMS se queda donde está. El plugin dibuja la imagen que elijas sobre una superficie transparente por encima: dentro del agujero alrededor del puntero, y en ningún sitio más. Todo lo que no dibuja queda despejado, así que las transiciones del fondo, los widgets del escritorio y otros plugins de fondo siguen funcionando.

En el escritorio el agujero sigue al puntero; aparta el puntero del escritorio y el agujero se cierra.

Sobre una ventana el puntero pertenece a esa ventana, así que hay una segunda vía: el modo peek. Abre una vista redonda de la imagen por encima de todas las ventanas, sigue al puntero en cualquier sitio y termina con un clic, a los pocos segundos, o cuando sueltas la tecla que mantienes pulsada.

En niri hay una tercera vía: «Seguir detrás de las ventanas» lee la posición del puntero del socket IPC de niri, y el agujero sigue corriendo detrás de las ventanas, visible allí donde son translúcidas. niri no entrega la posición del puntero por sí mismo, así que esto necesita un niri con un parche mío (ver más abajo). Con un niri normal el ajuste queda oculto y las dos vías de arriba funcionan como siempre.

«Opacidad de la capa superior» por debajo del 100 % deja pasar la imagen por toda la pantalla, con lo que el conjunto se convierte en una mezcla de dos imágenes con un punto despejado alrededor del puntero. Con «Segunda imagen arriba» la imagen tapa el fondo y el agujero muestra el fondo. El tamaño del agujero, la suavidad de su borde, un anillo de luz opcional y la rapidez con la que el agujero sigue al puntero se pueden ajustar. «Intensidad del agujero» por debajo del 100 % abre el agujero solo en parte, así que la imagen se transparenta alrededor del puntero sin sustituir allí el fondo, por ejemplo una placa de circuito detrás de un fondo normal.

La imagen se mapea igual que el fondo de DMS, así que estirar, ajustar y recortar se ven como en tu fondo.

## Requisitos

DankMaterialShell 1.6.1 o más reciente. Yo lo uso en niri. Con un niri normal funciona todo menos «Seguir detrás de las ventanas», que necesita un niri parcheado; lo explica la sección «Seguir detrás de las ventanas» más abajo.

En niri, las superficies de fondo se mueven con los espacios de trabajo si no están en el backdrop. Añade esto a tu configuración de niri; si no, la imagen se desplaza cuando cambias de espacio de trabajo:

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

## Instalación

Desde el registro de complementos:

```sh
dms plugins install xrayWallpaper
dms ipc call plugins enable xrayWallpaper
```

También aparece en DMS en Ajustes → Complementos → Explorar. Para instalarlo desde el repositorio:

```sh
git clone https://github.com/satoshoe-dev/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
dms ipc call plugins enable xrayWallpaper
```

Después elige la segunda imagen en Ajustes → Complementos → Xray Wallpaper. Hasta que esté puesta, en la pantalla no cambia nada.

## Ajustes

Ajustes → Complementos → Xray Wallpaper

| Ajuste | Predeterminado |
|---|---|
| Segunda imagen | ninguna |
| Segunda imagen arriba | desactivado |
| Tamaño del agujero | 260 px |
| Borde suave | 90 px |
| Anillo luminoso | 0 px (desactivado) |
| Color del anillo | acento |
| Opacidad de la capa superior | 100 % |
| Intensidad del agujero | 100 % |
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

El flujo del puntero es un parche mío para niri y no forma parte de niri. Añade al IPC una petición `PointerStream` aparte que envía eventos `PointerMoved`, de modo que los clientes que no la piden nunca los ven. Con un niri compilado con este parche el interruptor funciona. Un niri normal responde a la petición con un error; el plugin lo anota y se queda con el sensor del escritorio y el modo peek. La página de ajustes oculta entonces el interruptor, y todo lo demás funciona como se describe arriba.

El parche para niri 26.04 está en la rama [pointer-stream-v26.04](https://github.com/satoshoe-dev/niri/tree/pointer-stream-v26.04) de mi fork de niri. Se compila igual que niri, consulta su README.

## Traducciones

La página de ajustes está disponible en alemán, español, francés, italiano, portugués, ruso, japonés y chino simplificado, y sigue el idioma configurado en DMS. Si una traducción suena mal, se agradece un pull request.

## Nota

Escribí este plugin con ayuda de Claude (Anthropic) y probé cada cambio en mi propio escritorio niri.

## Licencia

MIT
