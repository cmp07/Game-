#!/bin/sh
# POSIX stamp helper for Godot CI containers (no python3 required).
# Mirrors tools/release/stamp_export_artifacts.py outputs:
#   BUILD_STAMP.json, SHA256SUMS.txt, ARTIFACTS.md
#
# Usage:
#   tools/release/stamp_export_artifacts.sh \
#     --out-dir DIR --preset NAME --artifact-name NAME --exe-name FILE \
#     [--custom-features FEATURES]
set -eu

OUT_DIR=""
PRESET=""
ARTIFACT_NAME=""
EXE_NAME=""
CUSTOM_FEATURES=""

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --out-dir) OUT_DIR="${2:-}"; shift ;;
    --preset) PRESET="${2:-}"; shift ;;
    --artifact-name) ARTIFACT_NAME="${2:-}"; shift ;;
    --exe-name) EXE_NAME="${2:-}"; shift ;;
    --custom-features) CUSTOM_FEATURES="${2:-}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown arg: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [ -z "$OUT_DIR" ] || [ -z "$PRESET" ] || [ -z "$ARTIFACT_NAME" ] || [ -z "$EXE_NAME" ]; then
  echo "error: --out-dir, --preset, --artifact-name, --exe-name are required" >&2
  exit 2
fi

ROOT="$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)"
PROJECT="$ROOT/game/echo_lattice"
TOOLCHAIN="$ROOT/tools/release/godot_toolchain.json"

mkdir -p "$OUT_DIR"

version="${BUILD_VERSION:-}"
if [ -z "$version" ] && [ -f "$PROJECT/project.godot" ]; then
  version="$(sed -n 's/^config\/version="\(.*\)"/\1/p' "$PROJECT/project.godot" | head -n1)"
fi
version="${version:-0.0.0}"

win_ver="${version}.0"
if [ -f "$TOOLCHAIN" ]; then
  tv="$(sed -n 's/.*"windows_file_version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$TOOLCHAIN" | head -n1)"
  [ -n "$tv" ] && win_ver="$tv"
fi

sha="${GITHUB_SHA:-${BUILD_GIT_SHA:-}}"
if [ -z "$sha" ] && command -v git >/dev/null 2>&1; then
  sha="$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || true)"
fi
sha="${sha:-unknown}"
case "$sha" in
  unknown) short="unknown" ;;
  *) short="$(printf '%s' "$sha" | cut -c1-12)" ;;
esac

godot_ver="${GODOT_VERSION:-4.3}"
if [ -f "$TOOLCHAIN" ]; then
  gv="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$TOOLCHAIN" | head -n1)"
  [ -n "$gv" ] && godot_ver="$gv"
fi

built_at="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u)"
ci_image="${GODOT_CI_IMAGE:-local}"
feature_note="$CUSTOM_FEATURES"
[ -n "$feature_note" ] || feature_note="(none)"

SUMS="$OUT_DIR/SHA256SUMS.txt"
: > "$SUMS"
checksum_json=""
first=1

# Hash shipping binaries (and console wrappers) only.
for path in "$OUT_DIR"/*; do
  [ -f "$path" ] || continue
  base="$(basename "$path")"
  case "$base" in
    BUILD_STAMP.json|SHA256SUMS.txt|ARTIFACTS.md) continue ;;
  esac
  case "$base" in
    *.exe|*.pck|*.x86_64|*.dll|*.so|*.dylib|*.zip|*.console.exe) ;;
    *) continue ;;
  esac
  if command -v sha256sum >/dev/null 2>&1; then
    digest="$(sha256sum "$path" | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then
    digest="$(shasum -a 256 "$path" | awk '{print $1}')"
  else
    echo "error: need sha256sum or shasum" >&2
    exit 1
  fi
  printf '%s  %s\n' "$digest" "$base" >> "$SUMS"
  if [ "$first" -eq 1 ]; then
    checksum_json="\"$base\": \"$digest\""
    first=0
  else
    checksum_json="$checksum_json, \"$base\": \"$digest\""
  fi
done

# Minimal JSON (keys ordered for readability; values escaped lightly).
json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

cat > "$OUT_DIR/BUILD_STAMP.json" <<EOF
{
  "product": "Echo Lattice",
  "preset": "$(json_escape "$PRESET")",
  "artifact_name": "$(json_escape "$ARTIFACT_NAME")",
  "exe": "$(json_escape "$EXE_NAME")",
  "product_version": "$(json_escape "$version")",
  "windows_file_version": "$(json_escape "$win_ver")",
  "custom_features": "$(json_escape "$CUSTOM_FEATURES")",
  "git_sha": "$(json_escape "$sha")",
  "git_sha_short": "$(json_escape "$short")",
  "godot_version": "$(json_escape "$godot_ver")",
  "built_at_utc": "$(json_escape "$built_at")",
  "steam_enabled": false,
  "runner": {
    "github_run_id": "$(json_escape "${GITHUB_RUN_ID:-}")",
    "github_run_attempt": "$(json_escape "${GITHUB_RUN_ATTEMPT:-}")",
    "github_ref": "$(json_escape "${GITHUB_REF:-}")",
    "ci_container": "$(json_escape "$ci_image")"
  },
  "checksums_sha256": { ${checksum_json} },
  "notes": [
    "Sidecar stamp is authoritative for CI provenance; Windows PE resource versioning stays off (application/modify_resources=false) so exports do not require rcedit.",
    "Coming Soon / page-only phase keeps config/steam_features.json steam_enabled=false.",
    "Verify artifact integrity with SHA256SUMS.txt before SteamPipe staging."
  ]
}
EOF

cat > "$OUT_DIR/ARTIFACTS.md" <<EOF
# Artifact notes — $ARTIFACT_NAME

| Field | Value |
|---|---|
| Preset | \`$PRESET\` |
| Exe | \`$EXE_NAME\` |
| Product version | \`$version\` |
| Git SHA | \`$short\` |
| Godot | \`$godot_ver\` |
| Built (UTC) | \`$built_at\` |
| Custom features | \`$feature_note\` |
| \`steam_enabled\` | \`false\` (page-only / offline OK) |

## Checksums (SHA-256)

See \`SHA256SUMS.txt\` in this directory. Re-verify after download:

\`\`\`bash
cd <artifact-dir>
sha256sum -c SHA256SUMS.txt
\`\`\`

## Consumers

- Steam depot staging: \`steam/echo_lattice/depot_build/\` (strip \`steam_appid.txt\`)
- itch butler: zip the directory (include stamp + sums)
- CI artifact name: \`$ARTIFACT_NAME\`

Full Windows export guide: \`docs/RELEASE/BUILD_WINDOWS.md\`
EOF

echo "stamped $OUT_DIR version=$version sha=$short"
wc -l < "$SUMS" | awk '{print "checksums:", $1, "file(s)"}'
