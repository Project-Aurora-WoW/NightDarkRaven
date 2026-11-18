-- ============================================================================
Ночь темного Ворона — Система патчей клиента через БД
-- База: world (AzerothCore 3.3.5a)
-- Отслеживание и автоматическое применение патчей клиента WoW 3.3.5a
-- ============================================================================

USE world;

-- Таблица патчей клиента (реальмлист, MPQ, конфиги)
CREATE TABLE IF NOT EXISTS `client_patches` (
    `patch_id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `patch_name` VARCHAR(100) NOT NULL,
    `patch_type` ENUM('realmlist', 'mpq', 'config', 'wtf', 'db') NOT NULL DEFAULT 'config',
    `target_file` VARCHAR(255) NOT NULL,
    `target_path` VARCHAR(500) DEFAULT NULL,
    `content` TEXT NOT NULL,
    `checksum` VARCHAR(64) DEFAULT NULL,
    `version_from` VARCHAR(20) DEFAULT NULL,
    `version_to` VARCHAR(20) DEFAULT NULL,
    `is_required` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `is_applied` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `applied_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_type` (`patch_type`),
    INDEX `idx_applied` (`is_applied`),
    INDEX `idx_name` (`patch_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- История применения патчей клиента
CREATE TABLE IF NOT EXISTS `client_patch_log` (
    `log_id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `patch_id` INT UNSIGNED NOT NULL,
    `client_version` VARCHAR(20) DEFAULT NULL,
    `account_id` INT UNSIGNED DEFAULT NULL,
    `status` ENUM('success','failed','skipped') NOT NULL,
    `message` TEXT,
    `applied_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`patch_id`) REFERENCES `client_patches` (`patch_id`) ON DELETE CASCADE,
    INDEX `idx_patch` (`patch_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Регистрация базового патча realmlist для сервера
INSERT INTO `client_patches` (
    `patch_name`, `patch_type`, `target_file`, `target_path`, `content`,
    `version_from`, `version_to`, `is_required`
) VALUES (
    'Realmlist Ночь темного Ворона',
    'realmlist',
    'realmlist.wtf',
    'WTF/',
    'set realmlist 127.0.0.1',
    '3.3.5a',
    '3.3.5a',
    1
);

-- Регистрация патча конфига клиента
INSERT INTO `client_patches` (
    `patch_name`, `patch_type`, `target_file`, `target_path`, `content`,
    `version_from`, `version_to`, `is_required`
) VALUES (
    'Конфиг клиента WTF',
    'wtf',
    'config.wtf',
    'WTF/',
    'SET portal "127.0.0.1"\nSET realmList "127.0.0.1"\n',
    '3.3.5a',
    '3.3.5a',
    1
);

SELECT 'Client patches tables created' AS info;