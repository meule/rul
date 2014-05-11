# RUL project — vector tile maps server with different osm layers
# download and setup osm_ru to amazon posgres db with user 'osm' and db 'osm'
# usage: rul -h <amazon rds host>

#sudo apt-get install git
#git clone git@github.com:meule/rul.git

# postgis + postgres setup http://gis-lab.info/qa/postgis-vps-install.html

while getopts h option
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

psql -a -h $rdshost -d osm -U osm -f amazon_postgis_setup.sql

# install osm2pgsql
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:kakrueger/openstreetmap
sudo apt-get update
sudo apt-get install osm2pgsql
sudo apt-get install p7zip-full

cd rul
wget http://data.gis-lab.info/osm_dump/dump/latest/RU.osm.pbf
#wget https://raw.githubusercontent.com/openstreetmap/osm2pgsql/master/default.style

osm2pgsql -H $rdshost -s -G -S default.style -U osm -d osm RU.osm.pbf -W --flat-nodes  flat-nodes --cache 200 --cache-strategy sparse
psql -a -c "VACUUM ANALYZE public.planet_osm_line;" -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE public.planet_osm_road;" -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE public.planet_osm_point;" -h $rdshost -d osm -U osm
psql -a -c "VACUUM ANALYZE public.planet_osm_polygon;" -h $rdshost -d osm -U osm


wget http://gis-lab.info/data/vmap0/vegetation.7z
mkdir vmap0
7z e -ovmap0 vegetation.7z
shp2pgsql -d -g way -s 4326 vmap0/veg-tree-a.shp rul.veg1 > veg.sql
shp2pgsql -a -g way -s 4326 vmap0/veg-swamp-a.shp rul.veg1 >> veg.sql
shp2pgsql -a -g way -s 4326 vmap0/veg-tundra-a.shp rul.veg1 >> veg.sql
shp2pgsql -d -g way -s 4326 vmap0/veg-cropland-a.shp rul.veg2 >> veg.sql
shp2pgsql -d -g way -s 4326 vmap0/veg-grassland-a.shp rul.veg3 >> veg.sql

psql -a -c "create schema rul;" -h $rdshost -d osm -U osm

psql -q -U osm -d osm -h $rdshost -f veg.sql

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

# server install (thanx to Nelson Minar https://github.com/NelsonMinar/vector-river-map)

sudo apt-get install python-dev
sudo apt-get install python-pip
pip install django  ModestMaps Werkzeug vectorformats gunicorn tilestache requests grequests shapely
#nginx
sudo apt-get install nginx-full
sudo mkdir /etc/nginx/sites-enabled/rul
sudo mkdir /var/www
sudo mkdir /var/www/rul
sudo cp nginx-rul.conf /etc/nginx/sites-enabled
service nginx start

rep='_host_'
sed -i.bak "s/${rep}/${rdshost}/g" tilestache.cfg
rep='_password_'
sed -i.bak "s/${rep}/${psswrd}/g" tilestache.cfg

bash serve.sh
