-- ============================================================================
-- Ночь темного Ворона — клиентский аддон (WoW 3.3.5a)
-- Кампании, соло-режим, награды. Общается с серверным модулем через .ndr
-- ============================================================================

local ADDON_NAME = "NightDarkRaven"
local PREFIX = "|cff4B0082[Ночь темного Ворона]|r "
local SERVER_PREFIX = "NDR|"

local ND = {}
_G.NightDarkRaven = ND

ND.version = "1.3.0"
ND.solo = false
ND.progress = {}   -- [campaignId] = { done = 0, total = 0 }
ND.shop = {}       -- { { entry=, name=, cost=, can= } }

-- Статический список кампаний (id, название, квесты)
ND.campaigns = {
    { id = 1,  name = "Пробуждение Ворона",     quests = { 90101, 90102, 90103 } },
    { id = 2,  name = "Тени Вороновой Горы",    quests = { 90201, 90202, 90203, 92004 } },
    { id = 3,  name = "Проклятие Перьев",       quests = { 90301, 90302, 90303 } },
    { id = 4,  name = "Кровавая Луна",          quests = { 90401, 90402, 90403, 90404 } },
    { id = 5,  name = "Хранители Ночи",         quests = { 90501, 90502, 90503 } },
    { id = 6,  name = "Забытый Храм",           quests = { 90601, 90602, 90603, 90604 } },
    { id = 7,  name = "Печать Тьмы",            quests = { 90701, 90702, 90703 } },
    { id = 8,  name = "Вороновой Клинок",       quests = { 90801, 90802, 90803, 90804 } },
    { id = 9,  name = "Ночной Дозор",           quests = { 90901, 90902, 90903 } },
    { id = 10, name = "Ворон и Луна",           quests = { 91001, 91002, 91003, 91004 } },
    { id = 11, name = "Конец Ночи",             quests = { 91101, 91102, 91103, 91104, 91105 } },
    { id = 12, name = "Повелители Теней",       quests = { 92001, 92002, 92003, 92004 } },
    { id = 13, name = "Королевство Пустоты",    quests = { 92005, 92006, 92007, 92008 } },
    { id = 14, name = "Звёздный Ворон",         quests = { 92009, 92010, 92011, 92012 } },
    { id = 15, name = "Векрной Ворон",          quests = { 92013, 92014, 92015, 92016 } },
}

-- ============================================================================
-- Утилиты
-- ============================================================================

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. msg)
end
ND.Print = Print

local function Skin(frame)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    frame:SetBackdropColor(0.08, 0.08, 0.12, 0.95)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
end

local function MakeButton(parent, text, width, height, onClick)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetWidth(width or 120)
    b:SetHeight(height or 24)
    b:SetText(text)
    b:SetScript("OnClick", onClick)
    return b
end

local function MakeCloseButton(parent, onClick)
    local b = MakeButton(parent, "Закрыть", 90, 22, onClick or function() parent:Hide() end)
    b:SetPoint("BOTTOM", parent, "BOTTOM", 0, 14)
    return b
end

-- ============================================================================
-- Главное окно
-- ============================================================================

local function CreateMainFrame()
    if ND.mainFrame then return ND.mainFrame end

    local f = CreateFrame("Frame", "NightDarkRavenMainFrame", UIParent)
    f:SetWidth(280)
    f:SetHeight(330)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
    Skin(f)
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", f, "TOP", 0, -12)
    title:SetText("|cffa78bfaНочь темного Ворона|r")

    local soloBtn = MakeButton(f, "Соло-режим: ВЫКЛ", 200, 28, function()
        SendChatMessage(".ndr solo", "SAY")
    end)
    soloBtn:SetPoint("TOP", f, "TOP", 0, -44)

    local campBtn = MakeButton(f, "Кампании", 200, 28, function()
        ND:OpenCampaigns()
    end)
    campBtn:SetPoint("TOP", soloBtn, "BOTTOM", 0, -8)

    local shopBtn = MakeButton(f, "Магазин наград", 200, 28, function()
        ND:OpenShop()
    end)
    shopBtn:SetPoint("TOP", campBtn, "BOTTOM", 0, -8)

    local kitBtn = MakeButton(f, "Забрать стартовый набор", 200, 28, function()
        SendChatMessage(".ndr kit", "SAY")
    end)
    kitBtn:SetPoint("TOP", shopBtn, "BOTTOM", 0, -8)

    local helpBtn = MakeButton(f, "Помощь", 200, 28, function()
        ND:ShowHelp()
    end)
    helpBtn:SetPoint("TOP", kitBtn, "BOTTOM", 0, -8)

    MakeCloseButton(f)

    ND.mainFrame = f
    ND.soloButton = soloBtn
    return f
