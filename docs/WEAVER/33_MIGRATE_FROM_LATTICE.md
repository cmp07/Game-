# Weaver — Safe migration: Echo Lattice → archive

**Doc:** `docs/WEAVER/33_MIGRATE_FROM_LATTICE.md`  
**Status:** Plan only — **no tree move in this PR**  
**Mode:** Cloud-only durable docs  
**Peers:** [`PIVOT.md`](PIVOT.md) · [`ROADMAP.md`](ROADMAP.md) · [`14_TECH.md`](14_TECH.md) · [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md)

| Field | Value |
|---|---|
| **Goal** | Relocate frozen Echo Lattice into an explicit **archive** home so `game/` is clear for Weaver |
| **Non-goal** | Delete product history, rewrite git ancestry, invent AppIDs, or ship Weaver by editing EL in place |
| **Source tree** | `game/echo_lattice/` |
| **Target tree** | `archive/echo_lattice/` |
| **History rule** | Preserve blob + commit ancestry; use rename-aware moves (`git mv`) — never wipe-then-readd |
| **Authority today** | [`PIVOT.md`](PIVOT.md) still says **keep** `game/echo_lattice/` until a human-approved execute PR lands |

**One line:** Archive by **rename under git**, after durable tags and path rewrites — never by delete.

---

## 0. Verdict (read this first)

| Lock | Meaning |
|---|---|
| **Archive ≠ delete** | The playable Godot project, Steam freeze pack, RELEASE / AUDIT / BACKUP docs, and `steam/echo_lattice/` scaffolding remain in the repo (or on durable refs). |
| **Plan before move** | This document is the contract. An execute PR may run only after the gates in §6 are green. |
| **History-preserving move** | Prefer a single `git mv game/echo_lattice archive/echo_lattice` (plus follow-up path updates). Do **not** `rm -rf` + copy, orphan-branch import, or `git filter-repo` path strip unless a human explicitly supersedes this plan. |
| **Weaver stays separate** | New code lands in `game/weaver/` (or successor). Do not overwrite archived EL scenes to “bootstrap” Weaver. |
| **CI must move with the tree** | `.github/workflows/ci.yml` and `tools/release/*` path literals are part of the migrate PR, not a later cleanup. |

---

## 1. Why migrate

[`PIVOT.md`](PIVOT.md) froze Echo Lattice as the durable reference while Weaver became the north star. Keeping the Godot project at `game/echo_lattice/` was correct for the freeze wave. As Weaver prototypes arrive, that layout creates agent / human confusion:

| Pressure | Risk if ignored |
|---|---|
| `game/` looks like the live product | Agents edit EL “to save time” ([`ROADMAP.md`](ROADMAP.md) §4) |
| CI defaults to EL project path | Weaver exports / contracts never become the default green path |
| Docs say “frozen archive” but path still says `game/` | Mental model disagrees with filesystem |

Archiving under `archive/echo_lattice/` makes the freeze **legible in the tree** without discarding archaeology.

---

## 2. What moves vs what stays

### 2.1 Move (execute PR)

| From | To | Notes |
|---|---|---|
| `game/echo_lattice/` | `archive/echo_lattice/` | Entire Godot project; one `git mv` |
| (optional same PR) thin pointer | `game/README.md` or `game/.gitkeep` note | States live product → `game/weaver/`; EL → `archive/echo_lattice/` |

### 2.2 Stay in place (do not relocate in the first migrate)

| Path | Why |
|---|---|
| `docs/ECHO_LATTICE/` · `docs/ECHO_LATTICE_META.md` | Already docs archaeology; update links only |
| `docs/RELEASE/` · `docs/AUDIT/` · `docs/BACKUP/` · `docs/VISION/` | Steam pack + audits stay discoverable; rewrite path strings |
| `steam/echo_lattice/` | Depot templates are product-named scaffolding, not the Godot project |
| Branch + tag `backup/echo-lattice-rc1-steam-pack` | Pre-move durable freeze — **do not delete** |
| Integration line `cursor/echo-lattice-rc1` | Remains history + merge target until Weaver integration line is renamed in a later policy PR |

### 2.3 Explicitly forbidden

| Action | Why forbidden |
|---|---|
| Delete `game/echo_lattice/` without a rename commit | Loses easy `git log --follow` / blame continuity |
| `git filter-repo` / BFG to erase `game/echo_lattice` from all history | Rewrites SHAs; breaks freeze tags, PRs, and BACKUP tip pins |
| Force-push to `main` / RC1 to “clean” history | Destroys shared tips cited in BACKUP / PIVOT |
| Squash the migrate into an orphan commit that re-adds files | Treats archive as new content; blame goes dark |
| Mutate EL store copy into Weaver during the move | Separate product identity ([`PIVOT.md`](PIVOT.md) §3) |
| Invent Steam AppIDs while touching paths | Unchanged human-only Partner rule |

