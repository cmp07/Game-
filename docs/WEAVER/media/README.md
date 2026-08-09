# The Weaver — media

Gameplay photo pack for the Shed Yard teaching loop (hosted on Echo Lattice).

| Path | Role |
|---|---|
| [`photos/`](photos/) | 1920×1080 stills — menu/yard enter → gather → combine → weave → emit → wider yard |
| [`../screenshots/`](../screenshots/) | Legacy 1280×720 (or recaptured) void / structure pair |

**Gallery with embeds + raw URLs:** [`../VIEW_SCREENSHOTS.md`](../VIEW_SCREENSHOTS.md)

## Regenerate

```bash
# Requires Godot 4.3 + xvfb-run. Pull LFS fonts first if latin faces are pointers.
git lfs pull --include "game/echo_lattice/fonts/**"
GODOT=/path/to/Godot_v4.3-stable_linux.x86_64 \
  ./game/echo_lattice/tools/capture_weaver_photos.sh
```

Standalone twin (title + field, writes the same `photos/` folder):

```bash
xvfb-run -a godot --path game/weaver -- --photos
```
