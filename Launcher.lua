local _, addon = ...
local L = addon.L

local icon
local category
local defaultAngle = math.rad(220)
local iconTexture = "Interface/Icons/INV_BannerPVP_02"
addon.iconTexture = iconTexture

local function UpdateIconPosition()
    local angle = BGStatsSettings.minimapAngle or defaultAngle
    local radius = Minimap:GetWidth() / 2 + 4
    icon:ClearAllPoints()
    icon:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function DragIcon()
    local x, y = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    local centerX, centerY = Minimap:GetCenter()
    BGStatsSettings.minimapAngle = math.atan2(y / scale - centerY, x / scale - centerX)
    UpdateIconPosition()
end

local function CreateMinimapIcon()
    icon = CreateFrame("Button", "BGStatsMinimapButton", Minimap)
    icon:SetSize(31, 31)
    icon:SetFrameStrata("MEDIUM")
    icon:SetNormalTexture(iconTexture)
    local texture = icon:GetNormalTexture()
    texture:ClearAllPoints()
    texture:SetPoint("CENTER")
    texture:SetSize(19, 19)
    texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local border = icon:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface/Minimap/MiniMap-TrackingBorder")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT")
    icon:SetHighlightTexture("Interface/Minimap/UI-Minimap-ZoomButton-Highlight", "ADD")
    icon:RegisterForDrag("LeftButton")
    icon:SetScript("OnDragStart", function(self)
        GameTooltip:Hide()
        self:SetScript("OnUpdate", DragIcon)
    end)
    local function StopDrag(self)
        self:SetScript("OnUpdate", nil)
    end
    icon:SetScript("OnDragStop", StopDrag)
    icon:SetScript("OnHide", StopDrag)
    icon:SetScript("OnClick", function() addon.OpenStatistics() end)
    icon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(L.title)
        GameTooltip:AddLine(L.openStats)
        GameTooltip:AddLine(L.dragIcon)
        GameTooltip:Show()
    end)
    icon:SetScript("OnLeave", function() GameTooltip:Hide() end)
    Minimap:HookScript("OnSizeChanged", UpdateIconPosition)
    UpdateIconPosition()
    icon:SetShown(not BGStatsSettings.hideMinimap)
end

local function RegisterSettings()
    local settings = CreateFrame("Frame")
    local title = settings:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(L.title)

    local check = CreateFrame("CheckButton", nil, settings, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", 12, -48)
    local label = check:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    label:SetPoint("LEFT", check, "RIGHT", 4, 0)
    label:SetText(L.showIcon)
    check:SetScript("OnClick", function(self)
        BGStatsSettings.hideMinimap = not self:GetChecked()
        icon:SetShown(not BGStatsSettings.hideMinimap)
    end)
    settings:SetScript("OnShow", function()
        check:SetChecked(not BGStatsSettings.hideMinimap)
    end)

    local reset = CreateFrame("Button", nil, settings, "UIPanelButtonTemplate")
    reset:SetPoint("TOPLEFT", 16, -92)
    reset:SetSize(230, 24)
    reset:SetText(L.resetIcon)
    reset:SetScript("OnClick", function()
        BGStatsSettings.minimapAngle = nil
        UpdateIconPosition()
    end)

    category = Settings.RegisterCanvasLayoutCategory(settings, L.title)
    Settings.RegisterAddOnCategory(category)
end

function addon.OpenSettings()
    addon.CloseStatistics()
    Settings.OpenToCategory(category:GetID())
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    BGStatsSettings = BGStatsSettings or {}
    CreateMinimapIcon()
    RegisterSettings()
end)
