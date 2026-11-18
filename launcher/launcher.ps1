# ============================================================================
# Ночь темного Ворона — Лаунчер для WoW 3.3.5a (PowerShell)
# ============================================================================

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ConfigFile = Join-Path $ScriptDir "config.json"

if (-not (Test-Path $ConfigFile)) {
    Write-Host "Конфиг не найден, копирую пример..." -ForegroundColor Yellow
    Copy-Path (Join-Path $ScriptDir "config.example.json") $ConfigFile
    Write-Host "Отредактируйте $ConfigFile и запустите лаунчер снова." -ForegroundColor Cyan
    pause
    exit 1
}

$Config = Get-Content $ConfigFile | ConvertFrom-Json

$WowPath = $Config.wowPath
$WowExe = $Config.wowExecutable
$RealmList = $Config.realmlist
$WebUrl = $Config.webUrl
$OpenWeb = $Config.openWebClient

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Ночь темного Ворона — Лаунчер WoW 3.3.5a" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Путь к WoW: $WowPath" -ForegroundColor Gray
Write-Host "Реалмлист: $RealmList" -ForegroundColor Gray
Write-Host "==========================================" -ForegroundColor Cyan

if (-not (Test-Path (Join-Path $WowPath $WowExe))) {
    Write-Host "ОШИБКА: $WowExe не найден по пути $WowPath" -ForegroundColor Red
    Write-Host "Проверьте wowPath в config.json" -ForegroundColor Red
    pause
    exit 1
}

# Патчим realmlist.wtf
$WtfDir = Join-Path $WowPath "WTF"
$RealmListFile = Join-Path $WtfDir "realmlist.wtf"

if (-not (Test-Path $WtfDir)) {
    New-Item -ItemType Directory -Path $WtfDir | Out-Null
}

"set realmlist $RealmList" | Out-File -FilePath $RealmListFile -Encoding UTF8
Write-Host "realmlist.wtf обновлён." -ForegroundColor Green

# Открываем веб-клиент
if ($OpenWeb) {
    Write-Host "Открытие веб-клиента: $WebUrl" -ForegroundColor Cyan
    Start-Process $WebUrl
}

# Запускаем WoW
Write-Host "Запуск $WowExe..." -ForegroundColor Green
Start-Process -FilePath (Join-Path $WowPath $WowExe) -WorkingDirectory $WowPath

Write-Host "Лаунчер завершён." -ForegroundColor Gray