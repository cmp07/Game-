# RC1 Steam pack — freeze / resume

**Status:** Steam pack frozen. **Product-line pivot:** Echo Lattice is frozen; **The Weaver** is the shipping north star — see [`../WEAVER/PIVOT.md`](../WEAVER/PIVOT.md) · [`../WEAVER/PRODUCT_IDENTITY.md`](../WEAVER/PRODUCT_IDENTITY.md).  
**Policy:** Do **not** delete Steam / RELEASE / AUDIT work, and do **not** delete Echo Lattice (`game/echo_lattice/` today; later may move to `game/_archive/echo_lattice/`). Resume Partner + store upload from this freeze **only after** depth gates G1–G4 in [`../VISION/ROADMAP_EXECUTE.md`](../VISION/ROADMAP_EXECUTE.md) §8 *if* Echo Lattice shipping is explicitly reopened. Public page rename toward Weaver is planned in PRODUCT_IDENTITY (human Partner; no AppID invention here).  
**Vision lock (historical EL):** [`../VISION/MASTER_1000X.md`](../VISION/MASTER_1000X.md) — game-feel **41/100** vs pack ship-readiness **78/100**. **Live north star:** [`../WEAVER/PIVOT.md`](../WEAVER/PIVOT.md).

| Field | Value |
|---|---|
| **Freeze tip (RC1)** | `5f0d46355abea0f5cd0f1da16c2e70c1eb717f55` |
| **Tip subject** | Merge pull request #113 (`cursor/view-media-index-9b2e`) |
| **Durable branch** | `backup/echo-lattice-rc1-steam-pack` |
| **Durable tag** | `backup/echo-lattice-rc1-steam-pack` (annotated) |
| **Integration line** | `cursor/echo-lattice-rc1` |
| **Freeze date** | 2026-08-09 |
| **Ship-readiness score** | **~78 / 100** ([`../AUDIT/ULTRA_AUDIT_RC1.md`](../AUDIT/ULTRA_AUDIT_RC1.md)) |
| **Path index** | [`PATHS_INDEX.md`](PATHS_INDEX.md) · [`KEY_PATHS.md`](KEY_PATHS.md) |

---

## 1. What was ready (in-repo)

### Store / Coming Soon pack

| Area | State at freeze |
|---|---|
| Store copy freeze | [`../RELEASE/STORE_COPY_FREEZE.md`](../RELEASE/STORE_COPY_FREEZE.md) |
| Store package | [`../RELEASE/STEAM_STORE_FINAL.md`](../RELEASE/STEAM_STORE_FINAL.md) |
| Capsule finals (Field Ledger sizes) | [`../RELEASE/capsules/`](../RELEASE/capsules/) |
| Screenshot slate 1920×1080 | [`../RELEASE/screenshots/`](../RELEASE/screenshots/) |
| Trailer editor pack (30s) | [`../RELEASE/trailer/`](../RELEASE/trailer/) — **final encode still human** |
| Media gallery links | [`../RELEASE/VIEW_MEDIA.md`](../RELEASE/VIEW_MEDIA.md) |
| Partner legal paste pack | [`../RELEASE/legal/`](../RELEASE/legal/) (survey / AI / privacy / ratings) |
| Achievements catalog | [`../RELEASE/ACHIEVEMENTS.json`](../RELEASE/ACHIEVEMENTS.json) ≡ runtime mirror |
| AppID policy | Placeholders only — [`../RELEASE/APPID_PLACEHOLDER_GATES.md`](../RELEASE/APPID_PLACEHOLDER_GATES.md) |

### CI / builds / Steamworks scaffolding

| Area | State at freeze |
|---|---|
| GitHub Actions | [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml) |
| CI / export notes | [`../RELEASE/CI_BUILDS.md`](../RELEASE/CI_BUILDS.md) |
| Windows (+ Demo) export | [`../RELEASE/BUILD_WINDOWS.md`](../RELEASE/BUILD_WINDOWS.md) |
| GodotSteam (fail-closed) | [`../RELEASE/GODOTSTEAM.md`](../RELEASE/GODOTSTEAM.md) + `game/echo_lattice/addons/godotsteam/` docs |
| Depot VDF templates | `steam/echo_lattice/` (Windows / Linux / demo + env render) |
| Offline Steam stub | `game/echo_lattice/scripts/steam/` + [`../RELEASE/STEAMWORKS.md`](../RELEASE/STEAMWORKS.md) |
| Python contract suite | **22/22** green (no Godot binary required in cloud) |

### Audits

Full corpus under [`../AUDIT/`](../AUDIT/). Executive synthesis: ship-readiness **78/100**; Partner/Coming Soon still blocked on human AppID + uploads. Steam Partner in-repo readiness was later raised by Gate A media (capsules / screenshots / trailer pack) beyond the earlier **38%** snapshot in [`STEAM_READINESS.md`](../AUDIT/STEAM_READINESS.md) — treat that doc’s percent as historical unless re-scored.

