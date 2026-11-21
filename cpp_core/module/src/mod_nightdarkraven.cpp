#include "mod_nightdarkraven.h"

#include "Chat.h"
#include "CommandScript.h"
#include "Config.h"
#include "DatabaseEnv.h"
#include "GossipDef.h"
#include "Item.h"
#include "Log.h"
#include "Timer.h"

#include <algorithm>
#include <set>
#include <vector>

namespace
{
    // Кэш навыков в памяти: кастомные навыки хранятся в characters.character_nightraven_skills
    std::map<ObjectGuid::LowType, std::map<uint32, uint32>> g_SkillCache;

    // Состояние соло-режима в памяти
    std::map<ObjectGuid::LowType, bool> g_SoloMode;

    float g_SoloHealthMultiplier = 0.60f;
    float g_SoloDamageMultiplier = 0.70f;

    bool g_EnableSoloMode = true;
    bool g_EnableCustomSkills = true;
    bool g_EnableStartingKit = true;

    inline ObjectGuid::LowType GetGuidLow(Player* player)
    {
        return player->GetGUID().GetCounter();
    }

    // Кампании: id -> список квестов (совпадает с клиентским аддоном)
    struct CampaignDef
    {
        uint32 id;
        std::vector<uint32> quests;
    };

    std::vector<CampaignDef> const g_Campaigns =
    {
        {  1, { 90101, 90102, 90103 } },
        {  2, { 90201, 90202, 90203, 92004 } },
        {  3, { 90301, 90302, 90303 } },
        {  4, { 90401, 90402, 90403, 90404 } },
        {  5, { 90501, 90502, 90503 } },
        {  6, { 90601, 90602, 90603, 90604 } },
        {  7, { 90701, 90702, 90703 } },
        {  8, { 90801, 90802, 90803, 90804 } },
        {  9, { 90901, 90902, 90903 } },
        { 10, { 91001, 91002, 91003, 91004 } },
        { 11, { 91101, 91102, 91103, 91104, 91105 } },
        { 12, { 92001, 92002, 92003, 92004 } },
        { 13, { 92005, 92006, 92007, 92008 } },
        { 14, { 92009, 92010, 92011, 92012 } },
        { 15, { 92013, 92014, 92015, 92016 } },
    };

    enum NightRavenGossipAction
    {
        ACTION_TELEPORT      = 1000,
        ACTION_SHOP          = 1001,
        ACTION_PROGRESS      = 1002,
        ACTION_SHOP_ITEM     = 100000, // action = ACTION_SHOP_ITEM + item_entry
    };

    bool IsAllianceNpc(uint32 entry)
    {
        return entry >= 95001 && entry <= 95016;
    }

    bool IsHordeNpc(uint32 entry)
    {
        return entry >= 95101 && entry <= 95116;
    }

    bool IsFactionNpc(uint32 entry)
    {
        return IsAllianceNpc(entry) || IsHordeNpc(entry);
    }

    bool IsShopNpc(uint32 entry)
    {
        return entry == 90099 || entry == 95016 || entry == 95116;
    }

    uint32 CampaignIndexForEntry(uint32 entry)
    {
        return IsHordeNpc(entry) ? entry - 95100 : entry - 95000;
    }

    void TeleportToFactionHub(Player* player, bool alliance)
    {
        if (!player)
            return;

        if (alliance)
            player->TeleportTo(0, -8895.0f, 520.0f, 96.5f, 0.5f);
        else
            player->TeleportTo(1, 1600.0f, -4400.0f, 8.6f, 0.7f);
    }
}

namespace NightDarkRaven
{
    bool IsCustomSkill(uint32 skillId)
    {
        return skillId >= 90001 && skillId <= 90005;
    }

    uint32 GetSkillMax(uint32 skillId)
    {
        // Совпадает с SkillSystem.Skills в Lua
        return IsCustomSkill(skillId) ? 375 : 0;
    }

    PlayerNightRavenScript::PlayerNightRavenScript() : PlayerScript("PlayerNightRavenScript") { }

