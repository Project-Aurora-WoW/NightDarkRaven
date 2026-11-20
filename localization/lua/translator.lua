-- ============================================================================
-- Ночь темного Ворона — Система локализации Lua / Eluna
-- Поддерживает русский (ru-RU) и английский (en-US) языки
-- ============================================================================

local Translator = {}

-- Текущий язык (по умолчанию русский)
Translator.CurrentLang = "ru-RU"

-- Загруженные переводы
Translator.Strings = {}

-- Загрузить язык
function Translator.LoadLang(lang)
    local langFile = "NightDarkRaven.localization.lua." .. lang:gsub("-", "_")
    
    local status, strings = pcall(require, langFile)
    if status then
        Translator.Strings = strings
        Translator.CurrentLang = lang
        print("|cff4B0082[NightDarkRaven]|r Язык загружен: " .. lang)
        return true
    else
        print("|cffFF0000[NightDarkRaven]|r Ошибка загрузки языка: " .. lang .. " — " .. tostring(strings))
        return false
    end
end

-- Получить переведенную строку
-- L("key") или L("section.key")
function L(key)
    local sections = Translator.Strings
    
    -- Поддержка вложенных ключей: "section.key"
    if key:find("%.") then
        local parts = {}
        for part in key:gmatch("([^%.]+)") do
            table.insert(parts, part)
        end
        
        local current = sections
        for _, part in ipairs(parts) do
            if current and current[part] then
                current = current[part]
            else
                return key -- Возвращаем ключ если перевод не найден
            end
        end
        return current or key
    end
    
    return Translator.Strings[key] or key
end

-- Глобальная функция L для удобства
_G.L = L

-- Получить текущий язык
function Translator.GetCurrentLang()
    return Translator.CurrentLang
end

-- Переключить язык
function Translator.SwitchLang(lang)
    return Translator.LoadLang(lang)
end

return Translator