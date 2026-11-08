# Ändringslogg

Formatet följer [Keep a Changelog](https://keepachangelog.com/sv/1.1.0/), versionsnumren [Semantic Versioning](https://semver.org/lang/sv/).

## Ej utgivet

- **Dokumentation: CORS för publika lager.** Nytt avsnitt i `docs/kom-igang.md` om hur andra webbappar kan läsa planerna som
  data (WFS/GeoJSON) direkt från karttjänsten: vad CORS är, att det är ofarligt för de publika lagren, hur det slås på i
  GeoServer och att det inte ska slås på för lager med inloggning. Förslag från Martin Wiss, som prövat planerna i
  Dataspatium.
- **Texter:** README kallar lösningen *integrationen för Origo*, som [ritaplan.xyz](https://ritaplan.xyz) och organisationens
  profil. Märket, banderollerna och förhandsbilden är borttagna.
- **Testdata:** `testdata/skapa_testschema.py` letar efter Rita Detaljplans kod i repot `rita-detaljplan` bredvid det här
  (förut ett lokalt mappnamn som ingen annan har). `RITA_DETALJPLAN_SOKVAG` gäller som förut. En gammal sökväg i en kommentar
  i `stil.py` är rättad.
- **Standardfiler och kontroller:** CONTRIBUTING, CHANGELOG och NOTICE, ärendemallar, Dependabot för GitHub Actions och
  automatiska kontroller på GitHub (kodanalys med CodeQL för JavaScript och Python, och OpenSSF Scorecard).

## [0.1.1] – 2026-11-03 – rättningar efter prov i SWEREF 99 TM (EPSG:3006)

Rekommenderas för alla som har sin Origo-karta i ett annat koordinatsystem än Web Mercator, till exempel EPSG:3006.

- **Rättat: informationspanelen i en karta i EPSG:3006** (eller annat koordinatsystem än Web Mercator). Markeringen av planen
  hamnade på fel plats och *Gäller här* hittades aldrig. Bestämmelsernas geometri räknas nu om till kartans koordinatsystem,
  och klickpunkten till Web Mercator när den jämförs med geometrin. Uppdatera `planmosaik-info.js` i din karta.
- **Rättat: byte av koordinatsystem (`PLAN_EPSG`).** `databas/installera.sh` kunde inte köras om med ett annat
  koordinatsystem (databasen avvisade det), och GeoServer behöll lagrens gamla koordinatsystem. Vyerna tas nu bort och skapas
  om, och lagren i GeoServer skapas om när koordinatsystemet ändrats.
- Dokumentation för Origo-kartor i SWEREF 99 TM (`docs/origo.md`), `testdata/kopiera_till_3006.sql` som gör ett testschema i
  ett annat koordinatsystem ur ett befintligt, och en rad i felsökningen om att planerna hamnar fel efter att `PLAN_EPSG`
  ändrats.
- Provat med Origo 2.10.0 i Web Mercator och i EPSG:3006 (bildlagret från GeoServer 3.0.2), med planer i EPSG:3008 och
  EPSG:3006. Inte provat: vektorrutor i en karta i EPSG:3006, QGIS Server i EPSG:3006 och andra lokala zoner än 3008.

**Uppgradera:** `git pull`, `sh databas/installera.sh`, `python3 geoserver/konfigurera_geoserver.py` (skapar om lagren om
`PLAN_EPSG` ändrats), kopiera `origo/planmosaik-info.js` till din karta och starta om QGIS Server om du använder det.

## [0.1.0] – 2026-11-03 – första versionen

- **Plankarta i webbläsaren:** användningsytor i Boverkets färger, egenskapsmönster (prickmark, korsmark, ringprickad mark),
  planområdesgräns, användningsgräns och egenskapsgräns i rätt hierarki. Där två planer ligger kant i kant ritas den delade
  gränsen en gång. Linjer och mönster har referensskala 1:1000 och blir mindre när man zoomar ut.
- **Informationspanel vid klick:** planens uppgifter (namn, beteckning, diarienummer, status i klartext, syfte, datum,
  genomförandetid), handlingar (plankarta och planbeskrivning som knappar), och bestämmelserna i området med motiv. De som
  gäller exakt där man klickade är markerade *Gäller här*, och en knapp hämtar alla bestämmelser i planen. Fungerar på dator
  och telefon.
- **Karttjänster att välja mellan:** GeoServer (bildlager, vektorrutor och WFS) eller QGIS Server (bildlager och WFS). Du
  behöver bara en. Förvalt startar installationen bara GeoServer.
- **Säkert som standard:** tjänsterna läser en skrivskyddad databasroll (`karta_ro`) som bara når schemat `publicering`, du
  bestämmer vilka planstatusar som är offentliga (förvalt *antagen* och *laga kraft*), GeoServers administration släpps inte ut,
  och lösenord slumpas av skripten.
- Databasvyer, skript för GeoServer och QGIS Server, nginx-konfiguration och en exempelkarta, och dokumentation för
  installation, konfiguration, data, felsökning och hur panelen läggs in i en egen Origo-karta.
