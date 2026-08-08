#!/usr/bin/env python3
"""Generate short procedural placeholder WAV/OGG for Echo Lattice audio stubs."""

from __future__ import annotations

import math
import struct
import subprocess
import sys
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
AUDIO = ROOT / "game" / "echo_lattice" / "audio"
SAMPLE_RATE = 44100


def _envelope(i: int, n: int, attack: float = 0.01, release: float = 0.05) -> float:
    t = i / SAMPLE_RATE
    dur = n / SAMPLE_RATE
    a = min(1.0, t / attack) if attack > 0 else 1.0
    r = 1.0
    if release > 0 and t > dur - release:
        r = max(0.0, (dur - t) / release)
    return a * r


def write_wav(path: Path, samples: list[float]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for s in samples:
            v = max(-1.0, min(1.0, s))
            frames += struct.pack("<h", int(v * 32767))
        wf.writeframes(frames)


def to_ogg(wav_path: Path) -> Path | None:
    ogg_path = wav_path.with_suffix(".ogg")
    try:
        subprocess.run(
            [
                "ffmpeg",
                "-y",
                "-loglevel",
                "error",
                "-i",
                str(wav_path),
                "-c:a",
                "libvorbis",
                "-q:a",
                "4",
                str(ogg_path),
            ],
            check=True,
        )
        return ogg_path
    except (subprocess.CalledProcessError, FileNotFoundError) as exc:
        print(f"ogg encode skipped for {wav_path.name}: {exc}", file=sys.stderr)
        return None


def tone(
    freq: float,
    duration: float,
    amp: float = 0.35,
    attack: float = 0.005,
    release: float = 0.04,
) -> list[float]:
    n = int(SAMPLE_RATE * duration)
    out: list[float] = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = _envelope(i, n, attack, release)
        out.append(math.sin(2 * math.pi * freq * t) * amp * env)
    return out


def noise_burst(duration: float, amp: float = 0.2) -> list[float]:
    # Deterministic "noise" so regenerations stay bit-stable.
    n = int(SAMPLE_RATE * duration)
    out: list[float] = []
    state = 1234567
    for i in range(n):
        state = (1103515245 * state + 12345) & 0x7FFFFFFF
        r = (state / 0x7FFFFFFF) * 2.0 - 1.0
        env = _envelope(i, n, 0.002, duration * 0.6)
        out.append(r * amp * env)
    return out


def mix(*parts: list[float]) -> list[float]:
    length = max((len(p) for p in parts), default=0)
    out = [0.0] * length
    for p in parts:
        for i, s in enumerate(p):
            out[i] += s
    peak = max((abs(s) for s in out), default=1.0) or 1.0
    if peak > 0.95:
        out = [s * (0.95 / peak) for s in out]
    return out


def concat(*parts: list[float]) -> list[float]:
    out: list[float] = []
    for p in parts:
        out.extend(p)
    return out


def footstep() -> list[float]:
    # Short dry click + soft low thump.
    return mix(noise_burst(0.045, 0.28), tone(180, 0.06, 0.22, 0.001, 0.05))


def rewrite() -> list[float]:
    # Rising dissonant chirp into a harder hit.
    n = int(SAMPLE_RATE * 0.22)
    chirp: list[float] = []
    for i in range(n):
        t = i / SAMPLE_RATE
        f = 220 + (880 - 220) * (t / 0.22)
        env = _envelope(i, n, 0.01, 0.06)
        chirp.append(math.sin(2 * math.pi * f * t) * 0.28 * env)
        chirp[-1] += math.sin(2 * math.pi * (f * 1.41) * t) * 0.12 * env
    hit = mix(tone(90, 0.12, 0.35, 0.001, 0.1), noise_burst(0.08, 0.25))
    # Overlap hit near end of chirp.
    out = chirp[:]
    start = len(out) - len(hit) // 3
    if start < 0:
        start = 0
    for i, s in enumerate(hit):
        idx = start + i
        if idx >= len(out):
            out.append(s)
        else:
            out[idx] += s
    peak = max((abs(s) for s in out), default=1.0) or 1.0
    return [s * (0.95 / peak) for s in out]


def win() -> list[float]:
    # Short major arpeggio C5-E5-G5.
    gap = [0.0] * int(SAMPLE_RATE * 0.03)
    return concat(
        tone(523.25, 0.12, 0.28, 0.005, 0.06),
        gap,
        tone(659.25, 0.12, 0.26, 0.005, 0.06),
        gap,
        tone(783.99, 0.22, 0.30, 0.005, 0.12),
    )


def ui_click() -> list[float]:
    return tone(1200, 0.04, 0.18, 0.001, 0.03)


def bed() -> list[float]:
    # ~2s soft loopable-ish low pulse for Music bus stub.
    duration = 2.0
    n = int(SAMPLE_RATE * duration)
    out: list[float] = []
    for i in range(n):
        t = i / SAMPLE_RATE
        pulse = 0.5 + 0.5 * math.sin(2 * math.pi * 1.5 * t)
        s = math.sin(2 * math.pi * 55 * t) * 0.12 * (0.6 + 0.4 * pulse)
        s += math.sin(2 * math.pi * 82.5 * t) * 0.04 * pulse
        # Fade edges slightly so loop is less clicky as a stub.
        edge = 1.0
        fade = 0.05
        if t < fade:
            edge = t / fade
        elif t > duration - fade:
            edge = (duration - t) / fade
        out.append(s * edge)
    return out


def emit(rel: str, samples: list[float]) -> None:
    wav_path = AUDIO / rel
    write_wav(wav_path, samples)
    ogg = to_ogg(wav_path)
    print(f"wrote {wav_path.relative_to(ROOT)}" + (f" + {ogg.name}" if ogg else ""))


def main() -> int:
    emit("sfx/footstep_placeholder.wav", footstep())
    emit("sfx/rewrite_placeholder.wav", rewrite())
    emit("sfx/win_placeholder.wav", win())
    emit("ui/ui_click_placeholder.wav", ui_click())
    emit("music/bed_placeholder.wav", bed())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
