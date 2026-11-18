# C++ ядро AzerothCore — Ночь темного Ворона

Патчи для ядра AzerothCore (ветка wotlk / WoW 3.3.5a). Переносят навыки и соло-режим из Lua в C++ для производительности и постоянного хранения.

## Что переносится в C++

| Система | Файлы ядра | Что делает |
|---------|------------|------------|
| Навыки/профессии | `Player.cpp`, `Player.h`, `Database/DatabaseWorkerPool.cpp` | Постоянное хранение в таблице `character_skills` |
| Соло-режим (урон/здоровье) | `Unit.cpp`, `Unit.h` | Модификатор урона (-30%) и здоровья (-40%) для соло-игроков |
| Компаньоны (ИИ) | `Pet.cpp`, `CreatureAI.cpp` | Поведение компаньона в режиме следования |

## Необходимые изменения в БД

Выполнить перед запуском сервера:

```sql
-- Таблица навыков персонажей (перманентное хранение)
CREATE TABLE IF NOT EXISTS `character_skills` (
    `guid` INT UNSIGNED NOT NULL,
    `skill_id` SMALLINT UNSIGNED NOT NULL,
    `value` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `max` SMALLINT UNSIGNED NOT NULL DEFAULT 375,
    PRIMARY KEY (`guid`, `skill_id`),
    INDEX `idx_guid` (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Таблица соло-состояния (если не создана через SQL)
CREATE TABLE IF NOT EXISTS `solo_state` (
    `character_guid` INT UNSIGNED NOT NULL PRIMARY KEY,
    `account_id` INT UNSIGNED NOT NULL,
    `solo_mode` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## Как применить патчи

1. Скачать AzerothCore (ветка wotlk):
   ```bash
   git clone https://github.com/azerothcore/azerothcore-wotlk.git ac-server
   cd ac-server
   ```

2. Скопировать патчи в корень репозитория AzerothCore и применить:
   ```bash
   git apply ../NightDarkRaven/cpp_core/patches/*.patch
   ```

3. Собрать сервер:
   ```bash
   mkdir build && cd build
   cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DWITH_SCRIPTING=ON -DWITH_LUA=ON
   make -j$(nproc)
   ```

4. Импортировать SQL схемы в базы данных

5. Запустить сервер

## Взаимодействие с Lua

C++ ядро предоставляет базовую функциональность, Lua-скрипты обрабатывают контент:

- C++: навыки в БД, модификаторы урона/здоровья, ИИ компаньонов
- Lua: квесты, gossip-меню, события мира, луты, патчи клиента

Lua может читать навыки игрока через стандартный API `GetSkillValue()` и `HasSkill()` после патчей C++.