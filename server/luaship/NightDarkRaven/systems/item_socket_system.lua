-- ============================================================================
-- Ночь темного Ворона — Система сокетов предметов (Lua / Eluna)
-- Постоянное хранение вставленных камней в БД character_item_sockets
-- ============================================================================

local ItemSocketSystem = {}

-- Кэш сокетов игроков: [character_guid] = {item_guid = {slot = gem_entry}}
ItemSocketSystem.Cache = {}

-- Кэш шаблонов сокетов: [item_entry] = {slot = gem_color}
ItemSocketSystem.SocketTemplates = {}

-- Загрузить шаблоны сокетов из БД
function ItemSocketSystem.LoadSocketTemplates()
    local query = "SELECT item_entry, slot, gem_color FROM item_socket_template"

    local result
    if WorldDBQuery then
        result = WorldDBQuery(query)
    end

    if result then
        repeat
            local entry = result:GetUInt32(0)
            local slot = result:GetUInt32(1)
            local color = result:GetString(2)

            if not ItemSocketSystem.SocketTemplates[entry] then
                ItemSocketSystem.SocketTemplates[entry] = {}
            end
            ItemSocketSystem.SocketTemplates[entry][tostring(slot)] = color
        until not result:NextRow()
    end

    local count = 0
    for _ in pairs(ItemSocketSystem.SocketTemplates) do count = count + 1 end
    print("|cff4B0082[NightDarkRaven]|r Шаблоны сокетов загружены: " .. count .. " предметов")
end

-- Загрузить вставленные камни игрока из БД
function ItemSocketSystem.LoadPlayerSockets(characterGuid)
    local query = string.format(
        "SELECT item_guid, item_entry, slot, gem_entry FROM character_item_sockets WHERE character_guid = %d",
        characterGuid
    )

    local result
    if WorldDBQuery then
        result = WorldDBQuery(query)
    end

    local sockets = {}
    if result then
        repeat
            local itemGuid = result:GetUInt32(0)
            local itemEntry = result:GetUInt32(1)
            local slot = result:GetUInt32(2)
            local gemEntry = result:GetUInt32(3)

            if not sockets[itemGuid] then
                sockets[itemGuid] = {}
            end
            sockets[itemGuid][tostring(slot)] = gemEntry
        until not result:NextRow()
    end

    ItemSocketSystem.Cache[characterGuid] = sockets
    return sockets
end

-- Получить сокеты предмета игрока
function ItemSocketSystem.GetItemSockets(characterGuid, itemGuid)
    if not ItemSocketSystem.Cache[characterGuid] then
        ItemSocketSystem.LoadPlayerSockets(characterGuid)
    end

    local sockets = ItemSocketSystem.Cache[characterGuid]
    return sockets[itemGuid] or {}
end

-- Получить информацию о сокете предмета (цвет)
function ItemSocketSystem.GetSocketColor(itemEntry, slot)
    local templates = ItemSocketSystem.SocketTemplates[itemEntry]
    if not templates then return nil end
    return templates[tostring(slot)]
end

-- Вставить камень в сокет предмета
function ItemSocketSystem.SocketGem(characterGuid, itemGuid, itemEntry, slot, gemEntry)
    -- Проверяем, что сокет существует для этого предмета
    local color = ItemSocketSystem.GetSocketColor(itemEntry, slot)
    if not color then
        return false, "Этот предмет не имеет сокета в этой позиции"
    end

    -- Проверяем, что сокет пуст
    local existing = ItemSocketSystem.GetItemSockets(characterGuid, itemGuid)
    if existing[tostring(slot)] then
        return false, "В этом сокете уже есть камень"
    end

    -- Проверяем, есть ли камень у игрока (через Lua API игрока)
    -- В AzerothCore Eluna есть GetItemCount
    local player = GetPlayerByGUID(characterGuid)
    if not player then return false, "Игрок не найден" end

    if player:GetItemCount(gemEntry) < 1 then
        return false, "У вас нет этого камня"
    end

    -- Убираем камень из инвентаря
    player:RemoveItem(gemEntry, 1)

    -- Сохраняем в БД
    local query = string.format(
        "INSERT INTO character_item_sockets (character_guid, item_guid, item_entry, slot, gem_entry) VALUES (%d, %d, %d, %d, %d)",
        characterGuid, itemGuid, itemEntry, slot, gemEntry
    )

    if WorldDBQuery then
        WorldDBQuery(query)
    end

    -- Обновляем кэш
    if not ItemSocketSystem.Cache[characterGuid] then
        ItemSocketSystem.Cache[characterGuid] = {}
    end
    if not ItemSocketSystem.Cache[characterGuid][itemGuid] then
        ItemSocketSystem.Cache[characterGuid][itemGuid] = {}
    end
    ItemSocketSystem.Cache[characterGuid][itemGuid][tostring(slot)] = gemEntry

    -- Применяем эффект камня
    local stoneInfo = LegendaryStones_GetStoneInfo(gemEntry)
    if stoneInfo then
        ItemSocketSystem.ApplyGemEffect(player, gemEntry, true)
    end

    return true, "Камень вставлен успешно"
