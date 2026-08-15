# The Weaver — 36 · Speak / Type spike

**Doc:** `docs/WEAVER/36_SPEAK_TYPE.md`  
**Status:** First playable spike (CLOUD ONLY) · **Branch:** `cursor/weaver-speak-type`  
**Product:** **The Weaver**  
**Job:** Let a human **type or speak** into a void scene and watch words become **Fragments / Threads / Laws** — diegetic matter, not a command console.  
**Code:** `game/weaver/scenes/void_speak.tscn` (+ `scripts/speak/*`)

**One-line brief:** _Your utterance is fiber. It settles in the fray as something you can see — never a slash-command HUD._

---

## 0. Why this spike

Players (and designers) need a fast “jump in and poke the fantasy” surface:

| Want | Spike answer |
|---|---|
| Type and see something happen | Glyphs chalk into the void; Enter seats matter |
| Speak and see something happen | Tab hold → stub voice→text → same seat pipeline |
| Feel Weaver nouns | Lexicon maps words → Fragment / Thread / Law |
| Avoid shed chrome | Pure void page + frayed gap — **no shed UI** |

This is **not** the Yard gather→combine→weave loop. That remains on `scenes/field.tscn`.

---

## 1. Fantasy lock

| Allowed | Banned |
|---|---|
| Typed / spoken words become material atoms in a physical void gap | Console / terminal / slash-commands |
| Chalk cursor in the gap; whisper caption | Inventory strip, combine panel, shed timber chrome |
| Stub voice that typewrites into the same buffer | Shipping cloud STT / always-on mic as a dependency |
| Warm bone page + torn fray (void art grammar) | Purple cosmos, neon console, circles-on-black |

Authority peers: [`25_VOID_ART_V2.md`](25_VOID_ART_V2.md) · [`MASTER_GDD.md`](MASTER_GDD.md) · [`1000X/12_UI.md`](1000X/12_UI.md) (diegetic type discipline).

---

## 2. Playable surface

### Run

```bash
godot --path game/weaver                  # boots void_speak (spike main)
godot --path game/weaver -- --void-speak-selftest
python3 game/weaver/tests/test_speak_type.py
```

Title (`scenes/main.tscn`) still offers **Speak the void** (primary) and **Yard loop** (secondary).

### Controls

| Input | Effect |
|---|---|
| **Type** | Chalk glyphs appear in the void center |
| **Enter** | Utterance classifies → Fragment / Thread / Law spawns |
| **Backspace** | Dissolve last chalk |
| **Hold Tab** | Voice stub listen → release → canned phrase typewrites → seats |
| **Esc** | Clear buffer; empty buffer returns to title |

### Classification (lexicon)

Data: `game/weaver/content/speak_lexicon.json`

1. **Law** tokens (`hold`, `seat`, `law`, …) → stamped LAW plate  
2. **Thread** tokens (`brace`, `feed`, `echo`, …) → filament; links toward nearest Fragment  
3. **Fragment** tokens (`anchor`, `span`, …) → material atom  
4. Unknown speech → Fragment labeled with the uttered word  

Voice stub phrases cycle the same lexicon — **one pipeline** for type and speak.

---

## 3. Non-goals (this PR)

- Real speech-to-text (OS / Whisper / cloud) — stub only  
- Wiring spoken matter into the Yard Loom inventory / recipes  
- Shed-yard visual lock reuse  
- Echo Lattice menu / chamber integration  

---

## 4. Next elevations (not this spike)

- Promote winners into Lattice host under `scenes/weaver/`  
- Optional mic permission + offline STT plug-in behind the same `VoiceStub` API  
- Multi-word grammar (“brace span to anchor”) as Thread chemistry  
- Persist uttered Laws as walkable field edits  

---

**v0.1** — First diegetic speak/type void spike. Words become matter.
