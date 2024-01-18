FROM php-app:latest
RUN curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"; chmod +x mkcert-v*-linux-amd64; mv mkcert-v*-linux-amd64 /usr/bin/mkcert; \
    sed -i -e 's#www.sock#dns.sock#g' -e 's#;clear_env#clear_env#g' /etc/opt/remi/php81/php-fpm.d/www.conf
ENTRYPOINT php-fpm -F