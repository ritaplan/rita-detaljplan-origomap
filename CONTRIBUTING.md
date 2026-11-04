# Bidra till integrationen för Origo

Tack för att du vill hjälpa till! Integrationen är ung och all återkoppling är värdefull, särskilt från dig som kör Origo i en
kommun och har en annan miljö än den jag har provat med (andra versioner av Origo, GeoServer, QGIS Server eller PostGIS, eller
ett annat koordinatsystem).

## Rapportera fel eller önska något

Öppna ett ärende under [Issues](https://github.com/ritaplan/rita-detaljplan-origomap/issues) och välj mall. Ange gärna
Origo-version, karttjänst och version, koordinatsystem och vad som syns i webbläsarens konsol och i karttjänstens logg.
**Klistra inte in innehållet i din `.env`, lösenord eller adresser till interna system, och bifoga aldrig en plan med uppgifter
du inte får dela.** Skärmbilder hjälper mycket.

Frågor om Origo i sig hör hemma i [Origos eget repo](https://github.com/origo-map/origo), och frågor om hur planerna ritas
och checkas in i QGIS hör till [Rita Detaljplan](https://github.com/ritaplan/rita-detaljplan).

## Köra och prova koden

Följ [docs/kom-igang.md](docs/kom-igang.md). Kort:

1. `cp .env.exempel .env` och fyll i databas, planschema och koordinatsystem.
2. `sh databas/installera.sh && sh databas/skapa_roll.sh && sh forbered.sh`, sedan `docker compose up -d` och
   `python3 geoserver/konfigurera_geoserver.py`.
3. Behöver du planer att prova med: `testdata/skapa_testschema.py` gör ett testschema ur en demoplan. Det använder
   Rita Detaljplans kod och letar efter repot `rita-detaljplan` bredvid det här; ligger det någon annanstans, sätt
   miljövariabeln `RITA_DETALJPLAN_SOKVAG`.

Repot har **inga automatiska tester än**: en ändring provas för hand mot en riktig Origo-karta och karttjänst, och *Provat
med* i [README](README.md) säger vad som har provats och inte. Bidrag med tester är mycket välkomna.

## Kodstil

- **Texterna som användaren ser är på svenska, koden på engelska** (namn på funktioner och variabler). Kommentarer får vara på
  svenska där de förklarar varför.
- Följ stilen i omgivande kod. Liten och tydlig kod före smart kod.
- **Databasvyerna avgör vad som blir offentligt.** Karttjänsterna läser bara vyerna i schemat `publicering`, med en
  skrivskyddad roll. Ändrar du `databas/publicering.sql`, beskriv i din pull request vad ändringen betyder för vilka planer och
  uppgifter som syns. Se [SECURITY.md](SECURITY.md).
- Allt som kommer ur databasen skrivs som text i panelen, aldrig som HTML.
- Måtten för linjer och mönster finns på två ställen, `stil.py` och en tabell i `origo/planmosaik.js`: ändra båda.
  GeoServers stilar byggs om med `python geoserver/bygg_stilar.py`.
- Lösenord och nycklar hör hemma i `.env`, som aldrig checkas in.

## Pull requests

1. Forka repot och skapa en gren.
2. Prova ändringen enligt ovan. På GitHub körs också kodanalys (CodeQL för JavaScript och Python) och OpenSSF Scorecard; de
   ska vara gröna. Hittar du en säkerhetsbrist: öppna inte ett ärende eller en pull request, utan följ
   [SECURITY.md](SECURITY.md).
3. Beskriv vad ändringen gör och varför, och lägg en rad i [CHANGELOG.md](CHANGELOG.md) under *Ej utgivet*.
4. Öppna en pull request.

Genom att bidra godkänner du att ditt bidrag licensieras under samma licens som projektet (GPL-2.0-or-later).
