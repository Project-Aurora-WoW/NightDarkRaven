-- ============================================================================
Ночь темного Ворона — Уроки Иллидана (PvP/PvE контент)
-- База: world (AzerothCore 3.3.5a)
-- Entry range: 94001-94020 (NPC), 95001-95030 (предметы уроков)
-- Quest range: 93001-93050 (квесты уроков)
-- ============================================================================

USE world;

-- --------------------------------------------------------
-- 1. NPC Иллидана и инструкторы
-- --------------------------------------------------------
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `scale`, `unit_class`, `unit_flags`, `type`, `type_flags`, `Rank`, `dmg_min`, `dmg_max`, `base_attack_time`) VALUES
(94001, 'Иллидан Ярче Звезд', 'Уроки Теней и Пламени', 80, 85, 35, 1, 1.0, 2.5, 1.2, 1, 0, 7, 138936390, 4, 500, 800, 1500),
(94002, 'Инструктор ПвП Ночи', 'Мастер дуэлей и арен', 80, 80, 35, 1, 1.0, 2.5, 1.0, 1, 0, 7, 138936390, 2, 200, 300, 2000),
(94003, 'Инструктор ПвЕ Ночи', 'Мастер рейдов и подземелий', 80, 80, 35, 1, 1.0, 2.5, 1.0, 1, 0, 7, 138936390, 2, 200, 300, 2000),
(94004, 'Цель Урока ПвП', 'Тренировочный манекен', 80, 80, 14, 0, 1.0, 2.5, 1.0, 1, 0, 7, 138936390, 0, 50, 100, 2000),
(94005, 'Цель Урока ПвЕ', 'Тренировочный моб рейда', 80, 80, 14, 0, 1.0, 2.5, 1.0, 1, 0, 7, 138936390, 1, 100, 200, 2000);

-- --------------------------------------------------------
-- 2. Предметы Уроков Иллидана
-- --------------------------------------------------------
INSERT INTO `item_template` (`entry`, `name`, `displayid`, `Quality`, `Flags`, `BuyPrice`, `SellPrice`, `InventoryType`, `Class`, `SubClass`, `MaxCount`, `bonding`, `description`) VALUES
-- Награда за уроки ПвП
(95001, 'Перчатки Теневого Боя', 1, 4, 0, 0, 5000, 0, 0, 0, 1, 1, 'Перчатки ученика Иллидана. Дают бонус к скорости атаки в ПвП.'),
(95002, 'Плащ Ночного Стража', 1, 4, 0, 0, 5000, 0, 0, 0, 1, 1, 'Плащ ученика Иллидана. Дает сопротивление магии тени.'),
-- Награда за уроки ПвЕ
(95003, 'Кольцо Свежих Уроков', 1, 4, 0, 0, 8000, 0, 0, 0, 1, 1, 'Кольцо ученика Иллидана. Дает бонус к урону по существам рейда.'),
(95004, 'Ошейник Теневого Ученика', 1, 4, 0, 0, 8000, 0, 0, 0, 1, 1, 'Ошейник ученика Иллидана. Дает бонус к здоровью.'),
-- Награда за полный курс
(95005, 'Медальон Иллидана Ярче Звезд', 1, 5, 0, 0, 25000, 0, 0, 0, 1, 1, 'Эпический медальон. Дает бонус ко всем характеристикам и урону тени.'),
(95006, 'Клинок Первого Урока', 1, 5, 0, 0, 30000, 0, 0, 0, 1, 1, 'Легендарный клинок ученика Иллидана. Оружие ближнего боя.');

-- --------------------------------------------------------
-- 3. Квесты Уроков Иллидана (PvP)
-- --------------------------------------------------------
-- 93001 Урок 1: Стойкость ПвП
INSERT INTO `quest_template` (
    `entry`, `Method`, `RaceMask`, `ClassMask`, `MinLevel`, `SuggestedPlayers`, `QuestLevel`, `Type`, `Flags`,
    `NextQuestId`, `NextQuestInChain`, `Title`, `Details`, `Objectives`,
    `OfferRewardText`, `RequestItemsText`, `EndText`, `CompletedText`,
    `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`,
    `RewardItemId1`, `RewardItemId2`, `RewardItemId3`, `RewardItemId4`,
    `RewardItemCount1`, `RewardItemCount2`, `RewardItemCount3`, `RewardItemCount4`,
    `RewardMoney`
) VALUES
(93001, 0, 1101, 1023, 80, 1, 80, 0, 0, 93002, 0,
 'Урок 1: Стойкость ПвП',
 'Иллидан Ярче Звезд учит выживанию в дуэли.',
 'Выдержать 5 минут в дуэли с Целью Урока ПвП.',
 'Вы выдержали урок. Вернитесь к Иллидану.',
 'Поговорите с Иллиданом о завершении урока.',
 'Урок стойкости выполнен.',
 'Времени выдержано: 5/5 мин', NULL, NULL, NULL,
 95001, 0, 0, 0, 1, 0, 0, 0, 20000000),
