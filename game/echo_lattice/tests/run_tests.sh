#!/usr/bin/env bash
# Convenience wrapper — cd into the Godot project, run the headless suite.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

GODOT="${GODOT:-godot4}"
if ! command -v "${GODOT}" >/dev/null 2>&1; then
	echo "ERROR: '${GODOT}' not found on PATH." >&2
	echo "Set GODOT=/path/to/godot4 or add the binary to PATH." >&2
	exit 127
fi

exec "${GODOT}" --headless --path "${PROJECT_DIR}" -s "res://tests/test_runner.gd" "$@"