P0 code + Gate A + fix waves landed on RC1 before this freeze (see [`../RELEASE/RC1_README.md`](../RELEASE/RC1_README.md)).

### Playable product (kept, not deleted)

| Area | Path |
|---|---|
| Godot 4.3 project | `game/echo_lattice/` |
| Campaign / Daily / Endless offline | vertical slice + `content/` |
| Museum / onboarding upgrades | landed on RC1 tip |
| Tests | `game/echo_lattice/tests/test_*.py` |

---

## 2. Partner checklist — still human

Cloud agents **must not** invent AppIDs or click Partner. Open items at freeze:

- [ ] Create real full-game **AppID** (+ DepotIDs) and demo AppID in Steamworks
- [ ] Replace `YOUR_APP_ID` / `YOUR_*_DEPOT_ID` / studio legal tokens (see placeholder gates)
- [ ] Paste store short/long copy, tags, categories, sysreqs, pricing from freeze docs
- [ ] Upload capsules + 1920×1080 screenshots to Partner
- [ ] Encode final 30s trailer from editor pack; upload
- [ ] Paste Content Survey + AI disclosure; publish privacy HTTPS URL
- [ ] Create achievement rows / icons; smoke unlocks on real AppID
- [ ] Stage retail binaries; SteamCMD depot upload; green CI with real IDs
- [ ] Deck Verified / hardware farm (never proven in cloud-only audits)

Until those are done, **public Coming Soon stays blocked**. In-repo pack remains the source of truth.

---

## 3. How to resume (Steam later)

1. **Checkout the freeze** (identical trees for game / RELEASE / AUDIT / steam):
   ```bash
   git fetch origin tag backup/echo-lattice-rc1-steam-pack
   git checkout backup/echo-lattice-rc1-steam-pack
   # or: git checkout backup/echo-lattice-rc1-steam-pack  # branch
   ```
2. **Rebase or merge into current RC1** if the integration line moved:
   ```bash
   git checkout cursor/echo-lattice-rc1
   git merge backup/echo-lattice-rc1-steam-pack   # should be ancestor if freeze was taken from tip
   ```
3. **Sanity contracts** (cloud-friendly):
   ```bash
   python3 game/echo_lattice/tests/test_release_liveops.py
   python3 game/echo_lattice/tests/test_rc_polish.py
   python3 game/echo_lattice/tests/test_adversarial_qa.py
   python3 game/echo_lattice/tests/test_security_high.py
   python3 game/echo_lattice/tests/test_godotsteam_gate.py
   ```
4. **Human Partner path:** follow [`../RELEASE/STEAM_STORE_FINAL.md`](../RELEASE/STEAM_STORE_FINAL.md) § Coming Soon checklist + [`../RELEASE/legal/`](../RELEASE/legal/) + [`../RELEASE/APPID_PLACEHOLDER_GATES.md`](../RELEASE/APPID_PLACEHOLDER_GATES.md).
5. **Do not** wipe `steam/`, `docs/RELEASE/`, or Gate A media while focusing on game depth — deepen content on RC1; resume Steam from this freeze when ready.

---

## 4. Intentionally out of scope for this freeze PR

- No Steam file deletion or Partner identity invention
- No merge of RC1 → `main`
- No claim of Next Fest Verified / paid 1.0
- No deletion of `game/echo_lattice/` (see Weaver pivot)
- New product north-star work lands under [`../WEAVER/`](../WEAVER/) — not by overwriting this freeze

---

## 5. Related entry points

| Doc | Role |
|---|---|
| [`../WEAVER/PIVOT.md`](../WEAVER/PIVOT.md) | **Weaver north star** — Echo Lattice frozen; `game/echo_lattice/` kept |
| [`../VISION/MASTER_1000X.md`](../VISION/MASTER_1000X.md) | Historical EL executive vision — pause Steam, deepen game |
| [`../VISION/ROADMAP_EXECUTE.md`](../VISION/ROADMAP_EXECUTE.md) | Ordered waves + G1–G4 before Steam resume (EL line) |
| [`../RELEASE/RC1_README.md`](../RELEASE/RC1_README.md) | RC1 integration hub |
| [`../AUDIT/ULTRA_AUDIT_RC1.md`](../AUDIT/ULTRA_AUDIT_RC1.md) | Scorecard ~78 + gates |
| [`KEY_PATHS.md`](KEY_PATHS.md) | Navigable tree of frozen areas |
| [`PATHS_INDEX.md`](PATHS_INDEX.md) | Full file listing at freeze tip |
| [`README.md`](README.md) | Backup folder index |
