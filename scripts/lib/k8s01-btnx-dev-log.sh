# Shared logging helpers for k8s01-btnx-dev playbooks (source, do not execute).
k8s01_log_path() {
  local prefix="$1"
  echo "inventory-k8s01-btnx-dev-${prefix}-$(date +%Y%m%d-%H%M).log"
}

k8s01_log_banner() {
  local log="$1"
  local playbook="$2"
  echo "Logging ${playbook} -> $(pwd)/${log}"
  {
    echo "========== k8s01-btnx-dev ${playbook} $(date -Iseconds) =========="
    echo "PWD=$(pwd)"
    echo "ANSIBLE_CONFIG=${ANSIBLE_CONFIG:-unset}"
    echo "INVENTORY=inventory/k8s01-btnx-dev/inventory.ini"
  } | tee "$log"
}

k8s01_log_finish() {
  local log="$1"
  local rc="$2"
  {
    echo "EXIT=$rc"
    echo "========== PLAY RECAP =========="
  } | tee -a "$log"
  grep -A8 'PLAY RECAP' "$log" | tail -10 | tee -a "$log" || true
  echo "Full log: $(pwd)/${log}"
}
