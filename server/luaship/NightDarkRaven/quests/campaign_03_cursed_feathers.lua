-- ============================================================================
-- Кампания 3: Проклятие Перьев (quests 90301-90303)
-- Дачитель: Друид Теней (entry 90030) — gossip обрабатывается quest_system.lua
-- Лут мобов кампании 3
-- ============================================================================

local function OnCreatureKill_90031(event, creature, victim)
    if creature:GetEntry() ~= 90031 then return end
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end
    local player = players[1]
    if player and player:HasQuest(90301) then
        if player:GetItemCount(90031) < 8 then
            if math.random(100) <= 40 then
                player:AddItem(90031, 1)
                player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Проклятое Перо! (" .. player:GetItemCount(90031) .. "/8)")
            end
        end
    end
end

RegisterCreatureEvent(90031, 4, OnCreatureKill_90031)

print("[NightDarkRaven] Кампания 3: Проклятие Перьев загружена.")