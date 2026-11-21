# Ночь темного Ворона — запуск тестового сервера (AzerothCore)
# Использование: powershell -ExecutionPolicy Bypass -File start_test.ps1

$ErrorActionPreference = "Stop"
$bin = "C:\Users\Orel\Downloads\azerothcore-wotlk\build\bin\RelWithDebInfo"

if (-not (Test-Path "$bin\authserver.exe")) { throw "authserver.exe not found in $bin" }
if (-not (Test-Path "$bin\worldserver.exe")) { throw "worldserver.exe not found in $bin" }

Write-Host "Starting authserver..."
Start-Process -FilePath "$bin\authserver.exe" -WorkingDirectory $bin

Start-Sleep -Seconds 3

Write-Host "Starting worldserver..."
Start-Process -FilePath "$bin\worldserver.exe" -WorkingDirectory $bin

Write-Host ""
Write-Host "Servers started. Logs:"
Write-Host "  $bin\authserver.log"
Write-Host "  $bin\worldserver.log"
Write-Host ""
Write-Host "Client: C:\World of Warcraft 3.3.5a (ruRu enGB enUs) (12340)\Wow.exe"
