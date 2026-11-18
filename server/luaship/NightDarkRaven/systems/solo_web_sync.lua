-- ============================================================================
-- Ночь темного Ворона — Синхронизация соло-режима с веб-клиентом
-- Читает таблицу solo_state из БД world и применяет соло-режим в игре
-- ============================================================================

local SoloWebSync = {}

-- Интервал опроса БД (секунды)
local POLL_INTERVAL = 5.0

-- Состояние опроса
SoloWebSync._lastPoll = 0
SoloWebSync._processedGuids = {} -- [guid] = timestamp последней обработки

-- Функция применения соло-режима к игроку (вызывается из quest_system при gossip)
function SoloWebSync.ApplySoloMode(player, enable)
    local guid = player:GetGUIDLow()
    local accountId = 0

    if enable then
        SoloSystem.EnableSoloMode(player)
    else
        SoloSystem.DisableSoloMode(player)
    end

    -- Записываем в БД для веб-клиента
    -- В AzerothCore Eluna есть WorldDBQuery / CharDBQuery в зависимости от сборки
    local query
    if enable then
        query = string.format(
            "INSERT INTO solo_state (character_guid, account_id, solo_mode) VALUES (%d, %d, 1) ON DUPLICATE KEY UPDATE solo_mode = 1, updated_at = NOW()",
            guid, accountId or 0
        )
    else
        query = string.format(
            "INSERT INTO solo_state (character_guid, account_id, solo_mode) VALUES (%d, %d, 0) ON DUPLICATE KEY UPDATE solo_mode = 0, updated_at = NOW()",
            guid, accountId or 0
        )
    end

    if CharDBQuery then
        CharDBQuery(query)
    elseif WorldDBQuery then
        WorldDBQuery(query)
    end

    -- Лог
    local logQuery = string.format(
        "INSERT INTO solo_state_log (character_guid, account_id, solo_mode, changed_by) VALUES (%d, %d, %d, 'lua')",
        guid, accountId or 0, enable and 1 or 0
    )
    if CharDBQuery then CharDBQuery(logQuery) end
end

-- Проверка: нужно ли применить соло-режим при входе игрока в мир
function SoloWebSync.OnPlayerLogin(event, player)
    local guid = player:GetGUIDLow()
    local accountId = 0

    local query = string.format(
        "SELECT solo_mode, companion_entry FROM solo_state WHERE character_guid = %d LIMIT 1",
        guid
    )

    local result
    if CharDBQuery then
        result = CharDBQuery(query)
    elseif WorldDBQuery then
        result = WorldDBQuery(query)
    end

    if result then
        -- В некоторых сборках Eluna результат возвращается иначе
        local soloMode = result:GetUInt32(0) -- колонка solo_mode
        local companionEntry = result:GetUInt32(1) -- колонка companion_entry

        if soloMode == 1 then
            SoloSystem.EnableSoloMode(player)
            player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Соло-режим восстановлен из веб-клиента.")
        end

        if companionEntry and companionEntry > 0 then
            CompanionSystem.SpawnCompanion(player, companionEntry)
            player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Компаньон восстановлен.")
        end
    end
end

-- Фоновый опрос БД для обработки изменений из веб-клиента
-- Вызывается каждые POLL_INTERVAL секунд через RegisterServerEvent
function SoloWebSync.PollDatabase()
    SoloWebSync._lastPoll = SoloWebSync._lastPoll + 1 -- упрощённо, в реальности diff

    -- Получаем список персонажей с изменённым соло-режимом
    local query = "SELECT character_guid, solo_mode, companion_entry FROM solo_state WHERE updated_at > DATE_SUB(NOW(), INTERVAL 10 SECOND)"

    local result
    if CharDBQuery then
        result = CharDBQuery(query)
    elseif WorldDBQuery then
        result = WorldDBQuery(query)
    end

    if not result then return end

    -- В реальной сборке Eluna итерация по результатам зависит от API
    -- Здесь примерная логика:
    repeat
        local guid = result:GetUInt32(0)
        local soloMode = result:GetUInt32(1)
        local companionEntry = result:GetUInt32(2)

        -- Находим игрока в мире по GUID (упрощённо)
        -- В AzerothCore Eluna можно использовать GetPlayerByGUID если доступно
        local player = GetPlayerByGUID and GetPlayerByGUID(guid) or nil

        if player then
            if soloMode == 1 then
                SoloSystem.EnableSoloMode(player)
            else
                SoloSystem.DisableSoloMode(player)
            end

            if companionEntry and companionEntry > 0 then
                CompanionSystem.SpawnCompanion(player, companionEntry)
            end
        end
    until not result:NextRow()
end

-- Регистрация событий
RegisterPlayerEvent(3, SoloWebSync.OnPlayerLogin) -- PLAYER_EVENT_ON_LOGIN

-- Фоновый опрос (через серверное событие обновления)
local _pollCounter = 0
RegisterServerEvent(24, function() -- SERVER_EVENT_ON_UPDATE
    _pollCounter = _pollCounter + 1
    if _pollCounter >= POLL_INTERVAL then
        _pollCounter = 0
        SoloWebSync.PollDatabase()
    end
end)

function SoloWebSync.Init()
    print("[NightDarkRaven] Solo Web Sync загружен (опрос БД каждые " .. POLL_INTERVAL .. " сек).")
end

return SoloWebSync