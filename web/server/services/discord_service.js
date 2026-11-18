// ============================================================================
// Ночь темного Ворона — Discord уведомления
// Отправляет сообщения в Discord через Webhook при событиях соло-режима
// ============================================================================

const https = require('https');

class DiscordService {
    constructor(webhookUrl) {
        this.webhookUrl = webhookUrl;
        this.enabled = !!webhookUrl;
    }

    // Отправить embed-сообщение в Discord
    sendEmbed({ title, description, color = 0x7b2cbf, fields = [], footer = 'Ночь темного Ворона' }) {
        if (!this.enabled) return Promise.resolve();

        const payload = JSON.stringify({
            username: 'Ночь темного Ворона',
            avatar_url: 'https://i.imgur.com/placeholder.png', // опционально
            embeds: [{
                title,
                description,
                color,
                fields,
                timestamp: new Date().toISOString(),
                footer: { text: footer }
            }]
        });

        return new Promise((resolve, reject) => {
            const url = new URL(this.webhookUrl);
            const options = {
                hostname: url.hostname,
                port: 443,
                path: url.pathname,
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Content-Length': Buffer.byteLength(payload)
                }
            };

            const req = https.request(options, (res) => {
                let data = '';
                res.on('data', chunk => data += chunk);
                res.on('end', () => {
                    if (res.statusCode >= 200 && res.statusCode < 300) resolve(data);
                    else reject(new Error(`Discord responded ${res.statusCode}: ${data}`));
                });
            });

            req.on('error', reject);
            req.write(payload);
            req.end();
        });
    }

    // Уведомление: игрок включил соло-режим
    async notifySoloEnabled({ characterName, accountId, characterGuid, zone }) {
        return this.sendEmbed({
            title: '🌙 Соло-режим включен',
            description: `Игрок перешел в одиночное прохождение`,
            color: 0x7b2cbf,
            fields: [
                { name: 'Персонаж', value: characterName, inline: true },
                { name: 'Аккаунт', value: String(accountId), inline: true },
                { name: 'GUID', value: String(characterGuid), inline: true },
                { name: 'Зона', value: zone || 'Неизвестно', inline: true },
                { name: 'Сервер', value: 'Ночь темного Ворона', inline: true }
            ],
            footer: 'Discord уведомления • AzerothCore'
        });
    }

    // Уведомление: игрок вошел в соло-подземелье
    async notifySoloDungeon({ characterName, dungeonName, level }) {
        return this.sendEmbed({
            title: '🏰 Вход в соло-подземелье',
            description: `Игрок вошел в инстанс в одиночку`,
            color: 0x4B0082,
            fields: [
                { name: 'Персонаж', value: characterName, inline: true },
                { name: 'Подземелье', value: dungeonName, inline: true },
                { name: 'Уровень', value: String(level), inline: true }
            ],
            footer: 'Discord уведомления • AzerothCore'
        });
    }

    // Уведомление: игрок получил компаньона
    async notifyCompanion({ characterName, companionName }) {
        return this.sendEmbed({
            title: '🐦 Новый компаньон',
            description: `Игрок приручил спутника для соло-игры`,
            color: 0x4ade80,
            fields: [
                { name: 'Персонаж', value: characterName, inline: true },
                { name: 'Компаньон', value: companionName, inline: true }
            ],
            footer: 'Discord уведомления • AzerothCore'
        });
    }

    // Уведомление: рестарт сервера
    async notifyServerRestart({ reason, initiatedBy }) {
        return this.sendEmbed({
            title: '🔄 Рестарт WorldServer',
            description: `Сервер перезагружен`,
            color: 0xf59e0b,
            fields: [
                { name: 'Причина', value: reason, inline: true },
                { name: 'Инициатор', value: initiatedBy, inline: true },
                { name: 'Время', value: new Date().toLocaleString('ru-RU'), inline: true }
            ],
            footer: 'Администрирование • AzerothCore'
        });
    }
}

module.exports = DiscordService;