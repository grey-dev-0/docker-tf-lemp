resource "docker_image" "os" {
  name = "os"
  build {
    context = "build"
    dockerfile = "os.Dockerfile"
    tag = ["kernel:latest"]
  }
}

resource "docker_image" "php" {
  depends_on = [docker_image.os]
  name = "php"
  build {
    context = "build"
    dockerfile = "php.Dockerfile"
    tag = ["php:8"]
  }
}

resource "docker_image" "php81" {
  depends_on = [docker_image.os]
  name = "php81"
  build {
    context = "build"
    dockerfile = "php81.Dockerfile"
    tag = ["php:81"]
  }
}

resource "docker_image" "nginx" {
  depends_on = [docker_image.os]
  name = "nginx"
  build {
    context = "build"
    dockerfile = "nginx.Dockerfile"
    tag = ["nginx:latest"]
  }
}

resource "docker_image" "node" {
  depends_on = [docker_image.os]
  name = "node"
  build {
    context = "build"
    dockerfile = "node.Dockerfile"
    tag = ["node:14"]
  }
}