-- ============================================================================
-- Ночь темного Ворона — Система компаньонов для соло-игроков
-- Призывает NPC-спутника, который помогает в бою и квестах
-- Включает приручение через навык "Приручение Теней" (skill 90005)
-- ============================================================================

local CompanionSystem = {}
local SkillSystem = require("NightDarkRaven.systems.skill_system")
local SoloSystem = require("NightDarkRaven.systems.solo_system")

-- Доступные компаньоны (entry, название, модель, роль, требование к навыку приручения)
CompanionSystem.Available = {
    [92001] = {name = "Теневой Врон", entry = 92001, model = 15678, role = "damage", desc = "Летающий компаньон, наносит урон тенью.", minTameSkill = 50},
    [92002] = {name = "Страж Ночи", entry = 92002, model = 23456, role = "tank", desc = "Тяжело сражающийся страж, притягивает на себя урон.", minTameSkill = 150},
    [92003] = {name = "Целитель Лунный", entry = 92003, model = 34567, role = "healer", desc = "Излечивает соло-игрока в бою.", minTameSkill = 250},
}

-- Активные компаньоны игроков: [playerGUID] = companionCreature
CompanionSystem.Active = {}

-- Выдать entry активного компаньона игрока (nil, если компаньона нет)
function CompanionSystem.GetActiveCompanionEntry(player)
    local guid = player:GetGUIDLow()
    local comp = CompanionSystem.Active[guid]
    if comp and comp:IsInWorld() then
        return comp:GetEntry()
    end
    return nil
end

-- Призвать компаньона (через навык приручения или квест)
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
    if SoloSystem.SoloPlayers[guid] then
        SoloSystem.SoloPlayers[guid].companion = nil
    end

    local info = CompanionSystem.Available[companionEntry]
    if not info then
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Неизвестный компаньон.")
        return false
    end

    local x, y, z, o = player:GetX(), player:GetY(), player:GetZ(), player:GetO()
    -- Временный спавн с таймером 0 = без автодеспавна (убираем вручную/DismissCompanion)
    local comp = player:SpawnCreature(companionEntry, x + 2, y, z, o, 1, 0, 0, 0)
    if comp then
        comp:SetFaction(35) -- дружелюбная фракция
        comp:SetLevel(player:GetLevel())
        comp:SetMaxHealth(CompanionSystem.CalcCompanionHealth(player))
        comp:SetHealth(comp:GetMaxHealth())
        -- Компаньон следует за владельцем
        comp:SetStandState(0)

        CompanionSystem.Active[guid] = comp
        SoloSystem.SoloPlayers[guid] = SoloSystem.SoloPlayers[guid] or {}
        SoloSystem.SoloPlayers[guid].companion = comp:GetGUIDLow()

        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Компаньон призван: " .. info.name .. ".")
        comp:SendUnitSay("Я с тобой, герой Ночи.", 0)
        return true
    end
    return false
end

-- Здоровье компаньона: 40% от максимального здоровья владельца, не меньше 100
function CompanionSystem.CalcCompanionHealth(player)
    local hp = math.floor(player:GetMaxHealth() * 0.4)
    return math.max(hp, 100)
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
        return true
    end
    return false
end

