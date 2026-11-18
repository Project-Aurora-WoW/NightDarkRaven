-- ============================================================================
-- Ночь темного Ворона — Система квестов кампаний
-- Единый gossip-процессор для всех дачителей кампаний
-- ============================================================================

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

-- Подключаем кампании (каждый файл регистрирует自己的 gossip)
QuestSystem.LoadedCampaigns = {}

function QuestSystem.RegisterCampaign(campaignId, campaignData)
    QuestSystem.LoadedCampaigns[campaignId] = campaignData
end

function QuestSystem.GetCampaignByNPC(npcEntry)
    for _, camp in ipairs(QuestSystem.Campaigns) do
        if camp.npc == npcEntry then return camp end
    end
    return nil
end

-- Универсальный обработчик gossip для дачителей кампаний
function QuestSystem.OnGossipHello(event, player, creature)
    local npcEntry = creature:GetEntry()
    local camp = QuestSystem.GetCampaignByNPC(npcEntry)
    if not camp then return end

    -- Добавляем пункты для доступных квестов кампании
    for _, questId in ipairs(camp.quests) do
        local canStart = not player:HasQuest(questId) and not player:HasFinishedQuest(questId)
        local canComplete = player:HasQuest(questId)

        if canStart then
            -- Проверяем предварительное условие (прошлый квест в цепочке)
            local prevQuest = QuestSystem.GetPreviousQuest(questId)
            if prevQuest == nil or player:HasFinishedQuest(prevQuest) then
                local questName = QuestSystem.GetQuestName(questId) or "Квест " .. questId
                player:GossipMenuAddItem(0, "Взять: " .. questName, 0, questId * 10 + 1)
            end
        elseif canComplete then
            player:GossipMenuAddItem(0, "Сдать: " .. (QuestSystem.GetQuestName(questId) or "Квест " .. questId), 0, questId * 10 + 2)
        end
    end

    player:GossipMenuAddItem(0, "Ничего", 0, 255)
    player:GossipSendMenu(90001, creature)
end

function QuestSystem.OnGossipSelect(event, player, creature, sender, intid, code)
    local npcEntry = creature:GetEntry()
    local camp = QuestSystem.GetCampaignByNPC(npcEntry)
    if not camp then return end

    -- Декодируем: questId = floor(intid / 10), action = intid % 10 (1 = взять, 2 = сдать)
    local questId = math.floor(intid / 10)
    local action = intid % 10

    if action == 1 then
        -- Взять квест
        player:AddQuest(questId)
        creature:SendUnitSay("Квест принят: " .. (QuestSystem.GetQuestName(questId) or ""), 0)
        player:GossipComplete()
    elseif action == 2 then
        -- Сдать квест (упрощённо: считаем выполненным)
        player:CompleteQuest(questId)
        player:RewardPlayer(questId)
        creature:SendUnitSay("Квест сдан: " .. (QuestSystem.GetQuestName(questId) or ""), 0)
        player:GossipComplete()
    elseif intid == 255 then
        player:GossipComplete()
    end
end

function QuestSystem.GetPreviousQuest(questId)
    -- Возвращает предыдущий квест в цепочке, или nil если первый
    local chainMap = {
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
    }
    return chainMap[questId]
end

function QuestSystem.GetQuestName(questId)
    local names = {
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
    }
    return names[questId]
end

function QuestSystem.Init()
    -- Регистрируем gossip для всех дачителей кампаний
    for _, camp in ipairs(QuestSystem.Campaigns) do
        RegisterCreatureGossipEvent(camp.npc, 1, QuestSystem.OnGossipHello)
        RegisterCreatureGossipEvent(camp.npc, 2, QuestSystem.OnGossipSelect)
    end
    print("|cff4B0082[NightDarkRaven]|r Система квестов: " .. #QuestSystem.Campaigns .. " кампаний зарегистрировано.")
end

return QuestSystem