# Gate A — Steam Partner legal pack

**Product:** Echo Lattice  
**Lane:** RC1 Coming Soon (Gate A)  
**AppID:** `YOUR_APP_ID` — **do not invent**; paste only after Steamworks creates the app  
**Status:** Paste-ready Partner answers + hostable privacy page  
**Source of truth for product facts:** [`../COMPLIANCE_FINAL.md`](../COMPLIANCE_FINAL.md)

This folder is the **Partner paste pack** for Gate A items that are documentation-only (survey, AI disclosure, privacy URL content, ratings notes). Capsules, trailer, and real AppID remain separate Gate A blockers.

---

## Files

| File | Paste into |
|---|---|
| [`STEAM_CONTENT_SURVEY.md`](STEAM_CONTENT_SURVEY.md) | Steamworks → App Admin → **Content Survey** (General + Mature) |
| [`AI_DISCLOSURE.md`](AI_DISCLOSURE.md) | Content Survey → **Generative AI** + store/public one-liner |
| [`PRIVACY_POLICY.md`](PRIVACY_POLICY.md) | Host as HTTPS page → Steam store **Legal → Privacy policy URL** |
| [`RATINGS_NOTES.md`](RATINGS_NOTES.md) | Age rating / IARC expectation notes; store consistency checks |

---

## Partner paste order (Gate A)

1. Create the Steam app in Partner → receive real AppID (replace every `YOUR_APP_ID` / `YOUR_DEMO_APP_ID` / depot tokens — see [`../APPID_PLACEHOLDER_GATES.md`](../APPID_PLACEHOLDER_GATES.md)).
2. Fill **Content Survey** from [`STEAM_CONTENT_SURVEY.md`](STEAM_CONTENT_SURVEY.md).
3. Fill **Generative AI** section from [`AI_DISCLOSURE.md`](AI_DISCLOSURE.md) → all **No**.
4. Replace `[LEGAL_*]` in [`PRIVACY_POLICY.md`](PRIVACY_POLICY.md), host HTTPS, link on store Legal.
5. Confirm ratings expectation from [`RATINGS_NOTES.md`](RATINGS_NOTES.md) matches capsules / trailer / copy (E / PEGI 3 band; no horror / AI / loot lead).

---

## Hard rules

| Rule | Why |
|---|---|
| **No fake AppID** | Partner is source of truth; inventing IDs breaks achievements / depots / wishlist |
| **No Spacewar `480` in retail** | Dev-only; fail-closed in shipping builds |
| **Do not invent mature content** | Survey must match the playable puzzle build |
| **Do not market as AI / horror** | Product is deterministic habit→geometry puzzle |
| Keep `[LEGAL_ENTITY_NAME]` / `[LEGAL_CONTACT_EMAIL]` until studio paperwork lands | Privacy + store Legal require a real entity |

---

## Related

| Doc | Role |
|---|---|
| [`../COMPLIANCE_FINAL.md`](../COMPLIANCE_FINAL.md) | Full compliance pack (credits, depot notices, checklist C1–C12) |
| [`../STEAM_STORE_FINAL.md`](../STEAM_STORE_FINAL.md) | Store copy + Coming Soon checklist |
| [`../APPID_PLACEHOLDER_GATES.md`](../APPID_PLACEHOLDER_GATES.md) | AppID / DepotID placeholder ship gates |
| [`../../AUDIT/ULTRA_AUDIT_RC1.md`](../../AUDIT/ULTRA_AUDIT_RC1.md) | Gate A definition |

---

*Last updated: 2026-08-09 — Gate A Partner legal pack; AppID still placeholder.*
