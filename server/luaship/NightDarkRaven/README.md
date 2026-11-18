# Lua-скрипты (Eluna) — Ночь темного Ворона

Папка содержит серверные Lua-скрипты для AzerothCore (ветка wotlk / WoW 3.3.5a).

## Содержимое

| Файл | Описание |
|------|----------|
| `npc_dark_raven.lua` | NPC "Темный Ворон" (entry 90001) с gossip-меню, фразами в бою и при смерти |
| `world_events.lua` | Сообщения при входе/выходе, объявление "Ночи темного Ворона" по игровому времени |
| `quest_shadow_feather.lua` | Пример квеста "Перо Тени": выдача, прогресс, сдача, лут с моба |

## Подключение

1. Убедитесь, что AzerothCore собран с поддержкой Eluna (Lua):
   ```cmake
   # в CMakeLists.txt AzerothCore должно быть включено:
   WITH_LUA=ON
   ```
   либо при конфигурации CMake укажите `-DWITH_SCRIPTING=ON` (в зависимости от версии сборки).

2. Положите скрипты в папку скриптов сервера, например:
   ```
   ac-server/luaship/NightDarkRaven/
   ```
   (точный путь зависит от сборки Eluna: обычно `luaship/` в корне сервера).

3. Перезапустите `worldserver`. В логе должны появиться строки:
   ```
   [NightDarkRaven] Lua: npc_dark_raven (entry 90001) loaded.
   [NightDarkRaven] Lua: world_events loaded.
   [NightDarkRaven] Lua: quest_shadow_feather (quest 90001) loaded.
   ```

## База данных

Для квеста `quest_shadow_feather.lua` необходимо заранее создать записи в БД `world`:
- `quest_template` — quest ID 90001
- `creature_queststarter` / `creature_questender` — NPC 90001
- `item_template` — item 90001 "Перо Тени"
- `creature_loot_template` — моб 90002 дропает item 90001

Пример SQL (опционально, подставив реальные значения):
```sql
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES (90001, 90001);
INSERT INTO `creature_questender`   (`id`, `quest`) VALUES (90001, 90001);
```