// ============================================================================
// Ночь темного Ворона — API патчей клиента (веб-админ)
// ============================================================================

const express = require('express');
const mysql = require('mysql2/promise');
const router = express.Router();
const config = require('../config');

const worldPool = mysql.createPool(config.databases.world);

// Middleware GM-прав
function requireGm(req, res, next) {
    const gmLevel = parseInt(req.headers['x-gm-level'] || '0', 10);
    if (gmLevel < 1) {
        return res.status(403).json({ error: 'Требуются права GM' });
    }
    next();
}

// GET /api/clientpatches — список всех патчей клиента
router.get('/', requireGm, async (req, res) => {
    try {
        const [rows] = await worldPool.query(
            `SELECT patch_id, patch_name, patch_type, target_file, target_path,
                    is_required, is_applied, applied_at, created_at, version_from, version_to
             FROM client_patches
             ORDER BY patch_id`
        );
        res.json({ patches: rows });
    } catch (err) {
        console.error('[ClientPatches]', err.message);
        res.status(500).json({ error: err.message });
    }
});

// POST /api/clientpatches — создать новый патч
router.post('/', requireGm, async (req, res) => {
    try {
        const { patch_name, patch_type, target_file, target_path, content, version_from, version_to, is_required } = req.body;

        if (!patch_name || !patch_type || !target_file || !content) {
            return res.status(400).json({ error: 'Не заполнены обязательные поля' });
        }

        const [result] = await worldPool.query(
            `INSERT INTO client_patches (patch_name, patch_type, target_file, target_path, content, version_from, version_to, is_required)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
            [patch_name, patch_type, target_file, target_path || null, content, version_from || null, version_to || null, is_required === true ? 1 : 0]
        );

        res.json({
            success: true,
            patchId: result.insertId,
            message: 'Патч клиента создан'
        });
    } catch (err) {
        console.error('[ClientPatches create]', err.message);
        res.status(500).json({ error: err.message });
    }
});

// POST /api/clientpatches/:patchId/apply — отметить патч как применённый
router.post('/:patchId/apply', requireGm, async (req, res) => {
    try {
        const { patchId } = req.params;

        await worldPool.query(
            `UPDATE client_patches SET is_applied = 1, applied_at = NOW() WHERE patch_id = ?`,
            [patchId]
        );

        await worldPool.query(
            `INSERT INTO client_patch_log (patch_id, status, message, changed_by) VALUES (?, 'success', 'Применено через веб-админ', 'web')`,
            [patchId]
        );

        res.json({ success: true, message: 'Патч отмечен как применённый' });
    } catch (err) {
        console.error('[ClientPatches apply]', err.message);
        res.status(500).json({ error: err.message });
    }
});

// GET /api/clientpatches/log — история применения
router.get('/log', requireGm, async (req, res) => {
    try {
        const [rows] = await worldPool.query(
            `SELECT l.log_id, l.patch_id, p.patch_name, l.client_version, l.account_id,
                    l.status, l.message, l.applied_at
             FROM client_patch_log l
             LEFT JOIN client_patches p ON p.patch_id = l.patch_id
             ORDER BY l.applied_at DESC
             LIMIT 100`
        );
        res.json({ log: rows });
    } catch (err) {
        console.error('[ClientPatches log]', err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;