---

## 3. History-preserving procedure

### 3.1 Preflight (read-only)

Run on the integration tip **before** any move commit:

```bash
# Durable freeze still reachable
git rev-parse backup/echo-lattice-rc1-steam-pack
git merge-base --is-ancestor \
  5f0d46355abea0f5cd0f1da16c2e70c1eb717f55 HEAD

# Working tree clean; no partial EL edits mixed into migrate
git status --porcelain

# Baseline contract suite (current path)
python3 game/echo_lattice/tests/validate_chambers.py
# …or the CI job set that does not need a Godot binary
```

Record the pre-move tip SHA in the execute PR body.

### 3.2 Tag the last live-path tip

```bash
git tag -a archive/echo-lattice-pre-move -m \
  "Last tip with Godot project at game/echo_lattice/ (pre-archive migrate)"
git push origin archive/echo-lattice-pre-move
```

Keep existing `backup/echo-lattice-rc1-steam-pack` untouched. The new tag is a **path-layout** bookmark; the backup tag remains the **Steam pack** bookmark.

### 3.3 Rename (history-aware)

```bash
mkdir -p archive
git mv game/echo_lattice archive/echo_lattice
git commit -m "chore(archive): move Echo Lattice Godot tree to archive/echo_lattice"
```

Verification immediately after:

```bash
git log --follow --oneline -- archive/echo_lattice/project.godot | head
git log --diff-filter=R --summary -1
# Expect a rename, not delete+add, for the bulk of the tree
```

Notes:

- Git stores renames as delete+add with similarity; `git log --follow` and `git blame -C` remain the archaeology tools.
- Large binary churn can break rename detection — do **not** recompress or re-export assets in the same commit as the move.
- `.gitignore` / LFS rules that mention `game/echo_lattice` must be updated in the **same** execute PR.

### 3.4 Path rewrite pass (same execute PR or stacked PR)

Update literals that would otherwise 404 CI or docs. Priority order:

| Layer | Examples |
|---|---|
| **CI / tools (must)** | `.github/workflows/ci.yml` `PROJECT_PATH`; `tools/release/export_windows.sh`; capture / font helpers under `tools/` |
| **Steam staging (must if path-coupled)** | Any script that `cd`s into `game/echo_lattice` for export; keep `steam/echo_lattice/` depot names unless a later Steam PR renames them |
| **Weaver / BACKUP hubs (must)** | [`PIVOT.md`](PIVOT.md), [`README.md`](README.md), [`ROADMAP.md`](ROADMAP.md), [`../BACKUP/*`](../BACKUP/), [`14_TECH.md`](14_TECH.md) |
| **RELEASE / AUDIT / VISION (should)** | Path tables and shell one-liners; historical prose may keep old paths **only if** labeled “pre-archive path” |
| **In-project relative refs** | Prefer project-relative Godot paths; fix any absolute/`res://` assumptions that encoded the old repo-relative folder |

Suggested ripgrep gate (must return empty for *executable* refs before merge):

```bash
rg -n 'game/echo_lattice' \
  .github/workflows tools steam \
  docs/WEAVER docs/BACKUP \
  --glob '!docs/BACKUP/PATHS_INDEX.md'
```

`PATHS_INDEX.md` may keep the freeze-tip listing as a historical snapshot **if** the header states it describes pre-move layout on `backup/echo-lattice-rc1-steam-pack`.

### 3.5 Post-move verify

```bash
test -f archive/echo_lattice/project.godot
test ! -e game/echo_lattice

# Contracts at new path
python3 archive/echo_lattice/tests/validate_chambers.py

# History still walks past the rename
git log --follow --pretty=%h -- archive/echo_lattice/project.godot | wc -l
# Expect more than the single migrate commit

# Optional: confirm freeze tag tree still has the old path (immutable archaeology)
git ls-tree -d --name-only backup/echo-lattice-rc1-steam-pack:game | grep echo_lattice
```

### 3.6 Policy doc sync (same wave)

After the move merges, update the pivot lock language:

| Doc | Change |
|---|---|
| [`PIVOT.md`](PIVOT.md) | “Keep `game/echo_lattice/`” → “Keep `archive/echo_lattice/`; do not delete” |
| [`MASTER_GDD.md`](MASTER_GDD.md) · [`ROADMAP.md`](ROADMAP.md) · [`README.md`](README.md) | Path + agent policy rows |
| [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md) · [`KEY_PATHS.md`](../BACKUP/KEY_PATHS.md) | Live path vs freeze-tag path distinction |

