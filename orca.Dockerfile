# Orca IDE remote server (`orca-ide serve`) with Claude Code and OpenCode.
# Standalone (does not need the stack's `kernel` image).
FROM rockylinux:9
ARG ORCA_VERSION=latest
ARG NODE_STREAM=22
ARG UID=9000
ARG GID=9000
ARG USERNAME=nginx

# Base tooling, GitHub CLI (Orca uses `gh` for PRs, checks and repos), Node.js (the agent CLIs ship
# through npm) and Xvfb (Orca starts its own virtual display for the embedded browser when it finds one).
RUN echo 'fastestmirror=1' >> /etc/dnf/dnf.conf; echo 'max_parallel_downloads=8' >> /etc/dnf/dnf.conf; \
    dnf install -y dnf-plugins-core epel-release; dnf config-manager --set-enabled crb; \
    dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo; \
    dnf module enable -y nodejs:${NODE_STREAM}; \
    dnf install -y --allowerasing nodejs npm git gh openssh-clients curl jq ripgrep procps-ng which tar gzip xz unzip \
        findutils less vim-minimal util-linux shadow-utils hostname iproute glibc-langpack-en tzdata qrencode \
        xorg-x11-server-Xvfb xorg-x11-xauth dbus-daemon; \
    dnf clean all

# Docker CLI with the buildx and compose plugins (no engine): drives the host's daemon through the mounted
# /var/run/docker.sock, to test stack projects or build/run other images and containers.
RUN dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo; \
    dnf install -y docker-ce-cli docker-buildx-plugin docker-compose-plugin; \
    dnf clean all

# Orca IDE rpm (provides /usr/bin/orca-ide); dnf resolves the Electron runtime libraries it depends on.
RUN set -eux; arch=$(uname -m); ver=$ORCA_VERSION; \
    if [ "$ver" = latest ]; then \
        ver=$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/stablyai/orca/releases/latest | sed 's#.*/tag/v##'); \
    fi; \
    dnf install -y "https://github.com/stablyai/orca/releases/download/v${ver}/orca-ide-${ver}.${arch}.rpm"; \
    dnf clean all; ln -s /usr/bin/orca-ide /usr/local/bin/orca

# Claude Code and OpenCode 2 (`@opencode/cli`; `opencode-ai` is the 1.x line), installed system-wide so a fresh or persisted home volume never shadows them.
# Self-updaters are off since the runtime user can't write here; rebuild the image to update.
RUN npm install -g @anthropic-ai/claude-code @opencode/cli && npm cache clean --force

RUN groupadd --gid $GID $USERNAME; useradd --uid $UID --gid $GID --create-home --shell /bin/bash $USERNAME; \
    git config --system --add safe.directory '*'
COPY resources/orca/entrypoint.sh /usr/local/bin/orca-entrypoint
COPY resources/orca/orca-urls /usr/local/bin/orca-urls

# The Electron serve runtime is the one that also serves the browser web client (orcad, the default, doesn't);
# its Chromium sandbox can't create namespaces inside an unprivileged container, hence ELECTRON_DISABLE_SANDBOX.
ENV ORCA_USER=$USERNAME \
    ORCA_PORT=6768 \
    ORCA_INFO_DIR=/var/lib/orca-info \
    ORCA_WORKDIR=/home/projects \
    ORCA_SERVE_RUNTIME=electron \
    ELECTRON_DISABLE_SANDBOX=1 \
    DISABLE_AUTOUPDATER=1 \
    OPENCODE_DISABLE_AUTOUPDATE=1 \
    LANG=en_US.UTF-8
EXPOSE 6768
HEALTHCHECK --interval=30s --timeout=5s --start-period=90s CMD curl -so /dev/null "http://127.0.0.1:${ORCA_PORT}/" || exit 1
# Starts as root only to fix volume ownership, then drops to $ORCA_USER before launching Orca.
ENTRYPOINT ["/usr/local/bin/orca-entrypoint"]
