#!/bin/sh
# Förbereder det som docker-compose.yml behöver: lösenordet för GeoServers administration och databasuppgifterna som
# QGIS Server läser. Kan köras om: det som redan finns lämnas orört (tjänstefilen skrivs om ur .env).
#
#   sh forbered.sh      (kör i mappen med docker-compose.yml, efter att .env fyllts i och databas/skapa_roll.sh körts)
set -eu
cd "$(dirname "$0")"
umask 077

[ -f .env ] || { echo "Det finns ingen .env. Kopiera .env.exempel och fyll i den: cp .env.exempel .env"; exit 1; }
grep -q '^KARTA_RO_PASSWORD=' .env || { echo "Kör databas/skapa_roll.sh först (den skapar databasrollen och lösenordet)."; exit 1; }
grep -q '^GEOSERVER_ADMIN_PASSWORD=' .env || \
    printf 'GEOSERVER_ADMIN_PASSWORD=%s\n' "$(head -c 24 /dev/urandom | base64 | tr -d '/+=' | cut -c1-24)" >> .env

# Inställningarna ur .env (utan att köra något i dem): värdena läses rad för rad
get() { sed -n "s/^$1=//p" .env | tail -1 | sed "s/^['\"]//; s/['\"]$//"; }
HOST=$(get DB_HOST); PORT=$(get DB_PORT); NAME=$(get DB_NAME); SSL=$(get DB_SSLMODE); PW=$(get KARTA_RO_PASSWORD)

mkdir -p qgis exempelkarta
chmod 755 qgis exempelkarta
# Filen läses av QGIS Server i behållaren och måste därför vara läsbar för den.
cat > qgis/pg_service.conf <<EOT
[planmosaik]
host=${HOST:-postgis}
port=${PORT:-5432}
dbname=${NAME:-gis}
user=karta_ro
password=$PW
sslmode=${SSL:-require}
EOT
chmod 644 qgis/pg_service.conf
echo "Klart."