Until that policy sync merges, agents must treat **this plan** as intent and **PIVOT** as the still-binding “do not delete” law.

---

## 4. Compatibility options (choose one in execute PR)

| Option | Mechanism | When to use |
|---|---|---|
| **A. Clean cut (default)** | Only `archive/echo_lattice/`; no symlink | Preferred — forces path honesty |
| **B. Pointer stub** | `game/echo_lattice/README.md` stating moved + link | If external notes still cite `game/echo_lattice/` |
| **C. Symlink** | `game/echo_lattice` → `../archive/echo_lattice` | **Avoid** on Windows/Steam export agents; last resort only |

Default for this studio: **A**, plus docs redirects. Do not commit a symlink unless a human explicitly requests Windows-safe verification.

---

## 5. Phased rollout

| Phase | Deliverable | Branch / PR pattern | Merges when |
|---|---|---|---|
| **M0 — Plan (this doc)** | `33_MIGRATE_FROM_LATTICE.md` | `cursor/weaver-migrate-plan` | Reviewed; no tree change |
| **M1 — Pre-move tag** | `archive/echo-lattice-pre-move` annotated tag | Human or cloud on integration tip | Tag pushed; CI green on old paths |
| **M2 — Rename + CI/tools** | `git mv` + workflow/tool path fixes | `cursor/weaver-migrate-execute` (name flexible) | §3.5 green; no asset recompress |
| **M3 — Docs policy sync** | PIVOT / BACKUP / WEAVER path law | May stack on M2 or follow immediately | Pivot language matches tree |
| **M4 — Weaver default CI (later)** | CI matrix prefers `game/weaver/` when that project exists | Separate PR | Weaver spike has contracts; EL archive jobs optional/manual |

Do not combine M2 with Weaver feature work, capsule regenerations, or Godot version bumps.

---

## 6. Execute gates (all required)

- [ ] Human ack that archive path is `archive/echo_lattice/` (or a written supersession of §0)
- [ ] Working tree clean; migrate PR contains **only** rename + path rewrites (+ optional pointer stub)
- [ ] Tag `archive/echo-lattice-pre-move` pushed
- [ ] Existing `backup/echo-lattice-rc1-steam-pack` still reachable and unchanged
- [ ] `git log --follow` on `archive/echo_lattice/project.godot` walks into pre-move history
- [ ] Python contract suite green at the **new** path
- [ ] CI workflow paths updated in the same change set as the rename
- [ ] PIVOT / BACKUP “do not delete” language retargeted to `archive/echo_lattice/`
- [ ] No AppID / Partner paste mutations
- [ ] No deletion of `docs/RELEASE/`, `docs/AUDIT/`, or `steam/echo_lattice/`

---

## 7. Rollback

If M2 lands and CI or export tooling breaks:

1. Revert the migrate merge commit with `git revert -m 1 <merge_sha>` (keeps history; restores old paths).  
2. Do **not** force-delete `archive/echo-lattice-pre-move` or the backup freeze tag.  
3. File a short incident note under `docs/BACKUP/` describing what failed (path miss, Windows export, rename detection).  
4. Re-attempt only after fixing the path matrix on a new branch.

Because the move is a normal commit (not a history rewrite), rollback does not require filter-repo or tag surgery.

---

## 8. Agent policy (after M3)

| Do | Do not |
|---|---|
| Treat `archive/echo_lattice/` as read-mostly craft reference | Edit archived EL to implement Weaver features |
| Put new prototypes in `game/weaver/` | Recreate `game/echo_lattice/` as a second live tree |
| Cite freeze tag + pre-move tag when discussing old paths | Claim Coming Soon / AppIDs from archive layout changes |
| Keep Steam pack docs linked from BACKUP | “Clean up” by deleting RELEASE media or AUDIT corpus |

---

## 9. Relationship to existing freeze

| Ref | Role after migrate |
|---|---|
| Tag/branch `backup/echo-lattice-rc1-steam-pack` @ `5f0d463` | Immutable Steam-pack archaeology — tree still has `game/echo_lattice/` **on that ref** |
| Tag `archive/echo-lattice-pre-move` | Last integration tip before path layout change |
| Tip after M2/M3 | Live layout: EL under `archive/echo_lattice/`; Weaver under `game/weaver/` when created |
| [`../BACKUP/PATHS_INDEX.md`](../BACKUP/PATHS_INDEX.md) | Historical listing for freeze tip — label, don’t silently rewrite unless regenerating from the freeze ref |

---

## 10. Lock line

**Echo Lattice becomes an on-disk archive by `git mv`, protected by tags, with CI and pivot docs moved in the same wave.** History stays; deletion stays forbidden; Weaver builds beside the archive — never on top of it.
