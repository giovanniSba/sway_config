#!/bin/bash
# # Web e HTML
xdg-mime default firefox.desktop x-scheme-handler/http x-scheme-handler/https text/html
# 
# # File Manager
xdg-mime default thunar.desktop inode/directory
# 
# # Testo e Codice
xdg-mime default geany.desktop text/plain application/json application/xml text/markdown text/csv
# 
# # PDF
xdg-mime default org.gnome.Evince.desktop application/pdf
# 
# # Immagini
xdg-mime default org.gnome.gThumb.desktop image/jpeg image/png image/gif image/webp image/bmp image/tiff image/svg+xml
# 
# # Video
xdg-mime default vlc.desktop video/mp4 video/x-matroska video/webm video/x-msvideo video/quicktime
# 
# # Audio
xdg-mime default vlc.desktop audio/mpeg audio/x-wav audio/ogg audio/flac
# 
# # Archivi (usando File Roller/Gestore archivi)
xdg-mime default org.gnome.FileRoller.desktop application/zip application/x-tar application/x-gzip application/x-bzip2 application/x-xz application/x-7z-compressed application/x-rar
# 
# Documenti Office (LibreOffice)
xdg-mime default libreoffice-writer.desktop application/vnd.openxmlformats-officedocument.wordprocessingml.document application/msword application/vnd.oasis.opendocument.text
xdg-mime default libreoffice-calc.desktop application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.ms-excel application/vnd.oasis.opendocument.spreadsheet
# 
# 
gio mime inode/directory thunar.desktop
gio mime application/pdf org.gnome.Evince.desktop
gio mime text/plain geany.desktop