-- Попытка приручить моба (через gossip или целевое взаимодействие)
function CompanionSystem.AttemptTame(player, targetCreature)
    if not targetCreature or not targetCreature:IsCreature() then
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Это не существо.")
        return false
    end

    local mobEntry = targetCreature:GetEntry()
    local tameTargets = SkillSystem.GetTameTargets(90005)

    -- Находим цель в списке приручаемых
    local tameTarget = nil
    for _, tt in ipairs(tameTargets) do
        if tt.mobEntry == mobEntry then
            tameTarget = tt
            break
        end
    end

    if not tameTarget then
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Это существо нельзя приручить.")
        return false
    end

    -- Проверяем навык приручения
    local playerSkill = SkillSystem.PlayerGetSkillValue(player, 90005)
    if playerSkill < tameTarget.minSkill then
        player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Недостаточно навыка Приручения Теней: %d/%d.", playerSkill, tameTarget.minSkill))
        return false
    end

    -- Уже приручен этим или другим игроком (по живому компаньону, не по faction)
    if CompanionSystem.GetActiveCompanionEntry(player) == mobEntry or CompanionSystem.IsTamedByAnyone(mobEntry) then
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Это существо уже приручено.")
        return false
    end

    -- Вычисляем шанс успеха
    local chance = SkillSystem.CalculateTameChance(playerSkill, tameTarget.minSkill)
    local roll = math.random(1, 100)

    if roll <= chance then
        -- Успех: приручаем
        targetCreature:SetFaction(35) -- дружелюбная фракция
        targetCreature:SetLevel(player:GetLevel())
        targetCreature:SetMaxHealth(CompanionSystem.CalcCompanionHealth(player))
        targetCreature:SetHealth(targetCreature:GetMaxHealth())

        local guid = player:GetGUIDLow()
        -- Прежний компаньон уходит, новый занимает его место
        if CompanionSystem.Active[guid] then
            local old = CompanionSystem.Active[guid]
            if old and old ~= targetCreature and old:IsInWorld() then
                old:Despawn(0, 0)
            end
        end
        CompanionSystem.Active[guid] = targetCreature
        SoloSystem.SoloPlayers[guid] = SoloSystem.SoloPlayers[guid] or {}
        SoloSystem.SoloPlayers[guid].companion = targetCreature:GetGUIDLow()

        -- Повышаем навык
        local newSkill = SkillSystem.PlayerSkillUp(player, 90005, 5)

        player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Вы приручили %s! Навык Приручения Теней повышен (%d).", tameTarget.desc, newSkill))
        targetCreature:SendUnitSay("Я теперь твой спутник.", 0)
        return true
    else
        -- Неудача: моб становится враждебным
        targetCreature:SetFaction(14) -- враждебная
        targetCreature:Attack(player)

        -- Небольшой шанс повысить навык даже при неудаче (если навык близок к минимуму)
        if playerSkill >= tameTarget.minSkill - 25 then
            SkillSystem.PlayerSkillUp(player, 90005, 1)
        end

        player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Приручение не удалось (%d%%). %s атакует!", chance, tameTarget.desc))
        return false
    end
end

-- Лечение компаньоном игрока (раз в 5 секунд в бою)
local function CompanionHealTick(event, comp)
    if not comp or not comp:IsInWorld() then return end

    local owner = CompanionSystem.GetOwner(comp)
    if not owner then return end
    if not SoloSystem.IsSoloMode(owner) then return end
    if comp:GetEntry() ~= CompanionSystem.HEALER_ENTRY then return end

    local missingHP = owner:GetMaxHealth() - owner:GetHealth()
    if missingHP > 0 then
        local heal = math.min(math.floor(owner:GetMaxHealth() * 0.05), missingHP) -- 5% макс HP
        owner:SetHealth(owner:GetHealth() + heal)
        if owner:GetHealth() > owner:GetMaxHealth() then
            owner:SetHealth(owner:GetMaxHealth())
        end
        owner:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Целитель Лунный исцеляет вас (" .. heal .. " HP).")
    end
end

CompanionSystem.HEALER_ENTRY = 92003

-- Найти владельца по объекту компаньона
function CompanionSystem.GetOwner(comp)
    local compGuid = comp:GetGUIDLow()
    for playerGuid, activeComp in pairs(CompanionSystem.Active) do
        if activeComp == comp then
            return GetPlayerByGUID and GetPlayerByGUID(playerGuid) or nil
        end
    end
    return nil
end

-- Компаньон приручён кем-то (есть в активных у любого игрока)
function CompanionSystem.IsTamedByAnyone(mobEntry)
    for _, comp in pairs(CompanionSystem.Active) do
        if comp and comp:IsInWorld() and comp:GetEntry() == mobEntry then
            return true
        end
    end
    return false
end

-- Отозвать компаньона при выходе игрока, чтобы не висел в мире
local function OnPlayerLogout(event, player)
    CompanionSystem.DismissCompanion(player)
end

function CompanionSystem.Init()
    -- Регистрируем хил-тик целителя (каждые 5000 мс)
    if CreateLuaEvent then
        CreateLuaEvent(function()
            for _, comp in pairs(CompanionSystem.Active) do
                CompanionHealTick(nil, comp)
            end
        end, 5000, 0)
    end

    RegisterPlayerEvent(4, OnPlayerLogout) -- PLAYER_EVENT_ON_LOGOUT

    local count = 0
    for _ in pairs(CompanionSystem.Available) do count = count + 1 end
    print("|cff4B0082[NightDarkRaven]|r Система компаньонов загружена (компаньоны: " .. count .. ").")
end

return CompanionSystem