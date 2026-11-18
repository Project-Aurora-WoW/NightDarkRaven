// ============================================================================
// Ночь темного Ворона — API соло-режима и компаньонов
// ============================================================================

const express = require('express');
const router = express.Router();

// В реальной реализации здесь состояние соло-режима хранится в Redis/памяти сервера AzerothCore (Lua)
// Для веб-клиента это эндпоинты для переключения режима и получения компаньонов

// POST /api/solo/toggle — включить/выключить соло-режим (требует интеграции с Lua через БД или IPC)
router.post('/toggle', (req, res) => {
    const { accountId, characterGuid, enable } = req.body;
    res.json({
        success: true,
        soloMode: enable === true,
        message: enable ? 'Соло-режим включен' : 'Соло-режим выключен',
        note: 'Интеграция с AzerothCore Lua через БД или IPC требует доработки'
    });
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

// GET /api/solo/status — статус соло-режима персонажа
router.get('/status/:characterGuid', (req, res) => {
    const { characterGuid } = req.params;
    res.json({
        characterGuid,
        soloMode: false, // по умолчанию, обновляется из Lua/БД
        companion: null,
        message: 'Статус соло-режима требует интеграции с сервером AzerothCore'
    });
});

module.exports = router;