end

function ND:UpdateSoloButton()
    if not self.soloButton then return end
    if self.solo then
        self.soloButton:SetText("Соло-режим: ВКЛ")
    else
        self.soloButton:SetText("Соло-режим: ВЫКЛ")
    end
end

-- ============================================================================
-- Окно кампаний
-- ============================================================================

local function CreateCampaignFrame()
    if ND.campaignFrame then return ND.campaignFrame end

    local f = CreateFrame("Frame", "NightDarkRavenCampaignFrame", UIParent)
    f:SetWidth(430)
    f:SetHeight(480)
    f:SetPoint("CENTER", UIParent, "CENTER", -230, 0)
    Skin(f)
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", f, "TOP", 0, -12)
    title:SetText("|cffa78bfaКампании|r")

    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hint:SetPoint("TOP", title, "BOTTOM", 0, -4)
    hint:SetText("Прогресс приходит с сервера при входе в мир")

    local scroll = CreateFrame("ScrollingMessageFrame", "NightDarkRavenCampaignScroll", f)
    scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -58)
    scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -14, 48)
    scroll:SetFading(false)
    scroll:SetMaxLines(500)
    scroll:SetFontObject(GameFontNormal)
    scroll:SetJustifyH("LEFT")

    MakeCloseButton(f)

    ND.campaignFrame = f
    ND.campaignScroll = scroll
    return f
end

function ND:RefreshCampaigns()
    local scroll = self.campaignScroll
    if not scroll then return end
    scroll:Clear()

    for _, camp in ipairs(self.campaigns) do
        local p = self.progress[camp.id]
        local done = p and p.done or 0
        local total = p and p.total or #camp.quests
        local color = "|cff7f7f7f"
        if done >= total and total > 0 then
            color = "|cff00ff00"
        elseif done > 0 then
            color = "|cffffd700"
        end
        scroll:AddMessage(string.format("%s[%d] %s — %d/%d|r", color, camp.id, camp.name, done, total))
    end
end

function ND:OpenCampaigns()
    CreateCampaignFrame():Show()
    self:RefreshCampaigns()
end

-- ============================================================================
-- Окно магазина
-- ============================================================================

local function CreateShopFrame()
    if ND.shopFrame then return ND.shopFrame end

    local f = CreateFrame("Frame", "NightDarkRavenShopFrame", UIParent)
    f:SetWidth(430)
    f:SetHeight(440)
    f:SetPoint("CENTER", UIParent, "CENTER", 230, 0)
    Skin(f)
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", f, "TOP", 0, -12)
    title:SetText("|cffa78bfaМагазин наград|r")

    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hint:SetPoint("TOP", title, "BOTTOM", 0, -4)
    hint:SetText("Купить можно у NPC «Торговец кампаний» (entry 90099/95016/95116)")

    local scroll = CreateFrame("ScrollingMessageFrame", "NightDarkRavenShopScroll", f)
    scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -58)
    scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -14, 48)
    scroll:SetFading(false)
    scroll:SetMaxLines(300)
    scroll:SetFontObject(GameFontNormal)
    scroll:SetJustifyH("LEFT")

    MakeCloseButton(f)

    ND.shopFrame = f
    ND.shopScroll = scroll
    return f
end

