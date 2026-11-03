#!/usr/bin/env bash
# ==============================================================================
# Sway Dotfiles Dependency Installer
# Detects the Linux distribution and installs all required packages,
# fonts, and tools for this Sway configuration.
#
# Supported Distros: Void, Arch, Debian/Ubuntu, Fedora, openSUSE
# ==============================================================================

set -e

# --- Colors for Output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- State Variables ---
DRY_RUN=false
NON_INTERACTIVE=false
MODE="core" # "core", "all", "apps", "check"
FORCED_DISTRO=""
ELEVATE_CMD=""

# --- Helper Functions ---
info() { echo -e "${BLUE}${BOLD}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}${BOLD}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}${BOLD}[WARN]${NC} $1"; }
error() { echo -e "${RED}${BOLD}[ERROR]${NC} $1"; }

show_help() {
    echo -e "${BOLD}Sway Config - Dependency Installer${NC}

${CYAN}Usage:${NC}
  ./install_dependencies.sh [OPTIONS]

${CYAN}Options:${NC}
  -c, --check             Verifica lo stato delle dipendenze sul sistema attuale senza installare nulla.
  -a, --all               Installa sia le dipendenze essenziali di Sway che le applicazioni consigliate.
      --apps              Installa solo le applicazioni consigliate (thunar, vlc, geany, evince, etc.).
  -d, --dry-run           Mostra i comandi del gestore di pacchetti che verrebbero eseguiti, senza eseguirli.
  -y, --yes               Modalità non interattiva (risponde 'Sì' a tutte le conferme).
      --distro <NAME>     Forza una distribuzione specifica (void, arch, debian, ubuntu, fedora, opensuse).
  -h, --help              Mostra questa guida.

${CYAN}Esempi:${NC}
  ./install_dependencies.sh --check        # Controlla cosa è installato e cosa manca
  ./install_dependencies.sh                # Installa le dipendenze essenziali
  ./install_dependencies.sh --all -y       # Installa tutto automaticamente"
}

# Parse Command Line Arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--check)
            MODE="check"
            shift
            ;;
        -a|--all)
            MODE="all"
            shift
            ;;
        --apps)
            MODE="apps"
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -y|--yes)
            NON_INTERACTIVE=true
            shift
            ;;
        --distro)
            FORCED_DISTRO="$(echo "$2" | tr '[:upper:]' '[:lower:]')"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            error "Opzione sconosciuta: $1"
            show_help
            exit 1
            ;;
    esac
done

# --- Detect Elevation Tool ---
detect_elevation() {
    if [ "$(id -u)" -eq 0 ]; then
        ELEVATE_CMD=""
    elif command -v sudo >/dev/null 2>&1; then
        ELEVATE_CMD="sudo"
    elif command -v doas >/dev/null 2>&1; then
        ELEVATE_CMD="doas"
    else
        error "Né 'sudo' né 'doas' trovati. Esegui lo script come root o installa sudo."
        exit 1
    fi
}

run_pkg_cmd() {
    local cmd="$1"
    if [ "$DRY_RUN" = true ]; then
        echo -e "${CYAN}[DRY-RUN]${NC} $cmd"
    else
        echo -e "${YELLOW}>>${NC} $cmd"
        eval "$cmd"
    fi
}

# --- Detect Distribution ---
detect_distro() {
    if [ -n "$FORCED_DISTRO" ]; then
        DISTRO="$FORCED_DISTRO"
        info "Distribuzione forzata manualmente: ${BOLD}$DISTRO${NC}"
        return
    fi

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID="${ID:-unknown}"
        DISTRO_LIKE="${ID_LIKE:-}"
    else
        DISTRO_ID="unknown"
        DISTRO_LIKE=""
    fi

    case "$DISTRO_ID" in
        void)
            DISTRO="void"
            ;;
        arch|manjaro|endeavouros|garuda|artix)
            DISTRO="arch"
            ;;
        ubuntu|debian|linuxmint|pop|elementary|zorin)
            DISTRO="debian"
            ;;
        fedora|rhel|centos|rocky|alma)
            DISTRO="fedora"
            ;;
        opensuse*|sles)
            DISTRO="opensuse"
            ;;
        *)
            # Fallback checking ID_LIKE
            if [[ "$DISTRO_LIKE" == *"arch"* ]]; then
                DISTRO="arch"
            elif [[ "$DISTRO_LIKE" == *"debian"* ]] || [[ "$DISTRO_LIKE" == *"ubuntu"* ]]; then
                DISTRO="debian"
            elif [[ "$DISTRO_LIKE" == *"fedora"* ]] || [[ "$DISTRO_LIKE" == *"rhel"* ]]; then
                DISTRO="fedora"
            elif [[ "$DISTRO_LIKE" == *"suse"* ]]; then
                DISTRO="opensuse"
            else
                DISTRO="unknown"
            fi
            ;;
    esac

    info "Distribuzione rilevata: ${BOLD}${PRETTY_NAME:-$DISTRO}${NC} (Famiglia: ${BOLD}$DISTRO${NC})"
}

