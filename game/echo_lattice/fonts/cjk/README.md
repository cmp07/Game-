# CJK fonts (`zh_Hans`)

| File | Role |
|---|---|
| `OFL.txt` | SIL Open Font License 1.1 (Noto Sans CJK / Source Han Sans family) |
| `NotoSansSC-Regular.otf` | Runtime face loaded by `LocaleManager` — **not committed** (gitignored) |
| `.gitkeep` | Keeps the directory in git |

## Fetch (local / CI / export)

```bash
python3 tools/fonts/fetch_noto_sans_sc.py
```

Downloads the OFL-licensed **Noto Sans SC Regular** subset from the
[notofonts/noto-cjk Sans 2.004](https://github.com/notofonts/noto-cjk/releases/tag/Sans2.004)
release into this directory. License allows embedding in a commercial Steam build.

## Git LFS (optional ship path)

Binaries are large (~tens of MB) and stay gitignored until the team opts in:

```bash
git lfs install
git lfs track 'game/echo_lattice/fonts/cjk/*.otf' 'game/echo_lattice/fonts/cjk/*.ttf'
# Remove the matching ignore rules in the repo root .gitignore, then:
git add .gitattributes game/echo_lattice/fonts/cjk/NotoSansSC-Regular.otf
```

`.gitattributes` already lists the LFS patterns so enabling LFS is one ignore-edit away.
Depot / CI may also call the fetch script at export time instead of committing the face.
