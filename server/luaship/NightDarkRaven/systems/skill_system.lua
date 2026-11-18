-- ============================================================================
-- Ночь темного Ворона — Система навыков (профессий)
-- Добавляет кастомные навыки под сеттинг фэнтези, включая Приручение Теней
-- ============================================================================

local SkillSystem = {}

-- Навыки модуля (skill id, name, max level, description)
SkillSystem.Skills = {
    [90001] = {name = "Ковка Теней", maxLevel = 375, description = "Ковка оружия и брони из теневого железа."},
    [90002] = {name = "Извлечение Перьев", maxLevel = 375, description = "Извлечение перьев из магических птиц."},
    [90003] = {name = "Зелья Ночи", maxLevel = 375, description = "Варка зелий под светом Луны."},
    [90004] = {name = "Чтение Рун", maxLevel = 375, description = "Чтение и gravaция древних рун."},
    [90005] = {name = "Приручение Теней", maxLevel = 375, description = "Приручение теневых зверей в качестве компаньонов."},
}

-- Рецепты навыков (skill id, список рецептов)
-- Каждый рецепт: {itemIn, itemOut, level, skillUpChance}
SkillSystem.Recipes = {
    [90001] = { -- Ковка Теней
        {itemIn = 90083, itemOut = 90081, level = 300, skillUpChance = 100}, -- Чешуя Теневого Ворона -> Клинок Ворона
    },
    [90002] = { -- Извлечение Перьев
        {itemIn = 90001, itemOut = 90001, level = 1, skillUpChance = 100}, -- Перо Тени
    },
    [90003] = { -- Зелья Ночи
        {itemIn = 90101, itemOut = 90101, level = 200, skillUpChance = 100}, -- Слёза Луны
    },
    [90004] = { -- Чтение Рун
        {itemIn = 90073, itemOut = 90073, level = 250, skillUpChance = 100}, -- Руна Печати
    },
    [90005] = { -- Приручение Теней
        -- Приручение мобов (не предметов, а существ). Здесь храним требования к уровню навыка для мобов.
        {mobEntry = 92001, minSkill = 50,  maxLevel = 20,  desc = "Теневой Ворон"},       -- Теневой Ворон (компаньон)
        {mobEntry = 92002, minSkill = 150, maxLevel = 40,  desc = "Страж Ночи"},         -- Страж Ночи (танк)
        {mobEntry = 92003, minSkill = 250, maxLevel = 60,  desc = "Целитель Лунный"},    -- Целитель Лунный (хил)
    },
}

-- Шанс успеха приручения в зависимости от разницы уровня навыка и минимума моба
-- skillDiff = playerSkill - mobMinSkill
local TAME_SUCCESS_CHANCES = {
    {minDiff = -50, chance = 10},   -- Навык на 50 ниже минимума — 10%
    {minDiff = -25, chance = 25},   -- Навык на 25 ниже — 25%
    {minDiff = 0,   chance = 50},   -- Равно минимуму — 50%
    {minDiff = 25,  chance = 75},   -- Навык на 25 выше — 75%
    {minDiff = 50,  chance = 90},   -- Навык на 50 выше — 90%
    {minDiff = 100, chance = 100},  -- Навык на 100 выше — 100%
}

function SkillSystem.GetSkillInfo(skillId)
    return SkillSystem.Skills[skillId]
end

function SkillSystem.GetRecipes(skillId)
    return SkillSystem.Recipes[skillId] or {}
end

function SkillSystem.GetTameTargets(skillId)
    if skillId ~= 90005 then return {} end
    return SkillSystem.Recipes[90005] or {}
end

function SkillSystem.Init()
    local count = 0
    for _ in pairs(SkillSystem.Skills) do count = count + 1 end
    print("|cff4B0082[NightDarkRaven]|r Система навыков: " .. count .. " профессий зарегистрировано.")
end

-- Помощник: проверить, знает ли игрок навык
function SkillSystem.PlayerKnowsSkill(player, skillId)
    -- Если загружен C++ модуль mod-nightdarkraven — используем постоянное хранение
    if NightDarkRaven and NightDarkRaven.HasSkill then
        return NightDarkRaven.HasSkill(player, skillId)
    end
    if player.HasSkill then
        return player:HasSkill(skillId)
    end
    -- Фоллбэк: виртуальное хранилище в памяти (теряется при рестарте сервера)
    return SkillSystem._virtualSkills[player:GetGUIDLow()] and SkillSystem._virtualSkills[player:GetGUIDLow()][skillId] == true
end

-- Помощник: получить уровень навыка игрока
function SkillSystem.PlayerGetSkillValue(player, skillId)
    if NightDarkRaven and NightDarkRaven.GetSkill then
        return NightDarkRaven.GetSkill(player, skillId) or 0
    end
    if player.GetSkillValue then
        return player:GetSkillValue(skillId) or 0
    end
    return SkillSystem._virtualSkills and SkillSystem._virtualSkills[player:GetGUIDLow()] and SkillSystem._virtualSkills[player:GetGUIDLow()][skillId] or 0
end

-- Помощник: установить уровень навыка игрока
function SkillSystem.PlayerSetSkillValue(player, skillId, value)
    if NightDarkRaven and NightDarkRaven.SetSkill then
        NightDarkRaven.SetSkill(player, skillId, value)
        return
    end
    if not SkillSystem._virtualSkills then SkillSystem._virtualSkills = {} end
    local guid = player:GetGUIDLow()
    if not SkillSystem._virtualSkills[guid] then SkillSystem._virtualSkills[guid] = {} end
    SkillSystem._virtualSkills[guid][skillId] = value
end

-- Помощник: увеличить навык (skill up)
function SkillSystem.PlayerSkillUp(player, skillId, amount)
    amount = amount or 1
    if NightDarkRaven and NightDarkRaven.SkillUp then
        return NightDarkRaven.SkillUp(player, skillId, amount) or 0
    end
    local current = SkillSystem.PlayerGetSkillValue(player, skillId)
    local max = SkillSystem.Skills[skillId] and SkillSystem.Skills[skillId].maxLevel or 375
    local newVal = math.min(current + amount, max)
    SkillSystem.PlayerSetSkillValue(player, skillId, newVal)
    return newVal
end

-- Вычислить шанс успеха приручения моба
function SkillSystem.CalculateTameChance(playerSkill, mobMinSkill)
    local diff = playerSkill - mobMinSkill
    local bestChance = 0
    for _, tier in ipairs(TAME_SUCCESS_CHANCES) do
        if diff >= tier.minDiff then
            bestChance = tier.chance
        end
    end
    return bestChance
end

function SkillSystem.Init()
    SkillSystem._virtualSkills = {}
    local count = 0
    for _ in pairs(SkillSystem.Skills) do count = count + 1 end
    print("|cff4B0082[NightDarkRaven]|r Система навыков: " .. count .. " профессий зарегистрировано (включая виртуальное хранение навыков).")
end

return SkillSystem