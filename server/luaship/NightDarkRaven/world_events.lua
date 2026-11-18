-- ============================================================================
-- Ночь темного Ворона — глобальные события мира
-- Lua / Eluna для AzerothCore (WoW 3.3.5a)
-- ============================================================================

local NIGHT_MESSAGE = "|cff4B0082[Ночь темного Ворона]|r "

-- Сообщение при входе в игру
local function OnPlayerLogin(event, player)
    local name = player:GetName()
    player:SendBroadcastMessage(NIGHT_MESSAGE .. "Добро пожаловать, " .. name .. ". Ночь только начинается...")
end

-- Сообщение при выходе из игры
local function OnPlayerLogout(event, player)
    local name = player:GetName()
    player:SendBroadcastMessage(NIGHT_MESSAGE .. name .. " покидает эти земли. Ворон наблюдает за тобой.")
end

-- Каждые 30 минут проверяем время игрового мира и объявляем "Ночь Ворона"
-- (игровое время: GetGameTime() возвращает часы, минуты)
local function OnUpdate(event, diff, pInstance)
    -- Этот хук вызывается часто, поэтому используем собственную задержку
    if not OnUpdate.lastCheck then
        OnUpdate.lastCheck = 0
    end
    OnUpdate.lastCheck = OnUpdate.lastCheck + diff

    if OnUpdate.lastCheck >= 1800000 then -- 30 минут в мс
        OnUpdate.lastCheck = 0

        local hour, minute = GetGameTime()
        -- Ночь в игровом мире (примерно с 20:00 до 06:00)
        if hour >= 20 or hour < 6 then
            local message = NIGHT_MESSAGE .. "Наступила Ночь темного Ворона. Будь осторожен..."
            SendWorldMessage(message)
        end
    end
end

-- Регистрация
RegisterPlayerEvent(3, OnPlayerLogin)   -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent(4, OnPlayerLogout)  -- PLAYER_EVENT_ON_LOGOUT

-- Ежесекундный тик для проверки времени (WorldUpdate)
RegisterServerEvent(24, OnUpdate)       -- SERVER_EVENT_ON_UPDATE (зависит от сборки Eluna)

print("[NightDarkRaven] Lua: world_events loaded.")