-- ============================================================================
Ночь темного Ворона — Камни Легенды Ночных Стражей
-- База: world (AzerothCore 3.3.5a)
-- Entry range: 92001-92100 (камни), 93001-93010 (NPC дачители)
-- Quest range: 92001-92050 (квесты камней)
-- ============================================================================

USE world;

-- --------------------------------------------------------
-- 1. Камни Легенды Ночных Стражей (сокетные предметы)
-- --------------------------------------------------------
INSERT INTO `item_template` (`entry`, `name`, `displayid`, `Quality`, `Flags`, `BuyPrice`, `SellPrice`, `InventoryType`, `Class`, `SubClass`, `MaxCount`, `bonding`, `description`) VALUES
-- Камень Теневой Мощи (красный, сила атаки)
(92001, 'Камень Теневой Мощи', 1, 4, 0, 0, 5000, 0, 0, 0, 1, 1, 'Легендарный камень. Дает бонус к силе атаки при вставке в сокет.'),
-- Камень Лунного Сияния (синий, интеллект)
(92002, 'Камень Лунного Сияния', 1, 4, 0, 0, 5000, 0, 0, 0, 1, 1, 'Легендарный камень. Дает бонус к интеллекту при вставке в сокет.'),
-- Камень Ночной Стойкости (желтый, выносливость)
(92003, 'Камень Ночной Стойкости', 1, 4, 0, 0, 5000, 0, 0, 0, 1, 1, 'Легендарный камень. Дает бонус к выносливости при вставке в сокет.'),
-- Камень Воронового Крика (фиолетовый, крит)
(92004, 'Камень Воронового Крика', 1, 4, 0, 0, 8000, 0, 0, 0, 1, 1, 'Редкий легендарный камень. Увеличивает шанс критического удара.'),
-- Камень Вечной Тьмы (зеленый, мастерство)
(92005, 'Камень Вечной Тьмы', 1, 4, 0, 0, 8000, 0, 0, 0, 1, 1, 'Редкий легендарный камень. Увеличивает мастерство владения оружием.'),
-- Камень Звездного Падения (оранжевый, сила + интеллект)
(92006, 'Камень Звездного Падения', 1, 5, 0, 0, 15000, 0, 0, 0, 1, 1, 'Эпический легендарный камень. Комбинированный бонус к силе и интеллекту.'),
-- Камень Пустотного Эха (циан, сила тени)
(92007, 'Камень Пустотного Эха', 1, 5, 0, 0, 20000, 0, 0, 0, 1, 1, 'Легендарный камень Пустоты. Дает урон тени при атаке.'),
-- Камень Ночного Стража (белый, защита)
(92008, 'Камень Ночного Стража', 1, 5, 0, 0, 25000, 0, 0, 0, 1, 1, 'Эпический камень Ночного Стража. Дает бонус к броне и защите.');

