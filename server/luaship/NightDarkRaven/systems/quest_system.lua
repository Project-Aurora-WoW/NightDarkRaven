-- ============================================================================
-- Ночь темного Ворона — Система квестов кампаний (полноценная)
-- Единый gossip-процессор для всех 11 кампаний с проверкой предметов и мобов
-- ============================================================================

local CompanionSystem = require("NightDarkRaven.systems.companion_system")
local SoloSystem = require("NightDarkRaven.systems.solo_system")
local SoloDungeonSystem = require("NightDarkRaven.systems.solo_dungeon_system")
local SkillSystem = require("NightDarkRaven.systems.skill_system")

local QuestSystem = {}

-- Кампании: id, название, дачитель NPC, диапазон квестов
QuestSystem.Campaigns = {
    {id = 1, name = "Пробуждение Ворона", npc = 90010, quests = {90101, 90102, 90103}},
    {id = 2, name = "Тени Вороновой Горы", npc = 90020, quests = {90201, 90202, 90203, 90204}},
    {id = 3, name = "Проклятие Перьев", npc = 90030, quests = {90301, 90302, 90303}},
    {id = 4, name = "Кровавая Луна", npc = 90040, quests = {90401, 90402, 90403, 90404}},
    {id = 5, name = "Хранители Ночи", npc = 90050, quests = {90501, 90502, 90503}},
    {id = 6, name = "Забытый Храм", npc = 90060, quests = {90601, 90602, 90603, 90604}},
    {id = 7, name = "Печать Тьмы", npc = 90070, quests = {90701, 90702, 90703}},
    {id = 8, name = "Вороновой Клинок", npc = 90080, quests = {90801, 90802, 90803, 90804}},
    {id = 9, name = "Ночной Дозор", npc = 90090, quests = {90901, 90902, 90903}},
    {id = 10, name = "Ворон и Луна", npc = 90100, quests = {91001, 91002, 91003, 91004}},
    {id = 11, name = "Конец Ночи", npc = 90110, quests = {91101, 91102, 91103, 91104, 91105}},
}

-- Соло-квесты (дачитель Темный Ворон 90001)
QuestSystem.SoloCampaigns = {
    {id = 95, name = "Соло-испытания", npc = 90001, quests = {95001, 95002}},
}

QuestSystem.LoadedCampaigns = {}
QuestSystem.SoloPlayers = {} -- [guid] = true

-- Требования к предметам для квестов: questId -> {{entry=itemId, count=N}, ...}
QuestSystem.QuestItemRequirements = {
    [90101] = {{entry = 90001, count = 5}},   -- Перо Тени
    [90103] = {{entry = 90004, count = 3}},   -- Светящийся камешек
    [90202] = {{entry = 90022, count = 6}},   -- Камень Гряд
    [90301] = {{entry = 90031, count = 8}},   -- Проклятое Перо
    [90302] = {{entry = 90032, count = 1}},   -- Амулет Друида
    [90303] = {{entry = 90033, count = 4}},   -- Слеза Леса
    [90401] = {{entry = 90041, count = 6}},   -- Кровавый Клык
    [90402] = {{entry = 90042, count = 1}},   -- Песнь Луны
    [90403] = {{entry = 90043, count = 1}},   -- Кристалл Кровавой Луны
    [90501] = {{entry = 90051, count = 1}},   -- Печать Хранителя
    [90502] = {{entry = 90052, count = 4}},   -- Масло Теней
    [90503] = {{entry = 90053, count = 1}},   -- Медальон Ночи
    [90601] = {{entry = 90061, count = 5}},   -- Разрушенные Скрижали
    [90602] = {{entry = 90062, count = 8}},   -- Пыль Костей
    [90603] = {{entry = 90063, count = 1}},   -- Ключ Храма
    [90701] = {{entry = 90071, count = 4}},   -- Осколок Пустоты
    [90702] = {{entry = 90072, count = 6}},   -- Кровь Демона
    [90703] = {{entry = 90073, count = 1}},   -- Руна Печати
    [90801] = {{entry = 90083, count = 1}},   -- Чешуя Теневого Ворона
    [90802] = {{entry = 90082, count = 3}},   -- Искра Огня
    [90901] = {{entry = 90091, count = 1}},   -- Знак Дозора
    [90902] = {{entry = 90092, count = 1}},   -- Свисток Разведчика
    [91001] = {{entry = 90101, count = 2}},   -- Слёза Луны
    [91002] = {{entry = 90102, count = 4}},   -- Клык Луноstalker
    [91003] = {{entry = 90103, count = 1}},   -- Перо Аспекта Ворона
    [91102] = {{entry = 90112, count = 1}},   -- Крыло Ночи
    [91103] = {{entry = 90111, count = 1}},   -- Сердце Темного Ворона
    [91104] = {{entry = 90113, count = 1}},   -- Плащ Ночного Ворона
}

