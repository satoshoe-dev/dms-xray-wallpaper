# Xray Wallpaper

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · **Português** · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh_CN.md)

Um plugin para o [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) que mantém uma segunda imagem por trás do teu papel de parede. Ao redor do ponteiro, o papel de parede tem um buraco suave, e a imagem aparece nele.

![Xray Wallpaper](assets/screenshot.png)

Passo a passo com imagens: [guia de instalação e configuração](docs/GUIDE.md).

## O que faz

O teu papel de parede do DMS fica onde está. O plugin desenha a imagem que escolhes numa superfície transparente por cima dele: dentro do buraco ao redor do ponteiro e em mais lado nenhum. Tudo o que não desenha fica livre, por isso as transições de papel de parede, os widgets do ambiente de trabalho e os outros plugins de fundo continuam a funcionar.

No ambiente de trabalho o buraco segue o ponteiro; afasta o ponteiro do ambiente de trabalho e o buraco fecha-se.

Sobre uma janela o ponteiro pertence a essa janela, por isso há um segundo caminho: o modo peek. Abre uma vista redonda da imagem acima de todas as janelas, segue o ponteiro em qualquer sítio e termina com um clique, depois de alguns segundos, ou quando largas a tecla que tens premida.

No niri há um terceiro caminho, se o teu niri fornecer a posição do ponteiro pelo seu socket IPC: então "Seguir por trás das janelas" tira a posição daí e o buraco continua a correr por trás das janelas, visível onde elas forem translúcidas. Onde isso falta, a opção não faz nada e ficam os dois caminhos de cima.

"Opacidade da camada de cima" deixa passar a imagem em todo o lado, não só no buraco, e o conjunto passa a ser uma mistura de duas imagens com um ponto nítido ao redor do ponteiro. Com "Segunda imagem em cima" é a imagem que cobre o papel de parede e o buraco mostra o papel de parede. O tamanho do buraco, a suavidade da sua borda, um anel de luz se quiseres e a rapidez com que o buraco segue podem todos ser ajustados.

A imagem é mapeada como o papel de parede do DMS, por isso esticar, ajustar e cortar ficam com o mesmo aspeto do teu papel de parede.

## Requisitos

DankMaterialShell 1.6.1 ou mais recente.

No niri, as superfícies de fundo movem-se com as áreas de trabalho a não ser que fiquem no backdrop. Acrescenta isto à tua configuração do niri, senão a imagem desaparece quando mudas de área de trabalho:

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

## Instalação

```sh
git clone https://github.com/21Rebel/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
dms ipc call plugins enable xrayWallpaper
```

Depois escolhe a segunda imagem em Definições → Plugins → Xray Wallpaper. Até estar definida, nada muda no ecrã.

## Definições

Definições → Plugins → Xray Wallpaper

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

O patch que a publica é pequeno e fica só no IPC: um pedido `PointerStream` à parte que envia eventos `PointerMoved`, por isso os clientes que não o pedem nunca os veem. Foi enviado ao niri como pull request; se entrar, "Seguir por trás das janelas" começa a funcionar sozinho. Até lá, o interruptor está ali para quem tiver o niri a correr com ele.

## Traduções

A página de definições está disponível em alemão, espanhol, francês, italiano, português, russo, japonês e chinês simplificado e segue a língua definida no DMS. Se uma tradução soar mal, um pull request é bem-vindo.

## Nota

Escrevi este plugin com a ajuda do Claude (Anthropic) e testei cada alteração no meu próprio ambiente de trabalho com niri.

## Licença

MIT
