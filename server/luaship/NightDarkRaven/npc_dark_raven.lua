-- ============================================================================
-- Ночь темного Ворона — NPC "Темный Ворон" (entry 90001)
-- Lua / Eluna для AzerothCore (WoW 3.3.5a)
-- ============================================================================

local NPC_DARK_RAVEN = 90001

local GOSSIP_TEXT_WELCOME   = 90001
local GOSSIP_TEXT_WORLD     = 90002
local GOSSIP_TEXT_GOODBYE   = 90003

-- Приветствие: формируем gossip-меню
local function OnGossipHello(event, player, creature)
    player:GossipMenuAddItem(0, "Приветствую, странник...", 0, 1)
    player:GossipMenuAddItem(0, "Расскажи о мире Ночь Темного Ворона", 0, 2)
    player:GossipMenuAddItem(0, "Прощай", 0, 3)

    player:GossipSendMenu(GOSSIP_TEXT_WELCOME, creature)
    return false
end

-- Обработка выбора пункта меню
local function OnGossipSelect(event, player, creature, sender, intid, code)
    if intid == 1 then
        -- Приветствие
        player:GossipSendMenu(GOSSIP_TEXT_WELCOME, creature)
    elseif intid == 2 then
        -- Рассказ о мире
        player:GossipSendMenu(GOSSIP_TEXT_WORLD, creature)
    elseif intid == 3 then
        -- Прощание
        creature:SendUnitSay("Пусть крылья Ворона оградят тебя в ночи...", 0)
        player:GossipComplete()
    end
    return false
end

-- Случайная фраза при входе в бой (придаёт жизни NPC)
local function OnCombat(event, creature, target)
    local phrases = {
        "Ты не уйдёшь от моих когтей!",
        "Ночь поглотит тебя...",
        "Темный Ворон видит всё..."
    }
    local phrase = phrases[math.random(#phrases)]
    creature:SendUnitSay(phrase, 0)
end

-- Смерть NPC
local function OnDied(event, creature, killer)
    creature:SendUnitSay("Ворона не убить... он лишь уходит в тень...", 0)
end

-- Регистрация событий
RegisterCreatureGossipEvent(NPC_DARK_RAVEN, 1, OnGossipHello)   -- GOSSIP_HELLO
RegisterCreatureGossipEvent(NPC_DARK_RAVEN, 2, OnGossipSelect)  -- GOSSIP_SELECT
RegisterCreatureEvent(NPC_DARK_RAVEN, 1, OnCombat)              -- COMBAT
RegisterCreatureEvent(NPC_DARK_RAVEN, 4, OnDied)                -- DIED

print("[NightDarkRaven] Lua: npc_dark_raven (entry " .. NPC_DARK_RAVEN .. ") loaded.")