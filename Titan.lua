local _, addon = ...
local L = addon.L
local id = "BGStats"

if not (Titan_G and Titan_G.plugins and Titan_Menu and Titan_Menu.AddCommand) then
    return
end

local function BuildMenu(_, root)
    Titan_Menu.AddCommand(root, id, L.globalStats, addon.OpenStatistics)
    local _, byMap = addon.GetStatistics()
    for _, map in ipairs(addon.GetBattlegrounds(byMap)) do
        Titan_Menu.AddCommand(root, id, map.name, addon.OpenStatistics, map.id)
    end
    Titan_Menu.AddCommand(root, id, L.settings, addon.OpenSettings)
end

local button = CreateFrame("Button", "TitanPanelBGStatsButton", UIParent, "TitanPanelComboTemplate")
button.registry = {
    id = id,
    menuText = L.title,
    menuContextFunction = BuildMenu,
    buttonTextFunction = function() return "", L.title end,
    icon = addon.iconTexture,
    iconWidth = 16,
    controlVariables = { ShowIcon = true },
    savedVariables = { ShowIcon = true },
}
button:SetScript("OnClick", function(self, mouseButton)
    if mouseButton == "LeftButton" then
        addon.OpenStatistics()
    end
    Titan_G.plugins.OnClick(self, mouseButton)
end)
