-- ============================================================================
-- Ночь темного Ворона — NPC Торговец кампаний (Lua / Eluna)
-- Gossip-меню для покупки наград кампаний через клиентский аддон
-- ============================================================================

local CampaignShop = {}

local NPC_SHOP_ID = 90099 -- NPC "Торговец кампаний"

-- Список доступных предметов магазина (синхронизировано с БД)
CampaignShop.ShopItems = {
    [1]  = { itemEntry = 90001, itemName = "Перо Тени", costGold = 500000, campaignReq = 1, questReq = 90101 },
    [2]  = { itemEntry = 90003, itemName = "Клык Теневой Совы", costGold = 750000, campaignReq = 1, questReq = 90102 },
    [3]  = { itemEntry = 90004, itemName = "Светящийся камешек", costGold = 1000000, campaignReq = 1, questReq = 90103 },
    [4]  = { itemEntry = 90021, itemName = "Шкура Горного Волка", costGold = 2000000, campaignReq = 2, questReq = 90201 },
    [5]  = { itemEntry = 90022, itemName = "Камень Гряд", costGold = 2200000, campaignReq = 2, questReq = 90202 },
    [6]  = { itemEntry = 90023, itemName = "Перо Каменного Гаргулья", costGold = 2500000, campaignReq = 2, questReq = 90203 },
    [7]  = { itemEntry = 90031, itemName = "Проклятое Перо", costGold = 3500000, campaignReq = 3, questReq = 90301 },
    [8]  = { itemEntry = 90032, itemName = "Амулет Друида", costGold = 4000000, campaignReq = 3, questReq = 90302 },
    [9]  = { itemEntry = 90033, itemName = "Слеза Леса", costGold = 4500000, campaignReq = 3, questReq = 90303 },
    [10] = { itemEntry = 90041, itemName = "Кровавый Клык", costGold = 5000000, campaignReq = 4, questReq = 90401 },
    [11] = { itemEntry = 90042, itemName = "Песнь Луны", costGold = 5500000, campaignReq = 4, questReq = 90402 },
    [12] = { itemEntry = 90043, itemName = "Кристалл Кровавой Луны", costGold = 6000000, campaignReq = 4, questReq = 90403 },
    [13] = { itemEntry = 90051, itemName = "Печать Хранителя", costGold = 7000000, campaignReq = 5, questReq = 90501 },
    [14] = { itemEntry = 90052, itemName = "Масло Теней", costGold = 7500000, campaignReq = 5, questReq = 90502 },
    [15] = { itemEntry = 90053, itemName = "Медальон Ночи", costGold = 8000000, campaignReq = 5, questReq = 90503 },
    [16] = { itemEntry = 90061, itemName = "Разрушенные Скрижали", costGold = 8500000, campaignReq = 6, questReq = 90601 },
    [17] = { itemEntry = 90062, itemName = "Пыль Костей", costGold = 9000000, campaignReq = 6, questReq = 90602 },
    [18] = { itemEntry = 90063, itemName = "Ключ Храма", costGold = 9500000, campaignReq = 6, questReq = 90603 },
    [19] = { itemEntry = 90071, itemName = "Осколок Пустоты", costGold = 10500000, campaignReq = 7, questReq = 90701 },
    [20] = { itemEntry = 90072, itemName = "Кровь Демона", costGold = 11000000, campaignReq = 7, questReq = 90702 },
    [21] = { itemEntry = 90073, itemName = "Руна Печати", costGold = 11500000, campaignReq = 7, questReq = 90703 },
    [22] = { itemEntry = 90081, itemName = "Клинок Ворона", costGold = 15000000, campaignReq = 8, questReq = 90804 },
    [23] = { itemEntry = 90083, itemName = "Чешуя Теневого Ворона", costGold = 12000000, campaignReq = 8, questReq = 90801 },
    [24] = { itemEntry = 90082, itemName = "Искра Огня", costGold = 12500000, campaignReq = 8, questReq = 90802 },
    [25] = { itemEntry = 90091, itemName = "Знак Дозора", costGold = 15500000, campaignReq = 9, questReq = 90901 },
    [26] = { itemEntry = 90092, itemName = "Свисток Разведчика", costGold = 16000000, campaignReq = 9, questReq = 90902 },
    [27] = { itemEntry = 90093, itemName = "Когти Ночного Хищника", costGold = 16500000, campaignReq = 9, questReq = 90903 },
    [28] = { itemEntry = 90101, itemName = "Слёза Луны", costGold = 17000000, campaignReq = 10, questReq = 91001 },
    [29] = { itemEntry = 90102, itemName = "Клык Луноstalker", costGold = 17500000, campaignReq = 10, questReq = 91002 },
    [30] = { itemEntry = 90103, itemName = "Перо Аспекта Ворона", costGold = 18000000, campaignReq = 10, questReq = 91003 },
    [31] = { itemEntry = 90111, itemName = "Сердце Темного Ворона", costGold = 20000000, campaignReq = 11, questReq = 91103 },
    [32] = { itemEntry = 90112, itemName = "Крыло Ночи", costGold = 19500000, campaignReq = 11, questReq = 91102 },
    [33] = { itemEntry = 90113, itemName = "Плащ Ночного Ворона", costGold = 21000000, campaignReq = 11, questReq = 91104 },
    [34] = { itemEntry = 92009, itemName = "Клинок Теневого Повелителя", costGold = 22000000, campaignReq = 12, questReq = 92001 },
    [35] = { itemEntry = 92010, itemName = "Шапка Теневого Ассасина", costGold = 24000000, campaignReq = 12, questReq = 92002 },
    [36] = { itemEntry = 92011, itemName = "Перчатки Теневого Убийцы", costGold = 26000000, campaignReq = 12, questReq = 92003 },
    [37] = { itemEntry = 92012, itemName = "Осколок Пустотного Короля", costGold = 24000000, campaignReq = 13, questReq = 92005 },
    [38] = { itemEntry = 92013, itemName = "Плащ Пустотного Повелителя", costGold = 26000000, campaignReq = 13, questReq = 92006 },
    [39] = { itemEntry = 92014, itemName = "Кольцо Пустотной Силы", costGold = 28000000, campaignReq = 13, questReq = 92007 },
    [40] = { itemEntry = 92015, itemName = "Перо Звёздного Ворона", costGold = 25000000, campaignReq = 14, questReq = 92009 },
    [41] = { itemEntry = 92016, itemName = "Крылья Звёздного Орла", costGold = 27000000, campaignReq = 14, questReq = 92010 },
    [42] = { itemEntry = 92017, itemName = "Амулет Астрального Хранителя", costGold = 29000000, campaignReq = 14, questReq = 92011 },
    [43] = { itemEntry = 92018, itemName = "Сердце Векрного Ворона", costGold = 30000000, campaignReq = 15, questReq = 92013 },
    [44] = { itemEntry = 92019, itemName = "Корона Векрного Ворона", costGold = 32000000, campaignReq = 15, questReq = 92014 },
    [45] = { itemEntry = 92020, itemName = "Клинок Векрного Ворона", costGold = 50000000, campaignReq = 15, questReq = 92016 },
}

