// ============================================================================
// Ночь темного Ворона — API автоимпорта SQL (админ)
// ============================================================================

const express = require('express');
const router = express.Router();
const config = require('../config');
const SqlImportService = require('../services/sql_import_service');
const mysql = require('mysql2/promise');

const worldPool = mysql.createPool(config.databases.world);
const sqlImport = new SqlImportService(config);

// Инициализировать при загрузке модуля
sqlImport.init(worldPool).catch(() => {});

// Middleware GM-прав
function requireGm(req, res, next) {
    const gmLevel = parseInt(req.headers['x-gm-level'] || '0', 10);
    if (gmLevel < 1) {
        return res.status(403).json({ error: 'Требуются права GM' });
    }
    next();
}

// POST /api/sqlimport/import — импортировать все SQL файлы
router.post('/import', requireGm, async (req, res) => {
    try {
        const { importAll = false } = req.body;

        let results;
        if (importAll) {
            results = await sqlImport.importAll();
        } else {
            results = await sqlImport.importNew();
        }

        const success = results.filter(r => r.status === 'success').length;
        const skipped = results.filter(r => r.status === 'skipped').length;
        const errors = results.filter(r => r.status === 'error').length;

        res.json({
            success: true,
            imported: results.length,
            success,
            skipped,
            errors,
            results,
            message: `Импортировано: ${success}, пропущено: ${skipped}, ошибок: ${errors}`
        });
    } catch (err) {
        console.error('[SQL Import API]', err.message);
        res.status(500).json({ error: err.message });
    }
});

// GET /api/sqlimport/status — статус импорта (какие файлы уже загружены)
router.get('/status', requireGm, async (req, res) => {
    try {
        const files = sqlImport.getSqlFiles();
        const imported = Array.from(sqlImport._importedLog);

        const status = files.map(f => ({
            filename: f,
            imported: imported.includes(f)
        }));

        res.json({
            total: files.length,
            imported: imported.length,
            pending: files.length - imported.length,
            status
        });
    } catch (err) {
        console.error('[SQL Import Status]', err.message);
        res.status(500).json({ error: err.message });
    }
});

// POST /api/sqlimport/import-file — импортировать один файл
router.post('/import-file', requireGm, async (req, res) => {
    try {
        const { filename } = req.body;
        if (!filename) return res.status(400).json({ error: 'Не указан filename' });

        const result = await sqlImport.importFile(filename);
        res.json({ success: true, ...result });
    } catch (err) {
        console.error('[SQL Import File]', err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;