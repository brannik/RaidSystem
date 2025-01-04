local roleCoords = {
    { 0, 0.25, 0, 1 },  -- First icon (skipped)
    { 0.25, 0.5, 0, 1 },  -- Second icon
    { 0.5, 0.75, 0, 1 },  -- Third icon
    { 0.75, 1, 0, 1 }  -- Fourth icon
}

local chatMessages = {}
local isListening = false

local frame = CreateFrame("Frame")

local raidKeywords = {
    "LFM", "LFG", "LF", "Looking for more", "Looking for group", "Need more", "Raid", "Group"
}

local dungeonNames = {
    ["ICC"] = "Icecrown Citadel",
    ["RS"] = "Ruby Sanctum",
    ["Naxx"] = "Naxxramas",
    ["Ulduar"] = "Ulduar",
    ["ToC"] = "Trial of the Crusader"
}

local dungeonIcons = {
    ["ICC"] = "Interface\\Icons\\Achievement_Dungeon_Icecrown_IcecrownEntrance",
    ["RS"] = "Interface\\Icons\\Achievement_Dungeon_RubySanctum",
    ["Naxx"] = "Interface\\Icons\\Achievement_Dungeon_Naxxramas",
    ["Ulduar"] = "Interface\\Icons\\Achievement_Dungeon_Ulduar77",
    ["ToC"] = "Interface\\Icons\\Achievement_Dungeon_TrialoftheCrusader"
}

local classColors = {
    ["WARRIOR"] = "C79C6E",
    ["PALADIN"] = "F58CBA",
    ["HUNTER"] = "ABD473",
    ["ROGUE"] = "FFF569",
    ["PRIEST"] = "FFFFFF",
    ["DEATHKNIGHT"] = "C41F3B",
    ["SHAMAN"] = "0070DE",
    ["MAGE"] = "69CCF0",
    ["WARLOCK"] = "9482C9",
    ["DRUID"] = "FF7D0A"
}

local classIconCoords = {
    ["WARRIOR"] = {0, 0.25, 0, 0.25},
    ["MAGE"] = {0.25, 0.5, 0, 0.25},
    ["ROGUE"] = {0.5, 0.75, 0, 0.25},
    ["DRUID"] = {0.75, 1, 0, 0.25},
    ["HUNTER"] = {0, 0.25, 0.25, 0.5},
    ["SHAMAN"] = {0.25, 0.5, 0.25, 0.5},
    ["PRIEST"] = {0.5, 0.75, 0.25, 0.5},
    ["WARLOCK"] = {0.75, 1, 0.25, 0.5},
    ["PALADIN"] = {0, 0.25, 0.5, 0.75},
    ["DEATHKNIGHT"] = {0.25, 0.5, 0.5, 0.75}
}

local function IsRaidMessage(message)
    for _, keyword in ipairs(raidKeywords) do
        if string.find(string.lower(message), string.lower(keyword)) then
            return true
        end
    end
    return false
end

local function ExtractDungeonName(message)
    for abbr, full in pairs(dungeonNames) do
        if string.find(string.lower(message), string.lower(full)) or string.find(string.lower(message), string.lower(abbr)) then
            return abbr
        end
    end
    return "Unknown"
end

local function ExtractDifficulty(message, dungeonName)
    local pattern = string.format("%s%s", dungeonName, "%s*(%d+%a?)")
    local diff = string.match(message, pattern)
    if diff == "10" or diff == "25" then
        diff = diff .. "N"
    elseif string.match(string.lower(message), "%d+%s*normal") or string.match(string.lower(message), "%d+%s*nor") or string.match(string.lower(message), "%d+%s*nomal") then
        diff = string.match(message, "%d+") .. "N"
    elseif string.match(string.lower(message), "%d+%s*heroic") or string.match(string.lower(message), "%d+%s*hero") or string.match(string.lower(message), "%d+%s*hc") then
        diff = string.match(message, "%d+") .. "HC"
    end
    return diff or "Unknown"
end

