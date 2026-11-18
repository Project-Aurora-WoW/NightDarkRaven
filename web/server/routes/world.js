// ============================================================================
// Ночь темного Ворона — API мира (AzerothCore БД world)
// Кампании, зоны, подземелья, мобы, предметы
// ============================================================================

const express = require('express');
const mysql = require('mysql2/promise');
const config = require('../config');

const router = express.Router();

const worldPool = mysql.createPool(config.databases.world);

// GET /api/world/campaigns — список кампаний (из квестов creature_template/quest_template)
router.get('/campaigns', async (req, res) => {
    try {
        // Кампании закодированы в квестах 90101-91105, выбираем уникальные дачителей
        const [rows] = await worldPool.query(
            `SELECT DISTINCT c.entry as npcId, c.name as npcName,
                    MIN(q.entry) as firstQuest, MAX(q.entry) as lastQuest
             FROM creature_template c
             JOIN creature_queststarter qs ON qs.id = c.entry
             JOIN quest_template q ON q.entry = qs.quest
             WHERE q.entry BETWEEN 90101 AND 91105
             GROUP BY c.entry
             ORDER BY firstQuest`
        );

        const campaigns = [
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

        res.json({ campaigns });
    } catch (err) {
        console.error('[Campaigns] Ошибка:', err.message);
        res.status(500).json({ error: 'Ошибка сервера' });
    }
});

// GET /api/world/zones — кастомные зоны
router.get('/zones', (req, res) => {
    const zones = [
        { id: 90001, name: 'Воронова Гора', map: 0, x: -8920, y: 540, z: 100, radius: 200 },
        { id: 90002, name: 'Лес Теней', map: 0, x: -8940, y: 550, z: 100, radius: 200 },
        { id: 90003, name: 'Храм Тьмы', map: 0, x: -9000, y: 580, z: 100, radius: 150 },
        { id: 90004, name: 'Логово Пустоты', map: 0, x: -9020, y: 590, z: 100, radius: 150 },
        { id: 90005, name: 'Крепость Ночи', map: 0, x: -9100, y: 630, z: 100, radius: 100 },
    ];
    res.json({ zones });
});

// GET /api/world/dungeons — подземелья
router.get('/dungeons', (req, res) => {
    const dungeons = [
        { id: 93001, name: 'Соло-ритуал Теней', minLevel: 10, maxLevel: 20 },
        { id: 93002, name: 'Соло-Храм Забвения', minLevel: 55, maxLevel: 65 },
        { id: 93003, name: 'Соло-Крепость Ночного Ворона', minLevel: 75, maxLevel: 80 },
    ];
    res.json({ dungeons });
});

// GET /api/world/items — список предметов модуля
router.get('/items', async (req, res) => {
    try {
        const [rows] = await worldPool.query(
            `SELECT entry, name, Quality as quality, description FROM item_template WHERE entry BETWEEN 90001 AND 91005`
        );
        res.json({ items: rows });
    } catch (err) {
        console.error('[Items] Ошибка:', err.message);
        res.status(500).json({ error: 'Ошибка сервера' });
    }
});

module.exports = router;