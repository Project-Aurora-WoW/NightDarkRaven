// ============================================================================
// Ночь темного Ворона — Автоимпорт SQL (интеграция с базой данных)
// Читает .sql файлы из server/sql/ и импортирует их в MySQL
// ============================================================================

const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');

class SqlImportService {
    constructor(config) {
        this.config = config;
        this.sqlDir = path.resolve(__dirname, '../../../server/sql');
        this._importedLog = new Set();
    }

    // Инициализация: создать таблицу лога импорта, если нужно
    async init(pool) {
        this.pool = pool;
        try {
            await pool.query(`
                CREATE TABLE IF NOT EXISTS sql_import_log (
                    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                    filename VARCHAR(255) NOT NULL,
                    status ENUM('success','error','skipped') NOT NULL,
                    message TEXT,
                    imported_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    INDEX idx_filename (filename)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
            `);

            // Загрузить уже импортированные файлы
            const [rows] = await pool.query("SELECT filename FROM sql_import_log WHERE status = 'success'");
            for (const r of rows) this._importedLog.add(r.filename);

            console.log(`[SQL Import] Загружено уже импортированных файлов: ${this._importedLog.size}`);
        } catch (err) {
            console.error('[SQL Init]', err.message);
        }
    }

    // Получить список SQL-файлов в порядке импорта
    getSqlFiles() {
        if (!fs.existsSync(this.sqlDir)) return [];
        return fs.readdirSync(this.sqlDir)
            .filter(f => f.endsWith('.sql'))
            .sort();
    }

    // Импортировать один файл (разбивает на отдельные запросы по точке с запятой)
    async importFile(filename) {
        if (this._importedLog.has(filename)) {
            return { filename, status: 'skipped', message: 'Уже импортирован' };
        }

        const filePath = path.join(this.sqlDir, filename);
        if (!fs.existsSync(filePath)) {
            return { filename, status: 'error', message: 'Файл не найден' };
        }

        const sql = fs.readFileSync(filePath, 'utf-8');
        const statements = sql.split(';').map(s => s.trim()).filter(s => s.length > 0);

        let successCount = 0;
        let errorMsg = null;

        for (const stmt of statements) {
            // Пропускаем комментарии и USE-запросы (уже имеем подключение к world)
            const trimmed = stmt.trim();
            if (trimmed.startsWith('--') || trimmed.startsWith('/*') || trimmed.toUpperCase().startsWith('USE ')) continue;

            try {
                await this.pool.query(stmt);
                successCount++;
            } catch (err) {
                // Некоторые ошибки (дубликаты ключей) не критичны
                if (err.code === 'ER_DUP_ENTRY' || err.code === 'ER_TABLE_EXISTS_ERROR') {
                    successCount++;
                } else {
                    errorMsg = err.message;
                    break;
                }
            }
        }

        const status = errorMsg ? 'error' : 'success';
        this._importedLog.add(filename);

        // Запись в лог
        await this.pool.query(
            `INSERT INTO sql_import_log (filename, status, message) VALUES (?, ?, ?)`,
            [filename, status, errorMsg || null]
        );

        return { filename, status, message: errorMsg || `Импортировано ${successCount} запросов` };
    }

    // Импортировать все файлы по порядку
    async importAll() {
        const files = this.getSqlFiles();
        const results = [];

        for (const file of files) {
            const result = await this.importFile(file);
            results.push(result);
            console.log(`[SQL Import] ${file}: ${result.status} — ${result.message}`);
        }

        return results;
    }

    // Импортировать только новые (не импортированные ранее)
    async importNew() {
        const files = this.getSqlFiles();
        const newFiles = files.filter(f => !this._importedLog.has(f));
        const results = [];

        for (const file of newFiles) {
            const result = await this.importFile(file);
            results.push(result);
        }

        return results;
    }
}

module.exports = SqlImportService;