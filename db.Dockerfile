FROM mariadb:11.8
RUN ln -sf /usr/bin/mariadb /usr/bin/mysql && \
    ln -sf /usr/bin/mariadb-dump /usr/bin/mysqldump && \
    ln -sf /usr/bin/mariadb-admin /usr/bin/mysqladmin
