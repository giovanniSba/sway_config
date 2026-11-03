# Sway Dotfiles

Configurazione personale e portabile per **Sway** (Wayland tiling compositor), completa di Waybar, Foot terminal, menu Rofi personalizzati, gestione notifiche con Dunst e script di utilità.

---

## 🚀 Installazione su un nuovo PC

### 1. Clona la repository
Clona il repository direttamente nella cartella `~/.config/sway`:

```bash
git clone <URL-DEL-TUO-REPO> ~/.config/sway
cd ~/.config/sway
```

### 2. Esegui l'installer delle dipendenze
Lo script `install_dependencies.sh` (o tramite il link rapido `./install.sh`) rileva automaticamente la distribuzione Linux in uso (**Void, Arch, Debian/Ubuntu, Fedora, openSUSE**) e installa tutti i pacchetti, font e strumenti necessari.

```bash
# Verifica lo stato attuale delle dipendenze (senza installare nulla):
./install.sh --check

# Installa tutte le dipendenze essenziali di Sway:
./install.sh

# Oppure installa tutto, incluse le applicazioni predefinite (thunar, vlc, geany, etc.):
./install.sh --all
```

---

## 🛠️ Opzioni dello script Installer

| Opzione | Descrizione |
|---|---|
| `-c`, `--check` | Esegue un check completo del sistema e mostra quali dipendenze sono presenti o mancanti |
| `-a`, `--all` | Installa sia i componenti essenziali che le applicazioni predefinite |
| `--apps` | Installa solo le applicazioni desktop (senza toccare i pacchetti base) |
| `-d`, `--dry-run` | Mostra i comandi del gestore di pacchetti che verrebbero eseguiti |
| `-y`, `--yes` | Modalità non-interattiva (risponde automaticamente 'Sì' a tutti i prompt) |
| `--distro <NAME>` | Forza una distribuzione specifica (`void`, `arch`, `debian`, `fedora`, `opensuse`) |

---

## 📦 Componenti Principali

- **Window Manager**: [Sway](https://github.com/swaywm/sway) + `swayidle` + `swaybg`
- **Barra di stato**: [Waybar](https://github.com/Alexays/Waybar) con palette Gruvbox e moduli interattivi
- **Terminale**: [Foot](https://codeberg.org/dnkl/foot) (leggero e nativo Wayland)
- **Application Launcher & Menu**: [Rofi](https://github.com/davatorium/rofi) (rofi-wayland)
- **Notifiche**: [Dunst](https://github.com/dunst-project/dunst) con cronologia navigabile da Rofi
- **Lockscreen**: [gtklock](https://github.com/jovanlanik/gtklock)
- **Clipboard**: `wl-clipboard` + `cliphist`
- **Screenshot**: `grim` + `slurp`
- **Controllo Audio/Luminosità**: `brightnessctl`, `pactl` (PipeWire/WirePlumber), `pavucontrol`
- **Reti & Bluetooth**: `NetworkManager` (`nmcli`, `rofi-wifi`), `bluez` (`rofi-bluetooth`)
- **Font & Icone**: `Font Awesome 6` + `Symbols Nerd Font` (scaricato in automatico se assente)

---

## 📂 Struttura della repository

```
~/.config/sway/
├── config                   # File di configurazione principale di Sway
├── variables.conf           # Variabili di base (mod, terminale, menu)
├── autostart.conf           # Avvio demone e servizi di background
├── monitors.conf            # Configurazione risoluzione e posizione monitor
├── default_apps.sh          # Assegnazione associazioni xdg-mime
├── install_dependencies.sh  # Script installer multi-distro
├── install.sh               # Collegamento simbolico a install_dependencies.sh
├── .gitignore               # Esclusioni file temporanei/cache
├── bin/                     # Script di supporto e wrapper universali
│   ├── networkmanager_dmenu # Gestione WiFi & reti tramite Rofi
│   ├── rofi-wifi            # Selettore rapido WiFi con Rofi
│   ├── rofi-bluetooth       # Gestione connessioni Bluetooth con Rofi
│   ├── rofi_notif.sh        # Cronologia notifiche Dunst tramite Rofi
│   ├── polkit-agent.sh      # Wrapper universale per l'agente PolKit
│   └── portal-init.sh       # Inizializzatore universale per XDG Desktop Portal
├── config.d/                # Moduli aggiuntivi
│   ├── 40-sway-background.conf
│   ├── default_applications.conf
│   ├── ricing.conf          # Colori Gruvbox, gap e bordi
│   └── windows_rules.conf   # Regole finestre fluttuanti
├── input/                   # Configurazione tastiera, touchpad e gesti
├── output/                  # Configurazione schermi e monitor
├── wallpaper/               # Sfondi desktop inclusi
└── waybar/                  # Configurazione e stile CSS di Waybar
```

---

## ⌨️ Scorciatoie Rapide Principali

| Scorciatoia | Azione |
|---|---|
| `Mod + Invio` | Apre il terminale Foot |
| `Mod + Spazio` | Apre il launcher Rofi |
| `Mod + Shift + q` | Chiude la finestra corrente |
| `Mod + Shift + c` | Cronologia appunti (Cliphist + Rofi) |
| `Mod + Shift + w` | Gestore reti WiFi (NetworkManager + Rofi) |
| `Mod + Shift + b` | Gestore Bluetooth (Rofi) |
| `Mod + Shift + n` | Centro notifiche (Dunst + Rofi) |
| `Mod + Shift + p` | Configurazione display grafici (`wdisplays`) |
| `Print` | Cattura schermo intero (in `~/Pictures/screenshots`) |
| `Mod + Print` | Selezione area screenshot copiata negli appunti |
| `Ctrl + Alt + l` | Blocca lo schermo (`gtklock`) |
