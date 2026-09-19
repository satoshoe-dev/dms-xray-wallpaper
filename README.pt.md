# Xray Wallpaper

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · **Português** · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh_CN.md)

Um plugin para o [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) que mantém uma segunda imagem por trás do teu papel de parede. Ao redor do ponteiro, o papel de parede tem um buraco suave, e a imagem aparece nele.

![Xray Wallpaper](assets/screenshot.png)

Passo a passo com imagens: [guia de instalação e configuração](docs/GUIDE.pt.md).

## O que faz

O teu papel de parede do DMS fica onde está. O plugin desenha a imagem que escolhes numa superfície transparente por cima dele: dentro do buraco ao redor do ponteiro e em mais lado nenhum. Tudo o que não desenha fica livre, por isso as transições de papel de parede, os widgets do ambiente de trabalho e os outros plugins de fundo continuam a funcionar.

No ambiente de trabalho o buraco segue o ponteiro; afasta o ponteiro do ambiente de trabalho e o buraco fecha-se.

Sobre uma janela o ponteiro pertence a essa janela, por isso há um segundo caminho: o modo peek. Abre uma vista redonda da imagem acima de todas as janelas, segue o ponteiro em qualquer sítio e termina com um clique, depois de alguns segundos, ou quando largas a tecla que tens premida.

No niri há um terceiro caminho: "Seguir por trás das janelas" lê a posição do ponteiro do socket IPC do niri, e o buraco continua a correr por trás das janelas, visível onde elas forem translúcidas. O niri não fornece a posição do ponteiro por si só, por isso isto precisa de um niri com um patch meu (ver mais abaixo). Com um niri normal a opção não faz nada e os dois caminhos de cima funcionam como sempre.

"Opacidade da camada de cima" abaixo de 100 % deixa passar a imagem pelo ecrã inteiro, e o conjunto passa a ser uma mistura de duas imagens com um ponto nítido ao redor do ponteiro. Com "Segunda imagem em cima" é a imagem que cobre o papel de parede e o buraco mostra o papel de parede. O tamanho do buraco, a suavidade da sua borda, um anel de luz se quiseres e a rapidez com que o buraco segue podem todos ser ajustados.

A imagem é mapeada como o papel de parede do DMS, por isso esticar, ajustar e cortar ficam com o mesmo aspeto do teu papel de parede.

## Requisitos

DankMaterialShell 1.6.1 ou mais recente. Eu uso-o no niri. Com um niri normal funciona tudo menos "Seguir por trás das janelas", que precisa de um niri com o patch; ver a secção "Seguir por trás das janelas" mais abaixo.

No niri, as superfícies de fundo movem-se com as áreas de trabalho a não ser que fiquem no backdrop. Acrescenta isto à tua configuração do niri, senão a imagem desaparece quando mudas de área de trabalho:

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

## Instalação

Pelo registo de plugins:

```sh
dms plugins install xrayWallpaper
dms ipc call plugins enable xrayWallpaper
```

Também aparece no DMS em Configurações → Plugins → Navegar. Para instalar a partir do repositório:

```sh
git clone https://github.com/satoshoe-dev/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
dms ipc call plugins enable xrayWallpaper
```

Depois escolhe a segunda imagem em Configurações → Plugins → Xray Wallpaper. Até estar definida, nada muda no ecrã.

## Definições

Configurações → Plugins → Xray Wallpaper

| Opção | Predefinição |
|---|---|
| Segunda imagem | nenhuma |
| Segunda imagem em cima | desligado |
| Tamanho do buraco | 260 px |
| Borda suave | 90 px |
| Anel luminoso | 0 px (desligado) |
| Cor do anel | Destaque |
| Opacidade da camada de cima | 100 % |
| Escurecer a camada de cima / de baixo | 0 % / 0 % |
| Velocidade de seguimento | 4000 px/s |
| Seguir no ambiente de trabalho | ligado |
| Seguir por trás das janelas | desligado |
| Manter: tempo depois da tecla | 800 ms |
| Terminar o modo peek após | 20 s |

## IPC

```sh
dms ipc call xray peek toggle     # round view above the windows, also on|off
dms ipc call xray hold            # the same, but only while a key is held
dms ipc call xray at 1280 800     # put the hole at a fixed spot
dms ipc call xray close           # close it again
dms ipc call xray status
dms ipc call xray set radius 400  # any setting from the table above
```

Atalhos de teclado no niri, um como interruptor e outro para manter premido:

```kdl
binds {
    Mod+Shift+X { spawn "dms" "ipc" "call" "xray" "peek" "toggle"; }
    Mod+Alt+X cooldown-ms=150 { spawn "dms" "ipc" "call" "xray" "hold"; }
}
```

O atalho para manter premido trabalha através da repetição da tecla: cada repetição empurra o fim um pouco mais para a frente, e pouco depois de largares a vista fecha-se. Se tremer enquanto tens a tecla premida, aumenta "Manter: tempo depois da tecla".

## Seguir por trás das janelas

O Wayland entrega o movimento do ponteiro só à superfície que está por baixo dele, por isso nenhum cliente o consegue seguir assim que uma janela fica pelo meio. O niri conhece a posição, mas não a publica.

O fluxo do ponteiro é um patch que eu escrevi para o niri e não faz parte do niri. Acrescenta ao IPC um pedido `PointerStream` à parte que envia eventos `PointerMoved`, por isso os clientes que não o pedem nunca os veem. Com um niri compilado com este patch o interruptor funciona. Um niri normal responde ao pedido com um erro; o plugin toma nota disso e fica-se pelo sensor do ambiente de trabalho e pelo modo peek. O interruptor não muda nada nesse caso, e tudo o resto funciona como descrito acima.

## Traduções

A página de definições está disponível em alemão, espanhol, francês, italiano, português, russo, japonês e chinês simplificado e segue a língua definida no DMS. Se uma tradução soar mal, um pull request é bem-vindo.

## Nota

Escrevi este plugin com a ajuda do Claude (Anthropic) e testei cada alteração no meu próprio ambiente de trabalho com niri.

## Licença

MIT