    void PlayerNightRavenScript::OnPlayerLogin(Player* player)
    {
        if (!player || !g_EnableSoloMode)
            return;

        ObjectGuid::LowType guid = GetGuidLow(player);
        g_SoloMode[guid] = false;
        g_SkillCache[guid].clear();

        if (QueryResult result = CharacterDatabase.Query(
            "SELECT solo_mode FROM character_solo_state WHERE guid = {}", guid))
        {
            if (result->Fetch()[0].Get<bool>())
                SetSoloMode(player, true);
        }

        if (g_EnableCustomSkills)
        {
            if (QueryResult result = CharacterDatabase.Query(
                "SELECT skill_id, value FROM character_nightraven_skills WHERE guid = {}", guid))
            {
                do
                {
                    Field* fields = result->Fetch();
                    g_SkillCache[guid][fields[0].Get<uint32>()] = fields[1].Get<uint32>();
                } while (result->NextRow());
            }
        }

        if (g_EnableStartingKit)
            GrantStartingKit(player);
    }

    void GrantStartingKit(Player* player, bool notifyIfAlreadyGranted)
    {
        if (!player)
            return;

        ObjectGuid::LowType guid = GetGuidLow(player);

        // Уже выдавали?
        if (CharacterDatabase.Query("SELECT 1 FROM character_nightraven_kit WHERE guid = {}", guid))
        {
            if (notifyIfAlreadyGranted)
                player->SendSystemMessage("|cff4B0082[Ночь темного Ворона]|r Стартовый набор уже получен.");
            return;
        }

        // Набор = общие предметы (class_id = 0) + предметы класса
        QueryResult result = WorldDatabase.Query(
            "SELECT item_entry, count FROM nightdarkraven_starting_kit "
            "WHERE class_id IN (0, {}) ORDER BY class_id, item_entry",
            static_cast<uint32>(player->getClass()));

        if (!result)
        {
            LOG_ERROR("module", "[NightDarkRaven] Starting kit table is empty, player {} gets nothing", guid);
            player->SendSystemMessage("|cffFF0000[Ночь темного Ворона]|r Таблица стартового набора пуста.");
            return;
        }

        uint32 granted = 0;
        uint32 failed = 0;

        do
        {
            Field* fields = result->Fetch();
            uint32 entry = fields[0].Get<uint32>();
            uint32 count = fields[1].Get<uint32>();

            if (player->AddItem(entry, count))
                ++granted;
            else
            {
                ++failed;
                LOG_ERROR("module", "[NightDarkRaven] Cannot add starting item {} to player {}", entry, guid);
            }
        } while (result->NextRow());

        // Отмечаем выдачу, чтобы не дублировать предметы при следующем входе
        CharacterDatabase.Execute(
            "INSERT IGNORE INTO character_nightraven_kit (guid) VALUES ({})", guid);

        if (granted)
        {
            player->SendSystemMessage(
                "|cff4B0082[Ночь темного Ворона]|r Стартовый набор получен. "
                "Предметы: " + std::to_string(granted) + ".");
        }

        if (failed)
        {
            player->SendSystemMessage(
                "|cffFF0000[Ночь темного Ворона]|r Не хватило места в сумках для "
                + std::to_string(failed) + " предмет(ов) стартового набора.");
        }
    }

    void PlayerNightRavenScript::OnPlayerLogout(Player* player)
    {
        if (!player)
            return;

        ObjectGuid::LowType guid = GetGuidLow(player);
        g_SoloMode.erase(guid);
        g_SkillCache.erase(guid);
    }

    void PlayerNightRavenScript::OnPlayerSave(Player* player)
    {
        if (!player)
            return;

        ObjectGuid::LowType guid = GetGuidLow(player);

        if (g_EnableCustomSkills)
        {
            CharacterDatabaseTransaction trans = CharacterDatabase.BeginTransaction();
            trans->Append("DELETE FROM character_nightraven_skills WHERE guid = {}", guid);

            for (auto const& [skillId, value] : g_SkillCache[guid])
                trans->Append("INSERT INTO character_nightraven_skills (guid, skill_id, value) VALUES ({}, {}, {})",
                    guid, skillId, value);

            CharacterDatabase.CommitTransaction(trans);
        }
    }

