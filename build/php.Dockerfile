FROM kernel:latest
RUN yum install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm; \
    dnf config-manager --set-enabled remi; \
    yum install -y php80 php80-php-bcmath php80-php-cli php80-php-common php80-php-fpm php80-php-gd php80-php-intl php80-php-json php80-php-mbstring php80-php-mysqlnd php80-php-pdo php80-php-pecl-geoip php80-php-pecl-imagick php80-php-pecl-zip php80-php-xml php80-runtime php80-php-process php80-php-opcache; \
    ln -s -T /usr/bin/php80 /usr/bin/php; ln -s -T /opt/remi/php80/root/usr/sbin/php-fpm /usr/bin/php-fpm; php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php; php -r "unlink('composer-setup.php');"; chmod +x composer.phar; mv composer.phar /usr/bin/composer
COPY resources/php/php.ini /etc/opt/remi/php80/
COPY resources/php/www.conf /etc/opt/remi/php80/php-fpm.d/
ENTRYPOINT php-fpm -F