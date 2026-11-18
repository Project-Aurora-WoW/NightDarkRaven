// ============================================================================
// Ночь темного Ворона — Мобильный лаунчер (PWA)
// Логика запуска WoW 3.3.5a с патчем realmlist.wtf
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

        this.log('Лаунчер загружен. Готов к работе.');
        this.status('Готов');

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
            this.logEl.scrollTop = this.logEl.logEl.scrollHeight;
        }
        console.log(message);
    },

    status(text) {
        if (this.statusEl) this.statusEl.textContent = text;
    },

    isAndroidWebView() {
        return navigator.userAgent.includes('Android') && navigator.userAgent.includes('wv');
    },

    // Обновить realmlist.wtf (запись в файл через WebView API или симуляция)
    async patchRealmlist() {
        const realm = this.realmlistInput.value.trim() || '127.0.0.1';
        this.status('Обновление realmlist.wtf...');
        this.log(`Попытка записи realmlist: set realmlist ${realm}`);

        try {
            // В реальном Android WebView здесь будет вызов JS-интерфейса Java/Kotlin
            // Например: AndroidLauncher.patchRealmlist(realm, wowPath)
            if (window.AndroidLauncher && window.AndroidLauncher.patchRealmlist) {
                await window.AndroidLauncher.patchRealmlist(realm, this.wowPathInput.value.trim());
                this.log('realmlist.wtf обновлен через Android WebView.');
                this.status('realmlist обновлен');
            } else {
                // Fallback: симуляция (для браузера)
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
                // Fallback для браузера
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
        const webUrl = 'http://localhost:3000'; // или из конфига
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