    UnitNightRavenScript::UnitNightRavenScript() : UnitScript("UnitNightRavenScript") { }

    void UnitNightRavenScript::OnDamage(Unit* attacker, Unit* victim, uint32& damage)
    {
        if (!g_EnableSoloMode || !attacker || !victim || !damage)
            return;

        // Соло-режим: мобы кампаний наносят игроку меньше урона
        Player* player = victim->ToPlayer();
        if (!player || !IsSoloMode(player))
            return;

        Creature* creature = attacker->ToCreature();
        if (!creature)
            return;

        uint32 entry = creature->GetEntry();
        if (entry < 90000 || entry > 90199)
            return;

        damage = std::max<uint32>(1, static_cast<uint32>(damage * g_SoloDamageMultiplier));
    }

    CreatureNightRavenScript::CreatureNightRavenScript() : AllCreatureScript("CreatureNightRavenScript") { }

    void CreatureNightRavenScript::OnCreatureAddWorld(Creature* creature)
    {
        if (!g_EnableSoloMode || !creature || creature->IsPet() || creature->IsSummon())
            return;

        // Соло-сложность относится к мобам кампаний (entry 90000-90199), не к NPC-дачителям
        uint32 entry = creature->GetEntry();
        if (entry < 90000 || entry > 90199)
            return;

        uint32 baseHealth = creature->GetMaxHealth();
        uint32 scaled = std::max<uint32>(1, static_cast<uint32>(baseHealth * g_SoloHealthMultiplier));
        creature->SetMaxHealth(scaled);
        creature->SetHealth(scaled);
    }

    WorldNightRavenScript::WorldNightRavenScript() : WorldScript("WorldNightRavenScript") { }

    void WorldNightRavenScript::OnAfterConfigLoad(bool /*reload*/)
    {
        g_EnableSoloMode = sConfigMgr->GetOption<bool>("NightDarkRaven.EnableSoloMode", true);
        g_EnableCustomSkills = sConfigMgr->GetOption<bool>("NightDarkRaven.EnableCustomSkills", true);
        g_EnableStartingKit = sConfigMgr->GetOption<bool>("NightDarkRaven.EnableStartingKit", true);

        g_SoloHealthMultiplier = sConfigMgr->GetOption<float>("NightDarkRaven.SoloHealthMultiplier", 0.60f);
        g_SoloDamageMultiplier = sConfigMgr->GetOption<float>("NightDarkRaven.SoloDamageMultiplier", 0.70f);

        LOG_INFO("server.loading", "[NightDarkRaven] C++ module loaded: solo={} skills={} kit={} hp={} dmg={}",
            g_EnableSoloMode, g_EnableCustomSkills, g_EnableStartingKit,
            g_SoloHealthMultiplier, g_SoloDamageMultiplier);
    }

    // ------------------------------------------------------------------------
    // Синхронизация с аддоном: NDR|KIND|...
    // ------------------------------------------------------------------------

    void SendCampaignProgress(Player* player)
    {
        if (!player)
            return;

        std::set<uint32> rewarded;
        if (QueryResult result = CharacterDatabase.Query(
            "SELECT quest FROM character_queststatus_rewarded WHERE guid = {}", GetGuidLow(player)))
        {
            do
            {
                rewarded.insert(result->Fetch()[0].Get<uint32>());
            } while (result->NextRow());
        }

        for (auto const& campaign : g_Campaigns)
        {
            uint32 done = 0;
            for (uint32 quest : campaign.quests)
                if (rewarded.count(quest))
                    ++done;

            player->SendSystemMessage("NDR|CAMP|" + std::to_string(campaign.id) + "|"
                + std::to_string(done) + "|" + std::to_string(campaign.quests.size()));
        }
    }

