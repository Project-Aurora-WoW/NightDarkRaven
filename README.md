# Ночь темного Ворона — MMORPG (AzerothCore + WoW 3.3.5a)

Проект фэнтези-MMORPG на базе эмулятора сервера **AzerothCore** (ветка в стилистике TrinityCore) и клиента **World of Warcraft 3.3.5a**.

| Компонент | Значение |
|-----------|----------|
| Движок сервера | AzerothCore (TrinityCore-стиль C++) |
| Клиент | WoW 3.3.5a (build 12340) |
| База данных | MySQL / MariaDB (world, characters, auth) |
| Язык серверного кода | C++17 + Lua (опционально, Eluna) |
| Протокол | WoW 3.3.5a realmlist/game |

## Структура репозитория

```
NightDarkRaven/
├── README.md
├── .gitignore
├── docs/                       # Документация, лор, концепт-арт, список мобов/квестов
├── server/                     # Серверная часть (AzerothCore)
│   ├── modules/
│   │   └── custom/
│   │       └── NightDarkRaven/ # Собственный модуль сервера (C++)
│   │           ├── CMakeLists.txt
│   │           ├── include/
│   │           └── src/
│   ├── luaship/                # Lua-скрипты (Eluna), загружаются без перекомпиляции
│   │   └── NightDarkRaven/
│   │       ├── npc_dark_raven.lua
│   │       ├── world_events.lua
│   │       ├── quest_shadow_feather.lua
│   │       └── README.md
│   ├── sql/                    # SQL-скрипты для БД (world/characters/auth)
│   ├── conf/                   # worldserver.conf, authserver.conf (шаблоны)
│   └── build_instructions.md
├── client/                     # Файлы клиента (не включает сам WoW 3.3.5a)
│   ├── configs/
│   │   └── realmlist.wtf
│   └── patches/                # Кастомные MPQ/ патчи клиента (опционально)
└── tools/                      # Вспомогательные скрипты (импорт, дампы, генераторы)
```

## Быстрый старт

### 1. Требования
- git, CMake 3.16+, GCC 9+ / MSVC 2019+
- MySQL 5.7+ / MariaDB 10.3+
- Установленный и патченый клиент WoW 3.3.5a
- 4+ ГБ ОЗУ, диск SSD рекомендуется

### 2. Сборка сервера (AzerothCore)
```bash
# Клонируем AzerothCore (официальный репозиторий)
git clone https://github.com/azerothcore/azerothcore-wotlk.git ac-server
cd ac-server

# Копируем наш модуль в дерево AzerothCore
cp -r ../NightDarkRaven/server/modules/custom/NightDarkRaven src/modules/custom/NightDarkRaven

# Подключаем модуль в корневой CMakeLists.txt (добавить строку):
# add_subdirectory(src/modules/custom/NightDarkRaven)

# Сборка
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo .
make -j$(nproc)
```

### 3. База данных
```bash
# Применить актуальную схему AzerothCore (из репозитория ac-server)
mysql -u root -p < ac-server/data/sql/create/mysql_create.sql

# Наши кастомные данные мира (моб "Темный Ворон", сплои, gossip-меню)
mysql -u root -p world < ../NightDarkRaven/server/sql/01_creatures_night_dark_raven.sql
```

### 4. Конфигурация
Отредактировать `worldserver.conf` и `authserver.conf` (подключение к БД, порты, реальмлист), затем запустить:
```bash
./authserver
./worldserver
```

### 5. Клиент
В папке с WoW 3.3.5a создать/отредактировать `WTF/realmlist.wtf`:
```
set realmlist logon.nightdarkraven.ru
```
(или `127.0.0.1` для локального теста).

## Модуль сервера: NightDarkRaven

### C++ модуль
Пример кастомного NPC — существ `"Темный Ворон"` (entry `90001`) с gossip-меню.
Реализовано в `server/modules/custom/NightDarkRaven/src/NightDarkRaven.cpp`.

### Lua-скрипты (Eluna)
Лёгкая логика (gossip, квесты, 세계events) вынесена в Lua, чтобы не пересобирать сервер при каждом изменении:
- `server/luaship/NightDarkRaven/npc_dark_raven.lua` — gossip-меню, фразы в бою/смерти
- `server/luaship/NightDarkRaven/world_events.lua` — приветствие при входе, объявление Ночи Ворона
- `server/luaship/NightDarkRaven/quest_shadow_feather.lua` — пример квеста "Перо Тени" с лутом

Подробнее: `server/luaship/NightDarkRaven/README.md` и раздел "Lua / Eluna" в `server/build_instructions.md`.

## Лицензия
Серверный код — AGPLv3 (в соответствии с AzerothCore). Клиент WoW 3.3.5a принадлежит Blizzard Entertainment; данный репозиторий **не содержит** файлов клиента.