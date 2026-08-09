# sandpile-tycoon

Planning and production workspace for a sequence of **small, separate Steam desktop games** (real Windows `.exe`, not browser) priced roughly **$0.99–$10**.

**Start here:** [`docs/GAME_PLAN.md`](docs/GAME_PLAN.md)

## Strategy (short)

- **One pure category per product** — do not mash genres into a hybrid “first game.”
- **Sequential small Steam releases**, not one mega-scope title:
  1. Tension / horror vignette (recommended Game 1 — **confirm before production**)
  2. Coin-machine game
  3. Idle / particle tycoon (Particul-like)
- Research scores & comps: [`docs/research/CATEGORY_RANKING.md`](docs/research/CATEGORY_RANKING.md)

## Layout

- `docs/` — game plan, design notes, Steam checklist
- `docs/RELEASE/` — RC1 / multi-platform store strategy + CI build sketch ([`RC1_README.md`](docs/RELEASE/RC1_README.md))
- `docs/RELEASE/STEAM_DECK.md` — Echo Lattice Steam Deck Verified prep
- `docs/RELEASE/STEAMWORKS.md` — Steamworks readiness (offline stub by default)
- `docs/RELEASE/ACHIEVEMENTS.json` — Steam achievement catalog
- `docs/research/` — category ranking and competitive notes
- `research/` — scratch references
- `game/echo_lattice/` — **Launch path:** Godot 4.3 host for **The Weaver** (Lattice shell + Weaver field; chambers as Archive) — see [`game/echo_lattice/README.md`](game/echo_lattice/README.md) · [`docs/WEAVER/BUILD_ON_LATTICE.md`](docs/WEAVER/BUILD_ON_LATTICE.md)
- `game/weaver/` — Temporary standalone Weaver spike (loop/juice twin; not the product launch path)
- `steam/echo_lattice/` — SteamPipe VDF templates (placeholder AppID)

## Stack

- Godot 4 (desktop / Steam)
- Windows-first development
