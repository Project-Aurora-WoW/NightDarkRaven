-- ============================================================================
-- Кампания 9: Ночной Дозор (quests 90901-90903)
-- Дачитель: Капитан Дозора (entry 90090)
-- Лут мобов кампании 9
-- ============================================================================

local function OnCreatureKill_90091(event, creature, victim)
    if creature:GetEntry() ~= 90091 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(90901) then
        if player:GetItemCount(90091) < 1 then
            if math.random(100) <= 30 then
                player:AddItem(90091, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Знак Дозора!")
            end
        end
    end
end

local function OnCreatureKill_90092(event, creature, victim)
    if creature:GetEntry() ~= 90092 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(90903) then
        if player:GetItemCount(90093) < 5 then
            if math.random(100) <= 80 then
                player:AddItem(90093, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Когти Ночного Хищника! (" .. player:GetItemCount(90093) .. "/5)")
            end
        end
    end
end

RegisterCreatureEvent(90091, 4, OnCreatureKill_90091)
RegisterCreatureEvent(90092, 4, OnCreatureKill_90092)

print("[NightDarkRaven] Кампания 9: Ночной Дозор загружена.")