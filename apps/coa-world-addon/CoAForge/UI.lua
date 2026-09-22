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
local STEPS = { 0.1, 0.25, 0.5, 1, 2, 5, 10 }
local TABS = { "Place", "Look", "Quest", "Browse", "Changes" }
local WINDOW_WIDTH = 780
local WINDOW_HEIGHT = 650

local UI = {}
F.UI = UI

local window, tabPanels, statusText, undoButton, redoButton, dirtyText, linkText
local listSerial = 0

local function Label(parent, text, font, x, y)
    local label = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormalSmall")
    label:SetText(text)
    if x then label:SetPoint("TOPLEFT", x, y) end
    return label
end

local function Button(parent, text, width, x, y, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetWidth(width)
    button:SetHeight(22)
    button:SetText(text)
    if x then button:SetPoint("TOPLEFT", x, y) end
    button:SetScript("OnClick", onClick)
    return button
end

local function Edit(parent, width, x, y, onAccept)
    local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    box:SetWidth(width)
    box:SetHeight(20)
    box:SetAutoFocus(false)
    if x then box:SetPoint("TOPLEFT", x + 6, y - 1) end
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

local function ScrollList(parent, x, y, width, height, buildRow)
    local rows = math.floor((height - 8) / ROW_HEIGHT)
    listSerial = listSerial + 1
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetWidth(width)
    holder:SetHeight(height)
    holder:SetPoint("TOPLEFT", x, y)
    holder:SetBackdrop(INSET)
    holder:SetBackdropColor(0, 0, 0, 0.5)

    local scroll = CreateFrame("ScrollFrame", "CoAForgeScroll" .. listSerial, holder, "FauxScrollFrameTemplate")
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
                row:SetScript("OnEnter", nil)
                row:SetScript("OnLeave", nil)
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

local function TextArea(parent, x, y, width, height)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetWidth(width)
    holder:SetHeight(height)
    holder:SetPoint("TOPLEFT", x, y)
    holder:SetBackdrop(INSET)
    holder:SetBackdropColor(0, 0, 0, 0.6)
    listSerial = listSerial + 1
    local scroll = CreateFrame("ScrollFrame", "CoAForgeText" .. listSerial, holder, "UIPanelScrollFrameTemplate")
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

local function ModelView(parent, x, y, width, height)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetWidth(width)
    holder:SetHeight(height)
    holder:SetPoint("TOPLEFT", x, y)
    holder:SetBackdrop(INSET)
    holder:SetBackdropColor(0, 0, 0, 0.7)

    local model = CreateFrame("PlayerModel", nil, holder)
    model:SetPoint("TOPLEFT", 5, -5)
    model:SetPoint("BOTTOMRIGHT", -5, 5)
    holder.model = model
    holder.facing = 0.4

    local empty = holder:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    empty:SetPoint("CENTER")
    empty:SetText("hover a model")
    holder.empty = empty

    model:EnableMouse(true)
    model:EnableMouseWheel(true)
    model:SetScript("OnMouseDown", function(self) self.dragging = true self.startX = GetCursorPosition() end)
    model:SetScript("OnMouseUp", function(self) self.dragging = false end)
    model:SetScript("OnUpdate", function(self)
        if not self.dragging then return end
        local currentX = GetCursorPosition()
        holder.facing = holder.facing + (currentX - (self.startX or currentX)) * 0.01
        self.startX = currentX
        self:SetRotation(holder.facing)
    end)

    function holder:SetModel(displayId, label)
        if not displayId or displayId == 0 then
            model:Hide()
            empty:Show()
            return
        end
        empty:Hide()
        model:Show()
        model:SetDisplayInfo(displayId)
        model:SetRotation(holder.facing)
        holder.current = displayId
        if holder.caption then holder.caption:SetText(label or "") end
    end

    return holder
end

local function SelectionSummary()
    local selection = F.Selection
    if not selection then return "|cffaaaaaano selection|r" end
    return string.format("%s   |cffaaaaaaguid|r %s   |cffaaaaaaentry|r %s   |cffaaaaaadisplay|r %s",
        tostring(selection.name or "?"), tostring(selection.guid or "?"),
        tostring(selection.entry or "?"), tostring(selection.display or "-"))
end

local function BuildPlaceTab(panel)
    local target = Label(panel, "", "GameFontNormal", 10, -8)
    local position = Label(panel, "", "GameFontHighlightSmall", 10, -28)

    local refresh = Button(panel, "Refresh", 80, 0, 0, function() F.Forge:RefreshTarget() end)
    refresh:ClearAllPoints()
    refresh:SetPoint("TOPRIGHT", -10, -6)

    Label(panel, "Step", "GameFontNormalSmall", 10, -54)
    panel.stepButtons = {}
    for index, value in ipairs(STEPS) do
        local button = Button(panel, tostring(value), 44, 44 + (index - 1) * 46, -50, function()
            CoAForgeDB.step = value
            panel.RefreshSteps()
        end)
        panel.stepButtons[index] = button
    end
    function panel.RefreshSteps()
        for index, button in ipairs(panel.stepButtons) do
            if STEPS[index] == CoAForgeDB.step then
                button:SetNormalFontObject("GameFontHighlightSmall")
            else
                button:SetNormalFontObject("GameFontDisableSmall")
            end
        end
    end

    local function nudge(dx, dy, dz)
        return function()
            local s = CoAForgeDB.step
            F.Forge:Nudge(dx * s, dy * s, dz * s)
        end
    end

    Button(panel, "North  +X", 88, 96, -82, nudge(1, 0, 0))
    Button(panel, "West  +Y", 88, 6, -108, nudge(0, 1, 0))
    Button(panel, "East  -Y", 88, 186, -108, nudge(0, -1, 0))
    Button(panel, "South  -X", 88, 96, -134, nudge(-1, 0, 0))
    Button(panel, "Up", 64, 292, -82, nudge(0, 0, 1))
    Button(panel, "Down", 64, 292, -134, nudge(0, 0, -1))

    Label(panel, "Facing", "GameFontNormalSmall", 380, -60)
    local facing = CreateFrame("Slider", "CoAForgeFacingSlider", panel, "OptionsSliderTemplate")
    facing:SetWidth(280)
    facing:SetHeight(16)
    facing:SetPoint("TOPLEFT", 386, -86)
    facing:SetMinMaxValues(0, 360)
    facing:SetValueStep(1)
    facing:SetValue(0)
    _G["CoAForgeFacingSliderLow"]:SetText("0")
    _G["CoAForgeFacingSliderHigh"]:SetText("360")
    _G["CoAForgeFacingSliderText"]:SetText("")

    local facingBox = Edit(panel, 52, 676, -84)
    facingBox:SetNumeric(false)

    local function setFacingDisplay(degrees)
        panel.updatingFacing = true
        facing:SetValue(degrees)
        facingBox:SetText(string.format("%.0f", degrees))
        panel.updatingFacing = false
    end

    local function applyFacing(degrees)
        while degrees < 0 do degrees = degrees + 360 end
        degrees = math.fmod(degrees, 360)
        setFacingDisplay(degrees)
        F.Forge:Face(degrees * math.pi / 180)
    end

    facing:SetScript("OnValueChanged", function(self, value)
        if panel.updatingFacing then return end
        facingBox:SetText(string.format("%.0f", value))
    end)
    facing:SetScript("OnMouseUp", function(self)
        if panel.updatingFacing then return end
        applyFacing(self:GetValue())
    end)
    facingBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        local value = tonumber(self:GetText())
        if value then applyFacing(value) end
    end)

    Button(panel, "Face me", 88, 386, -112, function()
        F.Forge:ReadPlayerPosition(function(me)
            local s = F.Selection
            if me and s then F.Forge:Face(math.atan2(me.y - s.y, me.x - s.x)) end
        end)
    end)
    Button(panel, "Turn -15", 76, 478, -112, function()
        if F.Selection then applyFacing((F.Selection.o or 0) * 180 / math.pi - 15) end
    end)
    Button(panel, "Turn +15", 76, 558, -112, function()
        if F.Selection then applyFacing((F.Selection.o or 0) * 180 / math.pi + 15) end
    end)

    Button(panel, "Move to cursor", 116, 6, -172, function() F.Forge:MoveToCursor() end)
    Button(panel, "Drop to ground", 116, 126, -172, function() F.Forge:DropToGround() end)
    Button(panel, "Copy", 76, 246, -172, function() F.Forge:Copy() end)
    Button(panel, "Paste", 76, 326, -172, function() F.Forge:Paste() end)
    Button(panel, "Delete", 76, 406, -172, function() F.Forge:DeleteSelection() end)
    Button(panel, "Apply queued", 110, 486, -172, function() F.Forge:ApplyQueued() end)

    Label(panel, "Movement", "GameFontNormalSmall", 10, -206)
    local moveType = Button(panel, "stay", 72, 76, -202, nil)
    moveType:SetScript("OnClick", function()
        local order = { "stay", "random", "way" }
        local index = 1
        for position, value in ipairs(order) do
            if value == moveType:GetText() then index = position end
        end
        local nextType = order[(index % #order) + 1]
        moveType:SetText(nextType)
        F.Forge:SetMoveType(nextType)
    end)

    Label(panel, "Wander", "GameFontNormalSmall", 162, -206)
    local wander = Edit(panel, 56, 210, -204, function(text)
        local value = tonumber(text)
        if value then F.Forge:SetWander(value) end
    end)

    Label(panel, "Respawn s", "GameFontNormalSmall", 284, -206)
    local respawn = Edit(panel, 64, 348, -204, function(text)
        local value = tonumber(text)
        if value then F.Forge:SetSpawnTime(math.floor(value)) end
    end)

    Label(panel, "Entry", "GameFontNormalSmall", 10, -240)
    local spawnEntry = Edit(panel, 84, 50, -238)
    Button(panel, "Spawn NPC", 100, 146, -236, function()
        local entry = tonumber(spawnEntry:GetText())
        if entry then F.Forge:SpawnCreature(entry) else F.Warn("enter a creature entry") end
    end)
    Button(panel, "Spawn object", 108, 250, -236, function()
        local entry = tonumber(spawnEntry:GetText())
        if entry then F.Forge:SpawnObject(entry) else F.Warn("enter a gameobject entry") end
    end)

    Label(panel, "Nearby spawns", "GameFontNormalSmall", 10, -274)
    local range = Edit(panel, 44, 96, -272)
    range:SetText(tostring(CoAForgeDB.scanRange))
    Button(panel, "Scan", 64, 152, -270, function()
        CoAForgeDB.scanRange = tonumber(range:GetText()) or 30
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
            panel.scanCount:SetText(#rows .. " found")
        end)
    end)
    panel.scanCount = Label(panel, "", "GameFontDisableSmall", 224, -274)

    panel.list = ScrollList(panel, 6, -296, 736, 212, function(row, item)
        local tag = item.kind == "gameobject" and "|cffffcc66OBJ|r" or "|cff88ff88NPC|r"
        row.text:SetText(string.format("%s  %s   |cffaaaaaaguid %s  entry %s|r", tag, tostring(item.name),
            tostring(item.guid), tostring(item.entry)))
        row:SetScript("OnClick", function()
            if item.kind == "gameobject" then
                F.Forge:SelectGameObject(item.guid)
            elseif F.Server.forge then
                F.Forge:Select(item.guid)
            else
                F.Print("target " .. tostring(item.name) .. " in game, then press Refresh")
            end
        end)
    end)

    local function update()
        target:SetText(SelectionSummary())
        local selection = F.Selection
        if selection then
            position:SetText(string.format("x %.3f   y %.3f   z %.3f   facing %.0f deg   map %s",
                selection.x or 0, selection.y or 0, selection.z or 0,
                (selection.o or 0) * 180 / math.pi, tostring(selection.map or 0)))
            setFacingDisplay(math.fmod((selection.o or 0) * 180 / math.pi + 360, 360))
            if selection.movetype then moveType:SetText(selection.movetype) end
            if selection.wander then wander:SetText(string.format("%.1f", selection.wander)) end
            if selection.spawntime then respawn:SetText(tostring(selection.spawntime)) end
        else
            position:SetText("target a creature and press Refresh, or press Scan and click a row")
        end
    end
    F.Events:Register("TARGET", update)
    panel.Update = function()
        update()
        panel.RefreshSteps()
    end
end

local function BuildLookTab(panel)
    local target = Label(panel, "", "GameFontNormal", 10, -8)

    Label(panel, "Display id", "GameFontNormalSmall", 10, -34)
    local displayBox = Edit(panel, 80, 70, -32)
    Button(panel, "Apply to target", 116, 162, -30, function()
        local value = tonumber(displayBox:GetText())
        if value then F.Forge:SetDisplay(value) end
    end)

    Label(panel, "Scale", "GameFontNormalSmall", 420, -34)
    local scaleBox = Edit(panel, 54, 460, -32)
    scaleBox:SetText("1.0")
    Button(panel, "Set", 54, 528, -30, function()
        local value = tonumber(scaleBox:GetText())
        if value then F.Forge:SetScale(value) end
    end)
    Button(panel, "x0.33", 60, 586, -30, function()
        scaleBox:SetText("0.33")
        F.Forge:SetScale(0.33)
    end)
    Button(panel, "Reset", 60, 650, -30, function()
        scaleBox:SetText("1.0")
        F.Forge:SetScale(1)
    end)

    Label(panel, "Find model", "GameFontNormalSmall", 10, -62)
    local searchBox = Edit(panel, 170, 74, -60)
    local function runModelSearch()
        local results, total = F.Catalog:SearchDisplays(searchBox:GetText(), 400)
        panel.displayList:SetData(results)
        panel.displayCount:SetText(string.format("showing %d of %d", #results, total))
    end
    searchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() runModelSearch() end)
    Button(panel, "Search", 70, 256, -58, runModelSearch)
    panel.displayCount = Label(panel, "", "GameFontDisableSmall", 334, -62)

    panel.preview = ModelView(panel, 470, -86, 270, 230)
    panel.preview.caption = Label(panel, "", "GameFontDisableSmall", 470, -322)
    panel.preview.caption:SetWidth(270)

    panel.displayList = ScrollList(panel, 6, -86, 456, 230, function(row, item)
        row.text:SetText(string.format("|cffffd100%s|r  %s", item.id, item.label))
        row:SetScript("OnEnter", function()
            panel.preview:SetModel(item.id, item.id .. "  " .. item.label)
        end)
        row:SetScript("OnClick", function()
            displayBox:SetText(tostring(item.id))
            F.Forge:SetDisplay(item.id)
        end)
    end)

    Label(panel, "Visual effect", "GameFontNormalSmall", 10, -324)
    local auraBox = Edit(panel, 70, 84, -322)
    Button(panel, "Apply", 64, 164, -320, function()
        local value = tonumber(auraBox:GetText())
        if value then F.Forge:AddAura(value) end
    end)
    Button(panel, "Clear all", 76, 232, -320, function() F.Forge:ClearAuras() end)

    local auraSearch = Edit(panel, 150, 330, -322)
    local function runAuraSearch()
        local results, total = F.Catalog:SearchAuras(auraSearch:GetText(), 400)
        panel.auraList:SetData(results)
        panel.auraCount:SetText(string.format("showing %d of %d", #results, total))
    end
    auraSearch:SetScript("OnEnterPressed", function(self) self:ClearFocus() runAuraSearch() end)
    Button(panel, "Search", 70, 492, -320, runAuraSearch)
    panel.auraCount = Label(panel, "", "GameFontDisableSmall", 570, -324)

    panel.auraList = ScrollList(panel, 6, -348, 736, 150, function(row, item)
        row.text:SetText(string.format("|cffffd100%s|r  %s", item.id, item.label))
        row:SetScript("OnClick", function()
            auraBox:SetText(tostring(item.id))
            F.Forge:AddAura(item.id)
        end)
    end)

    local note = Label(panel, "", "GameFontDisableSmall", 10, -504)
    note:SetWidth(736)
    note:SetJustifyH("LEFT")

    local function update()
        target:SetText(SelectionSummary())
        if F.Server.forge then
            note:SetText("Scale and effects are saved to the database and previewed live.")
        else
            note:SetText("Server toolset absent: scale and effects are previews only, exported from Changes.")
        end
        local selection = F.Selection
        if selection and selection.display then
            panel.preview:SetModel(selection.display, "selected: " .. tostring(selection.name))
        end
    end
    F.Events:Register("TARGET", update)
    F.Events:Register("PENDING", update)
    F.Events:Register("STATUS", update)

    panel.Update = function()
        update()
        if #panel.displayList.data == 0 then runModelSearch() end
        if #panel.auraList.data == 0 then runAuraSearch() end
    end
end

local function BuildQuestTab(panel)
    Label(panel, "Quest id", "GameFontNormalSmall", 10, -16)
    local questBox = Edit(panel, 90, 64, -14)

    local function questAction(action)
        return function()
            local id = tonumber(questBox:GetText())
            if id then F.Forge:Quest(action, id) else F.Warn("enter a quest id") end
        end
    end

    Button(panel, "Add", 64, 166, -12, questAction("add"))
    Button(panel, "Complete", 82, 234, -12, questAction("complete"))
    Button(panel, "Reward", 74, 320, -12, questAction("reward"))
    Button(panel, "Remove", 74, 398, -12, questAction("remove"))
    Button(panel, "Watch", 66, 476, -12, function()
        local id = tonumber(questBox:GetText())
        if not id then return end
        for _, existing in ipairs(CoAForgeDB.questWatch) do
            if existing == id then return end
        end
        table.insert(CoAForgeDB.questWatch, id)
        panel.Update()
    end)

    Label(panel, "Watched quests. Click to complete, shift-click to drop from the list.",
        "GameFontDisableSmall", 10, -48)
    panel.watchList = ScrollList(panel, 6, -66, 360, 150, function(row, item)
        row.text:SetText("quest " .. tostring(item))
        row:SetScript("OnClick", function()
            if IsShiftKeyDown() then
                for index, value in ipairs(CoAForgeDB.questWatch) do
                    if value == item then
                        table.remove(CoAForgeDB.questWatch, index)
                        break
                    end
                end
                panel.Update()
            else
                F.Forge:Quest("complete", item)
            end
        end)
    end)

    Label(panel, "Reload server data", "GameFontNormalSmall", 390, -48)
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
    for index, entry in ipairs(reloads) do
        local column = (index - 1) % 2
        local rowIndex = math.floor((index - 1) / 2)
        Button(panel, entry[1], 168, 390 + column * 176, -68 - rowIndex * 26, function()
            F.Forge:Reload(entry[2])
        end)
    end

    Label(panel, "Bookmark", "GameFontNormalSmall", 10, -236)
    local bookmarkBox = Edit(panel, 130, 74, -234)
    Button(panel, "Save here", 94, 216, -232, function()
        local name = F.Trim(bookmarkBox:GetText())
        if name == "" then return F.Warn("name the bookmark first") end
        F.Forge:SaveBookmark(name)
        bookmarkBox:SetText("")
    end)
    Label(panel, "Click to travel, shift-click to delete.", "GameFontDisableSmall", 10, -262)
    panel.markList = ScrollList(panel, 6, -280, 360, 130, function(row, item)
        row.text:SetText(string.format("%s   |cffaaaaaa%.0f %.0f %.0f|r", item.mark.name,
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

    Label(panel, "Test helpers", "GameFontNormalSmall", 390, -236)
    local helpers = {
        { "Respawn nearby", "respawn all" },
        { "Revive me", "revive" },
        { "GM on", "gm on" },
        { "GM off", "gm off" },
        { "Fly on", "gm fly on" },
        { "Fly off", "gm fly off" },
    }
    for index, entry in ipairs(helpers) do
        local column = (index - 1) % 2
        local rowIndex = math.floor((index - 1) / 2)
        Button(panel, entry[1], 168, 390 + column * 176, -256 - rowIndex * 26, function()
            F.Rpc:Send(entry[2])
        end)
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
    local actions = {
        creature = "clicking a row spawns that creature at your cursor",
        object = "clicking a row spawns that gameobject at your cursor",
        item = "clicking a row prints the item id",
        spell = "clicking a row applies that spell to your target as a visual effect",
        quest = "clicking a row adds that quest to your log",
    }
    local kindIndex = 1

    local kindButton = Button(panel, kinds[kindIndex], 96, 10, -12, nil)
    local searchBox = Edit(panel, 250, 112, -14)
    local status = Label(panel, "", "GameFontDisableSmall", 10, -42)
    status:SetWidth(730)
    status:SetJustifyH("LEFT")

    local function describe()
        status:SetText("Searches the live server database with .lookup " .. kinds[kindIndex] ..
            ". Type part of a name and press Enter. Then " .. actions[kinds[kindIndex]] .. ".")
    end

    kindButton:SetScript("OnClick", function()
        kindIndex = (kindIndex % #kinds) + 1
        kindButton:SetText(kinds[kindIndex])
        describe()
    end)

    local function run()
        local text = F.Trim(searchBox:GetText())
        if text == "" then
            status:SetText("|cffff8844Type part of a name first.|r " ..
                "This searches the server, so an empty search returns nothing.")
            return
        end
        status:SetText("searching the server for " .. text .. " ...")
        F.Forge:Lookup(kinds[kindIndex], text, function(results)
            panel.list:SetData(results)
            if #results == 0 then
                status:SetText("|cffff8844No " .. kinds[kindIndex] .. " matched " .. text ..
                    ".|r The server caps results, so try a more specific word.")
            else
                status:SetText(#results .. " " .. kinds[kindIndex] .. " result(s) for " .. text ..
                    ". " .. actions[kinds[kindIndex]] .. ".")
            end
        end)
    end
    searchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() run() end)
    Button(panel, "Search", 76, 374, -12, run)

    panel.list = ScrollList(panel, 6, -66, 736, 430, function(row, item)
        row.text:SetText(string.format("|cffffd100%s|r   %s", item.id, item.name or ""))
        row:SetScript("OnClick", function()
            local kind = kinds[kindIndex]
            if kind == "creature" then
                F.Forge:SpawnCreature(item.id)
            elseif kind == "object" then
                F.Forge:SpawnObject(item.id)
            elseif kind == "spell" then
                F.Forge:AddAura(item.id)
            elseif kind == "quest" then
                F.Forge:Quest("add", item.id)
            else
                F.Print(kind .. " " .. item.id .. " " .. tostring(item.name))
            end
        end)
    end)

    describe()
    panel.Update = describe
end

local function BuildChangesTab(panel)
    Label(panel, "History. Click a row to move the undo cursor to that point.",
        "GameFontDisableSmall", 10, -12)

    panel.list = ScrollList(panel, 6, -30, 736, 250, function(row, item)
        local marker = item.index == CoAForgeDB.cursor and "|cff00ff00>|r " or "   "
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

    Button(panel, "Build export", 110, 6, -288, function()
        panel.text.box:SetText(F.Forge:Export())
        panel.text.box:HighlightText()
        panel.text.box:SetFocus()
    end)
    Button(panel, "Save to disk (reloads UI)", 176, 122, -288, function()
        CoAForgeDB.dirty = 0
        ReloadUI()
    end)
    Button(panel, "Clear history", 116, 304, -288, function() F.Journal:Clear() end)
    Button(panel, "Clear export log", 128, 426, -288, function()
        CoAForgeDB.log = {}
        CoAForgeDB.pending = {}
        F.Print("export log cleared")
    end)

    panel.text = TextArea(panel, 6, -316, 736, 180)

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
    if F.Journal:CanUndo() then undoButton:Enable() else undoButton:Disable() end
    if F.Journal:CanRedo() then redoButton:Enable() else redoButton:Disable() end
    local label = F.Journal:UndoLabel()
    statusText:SetText(label and ("last: " .. label) or "no changes yet")
    local dirty = CoAForgeDB.dirty or 0
    dirtyText:SetText(dirty > 0 and ("|cffffcc00" .. dirty .. " unsaved|r") or "")
    if not F.Rpc.ready then
        linkText:SetText("|cffff4444server link: not connected|r")
    elseif F.Server.forge then
        linkText:SetText("|cff44ff44server link: " .. tostring(F.Rpc.channel) .. ", full toolset|r")
    else
        linkText:SetText("|cffffcc00server link: " .. tostring(F.Rpc.channel) .. ", basic commands only|r")
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
    window:SetWidth(WINDOW_WIDTH)
    window:SetHeight(WINDOW_HEIGHT)
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

    undoButton = Button(window, "Undo", 76, 16, -40, function() F.Journal:Undo() end)
    redoButton = Button(window, "Redo", 76, 96, -40, function() F.Journal:Redo() end)

    statusText = window:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    statusText:SetPoint("TOPLEFT", 180, -46)

    dirtyText = window:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dirtyText:SetPoint("TOPRIGHT", -30, -46)

    linkText = window:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    linkText:SetPoint("TOPRIGHT", -30, -24)

    local body = CreateFrame("Frame", nil, window)
    body:SetPoint("TOPLEFT", 14, -96)
    body:SetPoint("BOTTOMRIGHT", -14, 14)
    body:SetBackdrop(INSET)
    body:SetBackdropColor(0, 0, 0, 0.25)

    window.tabs = {}
    tabPanels = {}
    for index, name in ipairs(TABS) do
        local tab = Button(window, name, 108, 16 + (index - 1) * 112, -68, function() UI:SelectTab(name) end)
        tab.tabName = name
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
    F.Events:Register("STATUS", UpdateHeader)
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
        F.Rpc:Probe(function()
            F.Forge:ProbeServer()
            UpdateHeader()
        end)
        UpdateHeader()
        F.Print("loaded. Click the minimap gear or type /forge. Catalog: " .. F.Catalog:Summary())
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
    elseif message == "test" then
        F.Rpc.ready = false
        F.Rpc:Probe(function() F.Forge:ProbeServer() end)
    elseif message == "export" then
        UI:SetEditing(true)
        UI:SelectTab("Changes")
    else
        UI:SetEditing(not CoAForgeDB.editing)
    end
end
