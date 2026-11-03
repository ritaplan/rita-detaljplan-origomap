# Felsökning

| Du ser | Orsak och lösning |
|---|---|
| Kartan är tom, inga planer | Är planernas status offentlig (`PUBLIC_STATUSES`, förvalt *antagen* och *laga kraft*)? Är planen incheckad? Kontrollera: `select plan, status from publicering.planmosaik;` som `karta_ro`. |
| Lager i QGIS Server är plötsligt tomma | Starta om: `docker compose restart qgis-server`. QGIS Server behåller anslutningar och cachar projektet, så det måste startas om efter att vyerna byggts om. Gäller också om någon använt `FILTER` mot tjänsten: ett filter blir kvar i processen och tömmer lagret för alla. Använd aldrig `FILTER` mot den publika tjänsten. |
| `too many connections for role "karta_ro"` | Rollen har en gräns (40). GeoServer tar upp till 6 anslutningar och QGIS Server några. Höj gränsen med `ALTER ROLE karta_ro CONNECTION LIMIT 60;` eller starta om tjänsterna. |
| Vektorrutor saknas för vissa områden (404 i webbläsarens nätverksflik) | Planen ligger utanför `PLAN_EXTENT`. Ange kommunens utbredning i `.env`, kör `python3 geoserver/konfigurera_geoserver.py` (den tömmer cachen). 404 för rutor utan planer är ofarligt. |
| Vektorrutorna hoppar vid zoomning | Kartans `resolutions` är avrundade. Använd de exakta värdena i [origo.md](origo.md). |
| Alla vektorrutor ger 404 | Rutnätet räknar rader åt fel håll: `alignBottomLeft` ska vara `false` och `extent` kvadratisk (se [origo.md](origo.md)). |
| Klick gör ingenting | Är `planmosaik-info.js` inläst och `PlanMosaikInfo.init` anropad? Är lagrens `queryable` satta till `false`? Öppna webbläsarens konsol. Finns lagren `planmosaik` och `plan_bestammelser` i tjänsten? |
| Origos egen ruta ("Titel saknas" eller tom) visas | Något lager är `queryable: true`, eller `pinning` är inte avstängt. Se [origo.md](origo.md). |
| Handlingar saknas i panelen | Raden i tabellen *Dokument* i Rita Detaljplan saknar *Länk*, eller länken börjar inte med `http://` eller `https://`. |
| Texten i en bestämmelse innehåller `[...]` | Värdet för variabeln är inte ifyllt i Rita Detaljplan. |
| `Layer(s) not valid` i QGIS Server | Tjänstefilen saknas eller har fel uppgifter: kör `sh forbered.sh`, `sh qgis/bygg_projekt.sh` och starta om. |
| GeoServer startar inte om efter ändring | Titta i loggen: `docker compose logs geoserver`. Tillägget hämtas första gången och kräver internet. |
| `./.env: : not found` | `.env` har Windows-radslut. Spara den med LF-radslut (`dos2unix .env`). |
