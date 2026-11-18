// ============================================================================
// Ночь темного Ворона — API управления квестами кампаний (веб-админ)
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

// Кампании с квестами (кэшируемая метаинформация)
const CAMPAIGNS_META = [
    { id: 1, name: 'Пробуждение Ворона', npcId: 90010, quests: [90101, 90102, 90103] },
    { id: 2, name: 'Тени Вороновой Горы', npcId: 90020, quests: [90201, 90202, 90203, 90204] },
    { id: 3, name: 'Проклятие Перьев', npcId: 90030, quests: [90301, 90302, 90303] },
    { id: 4, name: 'Кровавая Луна', npcId: 90040, quests: [90401, 90402, 90403, 90404] },
    { id: 5, name: 'Хранители Ночи', npcId: 90050, quests: [90501, 90502, 90503] },
    { id: 6, name: 'Забытый Храм', npcId: 90060, quests: [90601, 90602, 90603, 90604] },
    { id: 7, name: 'Печать Тьмы', npcId: 90070, quests: [90701, 90702, 90703] },
    { id: 8, name: 'Вороновой Клинок', npcId: 90080, quests: [90801, 90802, 90803, 90804] },
    { id: 9, name: 'Ночной Дозор', npcId: 90090, quests: [90901, 90902, 90903] },
    { id: 10, name: 'Ворон и Луна', npcId: 90100, quests: [91001, 91002, 91003, 91004] },
    { id: 11, name: 'Конец Ночи', npcId: 90110, quests: [91101, 91102, 91103, 91104, 91105] },
];

// GET /api/campaigns — список кампаний с состоянием квестов
router.get('/', requireGm, async (req, res) => {
    try {
        const result = [];
        for (const camp of CAMPAIGNS_META) {
            const questDetails = [];
            for (const qid of camp.quests) {
                const [rows] = await worldPool.query(
                    `SELECT entry, Title as title, MinLevel as minLevel, QuestLevel as level, Flags as flags FROM quest_template WHERE entry = ?`,
                    [qid]
                );
                questDetails.push(rows[0] || { entry: qid, title: 'Неизвестно', flags: 0 });
            }
            result.push({
                id: camp.id,
                name: camp.name,
                npcId: camp.npcId,
                quests: questDetails
            });
        }
        res.json({ campaigns: result });
    } catch (err) {
        console.error('[Campaigns]', err.message);
        res.status(500).json({ error: err.message });
    }
});

// GET /api/campaigns/:questId — детали квеста
router.get('/:questId', requireGm, async (req, res) => {
    try {
        const { questId } = req.params;
        const [rows] = await worldPool.query(
            `SELECT * FROM quest_template WHERE entry = ? LIMIT 1`,
            [questId]
        );
        if (rows.length === 0) return res.status(404).json({ error: 'Квест не найден' });
        res.json({ quest: rows[0] });
    } catch (err) {
        console.error('[Campaign quest]', err.message);
        res.status(500).json({ error: err.message });
    }
});

// POST /api/campaigns/:questId/toggle — включить/выключить квест (флаг 0x0001 = активен)
router.post('/:questId/toggle', requireGm, async (req, res) => {
    try {
        const { questId } = req.params;
        const { enable } = req.body;

        const [rows] = await worldPool.query(
            `SELECT Flags FROM quest_template WHERE entry = ? LIMIT 1`,
            [questId]
        );
        if (rows.length === 0) return res.status(404).json({ error: 'Квест не найден' });

        let flags = rows[0].Flags || 0;
        const ACTIVE_FLAG = 0x0001;

        if (enable === true) {
            flags |= ACTIVE_FLAG;
        } else {
            flags &= ~ACTIVE_FLAG;
        }

        await worldPool.query(
            `UPDATE quest_template SET Flags = ? WHERE entry = ?`,
            [flags, questId]
        );

        res.json({
            success: true,
            questId: parseInt(questId),
            enabled: enable === true,
            flags,
            message: enable ? 'Квест активирован' : 'Квест деактивирован'
        });
    } catch (err) {
        console.error('[Campaign toggle]', err.message);
        res.status(500).json({ error: err.message });
    }
});

// POST /api/campaigns/:questId/level — изменить уровень квеста
router.post('/:questId/level', requireGm, async (req, res) => {
    try {
        const { questId } = req.params;
        const { level } = req.body;

        if (!level || level < 1 || level > 80) {
            return res.status(400).json({ error: 'Некорректный уровень (1-80)' });
        }

        await worldPool.query(
            `UPDATE quest_template SET QuestLevel = ?, MinLevel = ? WHERE entry = ?`,
            [level, level, questId]
        );

        res.json({
            success: true,
            questId: parseInt(questId),
            level,
            message: `Уровень квеста изменен на ${level}`
        });
    } catch (err) {
        console.error('[Campaign level]', err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;