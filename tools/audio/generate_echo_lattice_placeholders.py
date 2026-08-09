#!/usr/bin/env python3
"""Generate procedural AUDIO v3 lift assets for Echo Lattice.

Still procedural (not authored production audio) — but lifted beyond pure
beepware within DSP limits:

  * Rewrite slam = multi-stage ~0.90s musical phrase (heartbeat → crease →
    lift → slot → bleed) with authored rests and per-operator endings.
  * Habit stems = Ledger Cell motif transforms (1 → 5 → ♭2 → 1'), not four
    unrelated beds.
  * Win / fail stingers use the same cell grammar; rests stay quieter.

Regenerations are deterministic given GENERATOR_VERSION. Replace these before
marketing a "final mix" — see docs/VISION/AUDIO_V3.md + cue sheet.
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
GENERATOR_VERSION = 3

# Ledger Cell (AUDIO_V3 §4) — mid institutional register.
# scale degrees: 1 → 5 → ♭2 → 1'
CELL_1 = 220.0  # A3
CELL_5 = 330.0  # E4 (perfect fifth)
CELL_FLAT2 = 233.08  # ≈ A#3 / Bb — grit / habit wrongness
CELL_1P = 440.0  # A4 — almost home, leaves hunger
SLAM_TONIC = CELL_1  # slot lands into L0 tonic
REWRITE_DURATION = 0.90


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
    return [0.0] * max(0, int(SAMPLE_RATE * duration))


def noise_burst(
    duration: float,
    amp: float = 0.2,
    seed: int = 1234567,
    attack: float = 0.002,
    release_frac: float = 0.6,
) -> list[float]:
    n = int(SAMPLE_RATE * duration)
    out: list[float] = []
    state = seed & 0x7FFFFFFF
    for i in range(n):
        state = (1103515245 * state + 12345) & 0x7FFFFFFF
        r = (state / 0x7FFFFFFF) * 2.0 - 1.0
        env = _envelope(i, n, attack, max(0.001, duration * release_frac))
        out.append(r * amp * env)
    return out


def band_noise(
    duration: float,
    amp: float = 0.12,
    seed: int = 99,
    low_pass: float = 0.35,
) -> list[float]:
    """Soft fiber / paper noise — less hissy than white bursts."""
    n = int(SAMPLE_RATE * duration)
    out: list[float] = []
    state = seed & 0x7FFFFFFF
    y = 0.0
    for i in range(n):
        state = (1103515245 * state + 12345) & 0x7FFFFFFF
        r = (state / 0x7FFFFFFF) * 2.0 - 1.0
        y = y + low_pass * (r - y)
        env = _envelope(i, n, 0.004, duration * 0.55)
        out.append(y * amp * env)
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
    end = start + len(part)
    if end > len(out):
        out.extend([0.0] * (end - len(out)))
    for i, s in enumerate(part):
        out[start + i] += s
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


def plate_hit(freq: float, duration: float, amp: float = 0.28) -> list[float]:
    """Dry prepared-plate thud — cadmium body / slot downbeat."""
    body = tone(freq, duration, amp, 0.001, duration * 0.85)
    grit = noise_burst(min(0.05, duration * 0.4), amp * 0.45, seed=int(freq * 7), release_frac=0.75)
    partial = tone(freq * 2.01, duration * 0.55, amp * 0.22, 0.001, duration * 0.5)
    return mix(body, grit, partial)


def paper_crease(seed: int, amp: float = 0.16) -> list[float]:
    """Short dry paper percussion cell."""
    return mix(
        band_noise(0.028, amp, seed=seed, low_pass=0.55),
        tone(1400 + (seed % 5) * 90, 0.018, amp * 0.35, 0.001, 0.015),
        tone(90 + (seed % 3) * 12, 0.035, amp * 0.4, 0.001, 0.03),
    )


# ---------------------------------------------------------------------------
# Core locomotion / UI — dry ledger, not arcade
# ---------------------------------------------------------------------------


def footstep() -> list[float]:
    return mix(
        band_noise(0.05, 0.22, seed=11, low_pass=0.6),
        tone(165, 0.055, 0.16, 0.001, 0.045),
    )


def footstep_blocked() -> list[float]:
    return mix(
        band_noise(0.06, 0.14, seed=22, low_pass=0.45),
        tone(95, 0.07, 0.18, 0.001, 0.055),
    )


def ui_select() -> list[float]:
    """Selection tick — ink stroke / stick-on-wood (AUDIO_V3 §2.1 / UI_DIEGETIC §5.7)."""
    # Short pencil tip + dry fiber; authored silence tail so rapid nav breathes.
    tick = mix(
        tone(2050, 0.011, 0.065, 0.0004, 0.007),
        band_noise(0.016, 0.045, seed=41, low_pass=0.62),
        tone(170, 0.02, 0.035, 0.001, 0.016),
    )
    return concat(tick, silence(0.045))


def ui_hover() -> list[float]:
    """Extremely soft hover whisper — fiber brush only; omit if noisy in mix."""
    return concat(
        band_noise(0.014, 0.022, seed=53, low_pass=0.72),
        silence(0.055),
    )


def ui_click() -> list[float]:
    """Confirm stinger — soft ledger stamp (paper crease + ink), not arcade chirp."""
    crease = paper_crease(seed=77, amp=0.11)
    ink = tone(640, 0.032, 0.10, 0.001, 0.026)
    plate = tone(105, 0.048, 0.07, 0.001, 0.038)
    body = mix(crease, ink, plate)
    confirm = tone(960, 0.018, 0.045, 0.001, 0.014)
    phrase = overlay(body, confirm, start=int(SAMPLE_RATE * 0.018))
    return concat(phrase, silence(0.06))


# ---------------------------------------------------------------------------
# Shared slam grammar (stages 1–3) + operator endings (4–5)
# ---------------------------------------------------------------------------


def _slam_shared_prefix() -> list[float]:
    """Stages 1–3 timed to REWRITE_DURATION visual staging."""
    # Stage 1 Heartbeat 0.00–0.08: one dry cadmium hit, then ≥80 ms rest.
    heartbeat = plate_hit(95.0, 0.055, 0.34)
    post_heart_rest = silence(0.085)  # authored rest — ear must notice blank
    stage1 = concat(heartbeat, post_heart_rest)
    # Pad / trim so crease starts ≈0.08s from t0 (heartbeat+rest ≈0.14; pad later timeline)
    # Timeline absolute:
    out = silence(REWRITE_DURATION)
    out = overlay(out, heartbeat, start=0)
    # rest 0.055–0.14 is digital black by omission

    # Stage 2 Crease 0.08–0.35: staggered paper percussion with micro-gaps.
    crease_starts = [0.08, 0.13, 0.19, 0.25, 0.31]
    for k, t0 in enumerate(crease_starts):
        crease = paper_crease(seed=200 + k * 17, amp=0.14 + 0.02 * (k % 2))
        out = overlay(out, crease, start=int(SAMPLE_RATE * t0))

    # Stage 3 Lift 0.35–0.55: spectral / pitch lift with hush underneath (low amp).
    lift = mix(
        chirp(180, 420, 0.18, 0.12, 0.02, 0.08),
        tone(CELL_5 * 0.5, 0.16, 0.06, 0.03, 0.1),
        band_noise(0.14, 0.05, seed=301, low_pass=0.25),
    )
    out = overlay(out, lift, start=int(SAMPLE_RATE * 0.36))
    # Breath of hush under lift — no fill layers 0.50–0.55
    return out


def _slot_land(amp: float = 0.36) -> list[float]:
    """Stage 4 Slot — downbeat low plate + tonic confirmation."""
    return mix(
        plate_hit(70.0, 0.12, amp),
        tone(SLAM_TONIC, 0.14, amp * 0.55, 0.002, 0.12),
        tone(CELL_5, 0.08, amp * 0.18, 0.002, 0.07),
    )


def _bleed_grit(duration: float = 0.16, amp: float = 0.10, seed: int = 400) -> list[float]:
    return mix(
        band_noise(duration, amp, seed=seed, low_pass=0.4),
        tone(55, duration, amp * 0.7, 0.01, duration * 0.8),
    )


def _ending_fossilize() -> list[float]:
    # Descending lock into cold plate.
    lock = concat(
        tone(740, 0.05, 0.16, 0.002, 0.04),
        tone(520, 0.055, 0.18, 0.002, 0.04),
        tone(310, 0.09, 0.22, 0.002, 0.08),
    )
    plate = mix(tone(70, 0.14, 0.28, 0.001, 0.12), noise_burst(0.05, 0.12, seed=41))
    return overlay(lock, plate, start=int(SAMPLE_RATE * 0.08))


def _ending_deflector() -> list[float]:
    # Lateral shove interval (major 2nd sideways) + metallic edge.
    return mix(
        chirp(400, 180, 0.12, 0.22),
        tone(CELL_1 * 1.122, 0.09, 0.14, 0.001, 0.06),  # M2 above root
        tone(980, 0.04, 0.12, 0.001, 0.03),
        noise_burst(0.06, 0.14, seed=42),
    )


def _ending_carve() -> list[float]:
    # Air gate → bright click (shortest bleed).
    air = chirp(90, 640, 0.10, 0.14, 0.015, 0.05)
    gate = mix(tone(1320, 0.03, 0.16, 0.001, 0.025), noise_burst(0.028, 0.16, seed=43))
    return concat(air, gate)


def _ending_grow_wall() -> list[float]:
    # Stacked rising fifths (accretion arpeggio).
    return mix(
        tone(CELL_1, 0.16, 0.12, 0.02, 0.08),
        tone(CELL_5, 0.16, 0.11, 0.04, 0.08),
        tone(CELL_1P, 0.16, 0.09, 0.06, 0.08),
        noise_burst(0.1, 0.08, seed=44),
    )


def _ending_widen() -> list[float]:
    # Detuned open fifth bloom.
    return mix(
        tone(CELL_1, 0.14, 0.14, 0.01, 0.1),
        tone(CELL_5, 0.14, 0.12, 0.01, 0.1),
        tone(CELL_5 * 1.02, 0.14, 0.09, 0.01, 0.1),
        chirp(500, 820, 0.1, 0.1),
    )


def _ending_mirror() -> list[float]:
    # Motif then exact reverse (literal).
    forward = concat(
        tone(CELL_1, 0.045, 0.16),
        tone(CELL_5, 0.045, 0.16),
        tone(CELL_FLAT2, 0.055, 0.18),
    )
    return concat(forward, list(reversed(forward)))


def _ending_rotate() -> list[float]:
    # Pivot around a center tone.
    c = CELL_5
    return concat(
        tone(c * 0.84, 0.05, 0.14),
        tone(c, 0.055, 0.16),
        tone(c * 1.19, 0.05, 0.14),
        tone(c, 0.07, 0.18),
    )


def _ending_thicken() -> list[float]:
    # Low stack grows harmonics.
    n = int(SAMPLE_RATE * 0.18)
    out: list[float] = []
    for i in range(n):
        t = i / SAMPLE_RATE
        u = t / 0.18
        env = _envelope(i, n, 0.015, 0.06)
        s = math.sin(2 * math.pi * 90 * t) * 0.18
        s += math.sin(2 * math.pi * 180 * t) * 0.10 * u
        s += math.sin(2 * math.pi * 270 * t) * 0.07 * (u * u)
        out.append(s * env)
    return out


def _ending_invert() -> list[float]:
    # High tick → submerged inverse.
    return concat(
        tone(1100, 0.04, 0.16, 0.001, 0.025),
        silence(0.02),
        mix(tone(90, 0.12, 0.24, 0.001, 0.1), tone(45, 0.12, 0.14, 0.001, 0.1)),
    )


def _ending_generic() -> list[float]:
    # Neutral slot confirmation without strong consonant.
    return mix(
        tone(SLAM_TONIC, 0.12, 0.16, 0.005, 0.1),
        tone(CELL_5, 0.1, 0.08, 0.01, 0.08),
        _bleed_grit(0.12, 0.08, seed=39),
    )


OPERATOR_ENDINGS = {
    "fossilize_hot_cell": _ending_fossilize,
    "place_deflector": _ending_deflector,
    "carve_shortcut": _ending_carve,
    "grow_wall_far_from_path": _ending_grow_wall,
    "widen_hot_corridor": _ending_widen,
    "mirror": _ending_mirror,
    "rotate": _ending_rotate,
    "thicken": _ending_thicken,
    "invert": _ending_invert,
}


def rewrite_phrase(operator: str | None = None) -> list[float]:
    """Full ~0.90s slam phrase: shared grammar + operator consonant on 4–5."""
    out = _slam_shared_prefix()

    # Stage 4 Slot @ 0.55 — loudest point; no layers under the hit.
    slot = _slot_land(0.36)
    out = overlay(out, slot, start=int(SAMPLE_RATE * 0.55))

    # Post-slot breath 40–80 ms before bleed grit.
    # Stage 5 Bleed @ 0.70 — rust grit + operator ending.
    ending_fn = OPERATOR_ENDINGS.get(operator or "", _ending_generic)
    ending = ending_fn()
    bleed = _bleed_grit(
        0.18 if operator != "carve_shortcut" else 0.10,
        0.09 if operator != "carve_shortcut" else 0.06,
        seed=450 + (hash(operator or "generic") % 1000),
    )
    # Carve keeps shortest bleed; others settle motif into grit.
    if operator == "carve_shortcut":
        out = overlay(out, ending, start=int(SAMPLE_RATE * 0.70))
        out = overlay(out, bleed, start=int(SAMPLE_RATE * 0.78))
    else:
        out = overlay(out, ending, start=int(SAMPLE_RATE * 0.70))
        out = overlay(out, bleed, start=int(SAMPLE_RATE * 0.72))

    # Ensure exact phrase length (~0.90s); trim or pad.
    target = int(SAMPLE_RATE * REWRITE_DURATION)
    if len(out) < target:
        out.extend(silence((target - len(out)) / SAMPLE_RATE))
    elif len(out) > target:
        out = out[:target]
    # Soft tail into room silence (last 40 ms).
    fade_n = int(SAMPLE_RATE * 0.04)
    for i in range(fade_n):
        out[-(i + 1)] *= i / fade_n
    return out


def rewrite_generic() -> list[float]:
    return rewrite_phrase(None)


def rewrite_warn() -> list[float]:
    # Rising chalk scrape / dry tension — not a beep ladder.
    scrape = mix(
        band_noise(0.22, 0.12, seed=66, low_pass=0.3),
        chirp(240, 380, 0.2, 0.11, 0.02, 0.08),
        tone(CELL_FLAT2, 0.18, 0.06, 0.03, 0.1),
    )
    return scrape


# Compat wrappers used by emit table (operator-specific phrases).
def rewrite_fossilize() -> list[float]:
    return rewrite_phrase("fossilize_hot_cell")


def rewrite_deflector() -> list[float]:
    return rewrite_phrase("place_deflector")


def rewrite_carve() -> list[float]:
    return rewrite_phrase("carve_shortcut")


def rewrite_grow_wall() -> list[float]:
    return rewrite_phrase("grow_wall_far_from_path")


def rewrite_widen() -> list[float]:
    return rewrite_phrase("widen_hot_corridor")


def rewrite_mirror() -> list[float]:
    return rewrite_phrase("mirror")


def rewrite_rotate() -> list[float]:
    return rewrite_phrase("rotate")


def rewrite_thicken() -> list[float]:
    return rewrite_phrase("thicken")


def rewrite_invert() -> list[float]:
    return rewrite_phrase("invert")


# ---------------------------------------------------------------------------
# Diegetic PA / brutalist transit (no VO) — hush after
# ---------------------------------------------------------------------------


def pa_attention() -> list[float]:
    # Two-tone subway attention + authored post hush (silence tool).
    body = concat(
        squareish(880, 0.10, 0.13),
        silence(0.045),
        squareish(660, 0.12, 0.12),
    )
    return concat(body, silence(0.28))  # post-PA hush ~280 ms


def pa_board_tick() -> list[float]:
    return mix(tone(1900, 0.022, 0.09, 0.001, 0.018), noise_burst(0.018, 0.06, seed=55))


def pa_rewrite_armed() -> list[float]:
    body = concat(
        squareish(880, 0.09, 0.12),
        silence(0.04),
        squareish(660, 0.1, 0.11),
        silence(0.05),
        tone(520, 0.07, 0.11, 0.002, 0.05),
    )
    return concat(body, silence(0.32))


def pa_wing_clear() -> list[float]:
    body = concat(
        squareish(880, 0.09, 0.12),
        silence(0.04),
        squareish(660, 0.1, 0.11),
        silence(0.05),
        tone(CELL_1 * 2, 0.09, 0.12),
        tone(CELL_5 * 2, 0.12, 0.14),
    )
    return concat(body, silence(0.25))


# ---------------------------------------------------------------------------
# Win / fail — Ledger Cell grammar + open loop / institutional fail
# ---------------------------------------------------------------------------


def win_chamber() -> list[float]:
    # Short resolve via Ledger Cell 1 → 5 (satisfaction, no brass).
    gap = silence(0.04)
    resolve = concat(
        tone(CELL_1 * 2, 0.11, 0.22, 0.006, 0.07),  # 1'
        gap,
        tone(CELL_5 * 2, 0.18, 0.24, 0.006, 0.12),  # 5'
    )
    hold = tone(CELL_5 * 2, 0.12, 0.08, 0.01, 0.1)
    return concat(resolve, hold, silence(0.05))


def win_queue_next() -> list[float]:
    # Rising fourth → sharp leading tone cut early (hunger, not cadence).
    return concat(
        silence(0.03),
        tone(CELL_1 * 2, 0.07, 0.16, 0.004, 0.045),
        tone(CELL_1 * 2 * (4 / 3), 0.09, 0.2, 0.004, 0.05),  # fourth up
        tone(CELL_1 * 2 * 1.89, 0.12, 0.22, 0.004, 0.035),  # sharp leading, cuts
        silence(0.08),  # open-loop air — never resolve
    )


def win_fanfare() -> list[float]:
    return concat(win_chamber(), win_queue_next())


def win_wing() -> list[float]:
    # Longer dry filing stamp — still Field Ledger, not fanfare brass.
    body = win_chamber()
    coda = concat(
        silence(0.06),
        tone(CELL_1 * 2, 0.1, 0.16),
        tone(CELL_5 * 2, 0.1, 0.16),
        tone(CELL_1P * 2, 0.22, 0.18, 0.005, 0.14),
        silence(0.08),
    )
    return concat(body, coda)


def fail_reset() -> list[float]:
    """Dry institutional fail / restart — not cartoon sting or horror."""
    return concat(
        mix(plate_hit(80.0, 0.08, 0.22), tone(CELL_FLAT2, 0.1, 0.1, 0.002, 0.08)),
        silence(0.05),
        tone(CELL_1 * 0.75, 0.12, 0.14, 0.005, 0.1),
        silence(0.12),
    )


# ---------------------------------------------------------------------------
# Adaptive music stems — Ledger Cell motif transforms
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
    # Pedal / HVAC hum — root of Ledger Cell only; quieter than v2.
    duration = 4.0
    n = int(SAMPLE_RATE * duration)
    out: list[float] = []
    for i in range(n):
        t = i / SAMPLE_RATE
        pulse = 0.5 + 0.5 * math.sin(2 * math.pi * (66.0 / 60.0) * t)  # ~66 BPM felt
        s = math.sin(2 * math.pi * (CELL_1 * 0.5) * t) * 0.07 * (0.6 + 0.4 * pulse)
        s += math.sin(2 * math.pi * CELL_1 * t) * 0.018 * pulse
        # Soft duct air — felt more than heard
        s += math.sin(2 * math.pi * 48 * t) * 0.012 * (1.0 - 0.3 * pulse)
        out.append(s)
    return _loop_edge(out, 0.1)


def music_l1_lattice() -> list[float]:
    # Cell as sparse ticks — LED board rhythm, notes separated by rests.
    duration = 4.0
    n = int(SAMPLE_RATE * duration)
    out = [0.0] * n
    # Contour fragments: 1, rest, 5, rest, rest, ♭2 hint — never full cell.
    pattern = [
        (0.0, CELL_1, 0.04, 0.055),
        (1.0, CELL_5, 0.035, 0.05),
        (2.5, CELL_FLAT2, 0.03, 0.04),
        (3.25, CELL_1, 0.03, 0.035),
    ]
    for t0, freq, dur, amp in pattern:
        click = mix(
            tone(freq * 4, dur, amp, 0.001, 0.02),
            band_noise(dur * 0.8, amp * 0.35, seed=int(freq), low_pass=0.5),
        )
        start = int(SAMPLE_RATE * t0)
        for i, s in enumerate(click):
            if start + i < n:
                out[start + i] += s
    return _loop_edge(out, 0.06)


def music_l2_habit() -> list[float]:
    # Full cell; ♭2 / dissonant fifth heat (habit locking).
    duration = 4.0
    n = int(SAMPLE_RATE * duration)
    out: list[float] = []
    # Phrase every ~2s: 1 → 5 → ♭2 → 1'
    notes = [(0.0, CELL_1), (0.35, CELL_5), (0.7, CELL_FLAT2), (1.05, CELL_1P)]
    bed = [0.0] * n
    for cycle in (0.0, 2.0):
        for t0, freq in notes:
            start = int(SAMPLE_RATE * (cycle + t0))
            note = tone(freq, 0.28, 0.055 if freq != CELL_FLAT2 else 0.08, 0.02, 0.12)
            for i, s in enumerate(note):
                if start + i < n:
                    bed[start + i] += s
    for i in range(n):
        t = i / SAMPLE_RATE
        slow = 0.5 + 0.5 * math.sin(2 * math.pi * 0.25 * t)
        # Perfect fifth + minor second clash = habit locking
        s = math.sin(2 * math.pi * CELL_1 * t) * 0.035 * slow
        s += math.sin(2 * math.pi * CELL_5 * t) * 0.03
        s += math.sin(2 * math.pi * CELL_FLAT2 * t) * 0.04 * (0.4 + 0.6 * (1.0 - slow))
        out.append(s + bed[i])
    return _loop_edge(out, 0.08)


def music_l3_rewrite() -> list[float]:
    # Cell compressed / inverted / answered — commit heat (slam rhyme).
    duration = 4.0
    n = int(SAMPLE_RATE * duration)
    out: list[float] = []
    # Inverted contour fragments: 1' → ♭2 → 5 → 1 (answer, compressed).
    answer = [(0.0, CELL_1P), (0.18, CELL_FLAT2), (0.36, CELL_5), (0.54, CELL_1)]
    bed = [0.0] * n
    for cycle in (0.0, 1.2, 2.4, 3.2):
        for t0, freq in answer:
            start = int(SAMPLE_RATE * (cycle + t0))
            if start >= n:
                continue
            note = tone(freq, 0.14, 0.06, 0.008, 0.06)
            for i, s in enumerate(note):
                if start + i < n:
                    bed[start + i] += s
    for i in range(n):
        t = i / SAMPLE_RATE
        swell = 0.5 + 0.5 * math.sin(2 * math.pi * 0.5 * t)
        s = math.sin(2 * math.pi * CELL_1 * 0.75 * t) * 0.05 * swell
        s += math.sin(2 * math.pi * CELL_FLAT2 * t) * 0.035 * swell
        # Slight beating — rewrite imminent
        s += math.sin(2 * math.pi * (CELL_5 + 0.7) * t) * 0.02
        out.append(s + bed[i] * (0.7 + 0.3 * swell))
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
    print(f"Echo Lattice placeholder generator v{GENERATOR_VERSION} (AUDIO v3 lift)")

    # Locomotion / UI (Field Index feel — select / hover / confirm)
    emit("sfx/footstep_placeholder.wav", footstep())
    emit("sfx/footstep_blocked_placeholder.wav", footstep_blocked())
    emit("ui/ui_select_placeholder.wav", ui_select())
    emit("ui/ui_hover_placeholder.wav", ui_hover())
    emit("ui/ui_click_placeholder.wav", ui_click())

    # Generic rewrite (compat) + warn — full multi-stage phrase
    emit("sfx/rewrite_placeholder.wav", rewrite_generic())
    emit("sfx/rewrite_warn_placeholder.wav", rewrite_warn())

    # Per-operator slam phrases (~0.90s)
    emit("sfx/rewrite/fossilize_hot_cell.wav", rewrite_fossilize())
    emit("sfx/rewrite/place_deflector.wav", rewrite_deflector())
    emit("sfx/rewrite/carve_shortcut.wav", rewrite_carve())
    emit("sfx/rewrite/grow_wall_far_from_path.wav", rewrite_grow_wall())
    emit("sfx/rewrite/widen_hot_corridor.wav", rewrite_widen())
    emit("sfx/rewrite/mirror.wav", rewrite_mirror())
    emit("sfx/rewrite/rotate.wav", rewrite_rotate())
    emit("sfx/rewrite/thicken.wav", rewrite_thicken())
    emit("sfx/rewrite/invert.wav", rewrite_invert())

    # Diegetic PA (with post hush)
    emit("sfx/pa/attention_chime.wav", pa_attention())
    emit("sfx/pa/board_tick.wav", pa_board_tick())
    emit("sfx/pa/rewrite_armed.wav", pa_rewrite_armed())
    emit("sfx/pa/wing_clear.wav", pa_wing_clear())

    # Win / queue-next addiction beat + fail reset
    emit("sfx/win_placeholder.wav", win_fanfare())
    emit("sfx/win/chamber_resolve.wav", win_chamber())
    emit("sfx/win/queue_next.wav", win_queue_next())
    emit("sfx/win/fanfare.wav", win_fanfare())
    emit("sfx/win/wing_clear.wav", win_wing())
    emit("sfx/fail/reset.wav", fail_reset())

    # Adaptive stems — Ledger Cell transforms
    emit("music/bed_placeholder.wav", bed_legacy_alias())
    emit("music/L0_bed.wav", music_l0_bed())
    emit("music/L1_lattice.wav", music_l1_lattice())
    emit("music/L2_habit.wav", music_l2_habit())
    emit("music/L3_rewrite.wav", music_l3_rewrite())

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
