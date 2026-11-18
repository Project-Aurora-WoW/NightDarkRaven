// ============================================================================
// Ночь темного Ворона — Конфигурация веб-сервера
// ============================================================================

const path = require('path');
const fs = require('fs');

let config;
try {
    config = require(path.join(__dirname, '..', 'config.json'));
} catch (e) {
    console.warn('[NightDarkRaven Web] config.json не найден, используются значения по умолчанию');
    config = {
        server: { port: 3000, host: '0.0.0.0', https: false, httpsPort: 3443 },
        databases: {
            auth: { host: '127.0.0.1', port: 3306, user: 'root', password: '', database: 'auth' },
            characters: { host: '127.0.0.1', port: 3306, user: 'root', password: '', database: 'characters' },
            world: { host: '127.0.0.1', port: 3306, user: 'root', password: '', database: 'world' }
        },
        security: { corsOrigin: '*', sessionSecret: 'change-me-in-production' },
        ssl: { certPath: path.join(__dirname, '..', 'ssl', 'certs', 'nightdarkraven.crt'), keyPath: path.join(__dirname, '..', 'ssl', 'certs', 'nightdarkraven.key') }
    };
}

module.exports = config;