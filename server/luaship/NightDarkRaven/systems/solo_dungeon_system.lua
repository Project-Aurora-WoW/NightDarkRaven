-- ============================================================================
-- Ночь темного Ворона — Соло-подземелья
-- Инстансированные подземелья, доступные только одному игроку (или с компаньоном)
-- ============================================================================

local SoloDungeonSystem = {}

-- Соло-подземелья (id, название, карта, уровень, описание, координаты входа)
SoloDungeonSystem.Dungeons = {
    [93001] = {
        name = "Соло-ритуал Теней",
        map = 0,
        minLevel = 10,
        maxLevel = 20,
        desc = "Масштабированное подземелье кампании 1. Вход: один игрок.",
        entryX = -8920.0, entryY = 540.0, entryZ = 100.0,
    },
    [93002] = {
        name = "Соло-Храм Забвения",
        map = 0,
        minLevel = 55,
        maxLevel = 65,
        desc = "Подземелье кампании 6 для одного героя.",
        entryX = -9000.0, entryY = 580.0, entryZ = 100.0,
    },
    [93003] = {
        name = "Соло-Крепость Ночного Ворона",
        map = 0,
        minLevel = 75,
        maxLevel = 80,
        desc = "Финальное соло-подземелье campaña 11.",
        entryX = -9100.0, entryY = 630.0, entryZ = 100.0,
    },
}

-- Активные соло-инстансы (playerGUID -> dungeonId)
SoloDungeonSystem.ActiveInstances = {}

function SoloDungeonSystem.GetDungeon(dungeonId)
    return SoloDungeonSystem.Dungeons[dungeonId]
end

function SoloDungeonSystem.IsInSoloDungeon(player)
    local guid = player:GetGUIDLow()
    return SoloDungeonSystem.ActiveInstances[guid] ~= nil
end

function SoloDungeonSystem.EnterSoloDungeon(player, dungeonId)
    local dungeon = SoloDungeonSystem.GetDungeon(dungeonId)
    if not dungeon then return false end

    local level = player:GetLevel()
    if level < dungeon.minLevel or level > dungeon.maxLevel then
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Ваш уровень не подходит для этого подземелья (" .. dungeon.minLevel .. "-" .. dungeon.maxLevel .. ").")
        return false
    end

    if SoloSystem.IsSoloMode(player) == false then
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Включите соло-режим для входа.")
        return false
    end

    -- Телепортируем в подземелье (заглушка — координаты входа на карте)
    player:Teleport(dungeon.map, dungeon.entryX, dungeon.entryY, dungeon.entryZ, 0)

    local guid = player:GetGUIDLow()
    SoloDungeonSystem.ActiveInstances[guid] = dungeonId

    player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Вы вошли в соло-подземелье: " .. dungeon.name .. ".")
    return true
end

function SoloDungeonSystem.ExitSoloDungeon(player)
    local guid = player:GetGUIDLow()
    local dungeonId = SoloDungeonSystem.ActiveInstances[guid]
    if not dungeonId then return false end

    SoloDungeonSystem.ActiveInstances[guid] = nil
    player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Вы вышли из соло-подземелья.")
    return true
end

function SoloDungeonSystem.Init()
    local count = 0
    for _ in pairs(SoloDungeonSystem.Dungeons) do count = count + 1 end
    print("|cff4B0082[NightDarkRaven]|r Система соло-подземелий: " .. count .. " инстансов.")
end

return SoloDungeonSystem