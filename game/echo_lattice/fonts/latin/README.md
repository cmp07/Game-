# Latin fonts (IBM Plex)

| File | Role |
|---|---|
| `OFL.txt` | SIL Open Font License 1.1 (IBM Plex) |
| `IBMPlexSansCondensed-Bold.ttf` | Display / brand — `ECHO LATTICE` |
| `IBMPlexSansCondensed-Medium.ttf` | UI actions — Field Index rows |
| `IBMPlexSansCondensed-SemiBold.ttf` | Display fallback |
| `IBMPlexSansCondensed-Regular.ttf` | Action fallback |
| `IBMPlexSerif-Regular.ttf` | Body — blurbs, settings, captions |
| `IBMPlexMono-Regular.ttf` | Mono — seed header, punch-card labels |

Loaded at runtime by `scripts/ledger_type.gd` (autoload `LedgerType`).

## Fetch / refresh

Source faces also live under `tools/fonts/` for Bold/Medium. Full family:

```bash
python3 tools/fonts/fetch_ibm_plex_latin.py
```

Source: [IBM/plex](https://github.com/IBM/plex) complete TTF packages. Latin faces are small enough to commit for Steam/Deck embeds (unlike CJK).