function ND:RefreshShop()
    local scroll = self.shopScroll
    if not scroll then return end
    scroll:Clear()

    if #self.shop == 0 then
        scroll:AddMessage("|cff7f7f7fДанные магазина ещё не получены. Нажмите «Обновить».|r")
        return
    end

    for _, item in ipairs(self.shop) do
        local color = item.can and "|cff00ff00" or "|cffff5555"
        scroll:AddMessage(string.format("%s%s|r — %s зол.", color, item.name, tostring(item.cost)))
    end
end

function ND:OpenShop()
    CreateShopFrame():Show()
    self:RefreshShop()
end

-- ============================================================================
-- Серверные сообщения NDR|...
-- ============================================================================

function ND:OnSystemMessage(msg)
    if not msg or string.sub(msg, 1, #SERVER_PREFIX) ~= SERVER_PREFIX then
        return false
    end

    local parts = {}
    for token in string.gmatch(msg, "[^|]+") do
        parts[#parts + 1] = token
    end

    local kind = parts[2]
    if kind == "SOLO" then
        self.solo = (parts[3] == "1")
        self:UpdateSoloButton()
    elseif kind == "CAMP" then
        local id = tonumber(parts[3])
        if id then
            self.progress[id] = { done = tonumber(parts[4]) or 0, total = tonumber(parts[5]) or 0 }
            if self.campaignFrame and self.campaignFrame:IsShown() then
                self:RefreshCampaigns()
            end
        end
    elseif kind == "SHOP" then
        self.shop[#self.shop + 1] = {
            entry = tonumber(parts[3]) or 0,
            name = parts[4] or "?",
            cost = tonumber(parts[5]) or 0,
            can = (parts[6] == "1"),
        }
        if self.shopFrame and self.shopFrame:IsShown() then
            self:RefreshShop()
        end
    elseif kind == "SHOPRESET" then
        self.shop = {}
    end

    return true
end

-- ============================================================================
-- Инициализация и команды
-- ============================================================================

function ND:Init()
    CreateMainFrame()
    CreateCampaignFrame()
    CreateShopFrame()
    self:UpdateSoloButton()
    Print("Аддон v" .. self.version .. " загружен. Команды: /ndr help")
    SendChatMessage(".ndr sync", "SAY")
end

function ND:ShowHelp()
    Print("=== Ночь темного Ворона v" .. self.version .. " ===")
    Print("/ndr — главное окно")
    Print("/ndr campaigns — кампании и прогресс")
    Print("/ndr shop — магазин наград")
    Print("/ndr solo — включить/выключить соло-режим")
    Print("/ndr kit — повторно забрать стартовый набор")
    Print("/ndr sync — запросить данные с сервера")
end

SLASH_NIGHTDARKRAVEN1 = "/ndr"
SLASH_NIGHTDARKRAVEN2 = "/nightraven"
SlashCmdList["NIGHTDARKRAVEN"] = function(msg)
    local cmd = string.lower(msg or "")

    if cmd == "" or cmd == "main" then
        local f = CreateMainFrame()
        if f:IsShown() then f:Hide() else f:Show() end
    elseif cmd == "campaigns" or cmd == "кампании" then
        ND:OpenCampaigns()
    elseif cmd == "shop" or cmd == "магазин" then
        ND:OpenShop()
    elseif cmd == "solo" or cmd == "соло" then
        SendChatMessage(".ndr solo", "SAY")
    elseif cmd == "kit" or cmd == "набор" then
        SendChatMessage(".ndr kit", "SAY")
    elseif cmd == "sync" or cmd == "обновить" then
        SendChatMessage(".ndr sync", "SAY")
    elseif cmd == "help" or cmd == "помощь" then
        ND:ShowHelp()
    else
        Print("Неизвестная команда: " .. cmd .. ". Попробуйте /ndr help")
    end
end

-- ============================================================================
-- События
-- ============================================================================

local eventFrame = CreateFrame("Frame", "NightDarkRavenEventFrame", UIParent)
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == ADDON_NAME then
            NightDarkRavenDB = NightDarkRavenDB or {}
        end
    elseif event == "PLAYER_LOGIN" then
        ND:Init()
    elseif event == "CHAT_MSG_SYSTEM" then
        ND:OnSystemMessage(arg1)
    end
end)
