docker build -f .\os.Dockerfile -t kernel .
docker build -f .\nginx.Dockerfile -t nginx-app .
docker build -f .\php.Dockerfile -t php-app .
docker build -f .\dns.Dockerfile -t dns-app .
docker build -f .\mutagen.Dockerfile -t mutagen .