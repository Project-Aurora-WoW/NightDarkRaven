-- ============================================================================
-- Ночь темного Ворона — C++ модуль: схема БД (база characters)
-- Выполнить один раз после установки модуля mod-nightdarkraven
-- ============================================================================

-- Навыки персонажа (постоянное хранение кастомных навыков 90001-90005)
CREATE TABLE IF NOT EXISTS `character_nightraven_skills` (
    `guid` INT UNSIGNED NOT NULL,
    `skill_id` SMALLINT UNSIGNED NOT NULL,
    `value` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`guid`, `skill_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Соло-режим персонажа
CREATE TABLE IF NOT EXISTS `character_solo_state` (
    `guid` INT UNSIGNED NOT NULL,
    `account_id` INT UNSIGNED NOT NULL DEFAULT 0,
    `solo_mode` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`guid`),
    INDEX `idx_account` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Выдан ли персонажу стартовый набор (защита от повторной выдачи)
CREATE TABLE IF NOT EXISTS `character_nightraven_kit` (
    `guid` INT UNSIGNED NOT NULL,
    `received_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SELECT 'NightDarkRaven C++ module schema installed' AS info;