# --- Check Installed Status ---
check_system_status() {
    echo -e "\n${BOLD}=====================================================${NC}"
    echo -e "${BOLD}       VERIFICA DIPENDENZE CONFIGURAZIONE SWAY       ${NC}"
    echo -e "${BOLD}=====================================================${NC}\n"

    local missing_count=0
    local ok_count=0

    check_cmd() {
        local name="$1"
        local desc="$2"
        local binary="${3:-$1}"
        if command -v "$binary" >/dev/null 2>&1; then
            printf "  ${GREEN}✓${NC} %-22s %s\n" "$name" "($desc)"
            ok_count=$((ok_count + 1))
        else
            printf "  ${RED}✗${NC} %-22s %s ${RED}[MANCANTE]${NC}\n" "$name" "($desc)"
            missing_count=$((missing_count + 1))
        fi
    }

    echo -e "${CYAN}${BOLD}[1] Compositor & Sessione Wayland:${NC}"
    check_cmd "sway" "Window manager"
    check_cmd "swaybg" "Wallpaper daemon"
    check_cmd "swayidle" "Idle management daemon"
    check_cmd "swaynag" "Dialog & warning prompt"
    check_cmd "gtklock" "Schermata di blocco GTK"
    check_cmd "dbus-send" "D-Bus activation" "dbus-send"

    echo -e "\n${CYAN}${BOLD}[2] Interfaccia & Shell:${NC}"
    check_cmd "waybar" "Status bar"
    check_cmd "foot" "Terminale Wayland preferito"
    check_cmd "rofi" "App launcher & menu"
    check_cmd "dunst" "Demone notifiche"
    check_cmd "dunstctl" "Controllo notifiche Dunst"
    check_cmd "notify-send" "Invio notifiche desktop"

    echo -e "\n${CYAN}${BOLD}[3] Utilità & Scripting:${NC}"
    check_cmd "wl-copy" "Wayland clipboard (wl-clipboard)"
    check_cmd "cliphist" "Clipboard manager con cronologia"
    check_cmd "grim" "Screenshot capturer"
    check_cmd "slurp" "Regione dello schermo per screenshot"
    check_cmd "brightnessctl" "Regolazione luminosità schermo"
    check_cmd "pactl" "Controllo volume PulseAudio/PipeWire"
    check_cmd "pavucontrol" "Mixer audio grafico"
    check_cmd "wdisplays" "Configuratore grafico display"
    check_cmd "nmcli" "NetworkManager CLI"
    check_cmd "bluetoothctl" "Controllo Bluetooth"
    check_cmd "jq" "JSON processor per rofi_notif"
    check_cmd "bc" "Calcolatore per rofi-bluetooth"
    check_cmd "python3" "Richiesto per networkmanager_dmenu"

    echo -e "\n${CYAN}${BOLD}[4] Polkit & Portali:${NC}"
    local polkit_found=false
    for p in /usr/libexec/xfce-polkit /usr/lib/xfce-polkit/xfce-polkit \
             /usr/libexec/polkit-gnome-authentication-agent-1 /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 \
             /usr/lib/polkit-kde-authentication-agent-1 /usr/libexec/hyprpolkitagent /usr/bin/lxpolkit; do
        if [ -x "$p" ]; then
            printf "  ${GREEN}✓${NC} %-22s (%s)\n" "Polkit Agent" "$p"
            polkit_found=true
            ok_count=$((ok_count + 1))
            break
        fi
    done
    if [ "$polkit_found" = false ]; then
        printf "  ${RED}✗${NC} %-22s %s ${RED}[MANCANTE]${NC}\n" "Polkit Agent" "Nessun agente trovato"
        missing_count=$((missing_count + 1))
    fi

    local portal_found=false
    for p in /usr/libexec/xdg-desktop-portal-wlr /usr/lib/xdg-desktop-portal-wlr; do
        if [ -x "$p" ]; then
            printf "  ${GREEN}✓${NC} %-22s (%s)\n" "Portal WLR" "$p"
            portal_found=true
            ok_count=$((ok_count + 1))
            break
        fi
    done
    if [ "$portal_found" = false ]; then
        printf "  ${RED}✗${NC} %-22s %s ${RED}[MANCANTE]${NC}\n" "Portal WLR" "xdg-desktop-portal-wlr"
        missing_count=$((missing_count + 1))
    fi

    echo -e "\n${CYAN}${BOLD}[5] Font & Icone (Essenziali per Waybar e Rofi):${NC}"
    if fc-list : family | grep -iq "Font Awesome"; then
        printf "  ${GREEN}✓${NC} %-22s (Font Awesome presente)\n" "FontAwesome"
        ok_count=$((ok_count + 1))
    else
        printf "  ${RED}✗${NC} %-22s %s ${RED}[MANCANTE]${NC}\n" "FontAwesome" "Font Awesome non trovato"
        missing_count=$((missing_count + 1))
    fi

    if fc-list : family | grep -iq "Nerd Font"; then
        printf "  ${GREEN}✓${NC} %-22s (Symbols Nerd Font presente)\n" "Nerd Fonts"
        ok_count=$((ok_count + 1))
    else
        printf "  ${RED}✗${NC} %-22s %s ${RED}[MANCANTE]${NC}\n" "Nerd Fonts" "Nerd Font non trovato"
        missing_count=$((missing_count + 1))
    fi

    echo -e "\n${CYAN}${BOLD}[6] Applicazioni Predefinite (default_apps.sh):${NC}"
    check_cmd "thunar" "File manager"
    check_cmd "firefox" "Browser Web"
    check_cmd "vlc" "Media player"
    check_cmd "geany" "Editor di testo"
    check_cmd "evince" "Visualizzatore PDF"
    check_cmd "gthumb" "Visualizzatore immagini"
    check_cmd "file-roller" "Gestore archivi"
    check_cmd "gnome-calendar" "Calendario per Waybar"

    echo -e "\n-----------------------------------------------------"
    echo -e "Totale pacchetti verificati: ${BOLD}$((ok_count + missing_count))${NC} | Installati: ${GREEN}${BOLD}$ok_count${NC} | Mancanti: ${RED}${BOLD}$missing_count${NC}"
    echo -e "-----------------------------------------------------\n"

    if [ "$missing_count" -gt 0 ]; then
        info "Per installare i pacchetti mancanti, esegui: ${BOLD}./install_dependencies.sh${NC}"
    else
        success "Tutte le dipendenze essenziali sono installate e pronte all'uso!"
    fi
}

