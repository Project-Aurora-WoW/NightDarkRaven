# Лаунчер «Ночь темного Ворона» для WoW 3.3.5a

Варианты лаунчеров:

| Вариант | Папка | Описание |
|---------|-------|----------|
| Десктоп (Windows) | `launcher/` | `launcher.bat` / `launcher.ps1` — патчит `realmlist.wtf` и запускает `WoW.exe` |
| Мобильный (PWA) | `launcher/mobile/` | `index.html` + `manifest.json` + `sw.js` — мобильный веб-лаунчер, устанавливается на домашний экран |
| Python | `launcher/patch_realmlist.py` | Кросс-платформенный патч `realmlist.wtf` |

## Десктоп-лаунчер (Windows)

Отредактируйте `launcher/config.json`:
```json
{
  "wowPath": "C:\\Program Files\\World of Warcraft",
  "realmlist": "127.0.0.1",
  "webUrl": "http://localhost:3000"
}
```

Запустите `launcher.bat` или `launcher.ps1`.

## Мобильный лаунчер (PWA, Android/iOS)

Папка `launcher/mobile/` — готовый PWA-лаунчер:
- `index.html` — интерфейс запуска WoW и веб-клиента
- `style.css` — мобильные стили (фэнтези-оформление)
- `app.js` — логика: патч realmlist, запуск WoW, открытие веб-клиента
- `manifest.json` — манифест для установки на домашний экран
- `sw.js` — Service Worker для офлайн-режима

### Установка на Android
1. Откройте `launcher/mobile/index.html` в Chrome на Android.
2. Меню → «Добавить на главный экран».
3. Лаунчер появится как отдельное приложение.

### Интеграция с Android WebView (опционально)
Для полноценной работы (прямой запуск WoW с телефона) потребуется Android-приложение с WebView и JS-интерфейсом `AndroidLauncher` с методами:
- `patchRealmlist(realm, path)`
- `launchWow(path, realm)`
- `openUrl(url)`

### Python-патч (кроссплатформа)
```bash
python launcher/patch_realmlist.py
```
Отредактируйте `launcher/config.json` (укажите `wowPath` и `realmlist`) перед запуском.