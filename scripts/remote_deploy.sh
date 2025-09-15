#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="${APP_ROOT:-/var/www/html/my-react-app}"
TAR_PATH="${TAR_PATH:-/tmp/build.tar.gz}"
KEEP_RELEASES="${KEEP_RELEASES:-5}"

RELEASES_DIR="$APP_ROOT/releases"
TIMESTAMP="$(date +%s)"
NEW_RELEASE_DIR="$RELEASES_DIR/$TIMESTAMP"

log() { echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"; }

# Remember previous target (if any) for rollback
PREV_TARGET=""
if [ -e "$APP_ROOT/build" ] || [ -L "$APP_ROOT/build" ]; then
  PREV_TARGET="$(readlink -f "$APP_ROOT/build" || true)"
fi

rollback() {
  log "Deployment failed — running rollback"
  if [ -n "$PREV_TARGET" ] && [ -d "$PREV_TARGET" ]; then
    rm -f "$APP_ROOT/build" || true
    ln -s "$PREV_TARGET" "$APP_ROOT/build"
    log "Restored build symlink to $PREV_TARGET"
  else
    log "No previous release found; removing partial new release"
    rm -rf "$NEW_RELEASE_DIR" || true
  fi
  exit 1
}
trap rollback ERR

log "Preparing directories..."
mkdir -p "$RELEASES_DIR"
mkdir -p "$NEW_RELEASE_DIR"

log "Extracting $TAR_PATH -> $NEW_RELEASE_DIR"
tar -xzf "$TAR_PATH" -C "$NEW_RELEASE_DIR"

# Basic sanity check (fail => triggers rollback)
if [ ! -f "$NEW_RELEASE_DIR/index.html" ]; then
  log "Sanity check failed: index.html not found in new release"
  exit 1
fi

# Atomic symlink swap (create temp symlink then rename it over existing)
ln -s "$NEW_RELEASE_DIR" "$APP_ROOT/build_tmp"
mv -T "$APP_ROOT/build_tmp" "$APP_ROOT/build"
log "Switched $APP_ROOT/build -> $NEW_RELEASE_DIR"

# Optional post-deploy commands (uncomment/edit if needed)
# log "Running post-deploy actions..."
# sudo systemctl reload apache2 || true

# Cleanup older releases
cd "$RELEASES_DIR"
# keep the newest $KEEP_RELEASES; delete older
ls -1tr | head -n -"$KEEP_RELEASES" | xargs -r rm -rf --
log "Cleaned old releases, kept $KEEP_RELEASES."

log "Deployment finished successfully."
exit 0

