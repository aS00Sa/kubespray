#!/usr/bin/env bash
set -euo pipefail
KEY="${KEY:-$HOME/.ssh/id_ed25519}"
HOSTS=(
  192.168.25.61
  192.168.25.62
  192.168.25.63
  192.168.25.64
  192.168.25.65
  192.168.25.66
)
SSH_OPTS=(-i "$KEY" -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no)

for h in "${HOSTS[@]}"; do
  echo "=== $h ==="
  if ssh "${SSH_OPTS[@]}" "root@${h}" 'hostname; uptime -p; systemctl is-active kubelet 2>/dev/null || true'; then
    ssh "${SSH_OPTS[@]}" "root@${h}" 'test -x /usr/local/bin/kubectl && /usr/local/bin/kubectl get nodes -o wide 2>/dev/null | head -7 || echo "(kubectl/nodes skip)"' || true
  else
    echo "SSH FAILED"
  fi
  echo
done
