CoAForge = CoAForge or {}
local F = CoAForge

local DEFAULTS = {
    journal = {},
    log = {},
    cursor = 0,
    pending = {},
    bookmarks = {},
    questWatch = {},
    dirty = 0,
    step = 1,
    useAoeCursor = true,
    scanRange = 30,
    minimapAngle = 200,
    editing = false,
}

local BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
}

local INSET = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

local ROW_HEIGHT = 16
local TABS = { "Place", "Look", "Quest", "Browse", "Changes" }

local UI = {}
F.UI = UI

local window, tabPanels, statusText, undoButton, redoButton, dirtyText

local function Label(parent, text, size)
    local label = parent:CreateFontString(nil, "OVERLAY", size or "GameFontNormalSmall")
    label:SetText(text)
    return label
end

local function Button(parent, text, width, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetWidth(width or 80)
    button:SetHeight(20)
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    return button
end

local function Edit(parent, width, onAccept)
    local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    box:SetWidth(width or 60)
    box:SetHeight(18)
    box:SetAutoFocus(false)
    box:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        if onAccept then onAccept(self:GetText()) end
    end)
    box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    return box
end

local function Panel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints(parent)
    panel:Hide()
    return panel
end

local function ScrollList(parent, width, height, buildRow)
    local rows = math.floor(height / ROW_HEIGHT)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetWidth(width)
    holder:SetHeight(height)
    holder:SetBackdrop(INSET)
    holder:SetBackdropColor(0, 0, 0, 0.5)

    local scroll = CreateFrame("ScrollFrame", "CoAForgeScroll" .. tostring(GetTime()) .. tostring(math.random(99999)),
        holder, "FauxScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 4, -4)
    scroll:SetPoint("BOTTOMRIGHT", -26, 4)

    holder.buttons = {}
    for index = 1, rows do
        local row = CreateFrame("Button", nil, holder)
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", 6, -4 - (index - 1) * ROW_HEIGHT)
        row:SetPoint("RIGHT", scroll, "RIGHT", 0, 0)
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT")
        row.text:SetPoint("RIGHT")
        row.text:SetJustifyH("LEFT")
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        holder.buttons[index] = row
    end

    holder.data = {}

    function holder:Refresh()
        local offset = FauxScrollFrame_GetOffset(scroll)
        FauxScrollFrame_Update(scroll, #self.data, rows, ROW_HEIGHT)
        for index = 1, rows do
            local row = self.buttons[index]
            local item = self.data[index + offset]
            if item then
                buildRow(row, item)
                row:Show()
            else
                row:Hide()
            end
        end
    end

    function holder:SetData(data)
        self.data = data or {}
        self:Refresh()
    end

    scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, function() holder:Refresh() end)
    end)

    return holder
end

local function TextArea(parent, width, height)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetWidth(width)
    holder:SetHeight(height)
    holder:SetBackdrop(INSET)
    holder:SetBackdropColor(0, 0, 0, 0.6)
    local scroll = CreateFrame("ScrollFrame", "CoAForgeTextScroll", holder, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 6, -6)
    scroll:SetPoint("BOTTOMRIGHT", -28, 6)
    local box = CreateFrame("EditBox", nil, scroll)
    box:SetMultiLine(true)
    box:SetAutoFocus(false)
    box:SetFontObject("GameFontHighlightSmall")
    box:SetWidth(width - 40)
    box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    scroll:SetScrollChild(box)
    holder.box = box
    return holder
end

local function SelectionSummary()
    local selection = F.Selection
    if not selection then return "no selection" end
    return string.format("%s  |cffaaaaaaguid|r %s  |cffaaaaaaentry|r %s  |cffaaaaaadisplay|r %s",
        tostring(selection.name or "?"), tostring(selection.guid or "?"),
        tostring(selection.entry or "?"), tostring(selection.display or "-"))
end