    void SendShop(Player* player)
    {
        if (!player)
            return;

        player->SendSystemMessage("NDR|SHOPRESET");

        if (QueryResult result = WorldDatabase.Query(
            "SELECT item_entry, item_name, cost_gold FROM campaign_shop_items "
            "ORDER BY sort_order, item_entry"))
        {
            do
            {
                Field* fields = result->Fetch();
                player->SendSystemMessage("NDR|SHOP|" + std::to_string(fields[0].Get<uint32>())
                    + "|" + fields[1].Get<std::string>()
                    + "|" + std::to_string(fields[2].Get<uint32>()) + "|1");
            } while (result->NextRow());
        }
    }

    void SendSync(Player* player)
    {
        if (!player)
            return;

        player->SendSystemMessage(std::string("NDR|SOLO|") + (IsSoloMode(player) ? "1" : "0"));
        SendCampaignProgress(player);
        SendShop(player);
    }

    // ------------------------------------------------------------------------
    // Команды .ndr
    // ------------------------------------------------------------------------

    static Player* GetCommandPlayer(ChatHandler* handler)
    {
        return handler && handler->GetSession() ? handler->GetSession()->GetPlayer() : nullptr;
    }

    static bool HandleNdrSolo(ChatHandler* handler)
    {
        Player* player = GetCommandPlayer(handler);
        if (!player)
            return false;

        SetSoloMode(player, !IsSoloMode(player));
        SendSync(player);
        return true;
    }

    static bool HandleNdrKit(ChatHandler* handler)
    {
        Player* player = GetCommandPlayer(handler);
        if (!player)
            return false;

        GrantStartingKit(player, true);
        return true;
    }

    static bool HandleNdrSync(ChatHandler* handler)
    {
        Player* player = GetCommandPlayer(handler);
        if (!player)
            return false;

        SendSync(player);
        return true;
    }

    CommandNightRavenScript::CommandNightRavenScript() : CommandScript("CommandNightRavenScript") { }

    Acore::ChatCommands::ChatCommandTable CommandNightRavenScript::GetCommands() const
    {
        static Acore::ChatCommands::ChatCommandTable ndrTable =
        {
            { "solo", HandleNdrSolo, Acore::ChatCommands::Console::No },
            { "kit",  HandleNdrKit,  Acore::ChatCommands::Console::No },
            { "sync", HandleNdrSync, Acore::ChatCommands::Console::No },
        };

        static Acore::ChatCommands::ChatCommandTable commandTable =
        {
            { "ndr", ndrTable },
        };

        return commandTable;
    }

    // ------------------------------------------------------------------------
    // Фракционные дарители кампаний
    // ------------------------------------------------------------------------

    QuestGiverNightRavenScript::QuestGiverNightRavenScript() : CreatureScript("npc_nightdarkraven_questgiver") { }

    bool QuestGiverNightRavenScript::OnGossipHello(Player* player, Creature* creature)
    {
        if (!player || !creature)
            return false;

        uint32 entry = creature->GetEntry();
        if (!IsFactionNpc(entry))
            return false;

        bool allianceNpc = IsAllianceNpc(entry);
        bool alliancePlayer = player->GetTeamId() == TEAM_ALLIANCE;

        if (allianceNpc != alliancePlayer)
        {
            player->SendSystemMessage("|cffFF0000[Ночь темного Ворона]|r Этот даритель служит другой фракции.");
            player->PlayerTalkClass->SendCloseGossip();
            return true;
        }

        uint32 index = CampaignIndexForEntry(entry);

        player->PlayerTalkClass->ClearMenus();
        GossipMenu& menu = player->PlayerTalkClass->GetGossipMenu();
        menu.AddMenuItem(0, GOSSIP_ICON_CHAT,
            "Кампания " + std::to_string(index) + ": отправиться к месту событий",
            GOSSIP_SENDER_MAIN, ACTION_TELEPORT, "", 0);
        menu.AddMenuItem(1, GOSSIP_ICON_VENDOR, "Магазин наград",
            GOSSIP_SENDER_MAIN, ACTION_SHOP, "", 0);
        menu.AddMenuItem(2, GOSSIP_ICON_CHAT, "Показать прогресс кампаний",
            GOSSIP_SENDER_MAIN, ACTION_PROGRESS, "", 0);
        player->PlayerTalkClass->SendGossipMenu(1, creature->GetGUID());
        return true;
    }

