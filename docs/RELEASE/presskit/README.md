# Echo Lattice — Presskit

Drop-in structure for journalists, creators, and Steam page production.  
Zip this folder (plus rendered capsules when ready) as `EchoLattice_Presskit.zip`.

```
presskit/
├── README.md                 ← you are here
├── factsheet.md              ← copy/paste boilerplate
├── images/
│   ├── screenshots/          ← stills (symlink or copy from docs tour)
│   ├── capsules/             ← Steam capsule masters (header / library / small)
│   ├── logos/                ← wordmark + icon lockups
│   └── gif_sequences/        ← frame packs for GIFs / Shorts
│       ├── 01_rewrite_slam/
│       ├── 02_habit_trail/
│       └── 03_before_after/
├── trailers/                 ← finished mp4/webm + poster frames
└── keys_and_contact.md       ← key policy + contact (do not commit live keys)
```

## Regenerate GIF frame packs

```bash
export PATH="$HOME/bin:$PATH"   # Godot 4.3
./game/echo_lattice/tools/capture_press_gifs.sh
```

Stills for the store page can also be pulled from `docs/ECHO_LATTICE/screenshots/v2_complete/`.

## Do / don’t for third parties

- **Do** show the rewrite slam; it is the product.
- **Do** keep Field Ledger colors (paper bone, ink, rust).
- **Don’t** add neon purple, bloom, or “mystical void” thumbnails.
- **Don’t** spoil Act IV Nameplate solutions in thumbnails.