local function BuildPlaceTab(panel)
    local target = Label(panel, "no selection", "GameFontNormal")
    target:SetPoint("TOPLEFT", 12, -10)

    local position = Label(panel, "", "GameFontHighlightSmall")
    position:SetPoint("TOPLEFT", 12, -28)

    local refresh = Button(panel, "Refresh", 70, function() F.Forge:RefreshTarget() end)
    refresh:SetPoint("TOPRIGHT", -12, -6)

    local stepLabel = Label(panel, "Step")
    stepLabel:SetPoint("TOPLEFT", 12, -52)
    local stepButton
    stepButton = Button(panel, tostring(CoAForgeDB.step) .. " yd", 60, function()
        local steps = { 0.1, 0.25, 0.5, 1, 2, 5, 10 }
        local index = 1
        for i, value in ipairs(steps) do if value == CoAForgeDB.step then index = i end end
        CoAForgeDB.step = steps[(index % #steps) + 1]
        stepButton:SetText(tostring(CoAForgeDB.step) .. " yd")
    end)
    stepButton:SetPoint("LEFT", stepLabel, "RIGHT", 6, 0)

    local function nudge(dx, dy, dz)
        return function()
            local s = CoAForgeDB.step
            F.Forge:Nudge(dx * s, dy * s, dz * s)
        end
    end

    local north = Button(panel, "N +X", 52, nudge(1, 0, 0))
    north:SetPoint("TOPLEFT", 150, -46)
    local south = Button(panel, "S -X", 52, nudge(-1, 0, 0))
    south:SetPoint("TOPLEFT", north, "BOTTOMLEFT", 0, -22)
    local west = Button(panel, "W +Y", 52, nudge(0, 1, 0))
    west:SetPoint("RIGHT", north, "LEFT", -4, -11)
    local east = Button(panel, "E -Y", 52, nudge(0, -1, 0))
    east:SetPoint("LEFT", north, "RIGHT", 4, -11)
    local up = Button(panel, "Up", 46, nudge(0, 0, 1))
    up:SetPoint("LEFT", east, "RIGHT", 12, 11)
    local down = Button(panel, "Down", 46, nudge(0, 0, -1))
    down:SetPoint("LEFT", east, "RIGHT", 12, -11)

    local turnLeft = Button(panel, "Turn -45", 66, function()
        if F.Selection then F.Forge:Face((F.Selection.o or 0) - math.pi / 4) end
    end)
    turnLeft:SetPoint("TOPLEFT", 12, -112)
    local turnRight = Button(panel, "Turn +45", 66, function()
        if F.Selection then F.Forge:Face((F.Selection.o or 0) + math.pi / 4) end
    end)
    turnRight:SetPoint("LEFT", turnLeft, "RIGHT", 4, 0)
    local faceMe = Button(panel, "Face me", 66, function()
        F.Forge:ReadPlayerPosition(function(me)
            local s = F.Selection
            if me and s then
                F.Forge:Face(math.atan2(me.y - s.y, me.x - s.x))
            end
        end)
    end)
    faceMe:SetPoint("LEFT", turnRight, "RIGHT", 4, 0)

    local toCursor = Button(panel, "Move to cursor", 110, function() F.Forge:MoveToCursor() end)
    toCursor:SetPoint("TOPLEFT", turnLeft, "BOTTOMLEFT", 0, -6)
    local ground = Button(panel, "Drop to ground", 110, function() F.Forge:DropToGround() end)
    ground:SetPoint("LEFT", toCursor, "RIGHT", 4, 0)

    local copy = Button(panel, "Copy", 60, function() F.Forge:Copy() end)
    copy:SetPoint("LEFT", ground, "RIGHT", 12, 0)
    local paste = Button(panel, "Paste", 60, function() F.Forge:Paste() end)
    paste:SetPoint("LEFT", copy, "RIGHT", 4, 0)

    local moveLabel = Label(panel, "Movement")
    moveLabel:SetPoint("TOPLEFT", toCursor, "BOTTOMLEFT", 0, -12)
    local moveType
    moveType = Button(panel, "stay", 64, function()
        local order = { "stay", "random", "way" }
        local current = moveType:GetText()
        local index = 1
        for i, value in ipairs(order) do if value == current then index = i end end
        local nextType = order[(index % #order) + 1]
        moveType:SetText(nextType)
        F.Forge:SetMoveType(nextType)
    end)
    moveType:SetPoint("LEFT", moveLabel, "RIGHT", 6, 0)

    local wanderLabel = Label(panel, "Wander")
    wanderLabel:SetPoint("LEFT", moveType, "RIGHT", 12, 0)
    local wander = Edit(panel, 46, function(text)
        local value = tonumber(text)
        if value then F.Forge:SetWander(value) end
    end)
    wander:SetPoint("LEFT", wanderLabel, "RIGHT", 8, 0)

    local respawnLabel = Label(panel, "Respawn s")
    respawnLabel:SetPoint("LEFT", wander, "RIGHT", 12, 0)
    local respawn = Edit(panel, 52, function(text)
        local value = tonumber(text)
        if value then F.Forge:SetSpawnTime(math.floor(value)) end
    end)
    respawn:SetPoint("LEFT", respawnLabel, "RIGHT", 8, 0)

    local spawnLabel = Label(panel, "Entry")
    spawnLabel:SetPoint("TOPLEFT", moveLabel, "BOTTOMLEFT", 0, -16)
    local spawnEntry = Edit(panel, 80)
    spawnEntry:SetPoint("LEFT", spawnLabel, "RIGHT", 8, 0)
    local spawnNpc = Button(panel, "Spawn NPC", 90, function()
        local entry = tonumber(spawnEntry:GetText())
        if entry then F.Forge:SpawnCreature(entry) else F.Warn("enter a creature entry") end
    end)
    spawnNpc:SetPoint("LEFT", spawnEntry, "RIGHT", 8, 0)
    local spawnObject = Button(panel, "Spawn object", 96, function()
        local entry = tonumber(spawnEntry:GetText())
        if entry then F.Forge:SpawnObject(entry) else F.Warn("enter a gameobject entry") end
    end)
    spawnObject:SetPoint("LEFT", spawnNpc, "RIGHT", 4, 0)
    local remove = Button(panel, "Delete", 66, function() F.Forge:DeleteSelection() end)
    remove:SetPoint("LEFT", spawnObject, "RIGHT", 12, 0)

    local scanLabel = Label(panel, "Nearby spawns (click to select)")
    scanLabel:SetPoint("TOPLEFT", spawnLabel, "BOTTOMLEFT", 0, -14)
    local scan = Button(panel, "Scan", 60, function()
        F.Forge:ScanNear(CoAForgeDB.scanRange, function(result)
            local rows = {}
            for _, row in ipairs(result.creatures) do
                row.kind = "creature"
                rows[#rows + 1] = row
            end
            for _, row in ipairs(result.objects) do
                row.kind = "gameobject"
                rows[#rows + 1] = row
            end
            panel.list:SetData(rows)
        end)
    end)
    scan:SetPoint("LEFT", scanLabel, "RIGHT", 8, 0)

    panel.list = ScrollList(panel, 560, 140, function(row, item)
        local tag = item.kind == "gameobject" and "|cffffcc66OBJ|r" or "|cff88ff88NPC|r"
        row.text:SetText(string.format("%s %s  |cffaaaaaa%s / %s|r", tag, tostring(item.name),
            tostring(item.guid), tostring(item.entry)))
        row:SetScript("OnClick", function()
            if item.kind == "gameobject" then
                F.Forge:SelectGameObject(item.guid)
            else
                F.Print("target " .. tostring(item.name) .. " in game, then press Refresh")
            end
        end)
    end)
    panel.list:SetPoint("TOPLEFT", scanLabel, "BOTTOMLEFT", 0, -6)

    local function update()
        target:SetText(SelectionSummary())
        local selection = F.Selection
        if selection then
            position:SetText(string.format("x %.3f  y %.3f  z %.3f  o %.3f  map %s",
                selection.x or 0, selection.y or 0, selection.z or 0, selection.o or 0,
                tostring(selection.map or 0)))
        else
            position:SetText("target a creature and press Refresh, or Scan and pick an object")
        end
    end
    F.Events:Register("TARGET", update)
    panel.Update = update
end

local function BuildLookTab(panel)
    local target = Label(panel, "", "GameFontNormal")
    target:SetPoint("TOPLEFT", 12, -10)

    local displayLabel = Label(panel, "Display id")
    displayLabel:SetPoint("TOPLEFT", 12, -34)
    local displayBox = Edit(panel, 80)
    displayBox:SetPoint("LEFT", displayLabel, "RIGHT", 8, 0)
    local applyDisplay = Button(panel, "Apply (saved)", 100, function()
        local value = tonumber(displayBox:GetText())
        if value then F.Forge:SetDisplay(value) end
    end)
    applyDisplay:SetPoint("LEFT", displayBox, "RIGHT", 8, 0)

    local searchLabel = Label(panel, "Find model")
    searchLabel:SetPoint("TOPLEFT", displayLabel, "BOTTOMLEFT", 0, -14)
    local searchBox = Edit(panel, 150, function(text)
        panel.displayList:SetData(F.Catalog:SearchDisplays(text, 200))
    end)
    searchBox:SetPoint("LEFT", searchLabel, "RIGHT", 8, 0)
    local searchGo = Button(panel, "Search", 66, function()
        panel.displayList:SetData(F.Catalog:SearchDisplays(searchBox:GetText(), 200))
    end)
    searchGo:SetPoint("LEFT", searchBox, "RIGHT", 8, 0)

    panel.displayList = ScrollList(panel, 270, 190, function(row, item)
        row.text:SetText(string.format("|cffffd100%s|r %s", item.id, item.label))
        row:SetScript("OnClick", function()
            displayBox:SetText(tostring(item.id))
            F.Forge:SetDisplay(item.id)
        end)
    end)
    panel.displayList:SetPoint("TOPLEFT", searchLabel, "BOTTOMLEFT", 0, -8)

    local scaleLabel = Label(panel, "Scale (preview only)")
    scaleLabel:SetPoint("TOPLEFT", 300, -34)
    local scaleBox = Edit(panel, 56)
    scaleBox:SetPoint("LEFT", scaleLabel, "RIGHT", 8, 0)
    scaleBox:SetText("1.0")
    local applyScale = Button(panel, "Preview", 70, function()
        local value = tonumber(scaleBox:GetText())
        if value then F.Forge:PreviewScale(value) end
    end)
    applyScale:SetPoint("TOPLEFT", scaleLabel, "BOTTOMLEFT", 0, -4)
    local thirds = Button(panel, "x0.33", 56, function()
        F.Forge:PreviewScale(0.33)
        scaleBox:SetText("0.33")
    end)
    thirds:SetPoint("LEFT", applyScale, "RIGHT", 4, 0)
    local resetScale = Button(panel, "Reset", 56, function()
        F.Forge:PreviewScale(1)
        scaleBox:SetText("1.0")
    end)
    resetScale:SetPoint("LEFT", thirds, "RIGHT", 4, 0)

    local auraLabel = Label(panel, "Visual effect")
    auraLabel:SetPoint("TOPLEFT", 300, -88)
    local auraBox = Edit(panel, 70)
    auraBox:SetPoint("LEFT", auraLabel, "RIGHT", 8, 0)
    local applyAura = Button(panel, "Apply", 56, function()
        local value = tonumber(auraBox:GetText())
        if value then F.Forge:PreviewAura(value) end
    end)
    applyAura:SetPoint("LEFT", auraBox, "RIGHT", 6, 0)
    local clearAura = Button(panel, "Clear all", 70, function() F.Forge:ClearAuras() end)
    clearAura:SetPoint("LEFT", applyAura, "RIGHT", 4, 0)

    local auraSearch = Edit(panel, 150, function(text)
        panel.auraList:SetData(F.Catalog:SearchAuras(text, 200))
    end)
    auraSearch:SetPoint("TOPLEFT", auraLabel, "BOTTOMLEFT", 0, -26)
    local auraGo = Button(panel, "Search", 66, function()
        panel.auraList:SetData(F.Catalog:SearchAuras(auraSearch:GetText(), 200))
    end)
    auraGo:SetPoint("LEFT", auraSearch, "RIGHT", 8, 0)

    panel.auraList = ScrollList(panel, 270, 150, function(row, item)
        row.text:SetText(string.format("|cffffd100%s|r %s", item.id, item.label))
        row:SetScript("OnClick", function()
            auraBox:SetText(tostring(item.id))
            F.Forge:PreviewAura(item.id)
        end)
    end)
    panel.auraList:SetPoint("TOPLEFT", auraSearch, "BOTTOMLEFT", 0, -8)

    local queued = Button(panel, "Apply queued to target", 160, function() F.Forge:ApplyQueued() end)
    queued:SetPoint("BOTTOMLEFT", 12, 10)

    local note = Label(panel, "", "GameFontDisableSmall")
    note:SetPoint("LEFT", queued, "RIGHT", 10, 0)
    note:SetText("Scale and effects are live previews; export them from Changes.")

    local function update()
        target:SetText(SelectionSummary())
    end
    F.Events:Register("TARGET", update)
    F.Events:Register("PENDING", update)
    panel.Update = function()
        update()
        if #panel.displayList.data == 0 then
            panel.displayList:SetData(F.Catalog:SearchDisplays("", 200))
        end
        if #panel.auraList.data == 0 then
            panel.auraList:SetData(F.Catalog:SearchAuras("", 200))
        end
    end
end

local function BuildQuestTab(panel)
    local questLabel = Label(panel, "Quest id")
    questLabel:SetPoint("TOPLEFT", 12, -14)
    local questBox = Edit(panel, 90)
    questBox:SetPoint("LEFT", questLabel, "RIGHT", 8, 0)

    local function questAction(action)
        return function()
            local id = tonumber(questBox:GetText())
            if id then F.Forge:Quest(action, id) else F.Warn("enter a quest id") end
        end
    end

    local add = Button(panel, "Add", 60, questAction("add"))
    add:SetPoint("LEFT", questBox, "RIGHT", 10, 0)
    local complete = Button(panel, "Complete", 76, questAction("complete"))
    complete:SetPoint("LEFT", add, "RIGHT", 4, 0)
    local reward = Button(panel, "Reward", 66, questAction("reward"))
    reward:SetPoint("LEFT", complete, "RIGHT", 4, 0)
    local drop = Button(panel, "Remove", 70, questAction("remove"))
    drop:SetPoint("LEFT", reward, "RIGHT", 4, 0)
    local retake = Button(panel, "Reset", 60, function()
        local id = tonumber(questBox:GetText())
        if not id then return F.Warn("enter a quest id") end
        F.Rpc:SendSequence({ "quest remove " .. id }, function()
            F.Print("quest " .. id .. " removed; pick it up again to retest")
        end)
    end)
    retake:SetPoint("LEFT", drop, "RIGHT", 4, 0)

    local watchAdd = Button(panel, "Watch", 60, function()
        local id = tonumber(questBox:GetText())
        if not id then return end
        for _, existing in ipairs(CoAForgeDB.questWatch) do
            if existing == id then return end
        end
        table.insert(CoAForgeDB.questWatch, id)
        panel.Update()
    end)
    watchAdd:SetPoint("TOPLEFT", questLabel, "BOTTOMLEFT", 0, -10)

    local watchLabel = Label(panel, "Watched quests (click removes, shift-click completes)")
    watchLabel:SetPoint("LEFT", watchAdd, "RIGHT", 10, 0)

    panel.watchList = ScrollList(panel, 270, 120, function(row, item)
        row.text:SetText("quest " .. tostring(item))
        row:RegisterForClicks("LeftButtonUp")
        row:SetScript("OnClick", function()
            if IsShiftKeyDown() then
                F.Forge:Quest("complete", item)
            else
                for index, value in ipairs(CoAForgeDB.questWatch) do
                    if value == item then table.remove(CoAForgeDB.questWatch, index) break end
                end
                panel.Update()
            end
        end)
    end)
    panel.watchList:SetPoint("TOPLEFT", watchAdd, "BOTTOMLEFT", 0, -8)

    local reloadLabel = Label(panel, "Reload server data")
    reloadLabel:SetPoint("TOPLEFT", 300, -44)
    local reloads = {
        { "quest_template", "quest_template" },
        { "quest givers", "creature_queststarter" },
        { "quest enders", "creature_questender" },
        { "object givers", "gameobject_queststarter" },
        { "object enders", "gameobject_questender" },
        { "quest POI", "quest_poi" },
        { "smart scripts", "smart_scripts" },
        { "creature text", "creature_text" },
    }
    local previous
    for index, entry in ipairs(reloads) do
        local button = Button(panel, entry[1], 130, function() F.Forge:Reload(entry[2]) end)
        if index == 1 then
            button:SetPoint("TOPLEFT", reloadLabel, "BOTTOMLEFT", 0, -6)
        else
            button:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -2)
        end
        previous = button
    end

    local bookmarkLabel = Label(panel, "Bookmark")
    bookmarkLabel:SetPoint("TOPLEFT", 12, -230)
    local bookmarkBox = Edit(panel, 120)
    bookmarkBox:SetPoint("LEFT", bookmarkLabel, "RIGHT", 8, 0)
    local saveMark = Button(panel, "Save here", 84, function()
        local name = F.Trim(bookmarkBox:GetText())
        if name == "" then return F.Warn("name the bookmark first") end
        F.Forge:SaveBookmark(name)
        bookmarkBox:SetText("")
    end)
    saveMark:SetPoint("LEFT", bookmarkBox, "RIGHT", 8, 0)

    panel.markList = ScrollList(panel, 270, 100, function(row, item)
        row.text:SetText(string.format("%s |cffaaaaaa%.0f %.0f %.0f|r", item.mark.name,
            item.mark.x, item.mark.y, item.mark.z))
        row:SetScript("OnClick", function()
            if IsShiftKeyDown() then
                table.remove(CoAForgeDB.bookmarks, item.index)
                panel.Update()
            else
                F.Forge:GoBookmark(item.index)
            end
        end)
    end)
    panel.markList:SetPoint("TOPLEFT", bookmarkLabel, "BOTTOMLEFT", 0, -26)

    local testLabel = Label(panel, "Test helpers")
    testLabel:SetPoint("TOPLEFT", 300, -230)
    local helpers = {
        { "Respawn nearby", "respawn all" },
        { "Revive me", "revive" },
        { "GM on", "gm on" },
        { "GM off", "gm off" },
        { "Fly on", "gm fly on" },
        { "Fly off", "gm fly off" },
    }
    local last
    for index, entry in ipairs(helpers) do
        local button = Button(panel, entry[1], 130, function() F.Rpc:Send(entry[2]) end)
        if index == 1 then
            button:SetPoint("TOPLEFT", testLabel, "BOTTOMLEFT", 0, -6)
        else
            button:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -2)
        end
        last = button
    end

    panel.Update = function()
        panel.watchList:SetData(CoAForgeDB.questWatch)
        local marks = {}
        for index, mark in ipairs(CoAForgeDB.bookmarks) do
            marks[#marks + 1] = { index = index, mark = mark }
        end
        panel.markList:SetData(marks)
    end
    F.Events:Register("BOOKMARKS", function() panel.Update() end)
end

local function BuildBrowseTab(panel)
    local kinds = { "creature", "object", "item", "spell", "quest" }
    local kindIndex = 1

    local kindButton
    kindButton = Button(panel, kinds[kindIndex], 90, function()
        kindIndex = (kindIndex % #kinds) + 1
        kindButton:SetText(kinds[kindIndex])
    end)
    kindButton:SetPoint("TOPLEFT", 12, -14)

    local searchBox = Edit(panel, 240)
    searchBox:SetPoint("LEFT", kindButton, "RIGHT", 10, 0)

    local function run()
        local text = F.Trim(searchBox:GetText())
        if text == "" then return F.Warn("type something to search for") end
        F.Forge:Lookup(kinds[kindIndex], text, function(results)
            panel.list:SetData(results)
            F.Print(#results .. " result(s) for " .. text)
        end)
    end
    searchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() run() end)

    local go = Button(panel, "Search", 70, run)
    go:SetPoint("LEFT", searchBox, "RIGHT", 10, 0)

    local hint = Label(panel, "Searches the live server database. Click a row to use it.", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", kindButton, "BOTTOMLEFT", 0, -8)

    panel.list = ScrollList(panel, 560, 300, function(row, item)
        row.text:SetText(string.format("|cffffd100%s|r  %s", item.id, item.name or ""))
        row:SetScript("OnClick", function()
            local kind = kinds[kindIndex]
            if kind == "creature" then
                F.Forge:SpawnCreature(item.id)
            elseif kind == "object" then
                F.Forge:SpawnObject(item.id)
            elseif kind == "spell" then
                F.Forge:PreviewAura(item.id)
            elseif kind == "quest" then
                F.Forge:Quest("add", item.id)
            else
                F.Print(kind .. " " .. item.id .. " " .. tostring(item.name))
            end
        end)
    end)
    panel.list:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -8)

    panel.Update = function() end
end

local function BuildChangesTab(panel)
    local hint = Label(panel, "History. Click a row to jump the undo cursor there.", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", 12, -12)

    panel.list = ScrollList(panel, 560, 200, function(row, item)
        local marker = item.index == CoAForgeDB.cursor and "|cff00ff00>|r " or "  "
        local colour = item.index <= CoAForgeDB.cursor and "|cffffffff" or "|cff777777"
        row.text:SetText(marker .. colour .. tostring(item.entry.label) .. "|r")
        row:SetScript("OnClick", function()
            local steps = item.index - CoAForgeDB.cursor
            if steps < 0 then
                for _ = 1, -steps do F.Journal:Undo() end
            elseif steps > 0 then
                for _ = 1, steps do F.Journal:Redo() end
            end
        end)
    end)
    panel.list:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -6)

    local exportButton = Button(panel, "Build export", 100, function()
        panel.text.box:SetText(F.Forge:Export())
        panel.text.box:HighlightText()
        panel.text.box:SetFocus()
    end)
    exportButton:SetPoint("TOPLEFT", panel.list, "BOTTOMLEFT", 0, -8)

    local flush = Button(panel, "Save to disk (reloads UI)", 170, function()
        CoAForgeDB.dirty = 0
        ReloadUI()
    end)
    flush:SetPoint("LEFT", exportButton, "RIGHT", 6, 0)

    local clear = Button(panel, "Clear history", 110, function() F.Journal:Clear() end)
    clear:SetPoint("LEFT", flush, "RIGHT", 6, 0)

    panel.text = TextArea(panel, 560, 110)
    panel.text:SetPoint("TOPLEFT", exportButton, "BOTTOMLEFT", 0, -8)

    panel.Update = function()
        local rows = {}
        for index, entry in ipairs(CoAForgeDB.journal) do
            rows[#rows + 1] = { index = index, entry = entry }
        end
        panel.list:SetData(rows)
    end
    F.Events:Register("JOURNAL", function() panel.Update() end)
end

local function UpdateHeader()
    if not window then return end
    local undoLabel = F.Journal:UndoLabel()
    local redoLabel = F.Journal:RedoLabel()
    undoButton:SetText("Undo")
    redoButton:SetText("Redo")
    if F.Journal:CanUndo() then undoButton:Enable() else undoButton:Disable() end
    if F.Journal:CanRedo() then redoButton:Enable() else redoButton:Disable() end
    statusText:SetText(undoLabel and ("last: " .. undoLabel) or "no changes yet")
    local dirty = CoAForgeDB.dirty or 0
    if dirty > 0 then
        dirtyText:SetText("|cffffcc00" .. dirty .. " unsaved|r")
    else
        dirtyText:SetText("")
    end
end

function UI:SelectTab(name)
    for tabName, panel in pairs(tabPanels) do
        if tabName == name then
            panel:Show()
            if panel.Update then panel.Update() end
        else
            panel:Hide()
        end
    end
    CoAForgeDB.tab = name
    for _, tab in ipairs(window.tabs) do
        if tab.tabName == name then
            tab:SetNormalFontObject("GameFontHighlightSmall")
        else
            tab:SetNormalFontObject("GameFontDisableSmall")
        end
    end
end

local function BuildWindow()
    window = CreateFrame("Frame", "CoAForgeWindow", UIParent)
    window:SetWidth(620)
    window:SetHeight(560)
    window:SetPoint("CENTER")
    window:SetBackdrop(BACKDROP)
    window:SetMovable(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)
    window:SetClampedToScreen(true)
    window:Hide()
    tinsert(UISpecialFrames, "CoAForgeWindow")

    local title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText("CoA Forge")

    local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -6, -6)
    close:SetScript("OnClick", function() UI:SetEditing(false) end)

    undoButton = Button(window, "Undo", 70, function() F.Journal:Undo() end)
    undoButton:SetPoint("TOPLEFT", 16, -40)
    redoButton = Button(window, "Redo", 70, function() F.Journal:Redo() end)
    redoButton:SetPoint("LEFT", undoButton, "RIGHT", 4, 0)

    statusText = window:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    statusText:SetPoint("LEFT", redoButton, "RIGHT", 10, 0)

    dirtyText = window:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dirtyText:SetPoint("TOPRIGHT", -30, -46)

    local body = CreateFrame("Frame", nil, window)
    body:SetPoint("TOPLEFT", 14, -92)
    body:SetPoint("BOTTOMRIGHT", -14, 14)
    body:SetBackdrop(INSET)
    body:SetBackdropColor(0, 0, 0, 0.25)

    window.tabs = {}
    tabPanels = {}
    local previous
    for _, name in ipairs(TABS) do
        local tab = Button(window, name, 96, function() UI:SelectTab(name) end)
        tab.tabName = name
        if previous then
            tab:SetPoint("LEFT", previous, "RIGHT", 2, 0)
        else
            tab:SetPoint("TOPLEFT", 16, -66)
        end
        previous = tab
        window.tabs[#window.tabs + 1] = tab
        tabPanels[name] = Panel(body)
    end

    BuildPlaceTab(tabPanels.Place)
    BuildLookTab(tabPanels.Look)
    BuildQuestTab(tabPanels.Quest)
    BuildBrowseTab(tabPanels.Browse)
    BuildChangesTab(tabPanels.Changes)

    F.Events:Register("JOURNAL", UpdateHeader)
    F.Events:Register("TARGET", UpdateHeader)
end

local function BuildHiddenButtons()
    local copy = CreateFrame("Button", "CoAForgeCopyButton", UIParent)
    copy:SetScript("OnClick", function() F.Forge:Copy() end)
    local paste = CreateFrame("Button", "CoAForgePasteButton", UIParent)
    paste:SetScript("OnClick", function() F.Forge:Paste() end)
    local undo = CreateFrame("Button", "CoAForgeUndoButton", UIParent)
    undo:SetScript("OnClick", function() F.Journal:Undo() end)
    local redo = CreateFrame("Button", "CoAForgeRedoButton", UIParent)
    redo:SetScript("OnClick", function() F.Journal:Redo() end)
end

local function BuildMinimapButton()
    local button = CreateFrame("Button", "CoAForgeMinimapButton", Minimap)
    button:SetWidth(31)
    button:SetHeight(31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)

    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetWidth(53)
    overlay:SetHeight(53)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetPoint("TOPLEFT")

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetWidth(20)
    icon:SetHeight(20)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
    icon:SetPoint("TOPLEFT", 7, -6)
    button.icon = icon

    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local function place()
        local angle = math.rad(CoAForgeDB.minimapAngle or 200)
        button:SetPoint("TOPLEFT", Minimap, "TOPLEFT",
            54 - 80 * math.cos(angle), 80 * math.sin(angle) - 55)
    end

    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function(self) self.dragging = true end)
    button:SetScript("OnDragStop", function(self) self.dragging = false end)
    button:SetScript("OnUpdate", function(self)
        if not self.dragging then return end
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        CoAForgeDB.minimapAngle = math.deg(math.atan2(py / scale - my, px / scale - mx))
        place()
    end)

    button:SetScript("OnClick", function() UI:SetEditing(not CoAForgeDB.editing) end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("CoA Forge")
        GameTooltip:AddLine(CoAForgeDB.editing and "Edit mode ON" or "Edit mode off", 1, 1, 1)
        GameTooltip:AddLine("Click to toggle. Drag to move.", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    place()
    UI.minimapButton = button
end

function UI:SetEditing(on)
    CoAForgeDB.editing = on and true or false
    if on then
        window:Show()
        UI:SelectTab(CoAForgeDB.tab or "Place")
        SetOverrideBindingClick(window, true, "CTRL-C", "CoAForgeCopyButton")
        SetOverrideBindingClick(window, true, "CTRL-V", "CoAForgePasteButton")
        SetOverrideBindingClick(window, true, "CTRL-Z", "CoAForgeUndoButton")
        SetOverrideBindingClick(window, true, "CTRL-Y", "CoAForgeRedoButton")
        UI.minimapButton.icon:SetVertexColor(0.4, 1, 0.4)
        F.Forge:RefreshTarget()
        F.Print("edit mode on. Ctrl-C copy, Ctrl-V paste, Ctrl-Z undo, Ctrl-Y redo.")
    else
        window:Hide()
        ClearOverrideBindings(window)
        UI.minimapButton.icon:SetVertexColor(1, 1, 1)
        F.Print("edit mode off")
    end
    UpdateHeader()
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("PLAYER_TARGET_CHANGED")
loader:SetScript("OnEvent", function(_, event, addon)
    if event == "ADDON_LOADED" and addon == "CoAForge" then
        CoAForgeDB = CoAForgeDB or {}
        F.Defaults(CoAForgeDB, DEFAULTS)
        CoAForgeDB.editing = false
        CoAForgeDB.queued = nil
    elseif event == "PLAYER_LOGIN" then
        BuildHiddenButtons()
        BuildWindow()
        BuildMinimapButton()
        F.Catalog:Init()
        F.Rpc:Probe()
        UpdateHeader()
        F.Print("loaded. Click the minimap gear or type /forge.")
    elseif event == "PLAYER_TARGET_CHANGED" then
        if CoAForgeDB.editing then F.Forge:RefreshTarget() end
    end
end)

SLASH_COAFORGE1 = "/forge"
SLASH_COAFORGE2 = "/coaforge"
SlashCmdList["COAFORGE"] = function(message)
    message = F.Trim(message)
    if message == "undo" then
        F.Journal:Undo()
    elseif message == "redo" then
        F.Journal:Redo()
    elseif message == "export" then
        UI:SetEditing(true)
        UI:SelectTab("Changes")
    else
        UI:SetEditing(not CoAForgeDB.editing)
    end
end
