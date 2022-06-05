FROM kernel:latest
RUN yum install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm; \
    dnf config-manager --set-enabled remi; \
    yum install -y php74 php74-php-bcmath php74-php-cli php74-php-common php74-php-fpm php74-php-gd php74-php-intl php74-php-json php74-php-mbstring php74-php-mysqlnd php74-php-pdo php74-php-pecl-mongodb php74-php-pecl-geoip php74-php-pecl-imagick php74-php-pecl-zip php74-php-xml php74-runtime php74-php-process php74-php-opcache; \
	ln -s -T /usr/bin/php74 /usr/bin/php; ln -s -T /opt/remi/php74/root/usr/sbin/php-fpm /usr/bin/php-fpm; \
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
	php composer-setup.php; \
	php -r "unlink('composer-setup.php');"; \
	mv composer.phar /usr/bin/composer; chmod +x /usr/bin/composer;
COPY resources/php/php.ini /etc/opt/remi/php74/
COPY resources/php/www.conf /etc/opt/remi/php74/php-fpm.d/
ENTRYPOINT php-fpm -F