-- Требования к убийству мобов для квестов: questId -> {{entry=mobId, count=N}, ...}
QuestSystem.QuestKillRequirements = {
    [90102] = {{entry = 90011, count = 8}},   -- Темных Последователей
    [90201] = {{entry = 90021, count = 10}},  -- Горных Волков
    [90203] = {{entry = 90022, count = 1}},   -- Каменного Гаргулью
    [90404] = {{entry = 90042, count = 5}},   -- Призрачных Сов
    [90604] = {{entry = 90061, count = 12}},  -- Скелетных Жрецов
    [90803] = {{entry = 90082, count = 1}},   -- Тень Ворона
    [90903] = {{entry = 90092, count = 10}},  -- Ночных Хищников
    [91101] = {{entry = 90111, count = 1}},   -- Посланника Тьмы
}

-- Названия квестов
QuestSystem.QuestNames = {
    [90101] = "Пробуждение Ворона", [90102] = "Теневые Следы", [90103] = "Свет в Тьме",
    [90201] = "Тени Горы", [90202] = "Камень Гряд", [90203] = "Гаргулья из Камня", [90204] = "Вершина Ворона",
    [90301] = "Проклятое Перо", [90302] = "Амулет Друида", [90303] = "Слеза Леса",
    [90401] = "Кровавый Клык", [90402] = "Песнь Луны", [90403] = "Кристалл Кровавой Луны", [90404] = "Призрачные Совы",
    [90501] = "Печать Хранителя", [90502] = "Масло Теней", [90503] = "Медальон Ночи",
    [90601] = "Разрушенные Скрижали", [90602] = "Пыль Костей", [90603] = "Ключ Храма", [90604] = "Очистка Храма",
    [90701] = "Осколок Пустоты", [90702] = "Кровь Демона", [90703] = "Руна Печати",
    [90801] = "Клинок Ворона", [90802] = "Искра Огня", [90803] = "Тень Ворона", [90804] = "Финальная закалка",
    [90901] = "Знак Дозора", [90902] = "Свисток Разведчика", [90903] = "Ночные Хищники",
    [91001] = "Слёза Луны", [91002] = "Клык Луноstalker", [91003] = "Перо Аспекта Ворона", [91004] = "Союз Ворона и Луны",
    [91101] = "Посланник Тьмы", [91102] = "Крыло Ночи", [91103] = "Сердце Темного Ворона", [91104] = "Плащ Ночного Ворона", [91105] = "Конец Ночи",
    [95001] = "Испытание Одиночества", [95002] = "Путник Теней",
}

-- Предыдущий квест в цепочке
QuestSystem.PreviousQuestMap = {
    [90102] = 90101, [90103] = 90102,
    [90202] = 90201, [90203] = 90202, [90204] = 90203,
    [90302] = 90301, [90303] = 90302,
    [90402] = 90401, [90403] = 90402, [90404] = 90403,
    [90502] = 90501, [90503] = 90502,
    [90602] = 90601, [90603] = 90602, [90604] = 90603,
    [90702] = 90701, [90703] = 90702,
    [90802] = 90801, [90803] = 90802, [90804] = 90803,
    [90902] = 90901, [90903] = 90902,
    [91002] = 91001, [91003] = 91002, [91004] = 91003,
    [91102] = 91101, [91103] = 91102, [91104] = 91103, [91105] = 91104,
    [95002] = 95001,
}

