@echo off
:: ============================================================================
// Ночь темного Ворона — Рестарт WorldServer
// Запускается watcher_service.js при изменении Lua-файлов
// ============================================================================

setlocal

set "SERVER_DIR=%~dp0..\server"
set "WORLDSERVER_EXE=%SERVER_DIR%\worldserver.exe"
set "PID_FILE=%TEMP%\nightdarkraven_worldserver.pid"

echo [%date% %time%] Рестарт WorldServer...

:: Если есть PID — убиваем старый процесс
if exist "%PID_FILE%" (
    set /p OLD_PID="<%PID_FILE%"
    taskkill /PID %OLD_PID% /F >nul 2>&1
    echo Старый процесс %OLD_PID% завершен.
)

:: Запускаем новый worldserver и сохраняем PID
start "WorldServer" /D "%SERVER_DIR%" /B "%WORLDSERVER_EXE%"
:: Примечание: получение PID нового процесса в batch сложно, 
:: поэтому просто запускаем. Для продакшена используйте PM2 или systemd.

echo WorldServer запущен.
endlocal