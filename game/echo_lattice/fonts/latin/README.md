# Latin fonts (IBM Plex)

| File | Role |
|---|---|
| `OFL.txt` | SIL Open Font License 1.1 (IBM Plex) |
| `IBMPlexSansCondensed-SemiBold.ttf` | Display — brand, chamber titles |
| `IBMPlexSansCondensed-Regular.ttf` | UI actions / index underlines |
| `IBMPlexSerif-Regular.ttf` | Body — blurbs, settings, captions |
| `IBMPlexMono-Regular.ttf` | Mono — seed header, punch-card labels |

Loaded at runtime by `scripts/type_kit.gd` (autoload `TypeKit`).

## Fetch / refresh

```bash
python3 tools/fonts/fetch_ibm_plex_latin.py
```

Source: [IBM/plex](https://github.com/IBM/plex) complete TTF packages. Latin faces are small enough to commit for Steam/Deck embeds (unlike CJK).