end

-- Извлечь камень из сокета
function ItemSocketSystem.UnsocketGem(characterGuid, itemGuid, slot)
    local sockets = ItemSocketSystem.GetItemSockets(characterGuid, itemGuid)
    local gemEntry = sockets[tostring(slot)]

    if not gemEntry then
        return false, "В этом сокете нет камня"
    end

    -- Удаляем из БД
    local query = string.format(
        "DELETE FROM character_item_sockets WHERE character_guid = %d AND item_guid = %d AND slot = %d",
        characterGuid, itemGuid, slot
    )

    if WorldDBQuery then
        WorldDBQuery(query)
    end

    -- Обновляем кэш
    ItemSocketSystem.Cache[characterGuid][itemGuid][tostring(slot)] = nil

    -- Возвращаем камень игроку
    local player = GetPlayerByGUID(characterGuid)
    if player then
        player:AddItem(gemEntry, 1)
        ItemSocketSystem.ApplyGemEffect(player, gemEntry, false)
    end

    return true, "Камень извлечен"
end

-- Применить эффект камня к характеристикам игрока
function ItemSocketSystem.ApplyGemEffect(player, gemEntry, apply)
    local info = LegendaryStones_GetStoneInfo(gemEntry)
    if not info then return end

    local stones = require("NightDarkRaven.systems.legendary_stones_system")
    stones.ApplyStoneEffect(player, gemEntry, apply)

    if apply then
        player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Камень '%s' вставлен: %s", info.name, info.desc))
    else
        player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Камень '%s' извлечен.", info.name))
    end
end

-- Получить все вставленные камни предмета с информацией
function ItemSocketSystem.GetItemSocketInfo(characterGuid, itemGuid)
    local sockets = ItemSocketSystem.GetItemSockets(characterGuid, itemGuid)
    local result = {}

    for slotStr, gemEntry in pairs(sockets) do
        local slot = tonumber(slotStr)
        local color = ItemSocketSystem.GetSocketColor(0, slot) -- itemEntry не передаём, упрощённо
        local info = LegendaryStones_GetStoneInfo(gemEntry)

        result[tonumber(slot)] = {
            gem_entry = gemEntry,
            gem_name = info and info.name or "Неизвестно",
            gem_desc = info and info.desc or "",
            slot_color = color or "unknown"
        }
    end

    return result
end

-- Вспомогательная функция для получения инфо о камне (из legendary_stones_system)
function LegendaryStones_GetStoneInfo(entry)
    local stones = {
        [92001] = {name = "Камень Теневой Мощи", type = "red", stat = "attack_power", value = 500, desc = "+500 к силе атаки"},
        [92002] = {name = "Камень Лунного Сияния", type = "blue", stat = "intellect", value = 100, desc = "+100 к интеллекту"},
        [92003] = {name = "Камень Ночной Стойкости", type = "yellow", stat = "stamina", value = 150, desc = "+150 к выносливости"},
        [92004] = {name = "Камень Воронового Крика", type = "purple", stat = "crit", value = 50, desc = "+0.5% к шансу крита"},
        [92005] = {name = "Камень Вечной Тьмы", type = "green", stat = "expertise", value = 25, desc = "+25 к мастерству"},
        [92006] = {name = "Камень Звездного Падения", type = "orange", stat = "combo", value = 200, desc = "+200 к силе и интеллекту"},
        [92007] = {name = "Камень Пустотного Эха", type = "cyan", stat = "shadow_dmg", value = 300, desc = "+300 урона тенью"},
        [92008] = {name = "Камень Ночного Стража", type = "white", stat = "armor", value = 1000, desc = "+1000 к броне, +5% к защите"},
    }
    return stones[entry]
end

function ItemSocketSystem.Init()
    ItemSocketSystem.LoadSocketTemplates()
    print("|cff4B0082[NightDarkRaven]|r Система сокетов предметов загружена.")
end

return ItemSocketSystem