-- ============================================================================
-- Кампания 6: Забытый Храм (quests 90601-90604)
-- Дачитель: Хранитель Храма (entry 90060)
-- Лут мобов кампании 6
-- ============================================================================

local function OnCreatureKill_90061(event, creature, victim)
    if creature:GetEntry() ~= 90061 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(90602) then
        if player:GetItemCount(90062) < 8 then
            if math.random(100) <= 70 then
                player:AddItem(90062, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Пыль Костей! (" .. player:GetItemCount(90062) .. "/8)")
            end
        end
    end
end

local function OnCreatureKill_90062(event, creature, victim)
    if creature:GetEntry() ~= 90062 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(90603) then
        if player:GetItemCount(90063) < 1 then
            if math.random(100) <= 10 then
                player:AddItem(90063, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Ключ Храма!")
            end
        end
    end
end

RegisterCreatureEvent(90061, 4, OnCreatureKill_90061)
RegisterCreatureEvent(90062, 4, OnCreatureKill_90062)

print("[NightDarkRaven] Кампания 6: Забытый Храм загружена.")