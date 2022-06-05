resource "docker_image" "os" {
  name = "os"
  build {
    path = "build"
    dockerfile = "os.Dockerfile"
    tag = ["kernel:latest"]
  }
}

resource "docker_image" "php" {
  depends_on = [docker_image.os]
  name = "php"
  build {
    path = "build"
    dockerfile = "php.Dockerfile"
    tag = ["php:74"]
  }
}

resource "docker_image" "php8" {
  depends_on = [docker_image.os]
  name = "php8"
  build {
    path = "build"
    dockerfile = "php8.Dockerfile"
    tag = ["php:8"]
  }
}

resource "docker_image" "nginx" {
  depends_on = [docker_image.os]
  name = "nginx"
  build {
    path = "build"
    dockerfile = "nginx.Dockerfile"
    tag = ["nginx:latest"]
  }
}

resource "docker_image" "redis" {
  name = "redis"
  build {
    path = "build"
    dockerfile = "redis.Dockerfile"
    tag = ["redis:latest"]
  }
}

resource "docker_image" "node" {
  depends_on = [docker_image.os]
  name = "node"
  build {
    path = "build"
    dockerfile = "node.Dockerfile"
    tag = ["node:14"]
  }
}