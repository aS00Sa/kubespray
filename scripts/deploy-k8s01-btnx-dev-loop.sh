#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
[ -f .venv/bin/activate ] && source .venv/bin/activate
export ANSIBLE_CONFIG="$(cd "$(dirname "$0")/.." && pwd)/ansible.cfg"
INV="-i inventory/k8s01-btnx-dev/inventory.ini"
KEY="--private-key ~/.ssh/id_ed25519"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-10}"

recap_has_failures() {
  local log="$1"
  awk '/PLAY RECAP/,0' "$log" | grep -E 'failed=[1-9]' | grep -q .
}

attempt=0
while [ "$attempt" -lt "$MAX_ATTEMPTS" ]; do
  attempt=$((attempt + 1))
  LOG="inventory-k8s01-btnx-dev-cluster-$(date +%Y%m%d-%H%M)-a${attempt}.log"
  echo "========== Attempt ${attempt}/${MAX_ATTEMPTS}: cluster.yml -> ${LOG} =========="

  set +e
  ansible-playbook $INV $KEY -b cluster.yml -vv 2>&1 | tee "$LOG"
  rc=${PIPESTATUS[0]}
  set -e

  if [ "$rc" -eq 0 ] && ! recap_has_failures "$LOG"; then
    echo "========== SUCCESS on attempt ${attempt} =========="
    exit 0
  fi

  echo "========== FAILED (rc=${rc}); reset.yml then retry =========="
  RESET_LOG="inventory-k8s01-btnx-dev-reset-$(date +%Y%m%d-%H%M)-a${attempt}.log"
  ansible-playbook $INV $KEY -b reset.yml -e reset_confirmation=yes 2>&1 | tee "$RESET_LOG"
done

echo "========== Gave up after ${MAX_ATTEMPTS} attempts =========="
exit 1
