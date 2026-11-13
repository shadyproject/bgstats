if GetLocale() ~= "ruRU" then
    return
end

local _, addon = ...
local L = addon.L

L.globalStats = "Общая статистика"
L.settings = "Настройки"
L.battleground = "Поле боя"
L.ratio = "Победы/Поражения"
L.winPercentage = "% побед"
L.wins = "Победы"
L.losses = "Поражения"
L.draws = "Ничьи"
L.early = "Досрочные выходы"
L.empty = "Нет доступных полей боя."
L.noHistory = "Для этого поля боя нет записанных матчей."
L.history = "История матчей"
L.win = "Победа"
L.loss = "Поражение"
L.draw = "Ничья"
L.unknown = "Результат недоступен"
L.showIcon = "Показывать значок на мини-карте"
L.resetIcon = "Сбросить положение значка"
L.openStats = "Открыть статистику полей боя"
L.dragIcon = "Перетащите для перемещения"
