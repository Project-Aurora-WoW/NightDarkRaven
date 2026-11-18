-- ============================================================================
-- Ночь темного Ворона — Gossip сокетования предметов (Lua / Eluna)
-- Вставка/извлечение камней через NPC Мастера Камней Теней (93001)
-- ============================================================================

local ItemSocketSystem = require("NightDarkRaven.systems.item_socket_system")
local LegendaryStones = require("NightDarkRaven.systems.legendary_stones_system")

local NPC_STONE_MASTER = 93001

-- Временный выбор предмета игрока: [character_guid] = {item_guid, item_entry}
ItemSocketGossip = ItemSocketGossip or {}

-- Gossip Hello для Мастера Камней
local function OnGossipHello(event, player, creature)
    if creature:GetEntry() ~= NPC_STONE_MASTER then return end

    player:GossipMenuAddItem(0, "|cff7B2CBF[Сокеты]|r Вставить камень в предмет", 0, 101)
    player:GossipMenuAddItem(0, "|cff7B2CBF[Сокеты]|r Извлечь камень из предмета", 0, 201)
    player:GossipMenuAddItem(0, "|cff7B2CBF[Сокеты]|r Просмотреть сокеты предмета", 0, 301)
    player:GossipMenuAddItem(0, "|cff7B2CBF[Камни]|r Информация о камнях", 0, 401)
    player:GossipMenuAddItem(0, "Ничего", 0, 255)
    player:GossipSendMenu(90001, creature)
end

local function OnGossipSelect(event, player, creature, sender, intid, code)
    if creature:GetEntry() ~= NPC_STONE_MASTER then return end

    local guid = player:GetGUIDLow()

    if intid == 101 then
        -- Вставить камень: сначала выбрать предмет
        ShowItemsForSocketing(player, creature)
    elseif intid == 201 then
        -- Извлечь камень: выбрать предмет с сокетами
        ShowItemsForUnsocketing(player, creature)
    elseif intid == 301 then
        -- Просмотреть сокеты: выбрать предмет
        ShowItemsForSocketInfo(player, creature)
    elseif intid == 401 then
        -- Информация о камнях
        ShowStoneInfo(player, creature)
    elseif intid >= 1000 and intid < 2000 then
        -- Выбран предмет для вставки (item_index = intid - 1000)
        SelectItemForSocket(player, creature, intid - 1000)
    elseif intid >= 2000 and intid < 3000 then
        -- Выбран предмет для извлечения
        SelectItemForUnsocket(player, creature, intid - 2000)
    elseif intid >= 3000 and intid < 4000 then
        -- Выбран предмет для просмотра сокетов
        SelectItemForSocketInfo(player, creature, intid - 3000)
    elseif intid >= 4000 and intid < 5000 then
        -- Выбран слот для вставки (slot = intid - 4000)
        local data = ItemSocketGossip[guid]
        if data then
            local slot = intid - 4000
            ShowStonesForSocket(player, creature, data.item_guid, data.item_entry, slot)
        end
    elseif intid >= 5000 and intid < 6000 then
        -- Выбран камень для вставки (gem_entry = intid - 5000)
        local data = ItemSocketGossip[guid]
        if data then
            local gemEntry = intid - 5000
            local success, msg = ItemSocketSystem.SocketGem(guid, data.item_guid, data.item_entry, data.slot, gemEntry)
            player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r " .. msg)
            ItemSocketGossip[guid] = nil
            player:GossipComplete()
        end
    elseif intid >= 6000 and intid < 7000 then
        -- Выбран слот для извлечения (slot = intid - 6000)
        local data = ItemSocketGossip[guid]
        if data then
            local slot = intid - 6000
            local success, msg = ItemSocketSystem.UnsocketGem(guid, data.item_guid, slot)
            player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r " .. msg)
            ItemSocketGossip[guid] = nil
            player:GossipComplete()
        end
    elseif intid == 255 then
        player:GossipComplete()
    end
end

