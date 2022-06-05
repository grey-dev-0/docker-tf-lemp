FROM kernel:latest
COPY resources/nginx/nginx.repo /etc/yum.repos.d/
RUN yum install -y nginx nginx-module-perl
COPY resources/nginx/nginx.conf /etc/nginx/
COPY resources/nginx/php-fpm.conf /etc/nginx/common/
COPY resources/nginx/php8-fpm.conf /etc/nginx/common/
COPY resources/nginx/app.conf /etc/nginx/vhosts/
COPY resources/nginx/ssl/* /etc/nginx/ssl/
ENTRYPOINT nginx