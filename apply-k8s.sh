#!/usr/bin/env bash
# Applies k8s manifests from k8s-resources/ in dependency order.
# Usage: ./apply-k8s.sh [extra kubectl apply args, e.g. --dry-run=server]
set -euo pipefail
shopt -s nullglob

log() { echo "[$(date '+%H:%M:%S')] $*"; }

K8S_DIR="$(cd "$(dirname "$0")" && pwd)/k8s-resources"
EXTRA_ARGS=("$@")

apply_step() {
  local step="$1"; shift
  local files=("$@")
  log "=== Step $step ==="
  if [[ ${#files[@]} -eq 0 ]]; then
    log "No files found, skipping"
    return
  fi
  for f in "${files[@]}"; do
    log "Applying $(basename "$f")"
    kubectl apply -f "$f" ${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}
  done
}

cd "$K8S_DIR"

apply_step "0: namespace"                 k8s-namespace.yaml
apply_step "1: storage class"             storage-class.yaml
apply_step "2: persistent volume"         persistent-volume.yaml
apply_step "3: persistent volume claim"   persistent-volume-claim.yaml
apply_step "4: config maps & secrets"     *-config-map.yaml *-secret.yaml
apply_step "5: services"                  *-service.yaml
apply_step "6: stateful sets"             *-statefulset.yaml
apply_step "7: deployments"               *-deployment.yaml

log "=== All manifests applied ==="
