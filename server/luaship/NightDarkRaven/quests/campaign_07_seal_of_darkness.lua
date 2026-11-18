-- ============================================================================
-- Кампания 7: Печать Тьмы (quests 90701-90703)
-- Дачитель: Маг Пустоты (entry 90070)
-- Лут мобов кампании 7
-- ============================================================================

local function OnCreatureKill_90071(event, creature, victim)
    if creature:GetEntry() ~= 90071 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(90702) then
        if player:GetItemCount(90072) < 6 then
            if math.random(100) <= 60 then
                player:AddItem(90072, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Кровь Демона! (" .. player:GetItemCount(90072) .. "/6)")
            end
        end
    end
end

local function OnCreatureKill_90072(event, creature, victim)
    if creature:GetEntry() ~= 90072 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(90703) then
        if player:GetItemCount(90071) < 1 then
            if math.random(100) <= 15 then
                player:AddItem(90071, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Осколок Пустоты!")
            end
        end
    end
end

RegisterCreatureEvent(90071, 4, OnCreatureKill_90071)
RegisterCreatureEvent(90072, 4, OnCreatureKill_90072)

print("[NightDarkRaven] Кампания 7: Печать Тьмы загружена.")