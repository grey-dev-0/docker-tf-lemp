#!/bin/bash
# Starts `orca-ide serve` as $ORCA_USER and records the web / pairing URLs it prints
# into $ORCA_INFO_DIR/urls.txt (read them back with `orca-urls`).
set -euo pipefail

ORCA_PORT=${ORCA_PORT:-6768}
ORCA_INFO_DIR=${ORCA_INFO_DIR:-/var/lib/orca-info}
info_file="$ORCA_INFO_DIR/urls.txt"

if [ "$(id -u)" = 0 ]; then
    uid=$(id -u "$ORCA_USER"); gid=$(id -g "$ORCA_USER")
    home=$(getent passwd "$ORCA_USER" | cut -d: -f6)
    mkdir -p "$home" "$ORCA_INFO_DIR"
    # Fresh volumes arrive empty and/or root-owned.
    # Why: /etc/skel is root-owned, so its copy needs chowning even when the home dir itself is already $uid's.
    [ -f "$home/.bashrc" ] || { cp -a /etc/skel/. "$home/"; chown -R "$uid:$gid" "$home"; }
    [ "$(stat -c %u "$home")" = "$uid" ] || chown -R "$uid:$gid" "$home"
    chown "$uid:$gid" "$ORCA_INFO_DIR"; chmod 700 "$ORCA_INFO_DIR"
    # Host docker socket (when mounted): its group id differs per host, so add $ORCA_USER to a group
    # with that id here instead of at build time. --init-groups below then picks it up.
    sock=/var/run/docker.sock
    if [ -S "$sock" ]; then
        sock_gid=$(stat -c %g "$sock")
        if [ "$sock_gid" = 0 ]; then
            echo "orca-entrypoint: $sock is owned by group root; not granting $ORCA_USER access to it" >&2
        else
            sock_group=$(getent group "$sock_gid" | cut -d: -f1 || true)
            [ -n "$sock_group" ] || { sock_group=docker-host; groupadd --gid "$sock_gid" "$sock_group"; }
            [[ " $(id -nG "$ORCA_USER") " == *" $sock_group "* ]] || usermod -aG "$sock_group" "$ORCA_USER"
        fi
    fi
    exec setpriv --reuid="$uid" --regid="$gid" --init-groups \
        env HOME="$home" USER="$ORCA_USER" LOGNAME="$ORCA_USER" "$0" "$@"
fi

cd "${ORCA_WORKDIR:-$HOME}" 2>/dev/null || cd "$HOME"
rm -f "$info_file"

args=(serve --port "$ORCA_PORT")
[ -n "${ORCA_PAIRING_ADDRESS:-}" ] && args+=(--pairing-address "$ORCA_PAIRING_ADDRESS")
# Mobile-scoped offer instead of the runtime one (no web client URL in this mode).
[ "${ORCA_MOBILE_PAIRING:-0}" = 1 ] && args+=(--mobile-pairing)
args+=("$@")

record() {
    local web='' pairing='' line
    while IFS= read -r line; do
        printf '%s\n' "$line"
        case $line in
            'Web client URL: '*) web=${line#Web client URL: } ;;
            'Pairing URL: '*) pairing=${line#Pairing URL: } ;;
            *) continue ;;
        esac
        # Why: the URLs embed a device token; keep the file owner-only.
        (umask 077; cat > "$info_file.tmp" <<EOF
# Orca server access, written $(date -u +%FT%TZ). Treat these like passwords.
# Pairing URL: Orca desktop -> Settings -> Remote Orca Servers -> Add Server,
# or Orca mobile -> Pair -> scan the QR from "orca-urls --qr" (or "Paste code instead").
${web:+# Web client: open in a browser.
WEB_URL=$web}
PAIRING_URL=${pairing}
EOF
        mv -f "$info_file.tmp" "$info_file")
    done
}

exec orca-ide "${args[@]}" > >(record) 2>&1
