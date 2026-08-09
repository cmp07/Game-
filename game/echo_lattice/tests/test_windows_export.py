#!/usr/bin/env python3
"""Contract tests for reproducible Windows (+ Demo) export Gate A surfaces."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "game" / "echo_lattice"
PRESETS = PROJECT / "export_presets.cfg"
PROJECT_GODOT = PROJECT / "project.godot"
TOOLCHAIN = ROOT / "tools" / "release" / "godot_toolchain.json"
EXPORT_SH = ROOT / "tools" / "release" / "export_windows.sh"
STAMP_PY = ROOT / "tools" / "release" / "stamp_export_artifacts.py"
STAMP_SH = ROOT / "tools" / "release" / "stamp_export_artifacts.sh"
BUILD_DOC = ROOT / "docs" / "RELEASE" / "BUILD_WINDOWS.md"
CI_YML = ROOT / ".github" / "workflows" / "ci.yml"


def fail(msg: str) -> None:
    print(f"FAIL: {msg}", file=sys.stderr)
    raise SystemExit(1)


def project_version() -> str:
    text = PROJECT_GODOT.read_text(encoding="utf-8")
    for line in text.splitlines():
        if line.startswith("config/version="):
            return line.split("=", 1)[1].strip().strip('"')
    fail("project.godot missing config/version")
    return ""


def preset_block(name: str, text: str) -> str:
    # Split only on [preset.N] headers — not [preset.N.options].
    chunks = re.split(r"(?m)^\[preset\.\d+\]\s*$", text)
    for chunk in chunks:
        if re.search(rf'(?m)^name="{re.escape(name)}"\s*$', chunk):
            return chunk
    fail(f"export_presets.cfg missing preset {name!r}")
    return ""


def main() -> None:
    version = project_version()
    win_ver = f"{version}.0"

    if not EXPORT_SH.is_file():
        fail(f"missing {EXPORT_SH.relative_to(ROOT)}")
    if not STAMP_PY.is_file():
        fail(f"missing {STAMP_PY.relative_to(ROOT)}")
    if not STAMP_SH.is_file():
        fail(f"missing {STAMP_SH.relative_to(ROOT)}")
    if not BUILD_DOC.is_file():
        fail(f"missing {BUILD_DOC.relative_to(ROOT)}")
    if not TOOLCHAIN.is_file():
        fail(f"missing {TOOLCHAIN.relative_to(ROOT)}")

    tool = json.loads(TOOLCHAIN.read_text(encoding="utf-8"))
    if tool.get("product_version") != version:
        fail(
            f"godot_toolchain.json product_version {tool.get('product_version')!r} "
            f"!= project config/version {version!r}"
        )
    if tool.get("windows_file_version") != win_ver:
        fail(
            f"godot_toolchain.json windows_file_version {tool.get('windows_file_version')!r} "
            f"!= {win_ver!r}"
        )
    digest = tool.get("ci_container", {}).get("digest", "")
    if not str(digest).startswith("sha256:") or len(digest) < 70:
        fail("godot_toolchain.json ci_container.digest must be a full sha256:… pin")
    editor = tool.get("official_downloads", {}).get("linux_editor_x86_64", {})
    if len(editor.get("sha256", "")) != 64:
        fail("linux editor sha256 missing/invalid in godot_toolchain.json")

    presets = PRESETS.read_text(encoding="utf-8")
    for name, exe, features in (
        ("Windows Desktop", "EchoLattice.exe", None),
        ("Windows Demo", "EchoLatticeDemo.exe", "demo"),
    ):
        block = preset_block(name, presets)
        if f'export_path="builds/' not in block and exe not in block:
            fail(f"{name}: unexpected export_path")
        if exe not in block:
            fail(f"{name}: missing {exe}")
        if f'application/file_version="{win_ver}"' not in block:
            fail(f"{name}: application/file_version must be {win_ver}")
        if f'application/product_version="{win_ver}"' not in block:
            fail(f"{name}: application/product_version must be {win_ver}")
        if "application/modify_resources=false" not in block:
            fail(f"{name}: modify_resources must stay false for CI without rcedit")
        if "binary_format/architecture=\"x86_64\"" not in block:
            fail(f"{name}: architecture must be x86_64")
        if features is not None and f'custom_features="{features}"' not in block:
            fail(f"{name}: custom_features must be {features!r}")

    doc = BUILD_DOC.read_text(encoding="utf-8")
    for needle in (
        "export_windows.sh",
        "BUILD_STAMP.json",
        "SHA256SUMS.txt",
        "ARTIFACTS.md",
        "barichello/godot-ci",
        "Windows Demo",
        "0.2.1",
    ):
        if needle not in doc:
            fail(f"BUILD_WINDOWS.md missing {needle!r}")

    ci = CI_YML.read_text(encoding="utf-8")
    if digest not in ci:
        fail("ci.yml must pin barichello/godot-ci by digest from godot_toolchain.json")
    for needle in (
        "export-windows",
        "export-windows-demo",
        "stamp_export_artifacts.sh",
        "Windows Desktop",
        "Windows Demo",
        "echo-lattice-windows-x86_64",
        "echo-lattice-windows-demo-x86_64",
        "BUILD_STAMP.json",
    ):
        if needle not in ci:
            fail(f"ci.yml missing {needle!r}")

    # Stamp helper smoke (no Godot): Python + POSIX shell variants.
    import json as _json
    import subprocess
    import tempfile

    from importlib.util import module_from_spec, spec_from_file_location

    spec = spec_from_file_location("stamp_export_artifacts", STAMP_PY)
    assert spec and spec.loader
    mod = module_from_spec(spec)
    spec.loader.exec_module(mod)
    with tempfile.TemporaryDirectory() as tmp:
        out = Path(tmp)
        (out / "EchoLattice.exe").write_bytes(b"MZ-fake")
        (out / "EchoLattice.pck").write_bytes(b"pck-fake")
        stamp = mod.write_stamp(
            out,
            preset="Windows Desktop",
            artifact_name="echo-lattice-windows-x86_64",
            custom_features="",
            exe_name="EchoLattice.exe",
        )
        if stamp["product_version"] != version:
            fail("stamp product_version mismatch")
        if not (out / "SHA256SUMS.txt").is_file():
            fail("stamp did not write SHA256SUMS.txt")
        if not (out / "ARTIFACTS.md").is_file():
            fail("stamp did not write ARTIFACTS.md")
        if len(stamp["checksums_sha256"]) != 2:
            fail("stamp should checksum exe + pck")

    with tempfile.TemporaryDirectory() as tmp:
        out = Path(tmp)
        (out / "EchoLatticeDemo.exe").write_bytes(b"MZ-demo")
        (out / "EchoLatticeDemo.pck").write_bytes(b"pck-demo")
        subprocess.check_call(
            [
                "sh",
                str(STAMP_SH),
                "--out-dir",
                str(out),
                "--preset",
                "Windows Demo",
                "--artifact-name",
                "echo-lattice-windows-demo-x86_64",
                "--exe-name",
                "EchoLatticeDemo.exe",
                "--custom-features",
                "demo",
            ]
        )
        shell_stamp = _json.loads((out / "BUILD_STAMP.json").read_text(encoding="utf-8"))
        if shell_stamp.get("product_version") != version:
            fail("shell stamp product_version mismatch")
        if shell_stamp.get("custom_features") != "demo":
            fail("shell stamp custom_features mismatch")
        if len(shell_stamp.get("checksums_sha256") or {}) != 2:
            fail("shell stamp should checksum exe + pck")
        sums = (out / "SHA256SUMS.txt").read_text(encoding="utf-8").strip().splitlines()
        if len(sums) != 2:
            fail("shell SHA256SUMS.txt line count mismatch")

    print(f"  project version: {version}")
    print(f"  windows file version: {win_ver}")
    print("  presets: Windows Desktop + Windows Demo OK")
    print("  toolchain pin + CI digest: OK")
    print("  stamp helper smoke (py + sh): OK")
    print("result: OK")


if __name__ == "__main__":
    main()