-- 93002 Урок 2: Точность ПвП
INSERT INTO `quest_template` (
    `entry`, `Method`, `RaceMask`, `ClassMask`, `MinLevel`, `SuggestedPlayers`, `QuestLevel`, `Type`, `Flags`,
    `NextQuestId`, `NextQuestInChain`, `Title`, `Details`, `Objectives`,
    `OfferRewardText`, `RequestItemsText`, `EndText`, `CompletedText`,
    `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`,
    `RewardItemId1`, `RewardItemId2`, `RewardItemId3`, `RewardItemId4`,
    `RewardItemCount1`, `RewardItemCount2`, `RewardItemCount3`, `RewardItemCount4`,
    `RewardMoney`
) VALUES
(93002, 0, 1101, 1023, 80, 1, 80, 0, 0, 93003, 93001,
 'Урок 2: Точность ПвП',
 'Иллидан учит наносить точные удары по цели.',
 'Нанести 50 критических ударов по Цели Урока ПвП.',
 'Точность достигнута. Вернитесь к Иллидану.',
 'Поговорите с Иллиданом о завершении урока.',
 'Урок точности выполнен.',
 'Критических ударов: 50/50', NULL, NULL, NULL,
 95002, 0, 0, 0, 1, 0, 0, 0, 22000000),
-- 93003 Урок 3: Мастерство ПвП
INSERT INTO `quest_template` (
    `entry`, `Method`, `RaceMask`, `ClassMask`, `MinLevel`, `SuggestedPlayers`, `QuestLevel`, `Type`, `Flags`,
    `NextQuestId`, `NextQuestInChain`, `Title`, `Details`, `Objectives`,
    `OfferRewardText`, `RequestItemsText`, `EndText`, `CompletedText`,
    `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`,
    `RewardItemId1`, `RewardItemId2`, `RewardItemId3`, `RewardItemId4`,
    `RewardItemCount1`, `RewardItemCount2`, `RewardItemCount3`, `RewardItemCount4`,
    `RewardMoney`
) VALUES
(93003, 0, 1101, 1023, 80, 1, 80, 0, 0, 93004, 93002,
 'Урок 3: Мастерство ПвП',
 'Иллидан учит комбинировать способности в бою.',
 'Провести комбинированную атаку на Цели Урока ПвП.',
 'Мастерство достигнуто. Вернитесь к Иллидану.',
 'Поговорите с Иллиданом о завершении урока.',
 'Урок мастерства выполнен.',
 'Комбинаций выполнено: 1/1', NULL, NULL, NULL,
 0, 0, 0, 0, 0, 0, 0, 0, 25000000);

INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
(94002, 93001), (94002, 93002), (94002, 93003);
INSERT INTO `creature_questender` (`id`, `quest`) VALUES
(94002, 93001), (94002, 93002), (94002, 93003);

-- --------------------------------------------------------
-- 4. Квесты Уроков Иллидана (PvE)
-- --------------------------------------------------------
-- 93004 Урок 4: Выживание в Рейде
INSERT INTO `quest_template` (
    `entry`, `Method`, `RaceMask`, `ClassMask`, `MinLevel`, `SuggestedPlayers`, `QuestLevel`, `Type`, `Flags`,
    `NextQuestId`, `NextQuestInChain`, `Title`, `Details`, `Objectives`,
    `OfferRewardText`, `RequestItemsText`, `EndText`, `CompletedText`,
    `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`,
    `RewardItemId1`, `RewardItemId2`, `RewardItemId3`, `RewardItemId4`,
    `RewardItemCount1`, `RewardItemCount2`, `RewardItemCount3`, `RewardItemCount4`,
    `RewardMoney`
) VALUES
(93004, 0, 1101, 1023, 80, 1, 80, 0, 0, 93005, 0,
 'Урок 4: Выживание в Рейде',
 'Инструктор ПвЕ Ночи учит выживанию в рейде.',
 'Выдержать 10 минут возле Цели Урока ПвЕ.',
 'Вы выдержали урок. Вернитесь к Инструктору.',
 'Поговорите с Инструктором о завершении урока.',
 'Урок выживания выполнен.',
 'Времени выдержано: 10/10 мин', NULL, NULL, NULL,
 95003, 0, 0, 0, 1, 0, 0, 0, 20000000),
