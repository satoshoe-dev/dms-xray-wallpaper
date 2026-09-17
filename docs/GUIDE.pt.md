# Xray Wallpaper: passo a passo

[English](GUIDE.md) · [Deutsch](GUIDE.de.md) · [Español](GUIDE.es.md) · [Français](GUIDE.fr.md) · [Italiano](GUIDE.it.md) · **Português** · [Русский](GUIDE.ru.md) · [日本語](GUIDE.ja.md) · [简体中文](GUIDE.zh_CN.md)

## 1. Instalar o plugin

Clona o repositório para a tua pasta de plugins do DMS:

```sh
git clone https://github.com/21Rebel/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
```

## 2. Ativá-lo

Abre Definições → Plugins. O Xray Wallpaper aparece na lista. Liga-o.

![Lista de plugins com o Xray Wallpaper](images/01-plugin-list.png)

Se não aparecer, clica em "Scan" nessa página ou reinicia a shell com `dms restart`.

## 3. No niri: manter as camadas no backdrop

No niri as superfícies de fundo movem-se com as áreas de trabalho. Acrescenta isto a `~/.config/niri/config.kdl` para que a imagem fique no lugar:

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

O niri aceita a alteração assim que gravas o ficheiro.

## 4. Escolher a segunda imagem

Expande o Xray Wallpaper na lista de plugins e clica em "Escolher imagem". O explorador de ficheiros abre na tua pasta de imagens.

![A página de definições com o explorador de ficheiros](images/02-choose-image.png)

O teu papel de parede fica onde está; a imagem que escolhes aparece no buraco. Até escolheres uma, nada muda no ecrã.

## 5. Passar o ponteiro pelo ambiente de trabalho

Leva o ponteiro para um sítio livre do ambiente de trabalho. O buraco abre onde está o ponteiro e segue-o.

![O buraco no ambiente de trabalho](images/03-hole.png)

Leva o ponteiro para cima de uma janela e o buraco fecha-se outra vez.

## 6. Ajustar o tamanho e a borda

"Tamanho do buraco" é o raio em pixels, "Borda suave" a largura em que as duas camadas se misturam. Uma borda suave larga parece uma lâmpada a brilhar por trás, uma estreita parece um recorte.

![Tamanho do buraco e borda suave](images/04-size.png)

"Velocidade de seguimento" decide o quanto o buraco se cola ao ponteiro. A 4000 px/s acompanha, a 800 px/s desliza atrás dele.

## 7. Acrescentar um anel de luz (opcional)

"Anel luminoso" desenha luz na borda do buraco, na tua cor de destaque ou na cor do texto.

![O buraco com um anel](images/05-ring.png)

## 8. Deixar passar a imagem em todo o lado (opcional)

"Opacidade da camada de cima" decide quanto fica do papel de parede. A 100 % a imagem só aparece no buraco. Baixa o valor e a imagem passa por todo o ecrã, com o buraco como o único sítio onde está inteira.

![Opacidade da camada de cima a 60 por cento](images/07-opacity.png)

As duas camadas também podem ser escurecidas em separado. Escurecer a de cima faz o buraco saltar à vista; escurecer a de baixo mantém a imagem calma por trás dos teus ícones.

## 9. Ver através das janelas

Sobre uma janela o ponteiro pertence a essa janela, por isso o sensor do ambiente de trabalho não o vê. O modo peek coloca em vez disso uma vista redonda da imagem de baixo acima de todas as janelas:

```sh
dms ipc call xray peek toggle
```

![A vista redonda acima das janelas](images/06-peek.png)

Um clique termina-o, e o temporizador em "Terminar o modo peek após" também. Põe-no numa tecla, no niri:

```kdl
binds {
    Mod+Shift+X hotkey-overlay-title="Xray: look through the wallpaper" { spawn "dms" "ipc" "call" "xray" "peek" "toggle"; }
}
```

Se preferires ver só enquanto tens uma tecla premida, usa o segundo comando:

```kdl
binds {
    Mod+Alt+X cooldown-ms=150 hotkey-overlay-title="Xray: look while held" { spawn "dms" "ipc" "call" "xray" "hold"; }
}
```

Este apoia-se na repetição da tecla: cada repetição empurra o fim um pouco mais para a frente, e pouco depois de largares a vista fecha-se. Se tremer enquanto tens a tecla premida, aumenta "Manter: tempo depois da tecla" nas definições.

## 10. Seguir por trás das janelas (niri com o fluxo do ponteiro)

O Wayland só entrega o movimento do ponteiro à superfície que está por baixo dele, e é por isso que os passos 5 e 9 existem. Se o teu niri publicar a posição do ponteiro pelo seu socket IPC, o plugin pode tirá-la de lá:

```sh
niri msg pointer-stream      # prints positions while you move the mouse
```

Se aparecerem posições, liga "Seguir por trás das janelas". O buraco passa então a correr em todo o lado, também por trás das janelas, e mostra-se onde uma janela for translúcida. Se o comando for desconhecido, o teu niri não tem o fluxo e o interruptor fica sem efeito.

![O buraco por trás de uma janela translúcida](images/08-behind.png)

## 11. Trocar as camadas

Com "Segunda imagem em cima" a tua imagem passa a ser a camada de cima e o buraco mostra o papel de parede do DMS. Útil se a segunda imagem for a que queres ver a maior parte do tempo, por exemplo uma versão escura do teu papel de parede com o original claro por baixo.

## 12. Usá-lo em scripts

```sh
dms ipc call xray at 1280 800     # hole at a fixed spot
dms ipc call xray close           # close it again
dms ipc call xray set radius 400  # change any setting
dms ipc call xray status
```

## Resolução de problemas

**As camadas desaparecem quando mudo de área de trabalho.** Falta a regra de layer do niri do passo 3.

**O buraco não segue no ambiente de trabalho.** "Seguir no ambiente de trabalho" está desligado, ou uma janela cobre esse sítio. O sensor só vê o ponteiro onde o ambiente de trabalho está livre.

**Não muda nada.** Ainda não está definida nenhuma segunda imagem, ou o ficheiro desapareceu; a página de definições mostra o caminho que usa.

**Um widget do ambiente de trabalho deixou de reagir.** O sensor fica sob os widgets, por isso não devia acontecer. Se acontecer, desliga "Seguir no ambiente de trabalho" e usa o modo peek.

**"Seguir por trás das janelas" não muda nada.** O niri em execução não publica a posição do ponteiro. `dms ipc call xray status` diz nesse caso `"stream":"refused"`, e o plugin fica-se pelo sensor e pelo modo peek.

**A tecla premida treme.** A repetição da tecla é mais lenta do que o tempo em "Manter: tempo depois da tecla". Aumenta-o, ou reduz o atraso de repetição do teu teclado.
