#!/usr/bin/env python3
"""Generate procedural placeholder WAV/OGG for Echo Lattice AUDIO v2.

Placeholders are intentionally non-final: they encode *identity* (transit PA,
operator-unique rewrite stingers, habit-layer stems, silence-aware beds, and a
queue-next win fanfare) so Godot wiring and mix passes can land before authored
assets. Regenerations are deterministic given the same generator version.
"""

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
GENERATOR_VERSION = 2


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
    phase: float = 0.0,
) -> list[float]:
    n = int(SAMPLE_RATE * duration)
    out: list[float] = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = _envelope(i, n, attack, release)
        out.append(math.sin(2 * math.pi * freq * t + phase) * amp * env)
    return out


def silence(duration: float) -> list[float]:
    return [0.0] * int(SAMPLE_RATE * duration)


def noise_burst(duration: float, amp: float = 0.2, seed: int = 1234567) -> list[float]:
    n = int(SAMPLE_RATE * duration)
    out: list[float] = []
    state = seed & 0x7FFFFFFF
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


def overlay(base: list[float], part: list[float], start: int = 0) -> list[float]:
    out = base[:]
    for i, s in enumerate(part):
        idx = start + i
        if idx >= len(out):
            out.append(s)
        else:
            out[idx] += s
    peak = max((abs(s) for s in out), default=1.0) or 1.0
    if peak > 0.95:
        out = [s * (0.95 / peak) for s in out]
    return out


def concat(*parts: list[float]) -> list[float]:
    out: list[float] = []
    for p in parts:
        out.extend(p)
    return out


def chirp(
    f0: float,
    f1: float,
    duration: float,
    amp: float = 0.28,
    attack: float = 0.01,
    release: float = 0.06,
) -> list[float]:
    n = int(SAMPLE_RATE * duration)
    out: list[float] = []
    for i in range(n):
        t = i / SAMPLE_RATE
        u = t / duration if duration > 0 else 0.0
        f = f0 + (f1 - f0) * u
        env = _envelope(i, n, attack, release)
        out.append(math.sin(2 * math.pi * f * t) * amp * env)
    return out


def squareish(freq: float, duration: float, amp: float = 0.18) -> list[float]:
    """Soft clipped square for brutalist transit buzzers (not chiptune playful)."""
    n = int(SAMPLE_RATE * duration)
    out: list[float] = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = _envelope(i, n, 0.002, 0.03)
        s = math.sin(2 * math.pi * freq * t)
        s += 0.35 * math.sin(2 * math.pi * freq * 3 * t)
        out.append(max(-1.0, min(1.0, s * 1.4)) * amp * env)
    return out


# ---------------------------------------------------------------------------
# Core locomotion / UI
# ---------------------------------------------------------------------------


def footstep() -> list[float]:
    return mix(noise_burst(0.045, 0.28, seed=11), tone(180, 0.06, 0.22, 0.001, 0.05))


def footstep_blocked() -> list[float]:
    return mix(noise_burst(0.05, 0.18, seed=22), tone(110, 0.07, 0.2, 0.001, 0.06))


def ui_click() -> list[float]:
    return tone(1200, 0.04, 0.18, 0.001, 0.03)


# ---------------------------------------------------------------------------
# Per-operator rewrite stingers (unique identity each)
# ---------------------------------------------------------------------------


