@echo off
:: ============================================================================
:: Ночь темного Ворона — Лаунчер для WoW 3.3.5a
:: Патчит realmlist.wtf и запускает игру
:: ============================================================================

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "CONFIG_FILE=%SCRIPT_DIR%config.json"

:: Если конфига нет — копируем пример
if not exist "%CONFIG_FILE%" (
    echo Конфиг не найден, создаю config.json из примера...
    copy "%SCRIPT_DIR%config.example.json" "%CONFIG_FILE%"
    echo Отредактируйте %CONFIG_FILE% и запустите лаунчер снова.
    pause
    exit /b 1
)

:: Читаем настройки из JSON (упрощённо через findstr)
for /f "tokens=*" %%a in ('type "%CONFIG_FILE%"') do set "LINE=%%a"

:: Извлекаем wowPath (простой парсинг)
for /f "tokens=2 delims=:" %%a in ('findstr /c:"wowPath" "%CONFIG_FILE%"') do (
    set "WOW_PATH=%%a"
    set "WOW_PATH=!WOW_PATH: =!"
    set "WOW_PATH=!WOW_PATH:"=!"
    set "WOW_PATH=!WOW_PATH:,=!"
)

:: Извлекаем realmlist
for /f "tokens=2 delims=:" %%a in ('findstr /c:"realmlist" "%CONFIG_FILE%"') do (
    set "REALMLIST=%%a"
    set "REALMLIST=!REALMLIST: =!"
    set "REALMLIST=!REALMLIST:"=!"
    set "REALMLIST=!REALMLIST:,=!"
)

echo ==========================================
echo   Ночь темного Ворона — Лаунчер WoW 3.3.5a
echo ==========================================
echo Путь к WoW: %WOW_PATH%
echo Реалмлист: %REALMLIST%
echo ==========================================

:: Проверяем наличие WoW.exe
if not exist "%WOW_PATH%\%WOWEXECUTABLE%" (
    echo ОШИБКА: WoW.exe не найден по пути %WOW_PATH%
    echo Проверьте wowPath в config.json
    pause
    exit /b 1
)

:: Патчим realmlist.wtf
set "WTF_DIR=%WOW_PATH%\WTF"
set "REALMLIST_FILE=%WTF_DIR%\realmlist.wtf"

if not exist "%WTF_DIR%" mkdir "%WTF_DIR%"

echo set realmlist %REALMLIST% > "%REALMLIST_FILE%"
echo realmlist.wtf обновлён.

:: Опционально открываем веб-клиент
for /f "tokens=2 delims=:" %%a in ('findstr /c:"openWebClient" "%CONFIG_FILE%"') do (
    set "OPEN_WEB=%%a"
    set "OPEN_WEB=!OPEN_WEB: =!"
    set "OPEN_WEB=!OPEN_WEB:"=!"
    set "OPEN_WEB=!OPEN_WEB:,=!"
)

if /i "!OPEN_WEB!"=="true" (
    for /f "tokens=2 delims=:" %%a in ('findstr /c:"webUrl" "%CONFIG_FILE%"') do (
        set "WEB_URL=%%a"
        set "WEB_URL=!WEB_URL: =!"
        set "WEB_URL=!WEB_URL:"=!"
        set "WEB_URL=!WEB_URL:,=!"
    )
    echo Открытие веб-клиента: %WEB_URL%
    start "" "%WEB_URL%"
)

:: Запускаем WoW
echo Запуск WoW.exe...
start "" "%WOW_PATH%\%WOWEXECUTABLE%"

echo Лаунчер завершён.