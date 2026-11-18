// ============================================================================
// Ночь темного Ворона — Watcher Lua-файлов
// Следит за изменениями в server/luaship/NightDarkRaven/ и инициирует рестарт worldserver
// ============================================================================

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

class WatcherService {
    constructor(watchDir, restartScript, debounceMs = 3000) {
        this.watchDir = watchDir;
        this.restartScript = restartScript;
        this.debounceMs = debounceMs;
        this._timer = null;
        this._changedFiles = new Set();
        this._watcher = null;
    }

    start() {
        if (!fs.existsSync(this.watchDir)) {
            console.warn(`[Watcher] Директория не найдена: ${this.watchDir}`);
            return false;
        }

        console.log(`[Watcher] Слежение за Lua-файлами: ${this.watchDir}`);

        this._watcher = fs.watch(this.watchDir, { recursive: true }, (eventType, filename) => {
            if (!filename) return;
            if (!filename.endsWith('.lua') && !filename.endsWith('.cpp') && !filename.endsWith('.h')) return;

            this._changedFiles.add(filename);
            console.log(`[Watcher] Изменен: ${filename} (${eventType})`);

            if (this._timer) clearTimeout(this._timer);
            this._timer = setTimeout(() => this._triggerRestart(), this.debounceMs);
        });

        return true;
    }

    stop() {
        if (this._watcher) {
            this._watcher.close();
            this._watcher = null;
        }
        if (this._timer) clearTimeout(this._timer);
        this._changedFiles.clear();
    }

    async _triggerRestart() {
        const files = Array.from(this._changedFiles);
        this._changedFiles.clear();
        console.log(`[Watcher] Обнаружены изменения, инициирую рестарт: ${files.join(', ')}`);

        if (!this.restartScript || !fs.existsSync(this.restartScript)) {
            console.warn(`[Watcher] Скрипт рестарта не найден: ${this.restartScript}`);
            return;
        }

        exec(`"${this.restartScript}"`, (error, stdout, stderr) => {
            if (error) {
                console.error(`[Watcher] Ошибка рестарта: ${error.message}`);
                return;
            }
            console.log(`[Watcher] Рестарт выполнен: ${stdout}`);
        });
    }
}

module.exports = WatcherService;