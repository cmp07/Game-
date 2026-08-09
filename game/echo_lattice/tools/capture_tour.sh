#!/usr/bin/env bash
##
## capture_tour.sh — regenerate every screenshot in docs/ECHO_LATTICE/screenshots/tour/.
##
## Requires:
##   - Godot 4.3 stable at $GODOT (default: godot on PATH)
##   - xvfb-run (for headless X on Linux CI / cloud VMs)
##
## Usage:
##   GODOT=/path/to/godot ./tools/capture_tour.sh
##

set -euo pipefail

GODOT="${GODOT:-godot}"
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$HERE/.." && pwd)"
REPO_ROOT="$(cd -- "$PROJECT_DIR/../.." && pwd)"
OUT_DIR="$REPO_ROOT/docs/ECHO_LATTICE/screenshots/tour"
STAGING="$(mktemp -d)"

mkdir -p "$OUT_DIR"

# Wipe any leftover save so the menu shot always shows a fresh boot.
rm -rf "$HOME/.local/share/godot/app_userdata/Echo Lattice" || true

run_capture() {
  local kind="$1"
  echo ">> capture $kind"
  xvfb-run -a -s "-screen 0 1152x672x24" \
    "$GODOT" --path "$PROJECT_DIR" -- --screenshot "$kind" --out "$STAGING" \
    >/dev/null
}

# Capture each moment.
run_capture "menu"
run_capture "chamber:0"
run_capture "walk_only:2:5"
run_capture "rewrite:2"
run_capture "rewrite:4"
run_capture "won:2"
run_capture "chamber:3"

# Map staged filenames to the numbered tour filenames.
cp "$STAGING/menu.png"          "$OUT_DIR/01_main_menu.png"
cp "$STAGING/chamber_0.png"     "$OUT_DIR/02_chamber_start.png"
cp "$STAGING/walk_only_2_5.png" "$OUT_DIR/03_walking_trail.png"
cp "$STAGING/rewrite_2.png"     "$OUT_DIR/04_rewrite_moment.png"
cp "$STAGING/rewrite_4.png"     "$OUT_DIR/05_mid_chamber.png"
cp "$STAGING/won_2.png"         "$OUT_DIR/06_goal_win.png"
cp "$STAGING/chamber_3.png"     "$OUT_DIR/07_next_chamber.png"

rm -rf "$STAGING"

echo
echo "wrote:"
ls -1 "$OUT_DIR"
