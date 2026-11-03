# Kom igång

Så här sätter du upp detaljplanerna i webbkartan, från noll till en publicerad karta. Räkna med en till två timmar första
gången. Du behöver kunna logga in på servern, köra kommandon och ha administratörsrättigheter i databasen.

## Innan du börjar

- **Planerna ligger i PostGIS.** I Rita Detaljplan: *Ny detaljplan*, lagring *PostGIS-databas*. Planerna visas när de
  har checkats in. Schemat (till exempel `detaljplaner`) och planernas koordinatsystem (till exempel EPSG:3006) behöver
  du veta. Det finns en [beskrivning](data.md) av vad ur planerna som visas.
- **Docker och Docker Compose** (version 2) på servern där karttjänsterna ska köra.
- **Databasen ska kunna nås från Docker-behållarna.** Ligger PostGIS i en annan Docker-behållare är det enklast att
  ansluta till samma Dockernätverk. Ligger den på en annan server, ange dess adress. Tillåt anslutning från servern med
  rollen `karta_ro` (skapas nedan) i databasens `pg_hba.conf`.
- **En webbserver framför** (nginx, Apache) som publicerar kartan med HTTPS.
- Ett tips: gör allt i en testmiljö först. Det går att köra hela flödet mot demoplanerna i `testdata/`.

## 1. Hämta repot

```sh
git clone https://github.com/ritaplan/rita-detaljplan-origomap.git
cd rita-detaljplan-origomap
```

## 2. Fyll i inställningarna

```sh
cp .env.exempel .env
nano .env
```

Det du alltid måste ändra:

| Inställning | Vad du anger |
|---|---|
| `PSQL` | Kommandot som kör `psql` som databasens administratör, till exempel `psql -h db.exempelkommun.se -U gisadmin -d gis`, eller `docker exec -i postgis psql -U gisadmin -d gis` om databasen ligger i en behållare med namnet `postgis`. |
| `DB_NETWORK`, `DB_HOST`, `DB_PORT`, `DB_NAME` | Hur karttjänsterna når databasen. För en behållare: dess Dockernätverk (`docker network ls`) och namn. För en extern server: adressen, och lämna nätverket som det är. |
| `PLAN_SCHEMA` | Schemat där Rita Detaljplan lägger planerna. |
| `PLAN_EPSG` | Planernas koordinatsystem, bara siffrorna (3006, 3008 och så vidare). |
| `PLAN_EXTENT` | Kommunens utbredning i det koordinatsystemet: `minx,miny,maxx,maxy`. Ta gärna något för stort. |

Alla inställningar och deras förvalda värden finns i [konfiguration.md](konfiguration.md). Filen `.env` är hemlig:
den checkas aldrig in, och skripten lägger lösenord i den.

## 3. Databasen: vyer och en skrivskyddad roll

```sh
sh databas/installera.sh
sh databas/skapa_roll.sh
```

- `installera.sh` skapar schemat **`publicering`** med fem vyer (se [konfiguration.md](konfiguration.md)). Vyerna väljer
  vilka planer som är offentliga (förvalt: antagna planer och planer med laga kraft) och förbereder det kartan behöver.
  Rita Detaljplans egna tabeller rörs inte.
- `skapa_roll.sh` skapar databasrollen **`karta_ro`** med ett slumpat lösenord som sparas i `.env`. Rollen kan bara läsa
  schemat `publicering`: den kommer inte åt planernas egna tabeller, utkast eller något annat i databasen, och kan inte
  skriva.

Behöver du köra SQL:en för hand finns kommandot i skriptens kommentarer. Skripten kan köras om.

## 4. Lösenord och tjänstefil

```sh
sh forbered.sh
```

Skapar lösenordet för GeoServers administration (i `.env`) och `qgis/pg_service.conf` med databasuppgifterna som QGIS
Server läser (lösenordet står aldrig i QGIS-projektet).

## 5. Starta karttjänsterna

```sh
docker compose up -d
```

Första starten hämtar avbildningarna (GeoServer ungefär 600 MB, QGIS Server ungefär 850 MB) och GeoServer hämtar
tillägget *vectortiles* (2 MB, ur GeoServers officiella nedladdningar) för vektorrutor. Det tar några minuter.
Vill du bara använda en av tjänsterna: ta bort den andra ur `docker-compose.yml` och ur `nginx/web.conf`.

## 6. Ställ in GeoServer

```sh
python3 geoserver/konfigurera_geoserver.py
```

Skapar arbetsytan `planmosaik`, kopplar databasen, publicerar lagren med stilar, lagergruppen `planmosaik_karta` (som
ritar hela plankartan som ett lager) och vektorrutorna. Kan köras om: stilar och utbredning uppdateras.

