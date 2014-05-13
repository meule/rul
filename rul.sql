-- power
create table rul.power_generator as
  select osm_id,name,way,power,"generator:source" from planet_osm_point where power='generator'
  union select osm_id,name,way,power,"generator:source" from planet_osm_polygon where power='generator';
CREATE INDEX idx_way_power_generator ON rul.power_generator USING gist (way);
ALTER TABLE rul.power_generator ADD COLUMN id SERIAL PRIMARY KEY;
CREATE UNIQUE INDEX uidx_id_power_generator ON rul.power_generator USING btree (id);

create table rul.power_line as
  select osm_id,name,way,power from planet_osm_line where power is not null;
CREATE INDEX idx_way_power_line ON rul.power_line USING gist (way);
ALTER TABLE rul.power_line ADD COLUMN id SERIAL PRIMARY KEY;
CREATE UNIQUE INDEX uidx_id_power_line ON rul.power_line USING btree (id);

create table rul.power_station as
  select osm_id,name,way,power from planet_osm_point where power is not null and power!='generator' and power!='pole' and power!='tower'
  union select osm_id,name,way,power from planet_osm_polygon where power!='generator';
CREATE INDEX idx_way_power_station ON rul.power_station USING gist (way);
ALTER TABLE rul.power_station ADD COLUMN id SERIAL PRIMARY KEY;
CREATE UNIQUE INDEX uidx_id_power_station ON rul.power_station USING btree (id);

-- water
create table rul.rivers as
  select osm_id,name,waterway,way from planet_osm_line where waterway is not null;
CREATE INDEX idx_way_rivers ON rul.rivers USING gist (way);
ALTER TABLE rul.rivers ADD COLUMN id SERIAL PRIMARY KEY;
CREATE UNIQUE INDEX uidx_id_rivers ON rul.rivers USING btree (id);

create table rul.water as
  select osm_id,name,water,way from planet_osm_polygon where water is not null or waterway is not null or "natural"='water';
CREATE INDEX idx_way_water ON rul.water USING gist (way);
ALTER TABLE rul.water ADD COLUMN id SERIAL PRIMARY KEY;
CREATE UNIQUE INDEX uidx_id_water ON rul.water USING btree (id);

-- forest
create table rul.forest as
  select osm_id,name,way from planet_osm_polygon where landuse='forest' or "natural"='wood';
CREATE INDEX idx_way_forest ON rul.forest USING gist (way);
ALTER TABLE rul.forest ADD COLUMN id SERIAL PRIMARY KEY;
CREATE UNIQUE INDEX uidx_id_forest ON rul.forest USING btree (id);

-- man made
create table rul.buildings as
  select osm_id,name,way from planet_osm_polygon where building is not null or construction is not null;
CREATE INDEX idx_way_buildings ON rul.buildings USING gist (way);
ALTER TABLE rul.buildings ADD COLUMN id SERIAL PRIMARY KEY;
CREATE UNIQUE INDEX uidx_id_buildings ON rul.buildings USING btree (id);

create table rul.roads as
  select osm_id,name,way,highway from planet_osm_line where highway is not null;
CREATE INDEX idx_way_roads ON rul.roads USING gist (way);
ALTER TABLE rul.roads ADD COLUMN id SERIAL PRIMARY KEY;
CREATE UNIQUE INDEX uidx_id_roads ON rul.roads USING btree (id);

create table rul.railway as
  select osm_id,name,way,railway from planet_osm_line where railway is not null;
CREATE INDEX idx_way_railway ON rul.railway USING gist (way);
ALTER TABLE rul.railway ADD COLUMN id SERIAL PRIMARY KEY;
CREATE UNIQUE INDEX uidx_id_railway ON rul.railway USING btree (id);

create table rul.man_made as
  select osm_id,name,way,man_made from planet_osm_polygon where man_made is not null and building is null;
CREATE INDEX idx_way_man_made ON rul.man_made USING gist (way);
ALTER TABLE rul.man_made ADD COLUMN id SERIAL PRIMARY KEY;
CREATE UNIQUE INDEX uidx_id_man_made ON rul.man_made USING btree (id);

-- vegetation from vmap0
create table rul.veg as
  select f_code_des as type,way from rul.veg1
  union select f_code_des,way from rul.veg2
  union select f_code_des,way from rul.veg3;
drop table rul.veg1;
drop table rul.veg2;
drop table rul.veg3;
SELECT UpdateGeometrySRID('rul','veg','way',900913);
CREATE INDEX idx_way_veg ON rul.veg USING gist (way);
ALTER TABLE rul.veg ADD COLUMN id SERIAL PRIMARY KEY;
CREATE UNIQUE INDEX uidx_id_veg ON rul.veg USING btree (id);

-- elevations from vmap0
create table rul.elevation as
  select zv2 as height,way from rul.elev where zv2<10000;
SELECT UpdateGeometrySRID('rul','elevation','way',900913);
drop table rul.elev;
CREATE INDEX idx_way_elevation ON rul.elevation USING gist (way);
ALTER TABLE rul.elevation ADD COLUMN id SERIAL PRIMARY KEY;
CREATE UNIQUE INDEX uidx_id_elevation ON rul.elevation USING btree (id);
