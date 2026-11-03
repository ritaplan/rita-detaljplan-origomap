#!/bin/sh
# Skapar databasrollen karta_ro: bara läsrätt på publiceringsvyerna (schemat publicering), inget annat.
# Lösenordet slumpas och sparas i .env (läsbar bara för dig). Det skrivs aldrig ut.
#
#   sh databas/skapa_roll.sh     (efter att .env fyllts i och databas/publicering.sql körts)
#
# Kommandot som körs mot databasen står i .env som PSQL (se .env.exempel).
set -eu
cd "$(dirname "$0")/.."
[ -f .env ] || { echo "Det finns ingen .env. Kopiera .env.exempel och fyll i den: cp .env.exempel .env"; exit 1; }
# shellcheck disable=SC1091
. ./.env
: "${PSQL:?PSQL saknas i .env}"
: "${DB_NAME:?DB_NAME saknas i .env}"

if grep -q '^KARTA_RO_PASSWORD=' .env; then
    echo "Rollen finns redan (lösenordet ligger i .env). Ingenting ändrat."
    exit 0
fi

PW=$(head -c 24 /dev/urandom | base64 | tr -d '/+=' | cut -c1-24)
umask 077
# Lösenordet går via stdin och syns inte i processlistan.
# shellcheck disable=SC2086
$PSQL -v ON_ERROR_STOP=1 -q <<SQL
CREATE ROLE karta_ro LOGIN PASSWORD '$PW' CONNECTION LIMIT 40;
ALTER ROLE karta_ro SET default_transaction_read_only = on;
ALTER ROLE karta_ro SET statement_timeout = '30s';
GRANT CONNECT ON DATABASE "$DB_NAME" TO karta_ro;
GRANT USAGE ON SCHEMA publicering TO karta_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA publicering TO karta_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA publicering GRANT SELECT ON TABLES TO karta_ro;
SQL
printf 'KARTA_RO_PASSWORD=%s\n' "$PW" >> .env
echo "Rollen karta_ro är skapad (lösenordet ligger i .env)."
