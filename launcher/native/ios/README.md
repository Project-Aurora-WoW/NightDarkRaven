# iOS Лаунчер (Swift)

Нативный iOS-лаунчер для WoW 3.3.5a «Ночь темного Ворона».

## Структура
```
launcher/native/ios/
├── Runner/
│   ├── AppDelegate.swift
│   ├── ContentView.swift
│   └── Info.plist
└── README.md
```

## Возможности
- WKWebView с локальным HTML-лаунчером
- JS-интерфейс `iOSLauncher` для нативных вызовов
- Патч `realmlist.wtf` в папке клиента
- Открытие веб-клиента в Safari

## Сборка
Откройте проект в Xcode и соберите для iOS устройства/симулятора.

## Примечание
На iOS запуск `WoW.exe` напрямую невозможен (нет Windows API). Лаунчер открывает веб-клиент и позволяетpatched realmlist для дальнейшего использования в эмуляторе.