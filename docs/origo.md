# Lägg in detaljplanerna i din Origo-karta

Det här gör du i en Origo-karta (2.x) som du redan har. Du behöver kunna redigera kartans `index.html` och `index.json`.
Tjänsterna (GeoServer och/eller QGIS Server) ska vara igång enligt [kom-igang.md](kom-igang.md).

## 1. Välj variant

| Variant | Passar när | Läser från |
|---|---|---|
| **A. GeoServer, bilder (WMS)** | Du vill ha det enkla och robusta. Ritas på servern, ser likadant ut överallt, går att läsa i QGIS Desktop. | GeoServer |
| **B. GeoServer, vektorrutor** | Du har många planer eller vill ha skarp linjeritning vid alla zoomnivåer. Kräver att kartan går i Web Mercator (EPSG:3857). | GeoServer |
| **C. QGIS Server, bilder (WMS)** | Du kör redan QGIS Server och vill slippa GeoServer. | QGIS Server |

Alla tre visar samma karta. Informationspanelen (steg 4) fungerar med alla.

## 2. Kopiera filerna

Kopiera mappen `origo/` från det här repot till din webbplats, till exempel som `detaljplaner/`, så att den ligger bredvid
din `index.html`. Du behöver `planmosaik-info.js`, `planmosaik-info.css` och för variant B även `planmosaik.js`.

Lägg i din `index.html`, efter raden som läser in Origo (`origo.min.js`):

```html
<link href="detaljplaner/planmosaik-info.css" rel="stylesheet">
<script src="detaljplaner/planmosaik.js"></script>        <!-- bara variant B -->
<script src="detaljplaner/planmosaik-info.js"></script>
```

Och efter `var origo = Origo('index.json');`:

```js
origo.on('load', function (viewer) {
  PlanMosaikInfo.init(viewer, {
    infoUrl: 'https://kartor.exempelkommun.se/geoserver/planmosaik/wms',  // WMS i arbetsytan planmosaik
    wfsUrl: 'https://kartor.exempelkommun.se/geoserver/planmosaik/ows'    // valfritt: knappen "Alla bestämmelser i planen"
  });
});
```

Byt adresserna mot din server (eller använd relativa adresser om kartan och tjänsterna ligger på samma webbplats, vilket är
det enklaste: `geoserver/planmosaik/wms`). Panelen läser alltid uppgifterna ur GeoServer. Kör du bara QGIS Server, ange dess
adress och ta bort `wfsUrl`: lagren `planmosaik` och `plan_bestammelser` måste då läggas in i QGIS-projektet.

## 3. Lägg in ett lager i `index.json`

Färdiga exempel för alla tre varianter finns i [`origo/lager.exempel.json`](../origo/lager.exempel.json). Byt adresserna.
Lagret ska heta **Detaljplaner** i menyn: det är `title`. Lägg lagret i den grupp du vill (`group`).

**Alla tre varianter:** sätt `"queryable": false`. Informationspanelen sköter klicken, och Origos egen informationsruta ska
vara avstängd. Lägg även `"pinning": false` i `featureinfoOptions`:

```json
"featureinfoOptions": { "infowindow": "overlay", "pinning": false }
```

**A. GeoServer WMS**

```json
"source": { "detaljplaner_geoserver": { "url": "https://kartor.exempelkommun.se/geoserver/planmosaik/wms" } },
"layers": [ {
  "name": "detaljplaner", "id": "planmosaik_karta", "title": "Detaljplaner", "group": "root",
  "source": "detaljplaner_geoserver", "type": "WMS", "format": "image/png", "tiled": false,
  "visible": true, "queryable": false
} ]
```

**C. QGIS Server WMS:** samma lager, men `"source"` pekar på `https://kartor.exempelkommun.se/qgis/` (QGIS Servers
`/ows/`-adress). Lagernamnet `id` är fortfarande `planmosaik_karta`.

**B. GeoServer vektorrutor**

```json
"source": { "detaljplaner_rutor": { "url": "https://kartor.exempelkommun.se/geoserver/gwc/service/tms/1.0.0/" } },
"layers": [ {
  "name": "detaljplaner", "title": "Detaljplaner", "group": "root", "source": "detaljplaner_rutor",
  "type": "VECTORTILE", "format": "pbf", "layerName": "planmosaik:planmosaik_karta", "gridset": "EPSG:900913",
  "style": "detaljplaner", "visible": true, "queryable": false,
  "tileGrid": { "alignBottomLeft": false, "extent": [-20037508.342789244, -20037508.342789244, 20037508.342789244, 20037508.342789244],
                "resolutions": [ ...kartans resolutions, se nedan... ], "tileSize": [256, 256] }
} ],
"styles": { "detaljplaner": [ [ { "custom": { "type": "planmosaik", "name": "planmosaik", "file": "", "source": "" } } ] ] }
```

Variant B kräver tre saker i kartan, annars hoppar eller saknas rutorna:

