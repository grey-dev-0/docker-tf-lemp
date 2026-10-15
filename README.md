# Docker LEMP stack

This repository includes a docker compose plan which builds a dockerized LEMP stack, for terraform plan check the `main` branch.

## Services included in this stack

- `php 8.1.x`, `php 8.2.x`, and `php 8.4.x` including all extensions required by `Laravel 8.x` and newer.
- `nginx` latest `stable` release
- `MariaDB 11.4.x`
- `PostgreSQL 17.x`
- `NodeJS 20.x` (included in `php`)
- `Rocky Linux 9` (base image for `php` and, `nginx` services)
- `Orca IDE` remote server with Claude Code and OpenCode (`orca` service)

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

## Orca IDE remote server (`orca` service)

`orca.Dockerfile` builds `orca-app`, a standalone Rocky Linux 9 image (it doesn't use the `kernel` base) with:

- [Orca IDE](https://github.com/stablyai/orca) (`orca-ide` / `orca`) running `orca serve` headless
- Claude Code (`claude`) and OpenCode 2 (`opencode`, npm `@opencode/cli`), installed globally via npm
- GitHub CLI (`gh`), which Orca uses for PRs, checks and repos. Log in once with `docker exec -itu nginx lemp-orca gh auth login`
- Docker CLI (`docker`, with `docker compose` and `docker buildx`), which talks to the host daemon through the mounted `/var/run/docker.sock`. On each start the entrypoint adds `nginx` to a group with the socket's gid (`docker-host` when the gid has no name in the image), so the user stays non-root. Socket access is equivalent to root on the host. Containers started from Orca run on the host, so bind-mount paths are host paths (`${PROJECTS_ROOT}`, not `/home/projects`).

```bash
docker build -f orca.Dockerfile --build-arg UID=9000 --build-arg GID=9000 -t orca-app .   # ORCA_VERSION=x.y.z to pin
docker compose up -d orca
docker exec lemp-orca orca-urls        # or: cat orca-info/urls.txt
docker exec -it lemp-orca orca-urls --qr   # + pairing QR for the Orca mobile app (Pair -> scan)
```

The entrypoint starts as root only to fix the ownership of the home volume, then runs Orca as `nginx` (the `USERID`/`GROUPID` user, the owner of `PROJECTS_ROOT`). Projects are mounted at `/home/projects`, the same path the `nginx` and `php` services use. Terminals and agents started from Orca run as that user, so they can edit project files without permission problems. For a shell as that user, run `docker exec -itu nginx lemp-orca bash`.

| Item | Location |
| --- | --- |
| Web client / pairing URLs (regenerated on each start, mode `0600`) | `/var/lib/orca-info/urls.txt` in the container, `orca-info/urls.txt` in this repo (git-ignored) |
| Orca, Claude Code and OpenCode logins and state | `orca-home` volume → `/home/nginx` |
| Public endpoint | `https://ai.example.net` (TLS proxy, e.g. Cloudflare → nginx vhost `ai.conf` → `100.100.10.8:6768`) |
| Direct port, for SSH tunnels only | `127.0.0.1:6768` on the host |

The `ai.conf` vhost ships with the `nginx` image (`resources/nginx/ai.conf`). Replace `ai.example.net` there and in `ORCA_PAIRING_ADDRESS` (`docker-compose.yml`) with your own domain. It listens on port 80 only and expects TLS to be terminated in front of it. The `nginx` vhosts directory is a named volume, so the file is only copied into a fresh volume. On an existing stack, copy it in with `docker compose cp resources/nginx/ai.conf nginx:/etc/nginx/vhosts/` and reload nginx.

To see who has access, run `./orca-devices`. A used link stays valid across restarts. If the URLs are compromised, run `./orca-devices revoke`. It revokes every client and link, restarts `orca` and prints a fresh pairing/web URL pair. Every client must then re-pair, and agents running in Orca terminals stop.

The pairing and web URLs grant access to the runtime, so treat them like passwords. Paired clients get their own revocable grants. Restarting the container generates a fresh link but does not unpair existing clients.

Environment variables: `ORCA_PAIRING_ADDRESS` (the address clients dial, e.g. `wss://ai.example.net`), `ORCA_PORT` (`6768`), `ORCA_WORKDIR` (`/home/projects`), `ORCA_SERVE_RUNTIME` (`electron`; only this runtime serves the browser web client) and `ORCA_MOBILE_PAIRING` (`0`; `ORCA_MOBILE_PAIRING=1 docker compose up -d orca` issues a mobile-scoped offer instead of the runtime one, without a web URL).

Each link mints one device grant, so pair each device (desktop, browser, phone) from a fresh link: restart the container to get a new one. The mobile app accepts the regular runtime pairing URL by QR or by "Paste code instead".

Agent logins are done after deployment from Orca's terminals or from a shell in the container: `claude` → `/login`, `opencode auth login`, or `orca account add --agent claude`.

To update Orca, Claude Code and OpenCode, rebuild the image (`--no-cache`) and recreate the container. Their self-updaters are disabled.

## Credits &amp; Attribution

- [RockyLinux Docker Repository](https://hub.docker.com/u/rockylinux)
- [Remi's RPM Repository](https://rpms.remirepo.net)