# Xray Wallpaper: paso a paso

[English](GUIDE.md) · [Deutsch](GUIDE.de.md) · **Español** · [Français](GUIDE.fr.md) · [Italiano](GUIDE.it.md) · [Português](GUIDE.pt.md) · [Русский](GUIDE.ru.md) · [日本語](GUIDE.ja.md) · [简体中文](GUIDE.zh_CN.md)

## 1. Instalar el plugin

Desde el registro de complementos:

```sh
dms plugins install xrayWallpaper
```

O clona el repositorio en tu carpeta de plugins de DMS:

```sh
git clone https://github.com/satoshoe-dev/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
```

## 2. Activarlo

Abre Ajustes → Complementos. Xray Wallpaper aparece en la lista. Actívalo.

![Lista de plugins con Xray Wallpaper](images/01-plugin-list.png)

Si no aparece, pulsa «Escanear» en esa página o reinicia la shell con `dms restart`.

## 3. En niri: mantén las capas en el backdrop

En niri las superficies de fondo se mueven con los espacios de trabajo. Añade esto a `~/.config/niri/config.kdl` para que la imagen se quede quieta:

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

niri toma el cambio en cuanto guardas el archivo.

## 4. Elegir la segunda imagen

Despliega Xray Wallpaper en la lista de plugins y pulsa «Elegir imagen». El explorador de archivos se abre en tu carpeta de imágenes.

![La página de ajustes con el explorador de archivos](images/02-choose-image.png)

Tu fondo se queda donde está; la imagen que elijas se ve por el agujero. Hasta que elijas una, en la pantalla no cambia nada.

## 5. Mueve el puntero por el escritorio

Lleva el puntero a un sitio libre del escritorio. El agujero se abre donde está el puntero y lo sigue.

![El agujero en el escritorio](images/03-hole.png)

Lleva el puntero sobre una ventana y el agujero se cierra otra vez.

## 6. Ajustar el tamaño y el borde

«Tamaño del agujero» es el radio en píxeles, «Borde suave» es lo ancha que es la mezcla entre las dos capas. Un borde suave ancho parece una lámpara que atraviesa, uno estrecho parece un recorte.

![Tamaño del agujero y borde suave](images/04-size.png)

«Velocidad de seguimiento» decide lo pegado que va el agujero al puntero. A 4000 px/s lo acompaña, a 800 px/s se desliza detrás.

## 7. Añadir un anillo de luz (opcional)

«Anillo luminoso» dibuja luz en el borde del agujero, en tu color de acento o en el color del texto.

![El agujero con un anillo](images/05-ring.png)

## 8. Dejar pasar la imagen por todas partes (opcional)

«Opacidad de la capa superior» decide cuánto fondo se queda. Al 100 % la imagen solo se ve en el agujero. Bájala y la imagen sale por toda la pantalla, con el agujero como el único sitio donde está entera.

![Opacidad de la capa superior al 60 por ciento](images/07-opacity.png)

Las dos capas también se pueden oscurecer por separado. Oscurecer la de arriba hace que el agujero destaque; oscurecer la de abajo mantiene tranquila la imagen detrás de tus iconos.

## 9. Mirar a través de las ventanas

Sobre una ventana el puntero pertenece a esa ventana, así que el sensor del escritorio no lo ve. En su lugar, el modo peek pone una vista redonda de la imagen inferior por encima de todas las ventanas:

```sh
dms ipc call xray peek toggle
```

![La vista redonda sobre las ventanas](images/06-peek.png)

Un clic lo termina, y también el temporizador de «Terminar el modo peek tras». Ponlo en una tecla, en niri:

```kdl
binds {
    Mod+Shift+X hotkey-overlay-title="Xray: look through the wallpaper" { spawn "dms" "ipc" "call" "xray" "peek" "toggle"; }
}
```

Si prefieres mirar solo mientras mantienes una tecla, usa el segundo comando:

```kdl
binds {
    Mod+Alt+X cooldown-ms=150 hotkey-overlay-title="Xray: look while held" { spawn "dms" "ipc" "call" "xray" "hold"; }
}
```

Este se apoya en la repetición de tecla: cada repetición empuja el final un poco más allá, y poco después de soltar, la vista se cierra. Si parpadea mientras mantienes la tecla, sube «Mantener: tiempo tras soltar la tecla» en los ajustes.

## 10. Seguir detrás de las ventanas (solo con niri parcheado)

Wayland entrega el movimiento del puntero solo a la superficie que está debajo de él, y por eso existen los pasos 5 y 9. niri conoce la posición, pero no la entrega. Un parche mío, que no forma parte de niri, añade un flujo del puntero al socket IPC de niri, y el plugin puede tomar la posición de ahí. Con un niri normal, sáltate este paso; todo lo demás de esta guía funciona sin el parche. Para comprobar qué niri tienes:

```sh
niri msg pointer-stream      # prints positions while you move the mouse
```

Si eso imprime posiciones, activa «Seguir detrás de las ventanas». Entonces el agujero corre por todas partes, también detrás de las ventanas, y aparece allí donde una ventana es translúcida. Si niri no conoce el comando, tu niri no tiene el flujo del puntero y el interruptor no aparece.

![El agujero detrás de una ventana translúcida](images/08-behind.png)

## 11. Intercambiar las capas

Con «Segunda imagen arriba» tu imagen pasa a ser la capa superior y el agujero muestra el fondo de DMS. Útil si la segunda imagen es la que quieres ver la mayor parte del tiempo, por ejemplo una versión oscura de tu fondo con el original claro debajo.

## 12. Desde un script

```sh
dms ipc call xray at 1280 800     # hole at a fixed spot
dms ipc call xray close           # close it again
dms ipc call xray set radius 400  # change any setting
dms ipc call xray status
```

## Solución de problemas

### Las capas se desplazan cuando cambio de espacio de trabajo

Falta la regla de capa de niri del paso 3.

### El agujero no sigue en el escritorio

«Seguir en el escritorio» está desactivado, o una ventana cubre ese sitio. El sensor solo ve el puntero donde el escritorio está libre.

### No cambia nada de nada

Todavía no hay segunda imagen puesta, o el archivo ya no está; la página de ajustes muestra la ruta que usa.

### Un widget del escritorio deja de reaccionar

El sensor queda debajo de los widgets, así que esto no debería pasar. Si pasa, desactiva «Seguir en el escritorio» y usa el modo peek.

### «Seguir detrás de las ventanas» no cambia nada

El niri en marcha está compilado sin el parche del flujo del puntero. En ese caso `dms ipc call xray status` dice `"stream":"refused"`, y el plugin se queda con el sensor y el modo peek.

### La tecla mantenida parpadea

La repetición de tecla es más lenta que el tiempo de «Mantener: tiempo tras soltar la tecla». Súbelo, o baja el retardo de repetición de tu teclado.
