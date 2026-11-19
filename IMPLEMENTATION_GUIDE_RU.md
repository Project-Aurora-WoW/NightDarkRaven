# 📋 Руководство по реализации — Ночь темного Ворона

В этом документе описаны пошаговые инструкции по четырём направлениям:

1. 🌐 Веб-клиент — настройка и запуск
2. 🎨 MPQ ресурсы — создание кастомных моделей и текстур
3. 📜 Дополнительный контент — квесты, мобы, предметы (кампании 12-15)
4. 📚 Документация — инструкции по установке

---

## 1. 🌐 Веб-клиент — настройка и запуск

Веб-клиент на Node.js + Express для управления аккаунтом, персонажами и просмотра мира через браузер.

### Требования
- Node.js 16+
- MySQL 5.7+ / MariaDB 10.3+ с запущенным сервером

### Быстрый запуск

```bash
# Перейти в папку веб-клиента
cd web

# Установить зависимости
npm install

# Скопировать пример конфигурации
cp config.example.json config.json

# Отредактировать config.json — указать пароли к MySQL (auth/characters/world)
# Запустить сервер
npm start
```

Веб-клиент доступен на: `http://localhost:3000`

### Конфигурация (config.json)

```json
{
  "server": {
    "port": 3000,
    "host": "0.0.0.0",
    "http": true,
    "https": false,
    "httpsPort": 3443
  },
  "databases": {
    "auth": {
      "host": "127.0.0.1",
      "port": 3306,
      "user": "root",
      "password": "",
      "database": "auth"
    },
    "characters": {
      "host": "127.0.0.1",
      "port": 3306,
      "user": "root",
      "password": "",
      "database": "characters"
    },
    "world": {
      "host": "127.0.0.1",
      "port": 3306,
      "user": "root",
      "password": "",
      "database": "world"
    }
  },
  "discord": {
    "webhookUrl": "",
    "enabled": false
  },
  "watcher": {
    "enabled": false,
    "watchDir": "./server/luaship/NightDarkRaven",
    "restartScript": "./tools/restart_worldserver",
    "debounceMs": 3000
  },
  "sqlImport": {
    "autoImportOnStart": false,
    "importAll": false
  },
  "security": {
    "corsOrigin": "*",
    "sessionSecret": "night-dark-raven-secret-change-me"
  },
  "ssl": {
    "certPath": "./ssl/certs/nightdarkraven.crt",
    "keyPath": "./ssl/certs/nightdarkraven.key"
  }
}
```

### API эндпоинты

| Метод | Путь | Описание |
|-------|------|----------|
| GET | `/api/health` | Проверка работоспособности |
| POST | `/api/auth/login` | Авторизация аккаунта |
| GET | `/api/auth/realms` | Список реалмов |
| GET | `/api/characters/:accountId` | Список персонажей |
| GET | `/api/world/campaigns` | Список кампаний |
| GET | `/api/world/zones` | Список зон |
| GET | `/api/world/dungeons` | Список подземелий |
| GET | `/api/world/items` | Список предметов |
| POST | `/api/solo/toggle` | Включить/выключить соло-режим |
| GET | `/api/solo/companions` | Список компаньонов |
| GET | `/api/solo/status/:characterGuid` | Статус соло-режима |
| GET | `/api/campaigns` | Список кампаний с квестами |
| POST | `/api/campaigns/:questId/toggle` | Включить/выключить квест |
| POST | `/api/sqlimport/import` | Импортировать SQL файлы |
| GET | `/api/sqlimport/status` | Статус импорта |
| GET | `/api/clientpatches` | Список патчей клиента |
| POST | `/api/clientpatches` | Создать патч |

### Админ-панель

Доступна на `http://localhost:3000/admin` (требует заголовок `X-GM-Level >= 1`).

Возможности:
- Статистика сервера (онлайн, персонажи, соло-режимы)
- Управление соло-игроками (включение/выключение)
- Управление квестами кампаний (включение/выключение, изменение уровней)
- Автоимпорт SQL файлов
- Управление патчами клиента
- Рестарт WorldServer
- Логи изменений

---

## 2. 🎨 MPQ ресурсы — создание кастомных моделей и текстур

Папка `client/custom_content/` содержит инструменты и инструкции для создания кастомных ресурсов клиента WoW 3.3.5a.

### ⚠️ Важно

Сам клиент WoW 3.3.5a и его оригинальные ресурсы **НЕ входят** в репозиторий (авторские права Blizzard Entertainment). У вас должен быть установлен лицензионный клиент WoW 3.3.5a.

### Структура папок

```
client/custom_content/
├── README.md         # Общая инструкция
├── models/           # Кастомные 3D модели (.mdl, .m2)
├── textures/         # Кастомные текстуры (.blp)
├── mpq/              # Сборка MPQ архива
│   ├── README.md     # Инструкция по сборке patch.MPQ
│   ├── build_mpq.bat # Сборка MPQ (Windows)
│   ├── build_mpq.sh  # Сборка MPQ (Linux/macOS)
│   └── file_list.txt # Список файлов для MPQ
└── tools/            # Инструменты конвертации
    ├── m2_converter.py # Конвертация моделей
    └── blp_converter.py # Конвертация текстур
```

