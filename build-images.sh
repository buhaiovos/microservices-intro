#!/usr/bin/env bash
# Builds Docker images for resources-service and songs-service.
# Usage: ./build-images.sh <version>
set -euo pipefail

log() { echo "[$(date '+%H:%M:%S')] $*"; }

if [[ $# -ne 1 || -z "$1" ]]; then
  echo "Usage: $0 <version>" >&2
  exit 1
fi
VERSION="$1"

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

# service-dir:image-name
SERVICES=(
  "resources-service:resources-image"
  "songs-service:songs-image"
)

for entry in "${SERVICES[@]}"; do
  service="${entry%%:*}"
  image="${entry##*:}"

  log "=== [$service] Step 1: checking for jar in $service/build/libs ==="
  if compgen -G "$service/build/libs/*.jar" > /dev/null; then
    log "[$service] Jar found: $(ls "$service"/build/libs/*.jar)"
  else
    log "[$service] Step 2: jar not found, running ./gradlew :$service:build"
    ./gradlew ":$service:build"
    log "[$service] Gradle build finished"
  fi

  log "=== [$service] Step 3: building image $image:$VERSION ==="
  docker build -t "$image:$VERSION" "$service"
  log "[$service] Image $image:$VERSION built"
done

log "=== All images built successfully (version $VERSION) ==="
