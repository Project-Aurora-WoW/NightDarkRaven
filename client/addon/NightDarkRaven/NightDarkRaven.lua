-- ============================================================================
-- Ночь темного Ворона — Клиентский аддон для WoW 3.3.5a
-- Полная интеграция с сервером AzerothCore
-- Кампании, соло-режим, компаньоны, магазин наград
-- ============================================================================

local ND_R = {}
ND_R.version = "1.2.0"
ND_R.addonName = "NightDarkRaven"
ND_R.playerName = UnitName("player")
ND_R.playerRealm = GetRealmName()
ND_R.isInitialized = false

-- Состояние соло-режима
ND_R.soloMode = false
ND_R.companionActive = false
ND_R.companionType = nil

-- Данные кампаний
ND_R.campaigns = {}
ND_R.shopItems = {}
ND_R.isShopOpen = false

-- ============================================================================
-- Инициализация аддона
-- ============================================================================

function ND_R:OnLoad()
    self.frame = CreateFrame("Frame", "NightDarkRavenFrame", UIParent)
    self.frame:RegisterEvent("PLAYER_LOGIN")
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.frame:RegisterEvent("PLAYER_LEVEL_UP")
    self.frame:SetScript("OnEvent", function(self, event, ...)
        ND_R:OnEvent(event, ...)
    end)

    ND_R:CreateMainFrame()
    ND_R:CreateSoloFrame()
    ND_R:CreateCampaignFrame()
    ND_R:CreateShopFrame()
    ND_R:CreateCompanionFrame()

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
    ND_R:UpdateSoloUI()
end

function ND_R:OnPlayerEnteringWorld()
    if ND_R.isInitialized then
        ND_R:UpdateSoloUI()
    end
end

-- ============================================================================
-- Главное окно аддона
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

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", f, "TOP", 0, -10)
    title:SetText("|cff4B0082Ночь темного Ворона|r")

    local btnSolo = CreateFrame("Button", "ND_RBtnSolo", f, "UIPanelButtonTemplate")
    btnSolo:SetWidth(120)
    btnSolo:SetHeight(30)
    btnSolo:SetPoint("TOP", f, "TOP", 0, -40)
    btnSolo:SetText("Соло-режим: ВЫКЛ")
    btnSolo:SetScript("OnClick", function()
        ND_R:ToggleSoloMode()
    end)

    local btnCampaigns = CreateFrame("Button", "ND_RBtnCampaigns", f, "UIPanelButtonTemplate")
    btnCampaigns:SetWidth(120)
    btnCampaigns:SetHeight(30)
    btnCampaigns:SetPoint("TOP", btnSolo, "BOTTOM", 0, -10)
    btnCampaigns:SetText("Кампании")
    btnCampaigns:SetScript("OnClick", function()
        ND_R:ToggleCampaignFrame()
    end)

    local btnShop = CreateFrame("Button", "ND_RBtnShop", f, "UIPanelButtonTemplate")
    btnShop:SetWidth(120)
    btnShop:SetHeight(30)
    btnShop:SetPoint("TOP", btnCampaigns, "BOTTOM", 0, -10)
    btnShop:SetText("Магазин наград")
    btnShop:SetScript("OnClick", function()
        ND_R:ToggleShopFrame()
    end)

    local btnCompanion = CreateFrame("Button", "ND_RBtnCompanion", f, "UIPanelButtonTemplate")
    btnCompanion:SetWidth(120)
    btnCompanion:SetHeight(30)
    btnCompanion:SetPoint("TOP", btnShop, "BOTTOM", 0, -10)
    btnCompanion:SetText("Компаньоны")
    btnCompanion:SetScript("OnClick", function()
        ND_R:ToggleCompanionFrame()
    end)

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

-- ============================================================================
-- Окно кампаний с прогрессом
-- ============================================================================

function ND_R:CreateCampaignFrame()
    local f = CreateFrame("Frame", "NightDarkRavenCampaignFrame", UIParent)
    f:SetWidth(400)
    f:SetHeight(500)
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

    -- Список кампаний
    local scrollFrame = CreateFrame("ScrollFrame", "ND_RCampaignScrollFrame", f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 50)

    local content = CreateFrame("Frame", "ND_RCampaignScrollContent", scrollFrame)
    content:SetWidth(340)
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