### Пошаговая инструкция

#### Шаг 1: Установить инструменты
- **MPQ Editor** (Windows) — для создания и редактирования MPQ архивов
- **WoW Model Viewer** — для просмотра и конвертации моделей WoW
- **TexConv** или конвертер BLP — для конвертации текстур в формат BLP

#### Шаг 2: Создать модель
1. Создайте модель в 3D редакторе (Blender, 3ds Max)
2. Экспортируйте в формат WoW (.m2) через WoW Model Viewer
3. Положите в `client/custom_content/models/`

#### Шаг 3: Создать текстуру
1. Создайте текстуру в графическом редакторе (Photoshop, GIMP)
2. Конвертируйте в формат .blp
3. Положите в `client/custom_content/textures/`

#### Шаг 4: Собрать MPQ архив
```bash
# Windows
cd client/custom_content/mpq
build_mpq.bat

# Linux/macOS
cd client/custom_content/mpq
./build_mpq.sh
```

#### Шаг 5: Установить в клиент
1. Скопируйте `patch.MPQ` в папку с `WoW.exe`
2. Запустите клиент WoW 3.3.5a

#### Шаг 5: Связать с сервером
Добавьте запись в `creature_template` с `displayid` вашей кастомной модели:

```sql
INSERT INTO `creature_template` (`entry`, `name`, `modelid_1`, `faction`, `npcflag`) VALUES
(92001, 'Кастомный Ворон', 25001, 35, 1);
```

---

## 3. 📜 Дополнительный контент — квесты, мобы, предметы (кампании 12-15)

Добавлены 4 новых кампании (12-15) для игроков уровня 85-88.

### Новые SQL файлы

| Файл | Описание |
|------|----------|
| `server/sql/14_additional_creatures.sql` | 16 мобов/NPC (entry 90127-90142) |
| `server/sql/15_additional_items.sql` | 16 предметов (entry 92009-92024) |
| `server/sql/16_additional_quests.sql` | 16 квестов (entry 92001-92016) |
| `server/sql/17_additional_loot.sql` | Лут мобов кампаний 12-15 |
| `server/sql/18_additional_spawns.sql` | Спавны дачителей и мобов |

### Кампании 12-15

| # | Кампания | Дачитель (NPC) | Квесты | Уровень |
|---|----------|----------------|--------|---------|
| 12 | Повелители Теней | Повелитель Теней (90127) | 92001-92004 | 85-88 |
| 13 | Королевство Пустоты | Повелитель Пустоты (90130) | 92005-92008 | 85-88 |
| 14 | Звёздный Ворон | Звёздный Ворон (90133) | 92009-92012 | 85-88 |
| 15 | Векрной Ворон | Векрной Ворон (90136) | 92013-92016 | 85-88 |

### Импорт в БД

```bash
mysql -u root -p world < 14_additional_creatures.sql
mysql -u root -p world < 15_additional_items.sql
mysql -u root -p world < 16_additional_quests.sql
mysql -u root -p world < 17_additional_loot.sql
mysql -u root -p world < 18_additional_spawns.sql
```

### NPC дачители

| NPC | Entry | Кампания | Местоположение |
|-----|-------|----------|----------------|
| Повелитель Теней | 90127 | 12 | Координаты: -8950, 640, 100 |
| Повелитель Пустоты | 90130 | 13 | Координаты: -8970, 640, 100 |
| Звёздный Ворон | 90133 | 14 | Координаты: -8990, 640, 100 |
| Векрной Ворон | 90136 | 15 | Координаты: -9010, 640, 100 |

---

## 4. 📚 Документация — инструкции по установке

### Полный порядок развёртывания

#### Шаг 1: Установка AzerothCore

```bash
git clone https://github.com/azerothcore/azerothcore-wotlk.git ac-server
cd ac-server
```

#### Шаг 2: Применение C++ патчей

Скопируйте патчи из `NightDarkRaven/cpp_core/patches/` в AzerothCore и примените:

```bash
git apply ../NightDarkRaven/cpp_core/patches/01_player_skills.h.patch
git apply ../NightDarkRaven/cpp_core/patches/02_player_skills.cpp.patch
git apply ../NightDarkRaven/cpp_core/patches/03_unit_solo.h.patch
git apply ../NightDarkRaven/cpp_core/patches/04_unit_solo.cpp.patch
git apply ../NightDarkRaven/cpp_core/patches/05_worldserver_solo_login.patch
```

Или используйте автоустановщик:
```bash
python NightDarkRaven/cpp_core/apply_patches.py
```

#### Шаг 3: Сборка AzerothCore

