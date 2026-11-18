// ============================================================================
// Ночь темного Ворона — Android Лаунчер JS
// Взаимодействие с нативным кодом через window.AndroidLauncher
// ============================================================================

const launcher = {
    statusEl: null,
    logEl: null,
    realmlistInput: null,
    wowPathInput: null,

    async init() {
        this.statusEl = document.getElementById('status');
        this.logEl = document.getElementById('log');
        this.realmlistInput = document.getElementById('realmlist');
        this.wowPathInput = document.getElementById('wowPath');

        this.log('Лаунчер загружен.');
        this.status('Готов');

        // Проверка наличия нативного интерфейса
        if (window.AndroidLauncher) {
            this.log('Нативный интерфейс AndroidLauncher доступен.');
        } else {
            this.log('Нативный интерфейс недоступен (веб-режим).');
        }
    },

    log(message) {
        const time = new Date().toLocaleTimeString('ru-RU');
        const entry = `[${time}] ${message}\n`;
        if (this.logEl) {
            this.logEl.textContent += entry;
            this.logEl.scrollTop = this.logEl.scrollHeight;
        }
        console.log(message);
    },

    status(text) {
        if (this.statusEl) this.statusEl.textContent = text;
    },

    async patchRealmlist() {
        const realm = this.realmlistInput.value.trim() || '127.0.0.1';
        const wowPath = this.wowPathInput.value.trim();
        this.status('Обновление realmlist...');

        if (window.AndroidLauncher && window.AndroidLauncher.patchRealmlist) {
            window.AndroidLauncher.patchRealmlist(realm, wowPath);
        } else {
            this.log('Нативный API недоступен. Сохраните realmlist.wtf вручную:');
            this.log(`set realmlist ${realm}`);
            this.status('Готов (ручной патч)');
        }
    },

    async launch() {
        const realm = this.realmlistInput.value.trim() || '127.0.0.1';
        const wowPath = this.wowPathInput.value.trim();

        if (!wowPath) {
            this.log('Ошибка: укажите путь к WoW');
            this.status('Ошибка');
            return;
        }

        this.status('Запуск WoW...');
        this.log(`Путь: ${wowPath}`);
        this.log(`Realmlist: ${realm}`);

        if (window.AndroidLauncher && window.AndroidLauncher.launchWow) {
            window.AndroidLauncher.launchWow(wowPath, realm);
        } else {
            this.log('Нативный API недоступен. Запустите WoW.exe вручную.');
            this.status('Готов (ручной запуск)');
        }
    },

    async openWebClient() {
        const webUrl = 'http://10.0.2.2:3000'; // эмулятор Android -> localhost ПК
        this.log(`Открытие веб-клиента: ${webUrl}`);

        if (window.AndroidLauncher && window.AndroidLauncher.openUrl) {
            window.AndroidLauncher.openUrl(webUrl);
        } else {
            window.open(webUrl, '_blank');
        }
    }
};

document.addEventListener('DOMContentLoaded', () => launcher.init());