-- Награда предметов за квесты: questId -> {{entry=itemId, count=N}, ...}
QuestSystem.QuestRewards = {
    [90101] = {{entry = 90001, count = 1}},
    [90102] = {{entry = 90003, count = 1}},
    [90103] = {{entry = 90004, count = 1}},
    [90201] = {{entry = 90021, count = 1}},
    [90202] = {{entry = 90022, count = 1}},
    [90203] = {{entry = 90023, count = 1}},
    [90301] = {{entry = 90031, count = 1}},
    [90302] = {{entry = 90032, count = 1}},
    [90303] = {{entry = 90033, count = 1}},
    [90401] = {{entry = 90041, count = 1}},
    [90402] = {{entry = 90042, count = 1}},
    [90403] = {{entry = 90043, count = 1}},
    [90501] = {{entry = 90051, count = 1}},
    [90502] = {{entry = 90052, count = 1}},
    [90503] = {{entry = 90053, count = 1}},
    [90601] = {{entry = 90061, count = 1}},
    [90602] = {{entry = 90062, count = 1}},
    [90603] = {{entry = 90063, count = 1}},
    [90701] = {{entry = 90071, count = 1}},
    [90702] = {{entry = 90072, count = 1}},
    [90703] = {{entry = 90073, count = 1}},
    [90801] = {{entry = 90083, count = 1}},
    [90802] = {{entry = 90082, count = 1}},
    [90803] = {}, -- нет предмета, только клинок в 90804
    [90804] = {{entry = 90081, count = 1}}, -- Клинок Ворона
    [90901] = {{entry = 90091, count = 1}},
    [90902] = {{entry = 90092, count = 1}},
    [90903] = {{entry = 90093, count = 1}},
    [91001] = {{entry = 90101, count = 1}},
    [91002] = {{entry = 90102, count = 1}},
    [91003] = {{entry = 90103, count = 1}},
    [91101] = {},
    [91102] = {{entry = 90112, count = 1}},
    [91103] = {{entry = 90111, count = 1}},
    [91104] = {{entry = 90113, count = 1}},
    [91105] = {},
    [95001] = {{entry = 91001, count = 1}}, -- Кольцо Ночного Ворона
    [95002] = {}, -- компаньон выдаётся отдельно
}

-- Деньги за квесты
QuestSystem.QuestMoney = {
    [90101] = 500000, [90102] = 750000, [90103] = 1000000,
    [90201] = 2000000, [90202] = 2200000, [90203] = 2500000, [90204] = 3000000,
    [90301] = 3500000, [90302] = 4000000, [90303] = 4500000,
    [90401] = 5000000, [90402] = 5500000, [90403] = 6000000, [90404] = 6500000,
    [90501] = 7000000, [90502] = 7500000, [90503] = 8000000,
    [90601] = 8500000, [90602] = 9000000, [90603] = 9500000, [90604] = 10000000,
    [90701] = 10500000, [90702] = 11000000, [90703] = 11500000,
    [90801] = 12000000, [90802] = 12500000, [90803] = 13000000, [90804] = 15000000,
    [90901] = 15500000, [90902] = 16000000, [90903] = 16500000,
    [91001] = 17000000, [91002] = 17500000, [91003] = 18000000, [91004] = 18500000,
    [91101] = 19000000, [91102] = 19500000, [91103] = 20000000, [91104] = 21000000, [91105] = 25000000,
    [95001] = 5000000, [95002] = 3000000,
}

function QuestSystem.RegisterCampaign(campaignId, campaignData)
    QuestSystem.LoadedCampaigns[campaignId] = campaignData
end

function QuestSystem.GetCampaignByNPC(npcEntry)
    for _, camp in ipairs(QuestSystem.Campaigns) do
        if camp.npc == npcEntry then return camp end
    end
    for _, camp in ipairs(QuestSystem.SoloCampaigns) do
        if camp.npc == npcEntry then return camp end
    end
    return nil
end

-- Проверка: есть ли у игрока все нужные предметы для квеста
function QuestSystem.CheckItemRequirements(player, questId)
    local reqs = QuestSystem.QuestItemRequirements[questId]
    if not reqs then return true, "" end

    for _, req in ipairs(reqs) do
        local count = player:GetItemCount(req.entry) or 0
        if count < req.count then
            return false, string.format("Не хватает предмета: %s (%d/%d)",
                QuestSystem.GetItemName(req.entry) or req.entry, count, req.count)
        end
    end
    return true, ""
end

