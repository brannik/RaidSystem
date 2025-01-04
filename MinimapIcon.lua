local RaidSystem = LibStub("AceAddon-3.0"):GetAddon("RaidSystem")

local function CreateMinimapButton()
    local button = CreateFrame("Button", "RaidSystemMinimapButton", Minimap)
    button:SetFrameStrata("MEDIUM")
    button:SetSize(31, 31)
    button:SetFrameLevel(8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetPoint("TOPLEFT")

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Head_Dragon_01") -- Use an existing raid-related icon
    icon:SetPoint("CENTER")

    button:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            if MainUI:IsShown() then
                MainUI:Hide()
            else
                MainUI:Show()
            end
        end
    end)

    button:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    button:SetMovable(true)
    button:EnableMouse(true)
    button:RegisterForDrag("LeftButton")

    -- Position the button around the minimap
    button:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
    button:Show()

    print("Minimap button created and positioned")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    CreateMinimapButton()
end)
