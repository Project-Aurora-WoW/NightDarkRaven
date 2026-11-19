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
mysql -u root -p world < 07_campaigns_solo.sql
mysql -u root -p world < 08_solo_integration.sql
mysql -u root -p world < 09_client_patches.sql
mysql -u root -p world < 10_legendary_stones.sql
mysql -u root -p world < 11_illidans_lessons.sql
mysql -u root -p world < 14_additional_creatures.sql
mysql -u root -p world < 15_additional_items.sql
mysql -u root -p world < 16_additional_quests.sql
mysql -u root -p world < 17_additional_loot.sql
mysql -u root -p world < 18_additional_spawns.sql
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

## 17. Мобильный лаунчер (PWA + нативные приложения)

### PWA-веб-лаунчер (`launcher/mobile/`)
Устанавливается на домашний экран через браузер:
- `index.html`, `style.css`, `app.js` — интерфейс и логика
- `manifest.json` — манифест PWA
- `sw.js` — Service Worker

### Нативный Android-лаунчер (Kotlin) (`launcher/native/android/`)
- `MainActivity.kt` — главная активность с WebView
- `AndroidLauncherInterface` — JS-интерфейс (`patchRealmlist`, `launchWow`, `openUrl`)
- `assets/www/` — встроенный веб-лаунчер для WebView
- Сборка: `./gradlew assembleDebug`

### Нативный iOS-лаунчер (Swift) (`launcher/native/ios/`)
- `AppDelegate.swift` — точка входа
- `ContentView.swift` — SwiftUI интерфейс с WKWebView
- JS-интерфейс `iOSLauncher` для нативных вызовов

## 18. Система патчей клиента через БД

Таблицы `client_patches` и `client_patch_log` в БД `world` (`server/sql/09_client_patches.sql`).

### Возможности
- Регистрация патчей клиента (realmlist, mpq, config, wtf, db)
- Отслеживание применённых/неприменённых патчей
- Лог истории применения

### API
- `GET /api/clientpatches` — список патчей
- `POST /api/clientpatches` — создание патча
- `POST /api/clientpatches/:id/apply — отметить как применённый
- `GET /api/clientpatches/log` — история

### Lua-сервер
`systems/client_patch_system.lua` — загружает патчи при старте, может отправлять список клиенту при входе.

## 19. Веб-интерфейс: все разделы админ-панели

| Раздел | Путь | Описание |
|--------|------|----------|
| Статистика | `/admin` | Онлайн, персонажи, соло-режимы |
| Соло-игроки | `/admin` | Управление соло-статусом |
| Кампании | `/campaigns-admin` | Управление квестами кампаний |
| SQL Импорт | `/sqlimport` | Автоимпорт `.sql` файлов из `server/sql/` |
| Патчи клиента | `/clientpatches` | Управление патчами клиента WoW |
| Логи | `/admin` | История соло-состояний и патчей |

## 20. Настройка и сборка нативных мобильных приложений

### Android Studio (Kotlin)

#### Требования
- Android Studio Arctic Fox или новее
- JDK 11+
- Android SDK API 21+ (minSdk 21, targetSdk 34)

#### Установка
1. Скачайте и установите [Android Studio](https://developer.android.com/studio)
2. При первом запуске установите компоненты через SDK Manager:
   - Android SDK Platform 34
   - Android SDK Build-Tools 34.0.0
   - Android Emulator (опционально)

#### Сборка проекта
```bash
cd launcher/native/android

# Посмотреть доступные задачи
./gradlew tasks

# Собрать отладочную версию (APK)
./gradlew assembleDebug

# Собрать релизную версию (требует подписи)
./gradlew assembleRelease
```

Готовый APK будет в: `launcher/native/android/app/build/outputs/apk/debug/app-debug.apk`

#### Установка на устройство
```bash
# Через ADB (устройство должно быть в режиме отладки по USB)
adb install app/build/outputs/apk/debug/app-debug.apk

# Или через Android Studio: Run → Run 'app'
```

#### Структура проекта
```
launcher/native/android/
├── app/
│   ├── src/main/AndroidManifest.xml      # Манифест приложения
│   ├── src/main/java/.../MainActivity.kt  # Главная активность (WebView + JS-интерфейс)
│   ├── src/main/res/layout/activity_main.xml  # Разметка экрана
│   ├── src/main/res/values/               # Строки и темы
│   ├── src/main/assets/www/               # Встроенный веб-лаунчер (HTML/JS/CSS)
│   └── build.gradle
├── build.gradle
├── gradle/wrapper/gradle-wrapper.properties
└── README.md
```

#### JS-интерфейс AndroidLauncher
Из веб-лаунчера (в WebView) доступны методы:
- `AndroidLauncher.patchRealmlist(realm, path)` — обновить realmlist.wtf
- `AndroidLauncher.launchWow(path, realm)` — запустить WoW
- `AndroidLauncher.openUrl(url)` — открыть URL в браузере
- `AndroidLauncher.applyPatch(id, content, file)` — применить патч клиента

---

### Xcode (Swift / iOS)

#### Требования
- macOS с Xcode 15.0 или новее
- Apple ID для подписи приложения (для установки на устройство)
- iOS SDK 17.0+

#### Установка
1. Скачайте и установите [Xcode](https://developer.apple.com/xcode/) из App Store
2. При первом запуске установите дополнительные компоненты

#### Сборка проекта
```bash
cd launcher/native/ios

