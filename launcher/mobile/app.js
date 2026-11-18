// ============================================================================
// Ночь темного Ворона — Мобильный лаунчер (PWA)
// Логика запуска WoW 3.3.5a с патчем realmlist.wtf и скачиванием патчей клиента
// ============================================================================

const launcher = {
    statusEl: null,
    logEl: null,
    realmlistInput: null,
    wowPathInput: null,
    webApiUrl: 'http://localhost:3000', // URL веб-API сервера

    async init() {
        this.statusEl = document.getElementById('status');
        this.logEl = document.getElementById('log');
        this.realmlistInput = document.getElementById('realmlist');
        this.wowPathInput = document.getElementById('wowPath');

        this.log('Лаунчер загружен. Готов к работе.');
        this.status('Готов');

        // Проверка патчей при запуске
        await this.checkPatches();

        // Проверка поддержки WebView / Android (опционально)
        if (this.isAndroidWebView()) {
            this.log('Обнаружена среда Android WebView.');
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

    isAndroidWebView() {
        return navigator.userAgent.includes('Android') && navigator.userAgent.includes('wv');
    },

    // Проверить нужные патчи через веб-API
    async checkPatches() {
        try {
            this.status('Проверка патчей...');
            const response = await fetch(`${this.webApiUrl}/api/clientpatches/check`);
            const data = await response.json();

            if (data.needsUpdate && data.patches && data.patches.length > 0) {
                this.log(`Найдено патчей к применению: ${data.patches.length}`);
                for (const patch of data.patches) {
                    this.log(`  - ${patch.patch_name} (${patch.target_file})`);
                }
                this.status(`Нужно применить ${data.patches.length} патчей`);
                return data.patches;
            } else {
                this.log('Все патчи применены.');
                this.status('Все патчи применены');
                return [];
            }
        } catch (err) {
            this.log(`Не удалось проверить патчи: ${err.message}`);
            this.status('Ошибка проверки патчей');
            return [];
        }
    },

    // Скачать и применить патч через веб-API
    async applyPatch(patchId) {
        try {
            this.status(`Скачивание патча #${patchId}...`);
            this.log(`Скачивание патча #${patchId}...`);

            const response = await fetch(`${this.webApiUrl}/api/clientpatches/${patchId}/download?autoApply=true`);
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            const content = await response.text();
            const patchName = response.headers.get('X-Patch-Name') || 'Неизвестно';
            const targetFile = response.headers.get('X-Target-File') || 'Неизвестно';

            this.log(`Патч скачан: ${patchName}`);
            this.log(`Целевой файл: ${targetFile}`);

            // Пытаемся применить через нативный API (Android WebView)
            if (window.AndroidLauncher && window.AndroidLauncher.applyPatch) {
                await window.AndroidLauncher.applyPatch(patchId, content, targetFile);
                this.log('Патч применён через нативный API.');
            } else {
                // Fallback: выводим содержимое для ручного применения
                this.log('--- Содержимое патча ---');
                this.log(content);
                this.log('--- Конец патча ---');
                this.log('Примените патч вручную или через десктоп-лаунчер.');
            }

            this.status('Патч применён');
            await this.checkPatches();
        } catch (err) {
            this.log(`Ошибка применения патча: ${err.message}`);
            this.status('Ошибка применения патча');
        }
    },

    // Обновить realmlist.wtf (запись в файл через WebView API или симуляция)
    async patchRealmlist() {
        const realm = this.realmlistInput.value.trim() || '127.0.0.1';
        this.status('Обновление realmlist.wtf...');
        this.log(`Попытка записи realmlist: set realmlist ${realm}`);

        try {
            if (window.AndroidLauncher && window.AndroidLauncher.patchRealmlist) {
                await window.AndroidLauncher.patchRealmlist(realm, this.wowPathInput.value.trim());
                this.log('realmlist.wtf обновлён через Android WebView.');
                this.status('realmlist обновлен');
            } else {
                this.log('WebView API не найден. Симуляция записи.');
                this.log(`Буфер: set realmlist ${realm}`);
                this.status('Готов (симуляция)');
            }
        } catch (err) {
            this.log(`Ошибка: ${err.message}`);
            this.status('Ошибка');
        }
    },

    // Запустить WoW.exe
    async launch() {
        const realm = this.realmlistInput.value.trim() || '127.0.0.1';
        const wowPath = this.wowPathInput.value.trim();

        if (!wowPath) {
            this.log('Ошибка: укажите путь к WoW');
            this.status('Ошибка: нет пути');
            return;
        }

        this.status('Запуск WoW...');
        this.log(`Путь к WoW: ${wowPath}`);
        this.log(`Realmlist: ${realm}`);

        try {
            if (window.AndroidLauncher && window.AndroidLauncher.launchWow) {
                await window.AndroidLauncher.launchWow(wowPath, realm);
                this.log('WoW запущен через Android WebView.');
                this.status('WoW запущен');
            } else {
                this.log('WebView API не найден. Используйте десктопный лаунчер (.bat/.ps1).');
                this.status('Готов (веб-версия)');
            }
        } catch (err) {
            this.log(`Ошибка запуска: ${err.message}`);
            this.status('Ошибка запуска');
        }
    },

    // Открыть веб-клиент
    async openWebClient() {
        const webUrl = this.webApiUrl; // URL веб-клиента
        this.log(`Открытие веб-клиента: ${webUrl}`);

        try {
            if (window.AndroidLauncher && window.AndroidLauncher.openUrl) {
                await window.AndroidLauncher.openUrl(webUrl);
            } else {
                window.open(webUrl, '_blank');
            }
        } catch (err) {
            this.log(`Ошибка открытия URL: ${err.message}`);
        }
    }
};

// Запуск
document.addEventListener('DOMContentLoaded', () => launcher.init());