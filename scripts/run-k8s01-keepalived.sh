#!/usr/bin/env bash
# playbooks/k8s01-keepalived.yml — VIP 155.212.177.145 on ens19 (m1–m3)
set -u
cd "$(dirname "$0")/.."
# shellcheck source=scripts/lib/k8s01-btnx-dev-log.sh
source scripts/run-k8s01-log.sh
source .venv/bin/activate
export ANSIBLE_CONFIG="$PWD/ansible.cfg"

LOG="$(k8s01_log_path keepalived)"
k8s01_log_banner "$LOG" "keepalived.yml"

set +e
ansible-playbook -i inventory/k8s01-btnx-dev/inventory.ini scripts/run-k8s01-keepalived.yml 2>&1 | tee -a "$LOG"
rc=${PIPESTATUS[0]}
set -e

k8s01_log_finish "$LOG" "$rc"
exit "$rc"
