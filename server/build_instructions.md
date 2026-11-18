# Инструкция по сборке сервера (AzerothCore + модуль NightDarkRaven)

## Предварительные требования
- Git, CMake 3.16+, GCC 9+/Clang или MSVC 2019+
- MySQL 5.7+ / MariaDB 10.3+ с запущенным сервером
- boost, openssl, readline, ncurses (зависимости AzerothCore)

## Шаги

1. **Клонировать AzerothCore**
   ```bash
   git clone https://github.com/azerothcore/azerothcore-wotlk.git ac-server
   cd ac-server
   ```

2. **Добавить модуль NightDarkRaven**
   ```bash
   mkdir -p src/modules/custom
   cp -r /путь/к/NightDarkRaven/server/modules/custom/NightDarkRaven src/modules/custom/NightDarkRaven
   ```

3. **Подключить модуль в CMake**
   В корневом `CMakeLists.txt` AzerothCore добавить (примерно в раздел модулей):
   ```cmake
   add_subdirectory(src/modules/custom/NightDarkRaven)
   ```

4. **Собрать**
   ```bash
   mkdir build && cd build
   cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
   make -j$(nproc)
   ```

5. **База данных**
   ```bash
   # Создать схемы AzerothCore (из data/sql/create/)
   mysql -u root -p < ../data/sql/create/mysql_create.sql
   mysql -u root -p characters < ../data/sql/create/characters_create.sql
   mysql -u root -p auth < ../data/sql/create/auth_create.sql

   # Наш кастомный контент
   mysql -u root -p world < /путь/к/NightDarkRaven/server/sql/01_creatures_night_dark_raven.sql
   ```

6. **Конфиги**
   Скопировать `worldserver.conf.dist` → `worldserver.conf` и `authserver.conf.dist` → `authserver.conf`.
   Указать параметры подключения к MySQL и реальмлист.

7. **Запуск**
   ```bash
   ./authserver
   ./worldserver
   ```

8. **Pроверка в игре**
   Подключиться клиентом WoW 3.3.5a, найти NPC "Темный Ворон" (или вызвать `.npc go 90001` через GM-команду) и пообщаться через gossip-меню.

## 9. Lua / Eluna (опционально)

AzerothCore поддерживает серверные скрипты на Lua через движок **Eluna**.  
Это позволяет менять поведение NPC, квесты и события мира без перекомпиляции C++.

### Включение Eluna при сборке
При конфигурации CMake AzerothCore убедитесь, что скриптовая поддержка включена (имя опции зависит от версии ветки):
```bash
cmake .. -DWITH_SCRIPTING=ON -DWITH_LUA=ON
make -j$(nproc)
```

### Установка скриптов
Скопируйте папку со скриптами в директорию скриптов AzerothCore (обычно `luaship/`):
```bash
cp -r /путь/к/NightDarkRaven/server/luaship/NightDarkRaven ac-server/luaship/NightDarkRaven
```

Перезапустите `worldserver`. В консоли должны появиться сообщения:
```
[NightDarkRaven] Lua: npc_dark_raven (entry 90001) loaded.
[NightDarkRaven] Lua: world_events loaded.
[NightDarkRaven] Lua: quest_shadow_feather (quest 90001) loaded.
```

### Скрипты проекта
- `npc_dark_raven.lua` — gossip-меню NPC "Темный Ворон"
- `world_events.lua` — приветствие при входе, объявление Ночи Ворона
- `quest_shadow_feather.lua` — пример квеста "Перо Тени" с лутом мобов

### База данных для квестов
Перед использованием `quest_shadow_feather.lua` создайте в БД `world`:
- `quest_template` (quest 90001)
- `creature_queststarter` / `creature_questender` (NPC 90001)
- `item_template` (предмет 90001 "Перо Тени")
- `creature_loot_template` (моб 90002 дропает перо)