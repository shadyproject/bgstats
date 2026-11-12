local _, addon = ...

local function NewTotals()
    return { wins = 0, losses = 0, draws = 0, earlyDepartures = 0 }
end

local function CountMatch(totals, match)
    if match.outcome == "win" then
        totals.wins = totals.wins + 1
    elseif match.outcome == "loss" then
        totals.losses = totals.losses + 1
    elseif match.outcome == "draw" then
        totals.draws = totals.draws + 1
    end

    if match.leftEarly == true then
        totals.earlyDepartures = totals.earlyDepartures + 1
    end
end

local function SetRatio(totals)
    totals.ratio = ("%d:%d"):format(totals.wins, totals.losses)
end

function addon.GetStatistics()
    local overall = NewTotals()
    local byMap = {}
    local matches = BGStatsCharacterDB and BGStatsCharacterDB.matches

    if matches then
        for _, match in ipairs(matches) do
            local totals = byMap[match.mapID]
            if not totals then
                totals = NewTotals()
                byMap[match.mapID] = totals
            end
            totals.name = match.name
            CountMatch(totals, match)
            CountMatch(overall, match)
        end
    end

    SetRatio(overall)
    for _, totals in pairs(byMap) do
        SetRatio(totals)
    end
    return overall, byMap
end
