-- ============================================================================
-- Ночь темного Ворона — Синхронизация соло-режима (Web ↔ Lua)
-- База: world (AzerothCore 3.3.5a)
-- Позволяет веб-клиенту включать/выключать соло-режим, который применяется Lua-сервером
-- ============================================================================

USE world;

-- Таблица состояния соло-режима для персонажей
-- Web-клиент пишет сюда: solo_mode = 1/0
-- Lua-сервер читает и применяет множители сложности
CREATE TABLE IF NOT EXISTS `solo_state` (
    `character_guid` INT UNSIGNED NOT NULL PRIMARY KEY,
    `account_id` INT UNSIGNED NOT NULL,
    `solo_mode` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `companion_entry` INT UNSIGNED DEFAULT NULL,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_account` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Таблица активных компаньонов (synced с Lua)
CREATE TABLE IF NOT EXISTS `solo_companions` (
    `character_guid` INT UNSIGNED NOT NULL PRIMARY KEY,
    `companion_entry` INT UNSIGNED NOT NULL,
    `companion_guid` INT UNSIGNED DEFAULT NULL,
    `spawned_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_companion_entry` (`companion_entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Лог изменений соло-режима (для администрирования)
CREATE TABLE IF NOT EXISTS `solo_state_log` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `character_guid` INT UNSIGNED NOT NULL,
    `account_id` INT UNSIGNED NOT NULL,
    `solo_mode` TINYINT UNSIGNED NOT NULL,
    `changed_by` VARCHAR(64) DEFAULT 'web',
    `changed_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_char` (`character_guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SELECT 'Solo integration tables created' AS info;