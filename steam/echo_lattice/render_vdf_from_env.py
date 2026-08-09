#!/usr/bin/env python3
"""Render SteamPipe VDF templates from real AppID / DepotID environment variables.

Committed templates keep YOUR_* placeholders. This script writes a rendered
copy under dist/ (gitignored) for steamcmd — never invents IDs, never accepts
Spacewar 480.

Full game env:
  STEAM_APP_ID
  STEAM_DEPOT_ID_WINDOWS   (alias: STEAM_DEPOT_ID)
  STEAM_DEPOT_ID_LINUX

Demo env:
  STEAM_DEMO_APP_ID
  STEAM_DEMO_DEPOT_ID

Usage:
  # Dry-run: show which tokens would be substituted (fails if env missing)
  python3 steam/echo_lattice/render_vdf_from_env.py --check

  # Render full-game + demo VDFs into dist/echo_lattice/steampipe_rendered/
  python3 steam/echo_lattice/render_vdf_from_env.py --write

  # Full game only / demo only
  python3 steam/echo_lattice/render_vdf_from_env.py --write --full
  python3 steam/echo_lattice/render_vdf_from_env.py --write --demo
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
DEFAULT_OUT = REPO / "dist" / "echo_lattice" / "steampipe_rendered"

SPACEWAR = "480"
PLACEHOLDER_RE = re.compile(r"YOUR_[A-Z0-9_]+")

FULL_FILES = (
    "app_build.vdf",
    "depot_windows.vdf",
    "depot_linux.vdf",
)
DEMO_FILES = (
    "app_build_demo.vdf",
    "depot_windows_demo.vdf",
)

FULL_TOKENS = {
    "YOUR_APP_ID": ("STEAM_APP_ID",),
    "YOUR_DEPOT_ID": ("STEAM_DEPOT_ID_WINDOWS", "STEAM_DEPOT_ID"),
    "YOUR_DEPOT_ID_LINUX": ("STEAM_DEPOT_ID_LINUX",),
}
DEMO_TOKENS = {
    "YOUR_DEMO_APP_ID": ("STEAM_DEMO_APP_ID",),
    "YOUR_DEMO_DEPOT_ID": ("STEAM_DEMO_DEPOT_ID",),
}


def _env_first(names: tuple[str, ...]) -> str | None:
    for name in names:
        raw = os.environ.get(name, "").strip()
        if raw:
            return raw
    return None


def _validate_id(token: str, value: str) -> str | None:
    if not value.isdigit() or int(value) <= 0:
        return f"{token}: value {value!r} is not a positive integer App/Depot ID"
    if value == SPACEWAR:
        return (
            f"{token}: refusing Spacewar AppID 480 — retail/depot scripts must use "
            "the real Partner AppID (see docs/RELEASE/GODOTSTEAM.md)"
        )
    if value.startswith("YOUR_") or "PLACEHOLDER" in value.upper():
        return f"{token}: refusing placeholder-like value {value!r}"
    return None


def resolve_map(token_env: dict[str, tuple[str, ...]]) -> tuple[dict[str, str], list[str]]:
    resolved: dict[str, str] = {}
    errors: list[str] = []
    for token, env_names in token_env.items():
        value = _env_first(env_names)
        if value is None:
            errors.append(
                f"missing env for {token} (set one of: {', '.join(env_names)})"
            )
            continue
        err = _validate_id(token, value)
        if err:
            errors.append(err)
            continue
        resolved[token] = value
    return resolved, errors


def render_text(text: str, mapping: dict[str, str]) -> str:
    out = text
    for token, value in mapping.items():
        out = out.replace(token, value)
    leftover = PLACEHOLDER_RE.findall(out)
    # Comments may still mention YOUR_* historically; only fail on active VDF values.
    active = []
    for line in out.splitlines():
        stripped = line.strip()
        if stripped.startswith("//"):
            continue
        active.extend(PLACEHOLDER_RE.findall(line))
    if active:
        raise ValueError(f"unresolved placeholders after render: {sorted(set(active))}")
    return out


def collect_mapping(want_full: bool, want_demo: bool) -> tuple[dict[str, str], list[str]]:
    mapping: dict[str, str] = {}
    errors: list[str] = []
    if want_full:
        m, e = resolve_map(FULL_TOKENS)
        mapping.update(m)
        errors.extend(e)
    if want_demo:
        m, e = resolve_map(DEMO_TOKENS)
        mapping.update(m)
        errors.extend(e)
    return mapping, errors


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="Validate env vars and templates only (no write)",
    )
    parser.add_argument(
        "--write",
        action="store_true",
        help="Write rendered VDFs under --out",
    )
    parser.add_argument("--full", action="store_true", help="Full-game VDFs only")
    parser.add_argument("--demo", action="store_true", help="Demo VDFs only")
    parser.add_argument(
        "--out",
        type=Path,
        default=DEFAULT_OUT,
        help=f"Output directory (default: {DEFAULT_OUT})",
    )
    args = parser.parse_args(argv)

    if not args.check and not args.write:
        parser.error("specify --check and/or --write")

    want_full = args.full or (not args.full and not args.demo)
    want_demo = args.demo or (not args.full and not args.demo)
    if args.full and not args.demo:
        want_demo = False
    if args.demo and not args.full:
        want_full = False

    mapping, errors = collect_mapping(want_full, want_demo)
    if errors:
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        print(
            "Depot render is fail-closed without real AppID env vars. "
            "Do not invent IDs; set STEAM_* after Partner assign.",
            file=sys.stderr,
        )
        return 2

    files: list[str] = []
    if want_full:
        files.extend(FULL_FILES)
    if want_demo:
        files.extend(DEMO_FILES)

    rendered: dict[str, str] = {}
    for name in files:
        src = HERE / name
        if not src.is_file():
            print(f"error: missing template {src}", file=sys.stderr)
            return 2
        try:
            rendered[name] = render_text(src.read_text(encoding="utf-8"), mapping)
        except ValueError as exc:
            print(f"error: {name}: {exc}", file=sys.stderr)
            return 2

    print("Resolved IDs:")
    for token in sorted(mapping):
        print(f"  {token} <- {mapping[token]}")

    if args.write:
        out_dir: Path = args.out
        out_dir.mkdir(parents=True, exist_ok=True)
        for name, text in rendered.items():
            dest = out_dir / name
            dest.write_text(text, encoding="utf-8")
            print(f"wrote {dest}")
        print(
            "Next: steamcmd +run_app_build <abs>/"
            f"{out_dir.relative_to(REPO) if out_dir.is_relative_to(REPO) else out_dir}"
            "/app_build.vdf"
        )
    else:
        print(f"OK: would render {len(rendered)} file(s) (no write)")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
