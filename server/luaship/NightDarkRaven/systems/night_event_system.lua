-- ============================================================================
-- Ночь темного Ворона — Механика «Ночь Ворона» (Lua / Eluna)
-- Периодическое мировое событие: усиление мобов кампаний и бонус к наградам
-- Включается в игровое время с 20:00 до 06:00 и длится N минут
-- ============================================================================

local NightEvent = {}

local SoloSystem = require("NightDarkRaven.systems.solo_system")

-- Параметры события
NightEvent.Config = {
    startHour     = 20,   -- начало ночи (по часам игрового мира)
    endHour       = 6,    -- конец ночи (переход через полночь)
    mobHealthMult = 1.25, -- +25% здоровья мобов кампаний
    mobDamageMult = 1.20, -- +20% урона мобов кампаний
    rewardMult    = 1.50, -- +50% денег за сдачу квестов
    xpMult        = 1.15, -- +15% опыта
    announceEvery = 600,  -- напоминание раз в 10 минут
}

-- Мобы кампаний, на которых действует ночное усиление (entry -> true)
NightEvent.CampaignMobs = {
    [90011] = true, [90021] = true, [90022] = true, [90031] = true, [90041] = true,
    [90042] = true, [90061] = true, [90062] = true, [90071] = true, [90072] = true,
    [90082] = true, [90092] = true, [90111] = true, [90112] = true,
}

NightEvent.Active = false
NightEvent._lastAnnounce = 0

-- Проверка: сейчас ночь по игровому времени
function NightEvent.IsNightTime()
    if not GetGameTime then return false end
    local hour = GetGameTime()
    return hour >= NightEvent.Config.startHour or hour < NightEvent.Config.endHour
end

-- Усилить только что заспавненный моб кампании (вызывается из события спавна)
function NightEvent.ApplyToCreature(creature)
    if not NightEvent.Active then return false end
    if not creature or not creature:IsCreature() then return false end
    if not NightEvent.CampaignMobs[creature:GetEntry()] then return false end

    local baseHealth = creature:GetMaxHealth()
    local newHealth = math.floor(baseHealth * NightEvent.Config.mobHealthMult)
    creature:SetMaxHealth(newHealth)
    creature:SetHealth(newHealth)
    creature:SetDamage(creature:GetMinDamage() * NightEvent.Config.mobDamageMult,
                       creature:GetMaxDamage() * NightEvent.Config.mobDamageMult)
    return true
end

-- Множитель награды для сдачи квеста
function NightEvent.GetRewardMultiplier(player)
    if not NightEvent.Active then return 1.0 end
    local mult = NightEvent.Config.rewardMult
    -- Соло-игрокам ночная награда не урезается
    if SoloSystem and SoloSystem.IsSoloMode(player) then
        mult = mult + 0.10
    end
    return mult
end

-- Включить событие
function NightEvent.Start()
    if NightEvent.Active then return end
    NightEvent.Active = true
    NightEvent._lastAnnounce = 0

    if SendWorldMessage then
        SendWorldMessage("|cff4B0082[Ночь темного Ворона]|r Наступила Ночь Ворона: мобы кампаний стали сильнее, награды выросли.")
    end
    print("|cff4B0082[NightDarkRaven]|r Событие «Ночь Ворона» началось.")
end

-- Выключить событие
function NightEvent.Stop()
    if not NightEvent.Active then return end
    NightEvent.Active = false

    if SendWorldMessage then
        SendWorldMessage("|cff4B0082[Ночь темного Ворона]|r Ночь Ворона отступила. Мобы вернулись к обычной силе.")
    end
    print("|cff4B0082[NightDarkRaven]|r Событие «Ночь Ворона» завершилось.")
end

-- Периодическая проверка игрового времени
function NightEvent.Tick(diff)
    local isNight = NightEvent.IsNightTime()

    if isNight and not NightEvent.Active then
        NightEvent.Start()
    elseif not isNight and NightEvent.Active then
        NightEvent.Stop()
    end

    if NightEvent.Active then
        NightEvent._lastAnnounce = NightEvent._lastAnnounce + diff
        if NightEvent._lastAnnounce >= NightEvent.Config.announceEvery * 1000 then
            NightEvent._lastAnnounce = 0
            if SendWorldMessage then
                SendWorldMessage("|cff4B0082[Ночь темного Ворона]|r Ночь ещё держится. Сила Ворона растёт...")
            end
        end
    end
end

-- Усиливаем мобов кампаний при спавне
local function OnCreatureSpawn(event, creature)
    NightEvent.ApplyToCreature(creature)
end

-- Тик события: проверка игрового времени
local function OnServerUpdate(event, diff)
    NightEvent.Tick(diff or 1000)
end

function NightEvent.Init()
    RegisterServerEvent(24, OnServerUpdate) -- SERVER_EVENT_ON_UPDATE

    -- CREATURE_EVENT_ON_SPAWN = 5 в Eluna для AzerothCore wotlk.
    -- Если в вашей сборке ID отличается, задайте NightEvent.Config.spawnEventId.
    local spawnEventId = NightEvent.Config.spawnEventId or 5
    for entry in pairs(NightEvent.CampaignMobs) do
        RegisterCreatureEvent(entry, spawnEventId, OnCreatureSpawn)
    end

    -- Подхватываем уже заспавненных мобов
    for entry in pairs(NightEvent.CampaignMobs) do
        for _, creature in pairs(GetCreatureListWithEntryInGrid
            and { GetCreatureListWithEntryInGrid(entry, 500.0) } or {}) do
            NightEvent.ApplyToCreature(creature)
        end
    end

    print("|cff4B0082[NightDarkRaven]|r Механика «Ночь Ворона» загружена.")
end

return NightEvent
