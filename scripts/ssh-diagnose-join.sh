#!/usr/bin/env bash
KEY="${KEY:-$HOME/.ssh/id_ed25519}"
for h in 192.168.25.61 192.168.25.63; do
  echo "=== $h ==="
  ssh -i "$KEY" -o StrictHostKeyChecking=no "root@${h}" '
    echo "--- listen 6443 ---"
    ss -lntp | grep 6443 || true
    echo "--- manifests ---"
    ls -la /etc/kubernetes/manifests/ 2>/dev/null || true
    echo "--- kubelet ---"
    systemctl is-active kubelet || true
    echo "--- ca.crt ---"
    ls -la /etc/kubernetes/ssl/ca.crt 2>/dev/null || ls -la /etc/kubernetes/pki/ca.crt 2>/dev/null || true
    echo "--- curl localhost ---"
    curl -k -m 3 https://127.0.0.1:6443/healthz 2>&1 || true
  '
done
