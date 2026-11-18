-- ============================================================================
-- Ночь темного Ворона — Уроки Иллидана (Lua / Eluna)
-- Система PvP и PvE обучения с наградами
-- ============================================================================

local IllidanLessons = {}

-- Прогресс уроков игроков: [playerGUID] = {pvp = {lesson1 = true, ...}, pve = {...}}
IllidanLessons.PlayerProgress = {}

-- Определение уроков
IllidanLessons.Lessons = {
    pvp = {
        [93001] = {name = "Урок 1: Стойкость ПвП", type = "pvp", duration = 300, target = 94004, reward = 95001},
        [93002] = {name = "Урок 2: Точность ПвП", type = "pvp", kills = 50, target = 94004, reward = 95002},
        [93003] = {name = "Урок 3: Мастерство ПвП", type = "pvp", combos = 1, target = 94004, reward = 0},
    },
    pve = {
        [93004] = {name = "Урок 4: Выживание в Рейде", type = "pve", duration = 600, target = 94005, reward = 95003},
        [93005] = {name = "Урок 5: Урон по Боссу", type = "pve", damage = 100000, target = 94005, reward = 95004},
        [93006] = {name = "Урок 6: Позиционирование", type = "pve", duration = 300, target = 94005, reward = 0},
    }
}

-- Начало урока (таймер или цель)
function IllidanLessons.StartLesson(player, questId)
    local guid = player:GetGUIDLow()
    if not IllidanLessons.PlayerProgress[guid] then
        IllidanLessons.PlayerProgress[guid] = {pvp = {}, pve = {}}
    end

    local lesson = IllidanLessons.Lessons.pvp[questId] or IllidanLessons.Lessons.pve[questId]
    if not lesson then
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Урок не найден.")
        return false
    end

    player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Урок начался: %s", lesson.name))

    if lesson.duration then
        -- Урок на время (стойкость, выживание, позиционирование)
        player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Длительность: %d секунд.", lesson.duration))
        -- В реальной реализации здесь будет событийный таймер
    elseif lesson.kills then
        -- Урок на количество убитий
        player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Цель: %d критических ударов.", lesson.kills))
    elseif lesson.damage then
        -- Урок на урон
        player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Цель: %d урона.", lesson.damage))
    elseif lesson.combos then
        -- Урок на комбинации
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Цель: выполнить комбинированную атаку.")
    end

    return true
end

-- Завершение урока
function IllidanLessons.CompleteLesson(player, questId)
    local guid = player:GetGUIDLow()
    local lesson = IllidanLessons.Lessons.pvp[questId] or IllidanLessons.Lessons.pve[questId]
    if not lesson then return false end

    local type = lesson.type
    if not IllidanLessons.PlayerProgress[guid] then
        IllidanLessons.PlayerProgress[guid] = {pvp = {}, pve = {}}
    end

    IllidanLessons.PlayerProgress[guid][type][questId] = true

    -- Выдача награды
    if lesson.reward and lesson.reward > 0 then
        player:AddItem(lesson.reward, 1)
        local itemName = "Награда"
        -- Здесь можно получить имя предмета из item_template
        player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Вы получили награду за урок: %s", lesson.name))
    end

    player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Урок завершен: %s", lesson.name))

    -- Проверка полного курса
    IllidanLessons.CheckFullCourse(player)

    return true
end

-- Проверка полного курса (все уроки ПвП и ПвЕ)
function IllidanLessons.CheckFullCourse(player)
    local guid = player:GetGUIDLow()
    if not IllidanLessons.PlayerProgress[guid] then return false end

    local pvpCount = 0
    local pveCount = 0
    for _ in pairs(IllidanLessons.Lessons.pvp) do pvpCount = pvpCount + 1 end
    for _ in pairs(IllidanLessons.Lessons.pve) do pveCount = pveCount + 1 end

    local pvpDone = 0
    local pveDone = 0
    for questId in pairs(IllidanLessons.PlayerProgress[guid].pvp or {}) do pvpDone = pvpDone + 1 end
    for questId in pairs(IllidanLessons.PlayerProgress[guid].pve or {}) do pveDone = pveDone + 1 end

    if pvpDone >= pvpCount and pveDone >= pveCount then
        -- Полный курс завершен
        if not player:HasFinishedQuest(93007) then
            player:AddQuest(93007)
            player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Вы завершили все уроки Иллидана! Поговорите с Иллиданом о финальной награде.")
        end
        return true
    end

    return false
end

-- Получить прогресс игрока
function IllidanLessons.GetProgress(player)
    local guid = player:GetGUIDLow()
    return IllidanLessons.PlayerProgress[guid] or {pvp = {}, pve = {}}
end

-- Обработка убийства цели урока (для подсчета критов и урона)
function IllidanLessons.OnCreatureKill(event, creature, victim)
    local entry = creature:GetEntry()
    if entry ~= 94004 and entry ~= 94005 then return end

    -- Находим игрока, убившего цель (упрощенно: ближайший игрок)
    local players = creature:GetPlayersInRange(30)
    if not players or #players == 0 then return end

    local player = players[1]
    local guid = player:GetGUIDLow()

    -- Проверяем активные уроки этого игрока
    local progress = IllidanLessons.PlayerProgress[guid]
    if not progress then return end

    -- Для ПвП урока точности (93002) — считаем критические удары
    -- Здесь в реальной реализации нужно отслеживать критические удары, а не просто убийства
    if progress.pvp[93002] == nil and player:HasQuest(93002) then
        -- Упрощенно: считаем убийство как прогресс
        IllidanLessons.PlayerProgress[guid].pvp[93002] = true
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Прогресс урока точности обновлен.")
    end
end

RegisterCreatureEvent(94004, 4, IllidanLessons.OnCreatureKill)
RegisterCreatureEvent(94005, 4, IllidanLessons.OnCreatureKill)

function IllidanLessons.Init()
    local pvpCount = 0
    local pveCount = 0
    for _ in pairs(IllidanLessons.Lessons.pvp) do pvpCount = pvpCount + 1 end
    for _ in pairs(IllidanLessons.Lessons.pve) do pveCount = pveCount + 1 end
    print("|cff4B0082[NightDarkRaven]|r Система Уроков Иллидана: " .. pvpCount .. " ПвП уроков, " .. pveCount .. " ПвЕ уроков.")
end

return IllidanLessons