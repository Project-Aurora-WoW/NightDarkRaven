// ============================================================================
// Ночь темного Ворона — Веб-i18n (международная поддержка)
// Поддержка русского (ru-RU) и английского (en-US) языков
// ============================================================================

const I18n = {
    // Текущий язык
    currentLang: 'ru-RU',

    // Загруженные переводы
    translations: {},

    // Загрузить переводы
    async loadLang(lang) {
        try {
            const response = await fetch(`../localization/web/${lang}.json`);
            if (!response.ok) throw new Error(`Lang file not found: ${lang}`);
            this.translations = await response.json();
            this.currentLang = lang;
            
            // Сохранить в localStorage
            localStorage.setItem('ndr_lang', lang);
            
            // Применить переводы ко всем элементам
            this.applyTranslations();
            
            console.log(`[NightDarkRaven] Language loaded: ${lang}`);
            return true;
        } catch (err) {
            console.error(`[NightDarkRaven] Error loading language: ${lang}`, err);
            return false;
        }
    },

    // Получить перевод по ключу
    t(key) {
        const keys = key.split('.');
        let current = this.translations;
        
        for (const k of keys) {
            if (current && current[k] !== undefined) {
                current = current[k];
            } else {
                return key; // Возвращаем ключ если перевод не найден
            }
        }
        return current || key;
    },

    // Применить переводы ко всем элементам с data-i18n атрибутом
    applyTranslations() {
        const elements = document.querySelectorAll('[data-i18n]');
        elements.forEach(el => {
            const key = el.getAttribute('data-i18n');
            const translation = this.t(key);
            if (translation) {
                el.textContent = translation;
            }
        });
        
        // Также обновить title атрибуты
        const titleElements = document.querySelectorAll('[data-i18n-title]');
        titleElements.forEach(el => {
            const key = el.getAttribute('data-i18n-title');
            const translation = this.t(key);
            if (translation) {
                el.title = translation;
            }
        });
        
        // Обновить placeholders
        const placeholderElements = document.querySelectorAll('[data-i18n-placeholder]');
        placeholderElements.forEach(el => {
            const key = el.getAttribute('data-i18n-placeholder');
            const translation = this.t(key);
            if (translation) {
                el.placeholder = translation;
            }
        });
    },

    // Инициализация
    async init() {
        // Проверить сохраненный язык
        const savedLang = localStorage.getItem('ndr_lang') || 'ru-RU';
        await this.loadLang(savedLang);
    }
};

// Глобальная функция t для удобства
window.t = (key) => I18n.t(key);

// Автоматическая инициализация при загрузке
document.addEventListener('DOMContentLoaded', () => {
    I18n.init();
});