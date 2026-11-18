// ============================================================================
// Ночь темного Ворона — Админ API (требует gmlevel >= 1)
// ============================================================================

const express = require('express');
const mysql = require('mysql2/promise');
const router = express.Router();
const config = require('../config');
const DiscordService = require('../services/discord_service');

const worldPool = mysql.createPool(config.databases.world);
const charPool = mysql.createPool(config.databases.characters);

const discord = new DiscordService(config.discord.webhookUrl);

// Middleware проверки GM-уровня (упрощенно: заголовок X-GM-Level)
function requireGm(req, res, next) {
    const gmLevel = parseInt(req.headers['x-gm-level'] || '0', 10);
    if (gmLevel < 1) {
        return res.status(403).json({ error: 'Требуются права GM' });
    }
    next();
}

// GET /api/admin/solo-players — список всех соло-игроков
router.get('/solo-players', requireGm, async (req, res) => {
    try {
        const [rows] = await worldPool.query(
            `SELECT s.character_guid, s.account_id, s.solo_mode, s.companion_entry, s.updated_at,
                    c.name as character_name, c.level, c.zone, c.map, c.online
             FROM solo_state s
             LEFT JOIN characters c ON c.guid = s.character_guid
             ORDER BY s.updated_at DESC`
        );
        res.json({ soloPlayers: rows });
    } catch (err) {
        console.error('[Admin solo-players]', err.message);
        res.status(500).json({ error: err.message });
    }
});

// POST /api/admin/solo-toggle — массовое включение/выключение соло для персонажа
router.post('/solo-toggle', requireGm, async (req, res) => {
    try {
        const { characterGuid, enable, gmName } = req.body;
        if (!characterGuid) return res.status(400).json({ error: 'Не указан characterGuid' });

        const soloMode = enable === true ? 1 : 0;

        await worldPool.query(
            `INSERT INTO solo_state (character_guid, account_id, solo_mode) VALUES (?, 0, ?)
             ON DUPLICATE KEY UPDATE solo_mode = VALUES(solo_mode), updated_at = NOW()`,
            [characterGuid, soloMode]
        );

        await worldPool.query(
            `INSERT INTO solo_state_log (character_guid, account_id, solo_mode, changed_by) VALUES (?, 0, ?, 'admin')`,
            [characterGuid, soloMode]
        ]);

        // Уведомление в Discord
        const [chars] = await charPool.query('SELECT name FROM characters WHERE guid = ? LIMIT 1', [characterGuid]);
        if (chars.length > 0) {
            await discord.notifySoloEnabled({
                characterName: chars[0].name,
                accountId: 0,
                characterGuid,
                zone: 'Админ-панель'
            }).catch(() => {});
        }

        res.json({ success: true, soloMode: enable === true, message: 'Соло-режим изменен' });
    } catch (err) {
        console.error('[Admin solo-toggle]', err.message);
        res.status(500).json({ error: err.message });
    }
});

// GET /api/admin/stats — статистика сервера
router.get('/stats', requireGm, async (req, res) => {
    try {
        const [online] = await charPool.query('SELECT COUNT(*) as cnt FROM characters WHERE online = 1');
        const [soloActive] = await worldPool.query("SELECT COUNT(*) as cnt FROM solo_state WHERE solo_mode = 1");
        const [totalChars] = await charPool.query('SELECT COUNT(*) as cnt FROM characters');

        res.json({
            onlineCharacters: online[0].cnt,
            totalCharacters: totalChars[0].cnt,
            soloActive: soloActive[0].cnt,
            serverUptime: process.uptime()
        });
    } catch (err) {
        console.error('[Admin stats]', err.message);
        res.status(500).json({ error: err.message });
    }
});

// POST /api/admin/restart — сигнал рестарта worldserver (через скрипт)
router.post('/restart', requireGm, async (req, res) => {
    try {
        const { reason, initiatedBy } = req.body;
        const { exec } = require('child_process');
        const script = process.platform === 'win32'
            ? path.join(__dirname, '..', '..', '..', 'tools', 'restart_worldserver.bat')
            : path.join(__dirname, '..', '..', '..', 'tools', 'restart_worldserver.sh');

        const path = require('path');
        const scriptPath = path.resolve(__dirname, '../../../tools/restart_worldserver' + (process.platform === 'win32' ? '.bat' : '.sh'));

        exec(`"${scriptPath}"`, (error) => {
            if (error) {
                console.error('[Admin restart]', error.message);
                return res.status(500).json({ error: 'Ошибка рестарта' });
            }
            discord.notifyServerRestart({ reason: reason || 'Админ-панель', initiatedBy: initiatedBy || 'Admin' }).catch(() => {});
            res.json({ success: true, message: 'Рестарт инициирован' });
        });
    } catch (err) {
        console.error('[Admin restart]', err.message);
        res.status(500).json({ error: err.message });
    }
});

// GET /api/admin/logs — последние логи соло-состояний
router.get('/logs', requireGm, async (req, res) => {
    try {
        const [rows] = await worldPool.query(
            `SELECT id, character_guid, account_id, solo_mode, changed_by, changed_at
             FROM solo_state_log
             ORDER BY changed_at DESC
             LIMIT 50`
        );
        res.json({ logs: rows });
    } catch (err) {
        console.error('[Admin logs]', err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;