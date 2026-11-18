-- ============================================================================
-- Кампания 11: Конец Ночи (quests 91101-91105)
-- Дачитель: Темный Ворон (entry 90110) — финальный босс
-- Лут мобов кампании 11
-- ============================================================================

local function OnCreatureKill_90111(event, creature, victim)
    if creature:GetEntry() ~= 90111 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(91102) then
        if player:GetItemCount(90112) < 1 then
            if math.random(100) <= 100 then
                player:AddItem(90112, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Крыло Ночи!")
            end
        end
    end
end

local function OnCreatureKill_90110(event, creature, victim)
    if creature:GetEntry() ~= 90110 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(91103) then
        if player:GetItemCount(90111) < 1 then
            if math.random(100) <= 100 then
                player:AddItem(90111, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Сердце Темного Ворона!")
                creature:SendUnitSay("Сердце Ворона теперь твое...", 0)
            end
        end
    end
end

RegisterCreatureEvent(90111, 4, OnCreatureKill_90111)
RegisterCreatureEvent(90110, 4, OnCreatureKill_90110)

print("[NightDarkRaven] Кампания 11: Конец Ночи загружена.")