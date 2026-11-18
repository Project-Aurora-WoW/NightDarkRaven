#include "mod_nightdarkraven_lua.h"

#ifdef ELUNA

#include "Log.h"

namespace
{
    // Lua: NightDarkRaven.SetSoloMode(player, enable)
    int LuaSetSoloMode(lua_State* L)
    {
        Eluna* E = Eluna::GetEluna(L);
        Player* player = E->CHECKOBJ<Player>(1);
        bool enable = E->CHECKVAL<bool>(2);

        NightDarkRaven::SetSoloMode(player, enable);
        return 0;
    }

    // Lua: NightDarkRaven.IsSoloMode(player) -> bool
    int LuaIsSoloMode(lua_State* L)
    {
        Eluna* E = Eluna::GetEluna(L);
        Player* player = E->CHECKOBJ<Player>(1);

        lua_pushboolean(L, NightDarkRaven::IsSoloMode(player) ? 1 : 0);
        return 1;
    }

    // Lua: NightDarkRaven.GetSkill(player, skillId) -> int
    int LuaGetSkill(lua_State* L)
    {
        Eluna* E = Eluna::GetEluna(L);
        Player* player = E->CHECKOBJ<Player>(1);
        uint32 skillId = E->CHECKVAL<uint32>(2);

        lua_pushinteger(L, NightDarkRaven::GetSkill(player, skillId));
        return 1;
    }

    // Lua: NightDarkRaven.SetSkill(player, skillId, value)
    int LuaSetSkill(lua_State* L)
    {
        Eluna* E = Eluna::GetEluna(L);
        Player* player = E->CHECKOBJ<Player>(1);
        uint32 skillId = E->CHECKVAL<uint32>(2);
        uint32 value = E->CHECKVAL<uint32>(3);

        NightDarkRaven::SetSkill(player, skillId, value);
        return 0;
    }

    // Lua: NightDarkRaven.SkillUp(player, skillId, amount) -> int
    int LuaSkillUp(lua_State* L)
    {
        Eluna* E = Eluna::GetEluna(L);
        Player* player = E->CHECKOBJ<Player>(1);
        uint32 skillId = E->CHECKVAL<uint32>(2);
        uint32 amount = E->CHECKVAL<uint32>(3, 1);

        lua_pushinteger(L, NightDarkRaven::SkillUp(player, skillId, amount));
        return 1;
    }

    // Lua: NightDarkRaven.HasSkill(player, skillId) -> bool
    int LuaHasSkill(lua_State* L)
    {
        Eluna* E = Eluna::GetEluna(L);
        Player* player = E->CHECKOBJ<Player>(1);
        uint32 skillId = E->CHECKVAL<uint32>(2);

        lua_pushboolean(L, NightDarkRaven::HasSkill(player, skillId) ? 1 : 0);
        return 1;
    }

    const luaL_Reg NightDarkRavenFunctions[] =
    {
        { "SetSoloMode", LuaSetSoloMode },
        { "IsSoloMode",  LuaIsSoloMode  },
        { "GetSkill",    LuaGetSkill    },
        { "SetSkill",    LuaSetSkill    },
        { "SkillUp",     LuaSkillUp     },
        { "HasSkill",    LuaHasSkill    },
        { nullptr,       nullptr        },
    };
}

namespace NightDarkRaven
{
    LuaBridgeWorldScript::LuaBridgeWorldScript() : WorldScript("LuaBridgeWorldScript") { }

    void LuaBridgeWorldScript::OnStartup()
    {
        RegisterLuaFunctions();
    }

    void RegisterLuaFunctions()
    {
        Eluna* eluna = sElunaMgr->Get(ElunaInfo());
        if (!eluna || !eluna->HasLuaState())
        {
            LOG_INFO("server.loading", "[NightDarkRaven] Eluna is not available, C++ -> Lua bridge skipped");
            return;
        }

        lua_State* L = eluna->L;

        // merge в существующую таблицу, чтобы не затереть данные, созданные Lua-скриптами
        if (luaL_getmetatable(L, "NightDarkRaven") == LUA_TNIL)
        {
            lua_pop(L, 1);
            luaL_register(L, "NightDarkRaven", NightDarkRavenFunctions);
        }
        else
        {
            lua_pop(L, 1);
            lua_getglobal(L, "NightDarkRaven");
            if (!lua_istable(L, -1))
            {
                lua_pop(L, 1);
                lua_newtable(L);
            }
            luaL_register(L, nullptr, NightDarkRavenFunctions);
            lua_setglobal(L, "NightDarkRaven");
        }

        LOG_INFO("server.loading", "[NightDarkRaven] C++ -> Lua bridge registered (NightDarkRaven.*)");
    }

        lua_State* L = eluna->L;
        luaL_register(L, "NightDarkRaven", NightDarkRavenFunctions);
        lua_pop(L, 1);

        LOG_INFO("server.loading", "[NightDarkRaven] C++ -> Lua bridge registered (NightDarkRaven.*)");
    }
}

#endif
