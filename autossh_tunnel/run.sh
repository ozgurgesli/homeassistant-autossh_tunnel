#!/bin/sh
echo "Starting"
set -e

OPTS="/data/options.json"

USER="$(jq -r '.user' "$OPTS")"
HOST="$(jq -r '.host' "$OPTS")"
REMOTE_BIND="$(jq -r '.remote_bind' "$OPTS")"
LOCAL_TARGET="$(jq -r '.local_target' "$OPTS")"

TARGET_HOST="$(echo "$LOCAL_TARGET" | cut -d: -f1)"
TARGET_PORT="$(echo "$LOCAL_TARGET" | cut -d: -f2)"

if [ -z "$TARGET_HOST" ] || [ -z "$TARGET_PORT" ]; then
  echo "ERROR: local_target is invalid: '$LOCAL_TARGET' (expected host:port)"
  exit 1
fi

SSH_DIR="/config/.ssh"
KEY="$SSH_DIR/id_ed25519_ha_tunnel"
PUB="$KEY.pub"
KNOWN="$SSH_DIR/known_hosts"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Create keypair if missing (persistent across rebuilds if /config restored)
if [ ! -f "$KEY" ] || [ ! -f "$PUB" ]; then
  echo "No persistent SSH key found at $KEY. Generating a new ed25519 keypair..."
  ssh-keygen -t ed25519 -f "$KEY" -N "" >/dev/null
  chmod 600 "$KEY"
  chmod 644 "$PUB"
  echo ""
  echo "=== ACTION REQUIRED on ${HOST} (user ${USER}) ==="
  echo "Add this public key to: /home/${USER}/.ssh/authorized_keys"
  echo ""
  cat "$PUB"
  echo "=== END PUBLIC KEY ==="
  echo ""
else
  chmod 600 "$KEY" || true
  chmod 644 "$PUB" || true
fi

# Ensure known_hosts exists and contains host key (non-interactive host key verification)
echo "Touching to create known file"
touch "$KNOWN"
chmod 644 "$KNOWN"
echo "Done"

# Add host key if not already present
if ! ssh-keygen -F "$HOST" -f "$KNOWN" >/dev/null 2>&1; then
  echo "Seeding known_hosts for $HOST ..."
  ssh-keyscan -H "$HOST" >> "$KNOWN" 2>/dev/null || true
fi

echo "Waiting for HA at ${TARGET_HOST}:${TARGET_PORT} ..."
until nc -z "$TARGET_HOST" "$TARGET_PORT"; do
  sleep 2
done

echo "Starting reverse tunnel on ${HOST} (${REMOTE_BIND} -> ${LOCAL_TARGET})"
exec autossh -M 0 -N \
  -i "$KEY" \
  -o "UserKnownHostsFile=$KNOWN" \
  -o "StrictHostKeyChecking=yes" \
  -o "ServerAliveInterval=30" \
  -o "ServerAliveCountMax=3" \
  -o "ExitOnForwardFailure=yes" \
  -R "${REMOTE_BIND}:${LOCAL_TARGET}" \
  "${USER}@${HOST}"

echo "End of autossh_tunnel run"
