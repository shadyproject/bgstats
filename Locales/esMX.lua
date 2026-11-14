if GetLocale() ~= "esMX" then
    return
end

local _, addon = ...
local L = addon.L

L.globalStats = "Estadísticas generales"
L.settings = "Configuración"
L.battleground = "Campo de batalla"
L.ratio = "Victorias/Derrotas"
L.winPercentage = "% victorias"
L.wins = "Victorias"
L.losses = "Derrotas"
L.draws = "Empates"
L.early = "Abandonos"
L.empty = "No hay campos de batalla disponibles."
L.noHistory = "No hay partidas registradas en este campo de batalla."
L.history = "Historial de partidas"
L.joinedInProgress = "Entrada con partida en curso"
L.win = "Victoria"
L.loss = "Derrota"
L.draw = "Empate"
L.unknown = "Resultado no disponible"
L.showIcon = "Mostrar el ícono del minimapa"
L.resetIcon = "Restablecer la posición del ícono del minimapa"
L.openStats = "Abrir las estadísticas de campos de batalla"
L.dragIcon = "Arrastra para mover"
