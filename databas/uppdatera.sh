#!/bin/sh
# Uppdaterar de förberäknade gränslinjerna (plan_gransar). Kör det efter att planer checkats in, ändrats eller fått ny status,
# till exempel med cron (se docs/kom-igang.md). Kartan visar de gamla linjerna tills det är gjort, men inget går sönder.
#
#   sh databas/uppdatera.sh
#
# Kommandot som körs mot databasen står i .env som PSQL (se .env.exempel).
set -eu
cd "$(dirname "$0")/.."
[ -f .env ] || { echo "Det finns ingen .env. Kopiera .env.exempel och fyll i den: cp .env.exempel .env"; exit 1; }
# shellcheck disable=SC1091
. ./.env
: "${PSQL:?PSQL saknas i .env}"

# CONCURRENTLY: kartan kan läsa de gamla linjerna medan de nya räknas ut
# shellcheck disable=SC2086
$PSQL -v ON_ERROR_STOP=1 -q -c "REFRESH MATERIALIZED VIEW CONCURRENTLY publicering.plan_gransar_mat"
echo "Gränslinjerna är uppdaterade."
