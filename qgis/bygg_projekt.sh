#!/bin/sh
# Bygger QGIS-projektet (qgis/planmosaik.qgs) som QGIS Server publicerar. Körs när vyerna är skapade och när stilen
# (stil.py) ändrats, och därefter måste QGIS Server startas om: docker compose restart qgis-server
#
#   sh qgis/bygg_projekt.sh        (efter databas/installera.sh och forbered.sh)
set -eu
cd "$(dirname "$0")/.."
[ -f .env ] || { echo "Det finns ingen .env."; exit 1; }
# shellcheck disable=SC1091
. ./.env
: "${DB_NETWORK:?}" "${QGIS_SERVER_IMAGE:?}" "${PLAN_EPSG:?}"
cp stil.py qgis/stil.py  # behållaren ser bara mappen qgis/
docker run --rm --memory 700m --network "$DB_NETWORK" -v "$PWD/qgis:/io/data" \
    -v "$PWD/qgis/pg_service.conf:/etc/postgresql-common/pg_service.conf:ro" \
    -e QT_QPA_PLATFORM=offscreen -e PYTHONPATH=/usr/share/qgis/python:/usr/lib/python3/dist-packages \
    "$QGIS_SERVER_IMAGE" python3 /io/data/skapa_qgis_projekt.py "$PLAN_EPSG" 2>&1 | grep -v QThreadStorage
