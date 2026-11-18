# Лаунчер «Ночь темного Ворона» для WoW 3.3.5a

Лаунчер патчит `realmlist.wtf` клиента WoW 3.3.5a и запускает игру с подключением к серверу AzerothCore.

## Состав

| Файл | Описание |
|------|----------|
| `launcher.bat` | Batch-лаунчер (Windows) |
| `launcher.ps1` | PowerShell-лаунчер (Windows) |
| `config.json` | Конфигурация лаунчера |
| `patch_realmlist.py` | Python-скрипт для патча realmlist.wtf |

## Быстрый запуск (Windows)

1. Отредактируйте `launcher/config.json` — укажите путь к папке с WoW 3.3.5a и адрес сервера.
2. Запустите `launcher.bat` или `launcher.ps1`.

## Пример config.json

```json
{
  "wowPath": "C:\\Program Files\\World of Warcraft",
  "realmlist": "127.0.0.1",
  "webUrl": "http://localhost:3000",
  "launcherTitle": "Ночь темного Ворона — Лаунчер"
}
```

## Как работает

1. Читает `config.json` (путь к WoW, адрес реалма).
2. Перезаписывает `WTF/realmlist.wtf` в папке с WoW.
3. Запускает `WoW.exe`.
4. Опционально открывает веб-клиент в браузере для управления аккаунтом.