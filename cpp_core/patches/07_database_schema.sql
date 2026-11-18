-- ============================================================================
Ночь темного Ворона — C++ ядро: схема базы данных
-- Выполнить перед запуском сервера после применения C++ патчей
-- ============================================================================

USE world;

-- Таблица навыков персонажей (перманентное хранение в C++)
CREATE TABLE IF NOT EXISTS `character_skills` (
    `guid` INT UNSIGNED NOT NULL,
    `skill_id` SMALLINT UNSIGNED NOT NULL,
    `value` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `max` SMALLINT UNSIGNED NOT NULL DEFAULT 375,
    PRIMARY KEY (`guid`, `skill_id`),
    INDEX `idx_guid` (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Таблица соло-состояния (перманентное хранение в C++)
CREATE TABLE IF NOT EXISTS `solo_state` (
    `character_guid` INT UNSIGNED NOT NULL PRIMARY KEY,
    `account_id` INT UNSIGNED NOT NULL,
    `solo_mode` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_account` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Добавить тестовые навыки для проверки (опционально)
-- INSERT INTO `character_skills` (`guid`, `skill_id`, `value`, `max`) VALUES
-- (1, 90005, 50, 375),  -- Приручение Теней для игрока с guid=1
-- (1, 90001, 100, 375); -- Ковка Теней для игрока с guid=1

SELECT 'NightRaven C++ database schema installed' AS info;