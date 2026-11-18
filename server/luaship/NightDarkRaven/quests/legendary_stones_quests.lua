-- ============================================================================
-- Ночь темного Ворона — Квесты Камней Легенды (Lua / Eluna)
-- Дачитель: Мастер Камней Теней (entry 93001), Хранитель Легенд (93002)
-- ============================================================================

local LegendaryStones = require("NightDarkRaven.systems.legendary_stones_system")

local NPC_STONE_MASTER = 93001
local NPC_LORE_KEEPER = 93002

-- ============================================================================
-- Мастер Камней Теней (93001) — квесты и сокетрование
-- ============================================================================

local function OnGossipHello_StoneMaster(event, player, creature)
    if creature:GetEntry() ~= NPC_STONE_MASTER then return end

    -- Квесты камней
    if not player:HasQuest(92001) and not player:HasFinishedQuest(92001) then
        player:GossipMenuAddItem(0, "Взять квест: Поиск Первого Камня", 0, 101)
    end
    if player:HasQuest(92001) then
        player:GossipMenuAddItem(0, "Я нашел Камень Теневой Мощи", 0, 102)
    end
    if not player:HasQuest(92002) and not player:HasFinishedQuest(92002) and player:HasFinishedQuest(92001) then
        player:GossipMenuAddItem(0, "Взять квест: Очистка Камня", 0, 201)
    end
    if player:HasQuest(92002) then
        player:GossipMenuAddItem(0, "Я очистил камень от тени", 0, 202)
    end
    if not player:HasQuest(92003) and not player:HasFinishedQuest(92003) and player:HasFinishedQuest(92002) then
        player:GossipMenuAddItem(0, "Взять квест: Соединение Камней", 0, 301)
    end
    if player:HasQuest(92003) then
        player:GossipMenuAddItem(0, "Я соединил камни", 0, 302)
    end

    -- Сокетрование камней
    player:GossipMenuAddItem(0, "|cff7B2CBF[Камни]|r Вставить камень в сокет", 0, 501)
    player:GossipMenuAddItem(0, "|cff7B2CBF[Камни]|r Извлечь камень из сокета", 0, 502)
    player:GossipMenuAddItem(0, "|cff7B2CBF[Камни]|r Информация о камне", 0, 503)

    player:GossipMenuAddItem(0, "Ничего", 0, 255)
    player:GossipSendMenu(90001, creature)
end

