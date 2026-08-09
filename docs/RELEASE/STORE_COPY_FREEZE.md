# Echo Lattice — Store Copy Freeze (Gate A)

**Product:** Echo Lattice  
**Status:** **FROZEN** for Steam Coming Soon paste  
**Freeze date:** 2026-08-09  
**Canonical paste package:** [`STEAM_STORE_FINAL.md`](STEAM_STORE_FINAL.md)  
**RC1 line:** `cursor/echo-lattice-rc1` (cloud-only integration)  
**Gate:** Ultra Audit Gate A — store copy freeze (primary short/long; no horror / AI / loot lead)

---

## 1. What is locked

These Partner-facing fields are frozen. Paste from `STEAM_STORE_FINAL.md` only; do not freestyle in Steamworks.

| Field | Frozen source | Locked value (summary) |
|---|---|---|
| **Short description** | §2 Primary | Habit→geometry labyrinth; ≤300 chars; no AI / mystery / loot lead |
| **Long description** | §3.1 Master copy | Habits, Daily Challenge, Endless climb, 35 chambers, deterministic / no generative AI |
| **Tags (primary order)** | §4.1 | Puzzle → Procedural Generation → Minimalist → Singleplayer → Replay Value |
| **Supporting tags** | §4.2 | Indie, 2D, Atmospheric, Abstract, Logic (+ Controllers) |
| **Categories / features** | §4.3–4.4 | Single-player Puzzle / Indie; Achievements Yes; no MP / Workshop / IAP / VR |
| **System requirements** | §6 | Windows primary floors; Linux + macOS tables as written |
| **Pricing recommendation** | §5 | **$6.99 USD** list (band $4.99–$9.99; do not exceed $9.99 for v1) |

AI survey / public line remains **No generative AI in gameplay** — see `STEAM_STORE_FINAL.md` §10 and [`COMPLIANCE_FINAL.md`](COMPLIANCE_FINAL.md) §1.3.

---

## 2. Game-truth constraints (do not drift)

Frozen copy must keep matching ship truth on RC1:

| Truth | Store implication |
|---|---|
| **Habits → walls** | Maze rebuilds from the player’s last thirty moves; sell recognition, not RNG |
| **Daily Challenge** | Shared UTC seed wing; offline calendar — not a live-service feed |
| **Endless** | Thin vertical: seeded catalog climb with rising rewrite pressure; best depth persisted locally |
| **No AI gameplay** | Deterministic offline rules + hand-authored chambers; never “AI dungeon,” never generative levels/story |
| **Modes** | Campaign (35 chambers / 4 acts) + Daily + Endless — mention all three in About This Game |
| **Not** | Roguelike loot, combat, chatbot, always-online, horror lead |

If code removes or materially changes Endless / Daily / habit rewrite, **unfreeze via change control** before Partner paste.

---

## 3. Change control

**Default:** no edits to frozen fields without a docs PR.

1. Open a PR against `cursor/echo-lattice-rc1` (not silent Partner-only edits).
2. Update **both** [`STEAM_STORE_FINAL.md`](STEAM_STORE_FINAL.md) (paste text) and this freeze ledger (reason + date + owner).
3. Keep alignment with [`COMPLIANCE_FINAL.md`](COMPLIANCE_FINAL.md) AI / content answers.
4. Re-check Steam character limits (short ≤300) and tag order after any rewrite.
5. Only after merge: re-paste into Steamworks; note Partner revision in the table below.

### Allowed without unfreeze

- Replacing `YOUR_APP_ID` / `YOUR_STUDIO_NAME` placeholders when legal identity lands
- Capsule / screenshot / trailer **asset** swaps that do not change store prose
- Regional price *tables* in [`PLATFORMS.md`](PLATFORMS.md) that preserve the **$6.99 USD** recommendation

### Requires unfreeze + dual-doc PR

- Short or long description wording
- Primary tag set or order
- Category / feature checkbox answers
- Sysreq floors or OS claims
- USD list price recommendation or band

### Change log

| Date | Change | Reason | Owner |
|---|---|---|---|
| 2026-08-09 | Initial freeze | Gate A store-copy lock; align habits / Daily / Endless / no AI | Gate A store-copy PR |

---

## 4. Partner paste checklist (frozen fields only)

- [ ] Short description — `STEAM_STORE_FINAL.md` §2 Primary
- [ ] Long description — §3.1 (BBCode)
- [ ] Tags — §4.1 then §4.2
- [ ] Categories / features — §4.3–4.4
- [ ] Sysreqs — §6
- [ ] Price — **$6.99 USD** (§5)
- [ ] Generative AI survey — **No** (§10 / compliance)

---

*This ledger freezes store prose and commercial metadata for Coming Soon. Capsules, trailer encode, and AppID identity remain separate Gate A items.*
