RULmap is interactive map of Russia with different layers based on OSM data and vmap0 data. Data is from GIS-lab http://http://gis-lab.info/ (Thank you guys!)

This project contains everything you need from start to finish to make a vector based web map of nature and halo habitat of Russia.

The project runs on Amazon EC2 Ubuntu micro server and Amazon RDS PostgreSQL micro database. Both free for the first 1 year.

1. Register with Amazon AWS: https://aws.amazon.com
2. Run EC2 Ubuntu micro instance (30GB space) and RDS PostgreSQL micro instance (with database 'osm' and user 'osm', 20GB space) 
3. Create security group for ec2 instance with open inbound TCP port 80 to all IPs. Create security group for RDS instance with open inbound TCP port 5432 to internal IP of ec2 instance.
4. Create Elastic IP and associate it with ec2 instance.
5. Run: bash rul.sh -h <amazon rds hostname>
6. During downloading data and installation you will be promt several times to enter your RDS server user password (entered during instance starting)
7. Browse http://<Your Elastic IP>
8. You are my hero! -‿-
