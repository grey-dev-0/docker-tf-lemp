# Docker LEMP stack

This repository includes a docker compose plan which builds a dockerized LEMP stack, for terraform plan check the `main` branch.

## Services included in this stack

- `php 8.0.x` including all extensions required by the `Laravel 8.x` framework
- `nginx` latest `stable` release
- `MariaDB 10.5.x`
- `NodeJS 16.x` (image only)
- `Rocky Linux 9` (base image for `php`, `nginx` and, `node` services)

### Node image usage

The main purpose of the node image included in this plan is to run node commands within a php backend projects when necessary, e.g:

```bash
$ docker run --rm --volumes-from nginx -it -w /home/projects/example node npm install
$ docker run --rm --volumes-from nginx -it -w /home/projects/example node npm run build
$ docker run --rm --volumes-from nginx -it -w /home/projects/example node vue build --target lib --name some_library library.js
```

The `--volumes-from` option is used to inherit the php projects directory mounted to the `nginx` and `php-app` containers thus, any file changes applied by the `npm` command will instantly be reflected into those containers as well.

The image can be used to start a node server, it's recommended to add a container plan for it in the `plan/containers.tf` file.

# Customization &amp; Usage

To build and start the stack all you need is to have Docker installed then, in terminal you write:

```bash
$ docker compose up -d
```

## Customizing Project(s) Location

To specify where your project(s) is located in your system please put your projects' absolute directory path in place of `/opt/public_html` found in the `volumes` section of both `nginx` and `php` services in the `docker-compose.yml` file.

## Customizing Network Settings

The stack containers are bound to a network configured in the `docker-compose.yml` file, feel free to modify its IP address and, any other parameter as you see fit but, make sure that all services in the file follow the same IP range in case you've changed it.

## Credits &amp; Attribution

- [RockyLinux Docker Repository](https://hub.docker.com/u/rockylinux)
- [Remi's RPM Repository](https://rpms.remirepo.net)