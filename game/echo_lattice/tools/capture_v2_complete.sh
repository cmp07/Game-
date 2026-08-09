#!/usr/bin/env bash
##
## capture_v2_complete.sh — full visual tour for the complete v2 PR.
##
set -euo pipefail

GODOT="${GODOT:-godot}"
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$HERE/.." && pwd)"
REPO_ROOT="$(cd -- "$PROJECT_DIR/../.." && pwd)"
OUT_DIR="$REPO_ROOT/docs/ECHO_LATTICE/screenshots/v2_complete"
# SEC-03: --out must stay under the Godot project root (not /tmp).
STAGING="$PROJECT_DIR/.capture_staging"
rm -rf "$STAGING"
mkdir -p "$STAGING" "$OUT_DIR"
rm -rf "$HOME/.local/share/godot/app_userdata/Echo Lattice" || true

run_capture() {
  local kind="$1"
  echo ">> capture $kind"
  xvfb-run -a -s "-screen 0 1152x672x24" \
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

cp "$STAGING/menu.png"              "$OUT_DIR/01_main_menu.png"
cp "$STAGING/daily.png"             "$OUT_DIR/02_daily_select.png"
cp "$STAGING/chamber_0.png"         "$OUT_DIR/03_chamber_start.png"
cp "$STAGING/walk_only_2_5.png"     "$OUT_DIR/04_walking_trail.png"
cp "$STAGING/rewrite_12.png"        "$OUT_DIR/05_rewrite_slam.png"
cp "$STAGING/chamber_18.png"        "$OUT_DIR/06_mid_act_chamber.png"
cp "$STAGING/won_2.png"             "$OUT_DIR/07_win_stars.png"
cp "$STAGING/end.png"               "$OUT_DIR/08_wing_clear.png"

rm -rf "$STAGING"
echo
echo "wrote:"
ls -1 "$OUT_DIR"
