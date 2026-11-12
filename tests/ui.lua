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
BGStatsCharacterDB = {
    matches = {
        { mapID = 489, name = "Warsongschlucht", outcome = "win", recordedAt = 100 },
        { mapID = 489, name = "Warsongschlucht", leftEarly = true, recordedAt = 200 },
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

local function Load(file)
    assert(loadfile(file))("BGStats", addon)
end

Load("Locales/enUS.lua")
Load("Statistics.lua")
Load("UI.lua")
Load("Launcher.lua")
frames[#frames].scripts.OnEvent(frames[#frames], "PLAYER_LOGIN")
Load("Titan.lua")

local icon = Find("name", "BGStatsMinimapButton")
assert(icon:IsShown())
icon.scripts.OnClick()
local panel = Find("name", "BGStatsStatisticsFrame")
assert(panel:IsShown() and panel.TitleText.text == "Global Stats")
local warsong = Find("text", "Warsong Gulch")
warsong.parent.scripts.OnClick(warsong.parent)
assert(panel.TitleText.text == "Warsong Gulch")
assert(Find("text", date("%x %X", 200) .. "  |  Left Early"))
BGStatsCharacterDB.matches[3] = { mapID = 489, name = "Warsong Gulch", outcome = "draw", recordedAt = 300 }
addon.RefreshStatistics()
assert(Find("text", date("%x %X", 300) .. "  |  Draw"))

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
assert(#menu == 4 and menu[1].label == "Global Stats" and menu[2].label == "Arathi Basin")
menu[2].click()
assert(panel.TitleText.text == "Arathi Basin")
assert(Find("text", "No matches recorded for this battleground."))
menu[4].click()
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
