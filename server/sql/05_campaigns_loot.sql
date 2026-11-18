-- ============================================================================
Ночь темного Ворона — 11 кампаний: Лут мобов
-- База: world (AzerothCore 3.3.5a)
-- ============================================================================

USE world;

-- Лут для квестовых мобов (ChanceOrQuestChance = шанс * 10000, lootmode = 1 для обычного лута)

-- Кампания 1
INSERT INTO `creature_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincount`, `maxcount`) VALUES
(90011, 90001, 500000, 1, 0, 1, 2),  -- Темный последователь дропает Перо Тени (50%)
(90011, 90003, 300000, 1, 0, 1, 1), -- Клык (30%);

-- Кампания 2
INSERT INTO `creature_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincount`, `maxcount`) VALUES
(90021, 90021, 600000, 1, 0, 1, 2),  -- Горный волк дропает Шкуру (60%)
(90022, 90023, 100000, 1, 0, 1, 1);  -- Гаргулья дропает Перо (10%)

-- Кампания 3
INSERT INTO `creature_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincount`, `maxcount`) VALUES
(90031, 90031, 400000, 1, 0, 1, 1);  -- Теневой оборотень дропает Проклятое Перо (40%)

-- Кампания 4
INSERT INTO `creature_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincount`, `maxcount`) VALUES
(90041, 90041, 500000, 1, 0, 1, 1),  -- Кровавый волк дропает Клык (50%)
(90042, 90043, 50000, 1, 0, 1, 1);   -- Призрачная сова дропает Кристалл (5%)

-- Кампания 5
INSERT INTO `creature_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincount`, `maxcount`) VALUES
(90051, 90051, 200000, 1, 0, 1, 1),  -- Темный страж дропает Печать (20%)
(90052, 90052, 500000, 1, 0, 1, 2);  -- Призыватель дропает Масло (50%)

-- Кампания 6
INSERT INTO `creature_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincount`, `maxcount`) VALUES
(90061, 90062, 700000, 1, 0, 1, 2),  -- Скелет жреца дропает Пыль Костей (70%)
(90062, 90063, 100000, 1, 0, 1, 1);  -- Проклятый страж дропает Ключ (10%)

-- Кампания 7
INSERT INTO `creature_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincount`, `maxcount`) VALUES
(90071, 90072, 600000, 1, 0, 1, 1),  -- Демон тени дропает Кровь (60%)
(90072, 90071, 150000, 1, 0, 1, 1);  -- Страж Печати дропает Осколок (15%)

-- Кампания 8
INSERT INTO `creature_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincount`, `maxcount`) VALUES
(90081, 90082, 1000000, 1, 0, 1, 2), -- Огненный элементаль дропает Искру (100%)
(90082, 90083, 500000, 1, 0, 1, 1);  -- Тень Ворона дропает Чешую (50%)

-- Кампания 9
INSERT INTO `creature_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincount`, `maxcount`) VALUES
(90091, 90091, 300000, 1, 0, 1, 1),  -- Разведчик Теней дропает Знак (30%)
(90092, 90093, 800000, 1, 0, 1, 2);  -- Ночной хищник дропает Когти (80%)

-- Кампания 10
INSERT INTO `creature_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincount`, `maxcount`) VALUES
(90101, 90101, 300000, 1, 0, 1, 1),  -- Луноstalker дропает Слезu (30%)
(90102, 90103, 100000, 1, 0, 1, 1);  -- Аспект Ворона дропает Перо (10%)

-- Кампания 11 (финал)
INSERT INTO `creature_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincount`, `maxcount`) VALUES
(90110, 90111, 1000000, 1, 0, 1, 1), -- Темный Ворон дропает Сердце (100% квестовый)
(90111, 90112, 1000000, 1, 0, 1, 1); -- Посланник Тьмы дропает Крыло (100% квестовый)

SELECT 'Campaign loot inserted' AS info;