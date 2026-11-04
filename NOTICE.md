# Källor och material från andra

Integrationen är licensierad under GPL-2.0-or-later (se [LICENSE](LICENSE)). Följande kommer från andra och har egna villkor.
Kontrollera villkoren själv om du sprider eller bygger vidare på repot.

| Material | Var | Källa | Villkor |
|---|---|---|---|
| Origo, kartklienten | hämtas av `hamta_origo.sh` till exempelkartan (`build/`) och ingår **inte** i repot | [origo-map/origo](https://github.com/origo-map/origo) | BSD-2-Clause (enligt Origos `package.json`). |
| GeoServer, QGIS Server och nginx | Docker-avbildningar som hämtas när du kör `docker compose`; ingår **inte** i repot | `docker.osgeo.org/geoserver`, `qgis/qgis-server`, `nginx` | GPL-2.0 (GeoServer), GPL-2.0-or-later (QGIS Server) och BSD-2-Clause (nginx). Avbildningarna har även andra paket med egna licenser. |
| PostgreSQL och PostGIS | används, ingår **inte** i repot | [PostgreSQL](https://www.postgresql.org/) och [PostGIS](https://postgis.net/) | PostgreSQL-licensen respektive GPL-2.0-or-later. |
| Färger, mönster och linjemått för planerna | `stil.py`, `geoserver/*.sld`, `origo/planmosaik.js` | Boverkets föreskrifter om planbestämmelser (BFS 2020:6), så som Rita Detaljplans symbologi tolkar dem | Egen tolkning av en offentlig föreskrift. Se Rita Detaljplans NOTICE. |
| Skärmbilder | `docs/images/` | Kartbakgrunden är OpenStreetMap. Planerna är Rita Detaljplans påhittade demoplaner. | © OpenStreetMap-bidragsgivare, [ODbL 1.0](https://www.openstreetmap.org/copyright). |

Ikonen för lagret (`origo/ikon-detaljplaner.svg`), demoplanerna och testhandlingarna (`testdata/`) är egna.

Integrationen är **inte** en del av Origo-projektet och inte en officiell produkt från Origo, Lantmäteriet eller Boverket.
