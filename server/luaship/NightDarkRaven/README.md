# Lua-скрипты (Eluna) — Ночь темного Ворона

Архитектура модуля:

```
server/luaship/NightDarkRaven/
├── init.lua                  # Точка входа для Eluna
├── module.lua                # Основной модуль, регистрирует все подсистемы
├── systems/
│   ├── item_system.lua       # Предметы (entry 90001–91005)
│   ├── skill_system.lua      # Навыки/профессии (90001–90005)
│   ├── quest_system.lua      # Универсальный gossip для 11 кампаний
│   ├── zone_system.lua       # Кастомные зоны и точки телепорта
│   ├── dungeon_system.lua    # Подземелья кампаний 6, 7, 11
│   ├── solo_system.lua       # Соло-режим: масштабирование сложности под 1 игрока
│   ├── companion_system.lua  # Компаньоны-боты для соло-игроков
│   ├── scaling_system.lua    # Масштабирование квестов и мобов под соло
│   └── solo_dungeon_system.lua  # Соло-подземелья (инстансы)
└── quests/
    ├── campaign_01..11.lua   # Лут мобов для всех кампаний
    ├── solo_quests.lua       # Соло-квесты (95001-95002)
    └── campaign_manager.lua  # (устарело, заменено на module.lua + systems)
```

## Соло-режим (одиночное прохождение MMORPG)

### Что включает
1. **Соло-режим** (`solo_system.lua`) — включение/выключение через gossip NPC "Темный Ворон". Мобы вокруг соло-игрока получают `-40% HP` и `-30% урона`.
2. **Компаньоны** (`companion_system.lua`) — 3 спутника: Теневой Врон (урон), Страж Ночи (танк), Целитель Лунный (хил). Призываются через квест 95002.
3. **Масштабирование квестов** (`scaling_system.lua`) — соло-игроку нужно собирать меньше предметов квеста (коэффициент 0.5–0.9 от уровня).
4. **Соло-подземелья** (`solo_dungeon_system.lua`) — 3 инстанса для одного игрока (уровни 10–80).
5. **Соло-квесты** (`solo_quests.lua`) — квесты 95001 ("Испытание Одиночества") и 95002 ("Путник Теней") с наградой компаньона и кольца.

### Как включить соло-режим
1. Подойдите к NPC "Темный Ворон" (entry 90001).
2. Выберите gossip "Включить соло-режим".
3. Сложность мобов рядом адаптируется автоматически.

### Подключение
1. Убедитесь, что AzerothCore собран с поддержкой Lua/Eluna.
2. Положите папку `NightDarkRaven/` в директорию скриптов сервера (обычно `ac-server/luaship/`).
3. В `worldserver.conf` укажите путь:
   ```
   LuaEventPath = ../luaship/NightDarkRaven
   ```

## База данных

Предметы, квесты, мобы и спавны импортируются SQL-файлами:
- `server/sql/02_campaigns_creatures.sql`
- `server/sql/03_campaigns_items.sql`
- `server/sql/04_campaigns_quests.sql`
- `server/sql/05_campaigns_loot.sql`
- `server/sql/06_campaigns_spawns.sql`

## Аутентификация

Конфиги в `server/conf/`:
- `authserver.conf.dist` — AuthServer (порт 3724, БД `auth`)
- `worldserver.conf.dist` — WorldServer (порт 8090, БД `world`/`characters`)

Скопируйте `.dist` файлы без расширения и отредактируйте пароли к MySQL.

## Клиент

`client/configs/realmlist.wtf` — укажите адрес сервера входа (по умолчанию `127.0.0.1` для локального теста).