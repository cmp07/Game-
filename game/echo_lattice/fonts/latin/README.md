# Latin fonts (IBM Plex)

| File | Role |
|---|---|
| `OFL.txt` | SIL Open Font License 1.1 (IBM Plex) |
| `IBMPlexSansCondensed-Bold.ttf` | Display — brand lockup (preferred) |
| `IBMPlexSansCondensed-SemiBold.ttf` | Display fallback |
| `IBMPlexSansCondensed-Medium.ttf` | Action — Field Index rows (MENU_TYPE_SYSTEM) |
| `IBMPlexSansCondensed-Regular.ttf` | Action / display fallback |
| `IBMPlexSerif-Regular.ttf` | Body — blurbs, settings, captions |
| `IBMPlexMono-Regular.ttf` | Mono — seed header, meta, punch-card labels |

Loaded at runtime by `scripts/ledger_type.gd` (autoload `LedgerType`).

## Fetch / refresh

```bash
python3 tools/fonts/fetch_ibm_plex_latin.py
```

Source: [IBM/plex](https://github.com/IBM/plex) complete TTF packages. Latin faces are small enough to commit for Steam/Deck embeds (unlike CJK).
