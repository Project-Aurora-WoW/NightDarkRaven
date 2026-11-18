#include "NightDarkRaven.h"
#include "ScriptMgr.h"
#include "Chat.h"

bool npc_dark_raven::OnGossipHello(Player* player, Creature* creature)
{
    // Приветствие
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_CHAT, "Приветствую, странник...", GOSSIP_SENDER_MAIN, GOSSIP_ACTION_WELCOME);
    // О мире
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_CHAT, "Расскажи о мире Ночь Темного Ворона", GOSSIP_SENDER_MAIN, GOSSIP_ACTION_WORLD_INFO);
    // Прощание
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_CHAT, "Прощай", GOSSIP_SENDER_MAIN, GOSSIP_ACTION_GOODBYE);

    player->SEND_GOSSIP_MENU(GOSSIP_TEXT_WELCOME, creature->GetGUID());
    return true;
}

bool npc_dark_raven::OnGossipSelect(Player* player, Creature* creature, uint32 /*sender*/, uint32 action)
{
    player->PlayerTalkClass->ClearMenus();

    switch (action)
    {
    case GOSSIP_ACTION_WELCOME:
        player->SEND_GOSSIP_MENU(GOSSIP_TEXT_WELCOME, creature->GetGUID());
        break;
    case GOSSIP_ACTION_WORLD_INFO:
        player->SEND_GOSSIP_MENU(GOSSIP_TEXT_WORLD, creature->GetGUID());
        break;
    case GOSSIP_ACTION_GOODBYE:
        player->CLOSE_GOSSIP_MENU();
        creature->Say("Пусть крылья Ворона оградят тебя в ночи...", LANG_UNIVERSAL, 0);
        break;
    default:
        break;
    }

    return true;
}

void npc_dark_raven::RegisterGossip()
{
    // Регистрация происходит автоматически через AddSC
}

void AddSC_night_dark_raven()
{
    new npc_dark_raven();
}