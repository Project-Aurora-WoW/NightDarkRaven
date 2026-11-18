# Сервис автоимпорта SQL

Файл: `web/server/services/sql_import_service.js`

## Что делает
- Читает `.sql` файлы из `server/sql/` в алфавитном порядке
- Разбивает на отдельные запросы по точке с запятой
- Импортирует в базу `world` (MySQL)
- Отслеживает уже импортированные файлы в таблице `sql_import_log`
- Пропускает дубликаты ключей (ER_DUP_ENTRY) как успешные

## API
- `POST /api/sqlimport/import` — импортировать все/новые файлы
- `GET /api/sqlimport/status` — статус импорта по файлам
- `POST /api/sqlimport/import-file` — импорт одного файла

## Автоимпорт при старте
Добавьте в `web/config.json`:
```json
{
  "sqlImport": {
    "autoImportOnStart": true,
    "importAll": false
  }
}
```
И в `web/server/index.js` вызовите `sqlImport.importNew()` при запуске.