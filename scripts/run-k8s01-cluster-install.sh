#!/usr/bin/env bash
# cluster.yml with timestamped log in repo root (inventory-k8s01-btnx-dev-cluster-YYYYMMDD-HHMM.log)
set -u
cd "$(dirname "$0")/.."
# shellcheck source=scripts/lib/k8s01-btnx-dev-log.sh
source scripts/run-k8s01-log.sh
source .venv/bin/activate
export ANSIBLE_CONFIG="$PWD/ansible.cfg"

LOG="$(k8s01_log_path cluster)"
k8s01_log_banner "$LOG" "cluster.yml"

set +e
ansible-playbook -i inventory/k8s01-btnx-dev/inventory.ini cluster.yml 2>&1 | tee -a "$LOG"
rc=${PIPESTATUS[0]}
set -e

k8s01_log_finish "$LOG" "$rc"
exit "$rc"
