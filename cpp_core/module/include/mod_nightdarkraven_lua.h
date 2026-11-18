#pragma once

#include "mod_nightdarkraven.h"

#ifdef ELUNA

#include "LuaEngine.h"

/*
 * Мост C++ → Lua (Eluna).
 * Публикует глобальную таблицу `NightDarkRaven` с функциями модуля.
 *
 * Регистрация выполняется через WorldScript::OnStartup, то есть уже после
 * того как Eluna создала состояние Lua и загрузила скрипты.
 */

namespace NightDarkRaven
{
    class LuaBridgeWorldScript : public WorldScript
    {
    public:
        LuaBridgeWorldScript();

        void OnStartup() override;
    };

    void RegisterLuaFunctions();
}

#endif
