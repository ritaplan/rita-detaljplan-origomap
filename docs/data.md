# Vad som visas, och hur det kopplas

Allt kommer ur de tabeller Rita Detaljplan skriver i PostGIS-schemat (`PLAN_SCHEMA`). Kartan läser dem via vyerna i schemat
`publicering` (se [konfiguration.md](konfiguration.md)). Inget kopieras: ändrar du en plan i Rita Detaljplan och checkar in
den, ser besökarna det.

## Vilka planer som är offentliga

En plan visas när dess **status** står i listan `PUBLIC_STATUSES` i `.env`. Förvalt:

- `antagen`: antagen men ännu inte laga kraft (visas som "Antagen", gul)
- `laga kraft`: gällande (visas som "Gällande", med genomförandetidens läge: pågår eller har gått ut)

Andra statusar (påbörjad, samråd, granskning, överklagad, tillsyn, upphävd, avslutad) visas inte. Vill du visa fler, lägg
till dem i listan och kör `sh databas/installera.sh`. Kontrollera listan innan du publicerar: planer som inte är beslutade
ska normalt inte ligga öppet.

## Vad i planen som blir vad

| I Rita Detaljplan | I kartan |
|---|---|
| Planområdet (*Detaljplan*) | Planområdesgräns (tjock streckprickad linje), och rubrik och uppgifter i panelen: namn, beteckning, kommun, syfte, status. |
| *Beslutsinformation* | Datum för antagande och laga kraft, genomförandetid och diarienummer i panelen. Genomförandetidens slut räknas ut från första datumet för laga kraft. |
| Användningsytor och deras bestämmelser | Färgade ytor (Boverkets färger), användningsgräns, och bestämmelserna under "Användning" i panelen. |
| Egenskapsytor, -linjer och -punkter | Mönster (prickmark, korsmark, ringprickad mark), egenskapsgräns, och bestämmelserna under "Egenskaper" i panelen. |
| Bestämmelsernas **motiv** | Visas under varje bestämmelse. Saknas motiv står "Inget motiv är angivet". |
| *Dokument* | Knappar och länkar i panelen (se nedan). |

Bestämmelsens text visas med variablerna ifyllda (till exempel "Byggnadshöjd 7,5 m"). Ett värde som inte är ifyllt visas som
`[namn:typ]`.

## Handlingar: plankarta och planbeskrivning

Tabellen *Dokument* i Rita Detaljplan har en kolumn **Länk** (https). Dokumenten visas i panelen så här:

- Raden med *Innehåll* = `plankarta` blir den första knappen, **Plankarta**.
- Raden med *Roll* = `planbeskrivning` blir den andra knappen, **Planbeskrivning**.
- Övriga rader (beslutshandlingar, planeringsunderlag) hamnar under **Övriga handlingar**.
- Rader utan länk, eller med en länk som inte börjar med `http://` eller `https://`, visas inte.

Filerna ligger där kommunen vanligtvis har dem (e-tjänst, diarium, webbplats): kartan länkar bara dit. Länkarna öppnas i en
ny flik.

## Bestämmelserna i området

Ett klick hittar användningsytan där du klickade och visar:

1. **Användning:** användningsytans egna bestämmelser.
2. **Egenskaper där du klickade:** egenskapsytor som täcker exakt klickpunkten, märkta "Gäller här". Egenskapslinjer och
   -punkter ligger i området men täcker ingen yta, så de visas bland övriga.
3. **Övriga egenskaper i området:** egenskaper som ligger inom samma användningsyta men inte där du klickade, bakom en rubrik
   som fälls ut.

Knappen **Visa alla bestämmelser i planen** hämtar planens samtliga bestämmelser, grupperade per område.

## Vad som inte publiceras

Karttjänsterna når bara schemat `publicering`. Därför syns aldrig hjälplager (hjälplinjer, hjälpytor, hjälppunkter),
utcheckningslås, planernas arbetsmetadata, planer med annan status än de offentliga, eller något annat i databasen.

## Om Rita Detaljplan uppdateras

Vyerna bygger på Rita Detaljplans tabeller (schemaversion 11). Ändras tabellerna i en ny version, kör
`sh databas/installera.sh` och starta om QGIS Server. Fungerar inte en vy efter en uppdatering: se
[felsokning.md](felsokning.md).