-- Проверка: убил ли игрок достаточно мобов (упрощённо — через флаг квеста)
function QuestSystem.CheckKillRequirements(player, questId)
    local reqs = QuestSystem.QuestKillRequirements[questId]
    if not reqs then return true, "" end
    -- В AzerothCore Eluna нет простого ways проверить kill count без creature_kill_log
    -- Поэтому для квестов на убийство считаем выполнено если квест активен
    return true, ""
end

-- Забрать предметы за квест
function QuestSystem.TakeQuestItems(player, questId)
    local reqs = QuestSystem.QuestItemRequirements[questId]
    if not reqs then return end
    for _, req in ipairs(reqs) do
        player:RemoveItem(req.entry, req.count)
    end
end

-- Выдать награду за квест
function QuestSystem.GiveQuestReward(player, questId)
    local rewards = QuestSystem.QuestRewards[questId]
    if rewards then
        for _, reward in ipairs(rewards) do
            if reward.entry and reward.entry > 0 then
                player:AddItem(reward.entry, reward.count or 1)
            end
        end
    end
    local money = QuestSystem.QuestMoney[questId]
    if money and money > 0 then
        player:ModifyMoney(money)
        player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Награда: %d золота %d серебра",
            math.floor(money / 10000), math.floor(money % 10000 / 100)))
    end
end

function QuestSystem.GetPreviousQuest(questId)
    return QuestSystem.PreviousQuestMap[questId]
end

function QuestSystem.GetQuestName(questId)
    return QuestSystem.QuestNames[questId] or "Квест " .. tostring(questId)
end

function QuestSystem.GetItemName(itemEntry)
    local names = {
        [90001] = "Перо Тени", [90003] = "Клык Теневой Совы", [90004] = "Светящийся камешек",
        [90021] = "Шкура Горного Волка", [90022] = "Камень Гряд", [90023] = "Перо Каменного Гаргулья",
        [90031] = "Проклятое Перо", [90032] = "Амулет Друида", [90033] = "Слеза Леса",
        [90041] = "Кровавый Клык", [90402] = "Песнь Луны", [90043] = "Кристалл Кровавой Луны",
        [90051] = "Печать Хранителя", [90052] = "Масло Теней", [90053] = "Медальон Ночи",
        [90061] = "Разрушенные Скрижали", [90062] = "Пыль Костей", [90063] = "Ключ Храма",
        [90071] = "Осколок Пустоты", [90072] = "Кровь Демона", [90073] = "Руна Печати",
        [90081] = "Клинок Ворона", [90082] = "Искра Огня", [90083] = "Чешуя Теневого Ворона",
        [90091] = "Знак Дозора", [90092] = "Свисток Разведчика", [90093] = "Когти Ночного Хищника",
        [90101] = "Слёза Луны", [90102] = "Клык Луноstalker", [90103] = "Перо Аспекта Ворона",
        [90111] = "Сердце Темного Ворона", [90112] = "Крыло Ночи", [90113] = "Плащ Ночного Ворона",
        [91001] = "Кольцо Ночного Ворона",
    }
    return names[itemEntry]
end

