#!/usr/bin/env bash
##
## capture_steam_store.sh — Steam Partner screenshot slate at 1920×1080 (16:9).
##
## Writes store-ordered PNGs to docs/RELEASE/screenshots/.
## Requires Godot 4.3+ on PATH (or GODOT=...) and xvfb-run.
##
## Usage:
##   GODOT=/path/to/godot ./game/echo_lattice/tools/capture_steam_store.sh
##
set -euo pipefail

GODOT="${GODOT:-godot}"
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$HERE/.." && pwd)"
REPO_ROOT="$(cd -- "$PROJECT_DIR/../.." && pwd)"
OUT_DIR="$REPO_ROOT/docs/RELEASE/screenshots"
# SEC-03: --out must stay under the Godot project root (not /tmp).
STAGING="$PROJECT_DIR/.capture_staging"
OVERRIDE="$PROJECT_DIR/override.cfg"
WIDTH="${CAPTURE_WIDTH:-1920}"
HEIGHT="${CAPTURE_HEIGHT:-1080}"

cleanup() {
  rm -rf "$STAGING"
  rm -f "$OVERRIDE"
}
trap cleanup EXIT

rm -rf "$STAGING"
mkdir -p "$STAGING" "$OUT_DIR"
rm -rf "$HOME/.local/share/godot/app_userdata/Echo Lattice" || true

# Force a true 16:9 Partner viewport for this capture pass only.
cat > "$OVERRIDE" <<EOF
[display]
window/size/viewport_width=${WIDTH}
window/size/viewport_height=${HEIGHT}
window/size/window_width_override=${WIDTH}
window/size/window_height_override=${HEIGHT}
EOF

run_capture() {
  local kind="$1"
  echo ">> capture $kind (${WIDTH}x${HEIGHT})"
  xvfb-run -a -s "-screen 0 ${WIDTH}x${HEIGHT}x24" \
    "$GODOT" --path "$PROJECT_DIR" -- --screenshot "$kind" --out "$STAGING"
}

run_capture "menu"
run_capture "daily"
run_capture "chamber:0"
run_capture "walk_only:2:5"
run_capture "rewrite:12"
run_capture "chamber:18"
run_capture "won:2"
run_capture "end"

# Store-slot order (STEAM_STORE_FINAL §8): hook → brand → loop → modes → close.
cp "$STAGING/rewrite_12.png"        "$OUT_DIR/01_hook_rewrite_slam.png"
cp "$STAGING/menu.png"              "$OUT_DIR/02_brand_main_menu.png"
cp "$STAGING/chamber_0.png"         "$OUT_DIR/03_chamber_start.png"
cp "$STAGING/walk_only_2_5.png"     "$OUT_DIR/04_walking_trail.png"
cp "$STAGING/chamber_18.png"        "$OUT_DIR/05_mid_act_chamber.png"
cp "$STAGING/won_2.png"             "$OUT_DIR/06_win_stars.png"
cp "$STAGING/daily.png"             "$OUT_DIR/07_daily_select.png"
cp "$STAGING/end.png"               "$OUT_DIR/08_wing_clear.png"

echo
echo "wrote Steam slate (${WIDTH}x${HEIGHT}):"
ls -1 "$OUT_DIR"/*.png
for f in "$OUT_DIR"/0*.png; do
  file "$f"
done
