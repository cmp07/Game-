#!/usr/bin/env python3
"""Negative-tests for validate_chambers.py.

Constructs deliberately broken chambers in-memory and asserts the validator
rejects each one. Also asserts the shipped chamber roster passes end-to-end.

Run:

    python3 game/echo_lattice/tests/test_validator.py
"""

from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import validate_chambers as vc  # noqa: E402


def _base() -> dict:
    with (HERE.parent / "content" / "chambers" / "00_first_echo.json").open() as f:
        return json.load(f)


def _schema() -> dict:
    with vc.SCHEMA_PATH.open() as f:
        return json.load(f)


def _errors_for(chamber: dict, filename: str = "00_first_echo.json") -> list[str]:
    schema = _schema()
    path = Path(filename)
    errs = vc._schema_check(chamber, schema, path.name, schema)
    errs.extend(vc._semantic_check(chamber, path))
    return errs


def _assert_fails(chamber: dict, message: str) -> None:
    errs = _errors_for(chamber)
    assert errs, f"expected validation to fail: {message}"


def _assert_passes(chamber: dict) -> None:
    errs = _errors_for(chamber)
    assert not errs, f"expected clean chamber to pass, got: {errs}"


def test_pristine_tutorial_passes() -> None:
    _assert_passes(_base())


def test_missing_source_fails() -> None:
    c = _base()
    c["lattice"]["cells"] = [row.replace("S", ".") for row in c["lattice"]["cells"]]
    _assert_fails(c, "no source glyph on grid")


def test_row_length_mismatch_fails() -> None:
    c = _base()
    c["lattice"]["cells"][0] = c["lattice"]["cells"][0] + "."
    _assert_fails(c, "row length must equal cols")


def test_unknown_glyph_fails() -> None:
    c = _base()
    c["lattice"]["cells"][0] = "Q" + c["lattice"]["cells"][0][1:]
    _assert_fails(c, "unknown glyph 'Q'")


def test_bad_teaches_enum_fails() -> None:
    c = _base()
    c["teaches"] = "hologram"
    _assert_fails(c, "teaches must be enum")


def test_tick_budget_below_one_fails() -> None:
    c = _base()
    c["tick_budget"] = 0
    _assert_fails(c, "tick_budget must be >= 1")


def test_budget_delta_pushes_below_one_fails() -> None:
    c = _base()
    c["tick_budget"] = 3
    c["variations"]["budget_deltas"] = [-5]
    _assert_fails(c, "budget_delta would push below 1")


def test_tutorial_may_not_rotate() -> None:
    c = _base()
    c["variations"]["allow_rotate"] = True
    _assert_fails(c, "tutorial must not allow_rotate")


def test_id_mismatch_fails() -> None:
    c = _base()
    c["id"] = "00_wrong_slug"
    _assert_fails(c, "id must match filename stem")


def test_goal_out_of_bounds_fails() -> None:
    c = _base()
    c["goal"]["cells"] = [[999, 999]]
    _assert_fails(c, "goal cell out of bounds")


def test_full_roster_validates() -> None:
    report = vc.validate_all()
    assert not report.failed, f"shipped chambers failed: {report.fail}"


def _run() -> int:
    tests = [name for name in globals() if name.startswith("test_")]
    failures: list[tuple[str, BaseException]] = []
    for name in tests:
        try:
            globals()[name]()
            print(f"OK   {name}")
        except AssertionError as e:
            print(f"FAIL {name}: {e}")
            failures.append((name, e))
        except Exception as e:
            print(f"ERR  {name}: {type(e).__name__}: {e}")
            failures.append((name, e))
    print(f"\n{len(tests) - len(failures)}/{len(tests)} tests passed")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(_run())
