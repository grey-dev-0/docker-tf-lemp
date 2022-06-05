resource "docker_volume" "php" {
  name = "php"
}

resource "docker_volume" "php8" {
  name = "php8"
}

resource "docker_volume" "mariadb" {
  name = "mariadb"
}

resource "docker_volume" "redis" {
  name = "redis"
}