    bool QuestGiverNightRavenScript::OnGossipSelect(Player* player, Creature* creature, uint32 /*sender*/, uint32 action)
    {
        if (!player || !creature)
            return false;

        uint32 entry = creature->GetEntry();
        if (!IsFactionNpc(entry))
            return false;

        if (action == ACTION_TELEPORT)
        {
            TeleportToFactionHub(player, IsAllianceNpc(entry));
            player->PlayerTalkClass->SendCloseGossip();
            return true;
        }

        if (action == ACTION_SHOP)
        {
            SendShop(player);
            player->PlayerTalkClass->SendCloseGossip();
            return true;
        }

        if (action == ACTION_PROGRESS)
        {
            SendCampaignProgress(player);
            player->PlayerTalkClass->SendCloseGossip();
            return true;
        }

        return false;
    }

    // ------------------------------------------------------------------------
    // Торговец наград
    // ------------------------------------------------------------------------

    ShopNightRavenScript::ShopNightRavenScript() : CreatureScript("npc_nightdarkraven_shop") { }

    bool ShopNightRavenScript::OnGossipHello(Player* player, Creature* creature)
    {
        if (!player || !creature)
            return false;

        uint32 entry = creature->GetEntry();
        if (!IsShopNpc(entry))
            return false;

        if ((IsAllianceNpc(entry) && player->GetTeamId() != TEAM_ALLIANCE) ||
            (IsHordeNpc(entry) && player->GetTeamId() != TEAM_HORDE))
        {
            player->SendSystemMessage("|cffFF0000[Ночь темного Ворона]|r Этот торговец служит другой фракции.");
            player->PlayerTalkClass->SendCloseGossip();
            return true;
        }

        player->PlayerTalkClass->ClearMenus();
        GossipMenu& menu = player->PlayerTalkClass->GetGossipMenu();

        int32 menuId = 0;
        if (QueryResult result = WorldDatabase.Query(
            "SELECT item_entry, item_name, cost_gold FROM campaign_shop_items "
            "ORDER BY sort_order, item_entry LIMIT 20"))
        {
            do
            {
                Field* fields = result->Fetch();
                uint32 itemEntry = fields[0].Get<uint32>();
                std::string name = fields[1].Get<std::string>();
                uint32 cost = fields[2].Get<uint32>();

                menu.AddMenuItem(menuId++, GOSSIP_ICON_VENDOR,
                    name + " — " + std::to_string(cost) + " зол.",
                    GOSSIP_SENDER_MAIN, ACTION_SHOP_ITEM + itemEntry, "", 0);
            } while (result->NextRow());
        }

        if (menuId == 0)
            menu.AddMenuItem(menuId++, GOSSIP_ICON_CHAT, "Ассортимент пока пуст",
                GOSSIP_SENDER_MAIN, ACTION_PROGRESS, "", 0);

        player->PlayerTalkClass->SendGossipMenu(1, creature->GetGUID());
        return true;
    }

