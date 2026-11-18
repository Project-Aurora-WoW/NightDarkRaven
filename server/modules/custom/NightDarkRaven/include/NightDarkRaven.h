#pragma once

#include "ScriptMgr.h"
#include "CreatureScript.h"
#include "Player.h"
#include "Creature.h"

// Entry ID кастомного NPC "Темный Ворон"
#define NPC_DARK_RAVEN_ENTRY 90001

// Gossip action'ы
enum DarkRavenGossipActions
{
    GOSSIP_ACTION_WELCOME     = GOSSIP_ACTION_INFO_DEF + 1,
    GOSSIP_ACTION_WORLD_INFO  = GOSSIP_ACTION_INFO_DEF + 2,
    GOSSIP_ACTION_GOODBYE     = GOSSIP_ACTION_INFO_DEF + 3
};

// Тексты gossip-меню (заводятся в БД в gossip_menu_text)
#define GOSSIP_TEXT_WELCOME   90001
#define GOSSIP_TEXT_WORLD     90002

class npc_dark_raven : public CreatureScript
{
public:
    npc_dark_raven() : CreatureScript("npc_dark_raven") { }

    bool OnGossipHello(Player* player, Creature* creature) override;
    bool OnGossipSelect(Player* player, Creature* creature, uint32 sender, uint32 action) override;

    void RegisterGossip();
};

void AddSC_night_dark_raven();