-- ============================================================================
-- Ночь темного Ворона — Система навыков (профессий)
-- Добавляет кастомные навыки под сеттинг фэнтези
-- ============================================================================

local SkillSystem = {}

-- Навыки модуля (skill id, name, max level)
SkillSystem.Skills = {
    [90001] = {name = "Ковка Теней", maxLevel = 375, description = "Ковка оружия и брони из теневого железа."},
    [90002] = {name = "Извлечение Перьев", maxLevel = 375, description = "Извлечение перьев из магических птиц."},
    [90003] = {name = "Зелья Ночи", maxLevel = 375, description = "Варка зелий под светом Луны."},
    [90004] = {name = "Чтение Рун", maxLevel = 375, description = "Чтение и gravaция древних рун."},
    [90005] = {name = "Приручение Теней", maxLevel = 375, description = "Приручение теневых зверей."},
}

-- Рецепты навыков (skill id, item required, item created, level required)
SkillSystem.Recipes = {
    [90001] = { -- Ковка Теней
        {itemIn = 90083, itemOut = 90081, level = 300}, -- Чешуя Теневого Ворона -> Клинок Ворона
    },
    [90002] = { -- Извлечение Перьев
        {itemIn = 90001, itemOut = 90001, level = 1}, -- Перо Тени
    },
    [90003] = { -- Зелья Ночи
        {itemIn = 90101, itemOut = 90101, level = 200}, -- Слёза Луны
    },
    [90004] = { -- Чтение Рун
        {itemIn = 90073, itemOut = 90073, level = 250}, -- Руна Печати
    },
    [90005] = { -- Приручение Теней
        {itemIn = 90093, itemOut = 90093, level = 150}, -- Когти Ночного Хищника
    },
}

function SkillSystem.GetSkillInfo(skillId)
    return SkillSystem.Skills[skillId]
end

function SkillSystem.GetRecipes(skillId)
    return SkillSystem.Recipes[skillId] or {}
end

function SkillSystem.Init()
    local count = 0
    for _ in pairs(SkillSystem.Skills) do count = count + 1 end
    print("|cff4B0082[NightDarkRaven]|r Система навыков: " .. count .. " профессий зарегистрировано.")
end

-- Помощник: проверить, знает ли игрок навык (заглушка для AzerothCore Lua API)
function SkillSystem.PlayerKnowsSkill(player, skillId)
    -- В AzerothCore Eluna есть HasSkill/GetSkillValue, если доступны
    if player.HasSkill then
        return player:HasSkill(skillId)
    end
    return false
end

-- Помощник: получить уровень навыка игрока
function SkillSystem.PlayerGetSkillValue(player, skillId)
    if player.GetSkillValue then
        return player:GetSkillValue(skillId) or 0
    end
    return 0
end

return SkillSystem