local function ExtractGearScore(message)
    local gs = string.match(message, "%d+%.?%d*k")
    if not gs then
        gs = string.match(message, "%+(%d+)")
        if gs then
            gs = gs .. "k"
        end
    end
    return gs or "Unknown"
end

local function GetClassColor(class)
    return classColors[class] or "FFFFFF"
end

local function Capitalize(str)
    return str:gsub("^%l", string.upper)
end

local function GetTimeAgo(timestamp)
    local currentTime = date("%H:%M:%S")
    local pattern = "(%d+):(%d+):(%d+)"
    local h1, m1, s1 = timestamp:match(pattern)
    local h2, m2, s2 = currentTime:match(pattern)
    local time1 = (h1 * 3600) + (m1 * 60) + s1
    local time2 = (h2 * 3600) + (m2 * 60) + s2
    local diff = math.abs(time2 - time1)
    return diff
end

local function HandleChatMessage(self, event, ...)
    if not isListening then return end

    local message, sender, language, channelString, target, flags, unknown, channelNumber, channelName, unknown2, counter, guid = ...

    if not IsRaidMessage(message) then
        return
    end

    local dungeonName = ExtractDungeonName(message)
    local difficulty = ExtractDifficulty(message, dungeonName)
    local gearScore = ExtractGearScore(message)
    local timestamp = date("%H:%M:%S")

    local localizedClass, englishClass, localizedRace, englishRace, sex, name, realm = GetPlayerInfoByGUID(guid)
    englishClass = string.upper(englishClass)
    local classColor = GetClassColor(englishClass)
    local classIconCoords = classIconCoords[englishClass]
    local coloredSender = string.format("|cff%s%s|r", classColor, sender)

    local found = false

    for i, msg in ipairs(chatMessages) do
        if msg.sender == sender then
            msg.message = message
            msg.timestamp = timestamp
            msg.dungeon = dungeonName
            msg.difficulty = difficulty
            msg.gearScore = gearScore
            msg.coloredSender = coloredSender
            msg.classIconCoords = classIconCoords
            found = true
            break
        end
    end

    if not found then
        table.insert(chatMessages, { sender = sender, message = message, timestamp = timestamp, dungeon = dungeonName, difficulty = difficulty, gearScore = gearScore, coloredSender = coloredSender, classIconCoords = classIconCoords })
    end

    -- Update the grid view
    if OngoingRaidsContent then
        RaidSystem_CreateOngoingRaidsContent(OngoingRaidsContent)
    end
end

local function RegisterChatEvents()
    frame:RegisterEvent("CHAT_MSG_SAY")
    frame:RegisterEvent("CHAT_MSG_YELL")
    frame:RegisterEvent("CHAT_MSG_WHISPER")
    frame:RegisterEvent("CHAT_MSG_PARTY")
    frame:RegisterEvent("CHAT_MSG_RAID")
    frame:RegisterEvent("CHAT_MSG_GUILD")
    frame:RegisterEvent("CHAT_MSG_OFFICER")
    frame:RegisterEvent("CHAT_MSG_CHANNEL")
end

local function UnregisterChatEvents()
    frame:UnregisterEvent("CHAT_MSG_SAY")
    frame:UnregisterEvent("CHAT_MSG_YELL")
    frame:UnregisterEvent("CHAT_MSG_WHISPER")
    frame:UnregisterEvent("CHAT_MSG_PARTY")
    frame:UnregisterEvent("CHAT_MSG_RAID")
    frame:UnregisterEvent("CHAT_MSG_GUILD")
    frame:UnregisterEvent("CHAT_MSG_OFFICER")
    frame:UnregisterEvent("CHAT_MSG_CHANNEL")
end

