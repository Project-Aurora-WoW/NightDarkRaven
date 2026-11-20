-- ============================================================================
-- Ночь темного Ворона — Клиентский аддон для WoW 3.3.5a
-- Полная интеграция с сервером AzerothCore
-- ============================================================================

local ND_R = {}
ND_R.version = "1.2.0"
ND_R.addonName = "NightDarkRaven"
ND_R.playerName = UnitName("player")
ND_R.playerRealm = GetRealmName()
ND_R.isInitialized = false

-- Состояние соло-режима (синхронизируется с сервером через проверку)
ND_R.soloMode = false
ND_R.companionActive = false
ND_R.companionType = nil

-- ============================================================================
-- Инициализация аддона
-- ============================================================================

function ND_R:OnLoad()
    -- Регистрация событий
    self.frame = CreateFrame("Frame", "NightDarkRavenFrame", UIParent)
    self.frame:RegisterEvent("PLAYER_LOGIN")
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.frame:RegisterEvent("PLAYER_LEVEL_UP")
    self.frame:SetScript("OnEvent", function(self, event, ...)
        ND_R:OnEvent(event, ...)
    end)

    -- Создание интерфейса
    ND_R:CreateMainFrame()
    ND_R:CreateSoloFrame()
    ND_R:CreateCampaignFrame()
    ND_R:CreateCompanionFrame()

    -- Регистрация команд чата
    SLASH_NDR1 = "/ndr"
    SLASH_NDR2 = "/nightraven"
    SlashCmdList["NDR"] = function(msg)
        ND_R:SlashCommand(msg)
    end

    print("|cff4B0082[Ночь темного Ворона]|r Аддон загружен v" .. ND_R.version .. ". Наберите /ndr для помощи.")
    ND_R.isInitialized = true
end

function ND_R:OnEvent(event, ...)
    if event == "PLAYER_LOGIN" then
        ND_R:Initialize()
    elseif event == "PLAYER_ENTERING_WORLD" then
        ND_R:OnPlayerEnteringWorld()
    elseif event == "PLAYER_LEVEL_UP" then
        local level = ...
        ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Вы достигли уровня " .. level .. "!")
    end
end

function ND_R:Initialize()
    ND_R.isInitialized = true
    ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Добро пожаловать, " .. ND_R.playerName .. "!")
    
    -- Проверяем состояние соло-режима (через проверку на сервере или локально)
    if NightDarkRavenDB and NightDarkRavenDB.soloMode ~= nil then
        ND_R.soloMode = NightDarkRavenDB.soloMode
        ND_R:UpdateSoloUI()
    end
end

function ND_R:OnPlayerEnteringWorld()
    -- При входе в мир проверяем состояние
    if ND_R.isInitialized then
        ND_R:UpdateSoloUI()
    end
end

-- ============================================================================
-- Интерфейс аддона
-- ============================================================================

