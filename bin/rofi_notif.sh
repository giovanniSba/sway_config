#!/bin/bash

# Estrai la cronologia da dunst e formattala
history=$(dunstctl history | jq -r '.data[0][] | "\(.id.data) | \(.appname.data): \(.summary.data)"')

# Mostra in rofi e salva la selezione
selected=$(echo "$history" | rofi -dmenu -i -p "Notifications")

# Se hai selezionato qualcosa, estrai l'ID e fai un'azione (es. ripristina la notifica)
if [ -n "$selected" ]; then
    id=$(echo "$selected" | awk -F'|' '{print $1}' | tr -d ' ')
    dunstctl history-pop "$id"
fi
