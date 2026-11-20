# 🌐 Локализация — Ночь темного Ворона (RU/EN)

Система локализации для всех компонентов проекта на два языка:
- **Русский (ru-RU)** — основной язык
- **Английский (en-US)** — второй язык

## Структура

```
localization/
├── README.md
├── lua/                    # Lua переводы (server/luaship/NightDarkRaven/)
│   ├── ru-RU.lua           # Русские строки
│   ├── en-US.lua           # Английские строки
│   └── translator.lua      # Менеджер переводов
├── web/                    # Веб-клиент переводы
│   ├── ru-RU.json
│   ├── en-US.json
│   └── i18n.js
├── sql/                    # SQL переводы
│   ├── ru-RU/
│   │   ├── creatures.sql   # Локализованные имена мобов
│   │   ├── items.sql       # Локализованные имена предметов
│   │   └── quests.sql      # Локализованные квесты
│   └── en-US/
│       ├── creatures.sql
│       ├── items.sql
│       └── quests.sql
└── docs/                   # Документация
    ├── README.ru-RU.md
    └── README.en-US.md
```

## Как работает

### Lua переводы
Все строки в Lua-скриптах оборачиваются через `L("key")` вместо жесткого текста.

```lua
-- Было:
creature:SendUnitSay("Приветствую, странник...", 0)

-- Стало:
creature:SendUnitSay(L("npc_dark_raven.welcome"), 0)
```

### Веб-переводы
Все строки в веб-интерфейсе через `t("key")`.

```javascript
// Было:
document.getElementById('title').textContent = 'Персонажи';

// Стало:
document.getElementById('title').textContent = t('characters.title');
```

## Поддерживаемые языки

| Код | Название | Статус |
|-----|----------|--------|
| ru-RU | Русский | ✅ Полный |
| en-US | Английский | ✅ Полный |

## Добавление нового языка

1. Создайте файл `localization/lua/xx-XX.lua`
2. Скопируйте ключи из `ru-RU.lua` и переведите значения
3. Создайте `localization/web/xx-XX.json`
4. Добавьте язык в селектор веб-интерфейса