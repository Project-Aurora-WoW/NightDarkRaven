// ============================================================================
// Ночь темного Ворона — Веб-сервер (Express)
// Точка входа веб-клиента MMORPG
// ============================================================================

const express = require('express');
const cors = require('cors');
const path = require('path');
const config = require('./config');

const authRoutes = require('./routes/auth');
const charactersRoutes = require('./routes/characters');
const worldRoutes = require('./routes/world');
const soloRoutes = require('./routes/solo');

const app = express();
const PORT = config.server.port || 3000;

// Middleware
app.use(cors({ origin: config.security.corsOrigin || '*' }));
app.use(express.json());

// Статические файлы клиента
app.use(express.static(path.join(__dirname, '..', 'client')));

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'online', name: 'Ночь темного Ворона', version: '1.0.0' });
});

// API маршруты
app.use('/api/auth', authRoutes);
app.use('/api/characters', charactersRoutes);
app.use('/api/world', worldRoutes);
app.use('/api/solo', soloRoutes);

// Главная страница — отдаём веб-клиент
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '..', 'client', 'index.html'));
});

// 404
app.use((req, res) => {
    res.status(404).json({ error: 'Not found' });
});

// Обработка ошибок
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, config.server.host, () => {
    console.log(`|cff4B0082[Ночь темного Ворона - Web]|r Сервер запущен на http://${config.server.host}:${PORT}`);
});

module.exports = app;