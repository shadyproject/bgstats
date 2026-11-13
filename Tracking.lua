local addonName, addon = ...
local tracker = CreateFrame("Frame")
local db

local function FinishMatch(outcome, leftEarly)
    local match = db.activeMatch
    if not match or match.recorded then
        return
    end

    db.matches[#db.matches + 1] = {
        mapID = match.mapID,
        name = match.name,
        enteredAt = match.enteredAt,
        recordedAt = GetServerTime(),
        outcome = outcome,
        leftEarly = leftEarly,
    }
    match.recorded = true
    if addon and addon.RefreshStatistics then
        addon.RefreshStatistics()
    end
end

local function RecordResult(winner)
    if issecretvalue(winner) or type(winner) ~= "number" then
        return
    end
    if winner == 255 then
        FinishMatch("draw", false)
    elseif winner == 0 or winner == 1 then
        local team = GetBattlefieldArenaFaction()
        if not issecretvalue(team) and (team == 0 or team == 1) then
            FinishMatch(winner == team and "win" or "loss", false)
        end
    end
end

local function GetBattleground()
    local name, instanceType, _, _, _, _, _, mapID = GetInstanceInfo()
    if instanceType == "pvp" and not C_Commentator.IsSpectating() then
        return mapID, name
    end
end

local function ReconcileMatch(isWorldEntry, isRestart, completionEvent)
    local mapID, name = GetBattleground()
    local active = db.activeMatch
    if active and active.mapID ~= mapID then
        if not isWorldEntry then
            return
        end

        local leftEarly
        if active.completed then
            leftEarly = false
        -- A teleport can clear the PvP state before the world transition events.
        elseif not isRestart then
            leftEarly = true
        end
        FinishMatch(nil, leftEarly)
        db.activeMatch = nil
        active = nil
    end
    if not mapID then
        return
    end

    if not active then
        db.activeMatch = {
            mapID = mapID,
            name = name,
            enteredAt = GetServerTime(),
        }
    end
    active = db.activeMatch
    if completionEvent then
        active.completed = true
    elseif C_PvP.IsMatchComplete() then
        active.completed = true
        RecordResult(C_PvP.GetActiveMatchWinner())
    end
end

function tracker:ADDON_LOADED(loadedName)
    if loadedName ~= addonName then
        return
    end
    self:UnregisterEvent("ADDON_LOADED")
    BGStatsCharacterDB = BGStatsCharacterDB or { version = 1, matches = {} }
    db = BGStatsCharacterDB
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LEAVING_WORLD")
    self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
    self:RegisterEvent("PVP_MATCH_COMPLETE")
end

function tracker:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUI)
    ReconcileMatch(true, isInitialLogin or isReloadingUI)
end

function tracker:PLAYER_LEAVING_WORLD()
    ReconcileMatch(false)
end

function tracker:UPDATE_BATTLEFIELD_STATUS()
    ReconcileMatch(false)
end

function tracker:PVP_MATCH_COMPLETE(winner)
    local mapID = GetBattleground()
    if not mapID then
        return
    end
    ReconcileMatch(false, false, true)
    if db.activeMatch and db.activeMatch.mapID == mapID then
        RecordResult(winner)
    end
end

tracker:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)
tracker:RegisterEvent("ADDON_LOADED")
