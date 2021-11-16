resource "docker_volume" "php-fpm" {
  name = "php-fpm"
}

resource "docker_volume" "mariadb" {
  name = "mariadb"
}