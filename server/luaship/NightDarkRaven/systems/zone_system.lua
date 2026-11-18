-- ============================================================================
-- Ночь темного Ворона — Система кастомных зон
-- Определяет зоны мира, точки телепорта, безопасные зоны
-- ============================================================================

local ZoneSystem = {}

-- Кастомные зоны (zone id, name, map, x, y, z, radius, description)
ZoneSystem.Zones = {
    [90001] = {name = "Воронова Гора", map = 0, x = -8920.0, y = 540.0, z = 100.0, radius = 200, desc = "Стартовая зона кампании 2."},
    [90002] = {name = "Лес Теней", map = 0, x = -8940.0, y = 550.0, z = 100.0, radius = 200, desc = "Зона 캠ании 3."},
    [90003] = {name = "Храм Тьмы", map = 0, x = -9000.0, y = 580.0, z = 100.0, radius = 150, desc = "Забытый Храм (кампания 6)."},
    [90004] = {name = "Логово Пустоты", map = 0, x = -9020.0, y = 590.0, z = 100.0, radius = 150, desc = "Печать Тьмы (кампания 7)."},
    [90005] = {name = "Крепость Ночи", map = 0, x = -9100.0, y = 630.0, z = 100.0, radius = 100, desc = "Финальная зона campaign 11."},
}

-- Точки телепорта для игроков (teleport name, map, x, y, z, orientation)
ZoneSystem.Teleports = {
    ["Воронова Гора"] = {map = 0, x = -8920.0, y = 540.0, z = 100.0, o = 0.0},
    ["Лес Теней"] = {map = 0, x = -8940.0, y = 550.0, z = 100.0, o = 0.0},
    ["Храм Тьмы"] = {map = 0, x = -9000.0, y = 580.0, z = 100.0, o = 0.0},
    ["Логово Пустоты"] = {map = 0, x = -9020.0, y = 590.0, z = 100.0, o = 0.0},
    ["Крепость Ночи"] = {map = 0, x = -9100.0, y = 630.0, z = 100.0, o = 0.0},
    ["Stormwind"] = {map = 0, x = -8900.0, y = 530.0, z = 100.0, o = 0.0},
}

function ZoneSystem.GetZoneInfo(zoneId)
    return ZoneSystem.Zones[zoneId]
end

function ZoneSystem.GetTeleport(name)
    return ZoneSystem.Teleports[name]
end

function ZoneSystem.IsInZone(player, zoneId)
    local zone = ZoneSystem.Zones[zoneId]
    if not zone then return false end
    local dist = player:GetDistance(zone.x, zone.y, zone.z)
    return dist <= zone.radius
end

function ZoneSystem.Init()
    local count = 0
    for _ in pairs(ZoneSystem.Zones) do count = count + 1 end
    print("|cff4B0082[NightDarkRaven]|r Система зон: " .. count .. " зон зарегистрировано.")
end

return ZoneSystem