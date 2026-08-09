# VO + text cards — Gate A 30s

Voice: **dry cartographer**. One breath per line. No trailer-guy cadence. Prefer captions-on for mute viewers; VO is optional reinforcement.

Type: condensed grotesk feel — generator uses Noto Sans (system) at ink/rust on paper. Final grade may swap Akkurat / IBM Plex Sans Condensed.

## Primary VO take (≈28 s spoken + silence tails)

| TC | Line | On-screen (must match) |
|---|---|---|
| 0:00 | Echo Lattice. | `Deterministic.` *(card leads; brand spoken)* |
| 0:04 | A paper labyrinth that watches how you walk. | `Same seed. Different you.` |
| 0:09 | Hit a checkpoint— | `Hit a checkpoint…` |
| 0:11 | —and it rewrites the maze. | *(slam — no card)* then `IT LEARNED YOU` |
| 0:15 | Escape by rewriting yourself — not by beating RNG. | `The maze wears you.` |
| 0:20 | Thirty-five chambers. Four acts. Daily challenge. | `Thirty-five chambers.` / `Four acts.` / `Daily seed.` |
| 0:26 | Wishlist now. / Available on Steam. | `ECHO LATTICE` · `IT LEARNED YOU` · `Wishlist` |

## Alternate single-breath VO (A/B)

> It isn’t random. It’s you — printed back as architecture.

Use under prove (0:12–0:25) if primary feel too explanatory; keep end CTA lines.

## Caption / card bank (locked strings)

| ID | String | Color token | Pack file |
|---|---|---|---|
| C01 | `Deterministic.` | `ink_black` | `text_cards/card_deterministic.png` |
| C02 | `Your footsteps are a draft.` | `ink_black` | `text_cards/card_footsteps_draft.png` |
| C03 | `Same seed. Different you.` | `ink_black` | `text_cards/card_same_seed.png` |
| C04 | `Hit a checkpoint…` | `ink_black` | `text_cards/card_hit_checkpoint.png` |
| C05 | `IT LEARNED YOU` | `slate_teal` / `rust_fossil` accent | `text_cards/card_it_learned_you.png` |
| C06 | `The maze wears you.` | `rust_fossil` | `text_cards/card_maze_wears_you.png` |
| C07 | `Thirty-five chambers.` | `ink_black` | `text_cards/card_thirty_five.png` |
| C08 | `Four acts.` | `ink_black` | `text_cards/card_four_acts.png` |
| C09 | `Daily seed.` | `slate_teal` | `text_cards/card_daily_seed.png` |
| C10 | `ECHO LATTICE` | `ink_black` | `text_cards/card_title_lockup.png` |
| C11 | `Wishlist` / `Coming Soon` | `rust_fossil` underline | `text_cards/card_wishlist_cta.png` |

### Forbidden card copy

- “AI maze”, “procgen”, “roguelike loot”, horror stingers, purple glow taglines
- Competitor names, fake review quotes, “Overwhelmingly Positive” until real

## A/B social hooks (thumb / first frame captions)

1. `IT LEARNED YOU.`
2. `The maze keeps your first draft.`
3. `Stop walking like yourself.`
4. `Origami walls. Rust fossils.`
5. `Puzzle game where your path becomes the wall.`

## Regenerate PNGs

```bash
python3 tools/release/generate_trailer_text_cards.py
```

Cards are 1920×1080 transparent-friendly compositions on `paper_bone` with safe margins for Steam embed crop.
