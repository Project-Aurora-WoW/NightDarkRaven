# Сборка AzerothCore с модулем Ночь темного Ворона

Модуль подключается как обычный модуль AzerothCore — правки файлов ядра не нужны.

## Требования

- Git, CMake 3.16+, GCC 9+ / MSVC 2019+
- MySQL 5.7+ / MariaDB 10.3+
- boost, openssl, readline, ncurses
- 4+ ГБ ОЗУ, SSD рекомендуется

## Шаг 1: Клонировать AzerothCore

```bash
git clone https://github.com/azerothcore/azerothcore-wotlk.git ac-server
cd ac-server
```

## Шаг 2: Скопировать модуль

```bash
cp -r ../NightDarkRaven/cpp_core/module ./modules/mod-nightdarkraven
```

Если CMake не подхватывает папку автоматически, добавьте строку в корневой `CMakeLists.txt`:

```cmake
add_subdirectory(modules/mod-nightdarkraven)
```

## Шаг 3: Собрать сервер

```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DWITH_SCRIPTING=ON -DWITH_LUA=ON
make -j$(nproc)
```

## Шаг 4: База данных

```bash
# Создать схемы AzerothCore
mysql -u root -p < ../data/sql/create/mysql_create.sql
mysql -u root -p < ../data/sql/create/characters_create.sql
mysql -u root -p < ../data/sql/create/auth_create.sql

# Таблицы C++ модуля (база characters)
mysql -u root -p characters < ../modules/mod-nightdarkraven/data/sql/db-characters/nightdarkraven.sql

# Наш контент мира (кампании, мобы, предметы, квесты)
mysql -u root -p world < ../NightDarkRaven/server/sql/02_campaigns_creatures.sql
mysql -u root -p world < ../NightDarkRaven/server/sql/03_campaigns_items.sql
mysql -u root -p world < ../NightDarkRaven/server/sql/04_campaigns_quests.sql
mysql -u root -p world < ../NightDarkRaven/server/sql/05_campaigns_loot.sql
mysql -u root -p world < ../NightDarkRaven/server/sql/06_campaigns_spawns.sql
mysql -u root -p world < ../NightDarkRaven/server/sql/07_campaigns_solo.sql
```

## Шаг 6: Запуск

```bash
./authserver
./worldserver
```

## Проверка работы C++ изменений

### Навыки
В игровом чате (через GM-команду или Lua):
```
.lua print(NightDarkRaven.GetSkill(player, 90005))
```

### Соло-режим
```
.lua NightDarkRaven.SetSoloMode(player, true)
```

Урон мобов вокруг игрока снижается на 30% (`SoloDamageMultiplier`).

## Удаление

Модуль не меняет файлы ядра, поэтому достаточно удалить `modules/mod-nightdarkraven`
и таблицы:

```sql
DROP TABLE IF EXISTS `character_nightraven_skills`;
DROP TABLE IF EXISTS `character_solo_state`;
```

## Структура файлов

```
cpp_core/
├── README.md
├── BUILD.md
└── module/
    ├── CMakeLists.txt
    ├── include/
    │   └── mod_nightdarkraven.h
    ├── src/
    │   └── mod_nightdarkraven.cpp
    └── data/
        └── sql/
            └── db-characters/
                └── nightdarkraven.sql
```

## Соответствие Lua ↔ C++

| Функция | C++ (`namespace NightDarkRaven`) | Таблица БД |
|---------|----------------------------------|------------|
| Навык игрока | `GetSkill(player, id)` | `character_nightraven_skills` |
| Установить навык | `SetSkill(player, id, value)` | то же |
| Повысить навык | `SkillUp(player, id, amount)` | то же |
| Есть навык | `HasSkill(player, id)` | то же |
| Соло-режим вкл | `SetSoloMode(player, true)` | `character_solo_state` |
| Соло-режим выкл | `SetSoloMode(player, false)` | то же |
| Проверить соло | `IsSoloMode(player)` | `character_solo_state` |