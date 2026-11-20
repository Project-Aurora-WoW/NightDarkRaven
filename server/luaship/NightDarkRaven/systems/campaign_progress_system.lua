-- ============================================================================
-- Ночь темного Ворона — Система прогресса кампаний (Lua / Eluna)
-- Отслеживает выполнение квестов кампаний и взаимодействует с клиентским аддоном
-- ============================================================================

local CampaignProgress = {}

-- Кампании и их квесты
CampaignProgress.Campaigns = {
    [1]  = { name = "Пробуждение Ворона", quests = {90101, 90102, 90103} },
    [2]  = { name = "Тени Вороновой Горы", quests = {90201, 90202, 90203, 92004} },
    [3]  = { name = "Проклятие Перьев", quests = {90301, 90302, 90303} },
    [4]  = { name = "Кровавая Луна", quests = {90401, 90402, 90403, 90404} },
    [5]  = { name = "Хранители Ночи", quests = {90501, 90502, 90503} },
    [6]  = { name = "Забытый Храм", quests = {90601, 90602, 90603, 90604} },
    [7]  = { name = "Печать Тьмы", quests = {90701, 90702, 90703} },
    [8]  = { name = "Вороновой Клинок", quests = {90801, 90802, 90803, 90804} },
    [9]  = { name = "Ночной Дозор", quests = {90901, 90902, 90903} },
    [10] = { name = "Ворон и Луна", quests = {91001, 91002, 91003, 91004} },
    [11] = { name = "Конец Ночи", quests = {91101, 91102, 91103, 91104, 91105} },
    [12] = { name = "Повелители Теней", quests = {92001, 92002, 92003, 92004} },
    [13] = { name = "Королевство Пустоты", quests = {92005, 92006, 92007, 92008} },
    [14] = { name = "Звёздный Ворон", quests = {92009, 92010, 92011, 92012} },
    [15] = { name = "Векрной Ворон", quests = {92013, 92014, 92015, 92016} },
}

-- Инициализация прогресса игрока при входе
function CampaignProgress:OnPlayerLogin(event, player)
    local guid = player:GetGUIDLow()
    
    -- Проверяем все квесты всех кампаний
    for campId, campData in pairs(self.Campaigns) do
        for _, questId in ipairs(campData.quests) do
            local hasQuest = player:HasQuest(questId)
            local finishedQuest = player:HasFinishedQuest(questId)
            
            local status = 0 -- не начато
            if finishedQuest then
                status = 2 -- завершено
            elseif hasQuest then
                status = 1 -- в прогрессе
            end
            
            -- Записываем в БД
            local query = string.format(
                "INSERT INTO character_campaign_progress (character_guid, campaign_id, quest_id, status) VALUES (%d, %d, %d, %d) " ..
                "ON DUPLICATE KEY UPDATE status = %d",
                guid, campId, questId, status, status
            )
            CharDBQuery(query)
        end
    end
end

-- Обновление прогресса при завершении квеста
function CampaignProgress:OnQuestComplete(event, player, questId)
    local guid = player:GetGUIDLow()
    
    -- Находим кампанию для этого квеста
    for campId, campData in pairs(self.Campaigns) do
        for _, qId in ipairs(campData.quests) do
            if qId == questId then
                local query = string.format(
                    "UPDATE character_campaign_progress SET status = 2, completed_at = NOW() " ..
                    "WHERE character_guid = %d AND quest_id = %d",
                    guid, questId
                )
                CharDBQuery(query)
                break
            end
        end
    end
end

-- Получить прогресс игрока (для отправки клиенту)
function CampaignProgress:GetPlayerProgress(player)
    local guid = player:GetGUIDLow()
    local progress = {}
    
    for campId, campData in pairs(self.Campaigns) do
        local campaignProgress = {
            campaignId = campId,
            campaignName = campData.name,
            totalQuests = #campData.quests,
            completedQuests = 0,
            quests = {}
        }
        
        for _, questId in ipairs(campData.quests) do
            local query = string.format(
                "SELECT status FROM character_campaign_progress WHERE character_guid = %d AND quest_id = %d",
                guid, questId
            )
            local result = CharDBQuery(query)
            
            local status = 0
            if result then
                status = result:GetUInt32(0)
            end
            
            table.insert(campaignProgress.quests, {
                questId = questId,
                status = status
            })
            
            if status == 2 then
                campaignProgress.completedQuests = campaignProgress.completedQuests + 1
            end
        end
        
        table.insert(progress, campaignProgress)
    end
    
    return progress
end

