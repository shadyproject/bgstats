local function LoadStrings(locale)
    GetLocale = function() return locale end
    local addon = {}
    for line in io.lines("BGStats.toc") do
        if line:match("^Locales/.*%.lua$") then
            assert(loadfile(line))("BGStats", addon)
        end
    end
    return addon.L
end

local english = LoadStrings("enUS")
local locales = { "deDE", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW" }
for _, locale in ipairs(locales) do
    local strings = LoadStrings(locale)
    for key, value in pairs(english) do
        assert(type(strings[key]) == "string" and strings[key] ~= "", locale .. ": " .. key)
        if key == "title" then
            assert(strings[key] == value, locale .. ": title")
        else
            assert(strings[key] ~= value, locale .. ": " .. key .. " was not translated")
        end
    end
    for key in pairs(strings) do
        assert(english[key], locale .. ": unknown key " .. key)
    end
end

for _, locale in ipairs({ "enGB", "unsupported" }) do
    local strings = LoadStrings(locale)
    for key, value in pairs(english) do
        assert(strings[key] == value, locale .. ": " .. key)
    end
end
print("Localization checks passed")
