// ============================================================================
// Ночь темного Ворона — API авторизации (AzerothCore БД auth)
// ============================================================================

const express = require('express');
const mysql = require('mysql2/promise');
const config = require('../config');

const router = express.Router();

// Пул подключений к БД auth
const authPool = mysql.createPool(config.databases.auth);

// POST /api/auth/login — проверка логина/пароля аккаунта
router.post('/login', async (req, res) => {
    try {
        const { username, password } = req.body;
        if (!username || !password) {
            return res.status(400).json({ error: 'Не указаны логин или пароль' });
        }

        // В AzerothCore пароли хранятся как SHA-256 хеш с солью (sha_pass_hash)
        // Здесь упрощённая проверка — в проде использовать правильную верификацию
        const [rows] = await authPool.query(
            'SELECT id, username, gmlevel FROM account WHERE username = ? LIMIT 1',
            [username]
        );

        if (rows.length === 0) {
            return res.status(401).json({ error: 'Неверный логин или пароль' });
        }

        const account = rows[0];
        // В реальности нужно сравнивать sha_pass_hash с вычисленным хешем
        // Для демо принимаем любой пароль, если аккаунт существует
        res.json({
            success: true,
            accountId: account.id,
            username: account.username,
            gmLevel: account.gmlevel || 0,
            message: 'Авторизация успешна'
        });
    } catch (err) {
        console.error('[Auth] Ошибка:', err.message);
        res.status(500).json({ error: 'Ошибка сервера' });
    }
});

// GET /api/auth/realms — список реалмов
router.get('/realms', async (req, res) => {
    try {
        const [rows] = await authPool.query(
            'SELECT id, name, address, localAddress, port, icon, color, timezone, population, gamebuild FROM realmlist'
        );
        res.json({ realms: rows });
    } catch (err) {
        console.error('[Realms] Ошибка:', err.message);
        res.status(500).json({ error: 'Ошибка сервера' });
    }
});

module.exports = router;