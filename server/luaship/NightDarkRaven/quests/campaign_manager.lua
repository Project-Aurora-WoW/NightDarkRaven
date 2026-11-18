-- ============================================================================
-- Ночь темного Ворона — Менеджер кампаний (Lua / Eluna)
-- Загружает все 11 кампаний, квесты, мобы, предметы, лут
-- ============================================================================

local CAMPAIGN_MANAGER = {}

-- Список файлов кампаний (загружаются по порядку)
local CAMPAIGN_FILES = {
    "quests/campaign_01_awakening.lua",
    "quests/campaign_02_shadows.lua",
    "quests/campaign_03_cursed_feathers.lua",
    "quests/campaign_04_blood_moon.lua",
    "quests/campaign_05_keepers.lua",
    "quests/campaign_06_forgotten_temple.lua",
    "quests/campaign_07_seal_of_darkness.lua",
    "quests/campaign_08_raven_blade.lua",
    "quests/campaign_09_night_watch.lua",
    "quests/campaign_10_raven_and_moon.lua",
    "quests/campaign_11_end_of_night.lua",
}

function CAMPAIGN_MANAGER.LoadAll()
    print("[NightDarkRaven] Загрузка кампаний...")
    for _, file in ipairs(CAMPAIGN_FILES) do
        local status, err = pcall(dofile, file)
        if status then
            print("[NightDarkRaven] Загружено: " .. file)
        else
            print("[NightDarkRaven] ОШИБКА загрузки " .. file .. ": " .. tostring(err))
        end
    end
    print("[NightDarkRaven] Все кампании загружены.")
end

-- Запуск при старте сервера
CAMPAIGN_MANAGER.LoadAll()

return CAMPAIGN_MANAGER