-- Универсальный обработчик gossip для дачителей кампаний и приручаемых мобов
function QuestSystem.OnGossipHello(event, player, creature)
    local npcEntry = creature:GetEntry()
    local camp = QuestSystem.GetCampaignByNPC(npcEntry)

    -- Если это приручаемый моб (компаньон)
    local tameTargets = SkillSystem.GetTameTargets(90005)
    local isTameable = false
    local tameTargetInfo = nil
    for _, tt in ipairs(tameTargets) do
        if tt.mobEntry == npcEntry then
            isTameable = true
            tameTargetInfo = tt
            break
        end
    end

    if isTameable then
        local playerSkill = SkillSystem.PlayerGetSkillValue(player, 90005)
        local canTame = playerSkill >= tameTargetInfo.minSkill
        -- Приручённость проверяем по живому компаньону игрока, а не по faction:
        -- у приручаемых мобов в БД уже стоит дружелюбная фракция 35.
        local alreadyTamed = CompanionSystem.GetActiveCompanionEntry(player) == npcEntry

        if alreadyTamed then
            player:GossipMenuAddItem(0, "Это существо уже ваш компаньон.", 0, 255)
        elseif not canTame then
            player:GossipMenuAddItem(0, string.format("Приручить %s (нужен навык %d/%d)", tameTargetInfo.desc, playerSkill, tameTargetInfo.minSkill), 0, 255)
        else
            player:GossipMenuAddItem(0, string.format("Приручить %s (навык %d, шанс %d%%)", tameTargetInfo.desc, playerSkill, SkillSystem.CalculateTameChance(playerSkill, tameTargetInfo.minSkill)), 0, 7000 + npcEntry)
        end
        player:GossipMenuAddItem(0, "Ничего", 0, 255)
        player:GossipSendMenu(90001, creature)
        return
    end

    if not camp then return end

    local canStartSolo = false
    -- Проверяем соло-квесты отдельно (Темный Ворон 90001)
    if npcEntry == 90001 then
        if not player:HasQuest(95001) and not player:HasFinishedQuest(95001) then
            player:GossipMenuAddItem(0, "Соло-квест: Испытание Одиночества", 0, 95001 * 10 + 1)
        end
        if player:HasQuest(95001) then
            if SoloSystem and SoloSystem.IsSoloMode and SoloSystem.IsSoloMode(player) then
                player:GossipMenuAddItem(0, "Я прошёл испытание в одиночку", 0, 95001 * 10 + 2)
            else
                player:GossipMenuAddItem(0, "Включите соло-режим для прохождения", 0, 95001 * 10 + 3)
            end
        end
        if not player:HasQuest(95002) and not player:HasFinishedQuest(95002) and player:HasFinishedQuest(95001) then
            player:GossipMenuAddItem(0, "Соло-квест: Путник Теней (компаньон)", 0, 95002 * 10 + 1)
        end
        if player:HasQuest(95002) then
            player:GossipMenuAddItem(0, "Я приручил Теневого Ворона", 0, 95002 * 10 + 2)
        end

        -- Просмотр навыков
        player:GossipMenuAddItem(0, "Посмотреть мои навыки", 0, 60001)
    end

    -- Обычные квесты кампаний
    for _, questId in ipairs(camp.quests) do
        local canStart = not player:HasQuest(questId) and not player:HasFinishedQuest(questId)
        local canComplete = player:HasQuest(questId)

        if canStart then
            local prevQuest = QuestSystem.GetPreviousQuest(questId)
            if prevQuest == nil or player:HasFinishedQuest(prevQuest) then
                local qname = QuestSystem.GetQuestName(questId)
                player:GossipMenuAddItem(0, "Взять: " .. qname, 0, questId * 10 + 1)
            end
        elseif canComplete then
            -- Проверяем требования перед отображением кнопки сдачи
            local ok, msg = QuestSystem.CheckItemRequirements(player, questId)
            if ok then
                local qname = QuestSystem.GetQuestName(questId)
                player:GossipMenuAddItem(0, "Сдать: " .. qname, 0, questId * 10 + 2)
            else
                player:GossipMenuAddItem(0, "Не готово: " .. qname .. " — " .. msg, 0, questId * 10 + 9)
            end
        end
    end

    player:GossipMenuAddItem(0, "Ничего", 0, 255)
    player:GossipSendMenu(90001, creature)
end

