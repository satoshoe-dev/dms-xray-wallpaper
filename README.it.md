# Xray Wallpaper

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · **Italiano** · [Português](README.pt.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh_CN.md)

Un plugin per [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) che tiene una seconda immagine dietro il tuo sfondo. Attorno al puntatore lo sfondo ha un foro morbido, e nel foro si vede l'immagine.

![Xray Wallpaper](assets/screenshot.png)

Passo per passo con le immagini: [guida all'installazione e alla configurazione](docs/GUIDE.it.md).

## Cosa fa

Il tuo sfondo DMS resta dov'è. Il plugin disegna l'immagine che scegli su una superficie trasparente sopra di esso: dentro il foro attorno al puntatore e in nessun altro punto. Tutto quello che non disegna resta libero, quindi le transizioni dello sfondo, i widget della scrivania e gli altri plugin di sfondo continuano a funzionare.

Sulla scrivania il foro segue il puntatore; porta il puntatore via dalla scrivania e il foro si chiude.

Sopra una finestra il puntatore appartiene a quella finestra, quindi c'è una seconda via: la modalità peek. Apre una vista rotonda dell'immagine al di sopra di tutte le finestre, segue il puntatore in ogni punto e finisce con un clic, dopo qualche secondo, oppure quando lasci il tasto che tieni premuto.

Su niri c'è una terza via: "Seguire dietro le finestre" legge la posizione del puntatore dal socket IPC di niri, e il foro continua a correre dietro le finestre, visibile dove sono trasparenti. niri da solo non fornisce la posizione del puntatore, quindi serve un niri con una mia patch (vedi sotto). Con un niri normale l'impostazione non fa nulla e le due vie di sopra funzionano come sempre.

"Opacità del livello sopra" sotto il 100 % lascia passare l'immagine su tutto lo schermo, e il tutto diventa una miscela di due immagini con un punto nitido attorno al puntatore. Con "Seconda immagine sopra" è invece l'immagine a coprire lo sfondo e il foro mostra lo sfondo. La dimensione del foro, la morbidezza del suo bordo, un anello di luce se lo vuoi e la velocità con cui il foro insegue si possono impostare tutti.

L'immagine viene mappata come lo sfondo DMS, quindi stiramento, adattamento e taglio hanno lo stesso aspetto del tuo sfondo.

## Requisiti

DankMaterialShell 1.6.1 o più recente. Io lo uso su niri. Con un niri normale funziona tutto tranne "Seguire dietro le finestre", che richiede un niri con la patch; vedi la sezione "Seguire dietro le finestre" più sotto.

Su niri le superfici di sfondo si spostano con gli spazi di lavoro, a meno che non stiano nel backdrop. Aggiungi questo alla tua configurazione di niri, altrimenti l'immagine scorre via quando cambi spazio di lavoro:

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

## Installazione

Dal registro dei plugin:

```sh
dms plugins install xrayWallpaper
dms ipc call plugins enable xrayWallpaper
```

Si trova anche in DMS in Impostazioni → Plugin → Sfoglia. Per installarlo dal repository:

```sh
git clone https://github.com/satoshoe-dev/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
dms ipc call plugins enable xrayWallpaper
```

Poi scegli la seconda immagine in Impostazioni → Plugin → Xray Wallpaper. Finché non è impostata, sullo schermo non cambia nulla.

## Impostazioni

Impostazioni → Plugin → Xray Wallpaper

| Impostazione | Valore predefinito |
|---|---|
| Seconda immagine | nessuna |
| Seconda immagine sopra | spento |
| Dimensione del foro | 260 px |
| Bordo morbido | 90 px |
| Anello luminoso | 0 px (spento) |
| Colore dell'anello | Accento |
| Opacità del livello sopra | 100 % |
| Scurisci il livello sopra / sotto | 0 % / 0 % |
| Velocità di inseguimento | 4000 px/s |
| Segui sulla scrivania | acceso |
| Seguire dietro le finestre | spento |
| Tenere premuto: tempo dopo il tasto | 800 ms |
| Termina la modalità peek dopo | 20 s |

## IPC

```sh
dms ipc call xray peek toggle     # round view above the windows, also on|off
dms ipc call xray hold            # the same, but only while a key is held
dms ipc call xray at 1280 800     # put the hole at a fixed spot
dms ipc call xray close           # close it again
dms ipc call xray status
dms ipc call xray set radius 400  # any setting from the table above
```

Scorciatoie da tastiera su niri, una come interruttore e una da tenere premuta:

```kdl
binds {
    Mod+Shift+X { spawn "dms" "ipc" "call" "xray" "peek" "toggle"; }
    Mod+Alt+X cooldown-ms=150 { spawn "dms" "ipc" "call" "xray" "hold"; }
}
```

La scorciatoia da tenere premuta lavora attraverso la ripetizione del tasto: ogni ripetizione sposta la fine un po' più in là, e poco dopo che lasci, la vista si chiude. Se sfarfalla mentre tieni premuto il tasto, alza "Tenere premuto: tempo dopo il tasto".

## Seguire dietro le finestre

Wayland consegna i movimenti del puntatore solo alla superficie sotto il puntatore, quindi nessun client può seguirlo appena c'è una finestra di mezzo. niri conosce la posizione ma non la pubblica.

Il flusso del puntatore è una patch che ho scritto io per niri e non fa parte di niri. Aggiunge all'IPC una richiesta `PointerStream` a parte che manda eventi `PointerMoved`, così i client che non la chiedono non li vedono mai. Con un niri compilato con questa patch l'interruttore funziona. Un niri normale risponde alla richiesta con un errore; il plugin se lo segna e resta al sensore della scrivania e alla modalità peek. L'interruttore allora non cambia nulla, e tutto il resto funziona come descritto sopra.

La patch per niri 26.04 si trova nel ramo [pointer-stream-v26.04](https://github.com/satoshoe-dev/niri/tree/pointer-stream-v26.04) del mio fork di niri. Si compila come niri stesso, vedi il suo README.

## Traduzioni

La pagina delle impostazioni è disponibile in tedesco, spagnolo, francese, italiano, portoghese, russo, giapponese e cinese semplificato e segue la lingua impostata in DMS. Se una traduzione suona male, una pull request è benvenuta.

## Nota

Ho scritto questo plugin con l'aiuto di Claude (Anthropic) e ho provato ogni modifica sulla mia scrivania niri.

## Licenza

MIT
