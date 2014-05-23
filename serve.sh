# bash rul.sh -e 54.72.184.190 -h osm.cxgbat4jt7jg.eu-west-1.rds.amazonaws.com -p rds_password -i

rm tilestache.cfg
rm index.html

git pull
# replace credentials in configs and html
while getopts ":e:h:p:i:" option
do
        case "${option}"
        in
            h) rdshost=${OPTARG};;
            e) ec2host=${OPTARG};;
            p) psswrd=${OPTARG};;
            i) echo "index"
        esac
done

echo "ec2: $ec2host"
echo "rds: $rdshost"
echo "password: $psswrd"

rep='_host_'
sed -i.bak "s/${rep}/${rdshost}/g" tilestache.cfg
rep='_ec2host_'
sed -i.bak "s/${rep}/${ec2host}/g" index.html
rep='_password_'
sed -i.bak "s/${rep}/${psswrd}/g" tilestache.cfg

#sudo cp -R nginx-rul.conf /etc/nginx/sites-available/default
sudo cp -R nginx-rul.conf /etc/nginx/sites-enabled
#sudo cp -R nginx-rul.conf /etc/nginx/conf.d
sudo cp -R index.html /var/www/rul/public_html
sudo service nginx restart
kill `cat /tmp/gunicorn.pid`
gunicorn -c gunicorn.cfg.py -p /tmp/gunicorn.pid 'TileStache:WSGITileServer("tilestache.cfg")' &
