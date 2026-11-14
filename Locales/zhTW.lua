if GetLocale() ~= "zhTW" then
    return
end

local _, addon = ...
local L = addon.L

L.globalStats = "整體統計"
L.settings = "設定"
L.battleground = "戰場"
L.ratio = "勝/敗"
L.winPercentage = "勝率"
L.wins = "勝利"
L.losses = "失敗"
L.draws = "平手"
L.early = "提前離場"
L.empty = "沒有可用的戰場。"
L.noHistory = "此戰場尚無對戰紀錄。"
L.history = "對戰紀錄"
L.joinedInProgress = "中途加入"
L.win = "勝利"
L.loss = "失敗"
L.draw = "平手"
L.unknown = "結果未知"
L.showIcon = "顯示小地圖圖示"
L.resetIcon = "重設小地圖圖示位置"
L.openStats = "開啟戰場統計"
L.dragIcon = "拖曳以移動"
