.\build.bat
docker compose up -d
docker cp docker-tf-lemp-dns-1:/usr/bin/mkcert .\mkcert.exe
for /f "tokens=*" %%A in ('.\mkcert.exe -CAROOT') do set CAROOT=%%A
powershell -Command "(Get-Content .env) -replace 'MKCERT_ROOT=.*', ('MKCERT_ROOT=' + '%CAROOT%') | Set-Content .env"
.\mkcert.exe -install
del .\mkcert.exe
docker exec docker-tf-lemp-dns-1 rm -rf /home/projects/lemp/* /home/projects/lemp/.[^.]*
docker exec -w /home/projects docker-tf-lemp-dns-1 composer create-project --repository "{\"type\":\"vcs\", \"url\":\"https://github.com/grey-dev-0/lemp-server\"}" --keep-vcs --stability dev grey-dev-0/lemp-server lemp
REM To pick up new CAROOT env variable change if it occurs.
docker compose restart
docker exec -w /home/projects/lemp docker-tf-lemp-dns-1 php artisan lemp:setup
docker exec -itw /home/projects/lemp docker-tf-lemp-dns-1 npm i
docker exec -itw /home/projects/lemp docker-tf-lemp-dns-1 npm run build
docker exec docker-tf-lemp-dns-1 chown -R user:user /home/projects/lemp
docker exec -w /home/projects/lemp docker-tf-lemp-dns-1 chmod 777 -R storage bootstrap/cache