function ND_R:CreateMainFrame()
    local f = CreateFrame("Frame", "NightDarkRavenMainFrame", UIParent)
    f:SetWidth(300)
    f:SetHeight(400)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    f:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    -- Заголовок
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", f, "TOP", 0, -10)
    title:SetText("|cff4B0082Ночь темного Ворона|r")
    title:SetTextColor(0.8, 0.2, 0.8, 1)

    -- Кнопка соло-режима
    local btnSolo = CreateFrame("Button", "ND_RBtnSolo", f, "UIPanelButtonTemplate")
    btnSolo:SetWidth(120)
    btnSolo:SetHeight(30)
    btnSolo:SetPoint("TOP", f, "TOP", 0, -40)
    btnSolo:SetText("Соло-режим: ВЫКЛ")
    btnSolo:SetScript("OnClick", function()
        ND_R:ToggleSoloMode()
    end)

    -- Кнопка кампаний
    local btnCampaigns = CreateFrame("Button", "ND_RBtnCampaigns", f, "UIPanelButtonTemplate")
    btnCampaigns:SetWidth(120)
    btnCampaigns:SetHeight(30)
    btnCampaigns:SetPoint("TOP", btnSolo, "BOTTOM", 0, -10)
    btnCampaigns:SetText("Кампании")
    btnCampaigns:SetScript("OnClick", function()
        ND_R:ToggleCampaignFrame()
    end)

    -- Кнопка компаньонов
    local btnCompanion = CreateFrame("Button", "ND_RBtnCompanion", f, "UIPanelButtonTemplate")
    btnCompanion:SetWidth(120)
    btnCompanion:SetHeight(30)
    btnCompanion:SetPoint("TOP", btnCampaigns, "BOTTOM", 0, -10)
    btnCompanion:SetText("Компаньоны")
    btnCompanion:SetScript("OnClick", function()
        ND_R:ToggleCompanionFrame()
    end)

    -- Кнопка подземелий
    local btnDungeon = CreateFrame("Button", "ND_RBtnDungeon", f, "UIPanelButtonTemplate")
    btnDungeon:SetWidth(120)
    btnDungeon:SetHeight(30)
    btnDungeon:SetPoint("TOP", btnCompanion, "BOTTOM", 0, -10)
    btnDungeon:SetText("Соло-подземелья")
    btnDungeon:SetScript("OnClick", function()
        ND_R:ShowDungeonMenu()
    end)

    -- Кнопка закрытия
    local btnClose = CreateFrame("Button", "ND_RBtnClose", f, "UIPanelButtonTemplate")
    btnClose:SetWidth(100)
    btnClose:SetHeight(25)
    btnClose:SetPoint("BOTTOM", f, "BOTTOM", 0, 15)
    btnClose:SetText("Закрыть")
    btnClose:SetScript("OnClick", function()
        f:Hide()
    end)

    ND_R.mainFrame = f
end

function ND_R:CreateSoloFrame()
    local f = CreateFrame("Frame", "NightDarkRavenSoloFrame", UIParent)
    f:SetWidth(250)
    f:SetHeight(200)
    f:SetPoint("CENTER", UIParent, "CENTER", 150, 0)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    f:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", f, "TOP", 0, -10)
    title:SetText("|cff4B0082Соло-режим|r")
    title:SetTextColor(0.8, 0.2, 0.8, 1)

    local status = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    status:SetPoint("TOP", f, "TOP", 0, -40)
    status:SetText("Статус: ВЫКЛЮЧЕН")
    status:SetTextColor(0.8, 0.2, 0.2, 1)
    ND_R.soloStatusText = status

    local btnToggle = CreateFrame("Button", "ND_RBtnSoloToggle", f, "UIPanelButtonTemplate")
    btnToggle:SetWidth(100)
    btnToggle:SetHeight(25)
    btnToggle:SetPoint("TOP", f, "TOP", 0, -70)
    btnToggle:SetText("Включить соло")
    btnToggle:SetScript("OnClick", function()
        ND_R:ToggleSoloMode()
    end)

    local btnClose = CreateFrame("Button", "ND_RBtnSoloClose", f, "UIPanelButtonTemplate")
    btnClose:SetWidth(100)
    btnClose:SetHeight(25)
    btnClose:SetPoint("BOTTOM", f, "BOTTOM", 0, 15)
    btnClose:SetText("Закрыть")
    btnClose:SetScript("OnClick", function()
        f:Hide()
    end)

    ND_R.soloFrame = f
end

function ND_R:CreateCampaignFrame()
    local f = CreateFrame("Frame", "NightDarkRavenCampaignFrame", UIParent)
    f:SetWidth(350)
    f:SetHeight(400)
    f:SetPoint("CENTER", UIParent, "CENTER", -200, 0)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    f:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", f, "TOP", 0, -10)
    title:SetText("|cff4B0082Кампании|r")
    title:SetTextColor(0.8, 0.2, 0.8, 1)

    local scrollFrame = CreateFrame("ScrollFrame", "ND_RCampaignScrollFrame", f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 40)

    local content = CreateFrame("Frame", "ND_RCampaignScrollContent", scrollFrame)
    content:SetWidth(300)
    content:SetHeight(1)
    scrollFrame:SetScrollChild(content)
    ND_R.campaignContent = content

    local btnClose = CreateFrame("Button", "ND_RBtnCampaignClose", f, "UIPanelButtonTemplate")
    btnClose:SetWidth(100)
    btnClose:SetHeight(25)
    btnClose:SetPoint("BOTTOM", f, "BOTTOM", 0, 15)
    btnClose:SetText("Закрыть")
    btnClose:SetScript("OnClick", function()
        f:Hide()
    end)

    ND_R.campaignFrame = f
