CoAForge = CoAForge or {}
local F = CoAForge

local Forge = {}
F.Forge = Forge

F.Selection = nil
F.Cursor = { source = "player" }

local aoeCursorState = "unknown"

local function coords(position)
    return F.Coord(position.x) .. " " .. F.Coord(position.y) .. " " .. F.Coord(position.z)
end

local function teleport(position)
    return "go xyz " .. coords(position) .. " " .. tostring(position.map or 0) .. " " .. F.Coord(position.o or 0)
end

function Forge:ReadPlayerPosition(callback)
    F.Rpc:Send("gps " .. UnitName("player"), function(ok, lines)
        callback(ok and F.ParseGps(lines) or nil)
    end)
end

function Forge:ReadCursor(callback)
    if aoeCursorState == "absent" or not CoAForgeDB.useAoeCursor then
        return self:ReadPlayerPosition(function(position)
            if position then position.source = "player" end
            callback(position)
        end)
    end
    F.Rpc:Send("coa cursor", function(ok, lines)
        if ok then
            aoeCursorState = "present"
            local position = F.ParseGps(lines)
            if position then
                position.source = "aoe"
                F.Cursor = position
                return callback(position)
            end
        end
        if aoeCursorState == "unknown" then
            aoeCursorState = "absent"
            F.Print("ground-target cursor not available on this server; using your own position")
        end
        self:ReadPlayerPosition(function(position)
            if position then position.source = "player" end
            callback(position)
        end)
    end)
end

function Forge:RefreshTarget(callback)
    if not UnitExists("target") or UnitIsPlayer("target") then
        F.Selection = nil
        F.Events:Fire("TARGET")
        if callback then callback(nil) end
        return
    end
    F.Rpc:Send("npc info", function(ok, lines)
        if not ok then
            if callback then callback(nil) end
            return
        end
        local info = F.ParseNpcInfo(lines)
        if not info then
            if callback then callback(nil) end
            return
        end
        F.Rpc:Send("gps", function(gpsOk, gpsLines)
            local position = gpsOk and F.ParseGps(gpsLines) or nil
            F.Selection = {
                kind = "creature",
                guid = info.guid,
                entry = info.entry,
                name = UnitName("target"),
                display = info.display,
                nativeDisplay = info.nativeDisplay,
                faction = info.faction,
                x = position and position.x or info.x,
                y = position and position.y or info.y,
                z = position and position.z or info.z,
                o = position and position.o or 0,
                map = position and position.map or 0,
                groundZ = position and position.groundZ,
            }
            F.Events:Fire("TARGET")
            if callback then callback(F.Selection) end
        end)
    end)
end

function Forge:SelectGameObject(guid, callback)
    F.Rpc:Send("gobject info guid " .. guid, function(ok, lines)
        if not ok then
            F.Warn("gameobject " .. guid .. " is not loaded nearby")
            if callback then callback(nil) end
            return
        end
        local info = F.ParseGameObjectInfo(lines)
        if not info then
            if callback then callback(nil) end
            return
        end
        info.kind = "gameobject"
        info.name = F.Strip(F.Join(lines)):match("%[(.-)%]") or ("object " .. guid)
        F.Selection = info
        F.Events:Fire("TARGET")
        if callback then callback(info) end
    end)
end

function Forge:ScanNear(distance, callback)
    local result = { creatures = {}, objects = {} }
    F.Rpc:Send("npc near " .. distance, function(_, lines)
        result.creatures = F.ParseNearList(lines, "creature")
        F.Rpc:Send("gobject near " .. distance, function(_, objectLines)
            result.objects = F.ParseNearList(objectLines, "gameobject")
            callback(result)
        end)
    end)
end

local function creaturePlacement(guid, position)
    return { teleport(position), "npc move " .. guid }
end