-- Проверка завершения квеста игроком
function CampaignShop:IsQuestCompleted(player, questId)
    return player:HasFinishedQuest(questId)
end

-- Проверка завершения всех квестов кампании
function CampaignShop:IsCampaignCompleted(player, campaignId)
    local campaigns = {
        [1]  = {90101, 90102, 90103},
        [2]  = {90201, 90202, 90203, 92004},
        [3]  = {90301, 90302, 90303},
        [4]  = {90401, 90402, 90403, 90404},
        [5]  = {90501, 90502, 90503},
        [6]  = {90601, 90602, 90603, 90604},
        [7]  = {90701, 90702, 90703},
        [8]  = {90801, 90802, 90803, 90804},
        [9]  = {90901, 90902, 90903},
        [10] = {91001, 91002, 91003, 91004},
        [11] = {91101, 91102, 91103, 91104, 91105},
        [12] = {92001, 92002, 92003, 92004},
        [13] = {92005, 92006, 92007, 92008},
        [14] = {92009, 92010, 92011, 92012},
        [15] = {92013, 92014, 92015, 92016},
    }
    
    local quests = campaigns[campaignId]
    if not quests then return false end
    
    for _, qId in ipairs(quests) do
        if not player:HasFinishedQuest(qId) then
            return false
        end
    end
    return true
end

-- Gossip Hello для NPC торговца
function CampaignShop:OnGossipHello(event, player, creature)
    if creature:GetEntry() ~= NPC_SHOP_ID then return end
    
    player:GossipMenuAddItem(0, "|cff4B0082Магазин наград кампаний|r", 0, 999)
    
    -- Показываем доступные предметы
    local hasAvailable = false
    for id, item in pairs(CampaignShop.ShopItems) do
        local canBuy = true
        local reasons = {}
        
        -- Проверяем кампанию
        if item.campaignReq > 0 then
            if not CampaignShop:IsCampaignCompleted(player, item.campaignReq) then
                canBuy = false
                table.insert(reasons, "Кампания не пройдена")
            end
        end
        
        -- Проверяем квест
        if item.questReq > 0 then
            if not player:HasFinishedQuest(item.questReq) then
                canBuy = false
                table.insert(reasons, "Квест не завершён")
            end
        end
        
        -- Проверяем золото
        if item.costGold > 0 and player:GetCoinage() < item.costGold then
            canBuy = false
            table.insert(reasons, "Недостаточно золота")
        end
        
        if canBuy then
            player:GossipMenuAddItem(0, "|cff00ff00" .. item.itemName .. " |cffffffff(" .. item.costGold .. " зол.)|r", 0, item.itemId)
            hasAvailable = true
        else
            player:GossipMenuAddItem(0, "|cff7f7f7f" .. item.itemName .. " |cff7f7f7f(" .. item.costGold .. " зол.)|r", 0, item.itemId + 1000)
        end
    end
    
    if not hasAvailable then
        player:GossipMenuAddItem(0, "|cff7f7f7fНет доступных товаров|r", 0, 998)
    end
    
    player:GossipMenuAddItem(0, "|cff00ffffОбновить список|r", 0, 997)
    player:GossipMenuAddItem(0, "|cffffff00Закрыть|r", 0, 255)
    player:GossipSendMenu(90001, creature)
