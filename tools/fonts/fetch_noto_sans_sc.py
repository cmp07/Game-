#!/usr/bin/env python3
"""Download Noto Sans SC Regular (SIL OFL 1.1) into fonts/cjk/.

Binaries stay gitignored by default (~tens of MB). For CI / Deck / zh_Hans
smoke, run this script before exporting. To commit via Git LFS later:

  git lfs install
  git lfs track 'game/echo_lattice/fonts/cjk/*.otf'
  # remove the matching lines from .gitignore, then:
  git add .gitattributes game/echo_lattice/fonts/cjk/NotoSansSC-Regular.otf

Source: notofonts/noto-cjk Sans 2.004 language-specific subset zip (OFL).
See game/echo_lattice/fonts/README.md and fonts/cjk/OFL.txt.
"""
from __future__ import annotations

import argparse
import io
import sys
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CJK_DIR = ROOT / "game" / "echo_lattice" / "fonts" / "cjk"
OFL_URL = "https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/LICENSE"
# Subset SC family zip (~50 MB) — extracts Regular only.
ZIP_URL = (
    "https://github.com/notofonts/noto-cjk/releases/download/"
    "Sans2.004/18_NotoSansSC.zip"
)
TARGET_NAMES = (
    "NotoSansSC-Regular.otf",
    "NotoSansSC-Regular.ttf",
)


def _download(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "echo-lattice-font-fetch/1.0"})
    with urllib.request.urlopen(req, timeout=120) as resp:
        return resp.read()


def ensure_ofl(force: bool = False) -> Path:
    dest = CJK_DIR / "OFL.txt"
    if dest.is_file() and not force:
        return dest
    CJK_DIR.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(_download(OFL_URL))
    return dest


def fetch_regular(force: bool = False) -> Path:
    CJK_DIR.mkdir(parents=True, exist_ok=True)
    for name in TARGET_NAMES:
        existing = CJK_DIR / name
        if existing.is_file() and not force:
            print(f"OK: already present {existing}")
            return existing

    print(f"Downloading {ZIP_URL} …")
    blob = _download(ZIP_URL)
    with zipfile.ZipFile(io.BytesIO(blob)) as zf:
        candidates = [
            n
            for n in zf.namelist()
            if n.endswith(TARGET_NAMES) and not n.startswith("__MACOSX")
        ]
        # Prefer Regular; avoid Bold/Light/etc.
        regular = [n for n in candidates if "Regular" in Path(n).name]
        if not regular:
            raise RuntimeError(
                f"No Regular face in zip; saw: {candidates[:8] or zf.namelist()[:12]}"
            )
        member = sorted(regular, key=lambda n: (0 if n.endswith(".otf") else 1, n))[0]
        data = zf.read(member)
        out_name = Path(member).name
        # Normalize to LocaleManager candidate name when needed.
        if out_name not in TARGET_NAMES:
            out_name = "NotoSansSC-Regular.otf"
        dest = CJK_DIR / out_name
        dest.write_bytes(data)
        print(f"OK: wrote {dest} ({len(data)} bytes) from {member}")
        return dest


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
        fetch_regular(force=args.force)
    except Exception as exc:  # noqa: BLE001 — CLI surface
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
