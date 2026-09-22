CoAForge = CoAForge or {}
local F = CoAForge

local PREFIX = "AzerothCore"
local MAX_COMMAND = 230
local MAX_IN_FLIGHT = 4
local SEND_INTERVAL = 0.05
local REPLY_TIMEOUT = 15
local CHANNEL_PROBE_TIMEOUT = 4
local CHANNELS = { "WHISPER", "GUILD", "PARTY", "RAID" }

local Rpc = { channel = nil, probing = false, ready = false }
F.Rpc = Rpc

local queue = {}
local inflight = {}
local inflightCount = 0
local counter = 0
local lastSend = 0
local channelIndex = 0

local function nextTag()
    counter = counter + 1
    if counter > 9999 then counter = 1 end
    return string.format("%04d", counter)
end

local function transmit(tag, command)
    local channel = Rpc.channel or CHANNELS[1]
    local body = "i" .. tag .. command
    if channel == "WHISPER" then
        SendAddonMessage(PREFIX, body, "WHISPER", UnitName("player"))
    else
        SendAddonMessage(PREFIX, body, channel)
    end
end

local function finish(tag, ok, lines)
    local request = inflight[tag]
    if not request then return end
    inflight[tag] = nil
    inflightCount = inflightCount - 1
    Rpc.ready = true
    if request.onDone then
        local safe, err = pcall(request.onDone, ok, lines or request.lines, request.command)
        if not safe then F.Warn("callback error: " .. tostring(err)) end
    end
end

function Rpc:Send(command, onDone)
    if type(command) ~= "string" then return end
    command = command:gsub("^%s*%.", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if command == "" then return end
    if #command > MAX_COMMAND then
        if onDone then onDone(false, { "command too long for the addon channel" }) end
        return
    end
    queue[#queue + 1] = { command = command, onDone = onDone }
end

function Rpc:SendSequence(commands, onDone)
    for index = 1, #commands do
        local last = index == #commands
        self:Send(commands[index], last and onDone or nil)
    end
end

function Rpc:Pending()
    return #queue + inflightCount
end

local function advanceChannel()
    channelIndex = channelIndex + 1
    Rpc.channel = CHANNELS[channelIndex]
    if not Rpc.channel then
        Rpc.probing = false
        channelIndex = 0
        Rpc.channel = CHANNELS[1]
        F.Warn("no addon command channel answered; is your account security level high enough?")
        return false
    end
    return true
end

function Rpc:Probe()
    if self.ready then return end
    self.probing = true
    channelIndex = 1
    self.channel = CHANNELS[1]
    self:Send("gps", function(ok)
        if ok then
            self.probing = false
            self.ready = true
            F.Print("connected over " .. tostring(self.channel))
        end
    end)
end

local pump = CreateFrame("Frame", "CoAForgeRpcFrame")
pump:RegisterEvent("CHAT_MSG_ADDON")

pump:SetScript("OnEvent", function(_, _, prefix, message)
    if prefix ~= PREFIX or type(message) ~= "string" or #message < 5 then return end
    local opcode = message:sub(1, 1)
    local tag = message:sub(2, 5)
    local request = inflight[tag]
    if not request then return end
    request.expires = GetTime() + REPLY_TIMEOUT
    if opcode == "m" then
        local line = message:sub(6):gsub("||", "|")
        request.lines[#request.lines + 1] = line
    elseif opcode == "o" then
        finish(tag, true)
    elseif opcode == "f" then
        finish(tag, false)
    end
end)

pump:SetScript("OnUpdate", function()
    local now = GetTime()
    for tag, request in pairs(inflight) do
        if now > request.expires then
            if Rpc.probing and advanceChannel() then
                inflight[tag] = nil
                inflightCount = inflightCount - 1
                queue[#queue + 1] = { command = request.command, onDone = request.onDone }
            else
                finish(tag, false, { "no reply from the server" })
            end
        end
    end
    if #queue == 0 or inflightCount >= MAX_IN_FLIGHT or now - lastSend < SEND_INTERVAL then return end
    local request = table.remove(queue, 1)
    local tag = nextTag()
    request.lines = {}
    request.expires = now + (Rpc.probing and CHANNEL_PROBE_TIMEOUT or REPLY_TIMEOUT)
    inflight[tag] = request
    inflightCount = inflightCount + 1
    lastSend = now
    transmit(tag, request.command)
end)
