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

    // Админ API
    adminGetStats() {
        return this.request('/admin/stats', { headers: { 'X-GM-Level': '3' } });
    },

    adminGetSoloPlayers() {
        return this.request('/admin/solo-players', { headers: { 'X-GM-Level': '3' } });
    },

    adminToggleSolo(characterGuid, enable) {
        return this.request('/admin/solo-toggle', {
            method: 'POST',
            headers: { 'X-GM-Level': '3' },
            body: JSON.stringify({ characterGuid, enable })
        });
    },

    adminRestart() {
        return this.request('/admin/restart', {
            method: 'POST',
            headers: { 'X-GM-Level': '3' },
            body: JSON.stringify({ reason: 'Админ-панель веб-клиента' })
        });
    },

    adminGetLogs() {
        return this.request('/admin/logs', { headers: { 'X-GM-Level': '3' } });
    },

    // SQL Импорт API
    sqlImportStatus() {
        return this.request('/sqlimport/status', { headers: { 'X-GM-Level': '3' } });
    },

    sqlImportAll() {
        return this.request('/sqlimport/import', {
            method: 'POST',
            headers: { 'X-GM-Level': '3' },
            body: JSON.stringify({ importAll: true })
        });
    },

    sqlImportNew() {
        return this.request('/sqlimport/import', {
            method: 'POST',
            headers: { 'X-GM-Level': '3' },
            body: JSON.stringify({ importAll: false })
        });
    },

    sqlImportFile(filename) {
        return this.request('/sqlimport/import-file', {
            method: 'POST',
            headers: { 'X-GM-Level': '3' },
            body: JSON.stringify({ filename })
        });
    },

    // Клиентские патчи API
    clientPatchesList() {
        return this.request('/clientpatches', { headers: { 'X-GM-Level': '3' } });
    },

    clientPatchesCreate(patchData) {
        return this.request('/clientpatches', {
            method: 'POST',
            headers: { 'X-GM-Level': '3' },
            body: JSON.stringify(patchData)
        });
    },

    clientPatchesApply(patchId) {
        return this.request(`/clientpatches/${patchId}/apply`, {
            method: 'POST',
            headers: { 'X-GM-Level': '3' }
        });
    },

    clientPatchesLog() {
        return this.request('/clientpatches/log', { headers: { 'X-GM-Level': '3' } });
    },

    // Кампании API
    getCampaigns() {
        return this.request('/campaigns', { headers: { 'X-GM-Level': '3' } });
    },

    getCampaignQuest(questId) {
        return this.request(`/campaigns/${questId}`, { headers: { 'X-GM-Level': '3' } });
    },

    toggleCampaignQuest(questId, enable) {
        return this.request(`/campaigns/${questId}/toggle`, {
            method: 'POST',
            headers: { 'X-GM-Level': '3' },
            body: JSON.stringify({ enable })
        });
    },

    setCampaignQuestLevel(questId, level) {
        return this.request(`/campaigns/${questId}/level`, {
            method: 'POST',
            headers: { 'X-GM-Level': '3' },
            body: JSON.stringify({ level })
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