-- Получить доступные предметы магазина для игрока
function CampaignProgress:GetAvailableShopItems(player)
    local guid = player:GetGUIDLow()
    local items = {}
    
    local query = "SELECT item_id, item_entry, item_name, item_description, campaign_required, quest_required, cost_type, cost_gold, cost_tokens, max_purchases FROM campaign_shop_items WHERE is_active = 1 ORDER BY sort_order"
    local result = CharDBQuery(query)
    
    if result then
        repeat
            local itemId = result:GetUInt32(0)
            local itemEntry = result:GetUInt32(1)
            local itemName = result:GetString(2)
            local itemDesc = result:GetString(3)
            local campaignReq = result:GetUInt32(4)
            local questReq = result:GetUInt32(5)
            local costType = result:GetString(6)
            local costGold = result:GetUInt64(7)
            local costTokens = result:GetUInt32(8)
            local maxPurchases = result:GetUInt32(9)
            
            -- Проверяем требования
            local canBuy = true
            local reason = ""
            
            if campaignReq > 0 then
                -- Проверяем завершены ли все квесты кампании
                local campData = self.Campaigns[campaignReq]
                if campData then
                    local allCompleted = true
                    for _, qId in ipairs(campData.quests) do
                        local qQuery = string.format(
                            "SELECT status FROM character_campaign_progress WHERE character_guid = %d AND quest_id = %d",
                            guid, qId
                        )
                        local qResult = CharDBQuery(qQuery)
                        if qResult then
                            local status = qResult:GetUInt32(0)
                            if status ~= 2 then
                                allCompleted = false
                                break
                            end
                        else
                            allCompleted = false
                            break
                        end
                    end
                    if not allCompleted then
                        canBuy = false
                        reason = "Необходимо пройти все квесты кампании"
                    end
                end
            end
            
            if questReq > 0 then
                local qQuery = string.format(
                    "SELECT status FROM character_campaign_progress WHERE character_guid = %d AND quest_id = %d",
                    guid, questReq
                )
                local qResult = CharDBQuery(qQuery)
                if qResult then
                    local status = qResult:GetUInt32(0)
                    if status ~= 2 then
                        canBuy = false
                        reason = "Необходимо завершить квест"
                    end
                else
                    canBuy = false
                    reason = "Квест не найден"
                end
            end
            
            -- Проверяем лимит покупок
            if maxPurchases > 0 then
                local pQuery = string.format(
                    "SELECT COUNT(*) FROM campaign_shop_purchases WHERE character_guid = %d AND item_id = %d",
                    guid, itemId
                )
                local pResult = CharDBQuery(pQuery)
                if pResult then
                    local count = pResult:GetUInt32(0)
                    if count >= maxPurchases then
                        canBuy = false
                        reason = "Лимит покупок исчерпан"
                    end
                end
            end
            
            table.insert(items, {
                itemId = itemId,
                itemEntry = itemEntry,
                itemName = itemName,
                itemDesc = itemDesc,
                campaignReq = campaignReq,
                questReq = questReq,
                costType = costType,
                costGold = costGold,
                costTokens = costTokens,
                maxPurchases = maxPurchases,
                canBuy = canBuy,
                reason = reason
            })
        until not result:NextRow()
    end
    
    return items
end

-- Купить предмет
function CampaignProgress:BuyItem(player, itemId)
    local guid = player:GetGUIDLow()
    
    -- Получить информацию о предмете
    local query = string.format(
        "SELECT item_entry, item_name, cost_type, cost_gold, cost_tokens, max_purchases FROM campaign_shop_items WHERE item_id = %d AND is_active = 1",
        itemId
    )
    local result = CharDBQuery(query)
    
    if not result then
        return false, "Предмет не найден"
    end
    
    local itemEntry = result:GetUInt32(1)
    local costType = result:GetString(3)
    local costGold = result:GetUInt64(4)
    local costTokens = result:GetUInt32(5)
    local maxPurchases = result:GetUInt32(6)
    
    -- Проверяем лимит
    if maxPurchases > 0 then
        local pQuery = string.format(
            "SELECT COUNT(*) FROM campaign_shop_purchases WHERE character_guid = %d AND item_id = %d",
            guid, itemId
        )
        local pResult = CharDBQuery(pQuery)
        if pResult then
            local count = pResult:GetUInt32(0)
            if count >= maxPurchases then
                return false, "Лимит покупок исчерпан"
            end
        end
    end
    
    -- Проверяем требования кампании/квеста
    local campReq = 0
    local questReq = 0
    local q2 = string.format("SELECT campaign_required, quest_required FROM campaign_shop_items WHERE item_id = %d", itemId)
    local r2 = CharDBQuery(q2)
    if r2 then
        campReq = r2:GetUInt32(0)
        questReq = r2:GetUInt32(1)
    end
    
    if campReq > 0 then
        local campData = self.Campaigns[campReq]
        if campData then
            for _, qId in ipairs(campData.quests) do
                local qQuery = string.format("SELECT status FROM character_campaign_progress WHERE character_guid = %d AND quest_id = %d", guid, qId)
                local qResult = CharDBQuery(qQuery)
                if qResult then
                    local status = qResult:GetUInt32(0)
                    if status ~= 2 then
                        return false, "Требуется пройти все квесты кампании"
                    end
                else
                    return false, "Требуется пройти все квесты кампании"
                end
            end
        end
    end
    
    if questReq > 0 then
        local qQuery = string.format("SELECT status FROM character_campaign_progress WHERE character_guid = %d AND quest_id = %d", guid, questReq)
        local qResult = CharDBQuery(qQuery)
        if qResult then
            local status = qResult:GetUInt32(0)
            if status ~= 2 then
                return false, "Требуется завершить квест"
            end
        else
            return false, "Квест не найден"
        end
    end
    
    -- Проверяем золото
    local playerGold = player:GetCoinage()
    if costGold > 0 and playerGold < costGold then
        return false, "Недостаточно золота"
    end
    
    -- Списываем золото
    if costGold > 0 then
        player:ModifyMoney(-costGold)
    end
    
    -- Выдаем предмет
    player:AddItem(itemEntry, 1)
    
    -- Записываем покупку
    local insertQuery = string.format(
        "INSERT INTO campaign_shop_purchases (character_guid, item_id) VALUES (%d, %d)",
        guid, itemId
    )
    CharDBQuery(insertQuery)
    
    return true, "Предмет приобретён!"
end

-- Регистрация событий
RegisterPlayerEvent(3, function(event, player)
    CampaignProgress:OnPlayerLogin(event, player)
end)

RegisterPlayerEvent(32, function(event, player, questId)
    CampaignProgress:OnQuestComplete(event, player, questId)
end)

print("[NightDarkRaven] Campaign Progress system loaded")