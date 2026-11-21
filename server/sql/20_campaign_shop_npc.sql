-- ============================================================================
-- Ночь темного Ворона — NPC «Торговец кампаний»
-- База: world (AzerothCore 3.3.5a)
-- ============================================================================

USE world;

INSERT INTO `creature_template` (
    `entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `unit_class`, `unit_flags`, `type`, `type_flags`, `rank`, `BaseAttackTime`
) VALUES
(90099, 'Торговец кампаний', 'Торговец наград ночи', 80, 80, 35, 1, 1.0, 2.5, 1, 0, 7, 138936390, 0, 2000)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);;

INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`)
VALUES (90099, 0, 3354, 1, 1)
ON DUPLICATE KEY UPDATE `CreatureDisplayID` = VALUES(`CreatureDisplayID`);

INSERT INTO `creature` (
    `id1`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`
) VALUES
(90099, 0, 0, 0, 1, 1, -8870.0, 530.0, 100.0, 0.0, 300, 0);

SELECT 'Campaign shop NPC 90099 created' AS info;