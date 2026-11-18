-- ============================================================================
-- Ночь темного Ворона — квест "Перо Тени"
-- Lua / Eluna для AzerothCore (WoW 3.3.5a)
--
-- Предполагается, что в БД уже создан квест с ID 90001 (quest_template),
-- NPC "Темный Ворон" (90001) является дачителем квеста, а моб "Теневая Сова"
-- (entry 90002) Drop'ит предмет "Перо Тени" (item 90001).
-- ============================================================================

local QUEST_ID      = 90001
local NPC_QUESTGIVER = 90001
local ITEM_FEATHER   = 90001  -- Перо Тени
local MOB_SHADOW_OWL = 90002  -- Теневая Сова

local REQUIRED_COUNT = 5

-- При разговоре с дачителем квеста
local function OnQuestGiverHello(event, player, creature)
    if player:HasQuest(QUEST_ID) then
        -- Игрок уже взял квест — проверяем выполнение
        local count = player:GetItemCount(ITEM_FEATHER)
        if count >= REQUIRED_COUNT then
            player:GossipMenuAddItem(0, "Я принес перья Теневой Совы", 0, 101)
        else
            player:GossipMenuAddItem(0, "Я ещё собираю перья (" .. count .. "/" .. REQUIRED_COUNT .. ")", 0, 102)
        end
    else
        -- Квест не взят — предлагаем взять
        player:GossipMenuAddItem(0, "Взять квест: Перо Тени", 0, 201)
    end
    player:GossipMenuAddItem(0, "Ничего", 0, 255)
    player:GossipSendMenu(90001, creature)
end

local function OnQuestGiverSelect(event, player, creature, sender, intid, code)
    if intid == 101 then
        -- Сдаём квест
        if player:GetItemCount(ITEM_FEATHER) >= REQUIRED_COUNT then
            player:RemoveItem(ITEM_FEATHER, REQUIRED_COUNT)
            player:CompleteQuest(QUEST_ID)
            player:RewardPlayer(QUEST_ID) --経騧, репутация, деньги (зависит от API сборки)
            creature:SendUnitSay("Отлично. Перья Тени Accepted.", 0)
        else
            creature:SendUnitSay("Тебе не хватает перьев, stranger.", 0)
        end
        player:GossipComplete()
    elseif intid == 102 then
        creature:SendUnitSay("Продолжай охотиться на Теневых Сов.", 0)
        player:GossipComplete()
    elseif intid == 201 then
        -- Выдаём квест
        player:AddQuest(QUEST_ID)
        creature:SendUnitSay("Принеси мне " .. REQUIRED_COUNT .. " перьев Теневой Совы.", 0)
        player:GossipComplete()
    elseif intid == 255 then
        player:GossipComplete()
    end
end

-- Лут с моба: если у игрока есть квест, шанс выпадения пера
local function OnCreatureKill(event, creature, victim)
    if creature:GetEntry() ~= MOB_SHADOW_OWL then return end

    -- Находим игрока, который убил моба (упрощённо: ближайший игрок)
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end

    local player = players[1]
    if player and player:HasQuest(QUEST_ID) then
        local count = player:GetItemCount(ITEM_FEATHER)
        if count < REQUIRED_COUNT then
            -- 40% шанс выпадения
            if math.random(100) <= 40 then
                player:AddItem(ITEM_FEATHER, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Вы нашли Перо Тени! (" .. (count+1) .. "/" .. REQUIRED_COUNT .. ")")
            end
        end
    end
end

-- Регистрация
RegisterCreatureGossipEvent(NPC_QUESTGIVER, 1, OnQuestGiverHello)
RegisterCreatureGossipEvent(NPC_QUESTGIVER, 2, OnQuestGiverSelect)
RegisterCreatureEvent(MOB_SHADOW_OWL, 4, OnCreatureKill) -- DIED

print("[NightDarkRaven] Lua: quest_shadow_feather (quest " .. QUEST_ID .. ") loaded.")