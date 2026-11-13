local _, addon = ...
local L = addon.L

local panel, scroll, content
local rows = {}
local selectedMap
local columns = { L.battleground, L.ratio, L.wins, L.losses, L.draws, L.early }
local overviewColumns = { L.battleground, L.ratio, L.wins, L.losses, L.draws, L.early, L.winPercentage }
local widths = { 246, 76, 64, 64, 64, 84, 82 }
local rowHeight = 24
local contentWidth = 680

-- Instance IDs match saved results. UI map IDs resolve localized display names.
local foreverBattlegrounds = {
    [30] = { uiMapID = 91, name = "Alterac Valley" },
    [489] = { uiMapID = 92, name = "Warsong Gulch" },
    [529] = { uiMapID = 93, name = "Arathi Basin" },
    [2997] = { uiMapID = 2524, name = "Darkspear Islands" },
}

function addon.GetBattlegrounds(byMap)
    local names = {}
    for id, totals in pairs(byMap) do
        names[id] = totals.name
    end

    local index = 1
    while true do
        local info = C_PvP.GetBattlegroundInfo(index)
        if not info then
            break
        end
        if info.mapID and info.mapID > 0 and not info.isRandom and not info.isTrainingGround then
            names[info.mapID] = info.name
        end
        index = index + 1
    end

    -- Queue availability can omit battlegrounds from the client list.
    for id, battleground in pairs(foreverBattlegrounds) do
        if not names[id] then
            local map = C_Map.GetMapInfo(battleground.uiMapID)
            names[id] = map and map.name or battleground.name
        end
    end

    local maps = {}
    for id, name in pairs(names) do
        maps[#maps + 1] = { id = id, name = name }
    end
    table.sort(maps, function(a, b)
        if a.name == b.name then
            return a.id < b.id
        end
        return a.name < b.name
    end)
    return maps, names
end

local function SetRow(index, values, mapID, heading)
    local row = rows[index]
    if not row then
        row = CreateFrame("Button", nil, content)
        row:SetPoint("TOPLEFT", 0, -(index - 1) * rowHeight)
        row:SetSize(contentWidth, rowHeight)
        row:SetHighlightTexture("Interface/QuestFrame/UI-QuestTitleHighlight", "ADD")
        row:SetScript("OnClick", function(self)
            addon.OpenStatistics(self.mapID)
        end)
        row.cells = {}
        local x = 0
        for column, width in ipairs(widths) do
            local cell = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            cell:SetPoint("LEFT", x + 6, 0)
            cell:SetWidth(width - 12)
            cell:SetJustifyH(column == 1 and "LEFT" or "CENTER")
            cell:SetWordWrap(false)
            row.cells[column] = cell
            x = x + width
        end
        rows[index] = row
    end

    row.mapID = mapID
    row:EnableMouse(mapID ~= nil)
    for column, cell in ipairs(row.cells) do
        cell:SetText(values[column] or "")
        if heading then
            cell:SetTextColor(1, 0.82, 0)
        else
            cell:SetTextColor(1, 1, 1)
        end
    end
    row:Show()
end

local function Summary(name, totals)
    if not totals then
        return { name, "0:0", 0, 0, 0, 0 }
    end
    return { name, totals.ratio, totals.wins, totals.losses, totals.draws, totals.earlyDepartures }
end

local function OverviewSummary(name, totals)
    local values = Summary(name, totals)
    local wins, losses, draws = values[3], values[4], values[5]
    local completed = wins + losses + draws
    values[7] = completed > 0 and ("%.1f%%"):format(100 * wins / completed) or "—"
    return values
end

local function Render()
    local overall, byMap = addon.GetStatistics()
    local maps, names = addon.GetBattlegrounds(byMap)
    panel.TitleText:SetText(selectedMap and names[selectedMap] or L.globalStats)
    panel.back:SetShown(selectedMap ~= nil)

    local count = 0
    local function Add(values, mapID, heading)
        count = count + 1
        SetRow(count, values, mapID, heading)
    end

    if selectedMap then
        Add(columns, nil, true)
        Add(Summary(names[selectedMap] or L.battleground, byMap[selectedMap]))
        Add({ L.history }, nil, true)
        local historyHeader = count
        local matches = BGStatsCharacterDB and BGStatsCharacterDB.matches or {}
        for index = #matches, 1, -1 do
            local match = matches[index]
            if match.mapID == selectedMap then
                local outcome = match.leftEarly and L.early or L[match.outcome] or L.unknown
                Add({ date("%x %X", match.recordedAt) .. "  |  " .. outcome })
            end
        end
        if count == historyHeader then
            Add({ L.noHistory })
        end
    else
        Add(overviewColumns, nil, true)
        Add(OverviewSummary(L.globalStats, overall))
        for _, map in ipairs(maps) do
            Add(OverviewSummary(map.name, byMap[map.id]), map.id)
        end
        if #maps == 0 then
            Add({ L.empty })
        end
    end

    for index = count + 1, #rows do
        rows[index]:Hide()
    end
    content:SetHeight(math.max(scroll:GetHeight(), count * rowHeight))
end

local function CreatePanel()
    panel = CreateFrame("Frame", "BGStatsStatisticsFrame", UIParent, "BasicFrameTemplateWithInset")
    panel:SetSize(746, 400)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:Hide()
    tinsert(UISpecialFrames, panel:GetName())

    panel.back = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    panel.back:SetSize(132, 24)
    panel.back:SetPoint("TOPLEFT", 16, -28)
    panel.back:SetText(L.globalStats)
    panel.back:SetScript("OnClick", function() addon.OpenStatistics() end)

    local settings = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    settings:SetSize(112, 24)
    settings:SetPoint("TOPRIGHT", -16, -28)
    settings:SetText(L.settings)
    settings:SetScript("OnClick", function() addon.OpenSettings() end)

    scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 16, -62)
    scroll:SetPoint("BOTTOMRIGHT", -34, 18)
    content = CreateFrame("Frame", nil, scroll)
    content:SetSize(contentWidth, 1)
    scroll:SetScrollChild(content)
end

function addon.OpenStatistics(mapID)
    if not panel then
        CreatePanel()
    end
    selectedMap = mapID
    Render()
    scroll:SetVerticalScroll(0)
    panel:Show()
end

function addon.CloseStatistics()
    if panel then
        panel:Hide()
    end
end

function addon.RefreshStatistics()
    if panel and panel:IsShown() then
        C_Timer.After(0, function()
            if panel:IsShown() then
                Render()
            end
        end)
    end
end
