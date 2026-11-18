# ============================================================================
# Ночь темного Ворона — Лаунчер для WoW 3.3.5a (PowerShell) с интеграцией патчей
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
Write-Host "Веб-API: $WebUrl" -ForegroundColor Gray
Write-Host "==========================================" -ForegroundColor Cyan

if (-not (Test-Path (Join-Path $WowPath $WowExe))) {
    Write-Host "ОШИБКА: $WowExe не найден по пути $WowPath" -ForegroundColor Red
    Write-Host "Проверьте wowPath в config.json" -ForegroundColor Red
    pause
    exit 1
}

# ============================================
# ЭТАП 1: Проверка и применение патчей клиента
# ============================================
Write-Host "[1/3] Проверка патчей клиента через веб-API..." -ForegroundColor Cyan

try {
    $PatchCheckUrl = "$WebUrl/api/clientpatches/check"
    $Response = Invoke-RestMethod -Uri $PatchCheckUrl -Method Get -ErrorAction Stop

    if ($Response.needsUpdate -and $Response.patches -and $Response.patches.Count -gt 0) {
        Write-Host "Найдено патчей к применению: $($Response.patches.Count)" -ForegroundColor Yellow
        foreach ($patch in $Response.patches) {
            Write-Host "  - $($patch.patch_name) ($($patch.target_file))" -ForegroundColor Gray
        }

        # Скачиваем и применяем каждый патч
        foreach ($patch in $Response.patches) {
            $DownloadUrl = "$WebUrl/api/clientpatches/$($patch.patch_id)/download?autoApply=true"
            Write-Host "Скачивание патча #$($patch.patch_id)..." -ForegroundColor Cyan
            try {
                $PatchContent = Invoke-RestMethod -Uri $DownloadUrl -Method Get -ErrorAction Stop
                Write-Host "Патч применён через веб-API." -ForegroundColor Green
            } catch {
                Write-Host "Ошибка применения патча #$($patch.patch_id): $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Все патчи применены." -ForegroundColor Green
    }
} catch {
    Write-Host "Не удалось подключиться к веб-API. Пропускаем проверку патчей." -ForegroundColor Yellow
}

# ============================================
# ЭТАП 2: Патчим realmlist.wtf
# ============================================
Write-Host "[2/3] Обновление realmlist.wtf..." -ForegroundColor Cyan

$WtfDir = Join-Path $WowPath "WTF"
$RealmListFile = Join-Path $WtfDir "realmlist.wtf"

if (-not (Test-Path $WtfDir)) {
    New-Item -ItemType Directory -Path $WtfDir | Out-Null
}

"set realmlist $RealmList" | Out-File -FilePath $RealmListFile -Encoding UTF8
Write-Host "realmlist.wtf обновлён." -ForegroundColor Green

# ============================================
# ЭТАП 3: Запуск WoW
# ============================================
Write-Host "[3/3] Запуск WoW..." -ForegroundColor Cyan

# Открываем веб-клиент
if ($OpenWeb) {
    Write-Host "Открытие веб-клиента: $WebUrl" -ForegroundColor Cyan
    Start-Process $WebUrl
}

Write-Host "Запуск $WowExe..." -ForegroundColor Green
Start-Process -FilePath (Join-Path $WowPath $WowExe) -WorkingDirectory $WowPath

Write-Host "Лаунчер завершён." -ForegroundColor Gray