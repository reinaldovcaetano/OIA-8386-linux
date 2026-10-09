#!/bin/bash
[ "$EUID" -eq 0 ] || { echo "Rode com sudo"; exit 1; }
lpadmin -x OIA-8386 2>/dev/null
rm -f /usr/lib/cups/filter/rastertotspl /usr/share/cups/model/OIA-8386.ppd
echo "Removido."
