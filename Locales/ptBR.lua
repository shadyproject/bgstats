if GetLocale() ~= "ptBR" then
    return
end

local _, addon = ...
local L = addon.L

L.globalStats = "Estatísticas gerais"
L.settings = "Configurações"
L.battleground = "Campo de batalha"
L.ratio = "Vitórias/Derrotas"
L.wins = "Vitórias"
L.losses = "Derrotas"
L.draws = "Empates"
L.early = "Abandonos"
L.empty = "Nenhum campo de batalha disponível."
L.noHistory = "Nenhuma partida registrada neste campo de batalha."
L.history = "Histórico de partidas"
L.win = "Vitória"
L.loss = "Derrota"
L.draw = "Empate"
L.unknown = "Resultado indisponível"
L.showIcon = "Mostrar ícone do minimapa"
L.resetIcon = "Redefinir a posição do ícone do minimapa"
L.openStats = "Abrir estatísticas dos campos de batalha"
L.dragIcon = "Arraste para mover"
