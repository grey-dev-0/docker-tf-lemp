resource "docker_network" "development" {
  name = "development"
  driver = "bridge"
  ipam_config {
    subnet = "100.100.50.0/24"
    gateway = "100.100.50.1"
  }
  options = {
    "com.docker.network.bridge.name" = "br_development"
  }
}