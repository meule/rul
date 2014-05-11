# RUL project — vector tile maps server with different osm layers
# download and setup osm_ru to amazon posgres db with user 'osm' and db 'osm'
# usage: rul -h <amazon rds host>

# postgis + postgres setup http://gis-lab.info/qa/postgis-vps-install.html

while getopts h option
do
        case "${option}"
        in
                h) rdshost=${OPTARG};;
        esac
done

sudo locale-gen ru_RU.utf8
sudo dpkg-reconfigure locales

sudo apt-get install postgresql-client

psql -a -h $rdshost -d osm -U osm -f amazon_postgis_setup.sql

# install osm2pgsql
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:kakrueger/openstreetmap
sudo apt-get update
sudo apt-get install osm2pgsql

mkdir rul
cd rul
wget http://data.gis-lab.info/osm_dump/dump/latest/RU.osm.pbf
#wget https://raw.githubusercontent.com/openstreetmap/osm2pgsql/master/default.style

osm2pgsql -H $rdshost -s -G -S default.style -U osm -d osm RU.osm.pbf -W --flat-nodes  flat-nodes --cache 200 --cache-strategy sparse

# rul tables init
psql -a -f rul.sql -h $rdshost -d osm -U osm

# server install (thanx to Nelson Minar https://github.com/NelsonMinar/vector-river-map)

sudo apt-get install python-dev
pip install django TileStache ModestMaps Werkzeug vectorformats psycopg2 gunicorn tilestache requests grequests shapely
#nginx
sudo mkdir /etc/nginx/sites-enabled/rul
cp nginx-rul.conf /etc/nginx
service nginx start
