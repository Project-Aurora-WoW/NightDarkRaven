# Сборка AzerothCore с патчами Ночь темного Ворона

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

## Шаг 2: Применить C++ патчи

Из папки проекта NightDarkRaven:

```bash
# Применить все патчи ядра
git apply ../NightDarkRaven/cpp_core/patches/01_player_skills.h.patch
git apply ../NightDarkRaven/cpp_core/patches/02_player_skills.cpp.patch
git apply ../NightDarkRaven/cpp_core/patches/03_unit_solo.h.patch
git apply ../NightDarkRaven/cpp_core/patches/04_unit_solo.cpp.patch
git apply ../NightDarkRaven/cpp_core/patches/05_worldserver_solo_login.patch

# Lua мост (если компилируете с Eluna)
git apply ../NightDarkRaven/cpp_core/patches/06_lua_bridge.cpp
```

> **Примечание:** Патчи созданы как unified diff. Если они не применяются автоматически, используйте код из патчей для ручного вставления в соответствующие файлы.

## Шаг 3: Добавить Lua мост в сборку (опционально)

Если используете Eluna/Lua и хотите мост к C++ функциям:

1. Скопируйте `06_lua_bridge.cpp` в `src/server/game/Scripting/Lua/` (или соответствующую папку вашей версии AzerothCore)
2. Добавьте его в `CMakeLists.txt` того же каталога:
   ```cmake
   set(LUA_SCRIPTS
       ${LUA_SCRIPTS}
       ${CMAKE_CURRENT_SOURCE_DIR}/NightRavenLuaBridge.cpp
   )
   ```

## Шаг 4: Собрать сервер

```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DWITH_SCRIPTING=ON -DWITH_LUA=ON
make -j$(nproc)
```

## Шаг 5: База данных

```bash
# Создать схемы AzerothCore
mysql -u root -p < ../data/sql/create/mysql_create.sql
mysql -u root -p < ../data/sql/create/characters_create.sql
mysql -u root -p < ../data/sql/create/auth_create.sql

# Наши таблицы C++
mysql -u root -p world < ../NightDarkRaven/cpp_core/patches/07_database_schema.sql

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
.lua print(player:GetNightRavenSkillValue(90005))
```

### Соло-режим
```
.lua player:SetSoloModeEnabled(true)
```

Мобы вокруг игрока должны получить -40% здоровья и -30% урона.

## Откат изменений

```bash
git apply -R ../NightDarkRaven/cpp_core/patches/0*.patch
```

## Структура файлов

```
cpp_core/
├── README.md
├── BUILD.md
└── patches/
    ├── 01_player_skills.h.patch
    ├── 02_player_skills.cpp.patch
    ├── 03_unit_solo.h.patch
    ├── 04_unit_solo.cpp.patch
    ├── 05_worldserver_solo_login.patch
    ├── 06_lua_bridge.cpp
    └── 07_database_schema.sql
```

## Соответствие Lua ↔ C++

| Функция | Lua (Eluna) | C++ (ядро) |
|---------|-------------|------------|
| Навык игрока | `GetNightRavenSkillValue()` | `Player::GetNightRavenSkillValue()` |
| Установить навык | `SetNightRavenSkillValue()` | `Player::SetNightRavenSkillValue()` |
| Повысить навык | `NightRavenSkillUp()` | `Player::NightRavenSkillUp()` |
| Есть навык | `HasNightRavenSkill()` | `Player::HasNightRavenSkill()` |
| Соло-режим вкл | `SoloEnable()` | `Player::SetSoloModeEnabled(true)` |
| Соло-режим выкл | `SoloDisable()` | `Player::SetSoloModeEnabled(false)` |
| Проверить соло | `SoloIsEnabled()` | `Player::IsSoloModeEnabled()` |
| Множитель HP | — | `Unit::GetSoloHealthMultiplier()` (0.60) |
| Множитель урона | — | `Unit::GetSoloDamageMultiplier()` (0.70) |