-- ============================================================================
-- Ночь темного Ворона — Соло-квесты
-- Квесты, доступные только в соло-режиме, с наградой компаньонов
-- ============================================================================

local SoloSystem = require("NightDarkRaven.systems.solo_system")
local CompanionSystem = require("NightDarkRaven.systems.companion_system")

local NPC_SOLO_GUIDE = 90001 -- Темный Ворон (главный NPC) также выдаёт соло-квесты

-- Соло-квест 95001: Испытание Одиночества
local function OnGossipHello_SoloGuide(event, player, creature)
    if creature:GetEntry() ~= NPC_SOLO_GUIDE then return end

    if not player:HasQuest(95001) and not player:HasFinishedQuest(95001) then
        player:GossipMenuAddItem(0, "Соло-квест: Испытание Одиночества", 0, 501)
    end
    if player:HasQuest(95001) then
        player:GossipMenuAddItem(0, "Я прошёл испытание в одиночку", 0, 502)
    end

    if not player:HasQuest(95002) and not player:HasFinishedQuest(95002) and player:HasFinishedQuest(95001) then
        player:GossipMenuAddItem(0, "Соло-квест: Путник Теней (компаньон)", 0, 511)
    end
    if player:HasQuest(95002) then
        player:GossipMenuAddItem(0, "Я приручил Теневого Ворона", 0, 512)
    end

    -- Соло-режим переключатель
    if SoloSystem.IsSoloMode(player) then
        player:GossipMenuAddItem(0, "Выключить соло-режим", 0, 601)
    else
        player:GossipMenuAddItem(0, "Включить соло-режим (одиночная игра)", 0, 600)
    end

    player:GossipMenuAddItem(0, "Ничего", 0, 255)
    player:GossipSendMenu(90001, creature)
end

local function OnGossipSelect_SoloGuide(event, player, creature, sender, intid, code)
    if creature:GetEntry() ~= NPC_SOLO_GUIDE then return end

    -- Переключатель соло-режима
    if intid == 600 then
        SoloSystem.EnableSoloMode(player)
        player:GossipComplete()
        return
    elseif intid == 601 then
        SoloSystem.DisableSoloMode(player)
        player:GossipComplete()
        return
    end

    if intid == 501 then
        if not SoloSystem.IsSoloMode(player) then
            creature:SendUnitSay("Включи соло-режим, чтобы пройти испытание.", 0)
            player:GossipComplete()
            return
        end
        player:AddQuest(95001)
        creature:SendUnitSay("Пройди путь Ворона в одиночку, без группы.", 0)
        player:GossipComplete()
    elseif intid == 502 then
        if SoloSystem.IsSoloMode(player) then
            player:CompleteQuest(95001)
            player:RewardPlayer(95001)
            player:AddItem(91001, 1) -- Кольцо Ночного Ворона
            creature:SendUnitSay("Ты достоин звания Ночного Ворона. Прими это кольцо.", 0)
        else
            creature:SendUnitSay("Это испытание только для соло.", 0)
        end
        player:GossipComplete()
    elseif intid == 511 then
        player:AddQuest(95002)
        creature:SendUnitSay("Приручи Теневого Ворона — он станет твоим компаньоном в соло.", 0)
        player:GossipComplete()
    elseif intid == 512 then
        -- Выдача компаньона после прохождения
        CompanionSystem.SpawnCompanion(player, 92001) -- Теневой Ворон
        player:CompleteQuest(95002)
        player:RewardPlayer(95002)
        creature:SendUnitSay("Теневой Ворон теперь с тобой.", 0)
        player:GossipComplete()
    elseif intid == 255 then
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NPC_SOLO_GUIDE, 1, OnGossipHello_SoloGuide)
RegisterCreatureGossipEvent(NPC_SOLO_GUIDE, 2, OnGossipSelect_SoloGuide)

print("[NightDarkRaven] Соло-квесты загружены (95001-95002).")