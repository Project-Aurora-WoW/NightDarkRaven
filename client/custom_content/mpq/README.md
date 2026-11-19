# Сборка кастомного MPQ архива для WoW 3.3.5A

MPQ (Mo'PaQ) — это формат архива, используемый клиентом WoW для хранения ресурсов. Для подключения кастомных моделей и текстур необходимо создать `patch.MPQ` и положить его в папку с клиентом WoW.

## Инструменты для работы с MPQ

### Windows
- **MPQ Editor** (от Ladislav Zezula) — графический интерфейс для создания и редактирования MPQ
- **StormLib** — библиотека для программной работы с MPQ

### Linux/macOS
- **libmpq** / **mpq-tools** — командная строка для работы с MPQ
- **WoW-Tools** — набор утилит для работы с ресурсами WoW

## Создание patch.MPQ

### Шаг 1: Подготовьте файлы

Все кастомные ресурсы должны находиться в папке с той же структурой папок, что и в клиенте WoW:

```
patch.MPQ/
├── data/
│   ├── creature/
│   │   └── custom_raven.m2
│   ├── textures/
│   │   └── custom_raven.blp
│   └── spells/
│       └── custom_spell.blp
```

### Шаг 2: Соберите MPQ

#### Используя MPQ Editor (графический интерфейс)
1. Откройте MPQ Editor
2. File → New → Create new MPQ archive
3. Добавьте папку с ресурсами через Add Files / Add Folder
4. Установите параметры:
   - Block size: 0x10000 (64KB)
   - Hash table size: автоматически
   - Block table size: автоматически
   - File time: текущее время
   - Attributes: 0x00000020 (MPQ_FILE_COMPRESS или без сжатия)
5. File → Save As → `patch.MPQ`

#### Используя командную строку (Linux/macOS)
```bash
# Пример с использованием mpq-tools
mpq-add patch.MPQ data/creature/custom_raven.m2
mpq-add patch.MPQ data/textures/custom_raven.blp
```

### Скрипт сборки (пример)

См. `build_mpq.bat` (Windows) или `build_mpq.sh` (Linux/macOS) в этой папке.

## Структура файлов в MPQ для разных типов ресурсов

| Тип ресурса | Путь в MPQ | Пример |
|-------------|------------|--------|
| Модель существа | `data/creature/<model>.m2` | `data/creature/custom_raven.m2` |
| Модель NPC | `data/creature/<model>.m2` | `data/creature/custom_npc.m2` |
| Текстура | `data/textures/<texture>.blp` | `data/textures/custom_raven.blp` |
| Звук | `data/sound/<sound>.wav` | `data/sound/custom_raven.wav` |
| Интерфейс | `data/interface/<file>.blp` | `data/interface/custom_frame.blp` |

## Проверка работоспособности

1. Положите `patch.MPQ` в папку с `WoW.exe`
2. Запустите клиент
3. В консоли игры введите `/console scriptErrors 1` для отображения ошибок
4. Если модель не отображается — проверьте `displayid` в базе данных AzerothCore

## Связь с AzerothCore

Для кастомной модели в базе данных сервера:

```sql
-- Пример: Темный Ворон с кастомной моделью
INSERT INTO `creature_template` (`entry`, `name`, `modelid_1`, `faction`, `npcflag`) VALUES
(92001, 'Кастомный Ворон', 25001, 35, 1);
```

Где `25001` — это `displayid`, который вы присвоили модели в клиенте.

## Решение проблем

| Проблема | Решение |
|----------|---------|
| Модель не отображается | Проверьте путь в MPQ (должен быть `data/creature/...`) |
| Текстура не загружается | Проверьте формат (должен быть BLP, размер степенью 2: 64, 128, 256, 512, 1024) |
| Клиент вылетает при входе | Проверьте целостность MPQ архива |
| Модель видна как красный куб | Неправильный формат модели или отсутствуют анимации |

## Ссылки

- [MPQ Editor на GitHub](https://github.com/ladislav-zezula/MPQEditor)
- [StormLib](https://github.com/ladislav-zezula/StormLib)
- [WoW Model Viewer](https://github.com/WowModelViewer/WowModelViewer) — для просмотра и конвертации моделей