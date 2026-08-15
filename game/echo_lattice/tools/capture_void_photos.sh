#!/usr/bin/env bash
##
## capture_void_photos.sh — VOID era visual proof (not shed photos_v2).
##
## Captures:
##   echo_lattice void_boot — black void, spark, after typing
##   weaver void_speak     — typed words seated as matter
##
## Writes PNGs to docs/WEAVER/media/photos_void/ (does NOT touch photos_v2).
## Requires Godot 4.3+ on PATH (or GODOT=...) and xvfb-run.
##
## Usage:
##   GODOT=/path/to/godot ./game/echo_lattice/tools/capture_void_photos.sh
##
set -euo pipefail

GODOT="${GODOT:-godot}"
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LATTICE_DIR="$(cd -- "$HERE/.." && pwd)"
WEAVER_DIR="$(cd -- "$LATTICE_DIR/../weaver" && pwd)"
REPO_ROOT="$(cd -- "$LATTICE_DIR/../.." && pwd)"
OUT_DIR="$REPO_ROOT/docs/WEAVER/media/photos_void"
LATTICE_STAGING="$LATTICE_DIR/.capture_staging/photos_void"
WEAVER_STAGING="$WEAVER_DIR/.capture_staging/photos_void"
LATTICE_OVERRIDE="$LATTICE_DIR/override.cfg"
WEAVER_OVERRIDE="$WEAVER_DIR/override.cfg"
WIDTH="${CAPTURE_WIDTH:-1920}"
HEIGHT="${CAPTURE_HEIGHT:-1080}"

cleanup() {
  rm -rf "$LATTICE_DIR/.capture_staging" "$WEAVER_DIR/.capture_staging"
  rm -f "$LATTICE_OVERRIDE" "$WEAVER_OVERRIDE"
}
trap cleanup EXIT

rm -rf "$LATTICE_STAGING" "$WEAVER_STAGING"
mkdir -p "$LATTICE_STAGING" "$WEAVER_STAGING" "$OUT_DIR"
rm -rf "$HOME/.local/share/godot/app_userdata/Echo Lattice" \
       "$HOME/.local/share/godot/app_userdata/The Weaver" || true

if command -v git >/dev/null 2>&1 && [[ -d "$REPO_ROOT/.git" ]]; then
  (
    cd "$REPO_ROOT"
    if file game/echo_lattice/fonts/latin/IBMPlexSansCondensed-Bold.ttf 2>/dev/null | grep -q 'ASCII text'; then
      echo ">> git lfs pull fonts/latin"
      git lfs pull --include "game/echo_lattice/fonts/**" || true
    fi
  )
fi

write_override() {
  local target="$1"
  cat > "$target" <<EOF
[display]
window/size/viewport_width=${WIDTH}
window/size/viewport_height=${HEIGHT}
window/size/window_width_override=${WIDTH}
window/size/window_height_override=${HEIGHT}
EOF
}

write_override "$LATTICE_OVERRIDE"
write_override "$WEAVER_OVERRIDE"

echo ">> void-photos lattice boot (${WIDTH}x${HEIGHT})"
xvfb-run -a -s "-screen 0 ${WIDTH}x${HEIGHT}x24" \
  "$GODOT" --path "$LATTICE_DIR" -- --void-photos --out ".capture_staging/photos_void"

echo ">> void-photos weaver speak/type (${WIDTH}x${HEIGHT})"
xvfb-run -a -s "-screen 0 ${WIDTH}x${HEIGHT}x24" \
  "$GODOT" --path "$WEAVER_DIR" -- --void-speak-selftest --screenshot --out ".capture_staging/photos_void"

for name in \
  01_void_black.png \
  02_void_spark.png \
  03_void_after_type.png
do
  if [[ ! -f "$LATTICE_STAGING/$name" ]]; then
    echo "missing staged lattice photo: $name" >&2
    exit 1
  fi
  cp "$LATTICE_STAGING/$name" "$OUT_DIR/$name"
done

if [[ ! -f "$WEAVER_STAGING/04_void_speak_seated.png" ]]; then
  echo "missing staged speak photo: 04_void_speak_seated.png" >&2
  exit 1
fi
cp "$WEAVER_STAGING/04_void_speak_seated.png" "$OUT_DIR/04_void_speak_seated.png"

echo
echo "wrote VOID photo pack (${WIDTH}x${HEIGHT}) — photos_v2 untouched:"
ls -1 "$OUT_DIR"/*.png
for f in "$OUT_DIR"/*.png; do
  file "$f"
  python3 - "$f" <<'PY'
import struct, sys
path = sys.argv[1]
with open(path, "rb") as fh:
    sig = fh.read(8)
    assert sig.startswith(b"\x89PNG"), path
    fh.read(8)  # IHDR chunk length+type
    w, h = struct.unpack(">II", fh.read(8))
print("%s %dx%d" % (path, w, h))
PY
done
