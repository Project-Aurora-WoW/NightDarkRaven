/*
 * Ночь темного Ворона — Lua мост для C++ функций
 * Позволяет Lua-скриптам управлять соло-режимом и навыками через C++ ядро
 *
 * Компилируется как часть ядра AzerothCore с включенным Eluna/Lua
 */

#include "ScriptMgr.h"
#include "Player.h"
#include "LuaEngine.h"

// Регистрируем функции для Lua
class NightRavenLuaBridge : public LuaEngine
{
public:
    // Включить соло-режим для игрока
    static int LuaSoloEnable(lua_State* L)
    {
        Player* player = GetPlayer(L, 1);
        if (!player)
            return 0;
        
        player->SetSoloModeEnabled(true);
        player->ApplySoloModifiers();
        
        // Сохранить в БД
        WorldDatabase.Execute("INSERT INTO solo_state (character_guid, account_id, solo_mode) VALUES (" 
            + std::to_string(player->GetGUIDLow()) + ", " 
            + std::to_string(player->GetSession()->GetAccountId()) + ", 1) "
            + "ON DUPLICATE KEY UPDATE solo_mode = 1");
        
        return 0;
    }
    
    // Выключить соло-режим для игрока
    static int LuaSoloDisable(lua_State* L)
    {
        Player* player = GetPlayer(L, 1);
        if (!player)
            return 0;
        
        player->SetSoloModeEnabled(false);
        
        // Сохранить в БД
        WorldDatabase.Execute("INSERT INTO solo_state (character_guid, account_id, solo_mode) VALUES (" 
            + std::to_string(player->GetGUIDLow()) + ", " 
            + std::to_string(player->GetSession()->GetAccountId()) + ", 0) "
            + "ON DUPLICATE KEY UPDATE solo_mode = 0");
        
        return 0;
    }
    
    // Проверить соло-режим
    static int LuaSoloIsEnabled(lua_State* L)
    {
        Player* player = GetPlayer(L, 1);
        if (!player)
        {
            lua_pushboolean(L, 0);
            return 1;
        }
        
        lua_pushboolean(L, player->IsSoloModeEnabled() ? 1 : 0);
        return 1;
    }
    
    // Получить значение навыка
    static int LuaGetSkillValue(lua_State* L)
    {
        Player* player = GetPlayer(L, 1);
        if (!player)
        {
            lua_pushinteger(L, 0);
            return 1;
        }
        
        uint32 skillId = (uint32)lua_tointeger(L, 2);
        uint32 value = player->GetNightRavenSkillValue(skillId);
        
        lua_pushinteger(L, value);
        return 1;
    }
    
    // Установить значение навыка
    static int LuaSetSkillValue(lua_State* L)
    {
        Player* player = GetPlayer(L, 1);
        if (!player)
            return 0;
        
        uint32 skillId = (uint32)lua_tointeger(L, 2);
        uint32 value = (uint32)lua_tointeger(L, 3);
        
        player->SetNightRavenSkillValue(skillId, value);
        
        return 0;
    }
    
    // Повысить навык
    static int LuaSkillUp(lua_State* L)
    {
        Player* player = GetPlayer(L, 1);
        if (!player)
            return 0;
        
        uint32 skillId = (uint32)lua_tointeger(L, 2);
        uint32 amount = (uint32)lua_tointeger(L, 3);
        
        player->NightRavenSkillUp(skillId, amount);
        
        return 0;
    }
    
    // Проверить навык
    static int LuaHasSkill(lua_State* L)
    {
        Player* player = GetPlayer(L, 1);
        if (!player)
        {
            lua_pushboolean(L, 0);
            return 1;
        }
        
        uint32 skillId = (uint32)lua_tointeger(L, 2);
        lua_pushboolean(L, player->HasNightRavenSkill(skillId) ? 1 : 0);
        return 1;
    }
    
    // Регистрация всех функций
    static void RegisterFunctions()
    {
        sLuaEngine->registerFunction("SoloEnable", LuaSoloEnable);
        sLuaEngine->registerFunction("SoloDisable", LuaSoloDisable);
        sLuaEngine->registerFunction("SoloIsEnabled", LuaSoloIsEnabled);
        sLuaEngine->registerFunction("GetNightRavenSkillValue", LuaGetSkillValue);
        sLuaEngine->registerFunction("SetNightRavenSkillValue", LuaSetSkillValue);
        sLuaEngine->registerFunction("NightRavenSkillUp", LuaSkillUp);
        sLuaEngine->registerFunction("HasNightRavenSkill", LuaHasSkill);
    }
};

// Авто-регистрация при загрузке модуля
class NightRavenLuaBridgeLoader
{
public:
    NightRavenLuaBridgeLoader()
    {
        NightRavenLuaBridge::RegisterFunctions();
        sLog->OutInfo(LOG_FILTER_SERVER_LOADING, "NightRaven Lua Bridge registered");
    }
};

static NightRavenLuaBridgeLoader g_nightRavenLuaBridgeLoader;