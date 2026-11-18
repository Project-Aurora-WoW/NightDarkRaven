-- ============================================================================
Ночь темного Ворона — Система сокетов предметов (вставка камней в шмот)
-- База: world (AzerothCore 3.3.5a)
-- ============================================================================

USE world;

-- Таблица вставленных камней в предметы игроков
CREATE TABLE IF NOT EXISTS `character_item_sockets` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `character_guid` INT UNSIGNED NOT NULL,
    `item_guid` INT UNSIGNED NOT NULL,
    `item_entry` INT UNSIGNED NOT NULL,
    `slot` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `gem_entry` INT UNSIGNED NOT NULL,
    `socketed_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_char` (`character_guid`),
    INDEX `idx_item` (`item_guid`),
    INDEX `idx_gem` (`gem_entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Таблица сокетов предметов (какой предмет имеет какие сокеты)
CREATE TABLE IF NOT EXISTS `item_socket_template` (
    `item_entry` INT UNSIGNED NOT NULL,
    `slot` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `gem_color` ENUM('red','blue','yellow','purple','green','orange','cyan','white','meta') NOT NULL DEFAULT 'white',
    `is_empty` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    PRIMARY KEY (`item_entry`, `slot`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Сокеты для наградных предметов Иллидана (пример)
INSERT INTO `item_socket_template` (`item_entry`, `slot`, `gem_color`, `is_empty`) VALUES
(95001, 0, 'red', 1),      -- Перчатки Теневого Боя - красный сокет
(95001, 1, 'blue', 1),    -- Перчатки Теневого Боя - синий сокет
(95002, 0, 'cyan', 1),    -- Плащ Ночного Стража - циановый сокет
(95003, 0, 'purple', 1),  -- Кольцо Свежих Уроков - фиолетовый сокет
(95004, 0, 'white', 1),   -- Ошейник Теневого Ученика - белый сокет
(95005, 0, 'meta', 1),    -- Медальон Иллидана - мета сокет
(95006, 0, 'red', 1),     -- Клинок Первого Урока - красный сокет
(95006, 1, 'blue', 1);    -- Клинок Первого Урока - синий сокет

SELECT 'Item sockets tables installed' AS info;