-- ============================================================================
-- Ночь темного Ворона — Квесты Уроков Иллидана (Lua / Eluna)
-- Дачители: Иллидан (94001), Инструктор ПвП (94002), Инструктор ПвЕ (94003)
-- ============================================================================

local IllidanLessons = require("NightDarkRaven.systems.illidans_lessons_system")

local NPC_ILLIDAN = 94001
local NPC_PVP_INSTRUCTOR = 94002
local NPC_PVE_INSTRUCTOR = 94003

-- ============================================================================
-- Иллидан Ярче Звезд (94001) — финальный квест и общий доступ
-- ============================================================================

local function OnGossipHello_Illidan(event, player, creature)
    if creature:GetEntry() ~= NPC_ILLIDAN then return end

    -- Финальный квест
    if not player:HasQuest(93007) and not player:HasFinishedQuest(93007) then
        -- Проверяем завершены ли все уроки
        local progress = IllidanLessons.GetProgress(player)
        local allPvpDone = true
        local allPveDone = true

        for questId in pairs(IllidanLessons.Lessons.pvp) do
            if not progress.pvp[questId] then allPvpDone = false break end
        end
        for questId in pairs(IllidanLessons.Lessons.pve) do
            if not progress.pve[questId] then allPveDone = false break end
        end

        if allPvpDone and allPveDone then
            player:GossipMenuAddItem(0, "Взять финальный квест: Полный Курс Иллидана", 0, 101)
        else
            player:GossipMenuAddItem(0, "|cffFF0000Требуется завершить все уроки ПвП и ПвЕ|r", 0, 255)
        end
    end
    if player:HasQuest(93007) then
        player:GossipMenuAddItem(0, "Я завершил все уроки Иллидана", 0, 102)
    end

    -- Информация о курсе
    player:GossipMenuAddItem(0, "Информация о курсе уроков", 0, 201)

    player:GossipMenuAddItem(0, "Ничего", 0, 255)
    player:GossipSendMenu(90001, creature)
end

local function OnGossipSelect_Illidan(event, player, creature, sender, intid, code)
    if creature:GetEntry() ~= NPC_ILLIDAN then return end

    if intid == 101 then
        player:AddQuest(93007)
        creature:SendUnitSay("Добро пожаловать на Полный Курс, ученик. Я жду твоего возвращения после завершения всех уроков.", 0)
        player:GossipComplete()
    elseif intid == 102 then
        player:CompleteQuest(93007)
        player:RewardPlayer(93007)
        creature:SendUnitSay("Ты proved himself worthy. Прими награду Иллидана.", 0)
        player:GossipComplete()
    elseif intid == 201 then
        creature:SendUnitSay("Курс состоит из 6 уроков: 3 ПвП и 3 ПвЕ. Заверши их все, чтобы получить эпическую награду.", 0)
        player:GossipComplete()
    elseif intid == 255 then
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NPC_ILLIDAN, 1, OnGossipHello_Illidan)
RegisterCreatureGossipEvent(NPC_ILLIDAN, 2, OnGossipSelect_Illidan)

-- ============================================================================
-- Инструктор ПвП (94002) — уроки ПвП
-- ============================================================================

local function OnGossipHello_PVP(event, player, creature)
    if creature:GetEntry() ~= NPC_PVP_INSTRUCTOR then return end

    -- Урок 1: Стойкость
    if not player:HasQuest(93001) and not player:HasFinishedQuest(93001) then
        player:GossipMenuAddItem(0, "Урок 1: Стойкость ПвП (5 мин)", 0, 101)
    end
    if player:HasQuest(93001) then
        player:GossipMenuAddItem(0, "Я выдержал 5 минут в дуэли", 0, 102)
    end

    -- Урок 2: Точность
    if not player:HasQuest(93002) and not player:HasFinishedQuest(93002) and player:HasFinishedQuest(93001) then
        player:GossipMenuAddItem(0, "Урок 2: Точность ПвП (50 критов)", 0, 201)
    end
    if player:HasQuest(93002) then
        player:GossipMenuAddItem(0, "Я нанес 50 критических ударов", 0, 202)
    end

    -- Урок 3: Мастерство
    if not player:HasQuest(93003) and not player:HasFinishedQuest(93003) and player:HasFinishedQuest(93002) then
        player:GossipMenuAddItem(0, "Урок 3: Мастерство ПвП (комбинации)", 0, 301)
    end
    if player:HasQuest(93003) then
        player:GossipMenuAddItem(0, "Я провел комбинированную атаку", 0, 302)
    end

    player:GossipMenuAddItem(0, "Ничего", 0, 255)
    player:GossipSendMenu(90001, creature)
end

