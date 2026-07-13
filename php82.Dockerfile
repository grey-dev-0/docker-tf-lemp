FROM kernel:latest
RUN yum install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm; \
    dnf config-manager --set-enabled remi; \
    yum install -y php82 php82-php-bcmath php82-php-cli php82-php-common php82-php-fpm php82-php-gd php82-php-intl php82-php-json php82-php-mbstring php82-php-mysqlnd php82-php-pdo php82-php-pgsql php82-php-pecl-geoip php82-php-pecl-imagick php82-php-pecl-zip php82-php-xml php82-runtime php82-php-process; \
    ln -s -T /usr/bin/php82 /usr/bin/php; ln -s -T /opt/remi/php82/root/usr/sbin/php-fpm /usr/bin/php-fpm; php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php; php -r "unlink('composer-setup.php');"; chmod +x composer.phar; mv composer.phar /usr/bin/composer
COPY resources/php82/php.ini /etc/opt/remi/php82/
COPY resources/php82/www.conf /etc/opt/remi/php82/php-fpm.d/
RUN curl -sL https://rpm.nodesource.com/setup_20.x | bash -; \
    yum install -y nodejs
ENTRYPOINT php-fpm -F
