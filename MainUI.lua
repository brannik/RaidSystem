local AceGUI = LibStub("AceGUI-3.0")

-- Create the MainUI frame
local function CreateMainUI()
    local frame = CreateFrame("Frame", "RaidSystemMainUI", UIParent)
    frame:SetSize(600, 500)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:Hide()

    -- Set the dark background
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = false,
        tileSize = 0,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    frame:SetBackdropColor(0, 0, 0, 1)  -- Ensure no transparency with a solid dark color

    -- Create the title frame
    local titleFrame = CreateFrame("Frame", nil, frame)
    titleFrame:SetPoint("TOP", frame, "TOP", 0, 20)
    titleFrame:SetSize(256, 64)
    titleFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Header",
        tile = false,
        tileSize = 0,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    titleFrame:EnableMouse(true)
    titleFrame:RegisterForDrag("LeftButton")
    titleFrame:SetScript("OnDragStart", function(self) self:GetParent():StartMoving() end)
    titleFrame:SetScript("OnDragStop", function(self) self:GetParent():StopMovingOrSizing() end)

    -- Set the title
    frame.title = titleFrame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlightLarge")
    frame.title:SetPoint("CENTER", titleFrame, "CENTER", 0, 12)
    frame.title:SetText("Raid System")

    -- Add gryphons around the title
    local leftGryphon = titleFrame:CreateTexture(nil, "ARTWORK")
    leftGryphon:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-EndCap-Human")
    leftGryphon:SetPoint("RIGHT", frame.title, "LEFT", -13, 28)
    leftGryphon:SetSize(64, 64)

    local rightGryphon = titleFrame:CreateTexture(nil, "ARTWORK")
    rightGryphon:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-EndCap-Human")
    rightGryphon:SetPoint("LEFT", frame.title, "RIGHT", 13, 28)
    rightGryphon:SetSize(64, 64)
    rightGryphon:SetTexCoord(1, 0, 0, 1)  -- Flip the texture horizontally

    -- Create a close button
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

    -- Create a container for the tabs and content
    local container = CreateFrame("Frame", nil, frame)
    container:SetSize(580, 460)
    container:SetPoint("TOPLEFT", 10, -30)

    -- Create frames for each tab's content
    local ongoingRaidsContent = CreateFrame("Frame", "OngoingRaidsContent", container)
    ongoingRaidsContent:SetPoint("TOPLEFT", container, "TOPLEFT", 160, 0)
    ongoingRaidsContent:SetSize(420, 460)
    ongoingRaidsContent:SetBackdrop({
        bgFile = "Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal",
        edgeFile = "Interface\\AchievementFrame\\UI-Achievement-WoodBorder",
        tile = false,
        tileSize = 0,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })

    local createRaidContent = CreateFrame("Frame", "CreateRaidContent", container)
    createRaidContent:SetPoint("TOPLEFT", container, "TOPLEFT", 160, 0)
    createRaidContent:SetSize(420, 460)
    createRaidContent:SetBackdrop({
        bgFile = "Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal",
        edgeFile = "Interface\\AchievementFrame\\UI-Achievement-WoodBorder",
        tile = false,
        tileSize = 0,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })

    -- Add debug text to create raid content
    local createRaidDebugText = createRaidContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    createRaidDebugText:SetPoint("TOPLEFT", createRaidContent, "TOPLEFT", 10, -10)
    createRaidDebugText:SetText("Debug: Create Raid Content Loaded")

    -- Create a custom template for the tabs
    local function CreateTab(parent, id, text, contentFrame, onShow, onHide)
        local tab = CreateFrame("Button", "RaidSystemTab" .. id, parent, "UIPanelButtonTemplate")
        tab:SetSize(130, 25)  -- Adjust the width and height to fit the text and remove empty space
        tab:SetText(text)
        tab:GetFontString():SetPoint("LEFT", tab, "LEFT", 10, 0)  -- Align the text to the left
        tab:GetFontString():SetWidth(tab:GetWidth() - 20)  -- Add padding to the text
        tab:SetNormalFontObject("GameFontNormalSmall")
        tab:SetHighlightFontObject("GameFontHighlightSmall")
        tab:SetDisabledFontObject("GameFontDisableSmall")
        tab:SetScript("OnClick", function(self)
            -- Hide all content frames
            ongoingRaidsContent:Hide()
            createRaidContent:Hide()
            
            -- Call the onHide function if provided
            if onHide then
                onHide()
            end

            -- Show the selected content frame
            contentFrame:Show()
            -- Call the onShow function if provided
            if onShow then
                onShow()
            end
            -- Update tab selection
            for i = 1, 2 do
                local otherTab = _G["RaidSystemTab" .. i]
                if otherTab then
                    otherTab:SetNormalFontObject("GameFontNormalSmall")
                    otherTab:SetHighlightFontObject("GameFontHighlightSmall")
                    otherTab:SetDisabledFontObject("GameFontDisableSmall")
                end
            end
            self:SetNormalFontObject("GameFontHighlightSmall")  -- Highlight the selected tab
        end)
        return tab
    end

    -- Add a dummy button for the faction image
    local factionButton = CreateFrame("Button", nil, container)
    factionButton:SetSize(64, 64)
    factionButton:SetPoint("TOPLEFT", container, "TOPLEFT", 43, -5)  -- Add spacing from the left to center the dummy button

    -- Add faction image to the dummy button
    local englishFaction = UnitFactionGroup("player")
    local factionImage
    if englishFaction == "Alliance" then
        factionImage = "Interface\\AddOns\\RaidSystem\\media\\faction\\Alliance.blp"
    elseif englishFaction == "Horde" then
        factionImage = "Interface\\AddOns\\RaidSystem\\media\\faction\\Horde.blp"
    end

    if factionImage then
        local factionTexture = factionButton:CreateTexture(nil, "OVERLAY")
        factionTexture:SetTexture(factionImage)
        factionTexture:SetAllPoints(factionButton)
    end

    frame.tab1 = CreateTab(container, 1, "Ongoing Raids", ongoingRaidsContent, function()
        RaidSystem_ClearChatMessages()
        RaidSystem_SetListening(true)
        RaidSystem_CreateOngoingRaidsContent(ongoingRaidsContent)
    end, function()
        RaidSystem_SetListening(false)
    end)
    frame.tab1:SetPoint("TOPLEFT", container, "TOPLEFT", 5, -75)  -- Position the tab buttons below the faction image

    frame.tab2 = CreateTab(container, 2, "Create Raid", createRaidContent)
    frame.tab2:SetPoint("TOPLEFT", frame.tab1, "BOTTOMLEFT", 0, -5)  -- Reduce the spacing between the buttons

    -- Set the initial tab
    frame.tab1:Click()

    return frame
end

MainUI = CreateMainUI()
