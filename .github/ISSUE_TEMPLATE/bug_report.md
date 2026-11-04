---
name: Fel
about: Något fungerar inte som det ska
title: ""
labels: bug
---

**Vad hände?**
Beskriv felet och vad du förväntade dig. Säg också var det går fel: installationen (databas, GeoServer eller QGIS Server),
lagret i kartan eller informationspanelen vid klick.

**Så återskapar man det**
1.
2.
3.

**Miljö**
- Version av integrationen (tagg, till exempel v0.1.1, eller commit):
- Origo-version (till exempel 2.10.0):
- Karttjänst och version: GeoServer / QGIS Server
- PostgreSQL och PostGIS-version:
- Docker och Docker Compose-version (om du kör dem):
- Planernas och kartans koordinatsystem: Web Mercator (EPSG:3857) / SWEREF 99 TM (EPSG:3006) / annat
- Hur planerna visas: bildlager (WMS) / vektorrutor
- Webbläsare och enhet:

**Felmeddelande eller skärmbild**
Klistra in texten, eller bifoga en bild. Webbläsarens konsol (F12, fliken *Console*), nätverksfliken (anropen till
karttjänsten) och loggen från karttjänsten hjälper mycket (`docker compose logs geoserver`).

_Klistra inte in innehållet i din `.env`, lösenord, nycklar eller adresser till interna system. Bifoga inte planer med uppgifter
du inte får dela._
