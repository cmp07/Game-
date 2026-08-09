# Key paths indexed at Steam pack freeze

Freeze tip: `5f0d46355abea0f5cd0f1da16c2e70c1eb717f55` · ref `backup/echo-lattice-rc1-steam-pack`.  
Full recursive listing: [`PATHS_INDEX.md`](PATHS_INDEX.md).

Steam scaffolding under `steam/` is **preserved** (not deleted). Trees below are the resume anchors.

---

## `game/` — playable product

| Path | Role |
|---|---|
| `game/echo_lattice/` | Godot 4.3 project root |
| `game/echo_lattice/project.godot` | Editor entry |
| `game/echo_lattice/scenes/` | Menus, chambers, HUD |
| `game/echo_lattice/scripts/` | Core loop, meta, Steam stub, ops |
| `game/echo_lattice/scripts/steam/` | Offline Steam service + achievements wire |
| `game/echo_lattice/content/` | Chambers, daily calendar, rewrites |
| `game/echo_lattice/config/` | `steam_features.json`, achievements mirror, balance |
| `game/echo_lattice/locale/` | EN + zh-Hans |
| `game/echo_lattice/art/` · `audio/` · `fonts/` | Field Ledger placeholders → production later |
| `game/echo_lattice/addons/godotsteam/` | Optional SDK install docs (fail-closed without binaries) |
| `game/echo_lattice/tests/` | Python contract suite (22/22 at freeze) |
| `game/echo_lattice/tools/` | Capture / export helpers |

---

## `docs/RELEASE/` — Steam ship pack

| Path | Role |
|---|---|
| `docs/RELEASE/RC1_README.md` | Integration policy + merged packs |
| `docs/RELEASE/README.md` | Release index |
| `docs/RELEASE/STEAM_STORE_FINAL.md` | Coming Soon / Next Fest store package |
| `docs/RELEASE/STORE_COPY_FREEZE.md` | Frozen Partner copy fields |
| `docs/RELEASE/STEAMWORKS.md` · `GODOTSTEAM.md` | Steamworks + optional SDK |
| `docs/RELEASE/APPID_PLACEHOLDER_GATES.md` | No fake AppID policy |
| `docs/RELEASE/BUILD_WINDOWS.md` · `CI_BUILDS.md` · `PLATFORMS.md` | Export + CI |
| `docs/RELEASE/COMPLIANCE_FINAL.md` | Full compliance pack |
| `docs/RELEASE/legal/` | Gate A Partner paste (survey / AI / privacy / ratings) |
| `docs/RELEASE/capsules/` | Capsule PNG finals |
| `docs/RELEASE/screenshots/` | 1920×1080 Partner slate |
| `docs/RELEASE/trailer/` | 30s editor pack (encode pending) |
| `docs/RELEASE/VIEW_MEDIA.md` | Gallery with GitHub links |
| `docs/RELEASE/DEMO_SPEC.md` · `STEAM_DECK.md` | Next Fest demo + Deck prep |
| `docs/RELEASE/presskit/` · `LAUNCH_PLAYBOOK.md` | Marketing |
| `docs/RELEASE/ACHIEVEMENTS.json` | Achievement catalog |

---

## `docs/AUDIT/` — ship score + risks

| Path | Role |
|---|---|
| `docs/AUDIT/ULTRA_AUDIT_RC1.md` | Executive synthesis — **~78/100** |
| `docs/AUDIT/STEAM_READINESS.md` | Partner readiness audit (historical %) |
| `docs/AUDIT/SECURITY.md` · `SECURITY_HIGH_FIXES.md` | SEC High closed notes |
| `docs/AUDIT/BUGS_CORE.md` · `BUGS_META.md` | P0 bug lanes |
| `docs/AUDIT/ADVERSARIAL_QA.md` | Session integrity |
| `docs/AUDIT/DESIGN_GAMEPLAY.md` · `CONTENT_CHAMBERS.md` | Depth backlog signals |
| `docs/AUDIT/ARCHITECTURE.md` · `PERFORMANCE.md` | Tech debt / perf |
| `docs/AUDIT/COMPAT_DESKTOP.md` · `COMPAT_PLATFORMS.md` | Compat matrices |
| `docs/AUDIT/A11Y_L10N.md` · `AUDIO_ART_UX.md` · `PRODUCT_UPGRADES.md` · `UPGRADE_LIST.md` | Remaining polish |

---

## `steam/` — preserved depot scaffolding

| Path | Role |
|---|---|
| `steam/echo_lattice/app_build.vdf` · `app_build_demo.vdf` | SteamPipe app builds |
| `steam/echo_lattice/depot_windows.vdf` · `depot_linux.vdf` · `depot_windows_demo.vdf` | Depot templates |
| `steam/echo_lattice/render_vdf_from_env.py` | `STEAM_*` env → VDF render |
| `steam/echo_lattice/verify_retail_staging.py` | Staging checks |
| `steam/echo_lattice/depot_build/` | Staging dirs (binaries not committed) |
| `steam/echo_lattice/README.md` | Upload runbook |

---

## This freeze folder

| Path | Role |
|---|---|
| `docs/BACKUP/RC1_STEAM_PACK_FREEZE.md` | What was ready / Partner human / resume |
| `docs/BACKUP/KEY_PATHS.md` | This navigable index |
| `docs/BACKUP/PATHS_INDEX.md` | Full file list at tip |
| `docs/BACKUP/README.md` | Folder entry |
