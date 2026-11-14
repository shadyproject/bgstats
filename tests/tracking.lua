local frame
local mapID, state, winner
local events = {}
local clock = 100
Enum = { PvPMatchState = { Inactive = 0, Waiting = 1, StartUp = 2, Engaged = 3, Complete = 5 } }
C_Commentator = { IsSpectating = function() return false end }
C_PvP = {
    IsMatchComplete = function() return state == 5 end,
    GetActiveMatchState = function() return state end,
    GetActiveMatchWinner = function() return winner end,
}

function CreateFrame()
    frame = {}
    function frame:SetScript(_, handler) self.dispatch = handler end
    function frame:RegisterEvent(event) events[event] = true end
    function frame:UnregisterEvent(event) events[event] = nil end
    return frame
end

function GetInstanceInfo()
    return "Warsong Gulch", mapID and "pvp" or "none", nil, nil, nil, nil, nil, mapID
end

function GetServerTime()
    clock = clock + 1
    return clock
end

function GetBattlefieldArenaFaction() return 1 end
function issecretvalue() return false end

local function Fire(event, ...)
    assert(events[event], event)
    frame:dispatch(event, ...)
end

local function LoadAddon()
    assert(loadfile("Tracking.lua"))("BGStats")
    Fire("ADDON_LOADED", "BGStats")
end

local function Enter()
    mapID, state = 489, 3
    Fire("PLAYER_ENTERING_WORLD", false, false)
end

local function Exit()
    Fire("PLAYER_LEAVING_WORLD")
    mapID, state = nil, 0
    Fire("PLAYER_ENTERING_WORLD", false, false)
end

LoadAddon()
local matches = BGStatsCharacterDB.matches
for index, result in ipairs({ { 1, "win" }, { 0, "loss" }, { 255, "draw" } }) do
    Enter()
    state, winner = 5, result[1]
    Fire("PVP_MATCH_COMPLETE", winner)
    Fire("PVP_MATCH_COMPLETE", winner)
    LoadAddon()
    Fire("PLAYER_ENTERING_WORLD", false, true)
    Exit()
    assert(#matches == index and matches[index].outcome == result[2])
    assert(matches[index].leftEarly == false and matches[index].joinedInProgress == true)
end

Enter()
local enteredAt = BGStatsCharacterDB.activeMatch.enteredAt
LoadAddon()
Fire("PLAYER_ENTERING_WORLD", false, true)
assert(BGStatsCharacterDB.activeMatch.enteredAt == enteredAt)
Exit()
assert(#matches == 4 and matches[4].leftEarly == true and matches[4].outcome == nil)
assert(matches[4].joinedInProgress == true)
assert(matches[4].mapID == 489 and matches[4].name == "Warsong Gulch")
assert(matches[4].recordedAt > matches[4].enteredAt)

Enter()
LoadAddon()
mapID, state = nil, 0
Fire("PLAYER_ENTERING_WORLD", true, false)
assert(#matches == 5 and matches[5].leftEarly == nil and matches[5].outcome == nil)

Enter()
LoadAddon()
state, winner = 5, 1
Fire("PLAYER_ENTERING_WORLD", true, false)
Exit()
assert(#matches == 6 and matches[6].outcome == "win" and matches[6].leftEarly == false)
Enter()
-- A hearthstone transition can clear the PvP state and instance before the exit event.
mapID, state = nil, 0
Fire("UPDATE_BATTLEFIELD_STATUS")
Fire("PLAYER_LEAVING_WORLD")
Fire("PLAYER_ENTERING_WORLD", false, false)
Fire("PLAYER_ENTERING_WORLD", false, false)
assert(#matches == 7 and matches[7].leftEarly == true and matches[7].outcome == nil)

Enter()
state = 0
Fire("PLAYER_LEAVING_WORLD")
mapID = nil
Fire("PLAYER_ENTERING_WORLD", false, false)
assert(#matches == 8 and matches[8].leftEarly == true and matches[8].outcome == nil)

Enter()
mapID, state = nil, 0
Fire("PLAYER_ENTERING_WORLD", false, false)
assert(#matches == 9 and matches[9].leftEarly == true and matches[9].outcome == nil)
Enter()
state, winner = 5, nil
Fire("PVP_MATCH_COMPLETE", winner)
mapID, state = nil, 0
Fire("PLAYER_ENTERING_WORLD", false, false)
assert(#matches == 10 and matches[10].leftEarly == false and matches[10].outcome == nil)
mapID, state = 489, 2
Fire("UPDATE_BATTLEFIELD_STATUS")
Fire("PLAYER_ENTERING_WORLD", false, false)
state = 3
Fire("UPDATE_BATTLEFIELD_STATUS")
LoadAddon()
Fire("PLAYER_ENTERING_WORLD", false, true)
Exit()
assert(matches[11].joinedInProgress == false)

LoadAddon()
mapID, state = 489, 3
Fire("UPDATE_BATTLEFIELD_STATUS")
Fire("PLAYER_ENTERING_WORLD", true, false)
Exit()
assert(matches[12].joinedInProgress == nil)
print("Tracking checks passed")
