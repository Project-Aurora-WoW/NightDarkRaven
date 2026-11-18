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
│   │       ├── init.lua
│   │       ├── module.lua
│   │       ├── systems/
│   │       │   ├── item_system.lua
│   │       │   ├── skill_system.lua
│   │       │   ├── quest_system.lua
│   │       │   ├── zone_system.lua
│   │       │   ├── dungeon_system.lua
│   │       │   ├── solo_system.lua
│   │       │   ├── companion_system.lua
│   │       │   ├── scaling_system.lua
│   │       │   └── solo_dungeon_system.lua
│   │       └── quests/
│   │           ├── campaign_01..11.lua
│   │           ├── solo_quests.lua
│   │           └── campaign_manager.lua
│   ├── sql/                    # SQL-скрипты для БД (world/characters/auth)
│   │   ├── 01_creatures_night_dark_raven.sql
│   │   ├── 02_campaigns_creatures.sql
│   │   ├── 03_campaigns_items.sql
│   │   ├── 04_campaigns_quests.sql
│   │   ├── 05_campaigns_loot.sql
│   │   ├── 06_campaigns_spawns.sql
│   │   └── 07_campaigns_solo.sql
│   ├── conf/                   # worldserver.conf, authserver.conf (шаблоны)
│   └── build_instructions.md
├── client/                     # Файлы клиента WoW 3.3.5a (не включает сам клиент)
│   ├── configs/
│   │   └── realmlist.wtf
│   └── patches/                # Кастомные MPQ/ патчи клиента (опционально)
├── web/                        # Веб-клиент (Node.js + Express + Vanilla JS)
│   ├── README.md
│   ├── package.json
│   ├── config.example.json
│   ├── .gitignore
│   ├── server/
│   │   ├── index.js
│   │   ├── config.js
│   │   └── routes/
│   │       ├── auth.js
│   │       ├── characters.js
│   │       ├── world.js
│   │       └── solo.js
│   └── client/
│       ├── index.html
│       ├── css/style.css
│       └── js/{api,app}.js
└── tools/                      # Вспомогательные скрипты (импорт, дампы, генераторы)
```

## Быстрый старт

### 1. Требования
- git, CMake 3.16+, GCC 9+ / MSVC 2019+
- MySQL 5.7+ / MariaDB 10.3+
- Установленный и патченый клиент WoW 3.3.5a
- Node.js 16+ (для веб-клиента)
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

## 11 кампаний «Ночь темного Ворона»

SQL-контент для мира (БД `world`) — кампании 1–11, мобы, предметы, квесты, лут, спавны:

| Файл | Содержимое |
|------|------------|
| `server/sql/02_campaigns_creatures.sql` | 44 моба/NPC (entry 90001–90112), дачители каждой кампании |
| `server/sql/03_campaigns_items.sql` | 39 предметов (entry 90001–90113), квестовые и награды |
| `server/sql/04_campaigns_quests.sql` | 45 квестов (90101–91105), цепочки, creature_queststarter/ender |
| `server/sql/05_campaigns_loot.sql` | Лут мобов для кампаний 1–11 |
| `server/sql/06_campaigns_spawns.sql` | Спавны дачителей и мобов (карта 0, примерные координаты) |

### Список кампаний
1. Пробуждение Ворона (90101–90103)
2. Тени Вороновой Горы (90201–90204)
3. Проклятие Перьев (90301–90303)
4. Кровавая Луна (90401–90404)
5. Хранители Ночи (90501–90503)
6. Забытый Храм (90601–90604)
7. Печать Тьмы (90701–90703)
8. Вороновой Клинок (90801–90804)
9. Ночной Дозор (90901–90903)
10. Ворон и Луна (91001–91004)
11. Конец Ночи (91101–91105,finale)

Квесты цепочечные: `NextQuestInChain` связывает кампании, прохождение открывает следующую.

## Lua-модуль NightDarkRaven (Eluna)

Весь серверный квестовый и игровой логика вынесена в Lua-модуль под AzerothCore:

```
server/luaship/NightDarkRaven/
├── init.lua                  # Точка входа для Eluna
├── module.lua                # Основной модуль
├── systems/
│   ├── item_system.lua       # Предметы (entry 90001–91005)
│   ├── skill_system.lua      # Навыки/профессии (90001–90005)
│   ├── quest_system.lua      # Универсальный gossip для 11 кампаний
│   ├── zone_system.lua       # Кастомные зоны и телепорты
│   └── dungeon_system.lua    # Подземелья кампаний 6, 7, 11
└── quests/                   # 11 файлов кампаний (лут мобов)
```

### Навыки (профессии)
- `Ковка Теней` (90001) — ковка оружия из теневого железа
- `Извлечение Перьев` (90002) — сбор перьев магических птиц
- `Зелья Ночи` (90003) — варка зелий под Луной
- `Чтение Рун` (90004) — gravaция древних рун
- `Приручение Теней` (90005) — приручение теневых зверей

## Конфигурация аутентификации (Auth)

`server/conf/authserver.conf.dist` — AuthServer (порт 3724, БД `auth`)  
`server/conf/worldserver.conf.dist` — WorldServer (порт 8090, БД `world`/`characters`)

Скопируйте `.dist` файлы без расширения и укажите пароли к MySQL.

### Реалм в БД `auth`
```sql
INSERT INTO `realmlist` (`name`, `address`, `localAddress`, `port`, `gamebuild`)
VALUES ('Ночь темного Ворона', '127.0.0.1', '127.0.0.1', 8090, 12340);
```

## Веб-клиент (`web/`)

Веб-интерфейс на Node.js + Express для управления аккаунтом, персонажами и просмотра мира через браузер.

### Быстрый запуск
```bash
cd web
npm install
cp config.example.json config.json
# Отредактировать config.json: указать пароли к MySQL (auth/characters/world)
npm start
```
Веб-клиент доступен на `http://localhost:3000`.

### Возможности
- Авторизация через аккаунт AzerothCore (БД `auth`)
- Список персонажей (БД `characters`)
- Просмотр кампаний, зон, подземелий, предметов (БД `world`)
- Соло-режим и компаньоны (интеграция с Lua-сервером)

Подробнее: `web/README.md`.

## Лицензия
Серверный код — AGPLv3 (в соответствии с AzerothCore). Клиент WoW 3.3.5a принадлежит Blizzard Entertainment; данный репозиторий **не содержит** файлов клиента.