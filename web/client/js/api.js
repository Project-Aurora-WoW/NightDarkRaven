// ============================================================================
// Ночь темного Ворона — API клиент (веб)
// ============================================================================

const API_BASE = '/api';

const api = {
    async request(endpoint, options = {}) {
        const url = `${API_BASE}${endpoint}`;
        const config = {
            headers: { 'Content-Type': 'application/json' },
            ...options
        };
        const response = await fetch(url, config);
        if (!response.ok) {
            const err = await response.json().catch(() => ({}));
            throw new Error(err.error || `Ошибка ${response.status}`);
        }
        return response.json();
    },

    // Авторизация
    login(username, password) {
        return this.request('/auth/login', {
            method: 'POST',
            body: JSON.stringify({ username, password })
        });
    },

    getRealms() {
        return this.request('/auth/realms');
    },

    // Персонажи
    getCharacters(accountId) {
        return this.request(`/characters/${accountId}`);
    },

    getCharacter(accountId, guid) {
        return this.request(`/characters/${accountId}/${guid}`);
    },

    // Мир
    getCampaigns() {
        return this.request('/world/campaigns');
    },

    getZones() {
        return this.request('/world/zones');
    },

    getDungeons() {
        return this.request('/world/dungeons');
    },

    getItems() {
        return this.request('/world/items');
    },

    // Соло
    toggleSolo(enable, characterGuid) {
        return this.request('/solo/toggle', {
            method: 'POST',
            body: JSON.stringify({ enable, characterGuid })
        });
    },

    companionSelect(characterGuid, companionEntry) {
        return this.request('/solo/companion', {
            method: 'POST',
            body: JSON.stringify({ characterGuid, companionEntry })
        });
    },

    getCompanions() {
        return this.request('/solo/companions');
    },

    getSoloStatus(characterGuid) {
        return this.request(`/solo/status/${characterGuid}`);
    }
};