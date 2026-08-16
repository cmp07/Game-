# Solo Indie AI Tech Stack for Desktop Steam Games (2025–2026)

**Repo:** [cmp07/Game-](https://github.com/cmp07/game-)  
**Research window:** mid-2025 → August 2026  
**Lens:** Solo developer, Godot 4 (primary) / Unity (secondary), Windows-first Steam `.exe`, price band **$0.99–$10**, Steam Deck–aware, inventiveness without “AI slop.”  
**Companion docs:** [`docs/GAME_PLAN.md`](../GAME_PLAN.md), [`docs/research/CATEGORY_RANKING.md`](CATEGORY_RANKING.md)

---

## Executive verdict

For a solo Steam indie in 2026, **treat generative AI as an untrusted proposer**, never as the authority that owns fun. Ship a **deterministic core loop** (authored rules, behavior trees / utility / GOAP, seeded PCG) and let models only propose **bounded flavor**: dialogue variants, local lore crumbs, texture drafts you edit offline, optional voice skins. That architecture makes the game feel like it shapes around the player *when AI works*, and remain a complete, reviewable game *when AI fails* (offline Deck, API outage, weak GPU, Steam cert airplane-mode check).

**Recommended first product fit for this repo:** Game 1 tension/horror vignette with an original ritual premise — AI as **antagonist memory + line improvisation + optional local whisper**, not as “infinite chat companion.” Bake AI cost into the $2.99–$7.99 price or gate live cloud behind optional DLC; default path is **offline-capable**.

---

## 1. Design north star: inventiveness without slop

### What “AI slop” looks like on Steam in 2026

Players and reviewers now treat raw generative output as a quality smell: samey textures, chatbot NPCs with no stakes, lore walls with no mechanical consequence, store pages that scream “prompted asset dump.” Analyses of Steam AI disclosures show volume exploding (thousands of titles disclosing genAI by mid-2025), which raises the bar: **AI presence is no longer novel; craft is.**

Anti-slop rules that hold up in practice:

| Do | Don’t |
|---|---|
| Human-direct the fantasy; AI accelerates volume work | Ship Midjourney/Comfy dumps as hero art |
| Constrain model output to schemas / enums / tagged lines | Free-text that mutates quest flags unchecked |
| Seeded PCG + authored set pieces | Pure noise worlds with no emotional landmarks |
| Edit every player-facing asset to palette/voice | “First draft = ship” |
| Fail closed to authored content | Soft-lock or silence when the model dies |

The useful mental model from neuro-symbolic game AI work (e.g. LlamaBrain-style control planes, HeRoN-style mediated RL–LLM): **LLM proposes → validation gate → deterministic world applies or rejects.** Continuity lives in your state machine, not in the model’s chat history.

### “Shapes around the user” without depending on AI

Personalization that survives offline:

1. **Player telemetry → parameters** — risk preference, verbosity, aggression, session length → tune authored difficulty / antagonist cadence (no LLM required).
2. **Memory blackboard** — facts the player established (“I lied,” “I sacrificed X”) stored as structured tags; AI (or templates) only *colors* those tags.
3. **Seeded runs** — one master seed; AI flavor is optional salt, not the map generator.
4. **Choice residue** — previous vignette outcomes unlock modifiers; feel of “the game knows me” comes from systems design.

---

## 2. Stack map (what a solo can actually ship)

```
┌─────────────────────────────────────────────────────────────────┐
│                     AUTHORITY LAYER (always on)                 │
│  Godot/Unity game state · BT/Utility/GOAP · seeded PCG · save   │
└───────────────────────────────▲─────────────────────────────────┘
                                │ validated intents only
┌───────────────────────────────┴─────────────────────────────────┐
│                     PROPOSAL LAYER (optional)                   │
│  Local SLM (llama.cpp/GGUF)  ·  Cloud LLM (proxy)  ·  templates │
└───────────────┬─────────────────────┬───────────────────────────┘
                │                     │
        ┌───────▼────────┐    ┌───────▼────────┐
        │ Voice (opt.)   │    │ Art pipeline   │
        │ Piper / Whisper│    │ ComfyUI offline│
        │ ACE on RTX     │    │ human edit→ship│
        └────────────────┘    └────────────────┘
```

**Engine note for this repo:** Godot 4 is already the planned stack. Prefer Godot GDExtensions wrapping `llama.cpp` over Unity-only ACE plugins unless you deliberately switch engines. Unity remains stronger for Sentis / ML-Agents / ACE UE-adjacent ecosystems; Godot wins on license, iteration speed, and Deck-friendly binary size for $3–$8 vignettes.

---

## 3. Local LLMs (runtime)

### What’s usable in 2025–2026

| Piece | Role | Solo practicality |
|---|---|---|
| **llama.cpp + GGUF** | De facto local inference engine | High — C++, Vulkan/CUDA/Metal, embeddable |
| **Ollama / LM Studio** | Dev-time servers (OpenAI-compatible HTTP) | High for prototyping; don’t rely on player installing Ollama for ship |
| **SLMs (0.5B–4B, Q4)** | In-game dialogue / classification | High on desktop; marginal on Deck |
| **7B–8B Q4** | Better prose; heavier | Desktop OK; Deck thermal/battery painful as always-on |
| **Godot bridges** | GDLlama, godot_llama, godot-llm, OhMyDialogSystem | Usable but immature — budget integration risk |
| **Unity bridges** | LlamaBrain, Runtime LLM plugins, Sentis | More packaging examples; still treat as proposer |

**Steam Deck reality:** The Deck can run small GGUFs (≈1B–4B Q4) via Vulkan-accelerated `llama.cpp`, especially with VRAM share bumped in BIOS. That is a **tech-demo / optional enhancement** reality, not a “every NPC chats at 30 tok/s while you fight” reality. Shared 16 GB RAM + APU thermal budget means **async, rare inference** (between rounds, on menu, on ritual resolve) — never per-frame.

**Ship patterns that work:**

- **Optional local model pack** (DLC or first-run download) so the base install stays small.
- Cap context tightly (512–2K tokens); inject a **StateSnapshot**, not a novel.
- Force **JSON / tool-call schemas** (`{"line_id":..., "tone":..., "memory_write":[...]}`).
- Time-budget inference; on timeout → authored fallback line.

**Privacy win:** Local inference keeps player speech and chat off the network. Disclose model license (Llama, Qwen, Gemma, etc.) in legal docs; some weights forbid certain commercial uses — verify before bundling.

---

## 4. Cloud APIs (runtime)

### When cloud is worth it

Use cloud only if the *fantasy* requires stronger language than a 1–4B local model and you accept **online dependency + ongoing cost + Steam payment modeling**.

Indie-budget models (verify live rate cards before launch; prices move):

| Tier (examples, 2026 public cards) | Typical use | Rough economics |
|---|---|---|
| OpenAI mini/nano class (e.g. GPT-5.4 mini/nano) | Short NPC turns, classification | Cents per long session if prompts are tiny |
| Claude Haiku-class | Safer defaults, dialogue | Similar; watch tokenizer inflation |
| Gemini Flash / Flash-Lite | Cheap multimodal crumbs | Often lowest $/token for volume |

**Order-of-magnitude cost sketch** (planning only):

- Authored system prompt ~800 tokens cached + 150 in / 80 out per turn.
- At mini-class rates (~$0.75 / $4.50 per MTok input/output as publicly listed for GPT-5.4 mini mid-2026), **~1,000 turns ≈ a few dollars of API**, not hundreds — *if* you cache and cap.
- Failure modes that kill indies: dumping full lore bible every turn, uncapped `max_tokens`, no caching, calling flagship models for “color text.”

**Steam requirement (official):** If live AI incurs per-use cost, you must **manage access for players** and collect payment via Steam-supported methods: bake into base price, microtransactions, subscription, or DLC for unlimited AI access ([Steamworks Content Survey FAQ](https://partner.steamgames.com/doc/gettingstarted/contentsurvey)).

**Hard engineering rule:** Never ship provider API keys in the client. Use a tiny authenticated proxy you control, with per-Steam-ID budgets and kill switches.

### Commercial NPC platforms

| Platform | Fit for solo $3–$8 game | Notes |
|---|---|---|
| **Inworld** | Prototype only for this price band | Credit plans from free → $25–$1,500/mo; cloud dependency |
| **Convai** | Same caution | Often cheaper indie tiers; still online |
| **NVIDIA ACE** | Interesting on RTX PCs; weak as sole path | On-device Game Agent SDK + UE5 plugins; Godot path = custom via Inferencing SDK / own glue |
| **DIY OpenAI-compatible** | Best control | Your prompts, your fallback, your cost dial |

For this repo’s price band: **skip Inworld/Convai as launch dependencies.** Revisit only if a later higher-priced title centers AI characters.

---

## 5. Procedural generation vs generative AI

Keep the classic distinction:

| Approach | Strength | Weakness |
|---|---|---|
| **Seeded PCG** (WFC, grammars, BSP, particle sims) | Deterministic, testable, offline, cheap | Needs handcrafted modules for meaning |
| **LLM “generate a level”** | High novelty demos | Brittle, hard to QA, slop risk |
| **Hybrid** | LLM/diffusion proposes layouts → PCG + designer constraints instantiate | Best of both if validation is strict |

2026 research and studio practice converge on the same rule: **AI guides structure; code and authored pieces execute it.** Mix handcrafted set pieces into random bases so emotional beats survive.

For Game 1 (tension vignette): prefer **authored rooms + modifier decks + seeded item/order randomization**. Save LLM for antagonist lines and rumor slips, not geometry.

---

## 6. Diffusion & material pipelines (pre-production, not runtime)

**ComfyUI** is the indie production standard for reproducible image graphs (JSON workflows in git). Typical 2026 pipeline:

1. Style lock (palette board, few reference sheets, optional LoRA trained on *your* painted tiles).
2. Generate candidates (SDXL / FLUX-class / SD3.5 depending on VRAM).
3. ControlNet from blockouts / depth so output respects silhouettes.
4. Tileable textures → PBR decomposition (e.g. Ubisoft **CHORD** Comfy nodes for basecolor/normal/roughness/metalness).
5. **Human edit** in Krita/Aseprite/Photoshop; reject AI tells.
6. Import to Godot; bake atlases.

**VRAM guidance:** 8 GB = workable turbo pipelines; 12–16 GB = comfortable ControlNet stacks; 24 GB = luxury.

**Do not** run diffusion at runtime on player machines for a $3 vignette. Pre-generate, edit, ship. Runtime diffusion is a AAA/tech-demo tax (GPU, disk, moderation, Deck impossibility).

Steam disclosure: pre-generated AI art that ships is **Pre-Generated** genAI content — describe tools and human editing honestly.

---

## 7. Voice (STT / TTS)

| Stack | Quality | Cost | Offline | Solo fit |
|---|---|---|---|---|
| **Piper** (ONNX TTS) | Decent, fast | Free | Yes | Best default for local VO crumbs |
| **whisper.cpp / faster-whisper** | Good STT | Free | Yes | Optional voice commands / confession mic |
| **OpenAI TTS + Whisper API** | Good | ~$0.015/1K chars TTS class | No | Fine for trailers; risky in-game |
| **ElevenLabs** | Excellent emotion | ~$0.30/1K chars class | No | Marketing / hero lines only |
| **ACE Audio2Face / speech plugins** | High on NVIDIA path | SDK free; hardware/cloud varies | On-device RTX path | Skip for Godot Game 1 |

**Licensing gotcha:** Piper’s modern packaging has moved under GPL-oriented homes — confirm license compatibility with your commercial ship before bundling. Prefer MIT/Apache voices when in doubt, or commission a few lines of human VO for the antagonist (high inventiveness ROI).

**Horror vignette tip:** One great recorded antagonist voice + rare local TTS for “corrupted echoes” beats wall-to-wall neural speech.

---

## 8. Behavior trees + ML (the fun layer that must not die)

Classic game AI remains the spine:

- **Behavior Trees** — readable combat/ritual phases.
- **Utility AI** — weighted desires (pressure, mercy, greed).
- **GOAP / GOBT hybrids** — plan when BT strategy nodes need flexibility.
- **RL skills (optional)** — Unity ML-Agents style specialists; overkill for Game 1.

Hybrid patterns validated in 2025–2026 literature and practice:

1. **LLM as async planner** → BT/utility executes every frame.
2. **Mediated proposals** (Helper LLM + Reviewer/validator) before RL or BT acts.
3. **Hierarchical LLM planner + RL skills** — research shows believability gains without abandoning authored skills.

**Solo rule:** Build the BT until the game is fun with *zero* ML. Only then add a proposer that can swap line banks or utility weights within designer ranges.

---

## 9. NVIDIA ACE (what it means for indies)

ACE is a suite for speech, intelligence, and animation aimed at **middleware and game characters**, with:

- Cloud and on-device model paths
- **ACE Game Agent SDK** (C/C++, Agent/Chat/RAG APIs; open-source beta framing)
- **In-Game Inferencing (NVIGI)** for local model execution beside the renderer
- First-class **Unreal Engine 5** plugins (ASR, SLM, TTS) emphasized at NVIDIA events
- Optimization guidance: minimize inference calls so GPU isn’t stolen from frames

**Indie takeaway:**

- Excellent if you are Unreal + RTX-forward and AI companions are the product.
- **Poor default for this repo’s Godot + cheap vignette plan.**
- Revisit for a later higher-scope title or a NVIDIA tech co-marketing moment — not Game 1.

---

## 10. Costs (solo planning table)

| Budget item | Dev phase | Live ops (if any) |
|---|---|---|
| Godot 4 | $0 | $0 |
| ComfyUI + local GPU time | Electricity / your 3060–class card | $0 (prebaked) |
| Human VO (recommended) | $100–$800 for tight cast | $0 |
| Local SLM packaging | Time + download size | $0 runtime |
| Cloud LLM (optional mode) | Proxy hosting ~$5–$30/mo early | Must be priced into Steam SKU or DLC |
| Inworld/Convai | Avoid for v1 | Would dominate a $3 game’s margin |
| Steam fee | 30% after cut rules | — |
| Legal / disclosure hygiene | Your time | Support if survey changes |

**Margin intuition:** At $4.99, after Steam cut you keep roughly ~$3.50 before tax/refunds. A cloud companion that costs $0.10–$0.50 per heavily engaged player can erase profit. Hence: **offline default, cloud optional DLC**, or strictly capped free cloud tokens baked into price with a hard ceiling.

---

## 11. Privacy

| Data | Prefer |
|---|---|
| Chat logs, mic audio, “confession” text | Local-only processing; never train on player data without explicit opt-in |
| Telemetry for balancing | Anonymous, aggregated, settings toggle |
| Cloud LLM prompts | Strip PII; minimize retention on proxy; document in privacy policy |
| Save files | Local + Steam Cloud; no model fine-tune on saves |

Live AI that phones home should be **opt-in** in settings, with a clear store-page disclosure. Deck players in airplane mode are a first-class audience for short horror games — don’t punish them.

---

## 12. Steam Deck & offline requirements

**Product promises that matter:**

- Full single-player loop works **offline after first Steam auth launch**.
- No mandatory third-party launcher.
- Suspension/resume safe (Deck sleep): don’t hold brittle websocket AI sessions as the only dialogue path.
- Controllers: Steam Input defaults; readable UI at 1280×800.
- Optional AI packs: detect low RAM/thermal; auto-disable local SLM.

**Verified ≠ offline.** Deck Verified checks controls, glyphs, config — not your airplane-mode AI. Test airplane mode yourself.

If you mark `requires_internet_for_singleplayer`, expect lost Deck travelers and review complaints. For this catalog strategy: **do not require internet for Game 1.**

---

## 13. Steam ToS / Content Survey (AI) — compliance cheat sheet

Primary source: [Steamworks Content Survey](https://partner.steamgames.com/doc/gettingstarted/contentsurvey) (Valve wording, still current as of this research).

### What Valve cares about

Focus is **player-facing generative content**, not “I used Copilot.”

| Category | Meaning | Extra duty |
|---|---|---|
| **Pre-Generated** | AI-helped art/audio/narrative/etc. that ships | No illegal/infringing content; marketing consistency |
| **Live-Generated** | AI creates during gameplay | Describe **guardrails** against illegal content |

### Also true in practice (secondary analyses + Valve FAQ)

- Dev efficiency tools (Copilot-class) are not the survey’s focus after the **Jan 17, 2026** clarification wave.
- Disclosures appear publicly on the store page — write them for players, not just reviewers.
- Live Adult-Only Sexual Content via genAI is **not shippable** on Steam at this time (Valve FAQ).
- Live AI costs → monetize via price / MTX / sub / DLC (Valve FAQ).
- Surveys hard to edit post-approval — contact Support if AI usage changes.
- Copyright: purely AI assets may lack protectable authorship under USCO guidance — **human edit and document**.

### Guardrails worth listing in the survey

Be concrete:

1. Closed prompt templates (no free player→model jailbreak surface), or filtered player text.
2. Output schema validation; reject/retry; fallback lines.
3. Blocklists / classifier on output before display.
4. No web tool use from the in-game model.
5. Rate limits + max tokens.
6. Server-side moderation if cloud.
7. Disable live AI in modes that could produce disallowed content.

---

## 14. Engine comparison (solo, AI-aware)

| Concern | Godot 4 | Unity |
|---|---|---|
| License / store friction | Excellent | Acceptable; runtime fee history still scars some indies |
| Local LLM | Community GDExtensions (`llama.cpp`) | More mature packaging examples |
| ACE / NVIDIA demos | DIY | Better UE; Unity mid |
| ML-Agents / Sentis | Limited | Stronger |
| Deck / Linux export | Strong | Proton path usually fine |
| Fit for $3 vignette | **Best** | Heavier |

**Recommendation:** Stay on **Godot 4** for Games 1–3 as already planned. Use Unity only if a future title is AI-companion-first and needs Sentis/ACE ecosystem density.

---

## 15. Recommended architecture — first inventive game

Aligned with [`GAME_PLAN.md`](../GAME_PLAN.md): **Game 1 = original tension/horror vignette** (Buckshot-like *format*, not clone), $2.99–$7.99, Godot 4, Windows Steam + Deck-aware.

### Fantasy hook (systems, not mashup)

**One room, one ritual antagonist, escalating pressure.** The inventive AI angle is not “chat with an NPC forever.” It is:

> The antagonist *remembers how you cheat* and rewrites its taunts and table rules within a designer-owned modifier deck — so each player feels hunted personally, while every rule change remains a pre-authored, balance-tested card.

### Architecture: **Ritual Director** (fail-soft)

```
Player action
    → Ritual Director (deterministic)
         ├─ updates Pressure, Lies, Favors (structured memory)
         ├─ selects next RuleCard from authored deck (seeded + weighted)
         └─ requests Flavor (async, optional)
                ├─ Local SLM proposer (if enabled & healthy)
                ├─ else Template bank (persona × memory tags)
                └─ never blocks the next gameplay beat
Validation gate
    → allowed: substitute dialogue line, SFX tag, camera impulse
    → forbidden: invent new RuleCards, grant items, change odds silently
```

### Module breakdown

1. **Core loop (must ship fun alone)**  
   Readable stakes, short session (10–25 min), clip-friendly peaks, modifiers for replay. Pure Godot; BT for antagonist phases; utility for “when to apply pressure.”

2. **Memory blackboard**  
   Tags only: `lied_about_item`, `hesitated`, `asked_mercy`, `won_streak_3`. Survives saves. Drives both templates and SLM prompts.

3. **Flavor service interface**  
   `propose_line(context_snapshot) -> FlavorProposal | Error`  
   Implementations: `TemplateFlavor`, `LocalLlamaFlavor`, `CloudProxyFlavor` (optional DLC).

4. **Validation gate**  
   Length limits, banned topics, must reference at most N known tags, JSON schema, tone enum ∈ {mock, whisper, rage, calm}.

5. **Art**  
   Human-directed style; ComfyUI for texture/prop *drafts* only; heavy edit; limited palette; no runtime gen.

6. **Audio**  
   Commissioned antagonist VO for key lines; Piper optional for echoes; silence/music stings as fallback.

7. **Settings**  
   `AI Flavor: Off | Local | Cloud (DLC)` default **Local if capable else Off** (templates). Explicit privacy copy.

8. **Steam**  
   Disclose Pre-Generated (edited diffusion textures if any) and Live-Generated (if Local/Cloud flavor on). List guardrails. Prefer baking any cloud cost into a small **“Adaptive Antagonist” DLC** rather than base-game always-online.

### Why this is inventive *and* safe

- **Shapes around the user:** memory tags + weighted RuleCards + personalized taunts.
- **Fun if AI fails:** RuleCards and templates are the real game; AI only costumes them.
- **Not slop:** antagonist voice and rules are authored; model cannot invent win conditions.
- **Deck/offline:** default path never calls the network.
- **Solo-sized:** one GDExtension or even pure templates for v1; add local SLM after vertical slice fun exists.

### Explicit non-goals for Game 1

- Full conversational companion open world  
- Runtime diffusion  
- Inworld/Convai dependency  
- NVIDIA ACE requirement  
- Always-online DRM for AI  

### Build order

1. Lock original ritual premise + win/lose (user confirm lane).  
2. Vertical slice with **templates only**.  
3. Playtest fun.  
4. Add memory → template selection.  
5. Optional `llama.cpp` SLM behind the same interface.  
6. Steam page + Content Survey draft with real guardrail text.  
7. Deck airplane-mode QA.  
8. Only then consider Cloud DLC.

---

## 16. What to use on Games 2–3 (preview)

| Product | AI role |
|---|---|
| **Game 2 — Coin machine** | Almost none at runtime; Comfy for cabinet art drafts; classic physics AI |
| **Game 3 — Idle particle tycoon** | Zero runtime LLM; maybe offline name-gen for particle types during production |

Do not carry live LLM complexity into physics toys unless it is the marketing pillar.

---

## 17. Risk register

| Risk | Mitigation |
|---|---|
| Review bombing on AI disclosure | Make AI optional; lead marketing on *rules fantasy*, not “powered by GPT” |
| Model license / provenance rejection | Prefer permissively licensed weights; document tool chain |
| Deck thermals | Rare inference; CPU Q4 tiny models; auto-off |
| Scope creep into chatbot | Hard interface: FlavorProposal cannot touch rules |
| Proxy bill shock | Budgets per Steam ID; kill switch; DLC gate |
| Slop art backlash | Palette bible + human pass mandatory |

---

## Sources

### Primary / official

1. Valve — [Steamworks Content Survey](https://partner.steamgames.com/doc/gettingstarted/contentsurvey) (Generative AI section, live-AI monetization FAQ, Adult-Only + live AI prohibition).  
2. NVIDIA — [ACE for Games](https://developer.nvidia.com/ace-for-games) (Game Agent SDK, In-Game Inferencing, UE5 plugins).  
3. NVIDIA Technical Blog — [On-device AI companions / ACE Game Agent SDK](https://developer.nvidia.com/blog/build-on-device-ai-companions-with-the-nvidia-ace-game-agent-sdk-and-unreal-engine-5-plugins/).  
4. NVIDIA Technical Blog — [Minimize game runtime inference costs](https://developer.nvidia.com/blog/how-to-minimize-game-runtime-inference-costs-with-coding-agents/).  
5. OpenAI — [API Pricing](https://developers.openai.com/api/docs/pricing).  
6. ggml-org — [llama.cpp](https://github.com/ggml-org/llama.cpp) (GGUF local inference).  
7. Inworld — [Billing / plans](https://dev.docs.inworld.ai/portal/billing).  
8. ComfyUI / Ubisoft La Forge — [CHORD PBR material release](https://blog.comfy.org/p/ubisoft-open-sources-the-chord-model).

### Secondary (industry, legal, practice)

9. Zachary Strebeck / Legal Moves — [Steam AI Policy: What Every Game Developer Needs to Know](https://legalmoveslawfirm.com/steam-ai-policy/) (Jan 17, 2026 rewrite discussion; disclosure mechanics).  
10. VGC — [Valve significantly rewritten Steam AI disclosure rules](https://www.videogameschronicle.com/news/valve-has-significantly-rewritten-steams-rules-for-how-developers-much-disclose-ai-use/).  
11. StraySpark — [AI Slop in Game Development](https://www.strayspark.studio/blog/ai-slop-game-development-using-ai-responsibly).  
12. StraySpark — [ComfyUI for Game Asset Pipelines (2026)](https://www.strayspark.studio/blog/comfyui-game-asset-pipeline-indie-2026).  
13. Althera Games — [AI Asset Pipeline 2026: SD + ComfyUI](https://altheragames.com/en/blog/ai-asset-pipeline-stable-diffusion-ue5).  
14. GamineAI — [LLM NPC dialogue with hard fallback (Unity/Godot 2026)](https://gamineai.com/blog/your-first-llm-npc-dialogue-system-hard-fallback-net-unity-godot-2026-beginner-build).  
15. Michael Tiller — [LlamaBrain architecture](https://metagrue.com/llamabrain/) (untrusted proposer / validation gate).  
16. Bilawal Hameed — [Running LLMs on a Steam Deck](https://bilawal.net/running-llms-on-steam-deck.html).  
17. PromptQuorum — [Local voice stack 2026: Whisper + LLM + Piper](https://www.promptquorum.com/power-local-llm/build-local-voice-assistant-2026).  
18. Summer Engine — [AI Procedural Generation for Games (2026)](https://www.summerengine.com/blog/ai-procedural-generation-for-games).

### Academic / hybrid AI

19. HeRoN — mediated RL–LLM NPC framework, *Neural Computing and Applications* (2026).  
20. Hierarchical Control: LLM planning + RL execution (alphaXiv 2606.20014, 2026).  
21. GOBT — Goal-Oriented Behavior Trees (BT + GOAP + utility).  
22. BuildingBlock — hybrid diffusion/LLM + PCG for structured generation (arXiv 2505.04051).  
23. CreativeGame — mechanic-aware iterative game generation (arXiv 2604.19926).

### Godot local LLM projects (integration references)

24. [xarillian/GDLlama](https://github.com/xarillian/GDLlama)  
25. [mgrigajtis/godot_llama](https://github.com/mgrigajtis/godot_llama)  
26. [Adriankhl/godot-llm](https://github.com/Adriankhl/godot-llm)  
27. [lobinuxsoft/OhMyDialogSystem](https://github.com/lobinuxsoft/OhMyDialogSystem)

### Repo-internal

28. [`docs/GAME_PLAN.md`](../GAME_PLAN.md) — multi-game pure-category plan.  
29. [`docs/research/CATEGORY_RANKING.md`](CATEGORY_RANKING.md) — category scores and comps.

---

## Appendix A — One-page decision card (print this)

- **Runtime AI default:** Off/templates; optional local SLM; cloud only as DLC.  
- **Authority:** Game state + RuleCards.  
- **Proposer:** Schema-bound flavor.  
- **Art AI:** Offline Comfy + human edit only.  
- **Voice:** Human hero lines; Piper optional.  
- **Deck:** Airplane mode = full game.  
- **Steam survey:** Honest Pre/Live text + concrete guardrails.  
- **First vertical slice:** Zero model dependency.  
- **Inventiveness metric:** “Player feels remembered” via blackboard + rules, not via chatbot length.

---

*Compiled August 2026 for cmp07/Game-. Prices and vendor SKUs change; re-check OpenAI/Anthropic/Google/Inworld rate cards and Steamworks survey text before store submission.*
