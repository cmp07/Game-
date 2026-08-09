#!/usr/bin/env bash
# Reproducible Windows Desktop (+ Demo) export for Echo Lattice.
#
# Usage:
#   tools/release/export_windows.sh              # full + demo (default)
#   tools/release/export_windows.sh --full
#   tools/release/export_windows.sh --demo
#   tools/release/export_windows.sh --all
#   GODOT=/path/to/godot tools/release/export_windows.sh
#
# Requires Godot 4.3-stable + Windows desktop export templates (4.3.stable).
# See docs/RELEASE/BUILD_WINDOWS.md and tools/release/godot_toolchain.json.
set -eu

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROJECT="$ROOT/game/echo_lattice"
STAMP_PY="$ROOT/tools/release/stamp_export_artifacts.py"
STAMP_SH="$ROOT/tools/release/stamp_export_artifacts.sh"
TOOLCHAIN="$ROOT/tools/release/godot_toolchain.json"

MODE="all"
GODOT_BIN="${GODOT:-${GODOT_BIN:-godot}}"

usage() {
  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --full) MODE="full" ;;
    --demo) MODE="demo" ;;
    --all) MODE="all" ;;
    --godot)
      shift
      GODOT_BIN="${1:-}"
      if [ -z "$GODOT_BIN" ]; then
        echo "error: --godot requires a path" >&2
        exit 2
      fi
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if ! command -v "$GODOT_BIN" >/dev/null 2>&1 && [ ! -x "$GODOT_BIN" ]; then
  echo "error: Godot binary not found (set GODOT=... or install godot on PATH)" >&2
  echo "Expected 4.3-stable. Toolchain pin: $TOOLCHAIN" >&2
  exit 1
fi

if [ ! -f "$PROJECT/export_presets.cfg" ]; then
  echo "error: missing $PROJECT/export_presets.cfg" >&2
  exit 1
fi

export_one() {
  preset="$1"
  out_rel="$2"
  exe_name="$3"
  artifact_name="$4"
  features="$5"

  out_dir="$PROJECT/$(dirname "$out_rel")"
  mkdir -p "$out_dir"
  echo "==> Export preset '$preset' → $out_rel"
  # Import once then export. --path keeps project-relative export_path stable.
  "$GODOT_BIN" --headless --path "$PROJECT" --export-release "$preset" "$out_rel"
  if [ ! -f "$PROJECT/$out_rel" ]; then
    echo "error: export did not produce $PROJECT/$out_rel" >&2
    exit 1
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 "$STAMP_PY" \
      --out-dir "$out_dir" \
      --preset "$preset" \
      --artifact-name "$artifact_name" \
      --exe-name "$exe_name" \
      --custom-features "$features"
  else
    sh "$STAMP_SH" \
      --out-dir "$out_dir" \
      --preset "$preset" \
      --artifact-name "$artifact_name" \
      --exe-name "$exe_name" \
      --custom-features "$features"
  fi
  echo "    OK $out_dir (BUILD_STAMP.json + SHA256SUMS.txt + ARTIFACTS.md)"
}

case "$MODE" in
  full)
    export_one "Windows Desktop" "builds/windows/EchoLattice.exe" \
      "EchoLattice.exe" "echo-lattice-windows-x86_64" ""
    ;;
  demo)
    export_one "Windows Demo" "builds/windows_demo/EchoLatticeDemo.exe" \
      "EchoLatticeDemo.exe" "echo-lattice-windows-demo-x86_64" "demo"
    ;;
  all)
    export_one "Windows Desktop" "builds/windows/EchoLattice.exe" \
      "EchoLattice.exe" "echo-lattice-windows-x86_64" ""
    export_one "Windows Demo" "builds/windows_demo/EchoLatticeDemo.exe" \
      "EchoLatticeDemo.exe" "echo-lattice-windows-demo-x86_64" "demo"
    ;;
esac

echo "Done. Stage SteamPipe from builds/ into steam/echo_lattice/depot_build/ (no steam_appid.txt)."
echo "Docs: docs/RELEASE/BUILD_WINDOWS.md"
