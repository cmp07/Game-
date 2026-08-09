# Privacy Policy — Echo Lattice

**Last updated:** 2026-08-09  
**Contact:** `[LEGAL_CONTACT_EMAIL]`  
**Publisher / developer:** `[LEGAL_ENTITY_NAME]`  
**Steam AppID:** `YOUR_APP_ID` *(assigned by Steamworks Partner — do not invent; omit from the public page until real)*  

> **Hosting note (Gate A):** Publish this page at a stable HTTPS URL, then paste that URL into Steamworks → Edit Store Page → **Legal → Privacy policy**. Replace every `[LEGAL_*]` token before the page goes public. This markdown is the hostable page body.

---

## Summary

Echo Lattice is a single-player offline puzzle game. We do not operate online accounts for the game, and the game does not upload gameplay analytics to our servers.

---

## Data stored on your device

The game may write the following locally under the Godot user data folder (`user://`):

1. **Save progress and settings** (for example `save.json` and settings files).
2. **Optional local balance telemetry** as an append-only log  
   (`telemetry/echo_lattice_balance.jsonl`) containing chamber IDs, seeds, move counts, star ratings, softlock diagnostics, and similar gameplay metrics. This log is intended for offline tuning.

This local telemetry:

- does **not** include your name, email, or Steam account identifier (`include_pii: false`);
- is **not** uploaded by the shipping game build;
- may be disabled in Settings when the telemetry toggle is present.

Crash / diagnostic logs, when enabled, follow the same local-first contract: disk only unless you explicitly opt in to a future upload path (off by default; not required for play).

---

## Steam

If you play through Steam, Valve may collect data under the [Steam Subscriber Agreement](https://store.steampowered.com/subscriber_agreement/) and [Steam Privacy Policy](https://store.steampowered.com/privacy_agreement/). Achievements, Steam Cloud (if enabled later for **saves**), and other Steam features are provided by Steam and governed by Valve’s terms.

We do **not** sync local telemetry JSONL to Steam Cloud. If Cloud is enabled for saves, telemetry paths remain excluded.

---

## No selling of data · no ad SDKs

We do not sell personal information. The shipping game build does not include third-party advertising or analytics SDKs.

---

## Your choices

- Delete local saves and telemetry by removing the game’s user data folder.
- Disable local telemetry in Settings when that toggle is present.
- Uninstalling the game removes the install directory; user data may remain until deleted manually.

---

## Children

The game is suitable for a general audience and does not knowingly collect personal information from children.

---

## Changes

We will update this policy if we add network telemetry, accounts, or Cloud sync of analytics. Material changes will be noted by the **Last updated** date above and on the Steam store page.

---

## Contact

Privacy questions: `[LEGAL_CONTACT_EMAIL]`  
Publisher: `[LEGAL_ENTITY_NAME]`

---

## Partner / ship checklist (not for public page)

Strip this section before hosting, or keep it only in-repo.

- [ ] Replace `[LEGAL_ENTITY_NAME]` and `[LEGAL_CONTACT_EMAIL]`
- [ ] Host at stable HTTPS (GitHub Pages / studio site)
- [ ] Link URL on Steam store Legal section
- [ ] Confirm retail build never opens sockets for telemetry
- [ ] Exclude `user://telemetry/**` from Steam Cloud path rules if Cloud is enabled for saves
- [ ] Leave AppID as `YOUR_APP_ID` in-repo until Partner assigns a real ID — **never invent one**