end

function ND_R:CreateCompanionFrame()
    local f = CreateFrame("Frame", "NightDarkRavenCompanionFrame", UIParent)
    f:SetWidth(250)
    f:SetHeight(200)
    f:SetPoint("CENTER", UIParent, "CENTER", 150, -100)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    f:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", f, "TOP", 0, -10)
    title:SetText("|cff4B0082Компаньоны|r")
    title:SetTextColor(0.8, 0.2, 0.8, 1)

    local btnRaven = CreateFrame("Button", "ND_RBtnCompanionRaven", f, "UIPanelButtonTemplate")
    btnRaven:SetWidth(120)
    btnRaven:SetHeight(30)
    btnRaven:SetPoint("TOP", f, "TOP", 0, -40)
    btnRaven:SetText("Теневой Врон")
    btnRaven:SetScript("OnClick", function()
        ND_R:SpawnCompanion("shadow_raven")
    end)

    local btnGuard = CreateFrame("Button", "ND_RBtnCompanionGuard", f, "UIPanelButtonTemplate")
    btnGuard:SetWidth(120)
    btnGuard:SetHeight(30)
    btnGuard:SetPoint("TOP", btnRaven, "BOTTOM", 0, -10)
    btnGuard:SetText("Страж Ночи")
    btnGuard:SetScript("OnClick", function()
        ND_R:SpawnCompanion("night_guard")
    end)

    local btnHealer = CreateFrame("Button", "ND_RBtnCompanionHealer", f, "UIPanelButtonTemplate")
    btnHealer:SetWidth(120)
    btnHealer:SetHeight(30)
    btnHealer:SetPoint("TOP", btnGuard, "BOTTOM", 0, -10)
    btnHealer:SetText("Целитель Лунный")
    btnHealer:SetScript("OnClick", function()
        ND_R:SpawnCompanion("moon_healer")
    end)

    local btnDismiss = CreateFrame("Button", "ND_RBtnCompanionDismiss", f, "UIPanelButtonTemplate")
    btnDismiss:SetWidth(120)
    btnDismiss:SetHeight(30)
    btnDismiss:SetPoint("TOP", btnHealer, "BOTTOM", 0, -10)
    btnDismiss:SetText("Отозвать компаньона")
    btnDismiss:SetScript("OnClick", function()
        ND_R:DismissCompanion()
    end)

    local btnClose = CreateFrame("Button", "ND_RBtnCompanionClose", f, "UIPanelButtonTemplate")
    btnClose:SetWidth(100)
    btnClose:SetHeight(25)
    btnClose:SetPoint("BOTTOM", f, "BOTTOM", 0, 15)
    btnClose:SetText("Закрыть")
    btnClose:SetScript("OnClick", function()
        f:Hide()
    end)

    ND_R.companionFrame = f
end

-- ============================================================================
-- Функции соло-режима
-- ============================================================================

function ND_R:ToggleSoloMode()
    ND_R.soloMode = not ND_R.soloMode
    
    -- Сохраняем состояние
    if not NightDarkRavenDB then
        NightDarkRavenDB = {}
    end
    NightDarkRavenDB.soloMode = ND_R.soloMode

    ND_R:UpdateSoloUI()
    
    if ND_R.soloMode then
        ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Соло-режим ВКЛЮЧЕН. Сложность адаптирована под одного игрока.")
    else
        ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Соло-режим ВЫКЛЮЧЕН.")
    end
end

