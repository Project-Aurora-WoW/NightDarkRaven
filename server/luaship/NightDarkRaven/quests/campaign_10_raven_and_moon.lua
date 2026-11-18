-- ============================================================================
-- Кампания 10: Ворон и Луна (quests 91001-91004)
-- Дачитель: Оракул Луны (entry 90100)
-- Лут мобов кампании 10
-- ============================================================================

local function OnCreatureKill_90101(event, creature, victim)
    if creature:GetEntry() ~= 90101 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(91001) then
        if player:GetItemCount(90101) < 2 then
            if math.random(100) <= 30 then
                player:AddItem(90101, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Слёза Луны! (" .. player:GetItemCount(90101) .. "/2)")
            end
        end
    end
end

local function OnCreatureKill_90102(event, creature, victim)
    if creature:GetEntry() ~= 90102 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(91003) then
        if player:GetItemCount(90103) < 1 then
            if math.random(100) <= 10 then
                player:AddItem(90103, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Перо Аспекта Ворона!")
            end
        end
    end
end

RegisterCreatureEvent(90101, 4, OnCreatureKill_90101)
RegisterCreatureEvent(90102, 4, OnCreatureKill_90102)

print("[NightDarkRaven] Кампания 10: Ворон и Луна загружена.")