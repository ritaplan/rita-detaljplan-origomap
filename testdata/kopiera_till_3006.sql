-- Kopierar ett testschema (till exempel demoplanerna i SWEREF 99 13 30, EPSG:3008) till ett nytt schema med geometrierna
-- omräknade till ett annat koordinatsystem (förvalt SWEREF 99 TM, EPSG:3006), för att prova hela kedjan där.
--
--   psql -v ON_ERROR_STOP=1 -v fran=detaljplaner_test -v till=detaljplaner_test3006 -v epsg=3006 -f kopiera_till_3006.sql
--
-- Tabellerna kopieras med LIKE (kolumner och standardvärden) och data rad för rad. Geometrikolumnerna görs först om till
-- okonstruerade, räknas om med ST_Transform och får sedan sin typ och sitt nya koordinatsystem. Raden "epsg" i dp_schema
-- sätts till det nya värdet. Schemat "till" får inte finnas sedan tidigare.
CREATE SCHEMA :"till";
-- psql byter inte ut variabler inuti $$ ... $$: de förs över som sessionsinställningar
SELECT set_config('kopiera.fran', :'fran', false), set_config('kopiera.till', :'till', false),
       set_config('kopiera.epsg', :'epsg', false) \gset

DO $$
DECLARE
  t record;
  g record;
  fran text := current_setting('kopiera.fran');
  till text := current_setting('kopiera.till');
  epsg int := current_setting('kopiera.epsg')::int;
BEGIN
  FOR t IN SELECT table_name FROM information_schema.tables WHERE table_schema = fran AND table_type = 'BASE TABLE' LOOP
    EXECUTE format('CREATE TABLE %I.%I (LIKE %I.%I INCLUDING DEFAULTS)', till, t.table_name, fran, t.table_name);
    FOR g IN SELECT f_geometry_column AS col FROM geometry_columns
             WHERE f_table_schema = fran AND f_table_name = t.table_name LOOP
      EXECUTE format('ALTER TABLE %I.%I ALTER COLUMN %I TYPE geometry', till, t.table_name, g.col);
    END LOOP;
    EXECUTE format('INSERT INTO %I.%I SELECT * FROM %I.%I', till, t.table_name, fran, t.table_name);
    FOR g IN SELECT f_geometry_column AS col, type FROM geometry_columns
             WHERE f_table_schema = fran AND f_table_name = t.table_name LOOP
      EXECUTE format('UPDATE %I.%I SET %I = ST_Transform(%I, %s)', till, t.table_name, g.col, g.col, epsg);
      EXECUTE format('ALTER TABLE %I.%I ALTER COLUMN %I TYPE geometry(%s, %s)', till, t.table_name, g.col, g.type, epsg);
    END LOOP;
  END LOOP;
  EXECUTE format('UPDATE %I.dp_schema SET "value" = %L WHERE "key" = %L', till, epsg::text, 'epsg');
END
$$;
