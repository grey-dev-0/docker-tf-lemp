resource "docker_container" "php-app" {
  depends_on = [docker_image.php, docker_network.development]
  image = docker_image.php.image_id
  name  = "php-app"
  restart = "always"

  volumes {
    volume_name = docker_volume.php-fpm.name
    container_path = "/var/opt/remi/php80/run/php-fpm"
  }

  volumes {
    host_path = "/opt/public_html/"
    container_path = "/home/projects"
  }

  networks_advanced {
    name = docker_network.development.name
    ipv4_address = "100.100.50.2"
  }
}

resource "docker_container" "php81-app" {
  depends_on = [docker_image.php, docker_network.development]
  image = docker_image.php81.image_id
  name  = "php81-app"
  restart = "always"

  volumes {
    from_container = docker_container.php-app.name
  }

  volumes {
    volume_name = docker_volume.php81-fpm.name
    container_path = "/var/opt/remi/php81/run/php-fpm"
  }

  networks_advanced {
    name = docker_network.development.name
    ipv4_address = "100.100.50.5"
  }
}

resource "docker_container" "nginx" {
  depends_on = [docker_image.nginx, docker_container.php-app, docker_container.php81-app, docker_volume.nginx]
  image = docker_image.nginx.image_id
  name  = "nginx"
  restart = "always"

  volumes {
    from_container = docker_container.php-app.name
  }

  volumes {
    from_container = docker_container.php81-app.name
  }

  volumes {
    volume_name = docker_volume.nginx.name
    container_path = "/etc/nginx/vhosts"
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