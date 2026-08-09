#!/usr/bin/env bash
##
## capture_weaver_photos.sh — The Weaver gameplay photo pack (menu + loop beats).
##
## Writes PNGs to docs/WEAVER/media/photos/ and refreshes docs/WEAVER/screenshots/.
## Requires Godot 4.3+ on PATH (or GODOT=...) and xvfb-run.
##
## Usage:
##   GODOT=/path/to/godot ./game/echo_lattice/tools/capture_weaver_photos.sh
##
set -euo pipefail

GODOT="${GODOT:-godot}"
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$HERE/.." && pwd)"
REPO_ROOT="$(cd -- "$PROJECT_DIR/../.." && pwd)"
OUT_DIR="$REPO_ROOT/docs/WEAVER/media/photos"
# SEC-03: --out must stay under the Godot project root (not /tmp).
STAGING="$PROJECT_DIR/.capture_staging/weaver_photos"
OVERRIDE="$PROJECT_DIR/override.cfg"
WIDTH="${CAPTURE_WIDTH:-1920}"
HEIGHT="${CAPTURE_HEIGHT:-1080}"

cleanup() {
  rm -rf "$PROJECT_DIR/.capture_staging"
  rm -f "$OVERRIDE"
}
trap cleanup EXIT

rm -rf "$STAGING"
mkdir -p "$STAGING" "$OUT_DIR"
rm -rf "$HOME/.local/share/godot/app_userdata/Echo Lattice" \
       "$HOME/.local/share/godot/app_userdata/The Weaver" || true

# Brand menu needs real IBM Plex faces (often Git LFS pointers until pulled).
if command -v git >/dev/null 2>&1 && [[ -d "$REPO_ROOT/.git" ]]; then
  (
    cd "$REPO_ROOT"
    if file game/echo_lattice/fonts/latin/IBMPlexSansCondensed-Bold.ttf 2>/dev/null | grep -q 'ASCII text'; then
      echo ">> git lfs pull fonts/latin"
      git lfs pull --include "game/echo_lattice/fonts/**" || true
    fi
  )
fi
if file "$PROJECT_DIR/fonts/latin/IBMPlexSansCondensed-Bold.ttf" 2>/dev/null | grep -q 'ASCII text'; then
  echo "LFS fonts still missing — run: git lfs pull --include 'game/echo_lattice/fonts/**'" >&2
  exit 1
fi

# Force a clean 16:9 viewport for this capture pass only.
cat > "$OVERRIDE" <<EOF
[display]
window/size/viewport_width=${WIDTH}
window/size/viewport_height=${HEIGHT}
window/size/window_width_override=${WIDTH}
window/size/window_height_override=${HEIGHT}
EOF

echo ">> weaver-photos (${WIDTH}x${HEIGHT})"
xvfb-run -a -s "-screen 0 ${WIDTH}x${HEIGHT}x24" \
  "$GODOT" --path "$PROJECT_DIR" -- --weaver-photos --out ".capture_staging/weaver_photos"

# Promote staged stills into the docs photo pack.
for name in \
  01_menu_yard_enter.png \
  02_gather.png \
  03_combine.png \
  04_weave.png \
  05_structure_emit.png \
  06_wider_yard.png
do
  if [[ ! -f "$STAGING/$name" ]]; then
    echo "missing staged photo: $name" >&2
    exit 1
  fi
  cp "$STAGING/$name" "$OUT_DIR/$name"
done

echo
echo "wrote Weaver photo pack (${WIDTH}x${HEIGHT}):"
ls -1 "$OUT_DIR"/*.png
for f in "$OUT_DIR"/*.png; do
  file "$f"
done
