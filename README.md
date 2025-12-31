# Docker LEMP stack (macOS / OrbStack)

This repository includes a docker compose plan which builds a dockerized LEMP stack for macOS devices running OrbStack. For the Linux version, see the `dev-compose` branch. For Terraform-based infrastructure, check the `main` branch.

## Services included in this stack

- `php 8.1.x` including all extensions required by `Laravel 8.x` and newer
- `php 8.2.x` for newer projects
- `nginx` latest `stable` release
- `MariaDB 11.4.x`
- `NodeJS 20.x` (included in `php` container)
- `Rocky Linux 9` (base image for `php` and `nginx` services)
- `PhpMyAdmin` for database management
- `DNS` service for local development domains

## Prerequisites

- **OrbStack** - A lightweight Docker engine for macOS. Install from [orbstack.dev](https://orbstack.dev)
- **Git** - For cloning this repository
- **Homebrew** (optional) - For easier mkcert management

## Setup & Usage

### Initial Setup

1. Clone and navigate to this repository:
   ```bash
   git clone <repository-url> docker-lemp
   cd docker-lemp
   git checkout compose-orbstack
   ```

2. (Optional) Customize `PROJECTS_ROOT` in `.env`:
   ```bash
   # Default is ~/Projects
   # Change PROJECTS_ROOT to point to your projects directory
   nano .env
   ```

3. Run the initialization script:
   ```bash
   ./init
   ```

The initialization script will:
- Build all Docker images
- Start the containers
- Extract and install mkcert for SSL certificate generation
- Create the initial lemp project

**Note:** This setup only needs to run once. The stack will automatically restart when your macOS system or OrbStack starts.

## Customizing Project(s) Location

By default, projects are stored in `~/Projects`. To use a different location:

1. Edit the `.env` file
2. Change the `PROJECTS_ROOT` value to your preferred absolute path
3. Restart the containers: `docker compose restart`

## Customizing Network Settings

The stack containers are bound to a custom network with subnet `100.100.10.0/24`. To modify these settings:

1. Edit `docker-compose.yml`
2. Change the `subnet` value in the `networks.development.ipam.config` section
3. Update the `ipv4_address` for each service accordingly
4. Restart the stack: `docker compose restart`

## OrbStack Considerations

- **Volume Mounts:** Paths are automatically translated by OrbStack. Use standard macOS paths (e.g., `~/Projects`)
- **DNS Resolution:** The local DNS container handles *.test domains for development
- **Certificate Management:** mkcert is extracted from the DNS container and installed on your macOS
- **Performance:** OrbStack provides near-native performance for Docker workloads on Apple Silicon

## Accessing Services

Once running, access the services via:

- **Web:** http://lemp.test (or your configured domain)
- **PhpMyAdmin:** http://phpmyadmin.test
- **Database:** localhost, port 3306 (if exposed)

## Troubleshooting

### Container fails to start
- Ensure OrbStack is running: Open the OrbStack menu and verify the status
- Check logs: `docker compose logs -f <service-name>`

### mkcert installation fails
- Ensure you have Keychain access on your macOS
- Try running `./mkcert -install` manually after the init script completes

### Port conflicts
- Check if other services are using required ports
- Modify port mappings in `docker-compose.yml` if needed

### Volume mount issues
- OrbStack uses automatic path translation. Ensure paths in `.env` use standard macOS format
- Restart OrbStack if volume mounts aren't working

## Credits & Attribution

- [OrbStack](https://orbstack.dev) - Lightweight Docker/Linux engine for macOS
- [RockyLinux Docker Repository](https://hub.docker.com/u/rockylinux)
- [Remi's RPM Repository](https://rpms.remirepo.net)
- [mkcert](https://github.com/FiloSottile/mkcert) - Simple CA for local HTTPS development
