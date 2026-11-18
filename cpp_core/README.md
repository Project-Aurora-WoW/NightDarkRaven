# C++ модуль AzerothCore — Ночь темного Ворона

Модуль `mod-nightdarkraven` заменяет прежние патчи ядра. Патчи больше не нужны:
модуль подключается как обычный модуль AzerothCore и **не меняет ни одного файла ядра**,
поэтому переживает обновления AzerothCore.

## Что делает модуль

| Система | Реализация | Хранение |
|---------|------------|----------|
| Кастомные навыки 90001–90005 | `PlayerScript` + API-функции | `characters.character_nightraven_skills` |
| Соло-режим | `PlayerScript::OnPlayerLogin` + `UnitScript::OnDamage` | `characters.character_solo_state` |
| Настройки | `WorldScript::OnAfterConfigLoad` | `worldserver.conf` |

Модуль даёт Lua-скриптам постоянное хранение навыков и соло-режима —
сейчас в Lua это жило только в памяти и терялось при рестарте.

## Установка

```bash
# 1. Скопировать модуль в репозиторий AzerothCore
cp -r cpp_core/module <ac-server>/modules/mod-nightdarkraven

# 2. Пересобрать сервер (CMake подхватит modules/* автоматически)
cd <ac-server>/build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DWITH_SCRIPTING=ON
make -j$(nproc)

# 3. Применить схему БД
mysql -u root -p characters < <ac-server>/modules/mod-nightdarkraven/data/sql/db-characters/nightdarkraven.sql
```

Если CMake не подхватывает папку автоматически — добавьте в `modules/CMakeLists.txt`
или в корневой `CMakeLists.txt`:

```cmake
add_subdirectory(modules/mod-nightdarkraven)
```

## Настройки в `worldserver.conf`

```ini
NightDarkRaven.EnableSoloMode = 1
NightDarkRaven.EnableCustomSkills = 1
NightDarkRaven.SoloHealthMultiplier = 0.60
NightDarkRaven.SoloDamageMultiplier = 0.70
```

## Соответствие Lua ↔ C++

| Функция | C++ (`namespace NightDarkRaven`) | Таблица БД |
|---------|----------------------------------|------------|
| Навык игрока | `GetSkill(player, id)` | `character_nightraven_skills` |
| Установить навык | `SetSkill(player, id, value)` | то же |
| Повысить навык | `SkillUp(player, id, amount)` | то же |
| Есть навык | `HasSkill(player, id)` | то же |
| Соло-режим | `SetSoloMode(player, bool)` / `IsSoloMode(player)` | `character_solo_state` |

## Ограничения текущей версии

- Модификатор урона (`UnitScript::OnDamage`) режет урон **по мобам**, если рядом есть
  соло-игрок. Множитель здоровья моба (`SoloHealthMultiplier`) загружается и логируется,
  но пока не применяется к мобам — для этого нужен пересчёт `SetMaxHealth` при спавне.
- Публикация функций в Lua (Eluna) требует отдельного моста; сами функции C++ готовы
  и вызываются из GM-команд/другого модуля.
- Сборка модуля против AzerothCore **не проверена** — исходники эталонного ядра
  подтягивались только для сверки сигнатур (`PlayerScript::OnPlayerLogin/OnPlayerLogout/OnPlayerSave`,
  `UnitScript::OnDamage`, `WorldScript::OnAfterConfigLoad`).