-- Показать предметы игрока для сокетования
function ShowItemsForSocketing(player, creature)
    local guid = player:GetGUIDLow()
    ItemSocketGossip[guid] = nil

    -- В реальном AzerothCore нужно перебирать инвентарь игрока
    -- Здесь упрощённый пример: показываем предметы с сокетами
    local items = GetPlayerSocketableItems(player) -- функция ниже

    if #items == 0 then
        player:GossipMenuAddItem(0, "У вас нет предметов с сокетами", 0, 255)
    else
        for i, item in ipairs(items) do
            player:GossipMenuAddItem(0, item.name .. " (#" .. item.entry .. ")", 0, 1000 + i)
        end
    end
    player:GossipMenuAddItem(0, "Назад", 0, 254)
    player:GossipSendMenu(90001, creature)
end

-- Выбран предмет для вставки камня
function SelectItemForSocket(player, creature, itemIndex)
    local guid = player:GetGUIDLow()
    local items = GetPlayerSocketableItems(player)
    local item = items[itemIndex]

    if not item then
        player:GossipComplete()
        return
    end

    ItemSocketGossip[guid] = {
        item_guid = item.guid,
        item_entry = item.entry
    }

    -- Показать свободные сокеты
    local sockets = ItemSocketSystem.GetItemSockets(guid, item.guid)
    local templates = ItemSocketSystem.SocketTemplates[item.entry] or {}

    local hasFreeSlot = false
    for slotStr, color in pairs(templates) do
        local slot = tonumber(slotStr)
        if not sockets[tostring(slot)] then
            player:GossipMenuAddItem(0, "Слот " .. slot .. " (" .. color .. ")", 0, 4000 + slot)
            hasFreeSlot = true
        end
    end

    if not hasFreeSlot then
        player:GossipMenuAddItem(0, "Все сокеты заполнены", 0, 255)
    end
    player:GossipMenuAddItem(0, "Назад", 0, 254)
    player:GossipSendMenu(90001, creature)
end

-- Показать камни для вставки в выбранный слот
function ShowStonesForSocket(player, creature, itemGuid, itemEntry, slot)
    local guid = player:GetGUIDLow()
    ItemSocketGossip[guid].slot = slot

    local color = ItemSocketSystem.GetSocketColor(itemEntry, slot)

    local hasStone = false
    for entry, info in pairs(LegendaryStones.Stones) do
        if info.type == color and player:GetItemCount(entry) >= 1 then
            player:GossipMenuAddItem(0, info.name .. " (" .. info.desc .. ")", 0, 5000 + entry)
            hasStone = true
        end
    end

    if not hasStone then
        player:GossipMenuAddItem(0, "У вас нет камней типа " .. color, 0, 255)
    end
    player:GossipMenuAddItem(0, "Назад", 0, 254)
    player:GossipSendMenu(90001, creature)
end

-- Показать предметы для извлечения камня
function ShowItemsForUnsocketing(player, creature)
    local guid = player:GetGUIDLow()
    ItemSocketGossip[guid] = nil

    -- В реальности нужно перебирать все предметы игрока и находить те, у которых есть сокеты
    local items = GetPlayerSocketableItems(player)

    local itemsWithSockets = {}
    for i, item in ipairs(items) do
        local sockets = ItemSocketSystem.GetItemSockets(guid, item.guid)
        local hasGem = false
        for _, _ in pairs(sockets) do hasGem = true break end
        if hasGem then
            table.insert(itemsWithSockets, item)
        end
    end

    if #itemsWithSockets == 0 then
        player:GossipMenuAddItem(0, "У вас нет предметов с вставленными камнями", 0, 255)
    else
        for i, item in ipairs(itemsWithSockets) do
            player:GossipMenuAddItem(0, item.name .. " (#" .. item.entry .. ")", 0, 2000 + i)
        end
    end
    player:GossipMenuAddItem(0, "Назад", 0, 254)
    player:GossipSendMenu(90001, creature)
end

