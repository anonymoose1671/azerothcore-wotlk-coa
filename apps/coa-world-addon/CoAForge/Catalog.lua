CoAForge = CoAForge or {}
local F = CoAForge

CoAForgeData = CoAForgeData or { creatureDisplays = "", objectDisplays = "", visualAuras = "" }

local Catalog = {}
F.Catalog = Catalog

function Catalog:Init()
    self.ready = true
end

local function scan(blob, text, limit)
    local results = {}
    local total = 0
    if not blob or blob == "" then return results, total end
    local needle = F.Trim(tostring(text or "")):lower()
    local wantedId = tonumber(needle)
    limit = limit or 300
    for line in blob:gmatch("[^\n]+") do
        local id, label = line:match("^(%d+)\t(.*)$")
        if id then
            local keep
            if needle == "" then
                keep = true
            elseif wantedId and tonumber(id) == wantedId then
                keep = true
            else
                keep = label:lower():find(needle, 1, true) ~= nil
            end
            if keep then
                total = total + 1
                if #results < limit then
                    results[#results + 1] = { id = tonumber(id), label = label }
                end
            end
        end
    end
    return results, total
end

function Catalog:SearchDisplays(text, limit)
    return scan(CoAForgeData.creatureDisplays, text, limit)
end

function Catalog:SearchObjectDisplays(text, limit)
    return scan(CoAForgeData.objectDisplays, text, limit)
end

function Catalog:SearchAuras(text, limit)
    return scan(CoAForgeData.visualAuras, text, limit)
end

function Catalog:Summary()
    return CoAForgeData.generated or "no catalog generated"
end
