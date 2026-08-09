#!/usr/bin/env python3
"""Download IBM Plex Latin stack (SIL OFL 1.1) into fonts/latin/.

Vendors the Field Ledger typefaces required by ART_DIRECTION_V3 §3 / V3-T0:

  Display — IBM Plex Sans Condensed SemiBold (+ Regular for UI)
  Body    — IBM Plex Serif Regular
  Mono    — IBM Plex Mono Regular

Source: IBM/plex packages on GitHub (complete TTF). License allows embedding
in a commercial Steam build. See game/echo_lattice/fonts/README.md.
"""
from __future__ import annotations

import argparse
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LATIN_DIR = ROOT / "game" / "echo_lattice" / "fonts" / "latin"
RAW_BASE = "https://raw.githubusercontent.com/IBM/plex/master/packages"

FACES: tuple[tuple[str, str], ...] = (
    (
        "plex-sans-condensed/fonts/complete/ttf/IBMPlexSansCondensed-SemiBold.ttf",
        "IBMPlexSansCondensed-SemiBold.ttf",
    ),
    (
        "plex-sans-condensed/fonts/complete/ttf/IBMPlexSansCondensed-Regular.ttf",
        "IBMPlexSansCondensed-Regular.ttf",
    ),
    (
        "plex-serif/fonts/complete/ttf/IBMPlexSerif-Regular.ttf",
        "IBMPlexSerif-Regular.ttf",
    ),
    (
        "plex-mono/fonts/complete/ttf/IBMPlexMono-Regular.ttf",
        "IBMPlexMono-Regular.ttf",
    ),
)
OFL_URL = f"{RAW_BASE}/plex-sans-condensed/LICENSE.txt"


def _download(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "echo-lattice-font-fetch/1.0"})
    with urllib.request.urlopen(req, timeout=120) as resp:
        return resp.read()


def ensure_ofl(force: bool = False) -> Path:
    dest = LATIN_DIR / "OFL.txt"
    if dest.is_file() and not force:
        return dest
    LATIN_DIR.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(_download(OFL_URL))
    return dest


def fetch_faces(force: bool = False) -> list[Path]:
    LATIN_DIR.mkdir(parents=True, exist_ok=True)
    written: list[Path] = []
    for rel, name in FACES:
        dest = LATIN_DIR / name
        if dest.is_file() and not force:
            print(f"OK: already present {dest}")
            written.append(dest)
            continue
        url = f"{RAW_BASE}/{rel}"
        print(f"Downloading {url} …")
        data = _download(url)
        if len(data) < 1000 or data[:4] not in (b"\x00\x01\x00\x00", b"OTTO", b"ttcf"):
            raise RuntimeError(f"Unexpected font payload for {name} ({len(data)} bytes)")
        dest.write_bytes(data)
        print(f"OK: wrote {dest} ({len(data)} bytes)")
        written.append(dest)
    return written


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--force", action="store_true", help="Re-download even if present")
    parser.add_argument("--ofl-only", action="store_true", help="Refresh OFL.txt only")
    args = parser.parse_args(argv)

    try:
        ofl = ensure_ofl(force=args.force or args.ofl_only)
        print(f"OK: OFL at {ofl}")
        if args.ofl_only:
            return 0
        faces = fetch_faces(force=args.force)
        missing = [n for _, n in FACES if not (LATIN_DIR / n).is_file()]
        if missing:
            raise RuntimeError(f"Missing faces after fetch: {missing}")
        print(f"OK: {len(faces)} latin faces ready under {LATIN_DIR}")
    except Exception as exc:  # noqa: BLE001 — CLI surface
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