function ND_R:PopulateCampaignFrame()
    local content = ND_R.campaignContent
    if not content then return end

    for i = 1, content:GetNumChildren() do
        local child = select(i, content:GetChildren())
        if child then child:Hide() end
    end

    local yOffset = -10
    for _, camp in ipairs(ND_R.campaigns) do
        local frame = CreateFrame("Frame", "ND_RCamp_" .. camp.campaignId, content)
        frame:SetWidth(320)
        frame:SetHeight(60)
        frame:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)
        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        frame:SetBackdropColor(0.2, 0.2, 0.3, 0.8)

        local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameText:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -8)
        nameText:SetText("|cffa78bfa" .. camp.campaignName .. "|r")
        nameText:SetTextColor(0.8, 0.2, 0.8, 1)

        local progressText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        progressText:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -20)
        progressText:SetText(string.format("Прогресс: %d/%d квестов", camp.completedQuests, camp.totalQuests))

        local btnEnter = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        btnEnter:SetWidth(80)
        btnEnter:SetHeight(20)
        btnPoint = "BOTTOMRIGHT"
        btnEnter:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 5)
        btnEnter:SetText("Подробнее")
        btnEnter:SetScript("OnClick", function()
            ND_R:ShowCampaignDetails(camp.campaignId)
        end)

        yOffset = yOffset - 70
    end

    content:SetHeight(math.max(400, #ND_R.campaigns * 75 + 20))
end

function ND_R:ShowCampaignDetails(campaignId)
    local camp = nil
    for _, c in ipairs(ND_R.campaigns) do
        if c.campaignId == campaignId then
            camp = c
            break
        end
    end

    if not camp then return end

    local msg = "|cff4B0082[Ночь темного Ворона]|r Кампания: " .. camp.campaignName .. "\n"
    for _, q in ipairs(camp.quests) do
        local status = q.status == 2 and "|cff00ff00[Завершено]|r" or q.status == 1 and "|cffffd700[В прогрессе]|r" or "|cff7f7f7f[Не начат]|r"
        msg = msg .. "\n  " .. q.questName .. ": " .. status
    end
    ND_R:Print(msg)
end

-- ============================================================================
-- Окно магазина наград
-- ============================================================================

function ND_R:CreateShopFrame()
    local f = CreateFrame("Frame", "NightDarkRavenShopFrame", UIParent)
    f:SetWidth(450)
    f:SetHeight(550)
    f:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
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
    title:SetText("|cff4B0082Магазин наград|r")

    local scrollFrame = CreateFrame("ScrollFrame", "ND_RShopScrollFrame", f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 50)

    local content = CreateFrame("Frame", "ND_RShopScrollContent", scrollFrame)
    content:SetWidth(400)
    content:SetHeight(1)
    scrollFrame:SetScrollChild(content)
    ND_R.shopContent = content

    local btnClose = CreateFrame("Button", "ND_RBtnShopClose", f, "UIPanelButtonTemplate")
    btnClose:SetWidth(100)
    btnClose:SetHeight(25)
    btnClose:SetPoint("BOTTOM", f, "BOTTOM", 0, 15)
    btnClose:SetText("Закрыть")
    btnClose:SetScript("OnClick", function()
        f:Hide()
    end)

    ND_R.shopFrame = f
end

function ND_R:PopulateShopFrame()
    local content = ND_R.shopContent
    if not content then return end

    for i = 1, content:GetNumChildren() do
        local child = select(i, content:GetChildren())
        if child then child:Hide() end
    end

    local yOffset = -10
    for _, item in ipairs(ND_R.shopItems) do
        local frame = CreateFrame("Frame", "ND_RShopItem_" .. item.itemId, content)
        frame:SetWidth(380)
        frame:SetHeight(70)
        frame:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)
        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        frame:SetBackdropColor(0.2, 0.2, 0.3, 0.8)

        local itemName = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        itemName:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -8)
        itemName:SetText(item.itemName)
        itemName:SetTextColor(1, 0.8, 0, 1)

        local itemDesc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        itemDesc:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -22)
        itemDesc:SetText(item.itemDesc)
        itemDesc:SetTextColor(0.8, 0.8, 0.8, 1)

        local costText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        costText:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -36)
        local costStr = ""
        if item.costGold > 0 then
            costStr = costStr .. item.costGold .. " зол."
        end
        if item.costTokens > 0 then
            costStr = costStr .. item.costTokens .. " токенов"
        end
        costText:SetText("Стоимость: " .. costStr)
        costText:SetTextColor(1, 1, 0, 1)

        local btnBuy = CreateFrame("Button", "ND_RBtnBuy_" .. item.itemId, frame, "UIPanelButtonTemplate")
        btnBuy:SetWidth(80)
        btnBuy:SetHeight(22)
        btnBuy:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 5)
        btnBuy:SetText(item.canBuy and "Купить" or "Заблокировано")
        btnBuy:SetScript("OnClick", function()
            if item.canBuy then
                ND_R:BuyItem(item.itemId)
            else
                ND_R:Print("|cffFF0000[Ночь темного Ворона]|r " .. item.reason)
            end
        end)

        if not item.canBuy then
            btnBuy:SetEnabled(false)
        end

        yOffset = yOffset - 75
    end

    content:SetHeight(math.max(400, #ND_R.shopItems * 80 + 20))
end

-- ============================================================================
-- Окно компаньонов
-- ============================================================================

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
-- Соло-режим
-- ============================================================================

function ND_R:ToggleSoloMode()
    ND_R.soloMode = not ND_R.soloMode
    ND_R:UpdateSoloUI()
    
    if ND_R.soloMode then
        ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Соло-режим ВКЛЮЧЕН.")
    else
        ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Соло-режим ВЫКЛЮЧЕН.")
    end
end

function ND_R:UpdateSoloUI()
    if ND_R.mainFrame and ND_R.mainFrame.btnSolo then
        if ND_R.soloMode then
            ND_R.mainFrame.btnSolo:SetText("Соло-режим: ВКЛ")
        else
            ND_R.mainFrame.btnSolo:SetText("Соло-режим: ВЫКЛ")
        end
    end
end

-- ============================================================================
-- Компаньоны
-- ============================================================================

function ND_R:SpawnCompanion(type)
    if not ND_R.soloMode then
        ND_R:Print("|cffFF0000[Ночь темного Ворона]|r Включите соло-режим для призыва компаньона.")
        return
    end

    ND_R.companionActive = true
    ND_R.companionType = type

    local companionNames = {
        shadow_raven = "Теневой Врон",
        night_guard = "Страж Ночи",
        moon_healer = "Целитель Лунный"
    }

    ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Компаньон призывает: " .. (companionNames[type] or type) .. ".")
end

function ND_R:DismissCompanion()
    ND_R.companionActive = false
    ND_R.companionType = nil
    ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Компаньон отозван.")
end

-- ============================================================================
-- Магазин
-- ============================================================================

function ND_R:ToggleShopFrame()
    if ND_R.shopFrame:IsShown() then
        ND_R.shopFrame:Hide()
    else
        ND_R:RequestShopData()
        ND_R.shopFrame:Show()
    end
end

function ND_R:RequestShopData()
    -- Запрашиваем данные магазина через gossip NPC
    -- В реальном AzerothCore здесь был бы вызов через сервер
    -- Здесь мы эмулируем загрузку данных
    ND_R.shopItems = ND_R:GetMockShopData()
    ND_R:PopulateShopFrame()
end

function ND_R:GetMockShopData()
    -- Это временные данные, в реальности они приходят с сервера
    return {
        { itemId = 1, itemEntry = 90001, itemName = "Перо Тени", itemDesc = "Квестовая награда кампании 1", campaignReq = 1, questReq = 90101, costType = "gold", costGold = 500000, costTokens = 0, maxPurchases = 1, canBuy = true },
        { itemId = 2, itemEntry = 90021, itemName = "Шкура Горного Волка", itemDesc = "Квестовая награда кампании 2", campaignReq = 2, questReq = 90201, costType = "gold", costGold = 2000000, costTokens = 0, maxPurchases = 1, canBuy = false },
        { itemId = 3, itemEntry = 90111, itemName = "Сердце Темного Ворона", itemDesc = "Квестовая награда кампании 11", campaignReq = 11, questReq = 91103, costType = "gold", costGold = 20000000, costTokens = 0, maxPurchases = 1, canBuy = false },
    }
end

function ND_R:BuyItem(itemId)
    -- В реальном AzerothCore здесь был бы вызов gossip NPC для покупки
    -- Здесь мы эмулируем покупку
    local item = nil
    for _, it in ipairs(ND_R.shopItems) do
        if it.itemId == itemId then
            item = it
            break
        end
    end

    if item then
        if item.canBuy then
            ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Предмет '" .. item.itemName .. "' приобретён!")
            item.canBuy = false
            ND_R:PopulateShopFrame()
        else
            ND_R:Print("|cffFF0000[Ночь темного Ворона]|r " .. item.reason)
        end
    end
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
    elseif cmd == "shop" or cmd == "магазин" then
        ND_R:ToggleShopFrame()
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
    ND_R:Print("|cff4B0082/ndr shop     - Открыть магазин наград")
    ND_R:Print("|cff4B0082/ndr dungeon  - Показать соло-подземелья")
    ND_R:Print("|cff4B0082/ndr help     - Эта справка")
end

function ND_R:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

-- Запуск инициализации
ND_R.frame:SetScript("OnEvent", function(self, event, ...)
    ND_R:OnEvent(event, ...)
end)

if IsLoggedIn() then
    ND_R:Initialize()
end

ND_R:Print("|cff4B0082[Ночь темного Ворона]|r Аддон загружен. Наберите /ndr для справки.")