end

-- Gossip Select для NPC торговца
function CampaignShop:OnGossipSelect(event, player, creature, sender, intid, code)
    if creature:GetEntry() ~= NPC_SHOP_ID then return end
    
    if intid == 997 then
        -- Обновить список
        player:GossipMenuAddItem(0, "|cff4B0082Магазин наград кампаний|r", 0, 999)
        local hasAvailable = false
        for id, item in pairs(CampaignShop.ShopItems) do
            local canBuy = true
            if item.campaignReq > 0 and not CampaignShop:IsCampaignCompleted(player, item.campaignReq) then
                canBuy = false
            end
            if item.questReq > 0 and not player:HasFinishedQuest(item.questReq) then
                canBuy = false
            end
            if item.costGold > 0 and player:GetCoinage() < item.costGold then
                canBuy = false
            end
            
            if canBuy then
                player:GossipMenuAddItem(0, "|cff00ff00" .. item.itemName .. " |cffffffff(" .. item.costGold .. " зол.)|r", 0, item.itemId)
                hasAvailable = true
            else
                player:GossipMenuAddItem(0, "|cff7f7f7f" .. item.itemName .. " |cff7f7f7f(" .. item.costGold .. " зол.)|r", 0, item.itemId + 1000)
            end
        end
        if not hasAvailable then
            player:GossipMenuAddItem(0, "|cff7f7f7fНет доступных товаров|r", 0, 998)
        end
        player:GossipMenuAddItem(0, "|cff00ffffОбновить список|r", 0, 997)
        player:GossipMenuAddItem(0, "|cffffff00Закрыть|r", 0, 255)
        player:GossipSendMenu(90001, creature)
    elseif intid >= 1 and intid <= 1000 then
        -- Покупка предмета
        local item = CampaignShop.ShopItems[intid]
        if item then
            local canBuy = true
            local reasons = {}
            
            if item.campaignReq > 0 and not CampaignShop:IsCampaignCompleted(player, item.campaignReq) then
                canBuy = false
                table.insert(reasons, "Кампания не пройдена")
            end
            
            if item.questReq > 0 and not player:HasFinishedQuest(item.questReq) then
                canBuy = false
                table.insert(reasons, "Квест не завершён")
            end
            
            if item.costGold > 0 and player:GetCoinage() < item.costGold then
                canBuy = false
                table.insert(reasons, "Недостаточно золота: нужно " .. item.costGold .. ", есть " .. player:GetCoinage())
            end
            
            if canBuy then
                player:ModifyMoney(-item.costGold)
                player:AddItem(item.itemEntry, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Куплено: " .. item.itemName .. " (" .. item.costGold .. " зол.)")
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Предмет добавлен в инвентарь.")
            else
                player:SendBroadcastMessage("|cffFF0000[Ночь темного Ворона]|r " .. table.concat(reasons, ", "))
            end
        end
        player:GossipComplete()
    elseif intid >= 1001 and intid <= 2000 then
        -- Заблокированный предмет
        local item = CampaignShop.ShopItems[intid - 1000]
        if item then
            local reasons = {}
            if item.campaignReq > 0 and not CampaignShop:IsCampaignCompleted(player, item.campaignReq) then
                table.insert(reasons, "Кампания не пройдена")
            end
            if item.questReq > 0 and not player:HasFinishedQuest(item.questReq) then
                table.insert(reasons, "Квест не завершён")
            end
            if item.costGold > 0 and player:GetCoinage() < item.costGold then
                table.insert(reasons, "Недостаточно золота")
            end
            player:SendBroadcastMessage("|cffFF0000[Ночь темного Ворона]|r " .. item.itemName .. ": " .. table.concat(reasons, ", "))
        end
        player:GossipComplete()
    elseif intid == 255 then
        player:GossipComplete()
    end
end

-- Регистрация событий
RegisterCreatureGossipEvent(NPC_SHOP_ID, 1, CampaignShop.OnGossipHello)
RegisterCreatureGossipEvent(NPC_SHOP_ID, 2, CampaignShop.OnGossipSelect)

print("[NightDarkRaven] Магазин кампаний загружен (NPC " .. NPC_SHOP_ID .. ")")