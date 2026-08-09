#!/usr/bin/env python3
"""Write BUILD_STAMP.json, SHA256SUMS.txt, and ARTIFACTS.md for an export dir.

Used by tools/release/export_windows.sh and .github/workflows/ci.yml so local
and CI Windows (+ Demo) artifacts carry the same provenance + checksum notes.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
PROJECT = REPO_ROOT / "game" / "echo_lattice"
TOOLCHAIN = Path(__file__).resolve().parent / "godot_toolchain.json"
BINARY_SUFFIXES = {".exe", ".pck", ".x86_64", ".dll", ".so", ".dylib", ".zip"}


def read_project_version() -> str:
    text = PROJECT.joinpath("project.godot").read_text(encoding="utf-8")
    for line in text.splitlines():
        if line.startswith("config/version="):
            return line.split("=", 1)[1].strip().strip('"')
    return "0.0.0"


def git_sha() -> str:
    env_sha = os.environ.get("GITHUB_SHA") or os.environ.get("BUILD_GIT_SHA")
    if env_sha:
        return env_sha.strip()
    try:
        out = subprocess.check_output(
            ["git", "-C", str(REPO_ROOT), "rev-parse", "HEAD"],
            text=True,
            stderr=subprocess.DEVNULL,
        )
        return out.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return "unknown"


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def collect_binaries(out_dir: Path) -> list[Path]:
    files: list[Path] = []
    for path in sorted(out_dir.rglob("*")):
        if not path.is_file():
            continue
        if path.name in {"BUILD_STAMP.json", "SHA256SUMS.txt", "ARTIFACTS.md"}:
            continue
        if path.suffix.lower() in BINARY_SUFFIXES or path.name.endswith(".console.exe"):
            files.append(path)
    return files


def load_toolchain() -> dict:
    if TOOLCHAIN.is_file():
        return json.loads(TOOLCHAIN.read_text(encoding="utf-8"))
    return {}


def write_stamp(
    out_dir: Path,
    *,
    preset: str,
    artifact_name: str,
    custom_features: str,
    exe_name: str,
) -> dict:
    out_dir.mkdir(parents=True, exist_ok=True)
    version = os.environ.get("BUILD_VERSION") or read_project_version()
    sha = git_sha()
    toolchain = load_toolchain()
    container = toolchain.get("ci_container", {})
    built_at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    binaries = collect_binaries(out_dir)
    checksums = {
        str(p.relative_to(out_dir)).replace("\\", "/"): sha256_file(p) for p in binaries
    }

    stamp = {
        "product": "Echo Lattice",
        "preset": preset,
        "artifact_name": artifact_name,
        "exe": exe_name,
        "product_version": version,
        "windows_file_version": toolchain.get("windows_file_version", f"{version}.0"),
        "custom_features": custom_features,
        "git_sha": sha,
        "git_sha_short": sha[:12] if sha != "unknown" else "unknown",
        "godot_version": toolchain.get("version", os.environ.get("GODOT_VERSION", "4.3")),
        "built_at_utc": built_at,
        "steam_enabled": False,
        "runner": {
            "github_run_id": os.environ.get("GITHUB_RUN_ID", ""),
            "github_run_attempt": os.environ.get("GITHUB_RUN_ATTEMPT", ""),
            "github_ref": os.environ.get("GITHUB_REF", ""),
            "ci_container": (
                f"{container.get('image', 'barichello/godot-ci')}:"
                f"{container.get('tag', '4.3')}@"
                f"{container.get('digest', 'unpinned')}"
                if container
                else os.environ.get("GODOT_CI_IMAGE", "local")
            ),
        },
        "checksums_sha256": checksums,
        "notes": [
            "Sidecar stamp is authoritative for CI provenance; Windows PE resource "
            "versioning stays off (application/modify_resources=false) so exports "
            "do not require rcedit.",
            "Coming Soon / page-only phase keeps config/steam_features.json "
            "steam_enabled=false.",
            "Verify artifact integrity with SHA256SUMS.txt before SteamPipe staging.",
        ],
    }

    sums_lines = [f"{digest}  {rel}" for rel, digest in checksums.items()]
    (out_dir / "SHA256SUMS.txt").write_text(
        "\n".join(sums_lines) + ("\n" if sums_lines else ""),
        encoding="utf-8",
    )
    (out_dir / "BUILD_STAMP.json").write_text(
        json.dumps(stamp, indent=2, sort_keys=False) + "\n",
        encoding="utf-8",
    )

    feature_note = custom_features if custom_features else "(none)"
    md = f"""# Artifact notes — {artifact_name}

| Field | Value |
|---|---|
| Preset | `{preset}` |
| Exe | `{exe_name}` |
| Product version | `{version}` |
| Git SHA | `{stamp["git_sha_short"]}` |
| Godot | `{stamp["godot_version"]}` |
| Built (UTC) | `{built_at}` |
| Custom features | `{feature_note}` |
| `steam_enabled` | `false` (page-only / offline OK) |

## Checksums (SHA-256)

See `SHA256SUMS.txt` in this directory. Re-verify after download:

```bash
cd <artifact-dir>
sha256sum -c SHA256SUMS.txt
```

## Consumers

- Steam depot staging: `steam/echo_lattice/depot_build/` (strip `steam_appid.txt`)
- itch butler: zip the directory (include stamp + sums)
- CI artifact name: `{artifact_name}`

Full Windows export guide: `docs/RELEASE/BUILD_WINDOWS.md`
"""
    (out_dir / "ARTIFACTS.md").write_text(md, encoding="utf-8")
    return stamp


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out-dir", required=True, type=Path)
    parser.add_argument("--preset", required=True)
    parser.add_argument("--artifact-name", required=True)
    parser.add_argument("--exe-name", required=True)
    parser.add_argument("--custom-features", default="")
    args = parser.parse_args()

    stamp = write_stamp(
        args.out_dir.resolve(),
        preset=args.preset,
        artifact_name=args.artifact_name,
        custom_features=args.custom_features,
        exe_name=args.exe_name,
    )
    print(f"stamped {args.out_dir} version={stamp['product_version']} sha={stamp['git_sha_short']}")
    print(f"checksums: {len(stamp['checksums_sha256'])} file(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