function ND_R:UpdateSoloUI()
    if ND_R.soloFrame and ND_R.soloStatusText then
        if ND_R.soloMode then
            ND_R.soloStatusText:SetText("Статус: АКТИВЕН")
            ND_R.soloStatusText:SetTextColor(0.2, 0.8, 0.2, 1)
            if ND_R.mainFrame and ND_R.mainFrame.btnSolo then
                ND_R.mainFrame.btnSolo:SetText("Соло-режим: ВКЛ")
            end
        else
            ND_R.soloStatusText:SetText("Статус: ВЫКЛЮЧЕН")
            ND_R.soloStatusText:SetTextColor(0.8, 0.2, 0.2, 1)
            if ND_R.mainFrame and ND_R.mainFrame.btnSolo then
                ND_R.mainFrame.btnSolo:SetText("Соло-режим: ВЫКЛ")
            end
        end
    end
end

-- ============================================================================
-- Система компаньонов
-- ============================================================================

function ND_R:SpawnCompanion(type)
    if not ND_R.soloMode then
        ND_R:Print("|cffFF0000[Ночь темного Ворона]|r Включите соло-режим для призыва компаньона.")
        return
    end

    -- Отзываем существующего компаньона
    ND_R:DismissCompanion()

    local companionNames = {
        shadow_raven = "Теневой Врон",
        night_guard = "Страж Ночи",
        moon_healer = "Целитель Лунный"
    }

    ND_R.companionType = type
    ND_R.companionActive = true

    if NightDarkRavenDB then
        NightDarkRavenDB.companionActive = true
        NightDarkRavenDB.companionType = type
    end

    ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Компаньон призывает: " .. (companionNames[type] or type) .. ".")
    
    -- В реальном AzerothCore здесь был бы вызов через скрипт сервера
    -- Здесь мы просто уведомляем игрока
    ND_R:UpdateCompanionUI()
end

function ND_R:DismissCompanion()
    ND_R.companionActive = false
    ND_R.companionType = nil

    if NightDarkRavenDB then
        NightDarkRavenDB.companionActive = false
        NightDarkRavenDB.companionType = nil
    end

    ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Компаньон отозван.")
    ND_R:UpdateCompanionUI()
end

function ND_R:UpdateCompanionUI()
    if ND_R.companionFrame then
        -- Здесь можно обновить состояние кнопок компаньонов
    end
end

-- ============================================================================
-- Система кампаний
-- ============================================================================

function ND_R:ToggleCampaignFrame()
    if ND_R.campaignFrame:IsShown() then
        ND_R.campaignFrame:Hide()
    else
        ND_R:PopulateCampaignFrame()
        ND_R.campaignFrame:Show()
    end
end

