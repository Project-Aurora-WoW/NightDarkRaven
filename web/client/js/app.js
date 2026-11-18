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
        if (section === 'admin') {
            this.loadAdminStats();
            this.loadAdminSolo();
            this.loadAdminLogs();
        }
        if (section === 'campaigns-admin') {
            this.loadCampaigns();
        }
        if (section === 'sqlimport') {
            this.sqlImportStatus();
        }
        if (section === 'clientpatches') {
            this.loadClientPatches();
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
    },

    // Админ-панель
    async loadAdminStats() {
        try {
            const stats = await api.adminGetStats();
            document.getElementById('adminStats').innerHTML = `
                <div style="display:grid; grid-template-columns: repeat(3, 1fr); gap:1rem;">
                    <div style="background:var(--border); padding:1rem; border-radius:6px;">
                        <div style="color:var(--text-muted); font-size:0.8rem;">Онлайн персонажей</div>
                        <div style="color:var(--accent-glow); font-size:1.5rem;">${stats.onlineCharacters}</div>
                    </div>
                    <div style="background:var(--border); padding:1rem; border-radius:6px;">
                        <div style="color:var(--text-muted); font-size:0.8rem;">Всего персонажей</div>
                        <div style="color:var(--text); font-size:1.5rem;">${stats.totalCharacters}</div>
                    </div>
                    <div style="background:var(--border); padding:1rem; border-radius:6px;">
                        <div style="color:var(--text-muted); font-size:0.8rem;">Активных соло-режимов</div>
                        <div style="color:#4ade80; font-size:1.5rem;">${stats.soloActive}</div>
                    </div>
                </div>
            `;
        } catch (e) {
            document.getElementById('adminStats').innerHTML = `<p style="color:#f87171">${e.message}</p>`;
        }
    },

    async loadAdminSolo() {
        const el = document.getElementById('adminSoloList');
        el.innerHTML = 'Загрузка...';
        try {
            const result = await api.adminGetSoloPlayers();
            const players = result.soloPlayers || [];
            el.innerHTML = players.map(p => `
                <div class="char-card" style="padding:0.75rem;">
                    <div style="flex:1;">
                        <strong>${p.character_name || 'Неизвестно'}</strong> (GUID: ${p.character_guid})
                        <br><small style="color:var(--text-muted);">Уровень ${p.level} · Зона ${p.zone} · Аккаунт ${p.account_id}</small>
                    </div>
                    <div style="text-align:right;">
                        <span style="color:${p.solo_mode ? '#4ade80' : '#f87171'}; font-weight:bold;">
                            ${p.solo_mode ? 'СОЛО' : 'Группа'}
                        </span>
                    </div>
                </div>
            `).join('') || '<p>Нет данных о соло-состояниях</p>';
        } catch (e) {
            el.innerHTML = `<p style="color:#f87171">${e.message}</p>`;
        }
    },

    async adminToggleSolo() {
        const guid = document.getElementById('adminCharGuid').value;
        const enable = document.getElementById('adminSoloToggle').checked;
        const msgEl = document.getElementById('adminActionMessage');

        if (!guid) {
            msgEl.textContent = 'Укажите GUID персонажа';
            msgEl.style.color = '#f87171';
            return;
        }

        try {
            const result = await api.adminToggleSolo(parseInt(guid), enable);
            msgEl.textContent = result.message;
            msgEl.style.color = '#4ade80';
            this.loadAdminSolo();
        } catch (e) {
            msgEl.textContent = 'Ошибка: ' + e.message;
            msgEl.style.color = '#f87171';
        }
    },

    async adminRestart() {
        if (!confirm('Перезапустить WorldServer?')) return;
        try {
            const result = await api.adminRestart();
            document.getElementById('adminActionMessage').textContent = result.message;
            document.getElementById('adminActionMessage').style.color = '#4ade80';
            alert('Рестарт WorldServer инициирован. Подождите несколько секунд.');
        } catch (e) {
            alert('Ошибка: ' + e.message);
        }
    },

    async loadAdminLogs() {
        const el = document.getElementById('adminLogs');
        el.innerHTML = 'Загрузка...';
        try {
            const result = await api.adminGetLogs();
            const logs = result.logs || [];
            el.innerHTML = logs.map(l => {
                const date = new Date(l.changed_at).toLocaleString('ru-RU');
                return `<div style="padding:0.4rem 0; border-bottom:1px solid var(--border);">
                    <strong style="color:${l.solo_mode ? '#4ade80' : '#f87171'}">${l.solo_mode ? 'ВКЛ' : 'ВЫКЛ'} соло</strong>
                    · GUID ${l.character_guid} · ${l.changed_by} · ${date}
                </div>`;
            }).join('') || '<p>Логи пусты</p>';
        } catch (e) {
            el.innerHTML = `<p style="color:#f87171">${e.message}</p>`;
        }
    },

    // Управление кампаниями
    async loadCampaigns() {
        const el = document.getElementById('campaignsList');
        el.innerHTML = 'Загрузка кампаний...';
        try {
            const result = await api.getCampaigns();
            const campaigns = result.campaigns || [];
            el.innerHTML = campaigns.map(c => `
                <div class="campaign-card" style="padding:0.75rem; margin-bottom:0.5rem;">
                    <div style="flex:1;">
                        <strong style="color:var(--accent-glow)">Кампания ${c.id}: ${c.name}</strong>
                        <br><small style="color:var(--text-muted);">NPC дачитель: #${c.npcId}</small>
                    </div>
                    <div style="text-align:right; font-size:0.85rem;">
                        ${c.quests.length} квестов
                    </div>
                    <div style="margin-top:0.5rem;">
                        ${c.quests.map(q => `
                            <div style="display:flex; justify-content:space-between; align-items:center; padding:0.3rem 0; border-bottom:1px solid var(--border); font-size:0.9rem;">
                                <span>#${q.entry} ${q.title}</span>
                                <span style="color:${q.flags & 0x0001 ? '#4ade80' : '#94a3b8'}">
                                    ${q.flags & 0x0001 ? 'АКТИВЕН' : 'выключен'}
                                </span>
                                <span style="color:var(--text-muted);">ур. ${q.level}</span>
                            </div>
                        `).join('')}
                    </div>
                </div>
            `).join('') || '<p>Кампании не найдены</p>';
        } catch (e) {
            el.innerHTML = `<p style="color:#f87171">${e.message}</p>`;
        }
    },

    async adminToggleQuest() {
        const questId = document.getElementById('adminQuestId').value;
        const enable = document.getElementById('adminQuestEnabled').checked;
        const msgEl = document.getElementById('adminQuestMessage');

        if (!questId) {
            msgEl.textContent = 'Укажите ID квеста';
            msgEl.style.color = '#f87171';
            return;
        }

        try {
            const result = await api.toggleCampaignQuest(parseInt(questId), enable);
            msgEl.textContent = result.message;
            msgEl.style.color = '#4ade80';
            this.loadCampaigns();
        } catch (e) {
            msgEl.textContent = 'Ошибка: ' + e.message;
            msgEl.style.color = '#f87171';
        }
    },

    // SQL Импорт
    async sqlImportStatus() {
        const statusEl = document.getElementById('sqlImportStatus');
        const logEl = document.getElementById('sqlImportLog');
        statusEl.innerHTML = 'Загрузка...';
        logEl.innerHTML = 'Загрузка...';
        try {
            const result = await api.sqlImportStatus();
            statusEl.innerHTML = `
                <div style="display:grid; grid-template-columns: repeat(3, 1fr); gap:1rem; margin-bottom:1rem;">
                    <div style="background:var(--border); padding:1rem; border-radius:6px;">
                        <div style="color:var(--text-muted); font-size:0.8rem;">Всего файлов</div>
                        <div style="color:var(--accent-glow); font-size:1.5rem;">${result.total}</div>
                    </div>
                    <div style="background:var(--border); padding:1rem; border-radius:6px;">
                        <div style="color:var(--text-muted); font-size:0.8rem;">Импортировано</div>
                        <div style="color:#4ade80; font-size:1.5rem;">${result.imported}</div>
                    </div>
                    <div style="background:var(--border); padding:1rem; border-radius:6px;">
                        <div style="color:var(--text-muted); font-size:0.8rem;">Ожидают импорта</div>
                        <div style="color:#f59e0b; font-size:1.5rem;">${result.pending}</div>
                    </div>
                </div>
            `;

            const files = result.status || [];
            logEl.innerHTML = files.map(f => `
                <div style="padding:0.4rem 0; border-bottom:1px solid var(--border); font-size:0.85rem;">
                    <span style="color:${f.imported ? '#4ade80' : '#f87171'}">${f.imported ? '✓' : '○'}</span>
                    ${f.filename}
                </div>
            `).join('') || '<p>Нет SQL файлов</p>';
        } catch (e) {
            statusEl.innerHTML = `<p style="color:#f87171">${e.message}</p>`;
            logEl.innerHTML = `<p style="color:#f87171">${e.message}</p>`;
        }
    },

    async sqlImportAll() {
        try {
            const result = await api.sqlImportAll();
            document.getElementById('sqlFileMessage').textContent = result.message;
            document.getElementById('sqlFileMessage').style.color = '#4ade80';
            this.sqlImportStatus();
        } catch (e) {
            document.getElementById('sqlFileMessage').textContent = 'Ошибка: ' + e.message;
            document.getElementById('sqlFileMessage').style.color = '#f87171';
        }
    },

    async sqlImportNew() {
        try {
            const result = await api.sqlImportNew();
            document.getElementById('sqlFileMessage').textContent = result.message;
            document.getElementById('sqlFileMessage').style.color = '#4ade80';
            this.sqlImportStatus();
        } catch (e) {
            document.getElementById('sqlFileMessage').textContent = 'Ошибка: ' + e.message;
            document.getElementById('sqlFileMessage').style.color = '#f87171';
        }
    },

    async sqlImportFile() {
        const filename = document.getElementById('sqlFileName').value.trim();
        const msgEl = document.getElementById('sqlFileMessage');

        if (!filename) {
            msgEl.textContent = 'Укажите имя файла';
            msgEl.style.color = '#f87171';
            return;
        }

        try {
            const result = await api.sqlImportFile(filename);
            msgEl.textContent = result.message;
            msgEl.style.color = '#4ade80';
            this.sqlImportStatus();
        } catch (e) {
            msgEl.textContent = 'Ошибка: ' + e.message;
            msgEl.style.color = '#f87171';
        }
    },

    // Патчи клиента
    async loadClientPatches() {
        const listEl = document.getElementById('clientPatchesList');
        const logEl = document.getElementById('clientPatchesLog');
        listEl.innerHTML = 'Загрузка...';
        logEl.innerHTML = 'Загрузка...';
        try {
            const result = await api.clientPatchesList();
            const patches = result.patches || [];
            listEl.innerHTML = patches.map(p => `
                <div class="campaign-card" style="padding:0.75rem; margin-bottom:0.5rem;">
                    <div style="flex:1;">
                        <strong style="color:var(--accent-glow)">${p.patch_name}</strong>
                        <br><small style="color:var(--text-muted);">Тип: ${p.patch_type} · Файл: ${p.target_file} · Версия: ${p.version_from || 'any'}-${p.version_to || 'any'}</small>
                    </div>
                    <div style="text-align:right;">
                        <span style="color:${p.is_applied ? '#4ade80' : '#f59e0b'}; font-weight:bold;">
                            ${p.is_applied ? 'Применён' : 'Ожидает'}
                        </span>
                        <br><button class="btn btn-secondary" style="padding:0.3rem 0.6rem; font-size:0.8rem;" onclick="app.applyClientPatch(${p.patch_id})">
                            ${p.is_applied ? 'Уже применён' : 'Применить'}
                        </button>
                    </div>
                </div>
            `).join('') || '<p>Патчи не найдены</p>';

            // Загружаем лог
            const logResult = await api.clientPatchesLog();
            const log = logResult.log || [];
            logEl.innerHTML = log.map(l => `
                <div style="padding:0.4rem 0; border-bottom:1px solid var(--border); font-size:0.85rem;">
                    <span style="color:${l.status === 'success' ? '#4ade80' : '#f87171'}">${l.status}</span>
                    · ${l.patch_name || 'Нет патча'} · ${l.message} · ${new Date(l.applied_at).toLocaleString('ru-RU')}
                </div>
            `).join('') || '<p>История пуста</p>';
        } catch (e) {
            listEl.innerHTML = `<p style="color:#f87171">${e.message}</p>`;
            logEl.innerHTML = `<p style="color:#f87171">${e.message}</p>`;
        }
    },

    async applyClientPatch(patchId) {
        try {
            const result = await api.clientPatchesApply(patchId);
            document.getElementById('cpMessage').textContent = result.message;
            document.getElementById('cpMessage').style.color = '#4ade80';
            this.loadClientPatches();
        } catch (e) {
            document.getElementById('cpMessage').textContent = 'Ошибка: ' + e.message;
            document.getElementById('cpMessage').style.color = '#f87171';
        }
    },

    async clientPatchesCreate() {
        const name = document.getElementById('cpName').value.trim();
        const type = document.getElementById('cpType').value.trim();
        const targetFile = document.getElementById('cpTargetFile').value.trim();
        const content = document.getElementById('cpContent').value.trim();
        const msgEl = document.getElementById('cpMessage');

        if (!name || !type || !targetFile || !content) {
            msgEl.textContent = 'Заполните все поля';
            msgEl.style.color = '#f87171';
            return;
        }

        try {
            const result = await api.clientPatchesCreate({
                patch_name: name,
                patch_type: type,
                target_file: targetFile,
                target_path: null,
                content: content,
                version_from: '3.3.5a',
                version_to: '3.3.5a',
                is_required: true
            });
            msgEl.textContent = result.message;
            msgEl.style.color = '#4ade80';
            this.loadClientPatches();
        } catch (e) {
            msgEl.textContent = 'Ошибка: ' + e.message;
            msgEl.style.color = '#f87171';
        }
    }
};

// Запуск
document.addEventListener('DOMContentLoaded', () => app.init());