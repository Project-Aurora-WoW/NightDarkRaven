-- Кастомные данные мира для проекта "Ночь темного Ворона"
-- Применять к БД world AzerothCore (WoW 3.3.5a)

USE world;

-- --------------------------------------------------------
-- 1. Шаблон существа: "Темный Ворон" (entry 90001)
-- --------------------------------------------------------
INSERT INTO `creature_template` (
    `entry`, `name`, `subname`, `IconName`, `gossip_menu_id`, `minlevel`, `maxlevel`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `unit_class`, `unit_flags`, `type`, `type_flags`, `family`, `Rank`, `BaseAttackTime`, `unit_flags2`, `dynamicflags`
) VALUES
(90001, 'Темный Ворон', 'Хранитель ночи', '', 0, 80, 80, 35, -- faction: neutral-ish player friendly (подправить под нужную фракцию)
    1, -- npcflag: gossip
    1.0, 2.5, 1, 0, -- unit_class, unit_flags
    7, 138936390, -- type: humanoid, Rank (normal)
    100, 0, 2000)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);;

-- --------------------------------------------------------
-- 2. Спавн существа (пример: seeker coordinates, подставить свои)
-- Карта 0 (Eastern Kingdoms), пример координат рядом с Stormwind
-- --------------------------------------------------------
INSERT INTO `creature` (
    `id1`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`
) VALUES
(90001, 0, 0, 0, 1, 1, -8900.0, 530.0, 100.0, 0.0, 300);

-- --------------------------------------------------------
-- 3. Gossip-тексты (gossip_menu_text)
-- --------------------------------------------------------
INSERT INTO `gossip_menu_text` (`menu_id`, `text_id_0`, `text_id_1`, `language`, `text`) VALUES
(90001, 90001, 0, 0, 'Ты пришёл в тёмный час, stranger. Я — Темный Ворон, хранитель Secretов Ночи. Что привело тебя ко мне?'),
(90002, 90002, 0, 0, 'Мир Ночь Темного Ворона — земля фэнтези, где магия и сталь решают судьбы. Исследуй эти земли осторожно...')
ON DUPLICATE KEY UPDATE `text` = VALUES(`text`);

-- --------------------------------------------------------
-- 4. Gossip-меню опций (gossip_menu_option)
-- --------------------------------------------------------
INSERT INTO `gossip_menu_option` (`menu_id`, `id`, `option_icon`, `option_text`, `option_id`, `npc_option_npcflag`, `action_menu_id`, `action_poi_id`, `box_coded`, `box_text`, `box_money`) VALUES
(90001, 0, 1, 'Приветствую, странник...', 1, 0, 0, 0, 0, '', 0),
(90001, 1, 1, 'Расскажи о мире Ночь Темного Ворона', 2, 0, 0, 0, 0, '', 0),
(90001, 2, 2, 'Прощай', 3, 0, 0, 0, 0, '', 0)
ON DUPLICATE KEY UPDATE `option_text` = VALUES(`option_text`);

-- --------------------------------------------------------
-- 5. Комментарий для администратора
-- --------------------------------------------------------
-- После импорта: перезагрузить worldserver, затем в игре:
-- .npc go 90001   (если включены GM-команды)
-- Или найти спавн по координатам выше.
SELECT 'NightDarkRaven module data installed' AS info;