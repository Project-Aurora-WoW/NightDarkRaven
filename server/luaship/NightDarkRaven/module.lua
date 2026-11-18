-- ============================================================================
-- Ночь темного Ворона — Основной модуль AzerothCore (Lua / Eluna)
-- Регистрирует все подсистемы: предметы, навыки, кампании, зоны, подземелья, соло
-- ============================================================================

NightDarkRaven = {}
NightDarkRaven.Version = "1.1.0"
NightDarkRaven.ModuleName = "NightDarkRaven"

-- Подсистемы (порядок важен: зависимости)
local ItemSystem   = require("NightDarkRaven.systems.item_system")
local SkillSystem  = require("NightDarkRaven.systems.skill_system")
local QuestSystem  = require("NightDarkRaven.systems.quest_system")
local ZoneSystem   = require("NightDarkRaven.systems.zone_system")
local DungeonSystem= require("NightDarkRaven.systems.dungeon_system")
local SoloSystem   = require("NightDarkRaven.systems.solo_system")
local CompanionSystem = require("NightDarkRaven.systems.companion_system")
local ScalingSystem= require("NightDarkRaven.systems.scaling_system")
local SoloDungeonSystem = require("NightDarkRaven.systems.solo_dungeon_system")
local SoloWebSync  = require("NightDarkRaven.systems.solo_web_sync")
local ClientPatchSystem = require("NightDarkRaven.systems.client_patch_system")
local ClientPatchLauncher = require("NightDarkRaven.systems.client_patch_launcher")

function NightDarkRaven.OnLoad()
    print("|cff4B0082[NightDarkRaven]|r Загрузка модуля v" .. NightDarkRaven.Version .. "...")

    ItemSystem.Init()
    SkillSystem.Init()
    QuestSystem.Init()
    ZoneSystem.Init()
    DungeonSystem.Init()
    SoloSystem.Init()
    CompanionSystem.Init()
    ScalingSystem.Init()
    SoloDungeonSystem.Init()
    SoloWebSync.Init()
    ClientPatchSystem.Init()
    ClientPatchLauncher.Init()
end

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