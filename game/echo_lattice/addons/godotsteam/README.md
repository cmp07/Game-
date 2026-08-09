# GodotSteam (optional — not vendored)

Echo Lattice keeps GodotSteam **out of git** by default. The offline stub in
`scripts/steam/` is the CI / itch / editor path. Install the GDExtension locally
(or in a private release builder) only when bringing up real Steamworks.

**Do not commit Valve `steam_api` redistributables without license review.**

Full install + pin steps: [`docs/RELEASE/GODOTSTEAM.md`](../../../../docs/RELEASE/GODOTSTEAM.md).

## Expected layout after install

```text
game/echo_lattice/addons/godotsteam/
  README.md                 # this file (committed)
  godotsteam.gdextension    # from GodotSteam release matching Godot 4.3.x
  win64/ … linuxbsd/ …      # platform binaries (gitignored)
  # plus steam_api64.dll / libsteam_api.so beside exports when required
```

After install, open the project once in the Godot 4.3 editor so the `Steam`
singleton / ClassDB entry registers, then set `steam_enabled: true` only on
Steam-branded export presets (`custom_features` may include `steam`).
