# Creator Project Audit — cmp07 / Pr3is

**Audit date:** 2026-08-08 (UTC)  
**Auditor:** Cursor Cloud Agent (`gh` + git + GraphQL + public profile APIs)  
**Canonical public account:** [cmp07](https://github.com/cmp07) (display name **Pr3is**)  
**Canonical game workspace:** [cmp07/Game-](https://github.com/cmp07/Game-)  
**Method limits (read this first):** This audit reflects **public GitHub surface** visible to the authenticated `gh` integration, plus the local clone of `Game-` and open PR branches. Private repos, local-only Construct/Godot/Unity projects, Discord/Steam, and off-GitHub “22 months in stealth” work are **not inspectable here**. Absence of public code is not proof of absence of private work — but it *is* proof that the public portfolio cannot yet demonstrate shipped game craft.

---

## 0. Executive verdict

| Question | Honest answer |
|---|---|
| How deep is the public portfolio? | **Shallow.** One public repo, created the same day as this audit. |
| Is `sandpile-tycoon` a real GitHub repo? | **No.** Name appears as README/working title inside `Game-`; `gh api repos/cmp07/sandpile-tycoon` → 404. |
| Are there public Godot / Unity / Construct / Cortex projects? | **No.** Zero language bytes on `main`; empty `game/` placeholder; no other matching repos. |
| What has actually been built in-repo? | **Planning docs** (strong), plus an **unmerged browser Snake** scaffold on a PR branch (agent-authored demo). |
| Creator strengths (inferred) | Taste for **idle/particle systems**, **arcade physics toys**, **stakes/tension**, and **AI-assisted generative tooling** — currently evidenced as *taste + research velocity*, not as shipped engine mastery. |
| Best **next** inventive game (not a mashup) | **Pure idle/incremental whose core verb is sandpile criticality / avalanche economy** — the original DNA of this workspace, sharpened into one inventable loop, not Particul+coin+horror. |

**Bottom line:** Treat cmp07 today as a **high-intent Steam planning studio with almost no public executable game history**. The inventive path with the best fit is to *finish the thing the repo was born as*: a sandpile-native idle — not a genre mashup, not a Buckshot clone, not friendslop.

---

## 1. Account census (`gh repo list cmp07`)

### 1.1 Commands run

```bash
gh repo list cmp07 --limit 50
gh repo list cmp07 --limit 100 --json name,description,isPrivate,isFork,visibility
gh api users/cmp07
gh api users/cmp07/repos?per_page=100&type=all
gh search repos --owner=cmp07 --limit 50
gh api graphql  # user.repositories + repositoriesContributedTo
```

Pagination was unnecessary: the list returns a single repository and `public_repos: 1`.

### 1.2 Profile snapshot

| Field | Value |
|---|---|
| Login | `cmp07` |
| Name | Pr3is |
| Profile URL | https://github.com/cmp07 |
| Account created | 2025-01-07 |
| Profile updated | 2026-07-24 |
| Public repos | **1** |
| Public gists | 0 (gists list API returned 403 to this integration) |
| Followers / following | 0 / 1 (`nicholasklogan` — unrelated Python tooling history; not a game co-dev signal) |
| Orgs | none public |
| Starred repos | empty (no public stars to reverse-engineer taste from) |
| Public contributions to other repos | **0** (GraphQL `repositoriesContributedTo`) |

### 1.3 Bio (self-positioning)

> I build things that build themselves.  
> 22 months in stealth. Almost ready to show the world.  
> Follow along if you're tired of renting AI.  
> #AI #Creator …

**Interpretation (honest):** The public brand is **AI/creator autonomy**, not “veteran Godot indie with a catalog.” The “stealth” claim implies off-GitHub work; this audit **cannot verify** that claim. Do not invent a Unity/Construct résumé from a bio.

### 1.4 Full public repo list

| Repo | Visibility | Created | Languages | Stars | Fork? | Topics | Description |
|---|---|---|---|---|---|---|---|
| [cmp07/Game-](https://github.com/cmp07/Game-) | public | 2026-08-08 | *(none on default branch)* | 0 | no | (none) | (empty) |

That is the entire public catalog.

### 1.5 Related name collisions (not owned portfolio)

| Handle | Public repos | Relevance |
|---|---|---|
| [Pr3ist](https://github.com/Pr3ist) | 0 | Name-adjacent; empty; created 2022 |
| [Pr3isl3r](https://github.com/Pr3isl3r) | 0 | Name-adjacent; empty; created 2024 |
| `cmp07/sandpile-tycoon` | **does not exist** | Referenced in older `docs/GAME_PLAN.md` header as if it were the repo URL |

No additional cmp07 game/Cortex/Construct/Godot/Unity repositories appeared in owner search, keyword search (`sandpile`, `tycoon`, `cortex`, `construct`, `godot`, `unity`, `idle`, `particle`), or GraphQL.

---

## 2. Deep dive: `cmp07/Game-`

### 2.1 Repo facts

| Fact | Value |
|---|---|
| URL | https://github.com/cmp07/Game- |
| Default branch | `main` @ `a8d6b83` |
| Created / first push window | 2026-08-08 (~same calendar day as this audit) |
| GitHub “language” field | null (no detectable source language on `main`) |
| Disk size (API) | ~0 KB class / empty language map |
| Releases | 0 |
| Open draft PRs | 2 |
| Remote branches (audit time) | `main`, `cursor/setup-game-dev-environment-5252`, `cursor/market-deep-dive-game-plan-4f9e` (+ this audit branch) |

### 2.2 What `main` actually contains

| Path | Scope honesty |
|---|---|
| `README.md` | Planning README titled **sandpile-tycoon**; describes multi-game Steam strategy; **no runnable game**. |
| `.gitignore` | Godot 4 / desktop export oriented (`.godot/`, `*.exe`, `*.pck`, Mono stubs). Signal: **intent = Godot desktop**, not web primary. |
| `docs/GAME_PLAN.md` | Substantial Steam product plan (pure categories, price bands, decision gate). |
| `docs/research/CATEGORY_RANKING.md` | Condensed competitive ranking with Steam comps. |
| `docs/.gitkeep`, `game/.gitkeep`, `research/.gitkeep` | Placeholders. **`game/` has zero Godot project files** (`project.godot` absent). |

**Scope score for `main`:** Documentation + repo scaffolding. **Not** a playable prototype. **Not** a shipped Steam build. **Not** an engine sample.

### 2.3 Commit chronology (truthful authorship)

| SHA | When (approx) | Message | What it really is |
|---|---|---|---|
| `d36e59e` | 2026-08-08 15:31 −0400 | *Initial commit: Steam idle particle tycoon project scaffold* | Birth of workspace as **Sandpile Tycoon** idle/particle Steam intent (Godot folders + short README). Co-authored with Cursor. |
| `276f448` | 2026-08-08 15:41 −0400 | *Add Steam multi-game plan: pure categories, no mashups.* | Expands into ranked sequence: tension vignette → coin → idle. Adds `GAME_PLAN.md` + `CATEGORY_RANKING.md`. |
| `e1b38b4` | 2026-08-08 15:44 −0400 | *Initial commit* | Parallel empty `# Game-` README tip (agent/cloud collision lineage). |
| `a8d6b83` | 2026-08-08 15:50 −0400 | Merge of the two tips | Resolves README conflict; lands planning docs on `main`. |
| `eab176e` *(branch only)* | 2026-08-08 19:47 UTC | *Scaffold Snake game…* | Vite + TS HTML5 Snake + Cloud Agent env. **Not on `main`.** |
| `2fa8da4` / `efbc8bc` *(PR branch)* | later same day | Market deep dive + revise Game 1 to idle | Docs-only revision of strategy. **Not on `main` at audit time.** |

**Authorship pattern:** Nearly all meaningful commits are **Cursor Agent co-authored**. Human direction is visible in taste constraints (“no mashups,” Particul/RACCOIN/Buckshot references, sandpile naming). Human-authored *engine systems* are not yet visible in git history.

### 2.4 Original product DNA (do not lose this)

From the first commit README (`d36e59e`):

> Steam idle particle/resource tycoon — a desktop Godot game.  
> Inspired by Particool-like particle idle games, with original IP, systems, and presentation.  
> Players **grow, shape, and automate particle sandpiles** into a resource empire.

This is the strongest native signal in the entire account: the workspace was not born as “horror vignette studio” or “Snake tutorial.” It was born as **sandpile idle**. Later docs *reordered* market priorities; they did not erase this origin.

### 2.5 Strategy docs on `main` (pre-revision)

`docs/GAME_PLAN.md` + `CATEGORY_RANKING.md` on `main` recommend:

1. Tension / horror vignette (Buckshot-*format*, original premise) — Game 1  
2. Coin-machine — Game 2  
3. Idle / particle tycoon (Particul-like) — Game 3  

Hard rule (valuable and should be kept): **one pure category per Steam product; no mashup first game.**

Name resolutions from play history (taste map, not shipped games):

| Fuzzy input | Resolved taste |
|---|---|
| Raccoin / rack a coin | RACCOIN coin-pusher roguelike |
| Winrose | Windrose *or* Wildfrost (scope/taste, not first ship) |
| Rollerhalla | Brawlhalla (platform fighter — correctly flagged as avoid-early) |
| Particool | Particul particle idle |

**Scope honesty:** These docs are **market/taste research**, not prototypes. They demonstrate research appetite and constraint discipline. They do **not** demonstrate physics implementation skill, art pipeline, or Steam launch ops.

### 2.6 Open PR #1 — Snake / Cloud Agent env  
Branch: `cursor/setup-game-dev-environment-5252` · https://github.com/cmp07/Game-/pull/1

| Aspect | Assessment |
|---|---|
| Stack | Vite 5 + TypeScript + HTML5 canvas |
| Content | Playable classic Snake (grid, score, best score, pause, walls/self collision) |
| LOC signal | ~230 lines `src/main.ts` + CSS/HTML; competent tutorial-grade demo |
| Relation to Steam plan | **Orthogonal.** Browser Snake contradicts the README’s “real Windows `.exe`, not browser” product goal. Useful as **agent/environment smoke test**, not as Game 1. |
| Creator craft signal | Weak as portfolio evidence — agent-scaffolded greenfield demo to make Cloud Agent runnable. |

**Scope score:** Small web toy. Complete for what it is. Not a direction.

### 2.7 Open PR #2 — Market deep dive + idle-first revision  
Branch: `cursor/market-deep-dive-game-plan-4f9e` · https://github.com/cmp07/Game-/pull/2

Adds/revises:

- `docs/research/MARKET_DEEP_DIVE.md` — 2025–2026 Steam lane analysis (friendslop, horror fatigue, idle “Little League,” TFWR automation, tidy sims, synergy toys, avoid list).
- Revises Game 1 → **idle / incremental**; Game 2 → **systems/automation**; Game 3 → synergy toy *or* coin-machine.
- Demotes Buckshot-format vignette from default Game 1 due to clone fatigue.

**Scope score:** Stronger market reasoning than the first plan; still **docs-only**. Importantly, it **re-converges** with the repo’s original sandpile/idle birth — market and origin finally agree that Game 1 should be idle, not horror.

### 2.8 Parallel Cloud Agent swarm (same-day context)

Accessible agents on this repo at audit time included concurrent research threads such as:

- Inventive physics game feasibility  
- Godot AI game pipeline  
- Generative reality / generative AI game research  
- Steam indie trend map / Chinese Steam success  
- Co-op viability / product philosophies / inventiveness principles  
- AI content guidelines / Steam AI policy  
- This creator project audit  

**Interpretation:** Extremely high **research bandwidth** via AI agents; zero evidence yet of a locked vertical slice. Risk mode = **analysis paralysis / parallel-doc sprawl**. Strength mode = can load the design space quickly if a single lane is enforced.

---

## 3. Notable repos that were requested — findings

### 3.1 `sandpile-tycoon`

| Check | Result |
|---|---|
| `gh api repos/cmp07/sandpile-tycoon` | **404 Not Found** |
| Global search `sandpile-tycoon` | No cmp07-owned hit |
| Local meaning | Working title / README H1 / initial product fantasy inside `Game-` |

**Honest scope:** Concept name + folder intent. Not a separate codebase. Not a Steam page. Not a Godot project.

### 3.2 Game / Cortex / Construct / Godot / Unity

| Engine / keyword | Public cmp07 evidence |
|---|---|
| Godot | **Intent only** — `.gitignore`, README stack line, empty `game/` |
| Unity | **None** |
| Construct | **None** |
| Cortex | **None** |
| Web game | Snake PR only (unmerged) |
| Native desktop `.exe` | **None** |

If Construct 2/3, Unity, or Cortex work exists, it lives **outside** this public GitHub account (or in private repos inaccessible to this token). This audit must not fabricate a Construct/Unity track record.

### 3.3 AI / “things that build themselves”

Public code evidence of AI systems: **none** (no models, agents, training code, or generative pipelines in `Game-`).  
Bio + agent swarm: strong **interest** in generative/AI-assisted creation.  
That is a *tooling preference*, not yet a *shipped game mechanic*.

---

## 4. Inferred creator strengths (with confidence)

Confidence legend: **High** = repeated in git/docs; **Medium** = clear taste but unproven skill; **Low** = bio/aspiration only.

### 4.1 What looks strong

| Strength | Confidence | Evidence |
|---|---|---|
| **Idle / incremental taste** | High | Birth README (sandpile tycoon), Particul comps, market PR promoting idle Game 1 |
| **Constraint discipline (“no mashups”)** | High | Explicit hard rule across GAME_PLAN / ranking / market dive |
| **Catalog thinking (many small Steam ships)** | High | Multi-game sequence, price bands $0.99–$10 / $2.99–$9.99 |
| **Arcade physics *taste* (coin machines)** | Medium | RACCOIN / Coin Game comps; ranked highly for taste; **no physics code** |
| **Stakes / tension *taste*** | Medium | Buckshot / CloverPit language; later demoted for market reasons |
| **AI-assisted production velocity** | High | Entire public history is agent-coauthored in one day; large parallel research fleet |
| **Systems / automation aspiration** | Medium | TFWR elevated to Game 2 in revised plan; fits “things that build themselves” bio |

### 4.2 What is *not* evidenced (do not claim)

| Claim to avoid | Why |
|---|---|
| “Experienced Godot developer” | No `project.godot`, no GDScript/C#, no scenes |
| “Physics programmer” | No RigidBody/soft-body/coin sim implementations |
| “Horror designer with shipped vignettes” | Taste references only |
| “Unity / Construct veteran” | Zero public repos |
| “AI researcher / ML engineer” | Bio tags only; no code |
| “Has a Steam catalog” | No apps, builds, or store links owned in-repo |

### 4.3 Strength profile in one sentence

**A taste-driven solo creator optimizing for small paid Steam games, currently strongest at directing AI research toward idle/particle and automation fantasies, and still unproven at engine implementation and launch craft.**

---

## 5. Mapping past work → best NEXT inventive direction

### 5.1 What “past work” actually maps

| Past signal | Maps to |
|---|---|
| Sandpile Tycoon birth README | Core IP metaphor: **piles, cascades, automation of criticality** |
| Particul screenshots / comps | Visual/loop adjacency: particle feedback, sell, automate — **not** the inventive differentiator |
| RACCOIN / coin taste | Later pure product (physics toy) — **not** Game 1 mash-in |
| Buckshot / CloverPit taste | Later pure tension product — **not** Game 1 default (clone fatigue) |
| TFWR / “build themselves” bio | Natural **Game 2** automation sequel after idle ships |
| Snake PR | Ignore for product direction; keep only as env smoke test if useful |
| Agent research swarm | Capability to refine a locked lane quickly — dangerous if lanes stay unlocked |

### 5.2 Rejected “next” ideas (and why)

| Tempting next | Reject |
|---|---|
| Mashup: sandpile + coin pusher + horror stakes | Violates the repo’s own best rule; muddies Steam page |
| Buckshot-format vignette as first ship | Market PR correctly demotes; fatigue; weaker fit to sandpile DNA |
| Friendslop co-op | Upside real; netcode is the product; no MP evidence |
| Generic Particul clone | Fits ship-speed but fails inventiveness; “thin idle” trap |
| Full TFWR/Python-farm clone as Game 1 | UX/DSL mountain before first Steam lesson |
| Open-world / Windrose-scale / RimWorld | Explicit aspiration traps already documented |
| Browser Snake productization | Misaligned with desktop Steam goal |

### 5.3 Recommended NEXT direction (single pure category)

## **Sandpile Criticality Idle** — pure idle/incremental

**One-line pitch:**  
You tend a living sandpile. Grain by grain you push it toward criticality; avalanches are your harvest. Upgrade how the pile fails — channels, thresholds, droppers, topologies — until the cascade economy runs itself. Prestige rewrites the physics of collapse.

**Why this is the best next (not a mashup):**

1. **Origin fidelity** — Matches the first commit’s fantasy word-for-word (grow/shape/automate sandpiles).  
2. **Market alignment** — Matches the revised idle-first Game 1 recommendation without needing horror or coins.  
3. **Inventiveness without genre glue** — The hook is **self-organized criticality** (avalanche as resource event), not “idle + physics + dread.” Abelian/BTW sandpile dynamics are underused as a commercial idle core; particles are juice *for* that rule, not the whole identity.  
4. **Solo ship shape** — Offline, single-player, Godot-friendly cellular/particle sim + numbers + prestige; content mountain is systems/juice, not narrative levels.  
5. **Sequel runway** — Game 2 can be pure automation (program the droppers/thresholds — TFWR-adjacent) *without* stuffing scripting into Game 1. Coin-machine and synergy toys remain separate later apps.

**What it is not:**

- Not a coin pusher.  
- Not a horror vignette.  
- Not a Factorio.  
- Not “Particul with a rename.”  
- Not an AI chatbot companion game.

**Minimum inventive differentiators (pick and lock 2–3):**

| Differentiator | Player-facing |
|---|---|
| Criticality meter / topology | Shape the board so *where* it collapses matters |
| Avalanche as economy | Cascades mint resources; overcritical meltdowns punish greed |
| Automata upgrades | Belts, funnels, inhibitors, seed injectors — still idle, not factory-sim scope |
| Prestige = new collapse laws | Ascension changes grain rules / dimensions / colors of sand |
| Readable juice | Satisfying grain physics + screen-shake avalanches (desktop spectacle) |

**Price / stack (consistent with plan):** Godot 4 · Windows Steam `.exe` · **$2.99–$4.99** · demo that shows one full avalanche-economy loop.

**Decision gate (must stay binary):**

1. Confirm **Sandpile Criticality Idle** as Game 1, **or**  
2. Explicitly override to automation-first / original non-Buckshot horror — and rewrite docs so `main` stops disagreeing with itself.

Until confirmation, do **not** scaffold conflicting GDDs, Snake-as-product, or mashup prototypes.

---

## 6. Portfolio gap analysis (blunt)

| Gap | Severity | Fix |
|---|---|---|
| No Godot project in `game/` | Critical | After lane lock: `project.godot` + one vertical slice |
| `main` vs PR #2 strategy disagreement | High | Merge or re-decide; one scoreboard |
| Sandpile name without sandpile mechanic design | High | One-page GDD centered on criticality loop |
| Public “stealth” claim with empty portfolio | Medium | Ship something small publicly or stop implying a catalog |
| Parallel agent doc explosion | Medium | Freeze research; produce playable slice |
| Snake PR vs desktop strategy | Low | Close, park, or reframe as tooling-only |

---

## 7. Appendix A — Raw command results (abbreviated)

### `gh repo list cmp07 --limit 50`

```
cmp07/Game-		public	2026-08-08T19:55:14Z
```

### Profile (`gh api users/cmp07`)

- `public_repos: 1`  
- `created_at: 2025-01-07T21:02:22Z`  
- Bio as quoted in §1.3  

### GraphQL

- `repositories.totalCount = 1` (`Game-`)  
- `repositoriesContributedTo.totalCount = 0`  

### Missing repo checks

- `cmp07/sandpile-tycoon` → HTTP 404  
- Owner searches for godot/unity/construct/cortex/idle/particle/sandpile → only `Game-` (or zero)

### `Game-` tree on `main`

```
.gitignore
README.md
docs/.gitkeep
docs/GAME_PLAN.md
docs/research/CATEGORY_RANKING.md
game/.gitkeep
research/.gitkeep
```

### Languages API

```
{}   # empty
```

---

## 8. Appendix B — Document conflict map (as of audit)

| Source | Game 1 recommendation |
|---|---|
| `main` README / GAME_PLAN / CATEGORY_RANKING | Tension / horror vignette |
| Birth commit README (`d36e59e`) | Idle particle sandpile tycoon |
| PR #2 market revision (unmerged) | Idle / incremental |
| **This audit’s inventive recommendation** | **Sandpile Criticality Idle** (pure idle; inventiveness via criticality, not mashup) |

`main` is currently the odd one out relative to both origin DNA and newer market work. Resolve that before production.

---

## 9. Appendix C — Suggested immediate artifacts (after human confirm)

1. Merge or supersede strategy docs so **one** Game 1 exists on `main`.  
2. `docs/GDD_SANDPILE_IDLE.md` — one page: loop, resources, avalanche rules, prestige, session length, art direction, non-goals.  
3. Godot 4 vertical slice in `game/`: drop grains → hit criticality → avalanche pays → buy one automator → prestige stub.  
4. Close or quarantine Snake PR as non-product.  
5. Steam placeholder page only after the slice is demoable.

---

## 10. Audit integrity notes

- **Private repos:** This integration received 403 on `user/repos` and gist list endpoints; private inventory is unknown. If private Construct/Unity/Godot work exists, re-run this audit with access and revise §3–§4.  
- **Stealth work:** Bio claims ~22 months; GitHub public history for game code starts **2026-08-08**. Treat stealth as unverified.  
- **Agent authorship:** Planning quality is high; do not confuse agent prose volume with creator implementation skill.  
- **No Unity/Cortex/Construct findings** means *not found publicly*, not *proven never made*.

---

*End of audit.*
