-- ============================================================================
-- Ночь темного Ворона — Система соло-игры
-- Режим одиночного прохождения MMORPG: масштабирование сложности под одного игрока
-- ============================================================================

local SoloSystem = {}

-- Состояние соло-режима по игрокам: [playerGUID] = {companion = guid, mode = true}
SoloSystem.SoloPlayers = {}

-- Множители сложности для соло (меньше HP/урона мобов, чтобы один игрок мог пройти)
SoloSystem.SoloMultipliers = {
    health    = 0.60, -- 60% от обычного HP моба
    damage    = 0.70, -- 70% урона
    xp        = 1.20, -- +20% опыта за соло (компенсация отсутствия группы)
    lootChance = 1.10, -- +10% шанс лута
}

-- Включить соло-режим для игрока
function SoloSystem.EnableSoloMode(player)
    local guid = player:GetGUIDLow()
    SoloSystem.SoloPlayers[guid] = {companion = nil, mode = true}
    player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Соло-режим включен. Сложность адаптирована под одного игрока.")
end

-- Выключить соло-режим
function SoloSystem.DisableSoloMode(player)
    local guid = player:GetGUIDLow()
    if SoloSystem.SoloPlayers[guid] then
        SoloSystem.SoloPlayers[guid] = nil
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Соло-режим выключен.")
    end
end

-- Проверка: находится ли игрок в соло-режиме
function SoloSystem.IsSoloMode(player)
    local guid = player:GetGUIDLow()
    return SoloSystem.SoloPlayers[guid] ~= nil and SoloSystem.SoloPlayers[guid].mode == true
end

-- Получить множитель здоровья моба для соло
function SoloSystem.GetHealthMultiplier()
    return SoloSystem.SoloMultipliers.health
end

-- Получить множитель урона моба для соло
function SoloSystem.GetDamageMultiplier()
    return SoloSystem.SoloMultipliers.damage
end

-- Получить множитель опыта для соло
function SoloSystem.GetXPMultiplier()
    return SoloSystem.SoloMultipliers.xp
end

-- Получить множитель шанса лута для соло
function SoloSystem.GetLootMultiplier()
    return SoloSystem.SoloMultipliers.lootChance
end

function SoloSystem.Init()
    print("|cff4B0082[NightDarkRaven]|r Система соло-игры загружена.")
end

return SoloSystem