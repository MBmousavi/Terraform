#! /bin/bash -ex
apt update
apt install nginx -y
mkdir -p /var/www/html/
echo "<h1>This is NGINX Web Server from $HOSTNAME</h1>" > /var/www/html/index.html