-- --------------------------------------------------------
-- 2. NPC дачители квестов камней
-- --------------------------------------------------------
INSERT INTO `creature_template` (
    `entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `unit_class`, `unit_flags`, `type`, `type_flags`, `Rank`, `BaseAttackTime`
) VALUES
(93001, 'Мастер Камней Теней', 'Ювелир Ночных Стражей', 80, 80, 35, 1, 1.0, 2.5, 1, 0, 7, 138936390, 0, 2000),
(93002, 'Хранитель Легенд', 'Историк Ночных Стражей', 80, 80, 35, 1, 1.0, 2.5, 1, 0, 7, 138936390, 0, 2000);

-- --------------------------------------------------------
-- 3. Квесты камней легенды
-- --------------------------------------------------------
-- 92001 Поиск Первого Камня
INSERT INTO `quest_template` (
    `entry`, `Method`, `RaceMask`, `ClassMask`, `MinLevel`, `SuggestedPlayers`, `QuestLevel`, `Type`, `Flags`,
    `NextQuestId`, `NextQuestInChain`, `Title`, `Details`, `Objectives`,
    `OfferRewardText`, `RequestItemsText`, `EndText`, `CompletedText`,
    `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`,
    `RewardItemId1`, `RewardItemId2`, `RewardItemId3`, `RewardItemId4`,
    `RewardItemCount1`, `RewardItemCount2`, `RewardItemCount3`, `RewardItemCount4`,
    `RewardMoney`
) VALUES
(92001, 0, 1101, 1023, 80, 1, 80, 0, 0, 92002, 0,
 'Поиск Первого Камня',
 'Мастер Камней Теней просит найти первый Камень Легенды в руинах Ночного Храма.',
 'Добыть Камень Теневой Мощи из руин.',
 'Вы нашли камень. Вернитесь к Мастеру.',
 'Принесите камень Мастеру Камней.',
 'Первый камень получен. Путь к легенде открыт.',
 'Камней Теневой Мощи: 1/1', NULL, NULL, NULL,
 92001, 0, 0, 0, 1, 0, 0, 0, 10000000),
-- 92002 Очистка Камня
INSERT INTO `quest_template` (
    `entry`, `Method`, `RaceMask`, `ClassMask`, `MinLevel`, `SuggestedPlayers`, `QuestLevel`, `Type`, `Flags`,
    `NextQuestId`, `NextQuestInChain`, `Title`, `Details`, `Objectives`,
    `OfferRewardText`, `RequestItemsText`, `EndText`, `CompletedText`,
    `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`,
    `RewardItemId1`, `RewardItemId2`, `RewardItemId3`, `RewardItemId4`,
    `RewardItemCount1`, `RewardItemCount2`, `RewardItemCount3`, `RewardItemCount4`,
    `RewardMoney`
) VALUES
(92002, 0, 1101, 1023, 80, 1, 80, 0, 0, 92003, 92001,
 'Очистка Камня',
 'Мастер Камней Теней просит очистить камень от осквернения.',
 'Убить 10 Оскверненных Теней около руин.',
 'Камень очищен. Вернитесь к Мастеру.',
 'Принесите доказательство очистки Мастеру.',
 'Камень очищен от тени.',
 'Оскверненных Теней убито: 10/10', NULL, NULL, NULL,
 92002, 0, 0, 0, 1, 0, 0, 0, 12000000),
-- 92003 Соединение Камней
INSERT INTO `quest_template` (
    `entry`, `Method`, `RaceMask`, `ClassMask`, `MinLevel`, `SuggestedPlayers`, `QuestLevel`, `Type`, `Flags`,
    `NextQuestId`, `NextQuestInChain`, `Title`, `Details`, `Objectives`,
    `OfferRewardText`, `RequestItemsText`, `EndText`, `CompletedText`,
    `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`,
    `RewardItemId1`, `RewardItemId2`, `RewardItemId3`, `RewardItemId4`,
    `RewardItemCount1`, `RewardItemCount2`, `RewardItemCount3`, `RewardItemId4`,
    `RewardItemCount1`, `RewardItemCount2`, `RewardItemCount3`, `RewardItemCount4`,
    `RewardMoney`
) VALUES
(92003, 0, 1101, 1023, 80, 1, 80, 0, 0, 0, 92002,
 'Соединение Камней',
 'Создать Комбинированный Камень из трех основных камней.',
 'Собрать Камень Теневой Мощи, Камень Лунного Сияния и Камень Ночной Стойкости.',
 'Камни соединены. Вернитесь к Мастеру.',
 'Принесите соединенный камень Мастеру.',
 'Камни соединены в один артефакт.',
 'Камней соединено: 3/3', NULL, NULL, NULL,
 92006, 0, 0, 0, 1, 0, 0, 0, 15000000);

INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
(93001, 92001), (93001, 92002), (93001, 92003),
(93002, 92001);

INSERT INTO `creature_questender` (`id`, `quest`) VALUES
(93001, 92001), (93001, 92002), (93001, 92003),
(93002, 92001);

-- --------------------------------------------------------
-- 4. Спавны NPC камней (карта 0, около Stormwind)
-- --------------------------------------------------------
INSERT INTO `creature` (
    `id1`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`
) VALUES
(93001, 0, 0, 0, 1, 1, -8880.0, 520.0, 100.0, 0.0, 300);  -- Хранитель Легенд

SELECT 'Legendary Stones content installed' AS info;