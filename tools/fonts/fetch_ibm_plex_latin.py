#!/usr/bin/env python3
"""Fetch IBM Plex latin stack (OFL) into game/echo_lattice/fonts/latin/.

Uses jsDelivr GitHub mirror of IBM/plex. Stdlib only.
"""
from __future__ import annotations

import hashlib
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "game" / "echo_lattice" / "fonts" / "latin"
BASE = "https://cdn.jsdelivr.net/gh/IBM/plex@master"

FILES = {
    "IBMPlexSansCondensed-Regular.ttf": f"{BASE}/packages/plex-sans-condensed/fonts/complete/ttf/IBMPlexSansCondensed-Regular.ttf",
    "IBMPlexSansCondensed-SemiBold.ttf": f"{BASE}/packages/plex-sans-condensed/fonts/complete/ttf/IBMPlexSansCondensed-SemiBold.ttf",
    "IBMPlexSerif-Regular.ttf": f"{BASE}/packages/plex-serif/fonts/complete/ttf/IBMPlexSerif-Regular.ttf",
    "IBMPlexMono-Regular.ttf": f"{BASE}/packages/plex-mono/fonts/complete/ttf/IBMPlexMono-Regular.ttf",
    "OFL.txt": f"{BASE}/LICENSE.txt",
}


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    for name, url in FILES.items():
        dest = OUT / name
        print(f"GET {name}")
        with urllib.request.urlopen(url, timeout=60) as resp:
            data = resp.read()
        dest.write_bytes(data)
        digest = hashlib.sha256(data).hexdigest()[:16]
        print(f"  wrote {dest} ({len(data)} bytes, sha256={digest}…)")
    print("OK: latin stack ready under", OUT)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
