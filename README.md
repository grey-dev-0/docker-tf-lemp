# Docker LEMP stack

This repository includes a docker compose plan which builds a dockerized LEMP stack, for terraform plan check the `main` branch.

## Services included in this stack

- `php 8.1.x` including all extensions required by `Laravel 8.x` and newer.
- `nginx` latest `stable` release
- `MariaDB 10.6.x`
- `NodeJS 16.x` (included in `php`)
- `Rocky Linux 9` (base image for `php`, `nginx` and, `node` services)

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