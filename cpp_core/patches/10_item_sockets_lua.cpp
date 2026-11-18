/*
 * Ночь темного Ворона — Lua мост для сокетов предметов
 * Позволяет Lua-скриптам управлять сокетами через C++ ядро
 */

#include "ScriptMgr.h"
#include "Player.h"
#include "Item.h"
#include "LuaEngine.h"

class ItemSocketLuaBridge : public LuaEngine
{
public:
    // Вставить камень в сокет предмета
    static int LuaItemSocketGem(lua_State* L)
    {
        Player* player = GetPlayer(L, 1);
        if (!player) return 0;
        
        // В AzerothCore нужно получить Item по slot или guid
        uint8 bag = (uint8)lua_tointeger(L, 2);
        uint8 slot = (uint8)lua_tointeger(L, 3);
        uint32 gemEntry = (uint32)lua_tointeger(L, 4);
        
        Item* item = player->GetItemByPos(bag, slot);
        if (!item) return 0;
        
        bool success = item->SocketGem(slot, gemEntry);
        lua_pushboolean(L, success ? 1 : 0);
        return 1;
    }
    
    // Извлечь камень из сокета
    static int LuaItemUnsocketGem(lua_State* L)
    {
        Player* player = GetPlayer(L, 1);
        if (!player) return 0;
        
        uint8 bag = (uint8)lua_tointeger(L, 2);
        uint8 slot = (uint8)lua_tointeger(L, 3);
        
        Item* item = player->GetItemByPos(bag, slot);
        if (!item) return 0;
        
        bool success = item->UnsocketGem(slot);
        lua_pushboolean(L, success ? 1 : 0);
        return 1;
    }
    
    // Получить камень в сокете
    static int LuaItemGetSocketGem(lua_State* L)
    {
        Player* player = GetPlayer(L, 1);
        if (!player) { lua_pushinteger(L, 0); return 1; }
        
        uint8 bag = (uint8)lua_tointeger(L, 2);
        uint8 slot = (uint8)lua_tointeger(L, 3);
        
        Item* item = player->GetItemByPos(bag, slot);
        if (!item) { lua_pushinteger(L, 0); return 1; }
        
        lua_pushinteger(L, item->GetSocketGem(slot));
        return 1;
    }
    
    // Проверить есть ли сокет
    static int LuaItemHasSocket(lua_State* L)
    {
        Player* player = GetPlayer(L, 1);
        if (!player) { lua_pushboolean(L, 0); return 1; }
        
        uint8 bag = (uint8)lua_tointeger(L, 2);
        uint8 slot = (uint8)lua_tointeger(L, 3);
        
        Item* item = player->GetItemByPos(bag, slot);
        if (!item) { lua_pushboolean(L, 0); return 1; }
        
        lua_pushboolean(L, item->HasSocket(slot) ? 1 : 0);
        return 1;
    }
    
    static void RegisterFunctions()
    {
        sLuaEngine->registerFunction("ItemSocketGem", LuaItemSocketGem);
        sLuaEngine->registerFunction("ItemUnsocketGem", LuaItemUnsocketGem);
        sLuaEngine->registerFunction("ItemGetSocketGem", LuaItemGetSocketGem);
        sLuaEngine->registerFunction("ItemHasSocket", LuaItemHasSocket);
    }
};

class ItemSocketLuaLoader
{
public:
    ItemSocketLuaLoader()
    {
        ItemSocketLuaBridge::RegisterFunctions();
        sLog->OutInfo(LOG_FILTER_SERVER_LOADING, "Item Socket Lua Bridge registered");
    }
};

static ItemSocketLuaLoader g_itemSocketLuaLoader;