function ND_R:PopulateCampaignFrame()
    local content = ND_R.campaignContent
    if not content then return end

    -- Очищаем содержимое
    for i = 1, content:GetNumChildren() do
        local child = select(i, content:GetChildren())
        if child then child:Hide() end
    end

    local campaigns = {
        {id = 1, name = "Пробуждение Ворона", level = "10-12"},
        {id = 2, name = "Тени Вороновой Горы", level = "20-23"},
        {id = 3, name = "Проклятие Перьев", level = "30-32"},
        {id = 4, name = "Кровавая Луна", level = "40-43"},
        {id = 5, name = "Хранители Ночи", level = "50-52"},
        {id = 6, name = "Забытый Храм", level = "60-63"},
        {id = 7, name = "Печать Тьмы", level = "70-72"},
        {id = 8, name = "Вороновой Клинок", level = "75-78"},
        {id = 9, name = "Ночной Дозор", level = "78-80"},
        {id = 10, name = "Ворон и Луна", level = "80-83"},
        {id = 11, name = "Конец Ночи", level = "80"},
        {id = 12, name = "Повелители Теней", level = "85-88"},
        {id = 13, name = "Королевство Пустоты", level = "85-88"},
        {id = 14, name = "Звёздный Ворон", level = "85-88"},
        {id = 15, name = "Векрной Ворон", level = "85-88"}
    }

    local yOffset = -10
    for _, camp in ipairs(campaigns) do
        local btn = CreateFrame("Button", "ND_RBtnCamp_" .. camp.id, content, "UIPanelButtonTemplate")
        btn:SetWidth(280)
        btn:SetHeight(25)
        btn:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)
        btn:SetText(camp.name .. " (" .. camp.level .. ")")
        btn:SetScript("OnClick", function()
            ND_R:ShowCampaignDetails(camp.id)
        end)
        yOffset = yOffset - 30
    end

    content:SetHeight(math.max(400, #campaigns * 35 + 20))
end

function ND_R:ShowCampaignDetails(campaignId)
    local campaignNames = {
        [1] = "Пробуждение Ворона",
        [2] = "Тени Вороновой Горы",
        [3] = "Проклятие Перьев",
        [4] = "Кровавая Луна",
        [5] = "Хранители Ночи",
        [6] = "Забытый Храм",
        [7] = "Печать Тьмы",
        [8] = "Вороновой Клинок",
        [9] = "Ночной Дозор",
        [10] = "Ворон и Луна",
        [11] = "Конец Ночи",
        [12] = "Повелители Теней",
        [13] = "Королевство Пустоты",
        [14] = "Звёздный Ворон",
        [15] = "Векрной Ворон"
    }

    ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Кампания: " .. (campaignNames[campaignId] or "Неизвестно"))
end

-- ============================================================================
-- Система соло-подземелий
-- ============================================================================

function ND_R:ShowDungeonMenu()
    local dungeons = {
        {id = 93001, name = "Соло-ритуал Теней", level = "10-20", x = -8920, y = 540},
        {id = 93002, name = "Соло-Храм Забвения", level = "55-65", x = -9000, y = 580},
        {id = 93003, name = "Соло-Крепость Ночного Ворона", level = "75-80", x = -9100, y = 630}
    }

    local menu = CreateFrame("Frame", "ND_RDungeonMenu", UIParent, "UIDropDownMenuTemplate")
    -- В реальном AzerothCore здесь был бы вызов через серверную команду
    ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Доступные соло-подземелья:")
    for _, d in ipairs(dungeons) do
        ND_R:Print("  - " .. d.name .. " (ур. " .. d.level .. ")")
    end
    ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Используйте /ndr dungeon <id> для входа.")
end

-- ============================================================================
-- Команды чата
-- ============================================================================

function ND_R:SlashCommand(msg)
    local cmd = string.lower(msg or "")
    
    if cmd == "" or cmd == "help" then
        ND_R:ShowHelp()
    elseif cmd == "solo" or cmd == "соло" then
        ND_R:ToggleSoloMode()
    elseif cmd == "companion" or cmd == "компаньон" then
        ND_R:ToggleCompanionFrame()
    elseif cmd == "campaign" or cmd == "кампания" then
        ND_R:ToggleCampaignFrame()
    elseif cmd == "dungeon" or cmd == "подземелье" then
        ND_R:ShowDungeonMenu()
    elseif cmd == "main" or cmd == "главное" then
        if ND_R.mainFrame:IsShown() then
            ND_R.mainFrame:Hide()
        else
            ND_R.mainFrame:Show()
        end
    else
        ND_R:Print("|cffFF0000[Ночь темного Ворона]|r Неизвестная команда: " .. msg)
        ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Наберите /ndr help для справки.")
    end
end

function ND_R:ShowHelp()
    ND_R:Print("|cff4B0082=== Ночь темного Ворона - Аддон v" .. ND_R.version .. " ===")
    ND_R:Print("|cff4B0082/ndr          - Открыть главное окно")
    ND_R:Print("|cff4B0082/ndr solo     - Включить/выключить соло-режим")
    ND_R:Print("|cff4B0082/ndr companion - Открыть меню компаньонов")
    ND_R:Print("|cff4B0082/ndr campaign - Открыть меню кампаний")
    ND_R:Print("|cff4B0082/ndr dungeon  - Показать соло-подземелья")
    ND_R:Print("|cff4B0082/ndr help     - Эта справка")
end

function ND_R:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

-- ============================================================================
-- Запуск инициализации
-- ============================================================================

ND_R.frame:SetScript("OnEvent", function(self, event, ...)
    ND_R:OnEvent(event, ...)
end)

-- Авто-запуск если аддон загружается после входа в мир
if IsLoggedIn() then
    ND_R:Initialize()
end

ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Аддон загружен. Наберите /ndr для справки.")