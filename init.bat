.\build.bat
docker compose up -d
docker cp docker-tf-lemp-dns-1:/root/.local/share/mkcert/rootCA.pem cert.pem
certutil -addstore root .\cert.pem
rm .\cert.pem