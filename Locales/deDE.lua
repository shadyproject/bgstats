if GetLocale() ~= "deDE" then
    return
end

local _, addon = ...
local L = addon.L

L.globalStats = "Gesamtstatistik"
L.settings = "Einstellungen"
L.battleground = "Schlachtfeld"
L.ratio = "Siege/Niederlagen"
L.wins = "Siege"
L.losses = "Niederlagen"
L.draws = "Unentschieden"
L.early = "Vorzeitig verlassen"
L.empty = "Keine Schlachtfelder verfügbar."
L.noHistory = "Für dieses Schlachtfeld wurden keine Partien erfasst."
L.history = "Partienverlauf"
L.win = "Sieg"
L.loss = "Niederlage"
L.draw = "Unentschieden"
L.unknown = "Ergebnis nicht verfügbar"
L.showIcon = "Minikartensymbol anzeigen"
L.resetIcon = "Position des Minikartensymbols zurücksetzen"
L.openStats = "Schlachtfeldstatistik öffnen"
L.dragIcon = "Zum Verschieben ziehen"