```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DWITH_SCRIPTING=ON -DWITH_LUA=ON
make -j$(nproc)
```

#### Шаг 4: Создание баз данных

```bash
mysql -u root -p < ac-server/data/sql/create/mysql_create.sql
mysql -u root -p < ac-server/data/sql/create/characters_create.sql
mysql -u root -p < ac-server/data/sql/create/auth_create.sql
```

#### Шаг 5: Импорт нашего контента

```bash
# Таблицы C++ (навыки, соло-состояние, сокеты)
mysql -u root -p world < NightDarkRaven/server/sql/07_database_schema.sql
mysql -u root -p world < NightDarkRaven/server/sql/12_item_sockets.sql

# Кампании 1-11
mysql -u root -p world < NightDarkRaven/server/sql/02_campaigns_creatures.sql
mysql -u root -p world < NightDarkRaven/server/sql/03_campaigns_items.sql
mysql -u root -p world < NightDarkRaven/server/sql/04_campaigns_quests.sql
mysql -u root -p world < NightDarkRaven/server/sql/05_campaigns_loot.sql
mysql -u root -p world < NightDarkRaven/server/sql/06_campaigns_spawns.sql

# Кампании 12-15
mysql -u root -p world < NightDarkRaven/server/sql/14_additional_creatures.sql
mysql -u root -p world < NightDarkRaven/server/sql/15_additional_items.sql
mysql -u root -p world < NightDarkRaven/server/sql/16_additional_quests.sql
mysql -u root -p world < NightDarkRaven/server/sql/17_additional_loot.sql
mysql -u root -p world < NightDarkRaven/server/sql/18_additional_spawns.sql

# Камни Легенды и Уроки Иллидана
mysql -u root -p world < NightDarkRaven/server/sql/10_legendary_stones.sql
mysql -u root -p world < NightDarkRaven/server/sql/11_illidans_lessons.sql
```

#### Шаг 6: Копирование Lua-скриптов

```bash
cp -r NightDarkRaven/server/luaship/NightDarkRaven ac-server/luaship/NightDarkRaven
```

#### Шаг 7: Настройка конфигов

Скопируйте и отредактируйте:
```bash
cp ac-server/bin/RelWithDebInfo/worldserver.conf.dist ac-server/bin/RelWithDebInfo/worldserver.conf
cp ac-server/bin/RelWithDebInfo/authserver.conf.dist ac-server/bin/RelWithDebInfo/authserver.conf
```

Укажите пароли к MySQL в обоих файлах.

#### Шаг 8: Добавление реалма

```sql
INSERT INTO `realmlist` (`name`, `address`, `localAddress`, `port`, `gamebuild`)
VALUES ('Ночь темного Ворона', '127.0.0.1', '127.0.0.1', 8090, 12340);
```

#### Шаг 9: Запуск серверов

```bash
cd ac-server/bin/RelWithDebInfo
./authserver
./worldserver
```

#### Шаг 10: Настройка клиента WoW 3.3.5a

В папке с клиентом создайте `WTF/realmlist.wtf`:
```
set realmlist 127.0.0.1
```

Или используйте лаунчер:
```
NightDarkRaven/launcher/launcher.bat
```

---

## 📁 Структура репозитория (итоговая)

```
NightDarkRaven/
├── README.md
├── DOCUMENTATION.md          # Полная документация по механикам
├── IMPLEMENTATION_GUIDE_RU.md # Данный файл
├── server/
│   ├── modules/custom/NightDarkRaven/  # C++ модуль сервера
│   ├── luaship/NightDarkRaven/         # Lua / Eluna скрипты
│   ├── sql/                            # SQL скрипты (01-18)
│   ├── conf/                           # Конфиги сервера
│   └── build_instructions.md           # Инструкция по сборке
├── client/
│   ├── configs/
│   │   └── realmlist.wtf
│   ├── patches/
│   └── custom_content/
│       ├── README.md
│       ├── models/
│       ├── textures/
│       ├── mpq/
│       └── tools/
├── web/                          # Веб-клиент (Node.js + Express)
├── launcher/                     # Лаунчеры (Windows, Android, iOS)
├── cpp_core/                     # C++ патчи для AzerothCore
│   ├── patches/
│   ├── README.md
│   ├── BUILD.md
│   ├── HYBRID_ARCHITECTURE.md
│   └── apply_patches.py
└── tools/                        # Инструменты (restart_worldserver)
```

---

## ✅ Готово к развёртыванию

Все четыре направления реализованы:

| Направление | Статус | Файлы |
|-------------|--------|-------|
| Веб-клиент | ✅ Готов | `web/` |
| MPQ ресурсы | ✅ Инструкции | `client/custom_content/` |
| Дополнительный контент | ✅ Готов | `server/sql/14-18_*.sql` |
| Документация | ✅ Обновлена | `DOCUMENTATION.md`, `build_instructions.md`, `README.md` |