# Открыть в Xcode
open Runner.xcodeproj

# Или собрать из командной строки
xcodebuild -project Runner.xcodeproj -scheme Runner -configuration Debug build
```

#### Установка на устройство
1. Подключите iPhone/iPad через USB
2. В Xcode выберите устройство в верхней панели
3. Нажмите ▶️ Run
4. На устройстве доверьтесь разработчику: Настройки → Общие → Управление устройством

#### Структура проекта
```
launcher/native/ios/
├── Runner/
│   ├── AppDelegate.swift        # Точка входа, WKWebView + JS-интерфейс
│   ├── ContentView.swift        # SwiftUI интерфейс
│   └── Info.plist               # Конфигурация приложения
├── Runner.xcodeproj/
│   └── project.pbxproj          # Xcode проект
└── README.md
```

#### JS-интерфейс iOSLauncher
Из веб-лаунчера (в WKWebView) доступны методы через `window.webkit.messageHandlers.iOSLauncher.postMessage()`:
```javascript
window.webkit.messageHandlers.iOSLauncher.postMessage({
    action: "patchRealmlist",
    realm: "127.0.0.1",
    path: "/storage/emulated/0/WoW/"
});

window.webkit.messageHandlers.iOSLauncher.postMessage({
    action: "launchWow",
    path: "/storage/emulated/0/WoW/",
    realm: "127.0.0.1"
});

window.webkit.messageHandlers.iOSLauncher.postMessage({
    action: "openUrl",
    url: "http://localhost:3000"
});
```

> **Примечание:** На iOS запуск `WoW.exe` напрямую невозможен (нет Windows API). Лаунчер открывает веб-клиент и позволяет применить `realmlist.wtf` для дальнейшего использования в эмуляторе Windows или на ПК.

## 21. Автоматическое применение патчей клиента при входе

Система патчей клиента (`server/sql/09_client_patches.sql`, `systems/client_patch_system.lua`) работает следующим образом:

1. Администратор создаёт патч через веб-админку (`/clientpatches`) или прямо в БД `world`
2. При входе любого игрока в мир Lua-сервер проверяет таблицу `client_patches`
3. Игрок получает системные сообщения со списком неприменённых патчей
4. Патчи можно применить тремя способами:
   - **Десктоп-лаунчер** (`launcher.bat` / `launcher.ps1`) — автоматически проверяет и применяет патчи при запуске
   - **Мобильный PWA-лаунчер** (`launcher/mobile/`) — проверяет патчи при старте, позволяет скачать каждый патч
   - **Нативные мобильные приложения** (Android/iOS) — проверяют и применяют патчи через веб-API
   - **Веб-админка** — в разделе «Патчи клиента» можно вручную применить любой патч

### API для скачивания патчей лаунчером
| Метод | Путь | Описание |
|-------|------|----------|
| GET | `/api/clientpatches/check` | Проверить нужные патчи (без GM-проверки) |
| GET | `/api/clientpatches/:id/download?autoApply=true` | Скачать патч и отметить применённым |
| POST | `/api/clientpatches/:id/apply-launcher` | Отметить патч применённым через лаунчер |

## 22. Система сокетов предметов (вставка камней в шмот)

Три варианта реализации сокетов:

### 22.1 Вариант 1: Таблица БД + Lua (рекомендуется для старта)

Новые таблицы в БД `world`:
```bash
mysql -u root -p world < server/sql/12_item_sockets.sql
```

Лua-система: `server/luaship/NightDarkRaven/systems/item_socket_system.lua`
Gossip NPC: `server/luaship/NightDarkRaven/quests/item_socket_gossip.lua`

Возможности:
- Вставка камней в сокеты предметов через gossip NPC «Мастер Камней Теней» (93001)
- Извлечение камней обратно в инвентарь
- Постоянное хранение в таблице `character_item_sockets`
- Шаблоны сокетов в таблице `item_socket_template`

### 22.2 Вариант 2: Дубликаты предметов с камнями

```bash
mysql -u root -p world < server/sql/13_item_sockets_items.sql
```

Предметы с уже вставленными камнями (entry 950021-950030):
- Перчатки Теневого Боя с разными камнями
- Плащ Ночного Стража с камнями
- Кольцо, ошейник, медальон, клинок с камнями

Можно выдавать как награду за квесты или лут с мобов.

### 22.3 Вариант 3: Полноценные сокетов в C++ ядре

Патчи для AzerothCore ядра:
- `cpp_core/patches/08_item_sockets.h.patch` — Item.h: методы сокетов
- `cpp_core/patches/09_item_sockets.cpp.patch` — Item.cpp: реализация сокетов
- `cpp_core/patches/10_item_sockets_lua.cpp` — Lua мост для сокетов

Применение:
```bash
git apply ../NightDarkRaven/cpp_core/patches/08_item_sockets.h.patch
git apply ../NightDarkRaven/cpp_core/patches/09_item_sockets.cpp.patch
```

Lua API после применения C++ патчей:
```lua
ItemSocketGem(player, bag, slot, gemEntry)    -- Вставить камень
ItemUnsocketGem(player, bag, slot)            -- Извлечь камень
ItemGetSocketGem(player, bag, slot)           -- Получить камень в сокете
ItemHasSocket(player, bag, slot)              -- Проверить сокет
```

Лаунчер для применения патчей клиента: `launcher/patch_realmlist.py` или `launcher.bat`.

