// ============================================================================
// Ночь темного Ворона — Веб-сервер (Express + HTTPS опция)
// Точка входа веб-клиента MMORPG
// ============================================================================

const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const http = require('http');
const https = require('https');
const config = require('./config');

const authRoutes = require('./routes/auth');
const charactersRoutes = require('./routes/characters');
const worldRoutes = require('./routes/world');
const soloRoutes = require('./routes/solo');
const adminRoutes = require('./routes/admin');

const DiscordService = require('./services/discord_service');
const WatcherService = require('./services/watcher_service');

const app = express();
const PORT = config.server.port || 3000;
const HTTPS_PORT = config.server.httpsPort || 3443;

// Discord сервис
const discord = new DiscordService(config.discord.webhookUrl);

// Middleware
app.use(cors({ origin: config.security.corsOrigin || '*' }));
app.use(express.json());

// Статические файлы клиента
app.use(express.static(path.join(__dirname, '..', 'client')));

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'online', name: 'Ночь темного Ворона', version: '1.1.0' });
});

// API маршруты
app.use('/api/auth', authRoutes);
app.use('/api/characters', charactersRoutes);
app.use('/api/world', worldRoutes);
app.use('/api/solo', soloRoutes);
app.use('/api/admin', adminRoutes);

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

// Запуск HTTP и/или HTTPS
const servers = [];

if (config.server.http !== false) {
    const httpServer = http.createServer(app).listen(PORT, config.server.host, () => {
        console.log(`|cff4B0082[Ночь темного Ворона - Web]|r HTTP сервер на http://${config.server.host}:${PORT}`);
    });
    servers.push(httpServer);
}

if (config.server.https) {
    try {
        const httpsOptions = {
            key: fs.readFileSync(config.ssl.keyPath),
            cert: fs.readFileSync(config.ssl.certPath)
        };
        const httpsServer = https.createServer(httpsOptions, app).listen(HTTPS_PORT, config.server.host, () => {
            console.log(`|cff4B0082[Ночь темного Ворона - Web]|r HTTPS сервер на https://${config.server.host}:${HTTPS_PORT}`);
        });
        servers.push(httpsServer);
    } catch (err) {
        console.error(`|cff4B0082[Ночь темного Ворона - Web]|r Ошибка SSL: ${err.message}`);
        console.warn('Генерируйте сертификат: cd ssl && ./generate_self_signed.sh (или .bat на Windows)');
    }
}

// Watcher Lua-файлов (авто-рестарт worldserver при изменениях)
if (config.watcher && config.watcher.enabled) {
    const watcher = new WatcherService(
        config.watcher.watchDir || path.resolve(__dirname, '../../../server/luaship/NightDarkRaven'),
        config.watcher.restartScript || path.resolve(__dirname, '../../../tools/restart_worldserver' + (process.platform === 'win32' ? '.bat' : '.sh')),
        config.watcher.debounceMs || 3000
    );
    watcher.start();

    // graceful stop
    process.on('SIGINT', () => watcher.stop());
    process.on('SIGTERM', () => watcher.stop());
}

if (servers.length === 0) {
    console.error('Не настроен ни один сервер (HTTP/HTTPS).');
    process.exit(1);
}

module.exports = app;