local function CreateOngoingRaidsContent(parent)
    -- Clear previous content
    for i = 1, parent:GetNumChildren() do
        local child = select(i, parent:GetChildren())
        child:Hide()
        child:SetParent(nil)
    end

    -- Create a scroll frame for the grid view
    local scrollFrame = CreateFrame("ScrollFrame", "OngoingRaidsScrollFrame", parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -30, 10)

    local content = CreateFrame("Frame", "OngoingRaidsContentFrame", scrollFrame)
    content:SetWidth(scrollFrame:GetWidth())
    scrollFrame:SetScrollChild(content)

    local totalHeight = 0
    local columns = 3
    local iconSize = 96  -- Three times bigger than the original size

    -- Add dynamic data to the ongoing raids tab content
    for i, msg in ipairs(chatMessages) do
        local row = math.floor((i - 1) / columns)
        local col = (i - 1) % columns

        local gridElement = CreateFrame("Frame", nil, content)
        gridElement:SetSize(content:GetWidth() / columns, iconSize + 60)
        gridElement:SetPoint("TOPLEFT", content, "TOPLEFT", col * gridElement:GetWidth(), -row * gridElement:GetHeight())

        local dungeonIcon = gridElement:CreateTexture(nil, "OVERLAY")
        dungeonIcon:SetTexture(dungeonIcons[msg.dungeon] or "Interface\\Icons\\INV_Misc_QuestionMark")
        dungeonIcon:SetSize(iconSize, iconSize)
        dungeonIcon:SetPoint("TOP", gridElement, "TOP", 0, -10)

        local senderText = gridElement:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        senderText:SetPoint("TOP", dungeonIcon, "TOP", 0, -5)
        senderText:SetText(msg.coloredSender)
        senderText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        senderText:SetTextColor(1, 1, 1, 1)  -- White color

        if msg.difficulty ~= "Unknown" then
            local difficultyText = gridElement:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            difficultyText:SetPoint("TOP", senderText, "BOTTOM", 0, -5)
            difficultyText:SetText(msg.difficulty)
            difficultyText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
            difficultyText:SetTextColor(1, 1, 1, 1)  -- White color
            local bg = gridElement:CreateTexture(nil, "BACKGROUND")
            bg:SetTexture(0, 0, 0, 0.5)  -- Semi-transparent black background
            bg:SetPoint("CENTER", difficultyText, "CENTER", 0, 0)
            bg:SetSize(difficultyText:GetStringWidth() + 4, difficultyText:GetStringHeight() + 2)
        end

        local messageText = gridElement:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        messageText:SetPoint("TOP", difficultyText or senderText, "BOTTOM", 0, -5)
        messageText:SetWidth(gridElement:GetWidth() - 20)  -- Set the width to avoid overflowing
        messageText:SetWordWrap(true)
        messageText:SetJustifyH("CENTER")  -- Align text to the center
        messageText:SetText(string.format("%s\n|cffff8000%s|r", msg.dungeon, msg.gearScore))
        messageText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        messageText:SetTextColor(1, 1, 1, 1)  -- White color

        -- Add tooltip on hover to show the entire message in raw version
        gridElement:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(msg.message, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        gridElement:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        totalHeight = math.max(totalHeight, (row + 1) * gridElement:GetHeight())
    end

    content:SetHeight(totalHeight)

    -- Enable scrolling
    scrollFrame:SetVerticalScroll(0)
    scrollFrame:UpdateScrollChildRect()
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local newValue = self:GetVerticalScroll() - (delta * 20)
        if newValue < 0 then
            newValue = 0
        elseif newValue > self:GetVerticalScrollRange() then
            newValue = self:GetVerticalScrollRange()
        end
        self:SetVerticalScroll(newValue)
    end)
end

local function ClearChatMessages()
    chatMessages = {}
end

local function SetListening(listen)
    isListening = listen
    if listen then
        RegisterChatEvents()
    else
        UnregisterChatEvents()
    end
end

-- Register chat message events
frame:SetScript("OnEvent", HandleChatMessage)

-- Expose the functions to be used in other files
RaidSystem_CreateOngoingRaidsContent = CreateOngoingRaidsContent
RaidSystem_SetListening = SetListening
RaidSystem_ClearChatMessages = ClearChatMessages