-- Выбран предмет для извлечения
function SelectItemForUnsocket(player, creature, itemIndex)
    local guid = player:GetGUIDLow()
    local items = GetPlayerSocketableItems(player)

    local itemsWithSockets = {}
    for i, item in ipairs(items) do
        local sockets = ItemSocketSystem.GetItemSockets(guid, item.guid)
        local hasGem = false
        for _, _ in pairs(sockets) do hasGem = true break end
        if hasGem then
            table.insert(itemsWithSockets, item)
        end
    end

    local item = itemsWithSockets[itemIndex]
    if not item then
        player:GossipComplete()
        return
    end

    ItemSocketGossip[guid] = {
        item_guid = item.guid,
        item_entry = item.entry
    }

    local sockets = ItemSocketSystem.GetItemSockets(guid, item.guid)
    for slotStr, gemEntry in pairs(sockets) do
        local slot = tonumber(slotStr)
        local info = LegendaryStones_GetStoneInfo(gemEntry)
        player:GossipMenuAddItem(0, "Извлечь " .. (info and info.name or "Камень") .. " из слота " .. slot, 0, 6000 + slot)
    end

    player:GossipMenuAddItem(0, "Назад", 0, 254)
    player:GossipSendMenu(90001, creature)
end

-- Показать сокеты предмета
function ShowItemsForSocketInfo(player, creature)
    local guid = player:GetGUIDLow()
    ItemSocketGossip[guid] = nil

    local items = GetPlayerSocketableItems(player)

    if #items == 0 then
        player:GossipMenuAddItem(0, "У вас нет предметов с сокетами", 0, 255)
    else
        for i, item in ipairs(items) do
            player:GossipMenuAddItem(0, item.name .. " (#" .. item.entry .. ")", 0, 3000 + i)
        end
    end
    player:GossipMenuAddItem(0, "Назад", 0, 254)
    player:GossipSendMenu(90001, creature)
end

-- Выбран предмет для просмотра сокетов
function SelectItemForSocketInfo(player, creature, itemIndex)
    local items = GetPlayerSocketableItems(player)
    local item = items[itemIndex]

    if not item then
        player:GossipComplete()
        return
    end

    local guid = player:GetGUIDLow()
    local sockets = ItemSocketSystem.GetItemSockets(guid, item.guid)
    local templates = ItemSocketSystem.SocketTemplates[item.entry] or {}

    local info = string.format("|cff4B0082[Ночь темного Ворона]|r Сокеты предмета %s:\n", item.name)
    for slotStr, color in pairs(templates) do
        local slot = tonumber(slotStr)
        local gemEntry = sockets[tostring(slot)]
        local gemInfo = LegendaryStones_GetStoneInfo(gemEntry)
        if gemEntry and gemInfo then
            info = info .. string.format("Слот %d (%s): %s - %s\n", slot, color, gemInfo.name, gemInfo.desc)
        else
            info = info .. string.format("Слот %d (%s): Пусто\n", slot, color)
        end
    end

    player:SendBroadcastMessage(info)
    player:GossipComplete()
end

-- Показать информацию о всех камнях
function ShowStoneInfo(player, creature)
    local msg = "|cff4B0082[Ночь темного Ворона]|r Доступные камни:\n"
    for entry, info in pairs(LegendaryStones.Stones) do
        msg = msg .. string.format("• %s — %s\n", info.name, info.desc)
    end
    player:SendBroadcastMessage(msg)
    player:GossipComplete()
end

-- Вспомогательная функция: получить предметы игрока с сокетами
-- В реальном AzerothCore нужно использовать API инвентаря (GetInventoryItem, etc.)
function GetPlayerSocketableItems(player)
    local items = {}
    -- Упрощённый пример: в реальности нужно перебирать слоты экипировки
    -- и сумки игрока через API
    -- Здесь возвращаем пустую таблицу как заглушку
    -- Для работы нужно добавить перебор инвентаря через player:GetInventoryItem(slot)
    return items
end

RegisterCreatureGossipEvent(NPC_STONE_MASTER, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_STONE_MASTER, 2, OnGossipSelect)

print("[NightDarkRaven] Gossip сокетования загружен (NPC 93001).")