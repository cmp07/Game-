#!/usr/bin/env python3
"""Fail-closed checks for Steam depot staging (no Spacewar / no steam_appid.txt).

Scans steam/echo_lattice/depot_build/** for retail hygiene problems:
  - steam_appid.txt present (must never ship)
  - file contents equal to Spacewar AppID 480
  - allow_spacewar_dev left true in any staged json

Empty staging (only .gitkeep) is OK — returns success.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
STAGING = HERE / "depot_build"
SPACEWAR = "480"
FORBIDDEN_NAMES = {"steam_appid.txt"}


def iter_staged_files(root: Path) -> list[Path]:
    if not root.is_dir():
        return []
    out: list[Path] = []
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if path.name == ".gitkeep":
            continue
        out.append(path)
    return out


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        type=Path,
        default=STAGING,
        help=f"Staging root (default: {STAGING})",
    )
    args = parser.parse_args(argv)
    root: Path = args.root
    files = iter_staged_files(root)
    errors: list[str] = []

    for path in files:
        rel = path.relative_to(root) if path.is_relative_to(root) else path
        if path.name in FORBIDDEN_NAMES:
            errors.append(f"{rel}: steam_appid.txt must not ship in retail depots")
            continue
        try:
            text = path.read_text(encoding="utf-8", errors="ignore").strip()
        except OSError:
            continue
        if text == SPACEWAR:
            errors.append(f"{rel}: contents are Spacewar AppID 480 — refuse retail")
        if path.suffix.lower() == ".json":
            try:
                data = json.loads(text)
            except json.JSONDecodeError:
                data = None
            if isinstance(data, dict) and data.get("allow_spacewar_dev") is True:
                errors.append(f"{rel}: allow_spacewar_dev must be false for retail")

    if errors:
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        print("Retail staging check failed (fail-closed).", file=sys.stderr)
        return 2

    print(f"OK: retail staging clean ({len(files)} file(s) under {root})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
