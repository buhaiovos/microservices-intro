#!/usr/bin/env bash
# Deletes everything created by apply-k8s.sh, in reverse dependency order.
# Usage: ./teardown-k8s.sh [-y] [extra kubectl delete args, e.g. --dry-run=server]
#   -y  skip confirmation prompt
set -euo pipefail
shopt -s nullglob

log() { echo "[$(date '+%H:%M:%S')] $*"; }

K8S_DIR="$(cd "$(dirname "$0")" && pwd)/k8s-resources"
NAMESPACE="k8s-program-buhaiovos"

ASSUME_YES=false
if [[ "${1:-}" == "-y" ]]; then ASSUME_YES=true; shift; fi
EXTRA_ARGS=("$@")

if ! $ASSUME_YES; then
  read -r -p "This deletes all $NAMESPACE resources, including DB data (PVCs). Continue? [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]] || { log "Aborted"; exit 0; }
fi

delete_step() {
  local step="$1"; shift
  local files=("$@")
  log "=== Step $step ==="
  if [[ ${#files[@]} -eq 0 ]]; then
    log "No files found, skipping"
    return
  fi
  for f in "${files[@]}"; do
    log "Deleting $(basename "$f")"
    kubectl delete -f "$f" --ignore-not-found ${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}
  done
}

cd "$K8S_DIR"

delete_step "1: deployments"               *-deployment.yaml
delete_step "2: stateful sets"             *-statefulset.yaml

# PVCs created by StatefulSet volumeClaimTemplates are not removed with the StatefulSet
log "=== Step 3: stateful set PVCs (volumeClaimTemplates) ==="
sts_pvcs=$(kubectl -n "$NAMESPACE" get pvc -o name 2>/dev/null | grep '/pg-volume-' || true)
if [[ -n "$sts_pvcs" ]]; then
  for pvc in $sts_pvcs; do
    log "Deleting $pvc"
    kubectl -n "$NAMESPACE" delete "$pvc" --ignore-not-found ${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}
  done
else
  log "No stateful set PVCs found, skipping"
fi

delete_step "4: services"                  *-service.yaml
delete_step "5: config maps & secrets"     *-config-map.yaml *-secret.yaml
delete_step "6: persistent volume claim"   persistent-volume-claim.yaml
delete_step "7: persistent volume"         persistent-volume.yaml
delete_step "8: storage class"             storage-class.yaml
delete_step "9: namespace"                 k8s-namespace.yaml

log "=== Teardown complete ==="
