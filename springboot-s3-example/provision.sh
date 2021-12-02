#!/bin/bash
apt update
apt install nginx -y
apt install openjdk-8-jdk -y
apt install awscli -y
useradd springboot
chsh -s /sbin/nologin springboot
mkdir /opt/springboot-s3-example
aws s3 cp s3://springboot-s3-example/ /opt/springboot-s3-example/ --no-sign-request --region=eu-west-1 --recursive --exclude "*" --include "springboot-s3-example*.jar"
mv /opt/springboot-s3-example/springboot-s3-example*.jar /opt/springboot-s3-example/springboot-s3-example.jar
cat << EOF > /opt/springboot-s3-example/springboot-s3-example.conf
RUN_ARGS="--spring.datasource.url=jdbc:mysql://${database_endpoint}/${database_name}?useSSL=false --spring.datasource.password=${database_password}"
EOF
chmod 400 /opt/springboot-s3-example/springboot-s3-example.conf
chown springboot:springboot /opt/springboot-s3-example/springboot-s3-example.conf
cat << EOF > /etc/nginx/conf.d/springboot-s3-example-nginx.conf
server {
    listen 80 default_server;

    # Redirect if the protocol used by the client of the AWS application load balancer was not HTTPS
    #if (\$http_x_forwarded_proto != 'https') {
    #    return 301 https://\$host\$request_uri;
    #}

    location / {
        proxy_set_header    X-Real-IP \$remote_addr;
        proxy_set_header    Host \$http_host;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass          http://127.0.0.1:8080/;
    }
}
EOF
cat << EOF > /etc/nginx/nginx.conf
user root;
worker_processes 1;
error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;

    index   index.html index.htm;
}
EOF
chown springboot:springboot /opt/springboot-s3-example/springboot-s3-example.jar
chmod 500 /opt/springboot-s3-example/springboot-s3-example.jar
cat <<EOF > /lib/systemd/system/springboot-s3-example.service
[Unit]
Description=springboot-s3-example
After=syslog.target

[Service]
User=root
ExecStart=/opt/springboot-s3-example/springboot-s3-example.jar
SuccessExitStatus=143
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl restart nginx
systemctl restart springboot-s3-example
