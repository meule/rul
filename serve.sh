git pull
sudo cp -R nginx-rul.conf /etc/nginx/sites-available/rul
sudo cp -R index.html /var/www/rul/public_html
sudo service nginx restart
kill `cat /tmp/gunicorn.pid`
gunicorn -c gunicorn.cfg.py -p /tmp/gunicorn.pid 'TileStache:WSGITileServer("tilestache.cfg")' &
