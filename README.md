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
- **Godot 4 + AI + Steam desktop pipeline (8-week plan):** [`docs/research/GODOT_AI_STEAM_PIPELINE.md`](docs/research/GODOT_AI_STEAM_PIPELINE.md)

## Layout

- `docs/` — game plan, design notes, Steam checklist
- `docs/research/` — category ranking, competitive notes, technical pipeline
- `research/` — scratch references
- `game/` — Godot 4 project (after a lane is locked)

## Stack

- Godot 4 (desktop / Steam Windows `.exe`, not browser)
- GodotSteam GDExtension + SteamPipe
- AI-assisted **production** (textures/code); offline-first **runtime**
- Windows-first development
