# Echo Lattice — Visual Tour

Seven screenshots taken from the playable Godot 4.3 vertical slice, ordered so
a stranger can follow the game from title screen to second chamber without
ever touching a keyboard.

Every image lives beside this file, under `docs/ECHO_LATTICE/screenshots/tour/`,
and was captured by driving the real game (menu, chamber loader, movement,
rewrite engine, win screen) through the `-- --screenshot` mode in
`game/echo_lattice/scripts/main.gd`. See
[How the screenshots were captured](#how-the-screenshots-were-captured) at
the bottom of this file for the exact commands.

---

## Art style, in one paragraph

Top-down, brutalist subway map. The floor is deep almost-black indigo
(`#0c0c11` background, `#181822`/`#1c1c27` tile parity so you can still see the
grid). Walls are a muted purple (`#3b3b52`). The two colours the eye actually
lands on are the game's identity beat: **teal** (`#57f2b0`) for the goal, and
**orange** (`#ff5c3d`) for anything the lattice has learned from you — your
last footsteps and the new echo walls that grew from them. Nothing is
textured; every tile, ring, and pulse is drawn as a solid rect in
`Chamber._draw()`, so the aesthetic is deliberately geometric and legible.

---

## 1 — Main menu

![01 main menu](tour/01_main_menu.png)

The title card. Big display type reads **ECHO LATTICE**; the tagline
underneath — *"A labyrinth that rebuilds from your last thirty moves."* — is
the same one from the pitch. Because no save file exists yet, the "Continue"
button is greyed out and the subtitle reads "A vertical slice — 10 chambers."
The keyboard cheat-sheet along the bottom is the only chrome; everything else
sits on the black canvas.

## 2 — Chamber I, first step

![02 chamber start](tour/02_chamber_start.png)

Chamber 1 of 10, titled **I. First Step**. The player (the small white
square, upper-left) has just spawned. The teal outlined square on the right is
the goal. The maze here is deliberately trivial — one wide open room split by
a thin wall — because the caption at the bottom reads *"Walk. Nothing here
learns you yet."* The HUD confirms **Moves: 0** and **Habit: unwritten**: the
labyrinth is not yet forming an opinion about you.

## 3 — Walking, leaving a trail

![03 walking trail](tour/03_walking_trail.png)

Chamber III, **III. It Learned You**. The player has taken ten steps south
then east, and the orange ghost trail behind the white square is exactly the
"last thirty moves" the tagline promises. The yellow ring in the middle of
the room is a checkpoint — cross it and the game will mirror this exact path
into new walls. The HUD tells you the game already has an opinion:
**Habit: right-leaning (60%)**. This is the "walking" beat: motion, breadcrumb,
tension.

## 4 — Rewrite moment (habit becomes wall)

![04 rewrite moment](tour/04_rewrite_moment.png)

Same chamber, a few tiles later. The player crossed the yellow checkpoint,
which triggered a **mirror-vertical** rewrite: the path they just walked is
reflected across the room's vertical axis and printed as new orange **echo
walls** on the right-hand side. Notice the checkpoint is now a small dim
dot (used) and the fresh orange squares fence off the goal in a mirrored
shape. That's the whole game in one image: *your habit is the level
designer*.

## 5 — Mid-run, a different transform

![05 mid chamber](tour/05_mid_chamber.png)

Chamber V, **V. Ceiling** — same idea, different axis. Here the transform is
`mirror_h`, so instead of copying the walked path across left-right, it
copies it across up-down. The player walked along the top of the room and
the game **stamped that same shape onto the floor** — the long orange bar
across the bottom plus the L-shape climbing up. It reads visibly like a
different rewrite grammar even though the mechanic is the same. Also note
**Habit: right-leaning (68%)**: the profile persists across chambers.

## 6 — Chamber cleared

![06 goal win](tour/06_goal_win.png)

The between-chamber beat. When the player steps onto the teal goal tile, the
scene transitions to this summary card: **Chamber Cleared**, the chamber's
title (*III. It Learned You*), moves this run, best ever, and the current
habit label. The teal accent bars at the top and bottom of the frame are the
"you did it" identity beat. Three buttons offer **→ Next Chamber**,
**Replay this chamber**, or **Menu**.

## 7 — Onward, into a two-checkpoint room

![07 next chamber](tour/07_next_chamber.png)

Chamber IV, **IV. Mirrors** — the room the game hands you after clearing
Chamber III. Two yellow checkpoints, two rewrites incoming, and a caption
that spells out the new tension: *"Two checkpoints, two rewrites. Vary your
route or wall yourself in."* Move counter is back to 0, habit shows
**unwritten** for this fresh run, and the room's shape (a long L-corridor
plus a mid-room diagonal wall) hints at the strategic decision the player
now has to make: which checkpoint first?

---

## What the parent can tell the kid

- The game is called **Echo Lattice**.
- You move a little white square around a dark grid. You are the square.
- The green outlined square is where you're trying to get.
- The yellow rings are "checkpoints" — when you touch one, **the game copies
  the path you just walked and turns it into orange walls**, somewhere else
  on the board. That's the whole trick. The maze rebuilds itself out of your
  habits.
- Different rooms copy your path in different ways — mirrored left-right,
  mirrored up-down, rotated, or solidified right where you walked.
- If you always turn right, the game notices. It literally puts that up on
  the top bar: *"Habit: right-leaning (67%)."*
- You can't die. If a copied wall would trap you, the game silently drops it
  (that's a safety net in the code). So it never feels random — it feels
  like the level is a slow argument with your muscle memory.
- The vertical slice has 10 chambers. The first two are quiet tutorials, then
  the rewrites start in Chamber III, and the mechanic escalates
  (`mirror_v`, `mirror_h`, `rotate_180`, `thicken`, then a combined double
  mirror) until the final signature room.

---

## How the screenshots were captured

The game ships with a headless screenshot mode inside its main scene. Every
image in `tour/` came from these exact commands:

```bash
# One-time — install Godot 4.3 stable and xvfb.
sudo apt-get install -y xvfb
curl -L -o /tmp/godot.zip \
  https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip
unzip /tmp/godot.zip -d /tmp/godot
chmod +x /tmp/godot/Godot_v4.3-stable_linux.x86_64
export GODOT=/tmp/godot/Godot_v4.3-stable_linux.x86_64

# Regenerate every tour screenshot in one go:
game/echo_lattice/tools/capture_tour.sh
```

Under the hood the script runs Godot inside a virtual X server:

```bash
xvfb-run -a -s "-screen 0 1152x672x24" \
  "$GODOT" --path game/echo_lattice -- \
  --screenshot <kind> --out <staging_dir>
```

`<kind>` is one of:

| kind | what it captures |
|---|---|
| `menu` | Main menu with a fresh (wiped) save so "Continue" is disabled |
| `chamber:N` | Chamber N as it looks the moment you enter it |
| `walk_only:N:S` | Chamber N with the player BFS-stepped toward the nearest checkpoint, stopping S tiles short — used for the ghost-trail shot |
| `rewrite:N` | Chamber N right after its rewrite fires, echo walls settled |
| `won:N` | The Chamber Cleared screen for chamber N |
| `end` | The end-of-slice summary screen |

The Godot process quits with exit code 0 after saving the PNG, so the shell
script can chain seven captures back-to-back and the whole tour regenerates
in about ten seconds on a cold VM. This is the same code path as normal
gameplay — no debug tiles, no gizmos, no editor overlay — so what you see is
what a player would see with the game running full-screen.
