#!/bin/bash

# RUL project — vector tile maps server with different osm layers
# download and setup osm_ru to amazon posgres db with user 'osm' and db 'osm'
# usage: rul -h <amazon rds host>

#sudo apt-get install git
#git clone https://github.com/meule/rul.git
#cd rul
#rul.sh -h osm.cxgbat4jt7jg.eu-west-1.rds.amazonaws.com

# postgis + postgres setup http://gis-lab.info/qa/postgis-vps-install.html

set -e

while getopts ":h:" option
do
        case "${option}"
        in
                h) rdshost=${OPTARG};;
        esac
done

echo -n "Enter Amazon RDS database password (for user 'osm' created during database installation):"
read psswrd
export PGPASSWORD=$psswrd

sudo locale-gen ru_RU.utf8
sudo dpkg-reconfigure locales

sudo apt-get install postgresql-client


# install osm2pgsql
sudo apt-get -y install software-properties-common
sudo add-apt-repository -y ppa:kakrueger/openstreetmap
sudo apt-get update
sudo apt-get -y install osm2pgsql
sudo apt-get -y install p7zip-full
sudo apt-get -y install python-dev
sudo apt-get -y install python-pip
pip install django  ModestMaps Werkzeug vectorformats gunicorn tilestache requests grequests shapely
sudo apt-get -y install nginx-full

wget http://gis-lab.info/data/vmap0/vegetation.7z
wget http://data.gis-lab.info/osm_dump/dump/latest/RU.osm.pbf


mkdir vmap0
7z e -ovmap0 vegetation.7z
shp2pgsql -d -g way -s 4326 vmap0/veg-tree-a.shp rul.veg1 > veg.sql
shp2pgsql -a -g way -s 4326 vmap0/veg-swamp-a.shp rul.veg1 >> veg.sql
shp2pgsql -a -g way -s 4326 vmap0/veg-tundra-a.shp rul.veg1 >> veg.sql
shp2pgsql -d -g way -s 4326 vmap0/veg-cropland-a.shp rul.veg2 >> veg.sql
shp2pgsql -d -g way -s 4326 vmap0/veg-grassland-a.shp rul.veg3 >> veg.sql

psql -a -h $rdshost -d osm -U osm -f amazon_postgis_setup.sql
psql -a -c "create schema rul;" -h $rdshost -d osm -U osm
psql -q -U osm -d osm -h $rdshost -f veg.sql

osm2pgsql -H $rdshost -s -G -S default.style -U osm -d osm RU.osm.pbf --flat-nodes  flat-nodes --cache 300 --cache-strategy sparse
psql -a -c "VACUUM ANALYZE public.planet_osm_line;" -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE public.planet_osm_road;" -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE public.planet_osm_point;" -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE public.planet_osm_polygon;" -h $rdshost -d osm -U osm

# rul tables init
psql -a -f rul.sql -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE rul.buildings;" -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE rul.roads;"  -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE rul.railway;" -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE rul.man_made;" -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE rul.forest;" -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE rul.rivers;" -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE rul.water;" -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE rul.power_generator;" -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE rul.power_station;"  -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE rul.power_line;"  -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE rul.veg;"  -h $rdshost -d osm -U osm


sudo mkdir /etc/nginx/sites-enabled/rul
sudo cp nginx-rul.conf /etc/nginx/sites-enabled
service nginx start

rep='_host_'
sed -i.bak "s/${rep}/${rdshost}/g" tilestache.cfg
rep='_password_'
sed -i.bak "s/${rep}/${psswrd}/g" tilestache.cfg

bash serve.sh
