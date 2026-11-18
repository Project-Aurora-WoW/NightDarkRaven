-- ============================================================================
Ночь темного Ворона — Соло-контент (компаньоны, соло-квесты, соло-предметы)
-- База: world (AzerothCore 3.3.5a)
-- Entry range: 91001-91005 (предметы), 92001-92003 (компаньоны), 95001-95002 (квесты)
-- ============================================================================

USE world;

-- --------------------------------------------------------
-- 1. Соло-предметы (награды соло-квестов и оснащение)
-- --------------------------------------------------------
INSERT INTO `item_template` (`entry`, `name`, `displayid`, `Quality`, `Flags`, `BuyPrice`, `SellPrice`, `InventoryType`, `Class`, `SubClass`, `MaxCount`, `bonding`, `description`) VALUES
(91001, 'Кольцо Ночного Ворона', 1, 4, 0, 0, 2000, 0, 0, 0, 1, 1, 'Кольцо из тени Ворона. Награда за соло-испытание.'),
(91002, 'Ожерелье Темного Ворона', 1, 4, 0, 0, 2000, 0, 0, 0, 1, 1, 'Ожерелье Ночного Ворона.'),
(91003, 'Перстень Хранителя Ночи', 1, 3, 0, 0, 1200, 0, 0, 0, 1, 1, 'Перстень хранителей.'),
(91004, 'Поножи Ночного Ворона', 1, 4, 0, 0, 3000, 0, 0, 0, 1, 1, 'Поножи из тени.'),
(91005, 'Наручи Ворона', 1, 3, 0, 0, 1500, 0, 0, 0, 1, 1, 'Наручи Ночного Ворона.');

-- --------------------------------------------------------
-- 2. Компаньоны для соло-игроков (NPC)
-- --------------------------------------------------------
-- Теневой Ворон (урон)
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `scale`, `unit_class`, `unit_flags`, `type`, `type_flags`, `Rank`, `dmg_min`, `dmg_max`, `base_attack_time`) VALUES
(92001, 'Теневой Ворон', 'Компаньон', 1, 80, 35, 0, 1.0, 3.5, 0.8, 1, 0, 7, 138936390, 0, 50, 100, 2000);

-- Страж Ночи (танк)
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `scale`, `unit_class`, `unit_flags`, `type`, `type_flags`, `Rank`, `dmg_min`, `dmg_max`, `base_attack_time`) VALUES
(92002, 'Страж Ночи', 'Компаньон', 1, 80, 35, 0, 1.0, 2.5, 1.1, 1, 0, 7, 138936390, 1, 40, 80, 2200);

-- Целитель Лунный (хил)
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `scale`, `unit_class`, `unit_flags`, `type`, `type_flags`, `Rank`, `dmg_min`, `dmg_max`, `base_attack_time`) VALUES
(92003, 'Целитель Лунный', 'Компаньон', 1, 80, 35, 0, 1.0, 2.5, 0.9, 1, 0, 7, 138936390, 0, 30, 60, 2400);

-- --------------------------------------------------------
-- 3. Соло-квесты
-- --------------------------------------------------------
-- 95001 Испытание Одиночества
INSERT INTO `quest_template` (
    `entry`, `Method`, `RaceMask`, `ClassMask`, `MinLevel`, `SuggestedPlayers`, `QuestLevel`, `Type`, `Flags`,
    `NextQuestId`, `NextQuestInChain`, `Title`, `Details`, `Objectives`,
    `OfferRewardText`, `RequestItemsText`, `EndText`, `CompletedText`,
    `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`,
    `RewardItemId1`, `RewardItemId2`, `RewardItemId3`, `RewardItemId4`,
    `RewardItemCount1`, `RewardItemCount2`, `RewardItemCount3`, `RewardItemCount4`,
    `RewardMoney`
) VALUES
(95001, 0, 1101, 1023, 10, 1, 10, 0, 0, 95002, 0,
 'Испытание Одиночества',
 'Темный Ворон предлагает пройти путь Ворона в одиночку, без группы.',
 'Пройдите соло-режим и выполните любые 3 квеста кампании 1.',
 'Вы достоин称号 Ночного Ворона. Прими это кольцо.',
 'Вернитесь к Темному Ворону после прохождения.',
 'Испытание пройдено в одиночку.',
 'Испытание Одиночества: 1/1', NULL, NULL, NULL,
 91001, 0, 0, 0, 1, 0, 0, 0, 5000000);

-- 95002 Путник Теней (компаньон)
INSERT INTO `quest_template` (
    `entry`, `Method`, `RaceMask`, `ClassMask`, `MinLevel`, `SuggestedPlayers`, `QuestLevel`, `Type`, `Flags`,
    `NextQuestId`, `NextQuestInChain`, `Title`, `Details`, `Objectives`,
    `OfferRewardText`, `RequestItemsText`, `EndText`, `CompletedText`,
    `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`,
    `RewardItemId1`, `RewardItemId2`, `RewardItemId3`, `RewardItemId4`,
    `RewardItemCount1`, `RewardItemCount2`, `RewardItemCount3`, `RewardItemCount4`,
    `RewardMoney`
) VALUES
(95002, 0, 1101, 1023, 15, 1, 15, 0, 0, 0, 95001,
 'Путник Теней',
 'Приручи Теневого Ворона — он станет твоим компаньоном в соло.',
 'Поговори с Темным Вороном о компаньоне.',
 'Теневой Ворон теперь с тобой.',
 'Вернитесь к Темному Ворону.',
 'Теневой Ворон станет твоим спутником.',
 'Компаньон приручен: 1/1', NULL, NULL, NULL,
 0, 0, 0, 0, 0, 0, 0, 0, 3000000);

-- creature_queststarter / questender для соло-квестов (NPC 90001 Темный Ворон)
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
(90001, 95001), (90001, 95002);

INSERT INTO `creature_questender` (`id`, `quest`) VALUES
(90001, 95001), (90001, 95002);

SELECT 'Solo content inserted (companions, solo quests, solo items)' AS info;