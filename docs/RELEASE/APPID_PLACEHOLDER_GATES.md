# AppID / DepotID placeholder gates

**Policy:** Do **not** invent Steam AppIDs or DepotIDs in-repo. Until Steamworks Partner creates the apps, every identity token stays as a named placeholder. Spacewar `480` is **dev-only** and must never ship in retail depots.

**Related:** [`STEAMWORKS.md`](STEAMWORKS.md) · [`DEMO_SPEC.md`](DEMO_SPEC.md) · [`STEAM_STORE_FINAL.md`](STEAM_STORE_FINAL.md) · [`../AUDIT/STEAM_READINESS.md`](../AUDIT/STEAM_READINESS.md)

---

## 1. Placeholder vocabulary

| Token | Meaning | Replace when |
|---|---|---|
| `YOUR_APP_ID` | Full-game Steam AppID | Partner creates the main app |
| `YOUR_DEPOT_ID` | Full-game **Windows** content depot | Depot created under full-game app |
| `YOUR_DEPOT_ID_LINUX` | Full-game **Linux** / Deck content depot | Depot created under full-game app |
| `YOUR_DEMO_APP_ID` | Separate **Demo** AppID (Next Fest) | Partner creates the demo app |
| `YOUR_DEMO_DEPOT_ID` | Demo **Windows** content depot | Depot created under demo app |
| `YOUR_STUDIO_NAME` / `[LEGAL_*]` | Legal / store identity | Studio paperwork + store Legal tab |
| `480` (Spacewar) | Steamworks SDK sample | Local GodotSteam bring-up only — **never retail** |

---

## 2. Ship gates (must be green before upload)

### Full game

| Gate | Check |
|---|---|
| G1 | No committed file contains a real AppID except docs that explicitly say “placeholder” |
| G2 | `steam_features.json` → `app_id_placeholder` is still `YOUR_APP_ID` **or** the real ID after Partner assign |
| G3 | `steam/echo_lattice/app_build.vdf` AppID + both depot keys replaced |
| G4 | `depot_windows.vdf` / `depot_linux.vdf` DepotIDs replaced |
| G5 | Staging under `depot_build/windows/` and `depot_build/linux/` has binaries; **no** `steam_appid.txt` |
| G6 | Launch options: Windows → `EchoLattice.exe`; SteamOS/Deck → `EchoLattice.x86_64` (native, not Proton-first) |
| G7 | `steam_enabled` flipped only on Steam-branded exports; itch builds stay offline |

### Demo

| Gate | Check |
|---|---|
| D1 | `YOUR_DEMO_APP_ID` assigned and linked to full game in Partner |
| D2 | `app_build_demo.vdf` + `depot_windows_demo.vdf` IDs replaced |
| D3 | `DemoBuild.WISHLIST_URL` uses real **full-game** `YOUR_APP_ID` (not Spacewar) |
| D4 | Demo staging has `EchoLatticeDemo.exe` + `.pck` from **Windows Demo** preset only |
| D5 | Achievement policy decided (omit vs `mvp: true` only) on the demo AppID |

### Hard rejects

| Reject | Why |
|---|---|
| Shipping `steam_appid.txt` | Forces wrong AppID beside exe; listed in VDF `FileExclusion` |
| Shipping AppID `480` | Spacewar — players unlock wrong achievements |
| Inventing numeric IDs in git “to unblock CI” | Partner is source of truth; CI must pass with placeholders |
| Pointing Deck default launch at Windows `.exe` | Contradicts native Linux / Deck Verified path |

---

## 3. File checklist (replace before Partner upload)

| Path | Token(s) |
|---|---|
| `game/echo_lattice/config/steam_features.json` | `app_id_placeholder` |
| `game/echo_lattice/config/achievements_steam.json` | `app_id` |
| `docs/RELEASE/ACHIEVEMENTS.json` | `app_id` |
| `game/echo_lattice/steam_appid.txt.example` | example line |
| `game/echo_lattice/scripts/demo_build.gd` | `WISHLIST_URL` → `/app/YOUR_APP_ID/` |
| `steam/echo_lattice/app_build.vdf` | `YOUR_APP_ID`, `YOUR_DEPOT_ID`, `YOUR_DEPOT_ID_LINUX` |
| `steam/echo_lattice/depot_windows.vdf` | `YOUR_DEPOT_ID` |
| `steam/echo_lattice/depot_linux.vdf` | `YOUR_DEPOT_ID_LINUX` |
| `steam/echo_lattice/app_build_demo.vdf` | `YOUR_DEMO_APP_ID`, `YOUR_DEMO_DEPOT_ID` |
| `steam/echo_lattice/depot_windows_demo.vdf` | `YOUR_DEMO_DEPOT_ID` |
| `docs/RELEASE/STEAM_STORE_FINAL.md` | header AppID |

---

## 4. Verification (placeholders OK)

These gates must stay green **with** placeholders still in place:

```bash
python3 game/echo_lattice/tests/validate_chambers.py
python3 game/echo_lattice/tests/test_steamworks.py
python3 game/echo_lattice/tests/test_demo_spec.py
```

CI workflow: [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml) (`validate` job).

After Partner assign, grep the tree for leftover tokens before the first `run_app_build`:

```bash
rg -n 'YOUR_APP_ID|YOUR_DEPOT_ID|YOUR_DEMO_APP_ID|YOUR_DEMO_DEPOT_ID|YOUR_DEPOT_ID_LINUX' \
  game/echo_lattice steam/echo_lattice docs/RELEASE
```

Expect zero hits in VDF / runtime config / wishlist URL (docs may still mention the tokens historically).

---

*No AppIDs invented in this document.*
