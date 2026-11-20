-- ============================================================================
Ночь темного Ворона — NPC Торговец кампаний
-- База: world (AzerothCore 3.3.5a)
-- Entry: 90099
-- ============================================================================

USE world;

-- NPC Торговец кампаний
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `scale`, `unit_class`, `unit_flags`, `type`, `type_flags`, `Rank`, `dmg_min`, `dmg_max`, `base_attack_time`) VALUES
(90099, 'Торговец кампаний', 'Торговец наград ночи', 80, 80, 35, 1, 1.0, 2.5, 1.0, 1, 0, 7, 138936390, 0, 100, 150, 2000);

-- Спавн NPC (рядом с Темным Вороном)
INSERT INTO `creature` (`id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `modelid`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `animprogress`, `corpse_delay`) VALUES
(90099, 0, 0, 0, 1, 1, 0, -8870.0, 530.0, 100.0, 0.0, 300, 0, 0);

SELECT 'Campaign shop NPC inserted (90099)' AS info;