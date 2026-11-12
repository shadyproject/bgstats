local addon = {}
assert(loadfile("Statistics.lua"))("BGStats", addon)

local overall, byMap = addon.GetStatistics()
assert(overall.ratio == "0:0" and next(byMap) == nil)

BGStatsCharacterDB = {
    matches = {
        { mapID = 489, name = "Warsong Gulch", outcome = "win" },
        { mapID = 489, name = "Warsongschlucht", outcome = "draw", leftEarly = false },
        { mapID = 489, name = "Warsongschlucht", leftEarly = true },
        { mapID = 529, name = "Arathi Basin", outcome = "loss", leftEarly = false },
        { mapID = 529, name = "Arathi Basin" },
    },
}

overall, byMap = addon.GetStatistics()
assert(overall.wins == 1 and overall.losses == 1 and overall.draws == 1)
assert(overall.earlyDepartures == 1 and overall.ratio == "1:1")
assert(byMap[489].name == "Warsongschlucht")
assert(byMap[489].wins == 1 and byMap[489].draws == 1)
assert(byMap[489].earlyDepartures == 1 and byMap[489].ratio == "1:0")
assert(byMap[529].earlyDepartures == 0 and byMap[529].ratio == "0:1")

BGStatsCharacterDB = { matches = {} }
overall, byMap = addon.GetStatistics()
assert(overall.earlyDepartures == 0 and overall.ratio == "0:0" and next(byMap) == nil)
print("Statistics checks passed")
