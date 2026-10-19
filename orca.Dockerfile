# Orca IDE remote server (`orca-ide serve`) with Claude Code and OpenCode.
# Standalone (does not need the stack's `kernel` image).
FROM rockylinux:9
ARG ORCA_VERSION=latest
ARG ORCA_WEB_CLIENT=0
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
# Without ORCA_WEB_CLIENT=1 the browser web client (web IDE) goes: since 1.4.230 `orca serve` hands it to orcad whenever
# out/web/web-index.html exists, and there's no flag to stop it. Paired clients are unaffected; the mobile app's
# bundle is out/mobile-web.
RUN set -eux; arch=$(uname -m); ver=$ORCA_VERSION; \
    if [ "$ver" = latest ]; then \
        ver=$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/stablyai/orca/releases/latest | sed 's#.*/tag/v##'); \
    fi; \
    dnf install -y "https://github.com/stablyai/orca/releases/download/v${ver}/orca-ide-${ver}.${arch}.rpm"; \
    dnf clean all; ln -s /usr/bin/orca-ide /usr/local/bin/orca; \
    [ "$ORCA_WEB_CLIENT" = 1 ] || rm -rf /opt/Orca/resources/app.asar.unpacked/out/web

# Claude Code and OpenCode 2 (`@opencode/cli`; `opencode-ai` is the 1.x line), installed system-wide so a fresh or persisted home volume never shadows them.
# Self-updaters are off since the runtime user can't write here; rebuild the image to update.
RUN npm install -g @anthropic-ai/claude-code @opencode/cli && npm cache clean --force

# Home defaults, seeded into /etc/skel before the user exists so useradd copies them into the image's home, and the
# entrypoint into a fresh volume: Orca's skills (pinned to this Orca build's commit; for Claude Code and, through
# ~/.agents/skills, OpenCode), plus OpenCode's unattended `auto` agent and the opencode-quota plugin.
COPY resources/orca/skel/ /etc/skel/
RUN HOME=/etc/skel npm_config_cache=/tmp/npm-cache \
        orca-ide skills install --skill computer-use --skill orca-cli --skill orchestration && \
    rm -rf /tmp/npm-cache /etc/skel/.cache

RUN groupadd --gid $GID $USERNAME; useradd --uid $UID --gid $GID --create-home --shell /bin/bash $USERNAME; \
    git config --system --add safe.directory '*'
COPY resources/orca/entrypoint.sh /usr/local/bin/orca-entrypoint
COPY resources/orca/orca-urls /usr/local/bin/orca-urls

# orcad (Orca's default serve runtime) serves paired clients only here: no embedded browser, and no browser web
# client since the image drops it (see ORCA_WEB_CLIENT above). ORCA_SERVE_RUNTIME=electron adds the embedded browser,
# and the web client when built with ORCA_WEB_CLIENT=1; its Chromium sandbox can't create namespaces inside an
# unprivileged container, hence ELECTRON_DISABLE_SANDBOX.
ENV ORCA_USER=$USERNAME \
    ORCA_PORT=6768 \
    ORCA_INFO_DIR=/var/lib/orca-info \
    ORCA_WORKDIR=/home/projects \
    ORCA_SERVE_RUNTIME=orcad \
    ELECTRON_DISABLE_SANDBOX=1 \
    DISABLE_AUTOUPDATER=1 \
    OPENCODE_DISABLE_AUTOUPDATE=1 \
    LANG=en_US.UTF-8
EXPOSE 6768
# A TCP check: without the web client, orcad answers plain HTTP requests with a 404 at best.
HEALTHCHECK --interval=30s --timeout=5s --start-period=90s CMD bash -c "</dev/tcp/127.0.0.1/${ORCA_PORT}" || exit 1
# Starts as root only to fix volume ownership, then drops to $ORCA_USER before launching Orca.
ENTRYPOINT ["/usr/local/bin/orca-entrypoint"]
