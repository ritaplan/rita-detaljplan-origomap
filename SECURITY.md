# Säkerhet

Det här repot sätter upp karttjänster (GeoServer, QGIS Server) som visar kommunens detaljplaner i en webbkarta, direkt ur
plandatabasen. Därför handlar säkerheten om vad som blir åtkomligt utifrån och vad databasen släpper ut. Hur det är byggt
för att begränsa det beskrivs i [docs/kom-igang.md](docs/kom-igang.md#säkerhet-i-korthet).

I korthet:

- Karttjänsterna läser en **skrivskyddad databasroll** (`karta_ro`) som bara når schemat `publicering`: vyer med de planer
  som kommunen valt att göra offentliga. Planverktygets egna tabeller, utkast och övrigt i databasen når de inte.
- GeoServers administration och REST-gränssnitt släpps inte ut: de når du bara från servern själv.
- Tjänsterna lyssnar bara på `127.0.0.1` och publiceras genom din egen webbserver, med HTTPS.
- Lösenord slumpas av skripten och ligger bara i `.env`, som aldrig checkas in.
- Informationspanelen skriver allt som kommer ur databasen som text, aldrig som HTML.
- På GitHub körs automatisk kodanalys (CodeQL för JavaScript och Python) och OpenSSF Scorecard, och Dependabot håller de
  fastlåsta versionerna av GitHub Actions uppdaterade. De ersätter inte en oberoende granskning.

Kontrollera själv, innan du publicerar, att listan över offentliga planstatusar (`PUBLIC_STATUSES`) är den du vill.

## Rapportera en säkerhetsbrist

Beskriv inte säkerhetsbrister i ett öppet ärende. Använd i stället GitHubs
[privata rapportering](https://github.com/ritaplan/rita-detaljplan-origomap/security/advisories/new) (fliken *Security* →
*Report a vulnerability*). Då syns rapporten bara för dig och underhållaren. Skriv gärna:

- vad du gjorde och i vilken version av repot (commit) och av GeoServer, QGIS Server och Origo,
- vad som hände och vad du hade väntat dig,
- om du har ett exempel som visar felet (ta bort uppgifter du inte får dela).

**Vad du kan vänta dig:** repot underhålls av en enskild person på fritiden. Målet är att bekräfta rapporten inom
**14 dagar** och att ha en rättning eller en plan inom 60 dagar för det som är allvarligt.

## Vad som räknas

Som säkerhetsbrist räknas till exempel att en besökare kan läsa uppgifter som inte är offentliga (planer med fel status,
andra tabeller i databasen), nå GeoServers administration, få skript att köra, eller att text ur databasen kan tolkas som
HTML eller kod i informationspanelen. Att GeoServer, QGIS Server, Origo, PostGIS eller Docker själva har en sårbarhet räknas
inte hit: rapportera det till respektive projekt och uppdatera versionen (se
[underhåll i kom-igang.md](docs/kom-igang.md#underhåll)).

## Stödda versioner

Bara den senaste versionen på `main` får rättningar.
