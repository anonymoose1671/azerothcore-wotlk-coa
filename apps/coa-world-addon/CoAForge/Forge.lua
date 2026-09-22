CoAForge = CoAForge or {}
local F = CoAForge

local Forge = {}
F.Forge = Forge

F.Selection = nil
F.Server = { forge = false, cursor = false, probed = false }

local function coords(position)
    return F.Coord(position.x) .. " " .. F.Coord(position.y) .. " " .. F.Coord(position.z)
end

local function teleport(position)
    return "go xyz " .. coords(position) .. " " .. tostring(position.map or 0) .. " " .. F.Coord(position.o or 0)
end

local function withSelect(guid, commands)
    if not F.Server.forge or not guid then return commands end
    local out = { "coa select " .. guid }
    for _, command in ipairs(commands) do out[#out + 1] = command end
    return out
end

local function missingCommand(lines)
    local text = F.Strip(F.Join(lines)):lower()
    return text:find("no such command", 1, true) ~= nil
        or text:find("possible subcommands", 1, true) ~= nil
        or text:find("usage: .coa", 1, true) ~= nil
end

function Forge:ProbeServer()
    F.Rpc:Send("coa cursor", function(ok, lines)
        F.Server.probed = true
        F.Server.forge = ok or not missingCommand(lines)
        F.Server.cursor = ok
        if F.Server.forge then
            F.Rpc:Send("coa pickspell")
            F.Print("server toolset present: exact placement, selection and saved appearance are available")
        else
            F.Print("server toolset absent: falling back to teleport placement and preview-only appearance")
        end
        F.Events:Fire("STATUS")
    end)
end

function Forge:ReadPlayerPosition(callback)
    F.Rpc:Send("gps " .. UnitName("player"), function(ok, lines)
        callback(ok and F.ParseGps(lines) or nil)
    end)
end

function Forge:ReadCursor(callback)
    if not CoAForgeDB.useAoeCursor or not F.Server.forge then
        return self:ReadPlayerPosition(function(position)
            if position then position.source = "player" end
            callback(position)
        end)
    end
    F.Rpc:Send("coa cursor", function(ok, lines)
        local position = ok and F.ParseGps(lines) or nil
        if position then
            position.source = "aoe"
            F.Server.cursor = true
            return callback(position)
        end
        self:ReadPlayerPosition(function(fallback)
            if fallback then fallback.source = "player" end
            callback(fallback)
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
        self:LoadCreature(info.guid, info, callback)
    end)
end

function Forge:LoadCreature(guid, info, callback)
    if F.Server.forge then
        F.Rpc:Send("coa npcinfo " .. guid, function(ok, lines)
            local row = ok and F.ParseForgeInfo(lines) or nil
            if row then
                row.name = UnitName("target") or ("creature " .. guid)
                row.display = (info and info.display) or row.display
                row.nativeDisplay = info and info.nativeDisplay
                F.Selection = row
                F.Events:Fire("TARGET")
                if callback then callback(row) end
                return
            end
            self:LoadCreatureByGps(guid, info, callback)
        end)
        return
    end
    self:LoadCreatureByGps(guid, info, callback)
end

function Forge:LoadCreatureByGps(guid, info, callback)
    F.Rpc:Send("gps", function(gpsOk, gpsLines)
        local position = gpsOk and F.ParseGps(gpsLines) or nil
        F.Selection = {
            kind = "creature",
            guid = guid,
            entry = info and info.entry,
            name = UnitName("target") or ("creature " .. tostring(guid)),
            display = info and info.display,
            nativeDisplay = info and info.nativeDisplay,
            x = position and position.x or (info and info.x),
            y = position and position.y or (info and info.y),
            z = position and position.z or (info and info.z),
            o = position and position.o or 0,
            map = position and position.map or 0,
            groundZ = position and position.groundZ,
        }
        F.Events:Fire("TARGET")
        if callback then callback(F.Selection) end
    end)
end

function Forge:Select(guid, callback)
    if not F.Server.forge then
        F.Warn("server toolset absent; target the creature in game and press Refresh")
        return
    end
    F.Rpc:Send("coa select " .. guid, function(ok, lines)
        if not ok then
            F.Warn(F.Strip(F.Join(lines)))
            return
        end
        self:LoadCreature(guid, nil, callback)
    end)
end

function Forge:SelectGameObject(guid, callback)
    if F.Server.forge then
        F.Rpc:Send("coa goinfo " .. guid, function(ok, lines)
            local row = ok and F.ParseForgeInfo(lines) or nil
            if row then
                row.name = "object " .. guid
                F.Selection = row
                F.Events:Fire("TARGET")
                if callback then callback(row) end
                return
            end
            self:SelectGameObjectByInfo(guid, callback)
        end)
        return
    end
    self:SelectGameObjectByInfo(guid, callback)
end

function Forge:SelectGameObjectByInfo(guid, callback)
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

local function placementCommands(kind, guid, position)
    if F.Server.forge then
        local verb = kind == "gameobject" and "coa gopos " or "coa npcpos "
        return { verb .. guid .. " " .. coords(position) .. " " .. F.Coord(position.o or 0) }
    end
    if kind == "gameobject" then
        return { "gobject move " .. guid .. " " .. coords(position),
                 "gobject turn " .. guid .. " " .. F.Coord(position.o or 0) }
    end
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
    selection.x, selection.y, selection.z, selection.o = after.x, after.y, after.z, after.o
    F.Journal:Apply({
        label = label or "move",
        kind = "place",
        coalesce = coalesce,
        target = { kind = selection.kind, guid = selection.guid, entry = selection.entry, name = selection.name },
        redo = placementCommands(selection.kind, selection.guid, after),
        undo = placementCommands(selection.kind, selection.guid, before),
        before = before, after = after,
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
    while orientation < 0 do orientation = orientation + math.pi * 2 end
    while orientation >= math.pi * 2 do orientation = orientation - math.pi * 2 end
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
        if F.Server.forge then
            local command = "coa spawnnpc " .. entry .. " " .. coords(position) ..
                " " .. F.Coord(position.o or 0)
            F.Rpc:Send(command, function(ok, lines)
                if not ok then return F.Warn("spawn failed: " .. F.Strip(F.Join(lines))) end
                local guid = F.ParseSpawnResult(lines)
                if not guid then return F.Warn("spawned, but the server reported no guid") end
                F.Journal:Record({
                    label = "spawn " .. entry .. " as " .. guid,
                    kind = "spawn",
                    target = { kind = "creature", guid = guid, entry = entry },
                    redo = { command },
                    undo = { "npc delete " .. guid },
                    after = { x = position.x, y = position.y, z = position.z,
                              o = position.o, map = position.map },
                })
                F.Print("spawned " .. entry .. " as guid " .. guid)
                if properties then self:ApplyProperties(guid, properties) end
                if onSpawned then onSpawned(guid) end
                self:LoadCreature(guid, nil)
            end)
            return
        end
        self:ScanNear(8, function(before)
            local known = {}
            for _, row in ipairs(before.creatures) do known[row.guid] = true end
            F.Rpc:SendSequence({ teleport(position), "npc add " .. entry }, function(ok, lines)
                if not ok then return F.Warn("spawn failed: " .. F.Strip(F.Join(lines))) end
                self:ScanNear(8, function(after)
                    local guid
                    for _, row in ipairs(after.creatures) do
                        if not known[row.guid] and row.entry == entry then guid = row.guid end
                    end
                    if not guid then
                        return F.Warn("spawned, but could not identify the new guid; press Scan")
                    end
                    F.Journal:Record({
                        label = "spawn " .. entry .. " as " .. guid,
                        kind = "spawn",
                        target = { kind = "creature", guid = guid, entry = entry },
                        redo = { teleport(position), "npc add " .. entry },
                        undo = { "npc delete " .. guid },
                        after = { x = position.x, y = position.y, z = position.z,
                                  o = position.o, map = position.map },
                    })
                    F.Print("spawned " .. entry .. " as guid " .. guid)
                    if properties then self:ApplyProperties(guid, properties) end
                    if onSpawned then onSpawned(guid) end
                end)
            end)
        end)
    end)
end

function Forge:SpawnObject(entry, onSpawned)
    self:ReadCursor(function(position)
        if not position then return F.Warn("could not read a placement position") end
        if F.Server.forge then
            local command = "coa spawngo " .. entry .. " " .. coords(position) ..
                " " .. F.Coord(position.o or 0)
            F.Rpc:Send(command, function(ok, lines)
                if not ok then return F.Warn("spawn failed: " .. F.Strip(F.Join(lines))) end
                local guid = F.ParseSpawnResult(lines)
                if not guid then return F.Warn("spawned, but the server reported no guid") end
                F.Journal:Record({
                    label = "spawn object " .. entry .. " as " .. guid,
                    kind = "spawn",
                    target = { kind = "gameobject", guid = guid, entry = entry },
                    redo = { command },
                    undo = { "gobject delete " .. guid },
                    after = { x = position.x, y = position.y, z = position.z,
                              o = position.o, map = position.map },
                })
                F.Print("spawned object " .. entry .. " as guid " .. guid)
                if onSpawned then onSpawned(guid) end
                self:SelectGameObject(guid)
            end)
            return
        end
        F.Rpc:SendSequence({ teleport(position) }, function()
            F.Rpc:Send("gobject add " .. entry, function(ok, lines)
                if not ok then return F.Warn("spawn failed: " .. F.Strip(F.Join(lines))) end
                local guid = F.ParseAddedGameObject(lines)
                if not guid then return F.Warn("spawned, but the server reported no guid") end
                F.Journal:Record({
                    label = "spawn object " .. entry .. " as " .. guid,
                    kind = "spawn",
                    target = { kind = "gameobject", guid = guid, entry = entry },
                    redo = { teleport(position), "gobject add " .. entry },
                    undo = { "gobject delete " .. guid },
                    after = { x = position.x, y = position.y, z = position.z,
                              o = position.o, map = position.map },
                })
                F.Print("spawned object " .. entry .. " as guid " .. guid)
                self:SelectGameObject(guid)
            end)
        end)
    end)
end

function Forge:OnPicked()
    F.Rpc:Send("coa cursor", function(ok, lines)
        local position = ok and F.ParseGps(lines) or nil
        if not position then
            return F.Warn("the server did not record that ground target")
        end
        position.source = "aoe"
        F.Cursor = position
        F.Events:Fire("CURSOR")
        F.Print(string.format("spot picked at %.1f %.1f %.1f", position.x, position.y, position.z))
        local action = self.pendingPick
        self.pendingPick = nil
        if action then
            action(position)
        elseif CoAForgeDB.pickMoves and F.Selection then
            self:PlaceSelection({
                x = position.x, y = position.y, z = position.z,
                o = F.Selection.o, map = position.map,
            }, "place " .. (F.Selection.name or "spawn") .. " at picked spot")
        end
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
        redo = withSelect(selection.guid, { "npc set model " .. displayId }),
        undo = withSelect(selection.guid, { "npc set model " .. tostring(previous or selection.nativeDisplay or 0) }),
        before = { display = previous }, after = { display = displayId },
    })
    selection.display = displayId
    F.Events:Fire("TARGET")
end

function Forge:SetScale(scale)
    local selection = F.Selection
    if not selection then return F.Warn("nothing selected") end
    local key = "creature:" .. tostring(selection.entry)
    local previous = (CoAForgeDB.pending[key] or {}).scale or 1
    CoAForgeDB.pending[key] = CoAForgeDB.pending[key] or { entry = selection.entry, name = selection.name }
    CoAForgeDB.pending[key].scale = scale
    local saved = F.Server.forge and selection.entry
    local redo = withSelect(selection.guid, { "modify scale " .. F.Coord(scale) })
    local undo = withSelect(selection.guid, { "modify scale " .. F.Coord(previous) })
    if saved then
        redo[#redo + 1] = "coa scale " .. selection.entry .. " " .. F.Coord(scale)
        undo[#undo + 1] = "coa scale " .. selection.entry .. " " .. F.Coord(previous)
    end
    F.Journal:Apply({
        label = "scale " .. scale .. " on " .. (selection.name or selection.guid) .. (saved and "" or " (preview)"),
        kind = "scale",
        persistent = saved and true or false,
        coalesce = "scale:" .. tostring(selection.entry),
        target = { kind = "creature", guid = selection.guid, entry = selection.entry, name = selection.name },
        redo = redo, undo = undo,
        before = { scale = previous }, after = { scale = scale },
    })
    F.Events:Fire("PENDING")
end

function Forge:AddAura(spellId)
    local selection = F.Selection
    if not selection then return F.Warn("nothing selected") end
    local key = "creature:" .. tostring(selection.entry)
    CoAForgeDB.pending[key] = CoAForgeDB.pending[key] or { entry = selection.entry, name = selection.name }
    local auras = CoAForgeDB.pending[key].auras or {}
    local previous = table.concat(auras, " ")
    auras[#auras + 1] = spellId
    CoAForgeDB.pending[key].auras = auras
    local saved = F.Server.forge and selection.entry
    local redo = withSelect(selection.guid, { "aura " .. spellId })
    local undo = withSelect(selection.guid, { "unaura " .. spellId })
    if saved then
        redo[#redo + 1] = "coa aura " .. selection.entry .. " " .. table.concat(auras, " ")
        undo[#undo + 1] = "coa aura " .. selection.entry .. " " .. (previous == "" and "none" or previous)
    end
    F.Journal:Apply({
        label = "effect " .. spellId .. " on " .. (selection.name or selection.guid) .. (saved and "" or " (preview)"),
        kind = "aura",
        persistent = saved and true or false,
        target = { kind = "creature", guid = selection.guid, entry = selection.entry, name = selection.name },
        redo = redo, undo = undo,
        after = { auras = table.concat(auras, " ") },
    })
    F.Events:Fire("PENDING")
end

function Forge:ClearAuras()
    local selection = F.Selection
    if not selection then return F.Warn("nothing selected") end
    local key = "creature:" .. tostring(selection.entry)
    local auras = (CoAForgeDB.pending[key] or {}).auras
    local previous = auras and table.concat(auras, " ") or ""
    if CoAForgeDB.pending[key] then CoAForgeDB.pending[key].auras = nil end
    local redo = withSelect(selection.guid, { "unaura all" })
    local undo = {}
    if F.Server.forge and selection.entry then
        redo[#redo + 1] = "coa aura " .. selection.entry .. " none"
        if previous ~= "" then
            undo[#undo + 1] = "coa aura " .. selection.entry .. " " .. previous
        end
    end
    F.Journal:Apply({
        label = "clear effects on " .. (selection.name or selection.guid),
        kind = "aura",
        persistent = F.Server.forge and true or false,
        target = { kind = "creature", guid = selection.guid, entry = selection.entry, name = selection.name },
        redo = redo, undo = undo, after = { auras = "" },
    })
    F.Events:Fire("PENDING")
end

function Forge:ApplyProperties(guid, properties)
    local commands = {}
    if F.Server.forge then commands[#commands + 1] = "coa select " .. guid end
    if properties.display then commands[#commands + 1] = "npc set model " .. properties.display end
    if properties.phase then commands[#commands + 1] = "npc set phase " .. properties.phase end
    if properties.wander then commands[#commands + 1] = "npc set wanderdistance " .. F.Coord(properties.wander) end
    if properties.movetype then commands[#commands + 1] = "npc set movetype " .. guid .. " " .. properties.movetype end
    if properties.spawntime then commands[#commands + 1] = "npc set spawntime " .. properties.spawntime end
    if properties.scale then commands[#commands + 1] = "modify scale " .. F.Coord(properties.scale) end
    for _, spell in ipairs(properties.auras or {}) do commands[#commands + 1] = "aura " .. spell end
    if #commands == 0 then return end
    if not F.Server.forge then
        CoAForgeDB.queued = { guid = guid, scale = properties.scale, auras = properties.auras,
                              wander = properties.wander, spawntime = properties.spawntime,
                              movetype = properties.movetype }
        F.Print("target the new spawn and press Apply queued to finish the paste")
        F.Events:Fire("PENDING")
        return
    end
    F.Rpc:SendSequence(commands, function(ok)
        if ok then F.Print("pasted properties applied") end
    end)
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
    local prefix = F.Server.forge and { "coa select " .. selection.guid } or {}
    local redo, undo = {}, {}
    for index, command in ipairs(prefix) do redo[index] = command undo[index] = command end
    redo[#redo + 1] = "npc set wanderdistance " .. F.Coord(distance)
    undo[#undo + 1] = "npc set wanderdistance " .. F.Coord(previous)
    F.Journal:Apply({
        label = "wander " .. distance .. " on " .. (selection.name or selection.guid),
        kind = "wander",
        coalesce = "wander:" .. selection.guid,
        target = { kind = "creature", guid = selection.guid, entry = selection.entry, name = selection.name },
        redo = redo, undo = undo,
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
    local prefix = F.Server.forge and ("coa select " .. selection.guid) or nil
    local redo, undo = {}, {}
    if prefix then redo[1] = prefix undo[1] = prefix end
    redo[#redo + 1] = "npc set spawntime " .. seconds
    undo[#undo + 1] = "npc set spawntime " .. previous
    F.Journal:Apply({
        label = "respawn " .. seconds .. "s on " .. (selection.name or selection.guid),
        kind = "spawntime",
        target = { kind = "creature", guid = selection.guid, entry = selection.entry, name = selection.name },
        redo = redo, undo = undo,
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
        if not ok then
            F.Warn("lookup failed: " .. F.Strip(F.Join(lines)))
            callback({})
            return
        end
        callback(F.ParseLookup(lines))
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
    out[#out + 1] = "# op\tkind\tguid\tentry\tfields"
    for _, row in ipairs(CoAForgeDB.log) do
        local target = row.target or {}
        local fields = {}
        for key, value in pairs(row.after or {}) do
            fields[#fields + 1] = key .. "=" .. tostring(value)
        end
        out[#out + 1] = table.concat({
            row.kind or "?", target.kind or "?", tostring(target.guid or ""),
            tostring(target.entry or ""), table.concat(fields, ","),
        }, "\t")
    end
    for _, row in pairs(CoAForgeDB.pending) do
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
