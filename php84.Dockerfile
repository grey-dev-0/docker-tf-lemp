FROM kernel:latest
RUN yum install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm; \
    dnf config-manager --set-enabled remi; \
    yum install -y php84 php84-php-bcmath php84-php-cli php84-php-common php84-php-fpm php84-php-gd php84-php-intl php84-php-json php84-php-mbstring php84-php-mysqlnd php84-php-pdo php84-php-pecl-geoip php84-php-pecl-imagick php84-php-pecl-zip php84-php-xml php84-runtime php84-php-process; \
    ln -s -T /usr/bin/php84 /usr/bin/php; ln -s -T /opt/remi/php84/root/usr/sbin/php-fpm /usr/bin/php-fpm; php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php; php -r "unlink('composer-setup.php');"; chmod +x composer.phar; mv composer.phar /usr/bin/composer
COPY resources/php84/php.ini /etc/opt/remi/php84/
COPY resources/php84/www.conf /etc/opt/remi/php84/php-fpm.d/
RUN curl -sL https://rpm.nodesource.com/setup_20.x | bash -; \
    yum install -y nodejs
ENTRYPOINT php-fpm -F
