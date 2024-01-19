# Docker LEMP stack

This repository includes a docker compose plan which builds a dockerized LEMP stack, for terraform plan check the `main` branch.

## Services included in this stack

- `php 8.1.x` including all extensions required by `Laravel 8.x` and newer.
- `nginx` latest `stable` release
- `MariaDB 10.6.x`
- `NodeJS 20.x` (included in `php`)
- `Rocky Linux 9` (base image for `php` and, `nginx` services)

# Customization &amp; Usage

To build and start the stack all you need is to have Docker installed and, have this project cloned on your device then, in terminal you write:

```bash
$ git checkout compose
$ ./init
```

You'll need to run the previous commands only once, as the stack will automatically start every time your system and Docker service start.

## Customizing Project(s) Location

To specify where your project(s) is located in your system please put your projects' root absolute directory as a value to the `PROJECTS_ROOT` key in the `.env` file included in this project.

## Customizing Network Settings

The stack containers are bound to a network configured in the `docker-compose.yml` file, feel free to modify its IP address and, any other parameter as you see fit but, make sure that all services in the file follow the same IP range in case you've changed it.

## Credits &amp; Attribution

- [RockyLinux Docker Repository](https://hub.docker.com/u/rockylinux)
- [Remi's RPM Repository](https://rpms.remirepo.net)