def rewrite_generic() -> list[float]:
    chirp_part = mix(
        chirp(220, 880, 0.22, 0.28),
        chirp(220 * 1.41, 880 * 1.41, 0.22, 0.12),
    )
    hit = mix(tone(90, 0.12, 0.35, 0.001, 0.1), noise_burst(0.08, 0.25, seed=33))
    return overlay(chirp_part, hit, start=max(0, len(chirp_part) - len(hit) // 3))


def rewrite_fossilize() -> list[float]:
    # Cold lock: descending partials settle into a hard low plate.
    body = concat(
        tone(740, 0.07, 0.22, 0.002, 0.05),
        tone(520, 0.08, 0.24, 0.002, 0.05),
        tone(310, 0.14, 0.30, 0.002, 0.1),
    )
    plate = mix(tone(70, 0.18, 0.32, 0.001, 0.14), noise_burst(0.06, 0.16, seed=41))
    return overlay(body, plate, start=int(SAMPLE_RATE * 0.12))


def rewrite_deflector() -> list[float]:
    # Lateral shove: quick sideband sweep + metallic edge.
    return mix(
        chirp(400, 180, 0.14, 0.3),
        tone(980, 0.05, 0.16, 0.001, 0.04),
        noise_burst(0.07, 0.2, seed=42),
        tone(140, 0.1, 0.22, 0.001, 0.08),
    )


def rewrite_carve() -> list[float]:
    # Opening: reverse-ish air rush into a bright gate click.
    air = chirp(90, 640, 0.16, 0.2, 0.02, 0.08)
    gate = mix(tone(1320, 0.04, 0.2, 0.001, 0.03), noise_burst(0.035, 0.22, seed=43))
    return concat(air, gate)


def rewrite_grow_wall() -> list[float]:
    # Accretion: stacked rising fifths that thicken.
    layers = [
        tone(180, 0.22, 0.16, 0.02, 0.1),
        tone(270, 0.22, 0.14, 0.04, 0.1),
        tone(360, 0.22, 0.12, 0.06, 0.1),
    ]
    grit = noise_burst(0.12, 0.12, seed=44)
    return mix(*(layers + [grit]))


def rewrite_widen() -> list[float]:
    # Lateral open: stereo-implied by dual detuned highs (mono: two close tones).
    return mix(
        chirp(500, 900, 0.12, 0.2),
        tone(660, 0.14, 0.18, 0.01, 0.08),
        tone(673, 0.14, 0.14, 0.01, 0.08),
        tone(100, 0.1, 0.16, 0.001, 0.08),
    )


def rewrite_mirror() -> list[float]:
    # Symmetry: forward motif then exact reverse contour.
    forward = concat(tone(440, 0.06, 0.22), tone(554, 0.06, 0.22), tone(659, 0.08, 0.24))
    return concat(forward, list(reversed(forward)))


def rewrite_rotate() -> list[float]:
    # Pivot: three equal steps around a center.
    return concat(
        tone(392, 0.07, 0.2),
        tone(494, 0.07, 0.22),
        tone(587, 0.07, 0.2),
        tone(494, 0.09, 0.24),
    )


def rewrite_thicken() -> list[float]:
    # Mass: low stack grows harmonics.
    n = int(SAMPLE_RATE * 0.28)
    out: list[float] = []
    for i in range(n):
        t = i / SAMPLE_RATE
        u = t / 0.28
        env = _envelope(i, n, 0.02, 0.08)
        s = math.sin(2 * math.pi * 90 * t) * 0.22
        s += math.sin(2 * math.pi * 180 * t) * 0.12 * u
        s += math.sin(2 * math.pi * 270 * t) * 0.08 * (u * u)
        out.append(s * env)
    return out


def rewrite_invert() -> list[float]:
    # Polarity flip: high tick then submerged inverse.
    return concat(
        tone(1100, 0.05, 0.22, 0.001, 0.03),
        silence(0.02),
        mix(tone(90, 0.16, 0.3, 0.001, 0.12), tone(45, 0.16, 0.18, 0.001, 0.12)),
    )


def rewrite_warn() -> list[float]:
    return mix(chirp(300, 520, 0.18, 0.2), tone(300 * 1.5, 0.18, 0.08, 0.01, 0.08))


# ---------------------------------------------------------------------------
# Diegetic PA / brutalist transit (no VO)
# ---------------------------------------------------------------------------


def pa_attention() -> list[float]:
    # Two-tone subway attention chime (dry, institutional).
    return concat(
        squareish(880, 0.11, 0.16),
        silence(0.04),
        squareish(660, 0.14, 0.15),
    )


def pa_board_tick() -> list[float]:
    return mix(tone(1900, 0.025, 0.12, 0.001, 0.02), noise_burst(0.02, 0.08, seed=55))


def pa_rewrite_armed() -> list[float]:
    return concat(pa_attention(), silence(0.05), tone(520, 0.08, 0.14, 0.002, 0.05))


def pa_wing_clear() -> list[float]:
    return concat(
        pa_attention(),
        silence(0.06),
        tone(523.25, 0.1, 0.16),
        tone(659.25, 0.14, 0.18),
    )


# ---------------------------------------------------------------------------
# Win / addiction — resolve then open loop that begs the next chamber
# ---------------------------------------------------------------------------


def win_chamber() -> list[float]:
    # Clear major resolve (C–E–G) then a soft held fifth — satisfaction.
    gap = silence(0.03)
    resolve = concat(
        tone(523.25, 0.11, 0.28, 0.005, 0.06),
        gap,
        tone(659.25, 0.11, 0.26, 0.005, 0.06),
        gap,
        tone(783.99, 0.2, 0.30, 0.005, 0.12),
    )
    hold = tone(783.99, 0.18, 0.12, 0.01, 0.14)
    return concat(resolve, hold)


def win_queue_next() -> list[float]:
    # Open-loop hunger: unresolved rising fourth into a slightly sharp leading
    # tone that cuts early — dopamine for "one more chamber".
    return concat(
        silence(0.04),
        tone(523.25, 0.08, 0.2, 0.004, 0.05),
        tone(698.46, 0.1, 0.24, 0.004, 0.06),  # F5
        tone(830.61, 0.16, 0.26, 0.004, 0.05),  # G#5 — leans forward, cuts
    )


def win_fanfare() -> list[float]:
    return concat(win_chamber(), win_queue_next())


def win_wing() -> list[float]:
    body = win_chamber()
    coda = concat(
        silence(0.05),
        tone(523.25, 0.12, 0.22),
        tone(659.25, 0.12, 0.22),
        tone(783.99, 0.12, 0.22),
        tone(1046.5, 0.28, 0.26, 0.005, 0.18),
    )
    return concat(body, coda)


# ---------------------------------------------------------------------------
# Adaptive music stems (habit solidification layers)
# ---------------------------------------------------------------------------


def _loop_edge(samples: list[float], fade: float = 0.05) -> list[float]:
    n = len(samples)
    fade_n = int(SAMPLE_RATE * fade)
    out = samples[:]
    for i in range(fade_n):
        w = i / fade_n
        out[i] *= w
        out[n - 1 - i] *= w
    return out


def music_l0_bed() -> list[float]:
    # Ventilation pulse — subway HVAC / distant transformer.
    duration = 4.0
    n = int(SAMPLE_RATE * duration)
    out: list[float] = []
    for i in range(n):
        t = i / SAMPLE_RATE
        pulse = 0.5 + 0.5 * math.sin(2 * math.pi * 0.75 * t)
        s = math.sin(2 * math.pi * 55 * t) * 0.11 * (0.55 + 0.45 * pulse)
        s += math.sin(2 * math.pi * 82.5 * t) * 0.035 * pulse
        s += math.sin(2 * math.pi * 110 * t) * 0.015 * (1.0 - pulse)
        out.append(s)
    return _loop_edge(out, 0.08)


def music_l1_lattice() -> list[float]:
    # Sparse high ticks — map grid / LED board.
    duration = 4.0
    n = int(SAMPLE_RATE * duration)
    out = [0.0] * n
    interval = int(SAMPLE_RATE * 0.5)
    for k, start in enumerate(range(0, n, interval)):
        click = tone(1800 + (k % 3) * 120, 0.03, 0.07, 0.001, 0.02)
        for i, s in enumerate(click):
            if start + i < n:
                out[start + i] += s
    return _loop_edge(out, 0.05)


def music_l2_habit() -> list[float]:
    # Dissonant fifths — habit solidifying / addiction tension.
    duration = 4.0
    n = int(SAMPLE_RATE * duration)
    out: list[float] = []
    for i in range(n):
        t = i / SAMPLE_RATE
        slow = 0.5 + 0.5 * math.sin(2 * math.pi * 0.25 * t)
        s = math.sin(2 * math.pi * 220 * t) * 0.07 * slow
        s += math.sin(2 * math.pi * 329.63 * t) * 0.055  # E — uneasy vs A
        s += math.sin(2 * math.pi * 466.16 * t) * 0.03 * (1.0 - slow)
        out.append(s)
    return _loop_edge(out, 0.08)


def music_l3_rewrite() -> list[float]:
    # Narrow-band swell — rewrite imminent / committing.
    duration = 4.0
    n = int(SAMPLE_RATE * duration)
    out: list[float] = []
    for i in range(n):
        t = i / SAMPLE_RATE
        swell = 0.5 + 0.5 * math.sin(2 * math.pi * 0.5 * t)
        s = math.sin(2 * math.pi * 160 * t) * 0.08 * swell
        s += math.sin(2 * math.pi * 240 * t) * 0.05 * swell
        s += math.sin(2 * math.pi * 320.5 * t) * 0.03  # slight beating
        out.append(s)
    return _loop_edge(out, 0.08)


def bed_legacy_alias() -> list[float]:
    """Keep v1 bed_placeholder path working as L0 alias content."""
    return music_l0_bed()[: int(SAMPLE_RATE * 2.0)]


def emit(rel: str, samples: list[float]) -> None:
    wav_path = AUDIO / rel
    write_wav(wav_path, samples)
    ogg = to_ogg(wav_path)
    print(f"wrote {wav_path.relative_to(ROOT)}" + (f" + {ogg.name}" if ogg else ""))


def main() -> int:
    print(f"Echo Lattice placeholder generator v{GENERATOR_VERSION}")

    # Locomotion / UI
    emit("sfx/footstep_placeholder.wav", footstep())
    emit("sfx/footstep_blocked_placeholder.wav", footstep_blocked())
    emit("ui/ui_click_placeholder.wav", ui_click())

    # Generic rewrite (compat) + warn
    emit("sfx/rewrite_placeholder.wav", rewrite_generic())
    emit("sfx/rewrite_warn_placeholder.wav", rewrite_warn())

    # Per-operator stingers
    emit("sfx/rewrite/fossilize_hot_cell.wav", rewrite_fossilize())
    emit("sfx/rewrite/place_deflector.wav", rewrite_deflector())
    emit("sfx/rewrite/carve_shortcut.wav", rewrite_carve())
    emit("sfx/rewrite/grow_wall_far_from_path.wav", rewrite_grow_wall())
    emit("sfx/rewrite/widen_hot_corridor.wav", rewrite_widen())
    emit("sfx/rewrite/mirror.wav", rewrite_mirror())
    emit("sfx/rewrite/rotate.wav", rewrite_rotate())
    emit("sfx/rewrite/thicken.wav", rewrite_thicken())
    emit("sfx/rewrite/invert.wav", rewrite_invert())

    # Diegetic PA
    emit("sfx/pa/attention_chime.wav", pa_attention())
    emit("sfx/pa/board_tick.wav", pa_board_tick())
    emit("sfx/pa/rewrite_armed.wav", pa_rewrite_armed())
    emit("sfx/pa/wing_clear.wav", pa_wing_clear())

    # Win / queue-next addiction beat
    emit("sfx/win_placeholder.wav", win_fanfare())  # v1 path = full fanfare
    emit("sfx/win/chamber_resolve.wav", win_chamber())
    emit("sfx/win/queue_next.wav", win_queue_next())
    emit("sfx/win/fanfare.wav", win_fanfare())
    emit("sfx/win/wing_clear.wav", win_wing())

    # Adaptive stems
    emit("music/bed_placeholder.wav", bed_legacy_alias())
    emit("music/L0_bed.wav", music_l0_bed())
    emit("music/L1_lattice.wav", music_l1_lattice())
    emit("music/L2_habit.wav", music_l2_habit())
    emit("music/L3_rewrite.wav", music_l3_rewrite())

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
