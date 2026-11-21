# ============================================================================
# Ночь темного Ворона — нормализатор SQL под реальную схему AzerothCore 3.3.5a
# Убирает устаревшие колонки из INSERT-ов creature_template / creature,
# переносит modelid в creature_template_model.
# Использование: powershell -File normalize_sql.ps1 [-WhatIf]
# ============================================================================

param(
    [string]$SqlDir = (Join-Path $PSScriptRoot "..\server\sql"),
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

# Колонки creature_template, которых больше нет в AC (удаляются из VALUES)
$ctDrop = @('scale', 'dmg_min', 'dmg_max', 'attack_power', 'range_attack_time')
# Переименования колонок creature_template
$ctMap = @{ 'base_attack_time' = 'BaseAttackTime'; 'range_attack_time' = 'RangeAttackTime' }
# Колонки creature, которых нет (удаляются)
$cDrop = @('corpse_delay', 'animprogress')

function Split-TopLevel {
    param([string]$Text, [char]$Sep)
    $res = New-Object System.Collections.Generic.List[string]
    $depth = 0; $inS = $false; $inD = $false; $inB = $false; $start = 0
    for ($i = 0; $i -lt $Text.Length; $i++) {
        $ch = $Text[$i]
        if ($inS) { if ($ch -eq "'") { if ($i + 1 -lt $Text.Length -and $Text[$i + 1] -eq "'") { $i++ } else { $inS = $false } }; continue }
        if ($inD) { if ($ch -eq '"') { if ($i + 1 -lt $Text.Length -and $Text[$i + 1] -eq '"') { $i++ } else { $inD = $false } }; continue }
        if ($inB) { if ($ch -eq '`') { $inB = $false }; continue }
        if ($ch -eq "'") { $inS = $true; continue }
        if ($ch -eq '"') { $inD = $true; continue }
        if ($ch -eq '`') { $inB = $true; continue }
        if ($ch -eq '(') { $depth++; continue }
        if ($ch -eq ')') { $depth--; continue }
        if ($ch -eq $Sep -and $depth -eq 0) { $res.Add($Text.Substring($start, $i - $start)); $start = $i + 1 }
    }
    $res.Add($Text.Substring($start))
    return , $res
}

function Find-StatementEnd {
    param([string]$Text, [int]$Start)
    $depth = 0; $inS = $false; $inD = $false; $inB = $false
    for ($i = $Start; $i -lt $Text.Length; $i++) {
        $ch = $Text[$i]
        if ($inS) { if ($ch -eq "'") { if ($i + 1 -lt $Text.Length -and $Text[$i + 1] -eq "'") { $i++ } else { $inS = $false } }; continue }
        if ($inD) { if ($ch -eq '"') { if ($i + 1 -lt $Text.Length -and $Text[$i + 1] -eq '"') { $i++ } else { $inD = $false } }; continue }
        if ($inB) { if ($ch -eq '`') { $inB = $false }; continue }
        if ($ch -eq "'") { $inS = $true; continue }
        if ($ch -eq '"') { $inD = $true; continue }
        if ($ch -eq '`') { $inB = $true; continue }
        if ($ch -eq '(') { $depth++; continue }
        if ($ch -eq ')') { $depth--; continue }
        if ($ch -eq ';' -and $depth -eq 0) { return $i }
    }
    return -1
}

function Normalize-CreateTemplate {
    param([string]$Stmt)
    $open = $Stmt.IndexOf('(')
    if ($open -lt 0) { return $Stmt }
    $close = $Stmt.IndexOf(')', $open)
    if ($close -lt 0) { return $Stmt }
    $colText = $Stmt.Substring($open + 1, $close - $open - 1)
    $cols = (Split-TopLevel $colText ',') | ForEach-Object { $_.Trim().Trim('`') }
    $valsIdx = $Stmt.IndexOf('VALUES', $close, [StringComparison]::OrdinalIgnoreCase)
    if ($valsIdx -lt 0) { return $Stmt }
    $valuesText = $Stmt.Substring($valsIdx + 6)
    # Отрезаем возможный ON DUPLICATE KEY UPDATE
    $onDup = [regex]::Match($valuesText, '(?is)\bON\s+DUPLICATE\s+KEY\b')
    $tail = ''
    if ($onDup.Success) { $tail = $valuesText.Substring($onDup.Index); $valuesText = $valuesText.Substring(0, $onDup.Index) }
    $valuesText = $valuesText.Trim().TrimEnd(';')

    $keep = New-Object System.Collections.Generic.List[int]
    $newCols = New-Object System.Collections.Generic.List[string]
    for ($i = 0; $i -lt $cols.Count; $i++) {
        $c = $cols[$i]
        $lc = $c.ToLower()
        if ($ctDrop -contains $lc) { continue }
        $keep.Add($i)
        $newCols.Add($(if ($ctMap.ContainsKey($lc)) { $ctMap[$lc] } else { $c }))
    }

    $tuples = Split-TopLevel $valuesText ','
    $outTuples = New-Object System.Collections.Generic.List[string]
    foreach ($t in $tuples) {
        $tt = $t.Trim()
        if (-not $tt.StartsWith('(')) { continue }
        $inner = $tt.Substring(1, $tt.Length - 2)
        $vals = Split-TopLevel $inner ','
        $newVals = New-Object System.Collections.Generic.List[string]
        foreach ($k in $keep) { if ($k -lt $vals.Count) { $newVals.Add($vals[$k].Trim()) } }
        $outTuples.Add('(' + ($newVals -join ', ') + ')')
    }

    $nl = "`r`n"
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append('INSERT INTO `creature_template` (' + $nl)
    [void]$sb.Append('    ' + (($newCols | ForEach-Object { "``$_``" }) -join ', ') + $nl)
    [void]$sb.Append(') VALUES' + $nl)
    [void]$sb.Append(($outTuples -join (',' + $nl)))
    if ($tail) { [void]$sb.Append($nl + $tail) }
    [void]$sb.Append(';')
    return $sb.ToString()
}

function Normalize-CreatureSpawn {
    param([string]$Stmt, [ref]$Models)
    $open = $Stmt.IndexOf('(')
    if ($open -lt 0) { return $Stmt }
    $close = $Stmt.IndexOf(')', $open)
    if ($close -lt 0) { return $Stmt }
    $colText = $Stmt.Substring($open + 1, $close - $open - 1)
    $cols = (Split-TopLevel $colText ',') | ForEach-Object { $_.Trim().Trim('`') }
    $valsIdx = $Stmt.IndexOf('VALUES', $close, [StringComparison]::OrdinalIgnoreCase)
    if ($valsIdx -lt 0) { return $Stmt }
    $valuesText = $Stmt.Substring($valsIdx + 6).Trim().TrimEnd(';')

    $keep = New-Object System.Collections.Generic.List[int]
    $newCols = New-Object System.Collections.Generic.List[string]
    $idIdx = -1; $modelIdx = -1
    for ($i = 0; $i -lt $cols.Count; $i++) {
        $lc = $cols[$i].ToLower()
        if ($cDrop -contains $lc) { continue }
        if ($lc -eq 'id') { $idIdx = $i; $keep.Add($i); $newCols.Add('id1'); continue }
        if ($lc -eq 'modelid') { $modelIdx = $i; continue }
        $keep.Add($i); $newCols.Add($cols[$i])
    }

    $tuples = Split-TopLevel $valuesText ','
    $outTuples = New-Object System.Collections.Generic.List[string]
    foreach ($t in $tuples) {
        $tt = $t.Trim()
        if (-not $tt.StartsWith('(')) { continue }
        $inner = $tt.Substring(1, $tt.Length - 2)
        $vals = Split-TopLevel $inner ','
        if ($modelIdx -ge 0 -and $idIdx -ge 0 -and $modelIdx -lt $vals.Count -and $idIdx -lt $vals.Count) {
            $entry = $vals[$idIdx].Trim()
            $model = $vals[$modelIdx].Trim()
            if ($entry -match '^\d+$' -and $model -match '^\d+$' -and [int]$model -gt 0) {
                $Models.Value[$entry] = $model
            }
        }
        $newVals = New-Object System.Collections.Generic.List[string]
        foreach ($k in $keep) { if ($k -lt $vals.Count) { $newVals.Add($vals[$k].Trim()) } }
        $outTuples.Add('(' + ($newVals -join ', ') + ')')
    }

    $nl = "`r`n"
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append('INSERT INTO `creature` (' + $nl)
    [void]$sb.Append('    ' + (($newCols | ForEach-Object { "``$_``" }) -join ', ') + $nl)
    [void]$sb.Append(') VALUES' + $nl)
    [void]$sb.Append(($outTuples -join (',' + $nl)) + ';')
    return $sb.ToString()
}

function Normalize-File {
    param([string]$Path)
    $text = [IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8)
    $models = @{}
    $changed = $false
    $result = New-Object System.Text.StringBuilder
    $pos = 0

    $pattern = [regex]'(?i)INSERT\s+INTO\s+`(creature_template|creature)`'
    while ($true) {
        $m = $pattern.Match($text, $pos)
        if (-not $m.Success) { break }
        $end = Find-StatementEnd -Text $text -Start $m.Index
        if ($end -lt 0) { break }
        $stmt = $text.Substring($m.Index, $end - $m.Index + 1)
        $repl = if ($m.Groups[1].Value -eq 'creature_template') {
            Normalize-CreateTemplate -Stmt $stmt
        } else {
            Normalize-CreatureSpawn -Stmt $stmt -Models ([ref]$models)
        }
        if ($repl -ne $stmt) { $changed = $true }
        [void]$result.Append($text.Substring($pos, $m.Index - $pos))
        [void]$result.Append($repl)
        $pos = $end + 1
    }
    [void]$result.Append($text.Substring($pos))

    if ($models.Count -gt 0) {
        $rows = ($models.GetEnumerator() | Sort-Object { [int]$_.Key } | ForEach-Object { "($($_.Key), 0, $($_.Value), 1, 1)" }) -join ",`r`n"
        [void]$result.Append("`r`n`r`n-- Модели NPC, перенесённые из устаревшей колонки modelid`r`n")
        [void]$result.Append("INSERT INTO ``creature_template_model`` (``CreatureID``, ``Idx``, ``CreatureDisplayID``, ``DisplayScale``, ``Probability``) VALUES`r`n")
        [void]$result.Append($rows + "`r`nON DUPLICATE KEY UPDATE ``CreatureDisplayID`` = VALUES(``CreatureDisplayID``);`r`n")
        $changed = $true
    }

    if ($changed -and -not $WhatIf) {
        [IO.File]::WriteAllText($Path, $result.ToString(), (New-Object Text.UTF8Encoding($false)))
    }
    return [pscustomobject]@{ File = (Split-Path $Path -Leaf); Changed = $changed; Models = $models.Count }
}

$report = @()
Get-ChildItem $SqlDir -Filter *.sql | Sort-Object Name | ForEach-Object {
    $r = Normalize-File -Path $_.FullName
    $report += $r
    if ($r.Changed) { Write-Host ("[fix] {0} (models: {1})" -f $r.File, $r.Models) }
}
Write-Host ("Done. Files changed: {0}" -f ($report | Where-Object Changed).Count)
