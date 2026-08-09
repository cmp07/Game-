# Multi-platform release strategy

**Product:** Echo Lattice (and future catalog titles in this repo)  
**Engine:** Godot 4.3 desktop exports  
**Bar:** Top-publisher quality on store presentation, build hygiene, and honest scope — not “ship everywhere day one.”

Companion: [`CI_BUILDS.md`](CI_BUILDS.md) · Export presets: [`game/echo_lattice/export_presets.cfg`](../../game/echo_lattice/export_presets.cfg)

---

## Store priority

| Store | Role | When |
|---|---|---|
| **Steam** | **Primary** storefront, discovery, reviews, Steam Deck | Day-one launch target |
| **itch.io** | Secondary; DRM-free / press / tip-jar adjacent | Same-week or shortly after Steam |
| **GOG** | Optional DRM-free catalog | After Steam reviews stabilize; apply when pitch fits |
| **Epic Games Store** | Optional reach / exclusivity deals only if terms justify | Opportunistic; never block Steam |

**Rule:** Steam page, capsules, demo, and review velocity fund the rest. Do not dilute launch week across four storefronts unless ops capacity is already proven.

---

## Steam (primary)

- Windows `.exe` + `.pck` is the launch binary; Linux native + macOS follow as soon as CI signs off (see build matrix).
- Wire Steamworks only when features need it (achievements, Cloud, overlay). Until then, keep builds store-agnostic and inject Steam via a `steam` custom feature / GDExtension later.
- **Demo** ships on Steam before or with paid launch; itch can mirror the demo zip.
- Capsule / trailer briefs live in [`docs/ECHO_LATTICE/05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md) §7.

### Steam Deck

| Item | Policy |
|---|---|
| **Primary path** | Native **Linux/X11** `x86_64` build verified on Deck (or Deck-like Proton/Linux CI smoke) |
| **Fallback** | Windows build under Proton — acceptable for Verified/Playable chase, not the preferred shipping artifact |
| **Controls** | Full keyboard path required; gamepad map for move / undo / restart / pause before claiming Deck support |
| **Display** | 1280×800 native-friendly; UI must remain legible at Deck default scale (no unreadably small text) |
| **TDP / thermals** | 2D puzzle load is light; still profile 30/60 FPS caps and battery idle on title screen |
| **Deck Verified** | Target **Playable → Verified** after input glyphs, no forced keyboard text entry, and suspend/resume smoke |

Steam Deck is **in scope for desktop launch**, not a console port. Treat Deck QA as a release checklist item, not a separate SKU.

---

## itch.io

- Same content version as Steam when possible; **DRM-free** packaging differences below.
- Useful for journalists, bundle partners, and players who refuse store DRM.
- Page copy can be shorter; still reuse Steam screenshots and trailer.

### DRM-free itch build differences

| Concern | Steam build | itch DRM-free build |
|---|---|---|
| Store SDK | Steamworks optional / feature-flagged | **No** Steamworks, no overlay stub |
| `custom_features` | May include `steam` when integrated | Prefer `itch` (or omit); never require Steam API |
| Encryption | `encrypt_pck` stays **false** unless a real piracy plan exists | Same — itch buyers expect inspectable installs |
| Installer | Steam content pipeline | Zip / butler push; no installer required |
| Autoupdate | Steam | itch app / butler; document manual zip fallback |
| Achievements / Cloud | Steam APIs when ready | Local save only (or itch-agnostic cloud later) |
| Branding | “Available on Steam” OK in-game | Avoid Steam-only CTAs in the itch binary |
| Pricing | Steam regional matrix | Often match USD list; itch allows pay-what-you-want *only* if intentional |

Ship itch from the **same Godot presets** (Win / Linux / macOS) with store-specific packaging scripts, not a fork of the game project.

---

## GOG (optional)

- Strong DRM-free brand fit; Galaxy SDK is optional and usually skippable for a vignette.
- Expectation: polished store page, Windows first, Linux/macOS if already maintained for Steam.
- Cost is mostly **ops + QA + page production**, not engine work. Gate on: Steam ≥ Mixed/Positive, support load under control, and one person owning GOG builds for a patch cycle.

---

## Epic Games Store (optional)

- Only pursue with a clear distribution reason (featuring, co-marketing, or funded deal).
- EOS / launcher integration is non-trivial relative to itch/GOG for a small team.
- **Do not** accept timed Steam exclusivity that blocks the primary store unless cash + marketing clearly covers the discovery loss.

---

## Future consoles (Switch / Xbox / PlayStation)

Honest scope: **not a solo Godot export**. Consoles mean port partners, platform NDAs, certification (Lotcheck / TRC / XR), first-party accounts, and different input/storage/TRC constraints.

| Platform | Typical path | Order-of-magnitude cost* | Notes |
|---|---|---|---|
| **Nintendo Switch / Switch 2** | Port house + Nintendo lease | Mid five-figures to low six-figures USD per SKU (port + cert + first submission), plus hardware / mid-mort | Godot console support is partner/engine-dependent; plan for renderer and performance work |
| **Xbox (PC Game Pass / console)** | ID@Xbox + port partner or self if experienced | Similar band; Game Pass deals change economics | PC Xbox Store is closer to desktop; console still certs |
| **PlayStation (PS4/PS5)** | Port house almost always | Often the **highest** cert + middleware friction for indies | Budget partner time in months, not a patch week |

\*Ballpark for a **small** 2D game with an experienced porting house — not a quote. Marketing, localization, QA passes, and resubmissions add more. A “top publisher” console launch is a **separate project** funded after PC proof.

**Policy until funded:** Document console interest on the Steam page (“console versions being explored”) only if a partner conversation is real. Do not promise dates.

---

## Godot build matrix

Presets in `game/echo_lattice/export_presets.cfg`:

| Preset name | Platform | Arch | Output (relative to project) | Status |
|---|---|---|---|---|
| `Windows Desktop` | Windows Desktop | `x86_64` | `builds/windows/EchoLattice.exe` (+ `.pck`) | **Shipping primary** |
| `Linux/X11` | Linux/X11 | `x86_64` | `builds/linux/EchoLattice.x86_64` | **Stub → Deck / Steam Linux** |
| `macOS` | macOS | `universal` | `builds/macos/EchoLattice.zip` | **Stub** (unsigned; notarize before public mac) |

Shared export choices (all desktop presets):

- Godot **4.3** export templates (`4.3.stable`)
- `export_filter = all_resources`
- `encrypt_pck = false` (DRM-free friendly; revisit only with a real threat model)
- PCK **not** embedded on Win/Linux (smaller Steam depots / easier patch diffs)
- `application/modify_resources = false` on Windows so CI does not require `rcedit`

### Headless export commands

```bash
cd game/echo_lattice
godot --headless --export-release "Windows Desktop" builds/windows/EchoLattice.exe
godot --headless --export-release "Linux/X11"       builds/linux/EchoLattice.x86_64
godot --headless --export-release "macOS"           builds/macos/EchoLattice.zip
```

macOS public distribution still needs Apple Developer signing + notarization (credentials via env vars / CI secrets — see [`CI_BUILDS.md`](CI_BUILDS.md)). The committed preset intentionally leaves codesign/notarization **disabled** so Linux CI can validate the preset parses without certificates.

---

## Store asset reuse matrix

Produce once; crop/re-export per store. Master briefs: Art Bible §7.

| Asset | Master size | Steam | itch | GOG | Epic |
|---|---|---|---|---|---|
| Header / page banner | 460×215 (+ 2× master) | Header capsule | Page banner / header | Recrop to GOG banner | Recrop to EGS wide |
| Main capsule / cover | 616×353 | Main capsule | Cover image | Cover | Cover / portrait variants as required |
| Small capsule | 231×87 | Small capsule | Optional icon strip | — | — |
| Library hero | 3840×1240 | Library hero | Optional widescreen | Optional | EGS hero source |
| Vertical capsule | 374×448 (derive) | Vertical | — | Sometimes | Sometimes |
| Icon | 256×256+ | Client icon | Favicon / cover corner | Icon | Icon |
| Screenshots | ≥1920×1080, 5–8 shots | Store screenshots | Same set | Same set | Same set |
| Trailer | 1080p or 4K, ≤30–60s cut | Steam trailer | YouTube / embed | Same file | Same file |
| Logo lockup | SVG + PNG | Capsules + page | Page | Page | Page |

**Reuse rule:** Do not redesign per store — only meet minimum dimensions and safe margins. Copy decks differ; key art does not.

---

## Pricing and regional notes

Catalog band for this repo: roughly **$0.99–$10** USD ([`GAME_PLAN.md`](../GAME_PLAN.md)). Echo Lattice tension-vignette lane: about **$2.99–$7.99** USD recommended.

| Region / channel | Guidance |
|---|---|
| **USD (baseline)** | Pick a single list price; all regional prices derive from it |
| **EUR / GBP** | Use Steam’s recommended conversion; avoid psychological cliffs (e.g. €4.99 vs €5.69) without reason |
| **China (CNY / RMB)** | Set an explicit **人民币** price on Steam — do not leave USD-only conversion. For a ~$4.99 USD vignette, a common indie landing zone is roughly **¥18–¥28**; for ~$2.99, roughly **¥12–¥18**. Prefer a clean number (¥21 / ¥28) over exact FX. Revisit when Valve publishes updated regional recommendations |
| **CIS / LATAM / SEA** | Follow Steam regional recommendations; deep underpricing rarely buys reviews if wishlists are thin |
| **itch.io** | Match USD list by default; PWYW only as a conscious promo |
| **GOG / Epic** | Match Steam USD when possible; honor any funded deal constraints |
| **Launch discount** | ≤10–20% for week one is fine; avoid training the audience to wait for 50% |

Taxes, VAT display, and net revenue shares differ by store — model **net** revenue, not sticker price, when comparing itch vs Steam.

---

## Launch sequence (publisher-shaped)

1. Steam page + capsules + trailer + wishlist push  
2. Demo on Steam (and itch mirror)  
3. Win + Linux Steam build; Deck smoke  
4. Paid Steam launch  
5. itch DRM-free zips (same version)  
6. macOS once notarized  
7. GOG / Epic only if criteria above clear  
8. Consoles only with funded port partners  

---

## Related

- Vertical slice build notes: [`docs/ECHO_LATTICE/13_VERTICAL_SLICE_README.md`](../ECHO_LATTICE/13_VERTICAL_SLICE_README.md)  
- CI sketch: [`docs/RELEASE/CI_BUILDS.md`](CI_BUILDS.md)
