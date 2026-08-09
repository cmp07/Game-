# The Weaver — Tech

**Doc:** `docs/WEAVER/14_TECH.md`  
**Status:** Honest MVP cut — Godot desktop, offline loom  
**Peers:** [`01_CONCEPT.md`](01_CONCEPT.md) · [`PIVOT.md`](PIVOT.md) · [`12_MULTIPLAYER.md`](12_MULTIPLAYER.md) · [`../GAME_PLAN.md`](../GAME_PLAN.md)

---

## 0. Verdict (read this first)

| Lock | Meaning |
|---|---|
| **Engine** | **Godot 4** (track with studio skill; 4.3+ LTS-minded) |
| **Ship shape** | Windows-first Steam `.exe` + `.pck`; Mac/Linux optional later |
| **Runtime network** | **None required** for Campaign / Daily / Endless |
| **Code home** | Prefer future `game/weaver/` — **do not overwrite** `game/echo_lattice/` ([`PIVOT.md`](PIVOT.md)) |
| **Backend** | No Weaver game server for MVP |

**One line:** A deterministic offline toy in Godot — Steam is a storefront, not a dependency.

---

## 1. Stack (MVP)

| Layer | Choice | Cut / defer |
|---|---|---|
| Engine | Godot 4 (GDScript first; C# only if a hire already lives there) | Unity/Unreal rewrite — no |
| Rendering | 2D (Field Ledger / textile page) | 3D world, Nanite envy, RT — no |
| Physics | Only if design docs demand thread/verlet; else grid + transforms | Full soft-body / 3D cloth sim — no for MVP |
| Audio | Godot buses + authored stems; silence as tool | Middleware sprawl, adaptive middleware suites — defer |
| Input | KBM + gamepad; Steam Deck as stretch | Touch-first mobile port — out of band |
| Save | Local user:// JSON or Godot Resource; atomic write | Cloud save — optional post-1.0 |
| Platform | Steamworks via GodotSteam **fail-closed** (optional achievements) | Epic/console first — no |
| CI | Export Windows in CI when runners allow; Python contracts without editor | Full Deck farm in cloud — never claim |

---

## 2. Architecture principles

1. **Determinism** — same seed + same inputs → same weave. Required for dailies, ghosts, and “same loom, different hands.”  
2. **Offline first** — every core loop callable with Steam disabled / AppID placeholder.  
3. **Content as data** — chambers / fragments / threads authored as JSON (or Godot resources), validated by Python tests (Echo Lattice pattern worth stealing).  
4. **Fail-closed platform** — missing Steam DLL never bricks boot.  
5. **One product tree** — Weaver code does not silently mutate Echo Lattice shipping scripts.

### Suggested module map (greenfield)

```
game/weaver/
  project.godot
  content/          # chambers, seeds, copy
  scripts/
    loom/           # buffer → transform → commit
    modes/          # campaign, daily, endless
    meta/           # museum / stars / unlocks
    platform/       # steam stub + fail-closed
  tests/            # python contracts + gdscript where needed
```

Exact folder names may shift; the **separation from** `game/echo_lattice/` does not.

---

## 3. Honest MVP tech cuts

| Temptation | Cut for MVP | Revisit when… |
|---|---|---|
| Dedicated / relay servers | **Cut** | Never, unless MP product reboot ([`12_MULTIPLAYER.md`](12_MULTIPLAYER.md)) |
| LLM / online generative dungeon | **Cut** | Fantasy forbids AI-dungeon store lead |
| Steam Cloud | **Cut** | After local save is boring-reliable |
| Workshop UGC pipeline | **Cut** | Post-1.0 + moderation plan |
| Cross-play consoles | **Cut** | After Steam PC is real |
| Custom engine / Rust rewrite | **Cut** | Not this studio phase |
| Heavy compute PCG at runtime | Cap | Prefer authored grammars + deterministic transforms; profile before “more noise” |
| Shared library extraction from EL day one | Soft cut | Copy patterns, don’t block Weaver on a perfect monorepo framework |

---

## 4. Reuse from Echo Lattice (optional, careful)

| Steal | Do not steal |
|---|---|
| Offline mode shape (Campaign / Daily / Endless) | Store copy, capsules, AppID placeholders as if they were Weaver |
| Fail-closed Steam stub pattern | Assuming wishlist / achievement IDs transfer |
| Python content validators | Blind-copying habit ops that fight Weaver’s verb grammar |
| CI / SteamPipe *process* lessons | Overwriting `game/echo_lattice/` in place |

Pivot lock: Echo Lattice tree stays as archaeology + craft reference ([`PIVOT.md`](PIVOT.md)).

---

## 5. Platform & compliance (MVP minimum)

| Item | MVP bar |
|---|---|
| Steam AppID | Human-created when store work starts — agents **never invent** IDs |
| Achievements | Optional thin set; offline stub unlocks in dev |
| Cloud / networking survey | Declare **no online features** for v1 (match EL honesty) |
| AI disclosure | If any gen-AI used in production assets — disclose; runtime LLM still cut |
| Privacy | No account system → short privacy story; HTTPS policy when store needs it |
| Deck | Stretch goal after Windows ship path exists — do not block 1.0 |

---

## 6. Performance & content budgets (planning, not dogma)

| Budget | MVP guidance |
|---|---|
| Resolution | 1080p target; UI scale; 60 FPS comfort on mid-tier Windows |
| Frame spikes | Rewrite slam / commit is the juiciest frame — budget hitstop, not a hitch |
| Content volume | Prefer fewer **legible** chambers over infinite PCG sludge |
| Save size | Tiny; Museum ghosts capped |
| Install size | Keep lean — textile/paper art, not 4K video walls |

Exact numeric gates belong in later perf docs; this table exists to stop gold-plating.

---

## 7. Build / ship path (lean)

1. Vertical slice `.exe` (Windows) with one complete weave ceremony.  
2. Content pipeline + validators green in CI.  
3. Demo export skinned from slice (no second codebase).  
4. Steamworks wiring fail-closed; Partner upload is human.  
5. Mac/Linux after Windows reviews are not on fire.

---

## 8. Lock line

**MVP tech = Godot 4, local saves, deterministic loom, optional Steam.** Anything that needs a server, an LLM bill, or a second engine is not Weaver 1.0.
