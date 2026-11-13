if GetLocale() ~= "koKR" then
    return
end

local _, addon = ...
local L = addon.L

L.globalStats = "전체 통계"
L.settings = "설정"
L.battleground = "전장"
L.ratio = "승/패"
L.wins = "승리"
L.losses = "패배"
L.draws = "무승부"
L.early = "중도 이탈"
L.empty = "이용 가능한 전장이 없습니다."
L.noHistory = "이 전장에 기록된 경기가 없습니다."
L.history = "경기 기록"
L.win = "승리"
L.loss = "패배"
L.draw = "무승부"
L.unknown = "결과 확인 불가"
L.showIcon = "미니맵 아이콘 표시"
L.resetIcon = "미니맵 아이콘 위치 초기화"
L.openStats = "전장 통계 열기"
L.dragIcon = "끌어서 이동"
