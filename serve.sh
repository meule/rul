rm gunicorn.cfg.py
rm tilestache.cfg
rm nginx-rul.conf
rm index.html

git pull
# replace credentials in configs and html
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
echo "password: $psswrd"

rep='_host_'
sed -i.bak "s/${rep}/${rdshost}/g" tilestache.cfg
rep='_ec2host_'
sed -i.bak "s/${rep}/${ec2host}/g" index.html
rep='_password_'
sed -i.bak "s/${rep}/${psswrd}/g" tilestache.cfg

sudo cp -R nginx-rul.conf /etc/nginx/sites-available/rul
sudo cp -R index.html /var/www/rul/public_html
sudo service nginx restart
kill `cat /tmp/gunicorn.pid`
gunicorn -c gunicorn.cfg.py -p /tmp/gunicorn.pid 'TileStache:WSGITileServer("tilestache.cfg")' &
