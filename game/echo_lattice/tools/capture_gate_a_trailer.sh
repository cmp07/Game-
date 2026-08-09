#!/usr/bin/env bash
##
## capture_gate_a_trailer.sh — Gate A 30s rewrite-slam trailer frame packs.
##
## Writes editor-ready stills under docs/RELEASE/trailer/frame_packs/.
## Requires Godot 4.3 on PATH (or $GODOT) and xvfb-run.
##
## Usage:
##   export PATH="$HOME/bin:$PATH"
##   ./game/echo_lattice/tools/capture_gate_a_trailer.sh
##
set -euo pipefail

GODOT="${GODOT:-godot}"
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$HERE/.." && pwd)"
REPO_ROOT="$(cd -- "$PROJECT_DIR/../.." && pwd)"
OUT_ROOT="$REPO_ROOT/docs/RELEASE/trailer/frame_packs"
# SEC-03: --out must stay under the Godot project root (not /tmp).
STAGING="$PROJECT_DIR/.capture_staging"
rm -rf "$STAGING"
mkdir -p "$STAGING" "$OUT_ROOT"
rm -rf "$HOME/.local/share/godot/app_userdata/Echo Lattice" || true

run_capture() {
  local kind="$1"
  echo ">> capture $kind"
  xvfb-run -a -s "-screen 0 1152x672x24" \
    "$GODOT" --path "$PROJECT_DIR" -- --screenshot "$kind" --out "$STAGING"
}

copy_frame() {
  local src_kind="$1"
  local dest="$2"
  local src_file="$STAGING/${src_kind//:/_}.png"
  if [[ ! -f "$src_file" ]]; then
    echo "missing capture: $src_file" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src_file" "$dest"
  echo "   -> $dest"
}

echo "== A open corridor (chamber 0) =="
SEQ_A="$OUT_ROOT/01_open_corridor"
rm -rf "$SEQ_A"
run_capture "chamber:0"
copy_frame "chamber_0" "$SEQ_A/01_clean_ledger.png"

echo "== B habit trail densifying (chamber 2) =="
SEQ_B="$OUT_ROOT/02_habit_trail"
rm -rf "$SEQ_B"
for spec in \
  "01_far:14" \
  "02_mid:9" \
  "03_near:5" \
  "04_approach:2"
do
  name="${spec%%:*}"
  stop="${spec##*:}"
  run_capture "walk_only:2:${stop}"
  copy_frame "walk_only_2_${stop}" "$SEQ_B/${name}.png"
done

echo "== C rewrite slam phases (chamber 12) =="
SEQ_C="$OUT_ROOT/03_rewrite_slam"
rm -rf "$SEQ_C"
for spec in \
  "01_heartbeat:0.05" \
  "02_creases:0.20" \
  "03_lift:0.40" \
  "04_slot:0.55" \
  "05_overshoot:0.70" \
  "06_rust_bleed:0.90"
do
  name="${spec%%:*}"
  t="${spec##*:}"
  run_capture "rewrite:12:${t}"
  copy_frame "rewrite_12_${t}" "$SEQ_C/${name}.png"
done
# Poster / thumbnail still (slot)
cp "$SEQ_C/04_slot.png" "$OUT_ROOT/poster_slam.png"
echo "   -> $OUT_ROOT/poster_slam.png"

echo "== D after fossil + before (chamber 12) =="
SEQ_D="$OUT_ROOT/04_after_fossil"
rm -rf "$SEQ_D"
run_capture "walk_only:12:3"
copy_frame "walk_only_12_3" "$SEQ_D/01_before_trail.png"
run_capture "rewrite:12:0.55"
copy_frame "rewrite_12_0.55" "$SEQ_D/02_mid_slam.png"
run_capture "rewrite_done:12"
copy_frame "rewrite_done_12" "$SEQ_D/03_after_fossil.png"

echo "== E prove depth (mid-act / stars / daily) =="
SEQ_E="$OUT_ROOT/05_prove_depth"
rm -rf "$SEQ_E"
run_capture "chamber:18"
copy_frame "chamber_18" "$SEQ_E/01_mid_act.png"
run_capture "won:2"
copy_frame "won_2" "$SEQ_E/02_stars_clear.png"
run_capture "daily"
copy_frame "daily" "$SEQ_E/03_daily_select.png"

echo "== F title / CTA (menu lockup) =="
SEQ_F="$OUT_ROOT/06_title_cta"
rm -rf "$SEQ_F"
run_capture "menu"
copy_frame "menu" "$SEQ_F/01_main_menu.png"
run_capture "end"
copy_frame "end" "$SEQ_F/02_wing_clear.png"

rm -rf "$STAGING"
echo
echo "wrote trailer frame packs under $OUT_ROOT"
find "$OUT_ROOT" -type f -name '*.png' | sort