# --- Font Fallback Downloader ---
install_nerd_font_fallback() {
    if fc-list : family 2>/dev/null | grep -iq "Nerd Font"; then
        return 0
    fi

    warn "Nerd Fonts non rilevato nel sistema."
    local do_download=false
    if [ "$NON_INTERACTIVE" = true ]; then
        do_download=true
    else
        read -rp "Vuoi scaricare automaticamente 'Symbols Nerd Font' in ~/.local/share/fonts? [S/n] " answer
        case "$answer" in
            [nN][oO]|[nN]) do_download=false ;;
            *) do_download=true ;;
        esac
    fi

    if [ "$do_download" = true ]; then
        info "Download di Symbols Nerd Font in corso..."
        mkdir -p "$HOME/.local/share/fonts"
        local base_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/NerdFontsSymbolsOnly"
        
        if command -v curl >/dev/null 2>&1; then
            curl -fLo "$HOME/.local/share/fonts/SymbolsNerdFont-Regular.ttf" "$base_url/SymbolsNerdFont-Regular.ttf"
            curl -fLo "$HOME/.local/share/fonts/SymbolsNerdFontMono-Regular.ttf" "$base_url/SymbolsNerdFontMono-Regular.ttf"
        elif command -v wget >/dev/null 2>&1; then
            wget -qO "$HOME/.local/share/fonts/SymbolsNerdFont-Regular.ttf" "$base_url/SymbolsNerdFont-Regular.ttf"
            wget -qO "$HOME/.local/share/fonts/SymbolsNerdFontMono-Regular.ttf" "$base_url/SymbolsNerdFontMono-Regular.ttf"
        else
            warn "Né curl né wget disponibili per il download del font. Installa Symbols Nerd Font manualmente."
            return 1
        fi

        if command -v fc-cache >/dev/null 2>&1; then
            fc-cache -fv "$HOME/.local/share/fonts" >/dev/null 2>&1
        fi
        success "Symbols Nerd Font installato con successo in ~/.local/share/fonts!"
    fi
}

