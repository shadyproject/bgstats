if GetLocale() ~= "zhCN" then
    return
end

local _, addon = ...
local L = addon.L

L.globalStats = "总体统计"
L.settings = "设置"
L.battleground = "战场"
L.ratio = "胜/负"
L.wins = "胜利"
L.losses = "失败"
L.draws = "平局"
L.early = "提前离场"
L.empty = "没有可用的战场。"
L.noHistory = "此战场暂无对局记录。"
L.history = "对局记录"
L.win = "胜利"
L.loss = "失败"
L.draw = "平局"
L.unknown = "结果未知"
L.showIcon = "显示小地图图标"
L.resetIcon = "重置小地图图标位置"
L.openStats = "打开战场统计"
L.dragIcon = "拖动以移动"
