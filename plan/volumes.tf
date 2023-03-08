resource "docker_volume" "php-fpm" {
  name = "php-fpm"
}

resource "docker_volume" "php81-fpm" {
  name = "php81-fpm"
}

resource "docker_volume" "mariadb" {
  name = "mariadb"
}

resource "docker_volume" "nginx" {
  name = "nginx-hosts"
}