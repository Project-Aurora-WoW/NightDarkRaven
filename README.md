# Ночь темного Ворона — MMORPG (AzerothCore + WoW 3.3.5a)

Проект фэнтези-MMORPG на базе эмулятора сервера **AzerothCore** (ветка в стилистике TrinityCore) и клиента **World of Warcraft 3.3.5a**.

| Компонент | Значение |
|-----------|----------|
| Движок сервера | AzerothCore (TrinityCore-стиль C++) |
| Клиент | WoW 3.3.5a (build 12340) |
| База данных | MySQL / MariaDB (world, characters, auth) |
| Язык серверного кода | C++17 + Lua (опционально, Eluna) |
| Протокол | WoW 3.3.5a realmlist/game |
| Основные модули | 11 кампаний, Соло-режим, Камни Легенды, Уроки Иллидана |

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
│   ├── patches/                # Кастомные MPQ/ патчи клиента (опционально)
│   └── custom_content/         # Кастомные модели, текстуры и MPQ архив клиента
│       ├── README.md
│       ├── models/             # Кастомные 3D модели (.mdl, .m2)
│       ├── textures/           # Кастомные текстуры (.blp)
│       ├── mpq/                # Сборка MPQ архива (build_mpq.bat/.sh)
│       └── tools/              # Инструменты конвертации (m2, blp)
├── web/                        # Веб-клиент (Node.js + Express + Vanilla JS)
│   ├── README.md
│   ├── package.json
│   ├── config.example.json
│   ├── .gitignore
│   ├── ssl/                    # SSL-сертификаты (самоподписанные для разработки)
│   │   ├── generate_self_signed.sh
│   │   └── generate_self_signed.bat
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
├── launcher/                   # Лаунчер для WoW 3.3.5a
│   ├── README.md
│   ├── config.example.json
│   ├── launcher.bat            # Batch-лаунчер (Windows)
│   ├── launcher.ps1            # PowerShell-лаунчер (Windows)
│   └── patch_realmlist.py      # Патч realmlist.wtf (Python)
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
- Админ-панель (`/admin`) — статистика, управление соло-игроками, рестарт сервера (требует GM-прав)
- Управление квестами кампаний (`/campaigns-admin`) — включение/выключение квестов, изменение уровней
- Автоимпорт SQL (`/sqlimport`) — импорт `.sql` файлов из `server/sql/` в БД `world`
- Патчи клиента (`/clientpatches`) — управление патчами клиента WoW 3.3.5a через БД
- Авто-рестарт WorldServer при изменении Lua-файлов (watcher)
- Discord уведомления о соло-игроках (webhook)

Подробнее: `web/README.md` и `server/build_instructions.md` (разделы 17-19).

## SSL / HTTPS (веб-клиент)

Для разработки можно сгенерировать самоподписанный сертификат:
```bash
cd web/ssl
./generate_self_signed.sh   # Linux/macOS
generate_self_signed.bat    # Windows
```

Затем в `web/config.json` включить HTTPS:
```json
{
  "server": { "http": true, "https": true, "httpsPort": 3443 }
}
```

В проде замените на сертификат Let's Encrypt или коммерческий.

## Лаунчер WoW 3.3.5a (`launcher/`)

| Вариант | Папка | Описание |
|---------|-------|----------|
| Десктоп (Windows) | `launcher/` | `launcher.bat` / `launcher.ps1` — патчит `realmlist.wtf` и запускает `WoW.exe` |
| Мобильный PWA | `launcher/mobile/` | Веб-PWA для Android/iOS, устанавливается на домашний экран |
| Нативный Android (Kotlin) | `launcher/native/android/` | Нативное приложение с WebView и JS-интерфейсом |
| Нативный iOS (Swift) | `launcher/native/ios/` | Нативное приложение с WKWebView |
| Python-патч | `launcher/patch_realmlist.py` | Кросс-платформенный патч `realmlist.wtf` |

Подробнее: `launcher/README.md`.

## Кастомные MPQ ресурсы клиента (`client/custom_content/`)

Кастомные модели, текстуры и MPQ архив для клиента WoW 3.3.5a.

### ⚠️ Важно

Сам клиент WoW 3.3.5a и его оригинальные ресурсы **НЕ входят** в этот репозиторий (авторские права Blizzard Entertainment). Эта папка содержит инструменты, шаблоны и инструкции для создания собственных ресурсов на основе уже установленного у вас клиента.

