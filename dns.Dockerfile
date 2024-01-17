FROM php-app:latest
RUN curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"; \
    chmod +x mkcert-v*-linux-amd64; \
    mv mkcert-v*-linux-amd64 /usr/bin/mkcert
ENTRYPOINT bash