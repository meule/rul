#!/bin/bash

# RUL project — vector tile maps server with different osm layers
# download and setup osm_ru to amazon posgres db with user 'osm' and db 'osm'
# usage: bash rul.sh -e <elastic IP> -h <amazon rds host>

# tmux
# sudo apt-get -y install git
# git clone https://github.com/meule/rul.git
# cd rul
# bash rul.sh -e 54.72.184.190 -h osm.cxgbat4jt7jg.eu-west-1.rds.amazonaws.com

# postgis + postgres setup http://gis-lab.info/qa/postgis-vps-install.html

set -e

while getopts ":e:h:p:" option
do
        case "${option}"
        in
            h) rdshost=${OPTARG};;
            e) ec2host=${OPTARG};;
            p) psswrd=${OPTARG};;
        esac
done

echo "ec2: $ec2host"
echo "rds: $rdshost"

if [[ -n $psswrd ]] ; then
  echo "password is set: $psswrd" ;
else
  echo -n "Enter Amazon RDS database password (for user 'osm' created during database installation):"
  read psswrd
  echo "password: $psswrd"
fi
export PGPASSWORD=$psswrd

#sudo locale-gen ru_RU.utf8
#sudo locale-gen UTF-8
#sudo locale-gen
#sudo dpkg-reconfigure locales

sudo apt-get -y install postgresql-client
sudo apt-get -y install software-properties-common
sudo add-apt-repository -y ppa:kakrueger/openstreetmap
sudo apt-get update
sudo apt-get -y install osm2pgsql
sudo apt-get -y install p7zip-full
sudo apt-get -y install python-dev
sudo apt-get -y install python-pip
sudo pip install --allow-external PIL --allow-unverified PIL django  ModestMaps Werkzeug vectorformats gunicorn tilestache requests grequests shapely
sudo apt-get -y install nginx-full

#wget http://gis-lab.info/data/vmap0/vegetation.7z
#wget http://gis-lab.info/data/vmap0/elevation.7z
#wget http://gis-lab.info/data/vmap0/hydro-lines.7z
#wget http://gis-lab.info/data/vmap0/hydro-area.7z
#wget http://data.gis-lab.info/osm_dump/dump/latest/RU.osm.pbf

mkdir vmap0
7z e -ovmap0 vegetation.7z
7z e -ovmap0 elevation.7z
7z e -ovmap0 hydro-lines.7z
7z e -ovmap0 hydro-area.7z
shp2pgsql -d -g way -s 4326 vmap0/veg-tree-a.shp rul.veg1 > veg.sql
shp2pgsql -a -g way -s 4326 vmap0/veg-swamp-a.shp rul.veg1 >> veg.sql
shp2pgsql -a -g way -s 4326 vmap0/veg-tundra-a.shp rul.veg1 >> veg.sql
shp2pgsql -d -g way -s 4326 vmap0/veg-cropland-a.shp rul.veg2 >> veg.sql
shp2pgsql -d -g way -s 4326 vmap0/veg-grassland-a.shp rul.veg3 >> veg.sql
shp2pgsql -d -g way -W 'latin1' -s 4326 vmap0/elev-contour-l.shp rul.elev >> veg.sql

#rdshost=osm.cxgbat4jt7jg.eu-west-1.rds.amazonaws.com
psql -a -h $rdshost -d osm -U osm -f amazon_postgis_setup.sql
#psql -a -c "drop schema rul cascade;" -h $rdshost -d osm -U osm
psql -a -c "create schema rul;" -h $rdshost -d osm -U osm
psql -q -U osm -d osm -h $rdshost -f veg.sql

osm2pgsql -H $rdshost -G  -U osm -d osm RU.osm.pbf --cache 14500
#osm2pgsql -H $rdshost -s -G -U osm -d osm RU.osm.pbf --cache 7000 --cache-strategy sparse
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
psql -a -c "VACUUM ANALYZE rul.elevation;"  -h $rdshost -d osm -U osm


sudo mkdir /etc/nginx/sites-enabled/rul
sudo cp nginx-rul.conf /etc/nginx/sites-enabled
service nginx start

rep='_host_'
sed -i.bak "s/${rep}/${rdshost}/g" tilestache.cfg
rep='_ec2host_'
sed -i.bak "s/${rep}/${ec2host}/g" index.html
rep='_password_'
sed -i.bak "s/${rep}/${psswrd}/g" tilestache.cfg

bash serve.sh
