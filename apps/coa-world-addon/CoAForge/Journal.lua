CoAForge = CoAForge or {}
local F = CoAForge

local Journal = {}
F.Journal = Journal

local MAX_ENTRIES = 400
local COALESCE_SECONDS = 3

local function db()
    return CoAForgeDB
end

function Journal:Entries()
    return db().journal
end

function Journal:Cursor()
    return db().cursor
end

function Journal:CanUndo()
    return db().cursor > 0
end

function Journal:CanRedo()
    return db().cursor < #db().journal
end

function Journal:UndoLabel()
    local entry = db().journal[db().cursor]
    return entry and entry.label
end

function Journal:RedoLabel()
    local entry = db().journal[db().cursor + 1]
    return entry and entry.label
end

local function truncate()
    local store = db()
    for index = #store.journal, store.cursor + 1, -1 do
        store.journal[index] = nil
    end
end

local function trim()
    local store = db()
    while #store.journal > MAX_ENTRIES do
        table.remove(store.journal, 1)
        store.cursor = math.max(0, store.cursor - 1)
    end
end

function Journal:Record(action)
    local store = db()
    truncate()
    local top = store.journal[store.cursor]
    if top and action.coalesce and top.coalesce == action.coalesce
        and (time() - (top.at or 0)) <= COALESCE_SECONDS then
        top.redo = action.redo
        top.after = action.after
        top.at = time()
        top.label = action.label
    else
        store.journal[store.cursor + 1] = {
            at = time(),
            label = action.label,
            kind = action.kind,
            coalesce = action.coalesce,
            target = action.target,
            redo = action.redo,
            undo = action.undo,
            before = action.before,
            after = action.after,
        }
        store.cursor = store.cursor + 1
    end
    trim()
    store.dirty = (store.dirty or 0) + 1
    if action.persistent ~= false then
        self:Log(action)
    end
    F.Events:Fire("JOURNAL")
end

function Journal:Log(action)
    local store = db()
    store.log[#store.log + 1] = {
        at = time(),
        kind = action.kind,
        label = action.label,
        target = action.target,
        before = action.before,
        after = action.after,
    }
    while #store.log > 4000 do
        table.remove(store.log, 1)
    end
end

function Journal:Apply(action)
    F.Rpc:SendSequence(action.redo, function(ok, lines)
        if not ok then
            F.Warn((action.label or "change") .. " failed: " .. F.Strip(F.Join(lines)))
            return
        end
        if action.onApplied then action.onApplied() end
    end)
    self:Record(action)
end

function Journal:Undo()
    if not self:CanUndo() then
        F.Warn("nothing to undo")
        return
    end
    local store = db()
    local entry = store.journal[store.cursor]
    store.cursor = store.cursor - 1
    F.Rpc:SendSequence(entry.undo, function(ok, lines)
        if ok then
            F.Print("undid " .. (entry.label or "change"))
        else
            F.Warn("undo failed: " .. F.Strip(F.Join(lines)))
        end
        F.Events:Fire("TARGET")
    end)
    self:Log({ kind = "undo", label = entry.label, target = entry.target,
               before = entry.after, after = entry.before })
    F.Events:Fire("JOURNAL")
end

function Journal:Redo()
    if not self:CanRedo() then
        F.Warn("nothing to redo")
        return
    end
    local store = db()
    local entry = store.journal[store.cursor + 1]
    store.cursor = store.cursor + 1
    F.Rpc:SendSequence(entry.redo, function(ok, lines)
        if ok then
            F.Print("redid " .. (entry.label or "change"))
        else
            F.Warn("redo failed: " .. F.Strip(F.Join(lines)))
        end
        F.Events:Fire("TARGET")
    end)
    self:Log({ kind = "redo", label = entry.label, target = entry.target,
               before = entry.before, after = entry.after })
    F.Events:Fire("JOURNAL")
end

function Journal:Clear()
    local store = db()
    store.journal = {}
    store.cursor = 0
    F.Events:Fire("JOURNAL")
end

local Events = { handlers = {} }
F.Events = Events

function Events:Register(name, handler)
    self.handlers[name] = self.handlers[name] or {}
    table.insert(self.handlers[name], handler)
end

function Events:Fire(name, ...)
    for _, handler in ipairs(self.handlers[name] or {}) do
        local ok, err = pcall(handler, ...)
        if not ok then F.Warn("handler error: " .. tostring(err)) end
    end
end
