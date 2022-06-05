FROM redis:6
COPY resources/redis.conf /usr/local/etc/redis/redis.conf
RUN mkdir -p /var/lib/redis
ENTRYPOINT redis-server /usr/local/etc/redis/redis.conf