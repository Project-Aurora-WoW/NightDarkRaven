-- ============================================================================
-- Ночь темного Ворона — English localization (en-US)
-- All strings for Eluna Lua scripts
-- ============================================================================

return {
    -- ============================================================================
    -- NPC "Dark Raven" (90001)
    -- ============================================================================
    npc_dark_raven = {
        welcome = "You came in the dark hour, stranger. I am Dark Raven, Keeper of Night's Secrets. What brought you here?",
        world_info = "The world of Night of Dark Raven is a land of fantasy where magic and steel decide fates. Explore these lands carefully...",
        goodbye = "May the wings of the Raven protect you in the night...",
        combat_1 = "You won't escape my claws!",
        combat_2 = "The night will devour you...",
        combat_3 = "The Dark Raven sees everything...",
        died = "The Raven cannot be killed... he only retreats into the shadows...",
    },

    -- ============================================================================
    -- Campaigns
    -- ============================================================================
    campaigns = {
        [1] = { name = "Awakening of the Raven" },
        [2] = { name = "Shadows of Raven Mountain" },
        [3] = { name = "Curse of Feathers" },
        [4] = { name = "Blood Moon" },
        [5] = { name = "Keepers of the Night" },
        [6] = { name = "Forgotten Temple" },
        [7] = { name = "Seal of Darkness" },
        [8] = { name = "Raven's Blade" },
        [9] = { name = "Night Watch" },
        [10] = { name = "Raven and Moon" },
        [11] = { name = "End of Night" },
        [12] = { name = "Lords of Shadows" },
        [13] = { name = "Kingdom of Void" },
        [14] = { name = "Star Raven" },
        [15] = { name = "Eternal Raven" },
    },

    -- ============================================================================
    -- Quests Campaign 1
    -- ============================================================================
    quest_90101 = {
        title = "Awakening of the Raven",
        details = "Night Guardian asks you to go to Shadow Owls and collect feathers.",
        objectives = "Collect feathers from Shadow Owls.",
        reward_text = "You worked well. Here is your reward.",
        complete_text = "Thank you for your help. The Raven blesses your path.",
    },
    quest_90102 = {
        title = "Shadow Traces",
        details = "Find and destroy Dark Followers near the camp.",
        objectives = "Kill 8 Dark Followers.",
        reward_text = "Traces eliminated. Talk to Night Guardian.",
        complete_text = "You protected the Night Threshold.",
    },
    quest_90103 = {
        title = "Light in Darkness",
        details = "Obtain Glowing Pebble from ruins.",
        objectives = "Find 3 Glowing Pebbles.",
        reward_text = "Pebbles delivered. Return to Night Guardian.",
        complete_text = "The path to Raven Mountain is open.",
    },

    -- ============================================================================
    -- Solo system
    -- ============================================================================
    solo = {
        enabled = "Solo mode enabled. Difficulty adapted for one player.",
        disabled = "Solo mode disabled.",
        not_enabled = "Enable solo mode to pass the trial.",
        restored = "Solo mode restored from web client.",
    },

    -- ============================================================================
    -- Companions
    -- ============================================================================
    companion = {
        shadow_raven = "Shadow Raven",
        night_guard = "Night Guard",
        moon_healer = "Moon Healer",
        summoned = "Companion summoned: %s.",
        dismissed = "Companion dismissed.",
        not_found = "Unknown companion.",
        tame_success = "You tamed %s! Taming Shadows skill increased (%d).",
        tame_fail = "Taming failed (%d%%). %s attacks!",
        not_known = "This creature cannot be tamed.",
        already_tamed = "This creature is already your companion.",
        low_skill = "Insufficient Taming Shadows skill: %d/%d.",
    },

    -- ============================================================================
    -- Items
    -- ============================================================================
    items = {
        shadow_feather = "Shadow Feather",
        shadow_fang = "Shadow Owl Fang",
        glowing_pebble = "Glowing Pebble",
        raven_blade = "Raven Blade",
        raven_cloak = "Night Raven Cloak",
        raven_heart = "Dark Raven Heart",
        night_ring = "Night Raven Ring",
    },

    -- ============================================================================
    -- Socket system
    -- ============================================================================
    socket = {
        socket_success = "Gem '%s' inserted: %s.",
        socket_remove = "Gem '%s' removed.",
        no_socket = "This item doesn't have a socket in this position.",
        socket_full = "This socket already has a gem.",
        no_item = "You don't have this gem.",
        socket_info = "Gem '%s' inserted into slot %d.",
    },

    -- ============================================================================
    -- Skills system
    -- ============================================================================
    skills = {
        shadow_forging = "Shadow Forging",
        feather_extraction = "Feather Extraction",
        night_potions = "Night Potions",
        rune_reading = "Rune Reading",
        shadow_taming = "Taming Shadows",
        skill_up = "Skill '%s' increased (%d).",
    },

    -- ============================================================================
    -- Solo dungeon system
    -- ============================================================================
    dungeon = {
        entered = "You entered solo dungeon: %s.",
        exited = "You exited solo dungeon.",
        wrong_level = "Your level doesn't match this dungeon (%d-%d).",
        need_solo = "Enable solo mode to enter.",
    },

    -- ============================================================================
    -- Client patch system
    -- ============================================================================
    patch = {
        applied = "Patch '%s' applied.",
        available = "Client patches available:",
        apply_all = "Run launcher to automatically apply patches.",
    },
}