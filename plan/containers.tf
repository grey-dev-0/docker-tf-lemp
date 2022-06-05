resource "docker_container" "php-app" {
  depends_on = [docker_image.php, docker_volume.php, docker_container.redis]
  image = docker_image.php.latest
  name  = "php-app"
  restart = "always"

  volumes {
    from_container = docker_container.redis.name
  }
  volumes {
    volume_name = docker_volume.php.name
    container_path = "/var/opt/remi/php74/run/php-fpm"
  }
  volumes {
    host_path = "/opt/public_html"
    container_path = "/home/projects"
  }

  networks_advanced {
    name = docker_network.development.name
    ipv4_address = "100.100.50.2"
  }
}

resource "docker_container" "php8-app" {
  depends_on = [docker_image.php8, docker_volume.php8, docker_container.php-app]
  image = docker_image.php8.latest
  name  = "php8-app"
  restart = "always"

  volumes {
    from_container = docker_container.php-app.name
  }
  volumes {
    volume_name = docker_volume.php8.name
    container_path = "/var/opt/remi/php80/run/php-fpm"
  }

  networks_advanced {
    name = docker_network.development.name
    ipv4_address = "100.100.50.8"
  }
}

resource "docker_container" "nginx" {
  depends_on = [docker_image.nginx, docker_container.php-app, docker_container.php8-app]
  image = docker_image.nginx.latest
  name  = "nginx"
  restart = "always"

  volumes {
    from_container = docker_container.php8-app.name
  }

  networks_advanced {
    name = docker_network.development.name
    ipv4_address = "100.100.50.3"
  }
}

resource "docker_container" "mariadb" {
  depends_on = [docker_container.php-app, docker_volume.mariadb]
  image = "mariadb:10.5"
  name  = "mariadb"
  restart = "always"
  env = [
    "MYSQL_ROOT_PASSWORD=password"
  ]

  volumes {
    volume_name = "mariadb"
    container_path = "/var/lib/mysql"
  }

  networks_advanced {
    name = docker_network.development.name
    ipv4_address = "100.100.50.4"
  }
}

resource "docker_container" "redis" {
  depends_on = [docker_image.redis, docker_volume.redis, docker_network.development]
  image = docker_image.redis.latest
  name  = "redis"
  restart = "always"

  volumes {
    volume_name = "redis"
    container_path = "/var/run/redis"
  }

  networks_advanced {
    name = docker_network.development.name
    ipv4_address = "100.100.50.6"
  }
}