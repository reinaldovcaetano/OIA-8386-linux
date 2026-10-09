#!/bin/bash
# Instala o driver TSPL da OIA-8386 no CUPS. Uso: sudo ./instalar.sh
set -e
[ "$EUID" -eq 0 ] || { echo "Rode com sudo: sudo ./instalar.sh"; exit 1; }
DIR="$(cd "$(dirname "$0")" && pwd)"
NAME="OIA-8386"

install -o root -g root -m 755 "$DIR/rastertotspl" /usr/lib/cups/filter/rastertotspl
install -d /usr/share/cups/model
install -o root -g root -m 644 "$DIR/OIA-8386.ppd" /usr/share/cups/model/OIA-8386.ppd

URI=$(lpinfo -v 2>/dev/null | awk '/^direct usb:\/\//{print $2}' | grep -iE 'label|pos|0416|oia|printer' | head -1)
[ -n "$URI" ] || URI=$(lpinfo -v 2>/dev/null | awk '/^direct usb:\/\//{print $2}' | head -1)
[ -n "$URI" ] || URI="file:/dev/usb/lp0"
echo "Dispositivo: $URI"

lpadmin -p "$NAME" -E -v "$URI" -P /usr/share/cups/model/OIA-8386.ppd \
    -D "OIA-8386 Impressora de Etiquetas" -o printer-is-shared=false
lpadmin -d "$NAME" 2>/dev/null || true
cupsenable "$NAME"; cupsaccept "$NAME"
echo "Pronto. Impressora '$NAME' instalada."
echo "Teste: lp -d $NAME -o PageSize=w100h150 -o fit-to-page \"$DIR/teste-etiqueta.pdf\""
