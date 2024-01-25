FROM kernel:latest
RUN yum install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm; \
    dnf config-manager --set-enabled remi; \
    yum install -y php81 php81-php-bcmath php81-php-cli php81-php-common php81-php-fpm php81-php-gd php81-php-intl php81-php-json php81-php-mbstring php81-php-mysqlnd php81-php-pdo php81-php-pecl-geoip php81-php-pecl-imagick php81-php-pecl-zip php81-php-xml php81-runtime php81-php-process; \
    ln -s -T /usr/bin/php81 /usr/bin/php; ln -s -T /opt/remi/php81/root/usr/sbin/php-fpm /usr/bin/php-fpm; php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php; php -r "unlink('composer-setup.php');"; chmod +x composer.phar; mv composer.phar /usr/bin/composer
COPY resources/php/php.ini /etc/opt/remi/php81/
COPY resources/php/www.conf /etc/opt/remi/php81/php-fpm.d/
RUN curl -sL https://rpm.nodesource.com/setup_20.x | bash -; \
    yum install -y nodejs
ENTRYPOINT php-fpm -F