1. **Kartan går i EPSG:3857** (`"projectionCode": "EPSG:3857"`).
2. **Exakta upplösningar.** Origos exempel har avrundade värden (`9.5546` i stället för `9.554628…`), och med dem hamnar
   vektorrutorna fel och "hoppar" vid zoomning. Använd samma lista i kartans `resolutions` och i lagrets `tileGrid`:

   ```
   156543.03392804097, 78271.51696402048, 39135.75848201024, 19567.87924100512, 9783.93962050256, 4891.96981025128,
   2445.98490512564, 1222.99245256282, 611.49622628141, 305.748113140705, 152.8740565703525, 76.43702828517625,
   38.21851414258813, 19.109257071294063, 9.554628535647032, 4.777314267823516, 2.388657133911758, 1.194328566955879,
   0.5971642834779395, 0.29858214173896974, 0.14929107086948487
   ```
3. **`alignBottomLeft: false`** och den kvadratiska `extent` ovan, så att Origos `{-y}` blir den radnumrering som
   GeoServers cache vill ha.

Stilen för vektorrutorna (färger, mönster, streckmönster) ligger i `planmosaik.js`, som registrerar stiltypen `planmosaik`.
Origos färdiga fil saknar tillägget `olms`, därför behövs den.

### Ikon i lagerlistan (varianterna A och C)

Origo hämtar ikonen för ett bildlager (WMS) ur kartservens teckenförklaring, som för detaljplaner bara blir några små prickar.
Vill du ha en egen ikon, kopiera [`ikon-detaljplaner.svg`](../origo/ikon-detaljplaner.svg) (den följer med mappen `origo/`)
och lägg in en stil i `index.json` som heter som lagret plus `_WMSServerDefault`. Heter lagret `detaljplaner`:

```json
"styles": {
  "detaljplaner_WMSServerDefault": [ [ { "icon": { "src": "detaljplaner/ikon-detaljplaner.svg" }, "extendedLegend": false } ] ]
}
```

Sökvägen är relativ till `index.html`. Ikonen kan ritas om fritt: den visas i ungefär 36 px.

## Karta i SWEREF 99 TM

Många kommuner har sin Origo-karta i SWEREF 99 TM (EPSG:3006). Det fungerar med bildlagren (variant A och C): GeoServer ritar
planerna i kartans koordinatsystem, vilket det än är, och informationspanelen räknar om markeringen och klickpunkten själv.
Vektorrutorna (variant B) kräver Web Mercator. Ändra kartans `index.json` så här (resten är som ovan):

```json
"projectionCode": "EPSG:3006",
"projectionExtent": [-1200000, 4700000, 2600000, 8500000],
"extent": [-1200000, 4700000, 2600000, 8500000],
"resolutions": [4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1, 0.5, 0.25, 0.125],
"proj4Defs": [{ "code": "EPSG:3006", "projection": "+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs" }]
```

Bakgrundskartor i Web Mercator (till exempel OpenStreetMap) ritas om i webbläsaren och fungerar. Planernas koordinatsystem och
kartans är två skilda saker: planerna kan ligga i EPSG:3008 och kartan gå i EPSG:3006, eller tvärtom.

## 4. Informationspanelen

Ett klick på en plan öppnar panelen: status, handlingar, syfte och bestämmelser med motiv. Den kräver:

- att lagren `planmosaik` och `plan_bestammelser` är publicerade i din karttjänst (`konfigurera_geoserver.py` gör det),
- att anrop till `infoUrl` och `wfsUrl` får göras från din karta. Ligger kartan och tjänsterna på **samma webbplats**
  (via din webbserver) behövs inget mer. Ligger de på olika adresser måste tjänsten tillåta det (CORS): i GeoServer
  `CORS_ENABLED=true` i `docker-compose.yml`. Vill du att även *andra* webbappar ska kunna läsa planerna som data: se
  [Låt andra webbappar läsa planerna](kom-igang.md#låt-andra-webbappar-läsa-planerna-cors-valfritt).

Utseendet styrs av CSS-variablerna överst i `planmosaik-info.css` (färger) och texterna står i `planmosaik-info.js`.

## Begränsningar och goda råd

- Origo 2.10 kan inte fråga vektorrutor (ett klick på en yta i en vektorruta ger ett fel i Origo). Därför är lagret
  `queryable: false` och panelen frågar kartservern i stället. Det syns inte för användaren.
- Lagret `planmosaik_karta` i GeoServer är en lagergrupp (användning, egenskaper och gränser i rätt ordning). I QGIS Server
  är det en grupp med samma namn.
- Linjebredder och mönster följer kartans skala (referensskala 1:1000). Ändrar du dem, ändra `stil.py` och tabellen överst
  i `planmosaik.js` med samma tal.
- Kartans bakgrund (till exempel OpenStreetMap eller Lantmäteriets) har du själv. Planerna ritas halvtransparent över den.
