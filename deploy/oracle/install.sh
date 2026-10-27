#!/usr/bin/env bash
set -euo pipefail
umask 077

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run with sudo: sudo bash install.sh <public-hostname>" >&2
  exit 1
fi
PUBLIC_HOST="${1:-}"
if [[ ! "$PUBLIC_HOST" =~ ^[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?$ ]] || [[ "$PUBLIC_HOST" != *.* ]]; then
  echo "Provide a DNS hostname pointing to this VM, without https:// or a path." >&2
  exit 1
fi
SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_DIR=/opt/rolemint
for required in compose.yaml Caddyfile web/index.html; do
  [[ -f "$SOURCE_DIR/$required" ]] || { echo "Missing $required" >&2; exit 1; }
done

# Small Always Free AMD instances need swap for Chromium and the Python API.
memory_kb="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
if (( memory_kb < 2097152 )) && ! swapon --show=NAME --noheadings | grep -q .; then
  if [[ ! -e /swapfile ]]; then
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
  fi
  swapon /swapfile
  grep -q '^/swapfile ' /etc/fstab || printf '/swapfile none swap sw 0 0\n' >> /etc/fstab
fi

if ! command -v docker >/dev/null 2>&1; then
  . /etc/os-release
  case "$ID" in
    ubuntu|debian) ;;
    *) echo "Automatic Docker installation supports Ubuntu/Debian only. Install Docker Engine and Compose first." >&2; exit 1 ;;
  esac
  apt-get update
  apt-get install -y ca-certificates curl openssl
  installer="$(mktemp)"
  trap 'rm -f "$installer"' EXIT
  curl -fsSL https://get.docker.com -o "$installer"
  sh "$installer"
fi
docker compose version >/dev/null
command -v openssl >/dev/null
systemctl enable --now docker
install -d -m 700 "$DEPLOY_DIR"
install -m 644 "$SOURCE_DIR/compose.yaml" "$DEPLOY_DIR/compose.yaml"
install -m 644 "$SOURCE_DIR/Caddyfile" "$DEPLOY_DIR/Caddyfile"
install -d -m 755 "$DEPLOY_DIR/web"
install -m 644 "$SOURCE_DIR/web/index.html" "$DEPLOY_DIR/web/index.html"

if [[ ! -f "$DEPLOY_DIR/.env" ]]; then
  password="$(openssl rand -hex 24)"
  hash="$(printf '%s\n' "$password" | docker run --rm -i caddy:2 caddy hash-password)"
  {
    printf 'PUBLIC_HOST=%s\n' "$PUBLIC_HOST"
    printf 'PUBLIC_URL=https://%s\n' "$PUBLIC_HOST"
    printf 'ADMIN_USER=shaswat\n'
    printf "ADMIN_PASSWORD_HASH='%s'\n" "$hash"
  } > "$DEPLOY_DIR/.env"
  {
    printf 'Site: https://%s\n' "$PUBLIC_HOST"
    printf 'Username: shaswat\n'
    printf 'Password: %s\n' "$password"
  } > "$DEPLOY_DIR/credentials.txt"
  chmod 600 "$DEPLOY_DIR/.env" "$DEPLOY_DIR/credentials.txt"
  unset password hash
elif ! grep -Fxq "PUBLIC_HOST=$PUBLIC_HOST" "$DEPLOY_DIR/.env"; then
  echo "Existing configuration uses a different hostname. Preserved it; no services changed." >&2
  exit 1
fi

cd "$DEPLOY_DIR"
docker compose config --quiet
docker compose pull
docker compose up -d
docker compose ps
printf '\nRoleMint started at https://%s\n' "$PUBLIC_HOST"
echo "Login details are in /opt/rolemint/credentials.txt (root only)."
echo "Ensure Oracle VCN and VM firewall permit inbound TCP 80 and 443."
echo "Keep SSH restricted. The app and database are not published directly."
