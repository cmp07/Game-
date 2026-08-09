#!/usr/bin/env bash
##
## capture_press_gifs.sh — three GIF-ready frame sequences for the launch presskit.
##
## 01_rewrite_slam  — origami slam phases (heartbeat → rust bleed)
## 02_habit_trail   — chalk trail densifying toward a checkpoint
## 03_before_after  — trail → mid-slam → settled fossils
##
set -euo pipefail

GODOT="${GODOT:-godot}"
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$HERE/.." && pwd)"
REPO_ROOT="$(cd -- "$PROJECT_DIR/../.." && pwd)"
OUT_ROOT="$REPO_ROOT/docs/RELEASE/presskit/images/gif_sequences"
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

echo "== 01 rewrite slam phases (chamber 12) =="
SEQ1="$OUT_ROOT/01_rewrite_slam"
rm -rf "$SEQ1"
# Phases from VISUAL v2 / chamber.gd slam comments.
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
  copy_frame "rewrite_12_${t}" "$SEQ1/${name}.png"
done

echo "== 02 habit trail densifying (chamber 2) =="
SEQ2="$OUT_ROOT/02_habit_trail"
rm -rf "$SEQ2"
for spec in \
  "01_far:14" \
  "02_mid:9" \
  "03_near:5" \
  "04_approach:2"
do
  name="${spec%%:*}"
  stop="${spec##*:}"
  run_capture "walk_only:2:${stop}"
  copy_frame "walk_only_2_${stop}" "$SEQ2/${name}.png"
done

echo "== 03 before / mid-slam / after (chamber 12) =="
SEQ3="$OUT_ROOT/03_before_after"
rm -rf "$SEQ3"
run_capture "walk_only:12:3"
copy_frame "walk_only_12_3" "$SEQ3/01_before_trail.png"
run_capture "rewrite:12:0.55"
copy_frame "rewrite_12_0.55" "$SEQ3/02_mid_slam.png"
run_capture "rewrite_done:12"
copy_frame "rewrite_done_12" "$SEQ3/03_after_fossil.png"

# Tour docs
cat > "$OUT_ROOT/TOUR.md" <<'EOF'
# Presskit GIF sequences

Frame packs for social GIFs / Shorts. Captured with `game/echo_lattice/tools/capture_press_gifs.sh`.

## 01 — Rewrite slam

Origami slam on chamber 12, frozen at slam progress t:

| Frame | t | Phase |
|---|---|---|
| `01_heartbeat.png` | 0.05 | Cadmium margin heartbeat |
| `02_creases.png` | 0.20 | Ink creases on doomed floors |
| `03_lift.png` | 0.40 | Paper lift + cast shadow |
| `04_slot.png` | 0.55 | Trailer still — slot into fossil |
| `05_overshoot.png` | 0.70 | Overshoot bounce |
| `06_rust_bleed.png` | 0.90 | Rust bleed from joins |

Assemble at ~8–10 fps for a ~0.7–0.9s punch, or hold the 0.55 frame as a still.

## 02 — Habit trail

Chamber 2 walk toward checkpoint, stopped early so the chalk trail grows:

`01_far` → `02_mid` → `03_near` → `04_approach`

## 03 — Before / after

| Frame | Beat |
|---|---|
| `01_before_trail.png` | Habit written, no rewrite |
| `02_mid_slam.png` | Lift/slot trailer still |
| `03_after_fossil.png` | Settled rust echo walls |

## Regenerate

```bash
export PATH="$HOME/bin:$PATH"
./game/echo_lattice/tools/capture_press_gifs.sh
```
EOF

rm -rf "$STAGING"
echo
echo "wrote sequences under $OUT_ROOT"
find "$OUT_ROOT" -type f | sort