-- 93005 Урок 5: Урон по Боссу
INSERT INTO `quest_template` (
    `entry`, `Method`, `RaceMask`, `ClassMask`, `MinLevel`, `SuggestedPlayers`, `QuestLevel`, `Type`, `Flags`,
    `NextQuestId`, `NextQuestInChain`, `Title`, `Details`, `Objectives`,
    `OfferRewardText`, `RequestItemsText`, `EndText`, `CompletedText`,
    `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`,
    `RewardItemId1`, `RewardItemId2`, `RewardItemId3`, `RewardItemId4`,
    `RewardItemCount1`, `RewardItemCount2`, `RewardItemCount3`, `RewardItemCount4`,
    `RewardMoney`
) VALUES
(93005, 0, 1101, 1023, 80, 1, 80, 0, 0, 93006, 93004,
 'Урок 5: Урон по Боссу',
 'Инструктор ПвЕ Ночи учит эффективному урону.',
 'Нанести 100000 урона Цели Урока ПвЕ.',
 'Урон нанесен. Вернитесь к Инструктору.',
 'Поговорите с Инструктором о завершении урока.',
 'Урон по боссу отработан.',
 'Урона нанесено: 100000/100000', NULL, NULL, NULL,
 95004, 0, 0, 0, 1, 0, 0, 0, 22000000),
-- 93006 Урок 6: Позиционирование
INSERT INTO `quest_template` (
    `entry`, `Method`, `RaceMask`, `ClassMask`, `MinLevel`, `SuggestedPlayers`, `QuestLevel`, `Type`, `Flags`,
    `NextQuestId`, `NextQuestInChain`, `Title`, `Details`, `Objectives`,
    `OfferRewardText`, `RequestItemsText`, `EndText`, `CompletedText`,
    `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`,
    `RewardItemId1`, `RewardItemId2`, `RewardItemId3`, `RewardItemId4`,
    `RewardItemCount1`, `RewardItemCount2`, `RewardItemId3`, `RewardItemId4`,
    `RewardItemCount1`, `RewardItemCount2`, `RewardItemCount3`, `RewardItemCount4`,
    `RewardMoney`
) VALUES
(93006, 0, 1101, 1023, 80, 1, 80, 0, 0, 93007, 93005,
 'Урок 6: Позиционирование',
 'Инструктор ПвЕ Ночи учит правильному позиционированию.',
 'Сохранить позицию в зоне безопасности 5 минут.',
 'Позиция сохранена. Вернитесь к Инструктору.',
 'Поговорите с Инструктором о завершении урока.',
 'Урок позиционирования выполнен.',
 'Времени в зоне: 5/5 мин', NULL, NULL, NULL,
 0, 0, 0, 0, 0, 0, 0, 0, 25000000);

INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
(94003, 93004), (94003, 93005), (94003, 93006);
INSERT INTO `creature_questender` (`id`, `quest`) VALUES
(94003, 93004), (94003, 93005), (94003, 93006);

-- --------------------------------------------------------
-- 5. Финальный квест: Полный Курс Иллидана
-- --------------------------------------------------------
-- 93007 Полный Курс
INSERT INTO `quest_template` (
    `entry`, `Method`, `RaceMask`, `ClassMask`, `MinLevel`, `SuggestedPlayers`, `QuestLevel`, `Type`, `Flags`,
    `NextQuestId`, `NextQuestInChain`, `Title`, `Details`, `Objectives`,
    `OfferRewardText`, `RequestItemsText`, `EndText`, `CompletedText`,
    `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`,
    `RewardItemId1`, `RewardItemId2`, `RewardItemId3`, `RewardItemId4`,
    `RewardItemCount1`, `RewardItemCount2`, `RewardItemCount3`, `RewardItemCount4`,
    `RewardMoney`
) VALUES
(93007, 0, 1101, 1023, 80, 1, 80, 0, 0, 0, 93006,
 'Полный Курс Иллидана',
 'Иллидан Ярче Звезд ждет завершения всего курса уроков.',
 'Завершить все уроки ПвП и ПвЕ.',
 'Курс завершен. Вернитесь к Иллидану.',
 'Поговорите с Иллиданом о награде.',
 'Полный курс Иллидана завершен.',
 'Курс завершен: 1/1', NULL, NULL, NULL,
 95005, 95006, 0, 0, 1, 1, 0, 0, 50000000);

INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
(94001, 93007);
INSERT INTO `creature_questender` (`id`, `quest`) VALUES
(94001, 93007);

-- --------------------------------------------------------
-- 6. Спавны NPC Иллидана и инструкторов
-- --------------------------------------------------------
INSERT INTO `creature` (`id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `modelid`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `animprogress`, `corpse_delay`) VALUES
(94001, 0, 0, 0, 1, 1, 0, -8850.0, 530.0, 100.0, 0.0, 300, 0, 0),  -- Иллидан Ярче Звезд
(94002, 0, 0, 0, 1, 1, 0, -8860.0, 530.0, 100.0, 0.0, 300, 0, 0),  -- Инструктор ПвП
(94003, 0, 0, 0, 1, 1, 0, -8870.0, 530.0, 100.0, 0.0, 300, 0, 0),  -- Инструктор ПвЕ
(94004, 0, 0, 0, 1, 1, 0, -8880.0, 540.0, 100.0, 0.0, 300, 0, 0),  -- Цель ПвП
(94005, 0, 0, 0, 1, 1, 0, -8880.0, 550.0, 100.0, 0.0, 300, 0, 0);  -- Цель ПвЕ

SELECT 'Illidan Lessons content installed' AS info;