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

Requires account security 3 (Administrator). The window header reports the link state, so if a
command silently does nothing, look there first. `/forge test` re-runs the connection probe.

## The server side

`modules/mod-ascension-compat/src/AscensionForgeCursor.cpp` adds a `.coa` command family, every
entry gated at `SEC_ADMINISTRATOR`. The addon probes for it at login and adapts: with it present
placement is exact and appearance is saved, without it the addon falls back and says so.

| Command | Purpose |
|---|---|
| `.coa cursor` | Reports where the GM last aimed a ground-targeted spell, in `.gps` format |
| `.coa pickspell` | Teaches the caster the inert spell the Pick spot button casts |
| `.coa spawnnpc <entry> <x> <y> <z> <o>` | Creates a creature spawn at exact coordinates and reports its guid |
| `.coa spawngo <entry> <x> <y> <z> <o>` | Same for a gameobject |
| `.coa npcpos <guid> <x> <y> <z> <o>` | Moves a creature spawn to exact coordinates and saves it |
| `.coa gopos <guid> <x> <y> <z> <o>` | Same for a gameobject spawn, including rotation |
| `.coa select <guid>` | Targets a spawn server-side, so selection-only commands can be scripted |
| `.coa scale <entry> <scale>` | Writes `creature_template_model.DisplayScale` |
| `.coa aura <entry> <ids\|none>` | Writes `creature_template_addon.auras` |
| `.coa npcinfo <guid>` / `.coa goinfo <guid>` | One machine-readable `COAINFO` line for the addon to parse |

`.coa spawnnpc` exists because `.npc add` writes the spawn row before it tries to put the creature
in the world, so a failure there leaves a database row with nothing standing on it. It also gives
no guid back, which forced the addon to diff two `.npc near` listings to work out what it had just
created. The one-step command creates, saves, loads and reports the guid, or fails without leaving
anything behind.

`.coa npcpos` moves a creature with `NearTeleportTo` rather than the kill-and-respawn that `.npc
move` uses. Killing a freshly created spawn can leave it dead and out of the map, which looks
exactly like the spawn never happened.

## Picking a spot

The core has no concept of where a GM is pointing. The one place the client's aim reaches the
server is the destination of a ground-targeted spell cast, so that is what the editor uses.

Pressing **Pick spot** casts spell 257464, chosen because it is inert: a dummy effect with no
second or third effect, no cost, no cooldown, instant, unlimited range, no attribute flags, no
script and no DBC override, and a name unique in `Spell.dbc` so a secure cast button can name it.
It shows a small impact where you click, which is useful feedback. `OnPlayerSpellCast` records the
destination and `.coa cursor` reports it. With **move on pick** enabled the selected spawn goes
there immediately; otherwise the spot is remembered and Move to spot, Spawn and Paste all use it.

The button has to be a `SecureActionButtonTemplate`, because casting is a protected action that an
addon cannot perform directly. That template can only cast by name, which is why the spell's name
must be unique.

`.coa select` exists because `.npc set wanderdistance` and `.npc set spawntime` act only on the
current target, which an addon cannot set. With it, pasting a creature applies every copied
property automatically instead of asking you to click the new spawn first.

## Using it

Click the gear on the minimap, or type `/forge`. Edit mode binds Ctrl-C copy, Ctrl-V paste,
Ctrl-Z undo and Ctrl-Y redo, and releases them when you close the window.

**Place** — target a creature and press Refresh, or press Scan and click a row. Nudge on each
axis at a selectable step, set facing on a 0 to 360 slider or type the degrees, drop to ground,
move to the picked spot, delete, copy, paste. Movement type, wander distance and respawn
time sit below.

**Look** — search creature displays by the name of anything that uses them. Hovering a row shows
the model in a 3D preview you can drag to rotate; clicking applies it. Scale and visual effects
sit alongside, with their own searchable list.

**Quest** — add, complete, reward and remove a quest, keep a watch list of the ones you are
iterating on, reload the server tables a quest depends on, and bookmark positions to return to.

**Browse** — searches the **live server database** through the `.lookup` commands. This is not the
shipped catalog: nothing is listed until you type part of a name and press Enter, because the
query runs on the server. Pick the kind with the button on the left, and the tab states what
clicking a result will do. Results are capped by the server's `MaxResultsLookupCommands` setting.

**Changes** — the undo history, a cursor you can click to jump to any point, and the export.

## What persists

With the server toolset present, everything the editor does is written to the database:

| Edit | Command behind it | Table |
|---|---|---|
| Position and orientation | `.coa npcpos`, `.coa gopos` | `creature`, `gameobject` |
| Spawn and delete | `.coa spawnnpc`, `.coa spawngo`, `.npc delete` | `creature`, `gameobject` |
| Display | `.npc set model` | `creature.modelid` |
| Wander, movement type, respawn, phase | `.npc set ...` | `creature` |
| Size | `.coa scale` | `creature_template_model.DisplayScale` |
| Visual effects | `.coa aura` | `creature_template_addon.auras` |

Size and effects are also applied live with `.modify scale` and `.aura`, because the stored value
only reaches existing spawns after a template reload. Without the server toolset those two are
previews only, recorded in the change log and emitted by the export instead. The Look tab says
which mode you are in.

## Undo

Every mutating action records the commands to apply it and the commands to reverse it, both
built from values read back off the server rather than assumed. Repeated nudges of one spawn
inside three seconds collapse into a single history entry, so holding a nudge does not bury the
history. Deleting is reversible, but the respawn gets a new guid, and the history entry says so.

The history and the change log live in `CoAForgeDB`, which the client flushes to disk on reload
and logout. The Changes tab shows an unsaved count and a button that flushes by reloading the UI.
World edits themselves are durable on the server the moment they are made; only the history is at
risk from a crash.

## The catalog

Generated from real CoA data, not shipped stock lists.

| Catalog | Rows | Source |
|---|---|---|
| Creature displays | 22,530 | `CreatureDisplayInfo.dbc` joined to `creature_template_model`, labelled with a creature that uses each one |
| Object displays | 3,745 | `GameObjectDisplayInfo.dbc` joined to `gameobject_template` |
| Visual effects | 2,843 | `Spell.dbc`, filtered to infinite dummy auras that have a spell visual and no description |

That last filter matters. Without the description and visual tests the list is 8,684 entries and
full of food buffs and other non-visual dummy auras, which makes it useless for picking a look.

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
