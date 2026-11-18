// ============================================================================
// Ночь темного Ворона — Логика веб-клиента
// ============================================================================

const app = {
    currentAccountId: null,
    currentSection: 'login',

    async init() {
        // Проверка сервера
        try {
            await api.request('/health');
            document.getElementById('serverStatus').textContent = 'Сервер онлайн';
            document.getElementById('serverStatus').className = 'status online';
        } catch (e) {
            document.getElementById('serverStatus').textContent = 'Сервер недоступен';
            document.getElementById('serverStatus').className = 'status offline';
        }

        // Навигация
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', () => {
                const section = item.getAttribute('data-section');
                this.switchSection(section);
            });
        });

        // Загрузка данных мира при открытии
        this.loadWorldData();
    },

    switchSection(section) {
        // Скрыть все секции
        document.querySelectorAll('.section').forEach(s => s.classList.add('hidden'));
        // Активная навигация
        document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
        // Показать выбранную
        document.getElementById(`section-${section}`).classList.remove('hidden');
        document.querySelector(`.nav-item[data-section="${section}"]`).classList.add('active');
        this.currentSection = section;

        // Загрузка данных для секции
        if (section === 'characters' && this.currentAccountId) {
            this.loadCharacters();
        }
        if (section === 'world') {
            this.loadWorldData();
        }
        if (section === 'solo') {
            this.loadSoloData();
        }
    },

    async login() {
        const username = document.getElementById('loginUsername').value;
        const password = document.getElementById('loginPassword').value;
        const messageEl = document.getElementById('loginMessage');

        try {
            const result = await api.login(username, password);
            this.currentAccountId = result.accountId;
            messageEl.textContent = 'Успешный вход!';
            messageEl.style.color = '#4ade80';
            this.switchSection('characters');
            this.loadCharacters();
        } catch (e) {
            messageEl.textContent = e.message;
            messageEl.style.color = '#f87171';
        }
    },

    async loadCharacters() {
        const el = document.getElementById('charList');
        el.innerHTML = 'Загрузка персонажей...';
        try {
            const result = await api.getCharacters(this.currentAccountId);
            const chars = result.characters || [];
            el.innerHTML = chars.map(c => `
                <div class="char-card">
                    <div class="char-info">
                        <h4>${c.name}</h4>
                        <p>${c.race} · ${c.class} · Уровень ${c.level}</p>
                        <p>Зона: ${c.zone} · Онлайн: ${c.online ? 'Да' : 'Нет'}</p>
                    </div>
                    <div>
                        <button class="btn btn-primary" onclick="app.selectCharacter(${c.guid}, '${c.name}')" style="margin-right:0.5rem;">Выбрать</button>
                        ${c.online ? '<span style="color:#4ade80">●</span>' : '<span style="color:#6b7280">○</span>'}
                    </div>
                </div>
            `).join('') || '<p>Персонажи не найдены</p>';
        } catch (e) {
            el.innerHTML = `<p style="color:#f87171">Ошибка: ${e.message}</p>`;
        }
    },

    async loadWorldData() {
        // Зоны
        try {
            const zones = await api.getZones();
            document.getElementById('zoneList').innerHTML = zones.zones.map(z => `
                <li>${z.name} (карта ${z.map}, координаты ${z.x}, ${z.y})</li>
            `).join('');
        } catch (e) {
            document.getElementById('zoneList').innerHTML = `<p style="color:#f87171">${e.message}</p>`;
        }

        // Подземелья
        try {
            const dungeons = await api.getDungeons();
            document.getElementById('dungeonList').innerHTML = dungeons.dungeons.map(d => `
                <li>${d.name} (уровень ${d.minLevel}-${d.maxLevel})</li>
            `).join('');
        } catch (e) {
            document.getElementById('dungeonList').innerHTML = `<p style="color:#f87171">${e.message}</p>`;
        }

        // Предметы
        try {
            const items = await api.getItems();
            document.getElementById('itemList').innerHTML = items.items.slice(0, 10).map(i => `
                <li>${i.name} (качество ${i.quality})</li>
            `).join('');
        } catch (e) {
            document.getElementById('itemList').innerHTML = `<p style="color:#f87171">${e.message}</p>`;
        }

        // Кампании
        try {
            const campaigns = await api.getCampaigns();
            document.getElementById('campaignList').innerHTML = campaigns.campaigns.map(c => `
                <div class="campaign-card">
                    <div class="campaign-info">
                        <h4>${c.name}</h4>
                        <p>Квесты: ${c.quests[0]}–${c.quests[c.quests.length-1]}</p>
                    </div>
                    <div>NPC #${c.npcId}</div>
                </div>
            `).join('');
        } catch (e) {
            document.getElementById('campaignList').innerHTML = `<p style="color:#f87171">${e.message}</p>`;
        }
    },

    currentCharacterGuid: null,

    async loadSoloData() {
        try {
            const companions = await api.getCompanions();
            document.getElementById('companionList').innerHTML = companions.companions.map(c => `
                <li>
                    <strong>${c.name}</strong> — ${c.desc}
                    <button class="btn btn-secondary" style="float:right;margin-left:0.5rem;" onclick="app.selectCompanion(${c.entry})">Выбрать</button>
                </li>
            `).join('');
        } catch (e) {
            document.getElementById('companionList').innerHTML = `<p style="color:#f87171">${e.message}</p>`;
        }

        // Статус соло-режима для текущего персонажа
        if (this.currentCharacterGuid) {
            try {
                const status = await api.getSoloStatus(this.currentCharacterGuid);
                document.getElementById('soloStatus').textContent = `Соло-режим: ${status.soloMode ? 'активен' : 'выключен'}`;
                document.getElementById('soloStatus').style.color = status.soloMode ? '#4ade80' : '#94a3b8';
                if (status.companion) {
                    document.getElementById('soloStatus').textContent += ` | Компаньон: #${status.companion}`;
                }
            } catch (e) {
                document.getElementById('soloStatus').textContent = 'Не удалось загрузить статус';
            }
        } else {
            document.getElementById('soloStatus').textContent = 'Выберите персонажа';
        }
    },

    async toggleSolo() {
        if (!this.currentCharacterGuid) {
            alert('Сначала выберите персонажа');
            return;
        }
        try {
            // Определяем текущий статус и переключаем
            const status = await api.getSoloStatus(this.currentCharacterGuid);
            const result = await api.toggleSolo(!status.soloMode, this.currentCharacterGuid);
            document.getElementById('soloStatus').textContent = `Соло-режим: ${result.soloMode ? 'активен' : 'выключен'}`;
            document.getElementById('soloStatus').style.color = result.soloMode ? '#4ade80' : '#94a3b8';
            alert(result.message);
        } catch (e) {
            alert('Ошибка: ' + e.message);
        }
    },

    selectCharacter(guid, name) {
        this.currentCharacterGuid = guid;
        document.getElementById('soloStatus').textContent = `Персонаж: ${name}`;
        this.loadSoloData();
    },

    async selectCompanion(entry) {
        if (!this.currentCharacterGuid) {
            alert('Сначала выберите персонажа');
            return;
        }
        try {
            const result = await api.companionSelect(this.currentCharacterGuid, entry);
            alert(result.message);
            this.loadSoloData();
        } catch (e) {
            alert('Ошибка: ' + e.message);
        }
    },

    refreshChars() {
        this.loadCharacters();
    }
};

// Запуск
document.addEventListener('DOMContentLoaded', () => app.init());