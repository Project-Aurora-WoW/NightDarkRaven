-- ============================================================================
-- Кампания 2: Тени Вороновой Горы (quests 90201-90204)
-- Дачитель: Старшина Ворона (entry 90020) — gossip обрабатывается quest_system.lua
-- Лут мобов кампании 2
-- ============================================================================

local function OnCreatureKill_90021(event, creature, victim)
    if creature:GetEntry() ~= 90021 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(90201) then
        if math.random(100) <= 60 then
            player:AddItem(90021, 1)
            player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Шкура Горного Волка!")
        end
    end
end

local function OnCreatureKill_90022(event, creature, victim)
    if creature:GetEntry() ~= 90022 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(90203) then
        if math.random(100) <= 10 then
            player:AddItem(90023, 1)
            player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Перо Каменного Гаргулья!")
        end
    end
end

RegisterCreatureEvent(90021, 4, OnCreatureKill_90021)
RegisterCreatureEvent(90022, 4, OnCreatureKill_90022)

print("[NightDarkRaven] Кампания 2: Тени Вороновой Горы загружена.")