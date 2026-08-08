#!/usr/bin/env bash
# Export Echo Lattice for Windows (x86_64 .exe + .pck).
# Usage (from repo root):
#   ./scripts/echo_lattice/export_windows.sh
# Optional:
#   GODOT_BIN=/path/to/godot PRESET="Windows Desktop" ./scripts/echo_lattice/export_windows.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT="${ROOT}/game/echo_lattice"
OUT_DIR="${ROOT}/dist/echo_lattice/windows"
OUT_EXE="${OUT_DIR}/EchoLattice.exe"
PRESET="${PRESET:-Windows Desktop}"

resolve_godot() {
  if [[ -n "${GODOT_BIN:-}" ]]; then
    echo "${GODOT_BIN}"
    return
  fi
  if command -v godot >/dev/null 2>&1; then
    command -v godot
    return
  fi
  if command -v godot4 >/dev/null 2>&1; then
    command -v godot4
    return
  fi
  return 1
}

if [[ ! -f "${PROJECT}/project.godot" ]]; then
  cat <<EOF >&2
error: missing ${PROJECT}/project.godot
  The Godot scaffold must exist before export (see game/echo_lattice on the scaffold branch).
EOF
  exit 1
fi

if ! GODOT="$(resolve_godot)"; then
  cat <<EOF >&2
error: Godot 4.3+ binary not found.
  Install Godot and either add it to PATH as 'godot' / 'godot4',
  or set GODOT_BIN to the executable.
EOF
  exit 1
fi

mkdir -p "${OUT_DIR}"

echo "==> Godot:  ${GODOT}"
echo "==> Project:${PROJECT}"
echo "==> Preset: ${PRESET}"
echo "==> Output: ${OUT_EXE}"

"${GODOT}" --headless --path "${PROJECT}" --export-release "${PRESET}" "${OUT_EXE}"

if [[ ! -f "${OUT_EXE}" ]]; then
  echo "error: export finished but ${OUT_EXE} was not created" >&2
  exit 1
fi

PCK="${OUT_DIR}/EchoLattice.pck"
if [[ ! -f "${PCK}" ]]; then
  echo "warn: ${PCK} not found (PCK may be embedded). Check export preset 'Embed PCK'." >&2
fi

echo "==> Export OK"
ls -lh "${OUT_DIR}"
