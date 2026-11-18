-- ============================================================================
-- Ночь темного Ворона — Система патчей клиента (Lua / Eluna)
-- Автоматическое применение патчей при входе игрока + синхронизация с веб-лаунчером
-- ============================================================================

local ClientPatchSystem = {}

-- Кэш патчей
ClientPatchSystem._patchesCache = {}
ClientPatchSystem._cacheLoaded = false
ClientPatchSystem._lastReload = 0

-- Загрузить патчи из БД
function ClientPatchSystem.LoadPatches(force)
    local now = os.time()
    if ClientPatchSystem._cacheLoaded and not force and (now - ClientPatchSystem._lastReload) < 60 then
        return
    end

    ClientPatchSystem._patchesCache = {}
    ClientPatchSystem._lastReload = now

    local query = "SELECT patch_id, patch_name, patch_type, target_file, target_path, content, checksum, is_required, is_applied FROM client_patches WHERE is_required = 1"

    local result
    if WorldDBQuery then
        result = WorldDBQuery(query)
    elseif CharDBQuery then
        result = CharDBQuery(query)
    end

    if result then
        repeat
            local patch = {
                id = result:GetUInt32(0),
                name = result:GetString(1),
                type = result:GetString(2),
                targetFile = result:GetString(3),
                targetPath = result:GetString(4),
                content = result:GetString(5),
                checksum = result:GetString(6),
                isRequired = result:GetUInt32(7) == 1,
                isApplied = result:GetUInt32(8) == 1
            }
            table.insert(ClientPatchSystem._patchesCache, patch)
        until not result:NextRow()
    end

    ClientPatchSystem._cacheLoaded = true
    print("[NightDarkRaven] Клиентские патчи загружены: " .. #ClientPatchSystem._patchesCache .. " шт.")
end

-- Получить список неприменённых патчей
function ClientPatchSystem.GetUnappliedPatches()
    ClientPatchSystem.LoadPatches()
    local unapplied = {}
    for _, patch in ipairs(ClientPatchSystem._patchesCache) do
        if not patch.isApplied then
            table.insert(unapplied, patch)
        end
    end
    return unapplied
end

-- Получить список неприменённых патчей в виде текста для игрока
function ClientPatchSystem.GetUnappliedPatchesText()
    local unapplied = ClientPatchSystem.GetUnappliedPatches()
    if #unapplied == 0 then
        return "Все патчи клиента применены."
    end

    local text = "|cff4B0082[Ночь темного Ворона]|r Доступны патчи клиента:\n"
    for i, patch in ipairs(unapplied) do
        text = text .. string.format("|cffffd700%d.|r %s (тип: %s, файл: %s)\n",
            i, patch.name, patch.type, patch.targetFile)
    end
    text = text .. "\n|cffffff00Примените патчи через веб-лаунчер или десктоп-лаунчер,|r"
    text = text .. " либо обратитесь к администратору сервера."
    return text
end

-- Отметить патч как применённый
function ClientPatchSystem.MarkPatchApplied(patchId, changedBy)
    changedBy = changedBy or "system"
    local query = string.format(
        "UPDATE client_patches SET is_applied = 1, applied_at = NOW() WHERE patch_id = %d",
        patchId
    )
    if WorldDBQuery then
        WorldDBQuery(query)
    elseif CharDBQuery then
        CharDBQuery(query)
    end

    local logQuery = string.format(
        "INSERT INTO client_patch_log (patch_id, status, message, changed_by) VALUES (%d, 'success', 'Применено автоматически', '%s')",
        patchId, changedBy
    )
    if WorldDBQuery then
        WorldDBQuery(logQuery)
    elseif CharDBQuery then
        CharDBQuery(logQuery)
    end

    -- Обновляем кэш
    for i, patch in ipairs(ClientPatchSystem._patchesCache) do
        if patch.id == patchId then
            ClientPatchSystem._patchesCache[i].isApplied = true
            break
        end
    end

    print("[NightDarkRaven] Патч #" .. patchId .. " отмечен как применённый (" .. changedBy .. ").")
end

-- Отправить патчи клиенту при входе в мир
function ClientPatchSystem.OnPlayerLogin(event, player)
    local unapplied = ClientPatchSystem.GetUnappliedPatches()
    if #unapplied == 0 then
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Все патчи клиента применены. Добро пожаловать!")
        return
    end

    player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Обнаружены новые патчи клиента:")
    for _, patch in ipairs(unapplied) do
        player:SendBroadcastMessage(string.format("|cffffd700-|r %s (%s): %s",
            patch.name, patch.type, patch.targetFile))
    end
    player:SendBroadcastMessage("|cffffff00Запустите лаунчер для автоматического применения патчей,|r")
    player:SendBroadcastMessage("|cffffff00либо обратитесь к администратору сервера.|r")
end

-- Автоматическое применение патча через GM-команду или gossip
function ClientPatchSystem.ApplyPatchByGM(player, patchId)
    local patch = nil
    for _, p in ipairs(ClientPatchSystem._patchesCache) do
        if p.id == patchId then
            patch = p
            break
        end
    end

    if not patch then
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Патч #" .. patchId .. " не найден.")
        return false
    end

    if patch.isApplied then
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Патч уже применён.")
        return true
    end

    ClientPatchSystem.MarkPatchApplied(patchId, "gm_" .. player:GetName())
    player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Патч '%s' применён.", patch.name))
    return true
end

-- Регистрация: отправка патчей при входе игрока
RegisterPlayerEvent(3, ClientPatchSystem.OnPlayerLogin) -- PLAYER_EVENT_ON_LOGIN

-- Перезагрузка кэша патчей по команде сервера (раз в 60 сек при необходимости)
local _patchReloadTimer = 0
RegisterServerEvent(24, function() -- SERVER_EVENT_ON_UPDATE
    _patchReloadTimer = _patchReloadTimer + 1
    if _patchReloadTimer >= 60 then
        _patchReloadTimer = 0
        ClientPatchSystem.LoadPatches(true) -- принудительная перезагрузка кэша
    end
end)

function ClientPatchSystem.Init()
    ClientPatchSystem.LoadPatches()
    print("[NightDarkRaven] Клиентская система патчей инициализирована.")
end

return ClientPatchSystem