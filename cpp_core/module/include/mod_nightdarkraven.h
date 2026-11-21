#pragma once

#include "ScriptMgr.h"
#include "Player.h"
#include "Creature.h"
#include "ChatCommand.h"

#include <map>
#include <string>

/*
 * Ночь темного Ворона — серверный модуль AzerothCore.
 * Навыки, соло-режим, стартовый набор, кампании и магазин наград.
 * Все изменения идут через модуль: ядро не патчится.
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

    // Чат-команды .ndr solo / .ndr kit / .ndr sync
    class CommandNightRavenScript : public CommandScript
    {
    public:
        CommandNightRavenScript();

        Acore::ChatCommands::ChatCommandTable GetCommands() const override;
    };

    // Фракционные дарители кампаний (Альянс 95001-95016, Орда 95101-95116)
    class QuestGiverNightRavenScript : public CreatureScript
    {
    public:
        QuestGiverNightRavenScript();

        bool OnGossipHello(Player* player, Creature* creature) override;
        bool OnGossipSelect(Player* player, Creature* creature, uint32 sender, uint32 action) override;
    };

    // Торговец наград (90099, 95016, 95116)
    class ShopNightRavenScript : public CreatureScript
    {
    public:
        ShopNightRavenScript();

        bool OnGossipHello(Player* player, Creature* creature) override;
        bool OnGossipSelect(Player* player, Creature* creature, uint32 sender, uint32 action) override;
    };

    // Стартовый набор персонажа (выдаётся один раз при первом входе)
    void GrantStartingKit(Player* player, bool notifyIfAlreadyGranted = false);

    // Синхронизация состояния с клиентским аддоном (протокол NDR|...)
    void SendSync(Player* player);
    void SendCampaignProgress(Player* player);
    void SendShop(Player* player);

    // Публичные функции для Lua-моста и GM-команд
    void SetSoloMode(Player* player, bool enable);
    bool IsSoloMode(Player* player);
    uint32 GetSkill(Player* player, uint32 skillId);
    void SetSkill(Player* player, uint32 skillId, uint32 value);
    uint32 SkillUp(Player* player, uint32 skillId, uint32 amount);
    bool HasSkill(Player* player, uint32 skillId);
}

void AddSC_night_dark_raven();
