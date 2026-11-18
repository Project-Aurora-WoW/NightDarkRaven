# Android Лаунчер (Kotlin)

Нативный Android-лаунчер для WoW 3.3.5a «Ночь темного Ворона».

## Структура
```
launcher/native/android/
├── app/
│   ├── src/main/AndroidManifest.xml
│   ├── src/main/java/com/nightdarkraven/launcher/MainActivity.kt
│   ├── src/main/res/layout/activity_main.xml
│   ├── src/main/res/values/strings.xml
│   ├── src/main/res/values/themes.xml
│   └── build.gradle
├── build.gradle
├── gradle/wrapper/gradle-wrapper.properties
└── README.md
```

## Возможности
- WebView с локальным HTML-лаунчером (из `assets/www/`)
- JS-интерфейс `AndroidLauncher` для вызова нативного кода из JS
- Патч `realmlist.wtf` в папке клиента WoW
- Запуск `WoW.exe` (через Intent, требует эмулятор Windows или корень)
- Открытие веб-клиента в браузере

## Сборка
```bash
cd launcher/native/android
./gradlew assembleDebug
```

## Интеграция с веб-лаунчером
Веб-лаунчер (`launcher/mobile/`) может вызывать нативные методы через `window.AndroidLauncher.patchRealmlist()`, `launchWow()`, `openUrl()`.