function Forge:PlaceSelection(position, label, coalesce)
    local selection = F.Selection
    if not selection then
        F.Warn("nothing selected")
        return
    end
    position.map = position.map or selection.map
    local before = { x = selection.x, y = selection.y, z = selection.z, o = selection.o, map = selection.map }
    local after = { x = position.x, y = position.y, z = position.z, o = position.o or selection.o, map = position.map }
    local redo, undo
    if selection.kind == "gameobject" then
        redo = { "gobject move " .. selection.guid .. " " .. coords(after),
                 "gobject turn " .. selection.guid .. " " .. F.Coord(after.o) }
        undo = { "gobject move " .. selection.guid .. " " .. coords(before),
                 "gobject turn " .. selection.guid .. " " .. F.Coord(before.o) }
    else
        redo = creaturePlacement(selection.guid, after)
        undo = creaturePlacement(selection.guid, before)
    end
    selection.x, selection.y, selection.z, selection.o = after.x, after.y, after.z, after.o
    F.Journal:Apply({
        label = label or "move",
        kind = "place",
        coalesce = coalesce,
        target = { kind = selection.kind, guid = selection.guid, entry = selection.entry, name = selection.name },
        redo = redo, undo = undo, before = before, after = after,
    })
    F.Events:Fire("TARGET")
end

function Forge:Nudge(dx, dy, dz)
    local selection = F.Selection
    if not selection then return F.Warn("nothing selected") end
    self:PlaceSelection({
        x = selection.x + dx, y = selection.y + dy, z = selection.z + dz,
        o = selection.o, map = selection.map,
    }, "nudge " .. (selection.name or "spawn"), "place:" .. selection.kind .. ":" .. selection.guid)
end

function Forge:Face(orientation)
    local selection = F.Selection
    if not selection then return F.Warn("nothing selected") end
    self:PlaceSelection({
        x = selection.x, y = selection.y, z = selection.z, o = orientation, map = selection.map,
    }, "turn " .. (selection.name or "spawn"), "turn:" .. selection.kind .. ":" .. selection.guid)
end

function Forge:MoveToCursor()
    local selection = F.Selection
    if not selection then return F.Warn("nothing selected") end
    self:ReadCursor(function(position)
        if not position then return F.Warn("could not read a placement position") end
        self:PlaceSelection({
            x = position.x, y = position.y, z = position.z,
            o = position.o or selection.o, map = position.map,
        }, "place " .. (selection.name or "spawn"))
    end)
end

function Forge:DropToGround()
    local selection = F.Selection
    if not selection then return F.Warn("nothing selected") end
    F.Rpc:Send("gps", function(ok, lines)
        local position = ok and F.ParseGps(lines) or nil
        local ground = position and (position.floorZ or position.groundZ)
        if not ground then return F.Warn("no ground height available here") end
        self:PlaceSelection({
            x = selection.x, y = selection.y, z = ground, o = selection.o, map = selection.map,
        }, "drop " .. (selection.name or "spawn") .. " to ground")
    end)
end

function Forge:SpawnCreature(entry, properties, onSpawned)
    self:ReadCursor(function(position)
        if not position then return F.Warn("could not read a placement position") end
        self:ScanNear(6, function(before)
            local known = {}
            for _, row in ipairs(before.creatures) do known[row.guid] = true end
            F.Rpc:SendSequence({ teleport(position), "npc add " .. entry }, function(ok, lines)
                if not ok then
                    return F.Warn("spawn failed: " .. F.Strip(F.Join(lines)))
                end
                self:ScanNear(6, function(after)
                    local guid
                    for _, row in ipairs(after.creatures) do
                        if not known[row.guid] and row.entry == entry then guid = row.guid end
                    end
                    if not guid then
                        return F.Warn("spawned, but could not identify the new guid; use Scan to find it")
                    end
                    F.Journal:Record({
                        label = "spawn " .. entry,
                        kind = "spawn",
                        target = { kind = "creature", guid = guid, entry = entry },
                        redo = { teleport(position), "npc add " .. entry },
                        undo = { "npc delete " .. guid },
                        after = { x = position.x, y = position.y, z = position.z, o = position.o, map = position.map },
                    })
                    F.Print("spawned " .. entry .. " as guid " .. guid)
                    if properties then self:ApplyProperties(guid, properties) end
                    if onSpawned then onSpawned(guid) end
                    F.Events:Fire("TARGET")
                end)
            end)
        end)
    end)
