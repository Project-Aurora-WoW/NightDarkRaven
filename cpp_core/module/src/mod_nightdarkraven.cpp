#include "mod_nightdarkraven.h"

#include "Config.h"
#include "DatabaseEnv.h"
#include "Log.h"
#include "Timer.h"

#include <algorithm>

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

    inline ObjectGuid::LowType GetGuidLow(Player* player)
    {
        return player->GetGUID().GetCounter();
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

        g_SoloHealthMultiplier = sConfigMgr->GetOption<float>("NightDarkRaven.SoloHealthMultiplier", 0.60f);
        g_SoloDamageMultiplier = sConfigMgr->GetOption<float>("NightDarkRaven.SoloDamageMultiplier", 0.70f);

        LOG_INFO("server.loading", "[NightDarkRaven] C++ module loaded: solo={} skills={} hp={} dmg={}",
            g_EnableSoloMode, g_EnableCustomSkills, g_SoloHealthMultiplier, g_SoloDamageMultiplier);
    }

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

        // Пересчитываем здоровье мобов вокруг игрока в соответствии с режимом
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

void AddSC_night_dark_raven() { }
