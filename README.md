RULmap is an interactive map of Russia with different layers based on OSM data and Vmap0 data.

This project contains everything you need from start to finish to make a vector tile based web map of nature and halo habitat of Russia.

The project runs on Amazon EC2 Ubuntu micro server and Amazon RDS PostgreSQL micro database. Both free for the first 1 year.

1. Register with Amazon AWS: https://aws.amazon.com
2. Run EC2 Ubuntu micro instance (30GB space) and RDS PostgreSQL micro instance (with database 'osm' and user 'osm', 20GB space)
3. Change the type of EC2 and RDS instances to xlarge. It will cost you $1-2 but significantly reduce data loading time (1-2 hour instead of 1-2 days).
4. Create security group for ec2 instance with open inbound TCP ports 80 and 8000 to all IPs. Create security group for RDS instance with open inbound TCP port 5432 to internal IP of ec2 instance.
5. Create Elastic IP and associate it with ec2 instance.
6. Run: bash rul.sh -e \<elastic IP\> -h \<amazon rds host\>
7. Wait about 1 hour for software installation, data downloading, converting it to the database. Answer 'No' for new database creating and enter 'osm' for db name and users (during osm2pgsql install).
8. !!! Change the type of EC2 and RDS instances back to micro. Otherwise you will pay Amazon hundreds dollars.
9. Browse http://\<Your Elastic IP\>
10. You are my hero! -‿-

OpenStreetMap and <a href="http://gis-lab.info/qa/vmap0-about.html">Vmap0</a> data is from GIS-lab http://gis-lab.info (Thank you guys, you are the best!).

The server stack: PostgreSQL+PostGIS - TileStache - Gunicorn - Nginx.

The server architecture is taken from Nelson Minar great work: https://github.com/NelsonMinar/vector-river-map (Big thanx Nelson!)


2do
- finish client (layers, popup)
- add cache: https://console.aws.amazon.com/elasticache/home
- add cloudfront: https://console.aws.amazon.com/cloudfront/home
- add OSM data autoupdate
- make the project useful -‿-
