# CoA Forge — in-game world editing addon

A GM-only editor that runs inside the client. It places and dresses spawns, prototypes quests, and
records every change so the result can be baked into a migration instead of living only in the
live database.

It drives the server over AzerothCore's addon command channel, not chat. Commands go out as
`SendAddonMessage("AzerothCore", ...)` and the server replies with acknowledge, output, and
ok/failed frames (`src/server/game/Chat/Chat.cpp`, `AddonChannelCommandHandler`). That gives real
request/response pairs, so the addon can read positions back and build a correct undo stack.

## Install

```sh
python apps/coa-world-addon/build_catalog.py \
  --config <repack>/Core/configs/worldserver.conf \
  --mysql <repack>/mysql/bin/mysql.exe \
  --dbc <repack>/Data/dbc
python apps/coa-world-addon/install.py --client <client-root>
```

`build_catalog.py` regenerates `CoAForge/Data/Displays.lua` from the live world database and the
client DBC set. `install.py` copies the addon into `<client>/Interface/AddOns/CoAForge`, replaces
only files the addon owns, and deletes files it no longer owns. Use `--dry-run` to see the plan.

Requires account security 3 (Administrator). Spawn writes are gated at that level; the lookup and
info commands need 1–2.

## Using it

Click the gear on the minimap, or type `/forge`. Edit mode binds Ctrl-C copy, Ctrl-V paste,
Ctrl-Z undo and Ctrl-Y redo, and releases them when you close the window.

**Place** — target a creature and press Refresh, or Scan and click a gameobject. Nudge on each
axis at a selectable step, turn in 45 degree steps, face the player, drop to ground, move to
cursor, delete, copy, paste. Movement type, wander distance and respawn time sit alongside.
Spawn a new creature or object by entry.

**Look** — search 22,000 creature displays by the name of any creature that uses them, apply one
(saved to the database), preview scale and visual effects live, and browse 8,600 pure visual
auras. Scale and auras are previews; see the split below.

**Quest** — add, complete, reward, remove and reset a quest, keep a watch list of the ones you
are iterating on, reload the server tables a quest depends on, and bookmark positions to return to.

**Browse** — searches the live server database through `.lookup`, so results are always current
and no catalog is shipped for creatures, objects, items, spells or quests.

**Changes** — the undo history, a cursor you can click to jump to any point, and the export.

## What persists and what does not

This distinction is deliberate and visible in the interface, because getting it wrong silently
loses work.

Saved to the database by the server, immediately:

| Edit | Command behind it | Table |
|---|---|---|
| Position and orientation | `.go xyz` then `.npc move` | `creature` |
| Gameobject position and rotation | `.gobject move`, `.gobject turn` | `gameobject` |
| Spawn and delete | `.npc add`, `.gobject add`, `.npc delete` | `creature`, `gameobject` |
| Display | `.npc set model` | `creature.modelid` |
| Wander, movement type, respawn, phase | `.npc set ...` | `creature` |

Live preview only, never written by the server:

| Edit | Command behind it | Where it has to land |
|---|---|---|
| Size | `.modify scale` | `creature_template_model.DisplayScale` |
| Visual effect | `.aura` | `creature_template_addon.auras` |

Previews are recorded in the change log and come out of the export, which is how they reach a
migration. The Look tab labels them.

## Placement uses the player as the cursor

`.npc move` has no coordinate form; it moves the spawn to wherever the GM is standing. So the
addon teleports you to the target position first, with `.go xyz x y z map orientation`, and then
moves the spawn to you. Orientation is exact because `.go xyz` takes a fifth value.

`modules/mod-ascension-compat/src/AscensionForgeCursor.cpp` adds `.coa cursor`, which records the
destination of the last ground-targeted spell a GM cast and reports it in the same format `.gps`
uses. With it, placement lands where you point instead of where you stand. **It needs a server
build to take effect.** Until then the addon probes for the command once, finds it missing, says
so, and falls back to your own position for the rest of the session.

## Undo

Every mutating action records the commands to apply it and the commands to reverse it, both
built from values read back off the server rather than assumed. Repeated nudges of one spawn
inside three seconds collapse into a single history entry, so holding a nudge does not bury the
history. Deleting is reversible, but the respawn gets a new guid, and the history entry says so.

The history and the change log live in `CoAForgeDB`, which the client flushes to disk on reload
and logout. The Changes tab shows an unsaved count and a button that flushes by reloading the UI.
World edits themselves are already durable on the server the moment they are made; only the
history is at risk from a crash.

## Checking it

```sh
python apps/coa-world-addon/test_check_addon.py
python apps/coa-world-addon/check_addon.py
```

There is no Lua interpreter in this environment, so `check_addon.py` tokenizes each file the way
Lua does — handling comments, quoted and long strings, and escapes — and verifies block, string
and bracket balance, that every manifest entry exists, that no Lua file is missing from the
manifest, and that every catalog row is well formed. `test_check_addon.py` covers it with
positive and negative cases, so a passing run means something.
