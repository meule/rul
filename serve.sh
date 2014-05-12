git pull
#cp -R nginx-rul.conf /etc/nginx/sites-enabled/rul
sudo cp -R index.html /etc/nginx/sites-enabled/rul
#sudo cp -R index.html /var/www/rul
sudo service nginx restart
kill `cat /tmp/gunicorn.pid`
gunicorn -c gunicorn.cfg.py -p /tmp/gunicorn.pid 'TileStache:WSGITileServer("tilestache.cfg")' &
