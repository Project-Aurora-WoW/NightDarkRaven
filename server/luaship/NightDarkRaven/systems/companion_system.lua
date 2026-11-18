-- ============================================================================
-- Ночь темного Ворона — Система компаньонов для соло-игроков
-- Призывает NPC-спутника, который помогает в бою и квестах
-- ============================================================================

local CompanionSystem = {}

-- Доступные компаньоны (entry, название, модель, роль)
CompanionSystem.Available = {
    [92001] = {name = "Теневой Ворон", entry = 92001, model = 15678, role = "damage", desc = "Летающий компаньон, наносит урон тенью."},
    [92002] = {name = "Страж Ночи", entry = 92002, model = 23456, role = "tank", desc = "Тяжело сражающийся страж, притягивает на себя урон."},
    [92003] = {name = "Целитель Лунный", entry = 92003, model = 34567, role = "healer", desc = "Излечивает соло-игрока в бою."},
}

-- Активные компаньоны игроков: [playerGUID] = companionCreature
CompanionSystem.Active = {}

-- Призвать компаньона
function CompanionSystem.SpawnCompanion(player, companionEntry)
    local guid = player:GetGUIDLow()

    -- Удаляем старого компаньона если есть
    if CompanionSystem.Active[guid] then
        local old = CompanionSystem.Active[guid]
        if old and old:IsInWorld() then
            old:Despawn(0, 0)
        end
        CompanionSystem.Active[guid] = nil
    end

    local info = CompanionSystem.Available[companionEntry]
    if not info then
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Неизвестный компаньон.")
        return
    end

    local x, y, z, o = player:GetX(), player:GetY(), player:GetZ(), player:GetO()
    local comp = player:SpawnCreature(companionEntry, x + 2, y, z, o, 1, 0, 0, 0) -- временный спавн
    if comp then
        comp:SetFaction(35) -- дружелюбная фракция
        comp:SetLevel(player:GetLevel())
        -- Масштабируем статы компаньона под игрока
        local hp = player:GetMaxHealth() * 0.4
        comp:SetMaxHealth(math.floor(hp))
        comp:SetHealth(comp:GetMaxHealth())

        CompanionSystem.Active[guid] = comp
        SoloSystem.SoloPlayers[guid] = SoloSystem.SoloPlayers[guid] or {}
        SoloSystem.SoloPlayers[guid].companion = comp:GetGUIDLow()

        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Компаньон призывает: " .. info.name .. ".")
        comp:SendUnitSay("Я с тобой, герой Ночи.", 0)
    end
end

-- Отозвать компаньона
function CompanionSystem.DismissCompanion(player)
    local guid = player:GetGUIDLow()
    if CompanionSystem.Active[guid] then
        local comp = CompanionSystem.Active[guid]
        if comp and comp:IsInWorld() then
            comp:Despawn(0, 0)
        end
        CompanionSystem.Active[guid] = nil
        if SoloSystem.SoloPlayers[guid] then
            SoloSystem.SoloPlayers[guid].companion = nil
        end
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Компаньон отозван.")
    end
end

-- Лечение компаньоном игрока (раз в 5 секунд в бою)
local function CompanionHealTick(event, comp)
    -- Находим владельца поблизости
    local players = comp:GetPlayersInRange(30)
    if not players or #players == 0 then return end

    local owner = players[1]
    if owner and SoloSystem.IsSoloMode(owner) then
        local missingHP = owner:GetMaxHealth() - owner:GetHealth()
        if missingHP > 0 then
            local heal = math.floor(owner:GetMaxHealth() * 0.05) -- 5% макс HP
            owner:SetHealth(owner:GetHealth() + heal)
            if owner:GetHealth() > owner:GetMaxHealth() then
                owner:SetHealth(owner:GetMaxHealth())
            end
            owner:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Целитель Лунный исцеляет вас (" .. heal .. " HP).")
        end
    end
end

-- Регистрация тика лечения для целевых компаньонов
-- В реальной сборке Eluna это делается через RegisterCreatureEvent с типом periodic update
function CompanionSystem.Init()
    print("|cff4B0082[NightDarkRaven]|r Система компаньонов загружена (компаньоны: " .. table.getn(CompanionSystem.Available) .. ").")
end

return CompanionSystem