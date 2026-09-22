CoAForge = CoAForge or {}
local F = CoAForge

F.name = "CoA Forge"
F.version = "1.0"

local CHAT_COLOR = "|cff66ccff"
local WARN_COLOR = "|cffff8844"

function F.Print(message)
    DEFAULT_CHAT_FRAME:AddMessage(CHAT_COLOR .. "Forge|r " .. tostring(message))
end

function F.Warn(message)
    DEFAULT_CHAT_FRAME:AddMessage(WARN_COLOR .. "Forge|r " .. tostring(message))
end

function F.Round(value, places)
    local factor = 10 ^ (places or 3)
    return math.floor(value * factor + 0.5) / factor
end

function F.Coord(value)
    return string.format("%.4f", value or 0)
end

function F.Trim(text)
    return (tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

function F.Strip(text)
    text = tostring(text or "")
    text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    text = text:gsub("|H.-|h(.-)|h", "%1")
    text = text:gsub("|T.-|t", "")
    return text
end

function F.Join(lines)
    return table.concat(lines or {}, "\n")
end

local NUMBER = "(-?%d+%.?%d*)"

function F.ParseGps(lines)
    local text = F.Join(lines)
    local x, y, z, o = text:match("X:%s*" .. NUMBER .. "%s+Y:%s*" .. NUMBER .. "%s+Z:%s*" .. NUMBER .. "%s+Orientation:%s*" .. NUMBER)
    if not x then return nil end
    local map = text:match("Map:%s*(%d+)")
    local ground = text:match("GroundZ:%s*" .. NUMBER)
    local floor = text:match("FloorZ:%s*" .. NUMBER)
    return {
        x = tonumber(x), y = tonumber(y), z = tonumber(z), o = tonumber(o),
        map = tonumber(map) or 0,
        groundZ = tonumber(ground), floorZ = tonumber(floor),
    }
end

function F.ParseNpcInfo(lines)
    local text = F.Join(lines)
    local guid = text:match("DB GUID:%s*(%d+)")
    if not guid then return nil end
    local entry = text:match("Current Entry:%s*(%d+)")
    local display, native = text:match("DisplayID:%s*(%d+)%s*%(Native:%s*(%d+)%)")
    local x, y, z = text:match("Position:%s*" .. NUMBER .. "%s+" .. NUMBER .. "%s+" .. NUMBER)
    return {
        guid = tonumber(guid),
        entry = tonumber(entry),
        display = tonumber(display),
        nativeDisplay = tonumber(native),
        x = tonumber(x), y = tonumber(y), z = tonumber(z),
        faction = tonumber(text:match("Faction:%s*(%d+)")),
        phase = tonumber(text:match("Phasemask:%s*(%d+)") or text:match("Phase:%s*(%d+)")),
    }
end

F.MOVEMENT_NAMES = { [0] = "stay", [1] = "random", [2] = "way" }

function F.ParseForgeInfo(lines)
    for _, line in ipairs(lines or {}) do
        local kind, rest = line:match("COAINFO%s+(%a+)%s+(.+)$")
        if kind then
            local values = {}
            for token in rest:gmatch("%S+") do values[#values + 1] = tonumber(token) end
            if #values >= 12 then
                return {
                    kind = kind == "go" and "gameobject" or "creature",
                    guid = values[1], entry = values[2], map = values[3],
                    x = values[4], y = values[5], z = values[6], o = values[7],
                    phase = values[8], display = values[9] ~= 0 and values[9] or nil,
                    wander = values[10], movetype = F.MOVEMENT_NAMES[values[11]] or "stay",
                    spawntime = values[12],
                }
            end
        end
    end
    return nil
end

function F.ParseGameObjectInfo(lines)
    local text = F.Join(lines)
    local guid = text:match("GUID:%s*(%d+)")
    if not guid then return nil end
    local x, y, z = text:match("X:%s*" .. NUMBER .. "%s+Y:%s*" .. NUMBER .. "%s+Z:%s*" .. NUMBER)
    return {
        guid = tonumber(guid),
        entry = tonumber(text:match("ID:%s*(%d+)")),
        x = tonumber(x), y = tonumber(y), z = tonumber(z),
        map = tonumber(text:match("MapId:%s*(%d+)")),
        o = tonumber(text:match("Orientation:%s*" .. NUMBER)),
        phase = tonumber(text:match("Phasemask%s*(%d+)")),
    }
end

function F.ParseNearList(lines, link)
    local found = {}
    for _, line in ipairs(lines or {}) do
        local guid = line:match("|H" .. link .. ":(%d+)|h")
        local entry = line:match("[Ee]ntry:%s*(%d+)")
        local name, x, y, z, map = line:match("%[(.-)%s+X:" .. NUMBER .. "%s+Y:" .. NUMBER .. "%s+Z:" .. NUMBER .. "%s+MapId:%s*(%d+)%]")
        if guid and name then
            found[#found + 1] = {
                guid = tonumber(guid), entry = tonumber(entry), name = name,
                x = tonumber(x), y = tonumber(y), z = tonumber(z), map = tonumber(map),
            }
        end
    end
    return found
end

function F.ParseLookup(lines)
    local found = {}
    for _, line in ipairs(lines or {}) do
        local id, name = line:match("^(%d+)%s*%-%s*.-|H[%w_]+:%d+.-|h%[(.-)%]|h")
        if not id then
            id, name = line:match("^(%d+)%s*%-%s*(.+)$")
            if name then name = F.Strip(name) end
        end
        if id then
            found[#found + 1] = { id = tonumber(id), name = F.Trim(name) }
        end
    end
    return found
end

function F.ParseAddedGameObject(lines)
    return tonumber(F.Join(lines):match("GUID:%s*(%d+)"))
end

function F.Distance(a, b)
    if not a or not b then return math.huge end
    local dx, dy, dz = (a.x or 0) - (b.x or 0), (a.y or 0) - (b.y or 0), (a.z or 0) - (b.z or 0)
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function F.Defaults(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then
            if type(value) == "table" then
                target[key] = {}
                F.Defaults(target[key], value)
            else
                target[key] = value
            end
        end
    end
    return target
end