end

function Forge:SpawnObject(entry, onSpawned)
    self:ReadCursor(function(position)
        if not position then return F.Warn("could not read a placement position") end
        F.Rpc:SendSequence({ teleport(position) }, function()
            F.Rpc:Send("gobject add " .. entry, function(ok, lines)
                if not ok then return F.Warn("spawn failed: " .. F.Strip(F.Join(lines))) end
                local guid = F.ParseAddedGameObject(lines)
                if not guid then return F.Warn("spawned, but the server did not report a guid") end
                F.Journal:Record({
                    label = "spawn object " .. entry,
                    kind = "spawn",
                    target = { kind = "gameobject", guid = guid, entry = entry },
                    redo = { teleport(position), "gobject add " .. entry },
                    undo = { "gobject delete " .. guid },
                    after = { x = position.x, y = position.y, z = position.z, o = position.o, map = position.map },
                })
                F.Print("spawned object " .. entry .. " as guid " .. guid)
                if onSpawned then onSpawned(guid) end
            end)
        end)
    end)
end

function Forge:DeleteSelection()
    local selection = F.Selection
    if not selection then return F.Warn("nothing selected") end
    local position = { x = selection.x, y = selection.y, z = selection.z, o = selection.o, map = selection.map }
    local remove, restore
    if selection.kind == "gameobject" then
        remove = { "gobject delete " .. selection.guid }
        restore = { teleport(position), "gobject add " .. selection.entry }
    else
        remove = { "npc delete " .. selection.guid }
        restore = { teleport(position), "npc add " .. selection.entry }
    end
    F.Journal:Apply({
        label = "delete " .. (selection.name or selection.guid) .. " (undo respawns with a new guid)",
        kind = "delete",
        target = { kind = selection.kind, guid = selection.guid, entry = selection.entry, name = selection.name },
        redo = remove, undo = restore, before = position,
    })
    F.Selection = nil
    F.Events:Fire("TARGET")
end

function Forge:SetDisplay(displayId)
    local selection = F.Selection
    if not selection or selection.kind ~= "creature" then return F.Warn("target a creature first") end
    local previous = selection.display
    F.Journal:Apply({
        label = "display " .. displayId .. " on " .. (selection.name or selection.guid),
        kind = "display",
        target = { kind = "creature", guid = selection.guid, entry = selection.entry, name = selection.name },
        redo = { "npc set model " .. displayId },
        undo = { "npc set model " .. tostring(previous or selection.nativeDisplay or 0) },
        before = { display = previous }, after = { display = displayId },
    })
    selection.display = displayId
    F.Events:Fire("TARGET")
end

function Forge:PreviewScale(scale)
    local selection = F.Selection
    if not selection then return F.Warn("nothing selected") end
    local key = "creature:" .. tostring(selection.entry)
    local previous = (CoAForgeDB.pending[key] or {}).scale or 1
    CoAForgeDB.pending[key] = CoAForgeDB.pending[key] or { entry = selection.entry, name = selection.name }
    CoAForgeDB.pending[key].scale = scale
    F.Journal:Record({
        label = "scale " .. scale .. " on " .. (selection.name or selection.guid) .. " (preview)",
        kind = "scale",
        persistent = false,
        coalesce = "scale:" .. tostring(selection.entry),
        target = { kind = "creature", guid = selection.guid, entry = selection.entry, name = selection.name },
        redo = { "modify scale " .. F.Coord(scale) },
        undo = { "modify scale " .. F.Coord(previous) },
        before = { scale = previous }, after = { scale = scale },
    })
    F.Rpc:Send("modify scale " .. F.Coord(scale))
    F.Events:Fire("PENDING")
end

