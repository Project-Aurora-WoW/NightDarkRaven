// ============================================================================
// Ночь темного Ворона — API персонажей (AzerothCore БД characters)
// ============================================================================

const express = require('express');
const mysql = require('mysql2/promise');
const config = require('../config');

const router = express.Router();

const charPool = mysql.createPool(config.databases.characters);

// GET /api/characters/:accountId — список персонажей аккаунта
router.get('/:accountId', async (req, res) => {
    try {
        const { accountId } = req.params;
        const [rows] = await charPool.query(
            `SELECT guid, name, race, class, gender, level, zone, map, position_x, position_y, position_z,
                    online, totaltime, logout_time
             FROM characters WHERE account = ? ORDER BY level DESC`,
            [accountId]
        );

        const raceNames = { 1: 'Человек', 2: 'Орк', 3: 'Карлик', 4: 'Ночной эльф', 5: 'Нежить', 6: 'Таурен', 7: 'Гном', 8: 'Тролль', 10: 'Кровавый эльф', 11: 'Дреней' };
        const classNames = { 1: 'Воин', 2: 'Паладин', 3: 'Охотник', 4: 'Разбойник', 5: 'Жрец', 7: 'Шаман', 8: 'Маг', 9: 'Чернокнижник', 11: 'Друид' };

        const characters = rows.map(c => ({
            guid: c.guid,
            name: c.name,
            race: raceNames[c.race] || c.race,
            class: classNames[c.class] || c.class,
            gender: c.gender,
            level: c.level,
            zone: c.zone,
            map: c.map,
            x: c.position_x,
            y: c.position_y,
            z: c.position_z,
            online: c.online === 1,
            totalTime: c.totaltime || 0
        }));

        res.json({ characters });
    } catch (err) {
        console.error('[Characters] Ошибка:', err.message);
        res.status(500).json({ error: 'Ошибка сервера' });
    }
});

// GET /api/characters/:accountId/:guid — подробная информация о персонаже
router.get('/:accountId/:guid', async (req, res) => {
    try {
        const { accountId, guid } = req.params;
        const [rows] = await charPool.query(
            `SELECT * FROM characters WHERE guid = ? AND account = ? LIMIT 1`,
            [guid, accountId]
        );

        if (rows.length === 0) {
            return res.status(404).json({ error: 'Персонаж не найден' });
        }

        res.json({ character: rows[0] });
    } catch (err) {
        console.error('[Character] Ошибка:', err.message);
        res.status(500).json({ error: 'Ошибка сервера' });
    }
});

module.exports = router;