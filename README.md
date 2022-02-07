# Terraform Docker LEMP stack

This repository includes a terraform plan which can be used to build a dockerized LEMP stack, the `main` branch holds a single node stack plan, another branch that provides a scalable plan will be implemented later on.

## Services included in this stack

- `php 8.0.x` including all extensions required by the `Laravel 8.x` framework
- `nginx` latest `stable` release
- `MariaDB 10.5.x`
- `NodeJS 14.x` (image only - includes all node modules required for building VueJS SFC libraries)
- `Rocky Linux 8` (base image for `php`, `nginx` and, `node` services)

### Node image usage

The main purpose of the node image included in this plan is to run node commands within a php backend projects when necessary, e.g:

```bash
$ docker run --rm -it -w /home/server/project node npm install
$ docker run --rm -it -w /home/server/project node npm run build
$ docker run --rm -it -w /home/server/project node vue build --target lib --name some_library library.js
```

The image can be used to start a node server, it's recommended to add a container plan for it in the `plan/containers.tf` file.

# Customization &amp; Usage

To build and start the stack all you need is to have Docker and Terraform installed then, in terminal you write:

```bash
$ terraform init
$ terraform plan        # Optional
$ terraform apply 
```

## Customizing Project(s) Location

To specify where your project(s) is located in your system and, where you'd like to mount it within the `php-app` container, please add or edit the existing `volumes` block found in the first container in `plan/containers.tf` file.

The `volumes` block is repeatable, so if you want to mount multiple locations from your system into the container feel free to add as much `volumes` blocks as you need.

## Customizing Network Settings

The stack containers are bound to a network configured in the `plan/networks.tf` file, feel free to modify its IP address and, any other parameter as you see fit but, make sure that all containers in `plan/containers.tf` file follow the same IP range in case you've changed it, the IP address of each container is in the `networks_advanced` block under each container in the `containers.tf` file.

## Credits &amp; Attribution

- [Kreuzwerker Docker Terraform Provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest)
- [CentOS Docker Repository](https://hub.docker.com/u/centos)
- [Remi's RPM Repository](https://rpms.remirepo.net)