local function OnGossipSelect_StoneMaster(event, player, creature, sender, intid, code)
    if creature:GetEntry() ~= NPC_STONE_MASTER then return end

    -- Квест 92001: Поиск Первого Камня
    if intid == 101 then
        player:AddQuest(92001)
        creature:SendUnitSay("Ищите Камень Теневой Мощи в руинах Ночного Храма.", 0)
        player:GossipComplete()
    elseif intid == 102 then
        if player:GetItemCount(92001) >= 1 then
            player:RemoveItem(92001, 1)
            player:CompleteQuest(92001)
            player:RewardPlayer(92001)
            creature:SendUnitSay("Отличный камень. Путь к легенде открыт.", 0)
        else
            creature:SendUnitSay("У вас нет Камня Теневой Мощи.", 0)
        end
        player:GossipComplete()
    -- Квест 92002: Очистка Камня
    elseif intid == 201 then
        player:AddQuest(92002)
        creature:SendUnitSay("Убейте 10 Оскверненных Теней около руин.", 0)
        player:GossipComplete()
    elseif intid == 202 then
        player:CompleteQuest(92002)
        player:RewardPlayer(92002)
        creature:SendUnitSay("Камень очищен от тени.", 0)
        player:GossipComplete()
    -- Квест 92003: Соединение Камней
    elseif intid == 301 then
        player:AddQuest(92003)
        creature:SendUnitSay("Соберите Камень Теневой Мощи, Камень Лунного Сияния и Камень Ночной Стойкости.", 0)
        player:GossipComplete()
    elseif intid == 302 then
        if player:GetItemCount(92001) >= 1 and player:GetItemCount(92002) >= 1 and player:GetItemCount(92003) >= 1 then
            player:RemoveItem(92001, 1)
            player:RemoveItem(92002, 1)
            player:RemoveItem(92003, 1)
            player:AddItem(92006, 1) -- Камень Звездного Падения
            player:CompleteQuest(92003)
            player:RewardPlayer(92003)
            creature:SendUnitSay("Камни соединены в один артефакт.", 0)
        else
            creature:SendUnitSay("У вас не все необходимые камни.", 0)
        end
        player:GossipComplete()
    -- Сокетрование
    elseif intid == 501 then
        -- Показать список камней игрока для вставки
        local stones = LegendaryStones.GetPlayerStones(player)
        local hasStones = false
        for entry, _ in pairs(LegendaryStones.Stones) do
            if player:GetItemCount(entry) >= 1 then
                hasStones = true
                local info = LegendaryStones.GetStoneInfo(entry)
                player:GossipMenuAddItem(0, string.format("|cff%s%s|r", info.type == "red" and "FF0000" or info.type == "blue" and "0000FF" or "FFFFFF", info.name), 0, 6000 + entry)
            end
        end
        if not hasStones then
            player:GossipMenuAddItem(0, "У вас нет камней для вставки.", 0, 255)
        end
        player:GossipMenuAddItem(0, "Назад", 0, 254)
        player:GossipSendMenu(90001, creature)
    elseif intid == 502 then
        -- Извлечь камень
        local stones = LegendaryStones.GetPlayerStones(player)
        local hasSocketed = false
        for slot, entry in pairs(stones) do
            local info = LegendaryStones.GetStoneInfo(entry)
            player:GossipMenuAddItem(0, string.format("Извлечь %s из слота %s", info.name, slot), 0, 7000 + tonumber(slot))
            hasSocketed = true
        end
        if not hasSocketed then
            player:GossipMenuAddItem(0, "У вас нет вставленных камней.", 0, 255)
        end
        player:GossipMenuAddItem(0, "Назад", 0, 254)
        player:GossipSendMenu(90001, creature)
    elseif intid == 503 then
        -- Информация о камнях в инвентаре
        for entry, _ in pairs(LegendaryStones.Stones) do
            if player:GetItemCount(entry) >= 1 then
                LegendaryStones.ShowStoneInfo(player, entry)
            end
        end
        player:GossipComplete()
    elseif intid == 254 then
        -- Назад в главное меню
        OnGossipHello_StoneMaster(event, player, creature)
    elseif intid >= 6001 and intid <= 6100 then
        -- Вставка камня (entry = intid - 6000)
        local stoneEntry = intid - 6000
        -- Выбираем слот (упрощенно: первый свободный)
        local stones = LegendaryStones.GetPlayerStones(player)
        local slot = 1
        while stones[tostring(slot)] do
            slot = slot + 1
        end
        LegendaryStones.SocketStone(player, nil, stoneEntry, slot)
        player:GossipComplete()
    elseif intid >= 7001 and intid <= 7100 then
        -- Извлечение камня (slot = intid - 7000)
        local slot = tostring(intid - 7000)
        LegendaryStones.UnsocketStone(player, slot)
        player:GossipComplete()
    elseif intid == 255 then
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NPC_STONE_MASTER, 1, OnGossipHello_StoneMaster)
RegisterCreatureGossipEvent(NPC_STONE_MASTER, 2, OnGossipSelect_StoneMaster)

-- ============================================================================
-- Хранитель Легенд (93002) — лор и инфо о камнях
-- ============================================================================

local function OnGossipHello_LoreKeeper(event, player, creature)
    if creature:GetEntry() ~= NPC_LORE_KEEPER then return end

    player:GossipMenuAddItem(0, "История Камней Легенды", 0, 1)
    player:GossipMenuAddItem(0, "Список известных камней", 0, 2)
    player:GossipMenuAddItem(0, "Ничего", 0, 255)
    player:GossipSendMenu(90001, creature)
end

local function OnGossipSelect_LoreKeeper(event, player, creature, sender, intid, code)
    if creature:GetEntry() ~= NPC_LORE_KEEPER then return end

    if intid == 1 then
        creature:SendUnitSay("Камни Легенды Ночных Стражей были созданы в Эпоху Теней. Они хранят силу первых стражей Ночи.", 0)
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Легенда: В древние времена Ночные Стражи сражались с Пустотой, используя силу камней, выкованных из звездного света и теневой энергии.")
        player:GossipComplete()
    elseif intid == 2 then
        local msg = "|cff4B0082[Ночь темного Ворона]|r Известные камни:\n"
        for entry, info in pairs(LegendaryStones.Stones) do
            msg = msg .. string.format("• %s — %s\n", info.name, info.desc)
        end
        player:SendBroadcastMessage(msg)
        player:GossipComplete()
    elseif intid == 255 then
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NPC_LORE_KEEPER, 1, OnGossipHello_LoreKeeper)
RegisterCreatureGossipEvent(NPC_LORE_KEEPER, 2, OnGossipSelect_LoreKeeper)

print("[NightDarkRaven] Камни Легенды Ночных Стражей загружены (квесты 92001-92003, NPC 93001-93002).")