# --- Cliphist Fallback Downloader ---
install_cliphist_fallback() {
    if command -v cliphist >/dev/null 2>&1; then
        return 0
    fi

    warn "'cliphist' non è stato trovato nei repository della tua distribuzione."
    local do_dl=false
    if [ "$NON_INTERACTIVE" = true ]; then
        do_dl=true
    else
        read -rp "Vuoi scaricare l'eseguibile statico di cliphist da GitHub in ~/.local/bin? [S/n] " answer
        case "$answer" in
            [nN][oO]|[nN]) do_dl=false ;;
            *) do_dl=true ;;
        esac
    fi

    if [ "$do_dl" = true ]; then
        info "Download di cliphist da GitHub..."
        mkdir -p "$HOME/.local/bin"
        local arch="linux-amd64"
        case "$(uname -m)" in
            aarch64|arm64) arch="linux-arm64" ;;
            armv7l) arch="linux-armv7" ;;
            x86_64) arch="linux-amd64" ;;
        esac

        local clip_url="https://github.com/sentriz/cliphist/releases/latest/download/v0.5.0-$arch"
        if command -v curl >/dev/null 2>&1; then
            curl -fLo "$HOME/.local/bin/cliphist" "$clip_url"
            chmod +x "$HOME/.local/bin/cliphist"
            success "cliphist salvato in ~/.local/bin/cliphist (assicurati che ~/.local/bin sia nel tuo PATH)."
        elif command -v wget >/dev/null 2>&1; then
            wget -qO "$HOME/.local/bin/cliphist" "$clip_url"
            chmod +x "$HOME/.local/bin/cliphist"
            success "cliphist salvato in ~/.local/bin/cliphist."
        fi
    fi
}