local function OnGossipSelect_PVP(event, player, creature, sender, intid, code)
    if creature:GetEntry() ~= NPC_PVP_INSTRUCTOR then return end

    if intid == 101 then
        IllidanLessons.StartLesson(player, 93001)
        player:AddQuest(93001)
        creature:SendUnitSay("Урок стойкости начат. Выдержите 5 минут в дуэли.", 0)
        player:GossipComplete()
    elseif intid == 102 then
        IllidanLessons.CompleteLesson(player, 93001)
        player:GossipComplete()
    elseif intid == 201 then
        IllidanLessons.StartLesson(player, 93002)
        player:AddQuest(93002)
        creature:SendUnitSay("Урок точности начат. Нанесите 50 критических ударов.", 0)
        player:GossipComplete()
    elseif intid == 202 then
        IllidanLessons.CompleteLesson(player, 93002)
        player:GossipComplete()
    elseif intid == 301 then
        IllidanLessons.StartLesson(player, 93003)
        player:AddQuest(93003)
        creature:SendUnitSay("Урок мастерства начат. Проведите комбинированную атаку.", 0)
        player:GossipComplete()
    elseif intid == 302 then
        IllidanLessons.CompleteLesson(player, 93003)
        player:GossipComplete()
    elseif intid == 255 then
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NPC_PVP_INSTRUCTOR, 1, OnGossipHello_PVP)
RegisterCreatureGossipEvent(NPC_PVP_INSTRUCTOR, 2, OnGossipSelect_PVP)

-- ============================================================================
-- Инструктор ПвЕ (94003) — уроки ПвЕ
-- ============================================================================

local function OnGossipHello_PVE(event, player, creature)
    if creature:GetEntry() ~= NPC_PVE_INSTRUCTOR then return end

    -- Урок 4: Выживание
    if not player:HasQuest(93004) and not player:HasFinishedQuest(93004) then
        player:GossipMenuAddItem(0, "Урок 4: Выживание в Рейде (10 мин)", 0, 101)
    end
    if player:HasQuest(93004) then
        player:GossipMenuAddItem(0, "Я выдержал 10 минут в рейде", 0, 102)
    end

    -- Урок 5: Урон
    if not player:HasQuest(93005) and not player:HasFinishedQuest(93005) and player:HasFinishedQuest(93004) then
        player:GossipMenuAddItem(0, "Урок 5: Урон по Боссу (100000 урона)", 0, 201)
    end
    if player:HasQuest(93005) then
        player:GossipMenuAddItem(0, "Я нанёс 100000 урона", 0, 202)
    end

    -- Урок 6: Позиционирование
    if not player:HasQuest(93006) and not player:HasFinishedQuest(93006) and player:HasFinishedQuest(93005) then
        player:GossipMenuAddItem(0, "Урок 6: Позиционирование (5 мин)", 0, 301)
    end
    if player:HasQuest(93006) then
        player:GossipMenuAddItem(0, "Я сохранил позицию в безопасности", 0, 302)
    end

    player:GossipMenuAddItem(0, "Ничего", 0, 255)
    player:GossipSendMenu(90001, creature)
end

local function OnGossipSelect_PVE(event, player, creature, sender, intid, code)
    if creature:GetEntry() ~= NPC_PVE_INSTRUCTOR then return end

    if intid == 101 then
        IllidanLessons.StartLesson(player, 93004)
        player:AddQuest(93004)
        creature:SendUnitSay("Урок выживания начат. Выдержите 10 минут возле цели.", 0)
        player:GossipComplete()
    elseif intid == 102 then
        IllidanLessons.CompleteLesson(player, 93004)
        player:GossipComplete()
    elseif intid == 201 then
        IllidanLessons.StartLesson(player, 93005)
        player:AddQuest(93005)
        creature:SendUnitSay("Урон по боссу начат. Нанесите 100000 урона.", 0)
        player:GossipComplete()
    elseif intid == 202 then
        IllidanLessons.CompleteLesson(player, 93005)
        player:GossipComplete()
    elseif intid == 301 then
        IllidanLessons.StartLesson(player, 93006)
        player:AddQuest(93006)
        creature:SendUnitSay("Урок позиционирования начат. Сохраните позицию 5 минут.", 0)
        player:GossipComplete()
    elseif intid == 302 then
        IllidanLessons.CompleteLesson(player, 93006)
        player:GossipComplete()
    elseif intid == 255 then
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NPC_PVE_INSTRUCTOR, 1, OnGossipHello_PVE)
RegisterCreatureGossipEvent(NPC_PVE_INSTRUCTOR, 2, OnGossipSelect_PVE)

print("[NightDarkRaven] Уроки Иллидана загружены (квесты 93001-93007, NPC 94001-94005).")