### Структура

```
client/custom_content/
├── README.md         # Полная инструкция по созданию MPQ
├── models/           # Кастомные 3D модели (.mdl, .m2)
├── textures/         # Кастомные текстуры (.blp)
├── mpq/              # Сборка MPQ архива (build_mpq.bat/.sh)
└── tools/            # Инструменты конвертации (m2, blp)
```

### Быстрый старт

1. Установите клиент WoW 3.3.5a (build 12340)
2. Создайте кастомные модели и текстуры (инструкции в `client/custom_content/mpq/README.md`)
3. Соберите их в `patch.MPQ` с помощью скриптов в `client/custom_content/mpq/`
4. Положите `patch.MPQ` в папку с `WoW.exe` (рядом с клиентом)
5. Запустите клиент — кастомные ресурсы загрузятся автоматически

### Связь с сервером AzerothCore

Для кастомной модели NPC в базе данных:

```sql
INSERT INTO `creature_template` (`entry`, `name`, `modelid_1`, `faction`, `npcflag`) VALUES
(92001, 'Кастомный Ворон', 25001, 35, 1);
```

Где `25001` — это `displayid` вашей кастомной модели в клиенте.

### Подробнее

`client/custom_content/README.md`  
`client/custom_content/mpq/README.md`

## Админ-панель, Discord и авто-рестарт

Все подробности в `server/build_instructions.md` (разделы 12-14):
- Админ-панель веб-клиента для GM-управления соло-игроками
- Интеграция с Discord (уведомления о соло-режиме, подземельях, компаньонах, рестартах)
- Авто-рестарт WorldServer при изменении Lua-файлов сервера

## Камни Легенды Ночных Стражей (`server/sql/10_legendary_stones.sql`)

Система сокетных légendарных камней с уникальными эффектами:

| Камень | Тип | Эффект | Качество |
|--------|-----|--------|----------|
| Камень Теневой Мощи | Красный | +500 к силе атаки | Эпический |
| Камень Лунного Сияния | Синий | +100 к интеллекту | Эпический |
| Камень Ночной Стойкости | Желтый | +150 к выносливости | Эпический |
| Камень Воронового Крика | Фиолетовый | +0.5% к шансу крита | Редкий |
| Камень Вечной Тьмы | Зеленый | +25 к мастерству | Редкий |
| Камень Звездного Падения | Оранжевый | +200 к силе + интеллект | Легендарный |
| Камень Пустотного Эха | Циан | +300 урона тенью | Легендарный |
| Камень Ночного Стража | Белый | +1000 к броне + защита | Эпический |

NPC дачитель: **Мастер Камней Теней** (entry 93001) — выдаёт квесты и сокетрование.
NPC лор: **Хранитель Легенд** (entry 93002) — информация о камнях.
Квесты: 92001-92003 (Поиск, Очистка, Соединение Камней).

## Уроки Иллидана (`server/sql/11_illidans_lessons.sql`)

PvP и PvE обучающий контент с наградами:

### PvP уроки (Инструктор ПвП, entry 94002)
| Квест | Название | Цель | Награда |
|-------|----------|------|---------|
| 93001 | Урок 1: Стойкость ПвП | Выдержать 5 мин в дуэли | Перчатки Теневого Боя |
| 93002 | Урок 2: Точность ПвП | 50 критических ударов | Плащ Ночного Стража |
| 93003 | Урок 3: Мастерство ПвП | Комбинированная атака | — |

### PvE уроки (Инструктор ПвЕ, entry 94003)
| Квест | Название | Цель | Награда |
|-------|----------|------|---------|
| 93004 | Урок 4: Выживание в Рейде | Выдержать 10 мин | Кольцо Свежих Уроков |
| 93005 | Урок 5: Урон по Боссу | 100000 урона | Ошейник Теневого Ученика |
| 93006 | Урок 6: Позиционирование | 5 мин в безопасности | — |

### Финал
| Квест | Название | Цель | Награда |
|-------|----------|------|---------|
| 93007 | Полный Курс Иллидана | Завершить все уроки | Медальон Иллидана + Клинок Первого Урока |

NPC: **Иллидан Ярче Звезд** (entry 94001) — финальный квест и награда.

## Лицензия
Серверный код — AGPLv3 (в соответствии с AzerothCore). Клиент WoW 3.3.5a принадлежит Blizzard Entertainment; данный репозиторий **не содержит** файлов клиента.