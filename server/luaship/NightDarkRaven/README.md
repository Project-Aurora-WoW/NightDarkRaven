# Lua-скрипты (Eluna) — Ночь темного Ворона

Архитектура модуля:

```
server/luaship/NightDarkRaven/
├── init.lua                  # Точка входа для Eluna
├── module.lua                # Основной модуль, регистрирует все подсистемы
├── systems/
│   ├── item_system.lua       # Предметы (entry 90001-91005)
│   ├── skill_system.lua      # Навыки/профессии (90001-90005)
│   ├── quest_system.lua      # Универсальный gossip для 11 кампаний
│   ├── zone_system.lua       # Кастомные зоны и телепорты
│   └── dungeon_system.lua    # Подземелья campaign 6, 7, 11
└── quests/
    ├── campaign_01_awakening.lua          (квесты 90101-90103)
    ├── campaign_02_shadows.lua            (квесты 90201-90204)
    ├── campaign_03_cursed_feathers.lua    (квесты 90301-90303)
    ├── campaign_04_blood_moon.lua         (квесты 90401-90404)
    ├── campaign_05_keepers.lua            (квесты 90501-90503)
    ├── campaign_06_forgotten_temple.lua   (квесты 90601-90604)
    ├── campaign_07_seal_of_darkness.lua   (квесты 90701-90703)
    ├── campaign_08_raven_blade.lua        (квесты 90801-90804)
    ├── campaign_09_night_watch.lua        (квесты 90901-90903)
    ├── campaign_10_raven_and_moon.lua     (квесты 91001-91004)
    └── campaign_11_end_of_night.lua       (квесты 91101-91105)
```

## Как загрузить

1. Убедитесь, что AzerothCore собран с поддержкой Lua/Eluna.
2. Положите папку `NightDarkRaven/` в директорию скриптов сервера (обычно `ac-server/luaship/`).
3. В `worldserver.conf` укажите путь:
   ```
   LuaEventPath = ../luaship/NightDarkRaven
   ```
   либо загрузите `init.lua` через механизм скриптов вашей сборки Eluna.

## База данных

Предметы, квесты, мобы и спавны импортируются SQL-файлами:
- `server/sql/02_campaigns_creatures.sql`
- `server/sql/03_campaigns_items.sql`
- `server/sql/04_campaigns_quests.sql`
- `server/sql/05_campaigns_loot.sql`
- `server/sql/06_campaigns_spawns.sql`

## Аутентификация

Конфиги в `server/conf/`:
- `authserver.conf.dist` — настройки AuthServer (порт 3724, подключение к БД `auth`)
- `worldserver.conf.dist` — настройки WorldServer (порт 8090, БД `world`/`characters`)

Скопируйте `.dist` файлы без расширения и отредактируйте пароли к MySQL.

## Клиент

`client/configs/realmlist.wtf` — укажите адрес сервера входа (по умолчанию `127.0.0.1` для локального теста).