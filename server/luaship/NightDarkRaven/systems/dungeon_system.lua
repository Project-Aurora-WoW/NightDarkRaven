-- ============================================================================
-- Ночь темного Ворона — Система подземелий
-- Кастомные подземелья для кампаний
-- ============================================================================

local DungeonSystem = {}

-- Подземелья (id, name, map, description, minLevel, maxLevel)
DungeonSystem.Dungeons = {
    [90001] = {name = "Забытый Храм", map = 0, desc = "Подземелье кампании 6. Уровень 60-63.", minLevel = 60, maxLevel = 63},
    [90002] = {name = "Печать Тьмы", map = 0, desc = "Подземелье кампании 7. Уровень 70-73.", minLevel = 70, maxLevel = 73},
    [90003] = {name = "Крепость Ночного Ворона", map = 0, desc = "Финальное подземелье кампании 11. Уровень 80+.", minLevel = 80, maxLevel = 80},
}

-- Боссы подземелий (dungeonId, bossName, entry, hp, x, y, z, map)
DungeonSystem.Bosses = {
    [90001] = { -- Забытый Храм
        {name = "Скелет жреца", entry = 90061, x = -9005.0, y = 585.0, z = 100.0},
        {name = "Проклятый страж", entry = 90062, x = -9010.0, y = 590.0, z = 100.0},
    },
    [90002] = { -- Печать Тьмы
        {name = "Демон тени", entry = 90071, x = -9025.0, y = 595.0, z = 100.0},
        {name = "Страж Печати", entry = 90072, x = -9030.0, y = 600.0, z = 100.0},
    },
    [90003] = { -- Крепость Ночного Ворона
        {name = "Посланник Тьмы", entry = 90111, x = -9105.0, y = 635.0, z = 100.0},
        {name = "Крыло Ночи", entry = 90112, x = -9100.0, y = 640.0, z = 100.0},
        {name = "Темный Ворон", entry = 90110, x = -9100.0, y = 630.0, z = 100.0},
    },
}

function DungeonSystem.GetDungeonInfo(dungeonId)
    return DungeonSystem.Dungeons[dungeonId]
end

function DungeonSystem.GetBosses(dungeonId)
    return DungeonSystem.Bosses[dungeonId] or {}
end

function DungeonSystem.Init()
    local count = 0
    for _ in pairs(DungeonSystem.Dungeons) do count = count + 1 end
    print("|cff4B0082[NightDarkRaven]|r Система подземелий: " .. count .. " подземелий зарегистрировано.")
end

-- Команда телепорта в подземелье (через gossip или GM)
function DungeonSystem.TeleportPlayerToDungeon(player, dungeonId)
    local dungeon = DungeonSystem.GetDungeonInfo(dungeonId)
    if not dungeon then return false end
    player:Teleport(dungeon.map, 0, 0, 0, 0) -- Заглушка, координаты входа нужно задать
    return true
end

return DungeonSystem