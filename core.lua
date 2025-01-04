-- ...existing code...

local RaidSystem = LibStub("AceAddon-3.0"):NewAddon("RaidSystem", "AceConsole-3.0", "AceEvent-3.0")

function RaidSystem:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("RaidSystemDB", {
        profile = {
            minimap = {
                hide = false,
            },
        },
    })
    print("RaidSystem initialized")
end

function RaidSystem:OnEnable()
    -- Called when the addon is enabled
end

function RaidSystem:OnDisable()
    -- Called when the addon is disabled
end

function RaidSystem:GetPlayerFaction()
    local faction = UnitFactionGroup("player")
    return faction
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(event, addonName)
    if addonName == "RaidSystem" then
        -- Initialize the minimap button
        local icon = LibStub("LibDBIcon-1.0")
        icon:Register("RaidSystem", RaidSystem.LDB, RaidSystem.db.profile.minimap)
        icon:Show("RaidSystem")
        print("Minimap button shown")

        -- Print the player's faction
        local faction = RaidSystem:GetPlayerFaction()
        print("Player faction: " .. faction)
    end
end)

-- ...existing code...
