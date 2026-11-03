# Inställningar och uppbyggnad

## `.env`

Alla inställningar står i `.env` (kopierad från [`.env.exempel`](../.env.exempel), som har förklaringar på varje rad).

| Inställning | Förvalt | Betydelse |
|---|---|---|
| `PSQL` | – | Kommandot som kör `psql` som databasens administratör (läser SQL från stdin). Används av `databas/`-skripten. |
| `DB_NETWORK` | `postgis_default` | Dockernätverket där databasen nås. |
| `DB_HOST`, `DB_PORT`, `DB_NAME` | `postgis`, `5432`, `gis` | Databasen, så som karttjänsterna når den. |
| `DB_SSLMODE` | `require` | `require` eller `disable`. |
| `PLAN_SCHEMA` | `detaljplaner` | Schemat där Rita Detaljplan lägger planerna. |
| `PLAN_EPSG` | `3006` | Planernas koordinatsystem (siffrorna). |
| `PLAN_EXTENT` | – | `minx,miny,maxx,maxy` i planernas koordinatsystem. Vektorrutor levereras bara inom den. |
| `PUBLIC_STATUSES` | `'antagen','laga kraft'` | Vilka planstatusar som är offentliga (SQL-lista). |
| `COMPOSE_PROFILES` | tomt | Utöver GeoServer: `qgis` (QGIS Server), `exempel` (exempelmiljöns webbserver). |
| `WEB_CONF`, `WEB_ROOT` | `web.conf`, `./exempelkarta` | Exempelmiljöns webbserver: konfiguration och vilken Origo-karta den visar. |
| `WEB_PORT`, `GEOSERVER_ADMIN_PORT` | `8090`, `8081` | Portar på `127.0.0.1`. Din webbserver skickar `/geoserver/` till den senare. |
| `GEOSERVER_IMAGE`, `QGIS_SERVER_IMAGE` | se filen | Versioner. |
| `GEOSERVER_MEMORY`, `GEOSERVER_JAVA_OPTS`, `QGIS_SERVER_MEMORY` | 1g, `-Xmx640m`, 512m | Minne. |
| `KARTA_RO_PASSWORD`, `GEOSERVER_ADMIN_PASSWORD` | skapas | Läggs till av skripten. Skriv dem inte själv. |

Värden med blanksteg skrivs inom dubbla citationstecken. Filen läses både av `docker compose` och som skalskript: använd bara
rader av typen `NAMN=värde`, med LF-radslut.

## Vyerna i schemat `publicering`

| Vy | Innehåll | Används till |
|---|---|---|
| `planmosaik` | Planområden med plandata: namn, beteckning, kommun, syfte, status, datum, genomförandetid, `visningsstatus`, `handlingar` (JSON). **Bestämmer vilka planer som är offentliga.** | Informationspanelen, och grund för övriga vyer. |
| `plan_anvandning` | Användningsytor med Boverkets färg (`fyllfarg`) och plandata. | Ritning, fyllningar. |
| `plan_egenskap` | Egenskapsytor med mönster (`monster`). | Ritning, mönster. |
| `plan_gransar` | Planområdes-, användnings- och egenskapsgränser, i rätt hierarki. En gräns som delas av två planer ritas en gång. | Ritning, linjer. |
| `plan_bestammelser` | En rad per bestämmelse i varje användningsyta: text med variabler ifyllda, motiv, mönster och bestämmelsens egen geometri som GeoJSON. | Informationspanelen. |

Vyerna räknas om vid varje anrop. Är kommunen stor (många hundra planer) kan de göras om till materialiserade vyer
(`CREATE MATERIALIZED VIEW ... AS <samma fråga>`, med index, och `REFRESH MATERIALIZED VIEW` efter varje incheckning, till
exempel med ett cron-jobb). Starta om QGIS Server efter att vyerna byggts om.

## Utseendet: `stil.py`

Linjebredder, streckmönster och mönster anges i pixlar vid **referensskalan 1:1000** och skalas med kartskalan i band, med
en minsta bredd och med bortfall av detaljer som blivit för små. Alla ändringar görs i `stil.py`:

| Vill du ändra | Gör så |
|---|---|
| Linjer eller mönster | Ändra `LINES` eller `PATTERNS` i `stil.py`. |
| GeoServers stilar | `python3 geoserver/bygg_stilar.py`, sedan `python3 geoserver/konfigurera_geoserver.py`. |
| QGIS-projektet | `sh qgis/bygg_projekt.sh`, sedan `docker compose restart qgis-server`. |
| Vektorrutorna i Origo | Samma tal står i tabellen överst i `origo/planmosaik.js`: ändra den med. |
| Färger för användning | Färgerna sätts i vyn `plan_anvandning` (Boverkets färgnamn till hex): ändra CASE-satsen i `databas/publicering.sql`. |

## Informationspanelen

Alternativ till `PlanMosaikInfo.init(viewer, { ... })`:

| Alternativ | Betydelse |
|---|---|
| `infoUrl` | WMS-adressen för arbetsytan (GeoServer: `.../geoserver/planmosaik/wms`). Obligatoriskt. |
| `wfsUrl` | WFS-adressen (`.../geoserver/planmosaik/ows`). Utan den visas inte knappen "Visa alla bestämmelser i planen". |
| `layers` | Lagren som frågas (förvalt `plan_bestammelser,planmosaik`). |

Färgerna ändras med CSS-variablerna överst i `origo/planmosaik-info.css`.

## GeoServer och QGIS Server

- **GeoServer:** arbetsyta `planmosaik`, datakälla `publicering`, lager `plan_anvandning`, `plan_egenskap`, `plan_gransar`
  (ritas) och `planmosaik`, `plan_bestammelser` (bara frågas), lagergruppen `planmosaik_karta` (ritar de tre första i rätt
  ordning). Vektorrutorna ligger i GeoServers cache (GeoWebCache, gridset EPSG:900913) och förnyas efter en minut.
  Administrationen når du på `127.0.0.1:GEOSERVER_ADMIN_PORT` (SSH-tunnel), användare `admin`.
- **QGIS Server:** projektet `qgis/planmosaik.qgs` med samma lager i gruppen `planmosaik_karta`. Databasuppgifterna står i
  `qgis/pg_service.conf`, aldrig i projektet.
