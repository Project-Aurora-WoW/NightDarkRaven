-- ============================================================================
-- Ночь темного Ворона — модели NPC, ScriptName и gossip-флаги
-- База: world (AzerothCore 3.3.5a)
-- Выполнять после 01-22.
-- ============================================================================

USE world;

-- ----------------------------------------------------------------------------
-- 1. Модели для кампанийных NPC (в старом SQL колонка modelid была равна 0,
--    из-за чего NPC были невидимы). Модель выбирается по фракции.
-- ----------------------------------------------------------------------------
INSERT INTO `creature_template_model`
    (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`)
SELECT ct.`entry`, 0,
    CASE
        WHEN ct.`faction` = 35 THEN 3354  -- дружелюбный человек
        WHEN ct.`entry` % 4 = 0 THEN 2357 -- Defias Bandit
        WHEN ct.`entry` % 4 = 1 THEN 2361 -- Defias Cutpurse
        WHEN ct.`entry` % 4 = 2 THEN 4418 -- Defias Smuggler
        ELSE 2336                          -- Defias Pathstalker
    END,
    1, 1
FROM `creature_template` ct
WHERE ct.`entry` BETWEEN 90000 AND 90200
  AND NOT EXISTS (SELECT 1 FROM `creature_template_model` m WHERE m.`CreatureID` = ct.`entry`);

-- ----------------------------------------------------------------------------
-- 2. Скрипты gossip для фракционных дарителей и торговцев
-- ----------------------------------------------------------------------------
UPDATE `creature_template`
SET `ScriptName` = 'npc_nightdarkraven_questgiver'
WHERE (`entry` BETWEEN 95001 AND 95015) OR (`entry` BETWEEN 95101 AND 95115);

UPDATE `creature_template`
SET `ScriptName` = 'npc_nightdarkraven_shop'
WHERE `entry` IN (90099, 95016, 95116);

-- ----------------------------------------------------------------------------
-- 3. Гарантируем флаг gossip у всех NPC модуля
-- ----------------------------------------------------------------------------
UPDATE `creature_template`
SET `npcflag` = `npcflag` | 1
WHERE (`entry` BETWEEN 90000 AND 90200) OR (`entry` BETWEEN 95001 AND 95116);

SELECT 'NPC models and scripts applied' AS info;
