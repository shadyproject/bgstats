local addon = {}
local frames = {}
local methods = {
    SetScript = function(self, event, callback) self.scripts[event] = callback end,
    SetText = function(self, value) self.text = value end,
    SetChecked = function(self, value) self.checked = value end,
    GetChecked = function(self) return self.checked end,
    GetName = function(self) return self.name end,
    GetWidth = function() return 140 end,
    GetHeight = function() return 300 end,
    GetNormalTexture = function(self) return self:CreateTexture() end,
    IsShown = function(self) return self.shown end,
    SetShown = function(self, value) self.shown = value end,
    Hide = function(self) self.shown = false end,
    Show = function(self) self.shown = true end,
}

local function NewFrame(name, parent)
    local frame = setmetatable({ name = name, parent = parent, scripts = {} }, {
        __index = function(_, key)
            assert(key:match("^Set") or key:match("^Register") or key:match("^Unregister")
                or key == "EnableMouse" or key == "ClearAllPoints" or key == "HookScript", key)
            return function() end
        end,
    })
    for key, value in pairs(methods) do
        frame[key] = value
    end
    frame.CreateFontString = function(self) return NewFrame(nil, self) end
    frame.CreateTexture = frame.CreateFontString
    frames[#frames + 1] = frame
    return frame
end

function CreateFrame(_, name, parent, template)
    local frame = NewFrame(name, parent)
    if template == "BasicFrameTemplateWithInset" then
        frame.TitleText = frame:CreateFontString()
    end
    return frame
end

Minimap = NewFrame("Minimap")
UIParent = NewFrame("UIParent")
UISpecialFrames = {}
tinsert, date = table.insert, os.date
C_Timer = { After = function(_, callback) callback() end }
local catalog = {
    { mapID = 489, name = "Warsong Gulch" },
    { mapID = 529, name = "Arathi Basin" },
    { mapID = 1, name = "Random", isRandom = true },
}
C_PvP = { GetBattlegroundInfo = function(index) return catalog[index] end }
C_Map = { GetMapInfo = function(id)
    local names = { [91] = "Alterac Valley", [92] = "Warsong Gulch", [93] = "Arathi Basin" }
    return names[id] and { name = names[id] }
end }
BGStatsCharacterDB = {
    matches = {
        { mapID = 489, name = "Warsongschlucht", outcome = "win", recordedAt = 100 },
        { mapID = 489, name = "Warsongschlucht", leftEarly = true, joinedInProgress = true, recordedAt = 200 },
    },
}
local canvas, opened
Settings = {
    RegisterCanvasLayoutCategory = function(frame)
        canvas = frame
        return { GetID = function() return 42 end }
    end,
    RegisterAddOnCategory = function() end,
    OpenToCategory = function(id) opened = id end,
}

local function Find(key, value)
    for _, frame in ipairs(frames) do
        if rawget(frame, key) == value then
            return frame
        end
    end
    error("Frame not found for " .. tostring(value))
end

local function FindRow(name)
    for _, frame in ipairs(frames) do
        local cells = rawget(frame, "cells")
        if cells and cells[1].text == name then
            return frame
        end
    end
    error("Row not found for " .. name)
end

local function Load(file)
    assert(loadfile(file))("BGStats", addon)
end

Load("Locales/enUS.lua")
Load("Statistics.lua")
Load("UI.lua")
SlashCmdList = {}
Load("Launcher.lua")
frames[#frames].scripts.OnEvent(frames[#frames], "PLAYER_LOGIN")
Load("Titan.lua")

local icon = Find("name", "BGStatsMinimapButton")
assert(icon:IsShown())
icon.scripts.OnClick()
local panel = Find("name", "BGStatsStatisticsFrame")
panel:Hide()
assert(SLASH_BGSTATS1 == "/bgstats")
SlashCmdList.BGSTATS("")
assert(panel:IsShown() and panel.TitleText.text == "Global Stats")
assert(Find("text", "Win %"))
assert(FindRow("Global Stats").cells[7].text == "100.0%")
assert(FindRow("Arathi Basin").cells[7].text == "—")
assert(FindRow("Alterac Valley").mapID == 30)
local _, names = addon.GetBattlegrounds({})
local getBattlegroundInfo = C_PvP.GetBattlegroundInfo
C_PvP.GetBattlegroundInfo = function() end
local defaultMaps, defaultNames = addon.GetBattlegrounds({})
assert(#defaultMaps == 4)
for _, id in ipairs({ 30, 489, 529, 2997 }) do
    assert(defaultNames[id] == names[id])
end
C_PvP.GetBattlegroundInfo = getBattlegroundInfo
local darkspear = FindRow("Darkspear Islands")
assert(darkspear.mapID == 2997 and darkspear.cells[2].text == "0:0")
assert(darkspear.cells[3].text == 0 and darkspear.cells[4].text == 0)
local warsong = Find("text", "Warsong Gulch")
assert(warsong.parent.cells[7].text == "100.0%")
warsong.parent.scripts.OnClick(warsong.parent)
assert(panel.TitleText.text == "Warsong Gulch")
assert(Find("text", date("%x %X", 200) .. "  |  Left Early").parent.cells[2].text == "Joined in progress")
BGStatsCharacterDB.matches[3] = { mapID = 489, name = "Warsong Gulch", outcome = "draw", recordedAt = 300 }
addon.RefreshStatistics()
assert(Find("text", date("%x %X", 300) .. "  |  Draw"))

addon.OpenStatistics()
assert(FindRow("Global Stats").cells[7].text == "50.0%")
assert(FindRow("Warsong Gulch").cells[7].text == "50.0%")

Titan_G = { plugins = { OnClick = function() end } }
Titan_Menu = {
    AddCommand = function(root, _, label, callback, argument)
        root[#root + 1] = { label = label, click = function() callback(argument) end }
    end,
}
Load("Titan.lua")
local plugin = Find("name", "TitanPanelBGStatsButton")
local menu = {}
plugin.registry.menuContextFunction(plugin, menu)
assert(#menu == 6 and menu[1].label == "Global Stats" and menu[2].label == "Alterac Valley")
menu[2].click()
assert(panel.TitleText.text == "Alterac Valley")
assert(Find("text", "No matches recorded for this battleground."))
menu[6].click()
assert(opened == 42 and not panel:IsShown())

canvas.scripts.OnShow()
local check = Find("text", "Show minimap icon").parent
assert(check:GetChecked())
check:SetChecked(false)
check.scripts.OnClick(check)
assert(BGStatsSettings.hideMinimap and not icon:IsShown())
check:SetChecked(true)
check.scripts.OnClick(check)
assert(not BGStatsSettings.hideMinimap and icon:IsShown())
BGStatsSettings.minimapAngle = 0
Find("text", "Reset minimap icon position").scripts.OnClick()
assert(BGStatsSettings.minimapAngle == nil)
print("UI checks passed")
