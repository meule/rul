CREATE EXTENSION intarray;
CREATE EXTENSION postgis;
CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION postgis_tiger_geocoder;
CREATE EXTENSION postgis_topology;
alter schema tiger owner to rds_superuser;
alter schema topology owner to rds_superuser;
SELECT PostGIS_Full_Version();
