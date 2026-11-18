// ============================================================================
// Ночь темного Ворона — API соло-режима и компаньонов (с записью в БД)
// ============================================================================

const express = require('express');
const mysql = require('mysql2/promise');
const router = express.Router();
const config = require('../config');

// Пул подключений к БД world (для solo_state)
const worldPool = mysql.createPool(config.databases.world);

// POST /api/solo/toggle — включить/выключить соло-режим (запись в solo_state)
router.post('/toggle', async (req, res) => {
    try {
        const { accountId, characterGuid, enable } = req.body;

        if (!characterGuid) {
            return res.status(400).json({ error: 'Не указан characterGuid' });
        }

        const soloMode = enable === true ? 1 : 0;

        // Пишем в таблицу solo_state (Lua-сервер прочитает и применит)
        await worldPool.query(
            `INSERT INTO solo_state (character_guid, account_id, solo_mode) VALUES (?, ?, ?)
             ON DUPLICATE KEY UPDATE solo_mode = VALUES(solo_mode), updated_at = NOW()`,
            [characterGuid, accountId || 0, soloMode]
        );

        // Лог изменения
        await worldPool.query(
            `INSERT INTO solo_state_log (character_guid, account_id, solo_mode, changed_by) VALUES (?, ?, ?, 'web')`,
            [characterGuid, accountId || 0, soloMode]
        );

        res.json({
            success: true,
            soloMode: enable === true,
            message: enable ? 'Соло-режим включен' : 'Соло-режим выключен',
            note: 'Lua-сервер применит изменения при следующем опросе БД (до 5 сек)'
        });
    } catch (err) {
        console.error('[Solo toggle] Ошибка:', err.message);
        res.status(500).json({ error: 'Ошибка сервера: ' + err.message });
    }
});

// GET /api/solo/companions — список доступных компаньонов
router.get('/companions', (req, res) => {
    const companions = [
        { entry: 92001, name: 'Теневой Ворон', role: 'damage', desc: 'Летающий компаньон, наносит урон тенью.' },
        { entry: 92002, name: 'Страж Ночи', role: 'tank', desc: 'Тяжело сражающийся страж, притягивает на себя урон.' },
        { entry: 92003, name: 'Целитель Лунный', role: 'healer', desc: 'Излечивает соло-игрока в бою.' },
    ];
    res.json({ companions });
});

// POST /api/solo/companion — выбрать компаньона для персонажа
router.post('/companion', async (req, res) => {
    try {
        const { accountId, characterGuid, companionEntry } = req.body;

        if (!characterGuid || !companionEntry) {
            return res.status(400).json({ error: 'Не указаны characterGuid или companionEntry' });
        }

        await worldPool.query(
            `INSERT INTO solo_companions (character_guid, companion_entry) VALUES (?, ?)
             ON DUPLICATE KEY UPDATE companion_entry = VALUES(companion_entry), spawned_at = NOW()`,
            [characterGuid, companionEntry]
        );

        // Также обновляем companion_entry в solo_state
        await worldPool.query(
            `UPDATE solo_state SET companion_entry = ? WHERE character_guid = ?`,
            [companionEntry, characterGuid]
        );

        res.json({
            success: true,
            companionEntry,
            message: 'Компаньон установлен. Lua-сервер заспавнит его при входе в мир.'
        });
    } catch (err) {
        console.error('[Solo companion] Ошибка:', err.message);
        res.status(500).json({ error: 'Ошибка сервера: ' + err.message });
    }
});

// GET /api/solo/status/:characterGuid — статус соло-режима персонажа
router.get('/status/:characterGuid', async (req, res) => {
    try {
        const { characterGuid } = req.params;

        const [rows] = await worldPool.query(
            `SELECT solo_mode, companion_entry, updated_at FROM solo_state WHERE character_guid = ? LIMIT 1`,
            [characterGuid]
        );

        if (rows.length === 0) {
            return res.json({
                characterGuid: parseInt(characterGuid),
                soloMode: false,
                companion: null,
                message: 'Соло-режим не настроен'
            });
        }

        const row = rows[0];
        res.json({
            characterGuid: parseInt(characterGuid),
            soloMode: row.solo_mode === 1,
            companion: row.companion_entry || null,
            updatedAt: row.updated_at,
            message: row.solo_mode === 1 ? 'Соло-режим активен' : 'Соло-режим выключен'
        });
    } catch (err) {
        console.error('[Solo status] Ошибка:', err.message);
        res.status(500).json({ error: 'Ошибка сервера: ' + err.message });
    }
});

module.exports = router;