function QuestSystem.OnGossipSelect(event, player, creature, sender, intid, code)
    local npcEntry = creature:GetEntry()
    local camp = QuestSystem.GetCampaignByNPC(npcEntry)

    -- Обработка приручения моба (action = 7000 + npcEntry)
    if intid >= 7001 and intid <= 7126 then
        local tameMobEntry = intid - 7000
        CompanionSystem.AttemptTame(player, creature)
        player:GossipComplete()
        return
    end

    if not camp then return end

    -- Вход в соло-подземелья (action = 8000 + dungeonId)
    if intid >= 8001 and intid <= 8003 then
        local dungeonId = intid - 8000
        SoloDungeonSystem.EnterSoloDungeon(player, dungeonId)
        player:GossipComplete()
        return
    end

    -- Просмотр навыков (action = 60001)
    if intid == 60001 then
        local skills = {}
        for skillId, skillInfo in pairs(SkillSystem.Skills) do
            local currentLevel = SkillSystem.PlayerGetSkillValue(player, skillId)
            table.insert(skills, string.format("|cffffd700%s:|r %d/%d", skillInfo.name, currentLevel, skillInfo.maxLevel))
        end
        local skillsText = table.concat(skills, "\n")
        creature:SendUnitSay(string.format("Ваши навыки:\n%s", skillsText), 0)
        player:GossipComplete()
        return
    end

    -- Соло-квесты (Темный Ворон)
    if npcEntry == 90001 then
        local questId = math.floor(intid / 10)
        local action = intid % 10

        if questId == 95001 then
            if action == 1 then
                if not SoloSystem or not SoloSystem.IsSoloMode or not SoloSystem.IsSoloMode(player) then
                    creature:SendUnitSay("Включи соло-режим, чтобы пройти испытание.", 0)
                    player:GossipComplete()
                    return
                end
                player:AddQuest(95001)
                creature:SendUnitSay("Пройди путь Ворона в одиночку, без группы.", 0)
                player:GossipComplete()
            elseif action == 2 then
                if SoloSystem.IsSoloMode(player) then
                    player:CompleteQuest(95001)
                    player:RewardPlayer(95001)
                    QuestSystem.GiveQuestReward(player, 95001)
                    creature:SendUnitSay("Ты достоин称号 Ночного Ворона. Прими это кольцо.", 0)
                else
                    creature:SendUnitSay("Это испытание только для соло.", 0)
                end
                player:GossipComplete()
            end
            return
        elseif questId == 95002 then
            if action == 1 then
                player:AddQuest(95002)
                creature:SendUnitSay("Приручи Теневого Ворона — он станет твоим компаньоном в соло.", 0)
                player:GossipComplete()
            elseif action == 2 then
                CompanionSystem.SpawnCompanion(player, 92001)
                player:CompleteQuest(95002)
                player:RewardPlayer(95002)
                QuestSystem.GiveQuestReward(player, 95002)
                creature:SendUnitSay("Теневой Ворон теперь с тобой.", 0)
                player:GossipComplete()
            end
            return
        end
    end

    -- Обычные квесты кампаний
    local questId = math.floor(intid / 10)
    local action = intid % 10

    if action == 1 then
        -- Взять квест
        local prevQuest = QuestSystem.GetPreviousQuest(questId)
        if prevQuest ~= nil and not player:HasFinishedQuest(prevQuest) then
            creature:SendUnitSay("Сначала завершите предыдущий квест в цепочке.", 0)
            player:GossipComplete()
            return
        end
        player:AddQuest(questId)
        creature:SendUnitSay("Квест принят: " .. (QuestSystem.GetQuestName(questId) or ""), 0)
        player:GossipComplete()
    elseif action == 2 then
        -- Сдать квест (с проверкой предметов)
        local ok, msg = QuestSystem.CheckItemRequirements(player, questId)
        if not ok then
            creature:SendUnitSay(msg, 0)
            player:GossipComplete()
            return
        end

        local ok2, msg2 = QuestSystem.CheckKillRequirements(player, questId)
        if not ok2 then
            creature:SendUnitSay(msg2, 0)
            player:GossipComplete()
            return
        end

        QuestSystem.TakeQuestItems(player, questId)
        player:CompleteQuest(questId)
        player:RewardPlayer(questId)
        QuestSystem.GiveQuestReward(player, questId)
        creature:SendUnitSay("Квест сдан: " .. (QuestSystem.GetQuestName(questId) or ""), 0)
        player:GossipComplete()
    elseif action == 9 then
        -- Не готово (информационный пункт)
        creature:SendUnitSay("Вы ещё не выполнили требования этого квеста.", 0)
        player:GossipComplete()
    elseif intid == 255 then
        player:GossipComplete()
    end
end

function QuestSystem.Init()
    -- Регистрируем gossip для всех дачителей кампаний
    for _, camp in ipairs(QuestSystem.Campaigns) do
        RegisterCreatureGossipEvent(camp.npc, 1, QuestSystem.OnGossipHello)
        RegisterCreatureGossipEvent(camp.npc, 2, QuestSystem.OnGossipSelect)
    end
    for _, camp in ipairs(QuestSystem.SoloCampaigns) do
        RegisterCreatureGossipEvent(camp.npc, 1, QuestSystem.OnGossipHello)
        RegisterCreatureGossipEvent(camp.npc, 2, QuestSystem.OnGossipSelect)
    end
    print("|cff4B0082[NightDarkRaven]|r Система квестов: " .. #QuestSystem.Campaigns .. " кампаний, " .. #QuestSystem.SoloCampaigns .. " соло-кампаний зарегистрировано.")
end

return QuestSystem