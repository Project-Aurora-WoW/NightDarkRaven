-- ============================================================================
-- Ночь темного Ворона — Основной модуль AzerothCore (Lua / Eluna)
-- Регистрирует все подсистемы: предметы, навыки, кампании, зоны, подземелья
-- ============================================================================

NightDarkRaven = {}
NightDarkRaven.Version = "1.0.0"
NightDarkRaven.ModuleName = "NightDarkRaven"

-- Подсистемы
local ItemSystem   = require("NightDarkRaven.systems.item_system")
local SkillSystem  = require("NightDarkRaven.systems.skill_system")
local QuestSystem  = require("NightDarkRaven.systems.quest_system")
local ZoneSystem   = require("NightDarkRaven.systems.zone_system")
local DungeonSystem= require("NightDarkRaven.systems.dungeon_system")

function NightDarkRaven.OnLoad()
    print("|cff4B0082[NightDarkRaven]|r Загрузка модуля v" .. NightDarkRaven.Version .. "...")

    ItemSystem.Init()
    SkillSystem.Init()
    QuestSystem.Init()
    ZoneSystem.Init()
    DungeonSystem.Init()

    print("|cff4B0082[NightDarkRaven]|r Модуль загружен успешно.")
end

function NightDarkRaven.OnUnload()
    print("|cff4B0082[NightDarkRaven]|r Выгрузка модуля.")
end

-- Регистрация событий загрузки сервера
RegisterServerEvent(24, function() -- SERVER_EVENT_ON_UPDATE (первый тик)
    if not NightDarkRaven._loaded then
        NightDarkRaven._loaded = true
        NightDarkRaven.OnLoad()
    end
end)

return NightDarkRaven