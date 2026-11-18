-- ============================================================================
-- Кампания 4: Кровавая Луна (quests 90401-90404)
-- Дачитель: Жрица Луны (entry 90040) — gossip обрабатывается quest_system.lua
-- Лут мобов кампании 4
-- ============================================================================

local function OnCreatureKill_90041(event, creature, victim)
    if creature:GetEntry() ~= 90041 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(90401) then
        if player:GetItemCount(90041) < 6 then
            if math.random(100) <= 50 then
                player:AddItem(90041, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Кровавый Клык! (" .. player:GetItemCount(90041) .. "/6)")
            end
        end
    end
end

local function OnCreatureKill_90042(event, creature, victim)
    if creature:GetEntry() ~= 90042 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(90404) then
        if math.random(100) <= 30 then
            player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Призрачная Сова устранена!")
        end
    end
end

RegisterCreatureEvent(90041, 4, OnCreatureKill_90041)
RegisterCreatureEvent(90042, 4, OnCreatureKill_90042)

print("[NightDarkRaven] Кампания 4: Кровавая Луна загружена.")