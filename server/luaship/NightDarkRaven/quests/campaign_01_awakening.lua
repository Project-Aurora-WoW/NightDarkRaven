-- ============================================================================
-- Кампания 1: Пробуждение Ворона (quests 90101-90103)
-- Дачитель: Стражник Ночи (entry 90010) — gossip обрабатывается quest_system.lua
-- Лут мобов кампании 1
-- ============================================================================

local function OnCreatureKill_90011(event, creature, victim)
    if creature:GetEntry() ~= 90011 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(90101) then
        if player:GetItemCount(90001) < 5 then
            if math.random(100) <= 50 then
                player:AddItem(90001, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Перо Тени! (" .. player:GetItemCount(90001) .. "/5)")
            end
        end
    end
end

RegisterCreatureEvent(90011, 4, OnCreatureKill_90011)

print("[NightDarkRaven] Кампания 1: Пробуждение Ворона загружена.")