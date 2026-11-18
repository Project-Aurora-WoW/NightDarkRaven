-- ============================================================================
-- Ночь темного Ворона — Интеграция патчей с лаунчером
-- Предоставляет данные патчей для скачивания через веб-API и лаунчер
-- ============================================================================

local ClientPatchLauncher = {}

-- Получить патч по ID для отдачи лаунчеру
function ClientPatchLauncher.GetPatchForDownload(patchId)
    local patch = nil
    for _, p in ipairs(ClientPatchSystem._patchesCache or {}) do
        if p.id == patchId then
            patch = p
            break
        end
    end

    if not patch then
        -- Пытаемся загрузить из БД напрямую
        local query = string.format(
            "SELECT patch_id, patch_name, patch_type, target_file, target_path, content, checksum, is_required, is_applied FROM client_patches WHERE patch_id = %d",
            patchId
        )
        local result
        if WorldDBQuery then
            result = WorldDBQuery(query)
        end
        if result then
            patch = {
                id = result:GetUInt32(0),
                name = result:GetString(1),
                type = result:GetString(2),
                targetFile = result:GetString(3),
                targetPath = result:GetString(4),
                content = result:GetString(5),
                checksum = result:GetString(6),
                isRequired = result:GetUInt32(7) == 1,
                isApplied = result:GetUInt32(8) == 1
            }
        end
    end

    return patch
end

-- Получить все неприменённые патчи для лаунчера (JSON-подобная таблица)
function ClientPatchLauncher.GetUnappliedForLauncher()
    ClientPatchSystem.LoadPatches(true)
    local patches = {}
    for _, patch in ipairs(ClientPatchSystem.GetUnappliedPatches()) do
        table.insert(patches, {
            id = patch.id,
            name = patch.name,
            type = patch.type,
            targetFile = patch.targetFile,
            targetPath = patch.targetPath,
            content = patch.content,
            checksum = patch.checksum,
            isRequired = patch.isRequired
        })
    end
    return patches
end

-- Применить патч (пометить в БД как применённый)
function ClientPatchLauncher.ApplyPatch(patchId, source)
    source = source or "launcher"
    ClientPatchSystem.MarkPatchApplied(patchId, source)
end

-- Проверить статус патчей (для лаунчера)
function ClientPatchLauncher.CheckStatus()
    local unapplied = ClientPatchLauncher.GetUnappliedForLauncher()
    return {
        totalPatches = #(ClientPatchSystem._patchesCache or {}),
        unappliedCount = #unapplied,
        patches = unapplied,
        allApplied = #unapplied == 0
    }
end

function ClientPatchLauncher.Init()
    print("[NightDarkRaven] Интеграция патчей с лаунчером готова.")
end

return ClientPatchLauncher