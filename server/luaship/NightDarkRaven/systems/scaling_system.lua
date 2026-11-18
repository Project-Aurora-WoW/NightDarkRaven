-- ============================================================================
-- Ночь темного Ворона — Система масштабирования контента под соло
-- Адаптирует квесты, мобы и награды под одного игрока без группы
-- ============================================================================

local ScalingSystem = {}

-- Пороговые уровни для соло-масштабирования
ScalingSystem.LevelRanges = {
    {min = 1, max = 20, mobCountReduce = 0.5, questItemReduce = 0.6},
    {min = 21, max = 40, mobCountReduce = 0.6, questItemReduce = 0.7},
    {min = 41, max = 60, mobCountReduce = 0.7, questItemReduce = 0.8},
    {min = 61, max = 80, mobCountReduce = 0.8, questItemReduce = 0.9},
}

-- Получить коэффициент сокращения количества мобов для соло
function ScalingSystem.GetMobCountReduce(level)
    for _, range in ipairs(ScalingSystem.LevelRanges) do
        if level >= range.min and level <= range.max then
            return range.mobCountReduce
        end
    end
    return 0.8
end

-- Получить коэффициент сокращения количества предметов квеста для соло
function ScalingSystem.GetQuestItemReduce(level)
    for _, range in ipairs(ScalingSystem.LevelRanges) do
        if level >= range.min and level <= range.max then
            return range.questItemReduce
        end
    end
    return 0.9
end

-- Уменьшить требование квеста для соло-игрока (квестовые предметы)
-- При получении предмета квеста соло-игроку начисляется удвоенное количество
function ScalingSystem.AdjustQuestItemCount(player, itemEntry, count)
    if not SoloSystem.IsSoloMode(player) then return count end

    local level = player:GetLevel()
    local reduce = ScalingSystem.GetQuestItemReduce(level)
    -- Соло-игроку достаточно собрать меньше предметов
    local needed = math.ceil(count * reduce)
    return math.max(1, needed)
end

-- Сообщение о соло-масштабировании при старте квеста
function ScalingSystem.NotifySoloScaling(player, questId)
    if not SoloSystem.IsSoloMode(player) then return end
    player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Квест масштабирован под соло-прохождение.")
end

function ScalingSystem.Init()
    print("|cff4B0082[NightDarkRaven]|r Система масштабирования соло загружена.")
end

return ScalingSystem