# Generative AI disclosure — paste-ready

**Product:** Echo Lattice  
**Steamworks path:** App Admin → Content Survey → **Generative Artificial Intelligence Content**  
**Store / public:** use the one-liner below; never tag or market as “AI dungeon”  
**AppID:** `YOUR_APP_ID` *(do not invent)*  
**Companion:** [`STEAM_CONTENT_SURVEY.md`](STEAM_CONTENT_SURVEY.md) · [`../STEAM_STORE_FINAL.md`](../STEAM_STORE_FINAL.md) §10 · [`../COMPLIANCE_FINAL.md`](../COMPLIANCE_FINAL.md) §1.3

Steam’s focus (2026 clarification): **player-consumed** AI content (art, sound, narrative, localization, etc.), **not** IDE / copilot efficiency tools used while coding.

---

## 1. Survey answers — paste

| Question | Paste answer |
|---|---|
| Does this product use generative AI to create content consumed by players (pre-generated or live-generated)? | **No** |
| Pre-Generated AI content in the ship build? | **No** |
| Live-Generated AI during gameplay? | **No** |
| Runtime LLM / cloud model / chatbot? | **No** |

---

## 2. Why these answers are correct

| System | Generative AI? | Note |
|---|---|---|
| Habit buffer → rewrite operators | **No** | Offline deterministic rules / scoring — not a generative model |
| Chamber content | **No** | Hand-authored JSON under `game/echo_lattice/content/` |
| Placeholder SFX / music | **No** | Procedural DSP / math synthesis — not a generative model service |
| Placeholder art | **No** | Deterministic scripts + palette JSON |
| Code assistants during development | **Out of scope** | Dev tooling; Steam AI section does not target this |

---

## 3. Public / store one-liner (paste if asked)

```text
Echo Lattice adapts geometry with deterministic, offline rules from your recent moves. No generative AI models create art, audio, text, or levels in the shipping game.
```

**Survey blurb (if forced to explain “adaptive” systems):**

```text
The game adapts geometry using deterministic, offline rules based on the player’s recent moves. No generative AI models are used to create art, audio, text, or levels at runtime or in the shipping content pipeline.
```

---

## 4. Marketing-asset exception (future only)

If store capsules or trailer frames later use an image/audio **model**:

1. Disclose **only** that marketing-asset path under Pre-Generated.
2. State clearly that **gameplay does not use generative AI**.
3. Do **not** retcon rewrite systems as AI. Store tags stay Puzzle / Minimalist / Singleplayer.
4. Until that happens, keep every survey answer **No**.

---

## 5. Copy bans (store + trailer + social)

| Do not say | Say instead |
|---|---|
| AI dungeon / AI-powered maze | Deterministic habit → geometry rewrite |
| The game generates levels with AI | Hand-authored chambers; offline rules |
| Neural / LLM narrator | Field Ledger / transit-PA tone (authored) |

---

*Gate A item: submit AI disclosure **No** with the Content Survey. No AppID invented here.*
