-- ============================================================================
-- Кампания 8: Вороновой Клинок (quests 90801-90804)
-- Дачитель: Кузнец Теней (entry 90080)
-- Лут мобов кампании 8
-- ============================================================================

local function OnCreatureKill_90081(event, creature, victim)
    if creature:GetEntry() ~= 90081 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(90802) then
        if player:GetItemCount(90082) < 3 then
            if math.random(100) <= 100 then
                player:AddItem(90082, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Искра Огня! (" .. player:GetItemCount(90082) .. "/3)")
            end
        end
    end
end

local function OnCreatureKill_90082(event, creature, victim)
    if creature:GetEntry() ~= 90082 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(90801) then
        if player:GetItemCount(90083) < 1 then
            if math.random(100) <= 50 then
                player:AddItem(90083, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Чешуя Теневого Ворона!")
            end
        end
    end
end

RegisterCreatureEvent(90081, 4, OnCreatureKill_90081)
RegisterCreatureEvent(90082, 4, OnCreatureKill_90082)

print("[NightDarkRaven] Кампания 8: Вороновой Клинок загружена.")