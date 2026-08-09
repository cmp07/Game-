#!/usr/bin/env bash
# Convenience wrapper: run unit tests, then the demo smoke, then report.
# Usage:
#   ./game/echo_lattice/check.sh /path/to/godot
# Defaults to `godot` on PATH.
set -euo pipefail

GODOT="${1:-${GODOT:-godot}}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "-- Godot: $($GODOT --version)"
echo "-- Project: $PROJECT_DIR"

echo
echo "== Unit tests =="
"$GODOT" --headless --path "$PROJECT_DIR" --script res://echo_lattice/tests/run_tests.gd

echo
echo "== Demo smoke =="
"$GODOT" --headless --path "$PROJECT_DIR" --script res://echo_lattice/demo/demo_smoke.gd
