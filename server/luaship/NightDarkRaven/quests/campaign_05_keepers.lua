-- ============================================================================
-- Кампания 5: Хранители Ночи (quests 90501-90503)
-- Дачитель: Верховный Хранитель (entry 90050) — gossip обрабатывается quest_system.lua
-- Лут мобов кампании 5
-- ============================================================================

local function OnCreatureKill_90051(event, creature, victim)
    if creature:GetEntry() ~= 90051 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(90501) then
        if player:GetItemCount(90051) < 1 then
            if math.random(100) <= 20 then
                player:AddItem(90051, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Печать Хранителя!")
            end
        end
    end
end

local function OnCreatureKill_90052(event, creature, victim)
    if creature:GetEntry() ~= 90052 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(90502) then
        if player:GetItemCount(90052) < 4 then
            if math.random(100) <= 50 then
                player:AddItem(90052, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Масло Теней! (" .. player:GetItemCount(90052) .. "/4)")
            end
        end
    end
end

RegisterCreatureEvent(90051, 4, OnCreatureKill_90051)
RegisterCreatureEvent(90052, 4, OnCreatureKill_90052)

print("[NightDarkRaven] Кампания 5: Хранители Ночи загружена.")