# Godot 4 + AI + Steam Desktop Pipeline

**Repo:** [cmp07/Game-](https://github.com/cmp07/Game-)  
**Research window:** 2025–2026 (compiled Aug 2026)  
**Audience:** Solo / small team shipping a **real Windows `.exe` Steam game** (not browser / HTML5)  
**Companion docs:** [`docs/GAME_PLAN.md`](../GAME_PLAN.md) · [`docs/research/CATEGORY_RANKING.md`](CATEGORY_RANKING.md)

---

## 1. Executive verdict

Ship fastest by treating **AI as a production accelerator** (editor-time textures, scaffolding, QA help) while keeping the **player runtime offline-first**. Use **Godot 4 desktop export + GodotSteam GDExtension + SteamPipe**, not Web export. Lock **one pure category** before Week 1 production (see product decision gate below). Target a **playable Windows vertical slice by end of Week 2**, a **Steam Coming Soon + demo path by Weeks 4–6**, and a **review-ready build by Week 8** — accepting that Steam’s first-title waiting periods may push *public* release past the eight-week coding window.

| Principle | Choice |
|---|---|
| Product shape | One pure category per Steam app (no mashups) |
| Engine | Godot 4.x (match editor ↔ export templates patch) |
| Primary SKU | Windows x86_64 desktop `.exe` (+ optional external `.pck`) |
| Steam API | GodotSteam **GDExtension** + stock Godot export templates |
| AI (dev-time) | Cloud OK for art/code; keys never in repo |
| AI (player runtime) | Offline / deterministic default; online optional later |
| Not v1 | HTML5 primary product, multiplayer, live-service economy |

---

## 2. Product decision gate (before the clock starts)

From existing ranking research, confirm **exactly one** Game-1 lane:

| Option | Category | Why it fits this pipeline |
|---|---|---|
| **A (recommended)** | Tension / horror vignette | Smallest content mountain; AI helps props/UI/SFX; physics/particle load stays light |
| **B** | Coin-machine | Physics-heavy; AI helps art/SFX; need early RigidBody budget tests |
| **C** | Idle / particle tycoon | Fastest code path; GPUParticles / MultiMesh are core; AI helps FX + UI polish |

Until A/B/C is locked, do **not** scaffold conflicting GDDs. Shared stack (Godot, Steam, AI tooling) is fine; shared mechanics on one store page is not.

---

## 3. Architecture: three AI layers

Separate **where** AI runs so Steam builds stay reliable and offline-capable.

```text
┌─────────────────────────────────────────────────────────────┐
│  LAYER A — Dev / editor AI (you + Cursor / editor plugins) │
│  Textures, sprites, GDScript help, scene scaffolding         │
│  Online APIs OK · never ship API keys · human review always │
└────────────────────────────┬────────────────────────────────┘
                             │ bake assets into res://
┌────────────────────────────▼────────────────────────────────┐
│  LAYER B — Authored game systems (shipped binary)           │
│  Deterministic rules, FSM, dialogue trees, particle recipes │
│  Offline-first · no network required for core loop          │
└────────────────────────────┬────────────────────────────────┘
                             │ optional later
┌────────────────────────────▼────────────────────────────────┐
│  LAYER C — Runtime generative AI (player machine / cloud)   │
│  Local GGUF / ONNX OR opt-in cloud                          │
│  Feature-flagged · graceful fallback · never gate core play │
└─────────────────────────────────────────────────────────────┘
```

### 3.1 Layer A — Inventive production (recommended Week 1+)

| Job | Practical tools (2025–2026) | Notes |
|---|---|---|
| Pixel / 2D sprites & backgrounds | [PixelMaker](https://github.com/kbraiden/pixelmaker-godot-plugin), [godot-ai-image-generator](https://github.com/SynidSweet/godot-ai-image-generator) (Gemini), external Midjourney/Flux then import | Prefer a **locked palette + template prompts**; regenerate until style is consistent |
| PBR maps from albedo | [Photonic Ring](https://github.com/duyphan0503/photonic-ring) (offline CV / Rust GDExtension) | Good for 3D props/floors if Game B/C goes 3D |
| Scene / script scaffolding | Cursor / Claude / ChatGPT + Godot; experimental docks like [Genesis Engine](https://github.com/pranjal-jain-coder/GenesisEngine), [Blured](https://github.com/bluredengine/blured) | Treat output as **draft**; you own merge + playtest |
| Animation assist | PixelMaker Animate (local) | Walk/idle sheets without cloud |

**Hard rules for Layer A**

1. API keys live in editor settings / env vars — **never** `res://` or git.
2. Every generated texture gets a human pass for silhouette, palette, and readability at target resolution.
3. Keep a `docs/art/PROMPT_KIT.md` (style bible + negative prompts + resolution table) so batches stay coherent.
4. Prefer **atlas + few materials** over many unique textures (draw-call hygiene).

### 3.2 Layer B — Runtime systems that feel “AI-ish” without LLMs

For a fast Steam ship, inventiveness should come from **authored systems**, not cloud inference:

- Tension vignette: pressure meters, timed choices, seeded modifiers, replay challenges.
- Coin-machine: physics + payout tables + upgrade trees.
- Particle tycoon: recipes, automation graphs, prestige curves.

These read as clever / systemic on the store page and work **fully offline**.

### 3.3 Layer C — Optional runtime AI (post-MVP or gated)

| Approach | Stack examples | When to use |
|---|---|---|
| **Offline local LLM** | [GDLlama](https://github.com/xarillian/GDLlama), [OhMyDialogSystem](https://github.com/lobinuxsoft/OhMyDialogSystem), [GladeCore](https://github.com/Glade-tool/gladecore_godot) | Flavor dialogue, rumors — **not** win/lose logic |
| **Offline small models** | [godot_onnx_extension](https://github.com/joemarshall/godot_onnx_extension), [AI4U](https://github.com/gilzamir18/AI4U) | Tiny classifiers / RL toys |
| **Online APIs** | OpenAI / Gemini / Replicate | Only as **opt-in**; cache; timeout; degrade to Layer B |

**Steam / design constraints for Layer C**

- Core loop must work with airplane mode on.
- Store page must not claim AI features that are incomplete (Valve checks listed features).
- Model downloads: prefer first-run optional pack or Steam depot DLC — do not inflate the base depot with multi‑GB GGUF unless the fantasy requires it.
- For Game 1 (vignette), **skip Layer C in the 8-week plan** unless dialogue is the product.

---

## 4. Desktop Windows `.exe` pipeline (no browser)

### 4.1 Project bootstrap

```text
game/                     # Godot 4 project root
  project.godot
  export_presets.cfg      # Windows Desktop Release (committed)
  addons/godotsteam/      # GDExtension (or documented install script)
  assets/                 # AI + hand art (atlases)
  src/                    # GDScript (autoload + systems)
build/windows/            # local export output (gitignored)
steam/                    # VDF scripts, depot layout notes
```

Pin a **specific Godot patch** (e.g. 4.4.x / 4.5.x) and download matching **export templates**. Mismatched templates are a common silent ship-killer.

### 4.2 Export preset (Windows-first)

| Setting | Recommendation |
|---|---|
| Platform | Windows Desktop, **x86_64** |
| Template | Release (not debug) for Steam candidates |
| Embed PCK | **On** for early testers / simple Steam depot; off if you want shared `.pck` across platforms later |
| Runnable | One clear `Windows Release` preset |
| Codesign | Optional early; plan before public launch if SmartScreen friction appears |
| Architecture | Skip x86_32 unless you have a hard reason |

Official embed limit: executable + PCK roughly **≤ ~3.89 GB** total — irrelevant for small $0.99–$10 games, but do not ship multi‑GB AI weights inside the main `.exe`.

### 4.3 Weekly “playable program” ritual

Every Friday (or sooner):

1. `Project → Export` → `build/windows/GameName.exe`
2. Copy to a **clean folder / second user / VM** with no Godot install
3. Smoke: boot → one full loop → quit → relaunch → load (if saves exist)
4. Zip that exact folder as the weekly artifact

This is how you stay on a **desktop product**, not an editor-only prototype or HTML5 detour.

---

## 5. Steamworks integration

### 5.1 Partner setup (calendar reality)

| Gate | Typical duration | Implication for 8 weeks |
|---|---|---|
| Steam Direct fee + identity / tax | days | Start **Week 0 / Day 1** |
| First-title **30-day** wait after fee | 30 days | Coding can proceed; **public release** may land after Week 8 |
| Store page review | ~3–5 business days (budget **7**) | Submit Coming Soon materials by **Week 4–5** |
| Coming Soon minimum visibility | **14 days** | Page must go live by ~Week 6 for a Week-8+ launch |
| Build review | ~3–5 business days (budget **7**) | Submit review build by **Week 7** |

Sources: [Steam onboarding](https://partner.steamgames.com/doc/gettingstarted/onboarding), [review process](https://partner.steamgames.com/doc/store/review_process).

### 5.2 GodotSteam (GDExtension path)

Prefer **GDExtension** so you keep **stock Godot export templates**:

1. Install GodotSteam GDExtension (Asset Library / [GodotSteam docs](https://godotsteam.com/)).
2. Set App ID under **Project Settings → Steam → Initialization** (GodotSteam 4.14+).
3. Call `Steam.run_callbacks()` every frame (autoload `_process`).
4. Dev-only: `steam_appid.txt` next to the editor binary / exported exe when running **outside** Steam — **do not ship** that file in the Steam depot.
5. Ship `steam_api64.dll` (Windows 64-bit) beside the executable; include GodotSteam’s own `.dll` if the GDExtension export emits one.

**Do not** mix GDExtension GodotSteam with GodotSteam custom engine templates.

Minimum Steam feature set for MVP:

- Overlay works
- Achievements (3–8) wired to real events
- Cloud saves **optional** (local `user://` first is fine)
- Stats only if they support a real loop

### 5.3 Depot / SteamPipe layout (Windows-first)

Lean first-ship layout:

```text
depot_windows64/
  GameName.exe          # embed PCK OR exe + GameName.pck
  steam_api64.dll
  godotsteam*.dll       # if required by GDExtension export
```

Upload options:

1. **SteamCMD + VDF** (scriptable; best once repeating) — see [Valve uploading docs](https://partner.steamgames.com/doc/sdk/uploading) and [GodotSteam exporting/shipping](https://godotsteam.com/tutorials/exporting_shipping/) (updated Sep 2025).
2. **Website zip upload** per depot (fine for first title).
3. Set build live on a **password beta branch** before default.

Launch options in Steamworks: executable name + Windows OS flag.

### 5.4 Store page as a parallel deliverable

Treat capsules / trailer / first three screenshots as **production work**, not post-code chores:

- Readable title on capsule
- Screenshots = **gameplay only** (Valve rejects concept-art-heavy pages)
- Claim only features present in the review build
- Price in existing band ($0.99–$10; see category doc)
- Demo sub-app strongly recommended for discovery

---

## 6. Particle & physics performance budgets

Budgets differ by lane. Profile with **Debugger → Monitors** (`Physics 2D/3D` collision pairs, FPS, draw calls).

### 6.1 Visual particles (all lanes)

| Prefer | Avoid |
|---|---|
| `GPUParticles2D` / `GPUParticles3D` for FX | Spawning hundreds of `Sprite2D` nodes |
| Shared `ParticleProcessMaterial` variants | Unique material per emitter |
| Atlas textures | One PNG per particle type |
| Cap `amount`; use pooling for burst FX | Unbounded “emit forever” for gameplay-critical counts |

Godot docs recommend **GPUParticles\*** unless you have a concrete CPUParticles reason (low-end / GPU-bound edge cases).

### 6.2 Gameplay “particles” that must collide (idle tycoon / sandpile-likes)

Visual GPU particles **≠** simulated resources. For sellable / collidable grains:

| Scale | Approach |
|---|---|
| &lt; ~200 interacting bodies | Nodes (`RigidBody2D` / `AnimatableBody2D`) OK with sleep enabled |
| Hundreds–thousands | `MultiMeshInstance2D/3D` + `PhysicsServer2D/3D` (or custom sim) |
| Spectacle-only dust | GPUParticles only (no physics) |

May 2026 guidance: MultiMesh + shared collision shapes + RenderingServer/PhysicsServer paths scale far past SceneTree-per-instance designs ([Ezcha, “Rendering a Million Objects in Godot”](https://ezcha.net/news/5-16-26-rendering-a-million-objects-in-godot)).

### 6.3 Coin-machine / rigid stacks

| Rule | Why |
|---|---|
| Simple shapes (`Circle` / `Box` / `Cylinder`) | Convex meshes explode cost / tunneling |
| `can_sleep = true` on settled coins | Idle coins must stop simulating |
| Tight collision layers/masks | Collision **pairs** kill FPS before draw calls do |
| Move pusher via physics (`_integrate_forces`, joints, motors) | Animating `RigidBody` transforms causes tunneling |
| Cap live coins; cull / merge off-table | Soft body-count budget (prototype yours in Week 2) |
| Consider Jolt for 3D, but validate stack stability early | Community coin-pusher threads report precision issues when movers are animated incorrectly |

### 6.4 Tension vignette (lighter load)

Keep physics minimal: CharacterBody / Area triggers / a few props. Spend the frame budget on **feel** (juice, audio, camera), not body count. GPUParticles for atmosphere are cheap if atlas-shared.

### 6.5 Performance acceptance gates (put in CI-of-the-mind)

| Gate | Target (mid-range Win10/11 laptop) |
|---|---|
| Vertical slice | ≥ 60 FPS in main loop |
| Stress room | ≥ 30 FPS at intentional max entities |
| Collision pairs | Investigate if sustained ≫ ~5k (context-dependent) |
| Export parity | Editor FPS ≈ exported release FPS within ~15% |

---

## 7. Inventive design without scope explosion

“Inventive” for a $0.99–$10 Steam title means **one sharp systemic hook**, not a platform of AI features.

| Lane | Inventive MVP hook (examples) | Explicit non-goals for 8 weeks |
|---|---|---|
| Tension vignette | Original ritual stakes + modifiers; clip-length rounds | Full narrative adventure, multiplayer guilt, shotgun clone |
| Coin-machine | One signature table rule / risk event + demoable physics | Full casino metaverse, online trading |
| Particle tycoon | One transformation recipe chain + prestige | MMO market, UGC cloud AI |

AI accelerates **skinning and iteration** of that hook; it does not replace the hook.

---

## 8. Recommended toolchain (concrete)

### 8.1 Must-have

- Godot 4.x stable + matching export templates  
- Git + `.gitignore` for `.godot/`, `build/`, secrets  
- GodotSteam GDExtension  
- Steamworks partner account + SDK (ContentBuilder)  
- Cursor / LLM for GDScript + refactor help  
- Aseprite / Photoshop / Krita **or** AI image tool + palette lock  
- Windows test machine or clean VM for export smoke tests  

### 8.2 Nice-to-have

- PixelMaker or Gemini image plugin for in-editor 2D  
- Photonic Ring if shipping 3D PBR  
- RenderDoc / Godot profiler habit  
- itch.io parallel upload for friends builds (optional; Steam remains primary)  
- Codesign cert before wide Windows distribution  

### 8.3 Avoid for first ship

- Primary **Web/HTML5** target  
- Custom Godot engine forks unless a plugin forces it  
- Shipping cloud AI as a **hard dependency**  
- Genre mashups on one AppID  
- Building Mac/Linux depots before Windows loop is fun  

---

## 9. Eight-week milestone schedule

Assumes: category locked (A/B/C), Steam Direct fee paid **by Week 1**, solo or 2-person team, ~25–40 focused hours/week.  
**Coding complete ≠ Steam store live** if the 30-day / 14-day clocks started late — start partner paperwork immediately.

### Week 0 — Decision & paper (days −3 to 0)

| Deliverable | Done when |
|---|---|
| Category lock A/B/C | Written in `docs/GDD_GAME1.md` (1–2 pages) |
| Hook sentence | Fits on capsule without genre mash |
| Session length target | e.g. 3–12 min (vignette) / endless (idle/coin) |
| Art direction | Palette, resolution, 3 reference images |
| Steamworks | Org created, $100 fee paid / processing |

### Week 1 — Vertical slice skeleton (desktop only)

| Track | Tasks |
|---|---|
| Engine | Create `game/` Godot project; input map; main scene; autoload `Game` + `SteamMgr` stubs |
| Loop | **One** complete play loop with programmer art |
| Export | Windows Release preset; first clean-folder `.exe` smoke |
| AI (Layer A) | Prompt kit; generate 10–20 draft sprites; import atlas |
| Steam | AppID created; store placeholder title; depot stub |

**Exit criteria:** Zip of `.exe` that a friend can run without Godot.

### Week 2 — Feel + performance spike

| Lane focus | Spike |
|---|---|
| A vignette | Tension curve, fail/win states, juice |
| B coin | RigidBody stack + pusher driven correctly; body budget |
| C particles | GPUParticles FX + gameplay grain strategy (nodes vs MultiMesh) |

Also: local save/load; options (volume, fullscreen); crash-free 15‑minute soak.

**Exit criteria:** Fun in the first 60 seconds; FPS gate met on stress scene.

### Week 3 — Content depth (still one loop)

- Expand **only** the core loop: 1 enemy/ritual variant set **or** 1 table upgrade set **or** 1 tech tier
- Audio pass (SFX first; music loop second)
- UI: title → play → result/upgrade → retry
- Wire 3 Steam achievements in sandbox AppID
- AI: replace programmer art for hero props; reject inconsistent gens

**Exit criteria:** “Would wishlist” playtest with 3 outsiders.

### Week 4 — Steam presence + GodotSteam hardening

- Capsule drafts (AI OK, human composite final)
- 5 gameplay screenshots from **exported** build
- Short description + tags
- Submit store page for review when checklist is green
- GodotSteam: overlay + achievements verified via Steam client / test account
- Beta branch build uploaded

**Exit criteria:** Store page in Valve review **or** ready to mark for review.

### Week 5 — Demo cut + Coming Soon

- Demo build = best 5–10 minutes / first prestige / first table — **no** broken promises
- Demo depot + checklist
- Bug bash from Week 3–4 feedback
- Trailer: 30–60s capture from desktop build (not editor)
- When store approved: **Post Coming Soon** (start 14‑day clock)

**Exit criteria:** Wishlistable Coming Soon page live (or waiting only on Valve).

### Week 6 — Systems freeze → polish

- **Feature freeze** for anything not needed for review claims
- Juice, readability, tutorial tooltips (minimal)
- Balance pass; accessibility: remappable keys if feasible, subtitle critical text
- Performance: atlas consolidation; particle caps; physics sleep audit
- Optional Layer C prototype **behind flag** only if schedule is green (else cut)

**Exit criteria:** “Review build” candidate identified.

### Week 7 — Review build & certification

- Final Windows export; version stamp in UI
- SteamPipe upload → default or release candidate branch
- Mark **build** ready for review (budget 7 business days)
- QA script: fresh install → overlay → achievement → full loop → uninstall
- Price proposal; build Steam Deck report if time (nice-to-have, not blocker)

**Exit criteria:** Build with Valve / in review queue.

### Week 8 — Launch prep (or launch if clocks allow)

| If clocks allow | If clocks don’t |
|---|---|
| Day-1 patch branch ready | Keep polishing on beta branch |
| Launch checklist rehearsal | Schedule release day after Coming Soon + reviews clear |
| Press kit folder | Continue wishlist pushes |
| Post-mortem notes for Game 2 | Do not start Game 2 production |

**Exit criteria:** Either **Released**, or **Release-ready** with a dated public launch once Steam gates clear.

---

## 10. Week-by-week RACI (solo-friendly)

| Workstream | W1 | W2 | W3 | W4 | W5 | W6 | W7 | W8 |
|---|---|---|---|---|---|---|---|---|
| Core gameplay | ■■ | ■■ | ■■ | ■ | ■ | □ | □ | □ |
| Art / AI assets | ■ | ■ | ■■ | ■ | ■ | ■ | □ | □ |
| Audio | □ | ■ | ■■ | ■ | □ | ■ | □ | □ |
| Export / SteamPipe | ■ | ■ | □ | ■■ | ■■ | ■ | ■■ | ■ |
| Store / trailer | □ | □ | ■ | ■■ | ■■ | ■ | ■ | ■ |
| Perf / bugfix | □ | ■■ | ■ | ■ | ■■ | ■■ | ■■ | ■ |

■ = primary focus · □ = light / maintenance

---

## 11. Risk register

| Risk | Mitigation |
|---|---|
| Steam 30-day / 14-day clocks blow past Week 8 | Pay fee + draft store page in Week 1; code continues in parallel |
| AI art inconsistency | Prompt kit + palette lock + human gate; regenerate, don’t “fix in Photoshop forever” |
| Physics never feels fair (coin) | Week 2 spike or pivot to vignette/idle |
| Particle tycoon tanks FPS | Split FX vs sim; MultiMesh/PhysicsServer early |
| GodotSteam template mixup | GDExtension + **stock** templates only |
| Scope creep (“just add deckbuilder”) | Pure-category rule; backlog → Game 2/3 |
| Online AI as dependency | Offline core; online opt-in only |
| Editor-only prototype | Friday `.exe` ritual |

---

## 12. Fast path checklist (print this)

- [ ] Category locked (A/B/C)  
- [ ] 1-page GDD  
- [ ] Godot 4 project in `game/`  
- [ ] Windows export preset + clean smoke test  
- [ ] GodotSteam init + callbacks + `steam_api64.dll`  
- [ ] Steamworks app + depots + beta package  
- [ ] Core loop fun at 60s  
- [ ] Perf gate on stress scene  
- [ ] Capsules + 5 gameplay screenshots  
- [ ] Coming Soon submitted / live  
- [ ] Demo cut  
- [ ] Review build submitted  
- [ ] No browser primary target  

---

## 13. Sources (2025–2026 emphasis)

### Godot export & engine

- Godot docs — [Exporting for Windows](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html) (PCK embed ~3.89 GB, codesign, architectures)  
- Godot docs — [Particle systems (2D)](https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html) (GPUParticles vs CPUParticles)  
- Godot docs — [Physics introduction](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html) (RigidBody sleep, `_integrate_forces`)  
- Godot docs — [MultiMesh](https://docs.godotengine.org/en/stable/classes/class_multimesh.html)  
- Ezcha (May 16, 2026) — [Rendering a Million Objects in Godot](https://ezcha.net/news/5-16-26-rendering-a-million-objects-in-godot)  
- I Love Sprites — [Working With Sprites in Godot 4](https://ilovesprites.com/blog/godot-sprite-nuances-best-practices) (MultiMeshInstance2D guidance)

### Steam + GodotSteam

- GodotSteam — [Initializing Steam](https://godotsteam.com/tutorials/initializing/)  
- GodotSteam — [Exporting and Shipping](https://godotsteam.com/tutorials/exporting_shipping/) (updated Sep 22, 2025)  
- Godot Asset Library — [GodotSteam GDExtension](https://store.godotengine.org/asset/godotsteam/godotsteam-gdextension/)  
- Valve — [Uploading to Steam](https://partner.steamgames.com/doc/sdk/uploading)  
- Valve — [Onboarding](https://partner.steamgames.com/doc/gettingstarted/onboarding) (30-day wait, 14-day Coming Soon)  
- Valve — [Review Process](https://partner.steamgames.com/doc/store/review_process) (3–5 business days; budget 7)  
- Valve — [Demos](https://partner.steamgames.com/doc/store/application/demos)  
- GamineAI — [I Shipped a Godot Game to Steam — Postmortem](https://gamineai.com/blog/i-shipped-a-godot-game-to-steam-full-postmortem)  
- Immutable Guides (2026) — [How to Publish a Game on Steam](https://www.immutable.com/guides/how-to-publish-a-game-on-steam)

### AI-assisted creation & runtime

- PixelMaker — [kbraiden/pixelmaker-godot-plugin](https://github.com/kbraiden/pixelmaker-godot-plugin) (cloud gen + local animate)  
- SynidSweet — [godot-ai-image-generator](https://github.com/SynidSweet/godot-ai-image-generator) (Gemini image pipeline)  
- Photonic Ring — [duyphan0503/photonic-ring](https://github.com/duyphan0503/photonic-ring) (offline PBR map gen)  
- Genesis Engine — [pranjal-jain-coder/GenesisEngine](https://github.com/pranjal-jain-coder/GenesisEngine) (editor agent; cloud + optional local SD)  
- Blured — [bluredengine/blured](https://github.com/bluredengine/blured) (Godot + agentic tooling)  
- GDLlama — [xarillian/GDLlama](https://github.com/xarillian/GDLlama) (local GGUF via llama.cpp)  
- OhMyDialogSystem — [lobinuxsoft/OhMyDialogSystem](https://github.com/lobinuxsoft/OhMyDialogSystem) (offline dialogue)  
- GladeCore — [Glade-tool/gladecore_godot](https://github.com/Glade-tool/gladecore_godot) (on-device NPC AI)  
- ONNX — [joemarshall/godot_onnx_extension](https://github.com/joemarshall/godot_onnx_extension)  
- AI4U — [gilzamir18/AI4U](https://github.com/gilzamir18/AI4U)

### Physics / performance community signal

- Godot Forum — [Collision pairs optimization](https://forum.godotengine.org/t/collision-pairs-optimizing-performance-of-bullet-hell-enemy-hell-games/35027)  
- Godot Forum — [Coin pusher collision precision (Jolt)](https://forum.godotengine.org/t/how-do-i-make-the-collision-detection-more-precise-jolt-physics-coin-pusher-game/38671)  
- UhiyamaLab — [CharacterBody2D vs RigidBody2D vs StaticBody2D](https://uhiyama-lab.com/en/notes/godot/physics-body-comparison/)

### Internal product research

- [`docs/GAME_PLAN.md`](../GAME_PLAN.md)  
- [`docs/research/CATEGORY_RANKING.md`](CATEGORY_RANKING.md)

---

## 14. Next action

1. **Confirm Game 1 lane (A/B/C).**  
2. Copy Week 0 template into `docs/GDD_GAME1.md`.  
3. Scaffold `game/` Godot 4 project and run the first clean Windows `.exe` smoke test.  
4. Keep this pipeline doc updated when GodotSteam / Steam policy versions bump.