## 7. Bygg QGIS-projektet

```sh
sh qgis/bygg_projekt.sh
docker compose restart qgis-server
```

Skapar `qgis/planmosaik.qgs` med samma lager och utseende. QGIS Server måste startas om efter att projektet eller
vyerna ändrats.

## 8. Prova exempelkartan

```sh
sh hamta_origo.sh
```

Hämtar Origos färdiga filer (2.10.0, ur Origos GitHub-repo) till `exempelkarta/`. Öppna sedan
`http://127.0.0.1:8090/` (porten är `WEB_PORT` i `.env`). Ligger servern på avstånd, öppna en SSH-tunnel:
`ssh -L 8090:127.0.0.1:8090 din-server` och gå till `http://localhost:8090/`.

Kartan visar de tre lagren (GeoServer WMS, GeoServer vektorrutor och QGIS Server WMS) var för sig, så att du kan jämföra
dem. Zooma in över kommunen och klicka på en plan.

## 9. Publicera på nätet

Karttjänsterna lyssnar bara på `127.0.0.1`. Publicera dem genom din vanliga webbserver, med HTTPS. Med nginx:

1. Lägg in innehållet i [`nginx/varden/planmosaik.conf`](../nginx/varden/planmosaik.conf) i ditt HTTPS-`server`-block, eller
   låt skriptet göra det (det tar en säkerhetskopia, kör `nginx -t` och återställer själv om något går fel):

   ```sh
   sudo sh nginx/varden/installera.sh /etc/nginx/sites-available/default 'server_name kartor.exempelkommun.se;'
   ```

   Andra argumentet är en rad som finns exakt en gång i HTTPS-blocket. Skriptet lägger en `include`-rad efter den.
   Ta bort igen: `sudo sh nginx/varden/ta_bort.sh /etc/nginx/sites-available/default`.
2. Kartan finns sedan på `https://kartor.exempelkommun.se/planmosaik/`.

GeoServers administration (`/geoserver/web`, `/geoserver/rest`) släpps medvetet inte ut: den når du bara via SSH-tunnel
(`ssh -L 8081:127.0.0.1:8081 din-server`, sedan `http://localhost:8081/geoserver/web/`, användare `admin`, lösenordet står
i `.env`).

Vill du lägga detaljplanerna i en redan publicerad Origo-karta i stället för exempelkartan: gå vidare till
[origo.md](origo.md).

## Underhåll

| Du vill | Gör så |
|---|---|
| Se nya eller ändrade planer | Inget. De syns i kartan när planen checkats in (vektorrutor inom en minut). |
| Ändra vilka planer som visas | Ändra `PUBLIC_STATUSES` i `.env`, kör `sh databas/installera.sh` och `docker compose restart qgis-server`. |
| Lägga till en handling | I Rita Detaljplan: tabellen *Dokument*, fyll i *Länk* (https). Se [data.md](data.md). |
| Ändra utseendet | Ändra `stil.py`, kör `python3 geoserver/bygg_stilar.py`, `python3 geoserver/konfigurera_geoserver.py` och `sh qgis/bygg_projekt.sh`, och uppdatera tabellen överst i `origo/planmosaik.js` med samma tal. |
| Uppgradera GeoServer eller QGIS Server | Ändra versionen i `.env`, kör `docker compose pull && docker compose up -d`, och därefter stegen 6 och 7. Pröva i testmiljö först. |
| Uppdatera efter att Rita Detaljplan fått ett nytt schema | Kör `sh databas/installera.sh` och starta om QGIS Server. |

## Ta bort allt

```sh
sudo sh nginx/varden/ta_bort.sh /etc/nginx/sites-available/default   # om du lade in det i nginx
docker compose down -v                                                # behållarna och GeoServers data
```

I databasen (som administratör): `DROP SCHEMA publicering CASCADE; DROP ROLE karta_ro;`. Radera sedan mappen.

## Säkerhet i korthet

- Karttjänsterna använder en roll som bara kan **läsa** schemat `publicering`. Utkast, pågående planer, hjälplager och
  utcheckningslås syns inte.
- Vilka planer som visas bestäms på ett ställe, i vyn `planmosaik` (`PUBLIC_STATUSES`). Kontrollera listan innan du
  publicerar.
- GeoServers administration och REST är bara åtkomliga från servern själv. Lösenordet är slumpat.
- Länkar till handlingar visas bara om de börjar med `http://` eller `https://`.
- Begränsa antalet anrop per IP i din webbserver (se kommentaren i `nginx/varden/planmosaik.conf`).
- Använd aldrig `FILTER` mot den publika QGIS Server: se [felsokning.md](felsokning.md).
