# Xray Wallpaper: passo per passo

[English](GUIDE.md) · [Deutsch](GUIDE.de.md) · [Español](GUIDE.es.md) · [Français](GUIDE.fr.md) · **Italiano** · [Português](GUIDE.pt.md) · [Русский](GUIDE.ru.md) · [日本語](GUIDE.ja.md) · [简体中文](GUIDE.zh_CN.md)

## 1. Installare il plugin

Dal registro dei plugin:

```sh
dms plugins install xrayWallpaper
```

Oppure clona il repository nella tua cartella dei plugin DMS:

```sh
git clone https://github.com/satoshoe-dev/dms-xray-wallpaper ~/.config/DankMaterialShell/plugins/XrayWallpaper
```

## 2. Attivarlo

Apri Impostazioni → Plugin. Xray Wallpaper compare nell'elenco. Attivalo.

![Elenco dei plugin con Xray Wallpaper](images/01-plugin-list.png)

Se non compare, clicca su «Scansiona» in quella pagina oppure riavvia la shell con `dms restart`.

## 3. Su niri: tenere i livelli nel backdrop

Su niri le superfici di sfondo si spostano con gli spazi di lavoro. Aggiungi questo a `~/.config/niri/config.kdl` così l'immagine resta dov'è:

```kdl
layer-rule {
    match namespace="^xray-wallpaper$"
    place-within-backdrop true
}
```

niri recepisce la modifica appena salvi il file.

## 4. Scegliere la seconda immagine

Espandi Xray Wallpaper nell'elenco dei plugin e clicca su "Scegli immagine". Il selettore di file si apre nella tua cartella delle immagini.

![La pagina delle impostazioni con il selettore di file](images/02-choose-image.png)

Il tuo sfondo resta dov'è; l'immagine che scegli si vede nel foro. Finché non ne scegli una, sullo schermo non cambia nulla.

## 5. Muovere il puntatore sulla scrivania

Porta il puntatore su un punto libero della scrivania. Il foro si apre dove sta il puntatore e lo segue.

![Il foro sulla scrivania](images/03-hole.png)

Porta il puntatore su una finestra e il foro si richiude.

## 6. Impostare la dimensione e il bordo

"Dimensione del foro" è il raggio in pixel, "Bordo morbido" quanto è larga la zona in cui i due livelli si mescolano. Un bordo morbido largo sembra una lampada che filtra, uno stretto un ritaglio.

![Dimensione del foro e bordo morbido](images/04-size.png)

"Velocità di inseguimento" decide quanto il foro sta attaccato al puntatore. A 4000 px/s tiene il passo, a 800 px/s gli scivola dietro.

## 7. Aggiungere un anello di luce (facoltativo)

"Anello luminoso" disegna luce sul bordo del foro, nel tuo colore d'accento o nel colore del testo.

![Il foro con un anello](images/05-ring.png)

## 8. Lasciare passare l'immagine ovunque (facoltativo)

"Opacità del livello sopra" decide quanto resta dello sfondo. A 100 % l'immagine si vede solo nel foro. Abbassala e l'immagine passa su tutto lo schermo, con il foro come l'unico punto in cui è piena.

![Opacità del livello sopra al 60 per cento](images/07-opacity.png)

I due livelli si possono anche scurire separatamente. Scurire quello sopra fa risaltare il foro; scurire quello sotto tiene calma l'immagine dietro le tue icone.

## 9. Guardare attraverso le finestre

Sopra una finestra il puntatore appartiene a quella finestra, quindi il sensore della scrivania non lo vede. La modalità peek mette invece una vista rotonda dell'immagine sotto al di sopra di tutte le finestre:

```sh
dms ipc call xray peek toggle
```

![La vista rotonda sopra le finestre](images/06-peek.png)

Un clic la termina, e così anche il timer sotto "Termina la modalità peek dopo". Mettila su un tasto, su niri:

```kdl
binds {
    Mod+Shift+X hotkey-overlay-title="Xray: look through the wallpaper" { spawn "dms" "ipc" "call" "xray" "peek" "toggle"; }
}
```

Se preferisci guardare solo mentre tieni premuto un tasto, usa il secondo comando:

```kdl
binds {
    Mod+Alt+X cooldown-ms=150 hotkey-overlay-title="Xray: look while held" { spawn "dms" "ipc" "call" "xray" "hold"; }
}
```

Questo si appoggia alla ripetizione del tasto: ogni ripetizione sposta la fine un po' più in là, e poco dopo che lasci, la vista si chiude. Se sfarfalla mentre tieni premuto il tasto, alza "Tenere premuto: tempo dopo il tasto" nelle impostazioni.

## 10. Seguire dietro le finestre (solo niri con la patch)

Wayland passa i movimenti del puntatore solo alla superficie sotto il puntatore, ed è per questo che i passi 5 e 9 esistono. niri conosce la posizione ma non la fornisce. Una patch che ho scritto io, e che non fa parte di niri, aggiunge un flusso del puntatore al socket IPC di niri, e il plugin può prendere la posizione da lì. Con un niri normale salta questo passo; tutto il resto di questa guida funziona senza la patch. Per controllare quale niri hai:

```sh
niri msg pointer-stream      # prints positions while you move the mouse
```

Se compaiono delle posizioni, accendi "Seguire dietro le finestre". Il foro corre allora dappertutto, anche dietro le finestre, e si vede dove una finestra è trasparente. Se niri non conosce il comando, il tuo niri non ha il flusso del puntatore e l'interruttore non compare.

![Il foro dietro una finestra trasparente](images/08-behind.png)

## 11. Scambiare i livelli

Con "Seconda immagine sopra" la tua immagine diventa il livello sopra e il foro mostra lo sfondo DMS. Utile se la seconda immagine è quella che vuoi vedere per la maggior parte del tempo, per esempio una versione scura del tuo sfondo con l'originale chiaro sotto.

## 12. Comandarlo da script

```sh
dms ipc call xray at 1280 800     # hole at a fixed spot
dms ipc call xray close           # close it again
dms ipc call xray set radius 400  # change any setting
dms ipc call xray status
```

## Risoluzione dei problemi

### I livelli scorrono via quando cambio spazio di lavoro

Manca la regola layer di niri del passo 3.

### Il foro non segue sulla scrivania

"Segui sulla scrivania" è spento, oppure una finestra copre quel punto. Il sensore vede il puntatore solo dove la scrivania è libera.

### Non cambia proprio nulla

Non è ancora impostata nessuna seconda immagine, oppure il file non c'è più; la pagina delle impostazioni mostra il percorso che usa.

### Un widget della scrivania non reagisce più

Il sensore sta sotto i widget, quindi non dovrebbe succedere. Se succede, spegni "Segui sulla scrivania" e usa la modalità peek.

### "Seguire dietro le finestre" non cambia nulla

Il niri in esecuzione è compilato senza la patch del flusso del puntatore. `dms ipc call xray status` dice in quel caso `"stream":"refused"`, e il plugin resta al sensore e alla modalità peek.

### Il tasto tenuto premuto sfarfalla

La ripetizione del tasto è più lenta del tempo sotto "Tenere premuto: tempo dopo il tasto". Alzalo, oppure abbassa il ritardo di ripetizione della tua tastiera.
