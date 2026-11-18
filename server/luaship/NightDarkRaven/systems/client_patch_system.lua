-- ============================================================================
-- Ночь темного Ворона — Система патчей клиента (Lua / Eluna)
-- Синхронизация патчей между сервером и клиентом WoW 3.3.5a через БД
-- ============================================================================

local ClientPatchSystem = {}

-- Кэш патчей
ClientPatchSystem._patchesCache = {}
ClientPatchSystem._cacheLoaded = false

-- Загрузить патчи из БД
function ClientPatchSystem.LoadPatches()
    if ClientPatchSystem._cacheLoaded then return end

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
-- Отправить патчи клиенту (через gossip или при входе в мир)
function ClientPatchSystem.SendPatchesToPlayer(player)
    local unapplied = ClientPatchSystem.GetUnappliedPatches()
    if #unapplied == 0 then return end

    local patchList = ""
    for _, patch in ipairs(unapplied) do
        patchList = patchList .. patch.name .. " (" .. patch.type .. "): " .. patch.content .. "\n"
    end

    player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Доступны патчи клиента:\n" .. patchList)
    player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Примените их через лаунчер или вручную.")
end

-- Отметить патч как применённый
function ClientPatchSystem.MarkPatchApplied(patchId)
    local query = string.format(
        "UPDATE client_patches SET is_applied = 1, applied_at = NOW() WHERE patch_id = %d",
        patchId
    )
    if WorldDBQuery then
        WorldDBQuery(query)
    elseif CharDBQuery then
        CharDBQuery(query)
    end

    -- Лог
    local logQuery = string.format(
        "INSERT INTO client_patch_log (patch_id, status, message) VALUES (%d, 'success', 'Применено через сервер')",
        patchId
    )
    if WorldDBQuery then
        WorldDBQuery(logQuery)
    end

    print("[NightDarkRaven] Патч #" .. patchId .. " отмечен как применённый.")
end

-- Регистрация: отправка патчей при входе игрока
function ClientPatchSystem.OnPlayerLogin(event, player)
    -- Отправляем список доступных патчей (опционально, можно отключить)
    -- ClientPatchSystem.SendPatchesToPlayer(player)
end

RegisterPlayerEvent(3, ClientPatchSystem.OnPlayerLogin) -- PLAYER_EVENT_ON_LOGIN

function ClientPatchSystem.Init()
    ClientPatchSystem.LoadPatches()
end

return ClientPatchSystem