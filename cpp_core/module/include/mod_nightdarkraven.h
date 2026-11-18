#pragma once

#include "ScriptMgr.h"
#include "Player.h"

#include <map>
#include <string>

/*
 * Ночь темного Ворона — серверный модуль AzerothCore.
 * Навыки, соло-режим и реестр компаньонов без правок ядра.
 */

namespace NightDarkRaven
{
    // Навыки модуля (90001-90005)
    bool IsCustomSkill(uint32 skillId);
    uint32 GetSkillMax(uint32 skillId);

    // Скрипты, публикующие функции для Lua (Eluna) через глобальную таблицу
    class PlayerNightRavenScript : public PlayerScript
    {
    public:
        PlayerNightRavenScript();

        void OnPlayerLogin(Player* player) override;
        void OnPlayerLogout(Player* player) override;
        void OnPlayerSave(Player* player) override;
    };

    class UnitNightRavenScript : public UnitScript
    {
    public:
        UnitNightRavenScript();

        void OnDamage(Unit* attacker, Unit* victim, uint32& damage) override;
    };

    // Применяет снижение здоровья к мобам рядом с соло-игроками
    class CreatureNightRavenScript : public AllCreatureScript
    {
    public:
        CreatureNightRavenScript();

        void OnCreatureAddWorld(Creature* creature) override;
    };

    class WorldNightRavenScript : public WorldScript
    {
    public:
        WorldNightRavenScript();

        void OnAfterConfigLoad(bool /*reload*/) override;
    };

    // Публичные функции для Lua-моста и GM-команд
    void SetSoloMode(Player* player, bool enable);
    bool IsSoloMode(Player* player);
    uint32 GetSkill(Player* player, uint32 skillId);
    void SetSkill(Player* player, uint32 skillId, uint32 value);
    uint32 SkillUp(Player* player, uint32 skillId, uint32 amount);
    bool HasSkill(Player* player, uint32 skillId);
}

void AddSC_night_dark_raven();
