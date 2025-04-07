#!/bin/bash

MAP_FILE="${1:-/etc/auto.logs}"
AUTOMOUNT_BASE="${2:-/mnt/logs}"
TIMEOUT=5

errors=()
while read -r key rest; do
  mount_path="${AUTOMOUNT_BASE}/${key}"
  if ! timeout $TIMEOUT ls "$mount_path" >/dev/null 2>&1; then
    errors+=("$mount_path")
  fi
done < <(grep 'fstype=nfs' "$MAP_FILE")

if [ ${#errors[@]} -eq 0 ]; then
  echo "OK: All NFS mounts under $AUTOMOUNT_BASE are accessible"
  exit 0
else
  echo "CRITICAL: Unavailable mounts: ${errors[*]}"
  exit 2
fi
