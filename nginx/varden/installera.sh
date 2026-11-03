#!/bin/sh
# Lägger till /planmosaik/ i din nginx. Kör med sudo, en gång:
#
#   sudo sh installera.sh <konfigurationsfil> '<ankarrad>'
#
# Exempel (HTTPS-blocket i Debians/Ubuntus standardwebbplats; ankarraden är en rad som finns EXAKT en gång i filen,
# inuti server-blocket för HTTPS):
#
#   sudo sh installera.sh /etc/nginx/sites-available/default 'server_name kartor.exempelkommun.se;'
#
# Det här görs (och inget annat):
#   1. säkerhetskopierar konfigurationsfilen
#   2. kopierar planmosaik.conf till /etc/nginx/snippets/
#   3. lägger in EN rad (include) direkt efter ankarraden
#   4. kontrollerar med nginx -t. Misslyckas det återställs allt och nginx laddas inte om.
#   5. laddar om nginx
# Ta bort det igen med: sudo sh ta_bort.sh <konfigurationsfil>
set -eu
cd "$(dirname "$0")"
SITE="${1:?Ange konfigurationsfilen, till exempel /etc/nginx/sites-available/default}"
ANCHOR="${2:?Ange en rad som finns exakt en gång i HTTPS-blocket, till exempel server_name kartor.exempelkommun.se;}"
SNIPPET=/etc/nginx/snippets/planmosaik.conf
LINE="    include $SNIPPET;"
BACKUP="$SITE.bak-planmosaik-$(date +%Y%m%d-%H%M%S)"

[ "$(id -u)" = 0 ] || { echo "Kör med sudo."; exit 1; }
grep -q "snippets/planmosaik.conf" "$SITE" && { echo "Redan installerat (raden finns i $SITE). Ingenting ändrat."; exit 0; }
[ "$(grep -c -F "$ANCHOR" "$SITE")" = 1 ] || { echo "Ankarraden finns inte exakt en gång i $SITE. Avbryter, ingenting ändrat."; exit 1; }

mkdir -p "$(dirname "$SNIPPET")"
cp -p "$SITE" "$BACKUP"
cp planmosaik.conf "$SNIPPET"
# Raden läggs in direkt efter ankarraden
awk -v anchor="$ANCHOR" -v line="$LINE" '{ print } index($0, anchor) { print line }' "$BACKUP" > "$SITE"

if nginx -t; then
    systemctl reload nginx
    echo "Klart. Säkerhetskopia: $BACKUP"
else
    echo "nginx -t misslyckades: återställer."
    cp -p "$BACKUP" "$SITE"
    rm -f "$SNIPPET"
    nginx -t
    exit 1
fi