# --- Post Install Permissions & Scripts ---
post_install_tasks() {
    info "Verifica dei permessi per gli script locali..."
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -d "$script_dir/bin" ]; then
        chmod +x "$script_dir/bin/"* 2>/dev/null || true
        success "Tutti gli script in $script_dir/bin sono ora eseguibili."
    fi

    if [ -f "$script_dir/default_apps.sh" ]; then
        chmod +x "$script_dir/default_apps.sh"
    fi

    # Groups check
    local current_user="${USER:-$(whoami)}"
    local groups_to_check=("video" "input")
    local missing_groups=()

    for g in "${groups_to_check[@]}"; do
        if getent group "$g" >/dev/null 2>&1; then
            if ! id -nG "$current_user" | grep -qw "$g"; then
                missing_groups+=("$g")
            fi
        fi
    done

    if [ ${#missing_groups[@]} -gt 0 ]; then
        warn "Il tuo utente ($current_user) non appartiene a questi gruppi: ${missing_groups[*]}"
        warn "Questi gruppi sono utili per brightnessctl e la gestione dei dispositivi di input su Sway."
        echo -e "Per aggiungerli, esegui: ${BOLD}$ELEVATE_CMD usermod -aG $(IFS=,; echo "${missing_groups[*]}") $current_user${NC}"
    fi

    echo -e "\n${GREEN}${BOLD}Installazione completata!${NC}"
    echo -e "Per avviare Sway:"
    echo -e "  1. Assicurati che D-Bus e i servizi audio (PipeWire) siano attivi."
    echo -e "  2. Avvia la sessione con: ${BOLD}sway${NC}\n"
}

# ==============================================================================
# Distribution Specific Installers
# ==============================================================================

install_void() {
    detect_elevation

    local CORE_PKGS=(
        sway
        swaybg
        swayidle
        Waybar
        foot
        rofi
        gtklock
        dunst
        libnotify
        cliphist
        wl-clipboard
        grim
        slurp
        brightnessctl
        pavucontrol
        pulseaudio-utils
        wdisplays
        NetworkManager
        network-manager-applet
        bluez
        jq
        bc
        python3
        pipewire
        wireplumber
        alsa-pipewire
        xdg-desktop-portal
        xdg-desktop-portal-wlr
        xfce-polkit
        font-awesome6
        nerd-fonts-symbols-ttf
    )

    local APP_PKGS=(
        thunar
        firefox
        vlc
        geany
        evince
        gthumb
        file-roller
        gnome-calendar
        xdg-utils
    )

    local TO_INSTALL=()
    if [ "$MODE" = "core" ] || [ "$MODE" = "all" ]; then
        TO_INSTALL+=("${CORE_PKGS[@]}")
    fi
    if [ "$MODE" = "apps" ] || [ "$MODE" = "all" ]; then
        TO_INSTALL+=("${APP_PKGS[@]}")
    fi

    info "Installazione pacchetti per Void Linux con xbps-install..."
    run_pkg_cmd "$ELEVATE_CMD xbps-install -Sy ${TO_INSTALL[*]}"

    install_nerd_font_fallback
    post_install_tasks
}

install_arch() {
    detect_elevation

    local CORE_PKGS=(
        sway
        swaybg
        swayidle
        waybar
        foot
        rofi-wayland
        dunst
        libnotify
        cliphist
        wl-clipboard
        grim
        slurp
        brightnessctl
        pavucontrol
        libpulse
        wdisplays
        networkmanager
        network-manager-applet
        bluez
        bluez-utils
        jq
        bc
        python
        pipewire
        wireplumber
        pipewire-pulse
        pipewire-alsa
        xdg-desktop-portal
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        polkit-gnome
        ttf-font-awesome
        ttf-nerd-fonts-symbols
    )

    local APP_PKGS=(
        thunar
        firefox
        vlc
        geany
        evince
        gthumb
        file-roller
        gnome-calendar
        xdg-utils
    )

    local TO_INSTALL=()
    if [ "$MODE" = "core" ] || [ "$MODE" = "all" ]; then
        TO_INSTALL+=("${CORE_PKGS[@]}")
    fi
    if [ "$MODE" = "apps" ] || [ "$MODE" = "all" ]; then
        TO_INSTALL+=("${APP_PKGS[@]}")
    fi

    info "Installazione pacchetti per Arch Linux con pacman..."
    run_pkg_cmd "$ELEVATE_CMD pacman -Sy --needed ${TO_INSTALL[*]}"

    # Check for gtklock (often in AUR or extra)
    if ! command -v gtklock >/dev/null 2>&1; then
        if command -v paru >/dev/null 2>&1; then
            info "Installazione gtklock tramite paru (AUR)..."
            run_pkg_cmd "paru -S --needed gtklock xfce-polkit"
        elif command -v yay >/dev/null 2>&1; then
            info "Installazione gtklock tramite yay (AUR)..."
            run_pkg_cmd "yay -S --needed gtklock xfce-polkit"
        else
            warn "'gtklock' non è stato trovato nei repository ufficiali."
            warn "Puoi installarlo da AUR tramite yay/paru: yay -S gtklock"
        fi
    fi

    install_nerd_font_fallback
    post_install_tasks
}

install_debian() {
    detect_elevation

    local CORE_PKGS=(
        sway
        swaybg
        swayidle
        waybar
        foot
        rofi-wayland
        dunst
        libnotify-bin
        wl-clipboard
        grim
        slurp
        brightnessctl
        pavucontrol
        pulseaudio-utils
        wdisplays
        network-manager
        network-manager-gnome
        bluez
        jq
        bc
        python3
        pipewire
        wireplumber
        pipewire-pulse
        xdg-desktop-portal
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        policykit-1-gnome
        fonts-font-awesome
    )

    local APP_PKGS=(
        thunar
        vlc
        geany
        evince
        gthumb
        file-roller
        gnome-calendar
        xdg-utils
    )

    local TO_INSTALL=()
    if [ "$MODE" = "core" ] || [ "$MODE" = "all" ]; then
        TO_INSTALL+=("${CORE_PKGS[@]}")
    fi
    if [ "$MODE" = "apps" ] || [ "$MODE" = "all" ]; then
        TO_INSTALL+=("${APP_PKGS[@]}")
    fi

    info "Aggiornamento indice pacchetti Debian/Ubuntu..."
    run_pkg_cmd "$ELEVATE_CMD apt-get update"

    info "Installazione pacchetti con apt-get..."
    # Use --ignore-missing / install available packages gracefully
    run_pkg_cmd "$ELEVATE_CMD apt-get install -y ${TO_INSTALL[*]} || true"

    # Specific fallbacks
    install_cliphist_fallback
    install_nerd_font_fallback

    if ! command -v gtklock >/dev/null 2>&1; then
        warn "'gtklock' potrebbe non essere disponibile nei repository standard di questa versione di Debian/Ubuntu."
        warn "Puoi compilare gtklock da sorgente oppure usare swaylock sostituendo 'gtklock -d' con 'swaylock' in ~/.config/sway/config."
    fi

    post_install_tasks
}

install_fedora() {
    detect_elevation

    local CORE_PKGS=(
        sway
        swaybg
        swayidle
        waybar
        foot
        rofi-wayland
        dunst
        libnotify
        wl-clipboard
        grim
        slurp
        brightnessctl
        pavucontrol
        pulseaudio-utils
        wdisplays
        NetworkManager
        network-manager-applet
        bluez
        bluez-tools
        jq
        bc
        python3
        pipewire
        wireplumber
        pipewire-pulseaudio
        xdg-desktop-portal
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        polkit-gnome
        fontawesome-fonts-all
    )

    local APP_PKGS=(
        thunar
        firefox
        vlc
        geany
        evince
        gthumb
        file-roller
        gnome-calendar
        xdg-utils
    )

    local TO_INSTALL=()
    if [ "$MODE" = "core" ] || [ "$MODE" = "all" ]; then
        TO_INSTALL+=("${CORE_PKGS[@]}")
    fi
    if [ "$MODE" = "apps" ] || [ "$MODE" = "all" ]; then
        TO_INSTALL+=("${APP_PKGS[@]}")
    fi

    info "Installazione pacchetti per Fedora con dnf..."
    run_pkg_cmd "$ELEVATE_CMD dnf install -y ${TO_INSTALL[*]}"

    install_cliphist_fallback
    install_nerd_font_fallback
    post_install_tasks
}

install_opensuse() {
    detect_elevation

    local CORE_PKGS=(
        sway
        swaybg
        swayidle
        waybar
        foot
        rofi
        dunst
        libnotify-tools
        wl-clipboard
        grim
        slurp
        brightnessctl
        pavucontrol
        pulseaudio-utils
        wdisplays
        NetworkManager
        NetworkManager-applet
        bluez
        jq
        bc
        python3
        pipewire
        wireplumber
        pipewire-pulseaudio
        xdg-desktop-portal
        xdg-desktop-portal-wlr
        polkit-gnome
        fontawesome-fonts
    )

    local APP_PKGS=(
        thunar
        MozillaFirefox
        vlc
        geany
        evince
        gthumb
        file-roller
        gnome-calendar
        xdg-utils
    )

    local TO_INSTALL=()
    if [ "$MODE" = "core" ] || [ "$MODE" = "all" ]; then
        TO_INSTALL+=("${CORE_PKGS[@]}")
    fi
    if [ "$MODE" = "apps" ] || [ "$MODE" = "all" ]; then
        TO_INSTALL+=("${APP_PKGS[@]}")
    fi

    info "Installazione pacchetti per openSUSE con zypper..."
    run_pkg_cmd "$ELEVATE_CMD zypper in -y ${TO_INSTALL[*]}"

    install_cliphist_fallback
    install_nerd_font_fallback
    post_install_tasks
}

# ==============================================================================
# Main Routine
# ==============================================================================

main() {
    detect_distro

    if [ "$MODE" = "check" ]; then
        check_system_status
        exit 0
    fi

    echo -e "\n${BOLD}=====================================================${NC}"
    echo -e "${BOLD}       SWAY DOTFILES - INSTALLATORE DIPENDENZE       ${NC}"
    echo -e "${BOLD}=====================================================${NC}\n"
    info "Target OS: ${BOLD}$DISTRO${NC} | Modalità: ${BOLD}$MODE${NC}"

    if [ "$MODE" = "core" ] && [ "$NON_INTERACTIVE" = false ]; then
        read -rp "Desideri installare anche le applicazioni predefinite consigliate (thunar, vlc, geany, etc.)? [s/N] " ans
        case "$ans" in
            [sS][iI]|[sS]|[yY][eE][sS]|[yY])
                MODE="all"
                info "Modalità cambiata in: ${BOLD}all${NC}"
                ;;
            *)
                info "Procedo con le sole dipendenze essenziali del desktop Sway."
                ;;
        esac
    fi

    case "$DISTRO" in
        void)
            install_void
            ;;
        arch)
            install_arch
            ;;
        debian)
            install_debian
            ;;
        fedora)
            install_fedora
            ;;
        opensuse)
            install_opensuse
            ;;
        *)
            error "Distribuzione non supportata automaticamente: '$DISTRO'."
            echo "Puoi forzare una distribuzione con l'opzione --distro <void|arch|debian|fedora|opensuse>"
            echo "Oppure esegui ./install_dependencies.sh --check per vedere la lista dei binari necessari."
            exit 1
            ;;
    esac
}

main "$@"
