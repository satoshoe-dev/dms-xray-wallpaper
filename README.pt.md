# Xray Wallpaper

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · **Português** · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh_CN.md)

Um plugin para o [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) que mantém uma segunda imagem por trás do seu papel de parede. Ao redor do ponteiro, o papel de parede tem um buraco suave, e a imagem aparece nele.

![Xray Wallpaper](assets/screenshot.png)

Passo a passo com imagens: [guia de instalação e configuração](docs/GUIDE.pt.md).

## O que faz

O seu papel de parede do DMS fica onde está. O plugin desenha a imagem que você escolhe em uma superfície transparente por cima dele: dentro do buraco ao redor do ponteiro e em nenhum outro lugar. Tudo o que ele não desenha fica livre, então as transições de papel de parede, os widgets da área de trabalho e os outros plugins de fundo continuam funcionando.

Na área de trabalho o buraco segue o ponteiro; afaste o ponteiro da área de trabalho e o buraco se fecha.

Sobre uma janela o ponteiro pertence a essa janela, então há um segundo caminho: o modo peek. Ele abre uma vista redonda da imagem acima de todas as janelas, segue o ponteiro para qualquer lugar e termina com um clique, depois de alguns segundos, ou quando você solta a tecla que está segurando.

No niri há um terceiro caminho: "Seguir por trás das janelas" lê a posição do ponteiro do socket IPC do niri, e o buraco continua correndo por trás das janelas, visível onde elas forem translúcidas. O niri não fornece a posição do ponteiro por conta própria, então isso precisa de um niri com um patch meu (veja mais abaixo). Com um niri normal a opção fica oculta e os dois caminhos acima funcionam como sempre.

"Opacidade da camada de cima" abaixo de 100 % deixa a imagem passar pela tela inteira, e o conjunto vira uma mistura de duas imagens com um ponto nítido ao redor do ponteiro. Com "Segunda imagem em cima" é a imagem que cobre o papel de parede e o buraco mostra o papel de parede. O tamanho do buraco, a suavidade da borda, um anel de luz se você quiser e a rapidez com que o buraco segue podem ser ajustados.

A imagem é mapeada como o papel de parede do DMS, então esticar, ajustar e cortar ficam com o mesmo aspecto do seu papel de parede.

## Requisitos

DankMaterialShell 1.6.1 ou mais recente. Eu uso no niri. Com um niri normal tudo funciona, menos "Seguir por trás das janelas", que precisa de um niri com o patch; veja a seção "Seguir por trás das janelas" mais abaixo.

No niri, as superfícies de fundo se movem com os espaços de trabalho, a não ser que fiquem no backdrop. Adicione isto à sua configuração do niri, senão a imagem desaparece quando você muda de espaço de trabalho:

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

## Instalação

Pelo registro de plugins:

```sh
dms plugins install xrayWallpaper
dms ipc call plugins enable xrayWallpaper
```

Ele também aparece no DMS em Configurações → Plugins → Navegar. Para instalar a partir do repositório:

```sh
git clone https://github.com/satoshoe-dev/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
dms ipc call plugins enable xrayWallpaper
```

Depois escolha a segunda imagem em Configurações → Plugins → Xray Wallpaper. Enquanto ela não estiver definida, nada muda na tela.

## Configurações

Configurações → Plugins → Xray Wallpaper

| Configuração | Padrão |
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
| Seguir na área de trabalho | ligado |
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

Atalhos de teclado no niri, um como interruptor e outro para manter pressionado:

```kdl
binds {
    Mod+Shift+X { spawn "dms" "ipc" "call" "xray" "peek" "toggle"; }
    Mod+Alt+X cooldown-ms=150 { spawn "dms" "ipc" "call" "xray" "hold"; }
}
```

O atalho para manter pressionado funciona pela repetição da tecla: cada repetição empurra o fim um pouco mais para a frente, e pouco depois de você soltar, a vista se fecha. Se tremer enquanto você segura a tecla, aumente "Manter: tempo depois da tecla".

## Seguir por trás das janelas

O Wayland entrega o movimento do ponteiro só para a superfície que está embaixo dele, então nenhum cliente consegue segui-lo assim que uma janela fica no meio. O niri conhece a posição, mas não a publica.

O fluxo do ponteiro é um patch que eu escrevi para o niri e não faz parte do niri. Ele adiciona ao IPC um pedido `PointerStream` separado que envia eventos `PointerMoved`, então os clientes que não o pedem nunca os veem. Com um niri compilado com este patch o interruptor funciona. Um niri normal responde ao pedido com um erro; o plugin registra isso e fica só com o sensor da área de trabalho e o modo peek. Nesse caso a página de configurações esconde o interruptor, e todo o resto funciona como descrito acima.

O patch para o niri 26.04 está no branch [pointer-stream-v26.04](https://github.com/satoshoe-dev/niri/tree/pointer-stream-v26.04) do meu fork do niri. Ele é compilado como o próprio niri, veja o README dele.

## Traduções

A página de configurações está disponível em alemão, espanhol, francês, italiano, português, russo, japonês e chinês simplificado e segue o idioma definido no DMS. Se uma tradução soar mal, um pull request é bem-vindo.

## Nota

Escrevi este plugin com a ajuda do Claude (Anthropic) e testei cada mudança no meu próprio desktop com niri.

## Licença

MIT