    bool ShopNightRavenScript::OnGossipSelect(Player* player, Creature* creature, uint32 /*sender*/, uint32 action)
    {
        if (!player || !creature)
            return false;

        if (!IsShopNpc(creature->GetEntry()))
            return false;

        if (action == ACTION_PROGRESS)
        {
            player->PlayerTalkClass->SendCloseGossip();
            return true;
        }

        if (action < ACTION_SHOP_ITEM)
            return false;

        uint32 itemEntry = action - ACTION_SHOP_ITEM;

        QueryResult result = WorldDatabase.Query(
            "SELECT item_name, cost_gold FROM campaign_shop_items WHERE item_entry = {}", itemEntry);
        if (!result)
        {
            player->SendSystemMessage("|cffFF0000[Ночь темного Ворона]|r Этот товар недоступен.");
            player->PlayerTalkClass->SendCloseGossip();
            return true;
        }

        Field* fields = result->Fetch();
        std::string name = fields[0].Get<std::string>();
        uint64 price = static_cast<uint64>(fields[1].Get<uint32>()) * 10000ull;

        if (player->GetMoney() < price)
        {
            player->SendSystemMessage("|cffFF0000[Ночь темного Ворона]|r Недостаточно золота для покупки «" + name + "».");
            player->PlayerTalkClass->SendCloseGossip();
            return true;
        }

        ItemPosCountVec dest;
        InventoryResult msg = player->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, itemEntry, 1);
        if (msg != EQUIP_ERR_OK)
        {
            player->SendEquipError(msg, nullptr, nullptr, itemEntry);
            player->PlayerTalkClass->SendCloseGossip();
            return true;
        }

        Item* item = player->StoreNewItem(dest, itemEntry, true);
        player->SendNewItem(item, 1, true, false);
        player->ModifyMoney(-static_cast<int32>(price));

        player->SendSystemMessage("|cff4B0082[Ночь темного Ворона]|r Куплено: «" + name + "».");
        player->PlayerTalkClass->SendCloseGossip();
        return true;
    }

    // ------------------------------------------------------------------------
    // Соло-режим и навыки
    // ------------------------------------------------------------------------

    void SetSoloMode(Player* player, bool enable)
    {
        if (!player)
            return;

        ObjectGuid::LowType guid = GetGuidLow(player);
        g_SoloMode[guid] = enable;

        CharacterDatabase.Execute(
            "INSERT INTO character_solo_state (guid, account_id, solo_mode) VALUES ({}, {}, {}) "
            "ON DUPLICATE KEY UPDATE solo_mode = VALUES(solo_mode)",
            guid, player->GetSession()->GetAccountId(), enable ? 1u : 0u);

        if (enable)
            player->SendSystemMessage("Соло-режим включён.");
        else
            player->SendSystemMessage("Соло-режим выключен.");
    }

    bool IsSoloMode(Player* player)
    {
        if (!player)
            return false;

        auto itr = g_SoloMode.find(GetGuidLow(player));
        return itr != g_SoloMode.end() && itr->second;
    }

    uint32 GetSkill(Player* player, uint32 skillId)
    {
        if (!player || !IsCustomSkill(skillId))
            return 0;

        auto const& skills = g_SkillCache[GetGuidLow(player)];
        auto itr = skills.find(skillId);
        return itr != skills.end() ? itr->second : 0;
    }

    void SetSkill(Player* player, uint32 skillId, uint32 value)
    {
        if (!player || !IsCustomSkill(skillId))
            return;

        g_SkillCache[GetGuidLow(player)][skillId] = std::min(value, GetSkillMax(skillId));
    }

    uint32 SkillUp(Player* player, uint32 skillId, uint32 amount)
    {
        if (!player || !IsCustomSkill(skillId))
            return 0;

        uint32 newValue = std::min(GetSkill(player, skillId) + amount, GetSkillMax(skillId));
        SetSkill(player, skillId, newValue);
        return newValue;
    }

    bool HasSkill(Player* player, uint32 skillId)
    {
        return GetSkill(player, skillId) > 0;
    }
}

void AddSC_night_dark_raven()
{
    new NightDarkRaven::PlayerNightRavenScript();
    new NightDarkRaven::UnitNightRavenScript();
    new NightDarkRaven::CreatureNightRavenScript();
    new NightDarkRaven::WorldNightRavenScript();
    new NightDarkRaven::CommandNightRavenScript();
    new NightDarkRaven::QuestGiverNightRavenScript();
    new NightDarkRaven::ShopNightRavenScript();
}
