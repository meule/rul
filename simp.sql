-- psql -a -f simp.sql -h osm.cxgbat4jt7jg.eu-west-1.rds.amazonaws.com -d osm -U osm
-- create simplified geometry tables
  CREATE OR REPLACE FUNCTION simp(text) RETURNS void AS $$ DECLARE
    table_name ALIAS FOR $1;
    i integer; strahler integer; simpl float;
  BEGIN
    for i in 1..10 loop
      simpl:=2^(10-i)*30;
      -- strahler:=
      execute 'drop table if exists '||(table_name)||'_z'||(i)||';'; 
      execute 'create table '||table_name||'_z'||(i)||' (osm_id integer, name text);'; 
      execute 'SELECT AddGeometryColumn('|| quote_literal(split_part((table_name||'_z'||(i)),'.',1)) ||','|| quote_literal(split_part((table_name||'_z'||(i)),'.',2)) ||','|| quote_literal('way') ||',900913,'|| quote_literal('LineString') ||',2);';
      execute 'insert into '||(table_name)||'_z'||(i)||' (osm_id, name, way)
        select osm_id, name, ST_SimplifyPreserveTopology(way,'||(simpl)||') as way from '||(table_name); -- where strahler>... and where length or where area
      execute 'CREATE INDEX idx_'||(replace(table_name,'.','_'))||'_way_z'||(i)||' ON '||(table_name)||' USING gist (way);';
      raise info '%',m;
    end loop;
  END; $$ LANGUAGE plpgsql volatile RETURNS NULL ON NULL INPUT;

  select simp('rul.rivers');
  select simp('rul.water');
