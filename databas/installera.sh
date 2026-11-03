#!/bin/sh
# Skapar publiceringsvyerna (schemat publicering) i databasen. Kan köras om, till exempel efter en ändring i
# publicering.sql: vyerna byggs då om. Starta sedan om QGIS Server: docker compose restart qgis-server.
#
#   sh databas/installera.sh      (efter att .env fyllts i)
#
# Kommandot som körs mot databasen står i .env som PSQL (se .env.exempel).
set -eu
cd "$(dirname "$0")/.."
[ -f .env ] || { echo "Det finns ingen .env. Kopiera .env.exempel och fyll i den: cp .env.exempel .env"; exit 1; }
# shellcheck disable=SC1091
. ./.env
: "${PSQL:?PSQL saknas i .env}"
: "${PLAN_SCHEMA:?PLAN_SCHEMA saknas i .env}"
: "${PLAN_EPSG:?PLAN_EPSG saknas i .env}"

# shellcheck disable=SC2086
$PSQL -v ON_ERROR_STOP=1 -v "plan_schema=$PLAN_SCHEMA" -v "srid=$PLAN_EPSG" -v "statuses=${PUBLIC_STATUSES:-'antagen','laga kraft'}" \
    -q -f - < databas/publicering.sql
echo "Publiceringsvyerna är skapade i schemat publicering."