function Forge:PreviewAura(spellId)
    local selection = F.Selection
    if not selection then return F.Warn("nothing selected") end
    local key = "creature:" .. tostring(selection.entry)
    CoAForgeDB.pending[key] = CoAForgeDB.pending[key] or { entry = selection.entry, name = selection.name }
    local auras = CoAForgeDB.pending[key].auras or {}
    auras[#auras + 1] = spellId
    CoAForgeDB.pending[key].auras = auras
    F.Journal:Record({
        label = "aura " .. spellId .. " on " .. (selection.name or selection.guid) .. " (preview)",
        kind = "aura",
        persistent = false,
        target = { kind = "creature", guid = selection.guid, entry = selection.entry, name = selection.name },
        redo = { "aura " .. spellId },
        undo = { "unaura " .. spellId },
        after = { aura = spellId },
    })
    F.Rpc:Send("aura " .. spellId)
    F.Events:Fire("PENDING")
end

function Forge:ClearAuras()
    local selection = F.Selection
    if not selection then return F.Warn("nothing selected") end
    local key = "creature:" .. tostring(selection.entry)
    if CoAForgeDB.pending[key] then CoAForgeDB.pending[key].auras = nil end
    F.Rpc:Send("unaura all")
    F.Events:Fire("PENDING")
end

function Forge:ApplyProperties(guid, properties)
    local commands = {}
    if properties.display then commands[#commands + 1] = "npc set model " .. properties.display end
    if properties.phase then commands[#commands + 1] = "npc set phase " .. properties.phase end
    if #commands > 0 then F.Rpc:SendSequence(commands) end
    if properties.scale or properties.auras or properties.wander or properties.spawntime or properties.movetype then
        CoAForgeDB.queued = {
            guid = guid,
            scale = properties.scale,
            auras = properties.auras,
            wander = properties.wander,
            spawntime = properties.spawntime,
            movetype = properties.movetype,
        }
        F.Print("target the new spawn and click Apply queued to finish the paste")
        F.Events:Fire("PENDING")
    end
end

function Forge:ApplyQueued()
    local queued = CoAForgeDB.queued
    if not queued then return F.Warn("nothing queued") end
    if not F.Selection then return F.Warn("target the spawn first") end
    local commands = {}
    if queued.wander then commands[#commands + 1] = "npc set wanderdistance " .. F.Coord(queued.wander) end
    if queued.movetype then commands[#commands + 1] = "npc set movetype " .. queued.movetype end
    if queued.spawntime then commands[#commands + 1] = "npc set spawntime " .. queued.spawntime end
    if queued.scale then commands[#commands + 1] = "modify scale " .. F.Coord(queued.scale) end
    for _, spell in ipairs(queued.auras or {}) do commands[#commands + 1] = "aura " .. spell end
    F.Rpc:SendSequence(commands, function(ok)
        if ok then F.Print("queued properties applied") end
    end)
    CoAForgeDB.queued = nil
    F.Events:Fire("PENDING")
end

function Forge:SetWander(distance)
    local selection = F.Selection
    if not selection or selection.kind ~= "creature" then return F.Warn("target a creature first") end
    local previous = selection.wander or 0
    F.Journal:Apply({
        label = "wander " .. distance .. " on " .. (selection.name or selection.guid),
        kind = "wander",
        coalesce = "wander:" .. selection.guid,
        target = { kind = "creature", guid = selection.guid, entry = selection.entry, name = selection.name },
        redo = { "npc set wanderdistance " .. F.Coord(distance) },
        undo = { "npc set wanderdistance " .. F.Coord(previous) },
        before = { wander = previous }, after = { wander = distance },
    })
    selection.wander = distance
end

function Forge:SetMoveType(moveType)
    local selection = F.Selection
    if not selection or selection.kind ~= "creature" then return F.Warn("target a creature first") end
    local previous = selection.movetype or "stay"
    F.Journal:Apply({
        label = "movement " .. moveType .. " on " .. (selection.name or selection.guid),
        kind = "movetype",
        target = { kind = "creature", guid = selection.guid, entry = selection.entry, name = selection.name },
        redo = { "npc set movetype " .. selection.guid .. " " .. moveType },
        undo = { "npc set movetype " .. selection.guid .. " " .. previous },
        before = { movetype = previous }, after = { movetype = moveType },
    })
    selection.movetype = moveType
end

function Forge:SetSpawnTime(seconds)
    local selection = F.Selection
    if not selection or selection.kind ~= "creature" then return F.Warn("target a creature first") end
    local previous = selection.spawntime or 300
    F.Journal:Apply({
        label = "respawn " .. seconds .. "s on " .. (selection.name or selection.guid),
        kind = "spawntime",
        target = { kind = "creature", guid = selection.guid, entry = selection.entry, name = selection.name },
        redo = { "npc set spawntime " .. seconds },
        undo = { "npc set spawntime " .. previous },
        before = { spawntime = previous }, after = { spawntime = seconds },
    })
    selection.spawntime = seconds
end

function Forge:Copy()
    local selection = F.Selection
    if not selection then return F.Warn("nothing selected") end
    local pending = CoAForgeDB.pending["creature:" .. tostring(selection.entry)] or {}
    CoAForgeDB.clipboard = {
        kind = selection.kind,
        entry = selection.entry,
        name = selection.name,
        display = selection.display,
        phase = selection.phase,
        scale = pending.scale,
        auras = pending.auras,
        wander = selection.wander,
        movetype = selection.movetype,
        spawntime = selection.spawntime,
    }
    F.Print("copied " .. tostring(selection.name or selection.entry))
    F.Events:Fire("PENDING")
end

function Forge:Paste()
    local clip = CoAForgeDB.clipboard
    if not clip then return F.Warn("clipboard is empty") end
    if clip.kind == "gameobject" then
        self:SpawnObject(clip.entry)
    else
        self:SpawnCreature(clip.entry, clip)
    end
end

function Forge:Quest(action, questId)
    F.Rpc:Send("quest " .. action .. " " .. questId, function(ok, lines)
        if ok then
            F.Print("quest " .. questId .. " " .. action)
        else
            F.Warn("quest " .. action .. " failed: " .. F.Strip(F.Join(lines)))
        end
    end)
end

function Forge:Reload(what)
    F.Rpc:Send("reload " .. what, function(ok, lines)
        if ok then F.Print("reloaded " .. what) else F.Warn(F.Strip(F.Join(lines))) end
    end)
end

function Forge:Lookup(kind, text, callback)
    F.Rpc:Send("lookup " .. kind .. " " .. text, function(ok, lines)
        callback(ok and F.ParseLookup(lines) or {})
    end)
end

function Forge:SaveBookmark(name)
    self:ReadPlayerPosition(function(position)
        if not position then return F.Warn("could not read your position") end
        position.name = name
        table.insert(CoAForgeDB.bookmarks, position)
        F.Print("bookmarked " .. name)
        F.Events:Fire("BOOKMARKS")
    end)
end

function Forge:GoBookmark(index)
    local mark = CoAForgeDB.bookmarks[index]
    if not mark then return end
    F.Rpc:Send(teleport(mark))
end

function Forge:Export()
    local out = {}
    out[#out + 1] = "# CoA Forge change log"
    out[#out + 1] = "# columns: op<TAB>kind<TAB>guid<TAB>entry<TAB>fields"
    for _, row in ipairs(CoAForgeDB.log) do
        local target = row.target or {}
        local fields = {}
        for _, source in ipairs({ row.after or {} }) do
            for key, value in pairs(source) do
                fields[#fields + 1] = key .. "=" .. tostring(value)
            end
        end
        out[#out + 1] = table.concat({
            row.kind or "?", target.kind or "?", tostring(target.guid or ""),
            tostring(target.entry or ""), table.concat(fields, ","),
        }, "\t")
    end
    for key, row in pairs(CoAForgeDB.pending) do
        local fields = {}
        if row.scale then fields[#fields + 1] = "scale=" .. row.scale end
        if row.auras then fields[#fields + 1] = "auras=" .. table.concat(row.auras, "|") end
        if #fields > 0 then
            out[#out + 1] = table.concat({ "pending", "creature", "", tostring(row.entry),
                                           table.concat(fields, ",") }, "\t")
        end
    end
    return table.concat(out, "\n")
end
