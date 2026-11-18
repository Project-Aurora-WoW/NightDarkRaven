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

## Кампании (контент мира)

Для развёртывания 11 кампаний примените SQL-файлы по порядку к базе `world`:

```bash
mysql -u root -p world < 02_campaigns_creatures.sql
mysql -u root -p world < 03_campaigns_items.sql
mysql -u root -p world < 04_campaigns_quests.sql
mysql -u root -p world < 05_campaigns_loot.sql
mysql -u root -p world < 06_campaigns_spawns.sql
```

После импорта перезагрузите世界 в игре или сервер:
```
.reload quest
.reload creature
.reload item
.reload loot
```
(или просто перезапустите `worldserver`).

Координаты спавнов в `06_campaigns_spawns.sql` — примерные (карта 0, рядом со Stormwind). Подставьте реальные координаты под вашу карту/зону перед импортом.

## 9. Интеграция соло-режима с веб-клиентом (Web ↔ Lua)

Для того чтобы веб-клиент мог включать соло-режим, который применяется Lua-сервером:

```bash
mysql -u root -p world < server/sql/08_solo_integration.sql
```

Это создаст таблицы `solo_state`, `solo_companions`, `solo_state_log` в БД `world`.

### Как работает
1. Веб-клиент пишет в `solo_state` (POST `/api/solo/toggle`).
2. Lua-сервер (`solo_web_sync.lua`) опрашивает `solo_state` каждые 5 секунд.
3. При обнаружении изменения — применяет соло-режим к игроку в игре.

## 10. Веб-клиент с SSL/HTTPS

### Генерация самоподписанного сертификата (разработка)
```bash
cd web/ssl
./generate_self_signed.sh   # Linux/macOS
# или
generate_self_signed.bat    # Windows
```

### Запуск с HTTPS
Отредактируйте `web/config.json`:
```json
{
  "server": { "http": true, "https": true, "httpsPort": 3443 }
}
```
Затем `npm start`. Сервер будет доступен на `http://localhost:3000` и `https://localhost:3443`.

В проде замените самоподписанный сертификат на Let's Encrypt или коммерческий.

## 11. Лаунчер WoW 3.3.5a

Папка `launcher/` содержит лаунчер для клиента WoW 3.3.5a:
- `launcher.bat` / `launcher.ps1` — патчит `realmlist.wtf` и запускает `WoW.exe`
- `config.json` — путь к WoW, адрес реалма, URL веб-клиента
- `patch_realmlist.py` — альтернативный патч на Python

Отредактируйте `launcher/config.json`, укажите `wowPath` и `realmlist`, затем запустите лаунчер.

## 12. Админ-панель веб-клиента

Веб-клиент содержит админ-панель (`/admin`) для GM-администрирования:
- Список всех соло-игроков и их статусов
- Массовое включение/выключение соло-режима
- Статистика сервера (онлайн, персонажи, активных соло)
- Рестарт WorldServer из веб-интерфейса
- Логи изменений соло-состояний

Доступ: требуется заголовок `X-GM-Level >= 1` (или прямое обращение к БД `solo_state`).

## 13. Авто-рестарт WorldServer при изменении Lua

Сервис `watcher_service.js` следит за изменениями в `server/luaship/NightDarkRaven/`. При изменении `.lua` файлов запускается `tools/restart_worldserver.{sh,bat}`.

Включить в `web/config.json`:
```json
{
  "watcher": {
    "enabled": true,
    "watchDir": "./server/luaship/NightDarkRaven",
    "restartScript": "./tools/restart_worldserver",
    "debounceMs": 3000
  }
}
```

## 14. Discord уведомления

Интеграция с Discord через Webhook. Уведомления при:
- Включении соло-режима игроком
- Входе в соло-подземелье
- Получении компаньона
- Рестарте сервера из админ-панели

Настройка в `web/config.json`:
```json
{
  "discord": {
    "webhookUrl": "https://discord.com/api/webhooks/...",
    "enabled": true
  }
}
```

## 15. Управление квестами кампаний (веб)

API `web/server/routes/campaigns.js` позволяет просматривать и редактировать квесты кампаний через веб-интерфейс (`/admin` → «Кампании`):
- Просмотр всех 11 кампаний с квестами
- Включение/выключение квеста (флаг `Flags` в `quest_template`)
- Изменение уровня квеста

Эндпоинты:
- `GET /api/campaigns` — список кампаний с квестами
- `GET /api/campaigns/:questId` — детали квеста
- `POST /api/campaigns/:questId/toggle` — включить/выключить квест
- `POST /api/campaigns/:questId/level` — изменить уровень квеста

## 16. Автоимпорт SQL (интеграция с БД)

Сервис `web/server/services/sql_import_service.js` импортирует `.sql` файлы из `server/sql/` в базу `world` автоматически.

Настройка в `web/config.json`:
```json
{
  "sqlImport": {
    "autoImportOnStart": true,
    "importAll": false
  }
}
```

API:
- `POST /api/sqlimport/import` — импортировать файлы
- `GET /api/sqlimport/status` — статус импорта
- `POST /api/sqlimport/import-file` — импорт одного файла

## 17. Мобильный лаунчер (PWA)

Папка `launcher/mobile/` — мобильный веб-лаунчер для Android/iOS:
- Устанавливается на домашний экран через браузер
- Патчит `realmlist.wtf` (через Android WebView API или симуляцию)
- Запускает `WoW.exe` (через WebView JS-интерфейс)
- Открывает веб-клиент

Файлы:
- `index.html` — интерфейс
- `style.css` — мобильные стили
- `app.js` — логика запуска
- `manifest.json` — манифест PWA
- `sw.js` — Service Worker

