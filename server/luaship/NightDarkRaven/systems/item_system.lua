-- ============================================================================
-- Ночь темного Ворона — Система предметов
-- Регистрация квестовых предметов, наград, лута
-- ============================================================================

local ItemSystem = {}

-- База данных предметов модуля
-- entry, name, quality, sellPrice, bonding, description
ItemSystem.Items = {
    -- Кампания 1: Пробуждение Ворона
    [90001] = {name = "Перо Тени", quality = 2, sellPrice = 10, bonding = 1, desc = "Перо Теневой Совы. Необходимо для кампании 1."},
    [90003] = {name = "Клык Теневой Совы", quality = 1, sellPrice = 5, bonding = 1, desc = "Острый клык тени."},
    [90004] = {name = "Светящийся камешек", quality = 1, sellPrice = 2, bonding = 1, desc = "Маленький магический камешек."},

    -- Кампания 2: Тени Вороновой Горы
    [90021] = {name = "Шкура Горного Волка", quality = 2, sellPrice = 20, bonding = 1, desc = "Густая шкура горного волка."},
    [90022] = {name = "Камень Гряд", quality = 2, sellPrice = 15, bonding = 1, desc = "Камень из завалов Вороновой Горы."},
    [90023] = {name = "Перо Каменного Гаргулья", quality = 3, sellPrice = 50, bonding = 1, desc = "Редкое перо гаргулья."},

    -- Кампания 3: Проклятие Перьев
    [90031] = {name = "Проклятое Перо", quality = 3, sellPrice = 75, bonding = 1, desc = "Перо, проклятое Теневым Оборотнем."},
    [90032] = {name = "Амулет Друида", quality = 3, sellPrice = 100, bonding = 1, desc = "Амулет, отражающий проклятия."},
    [90033] = {name = "Слеза Леса", quality = 2, sellPrice = 40, bonding = 1, desc = "Чистая слеза магического леса."},

    -- Кампания 4: Кровавая Луна
    [90041] = {name = "Кровавый Клык", quality = 3, sellPrice = 120, bonding = 1, desc = "Клык Кровавого Волка."},
    [90042] = {name = "Песнь Луны", quality = 3, sellPrice = 150, bonding = 1, desc = "Запись древней песни Луны."},
    [90043] = {name = "Кристалл Кровавой Луны", quality = 4, sellPrice = 500, bonding = 1, desc = "Редкий кристалл, светящийся кроваво-красным."},

    -- Кампания 5: Хранители Ночи
    [90051] = {name = "Печать Хранителя", quality = 4, sellPrice = 300, bonding = 1, desc = "Печать Верховного Хранителя Ночи."},
    [90052] = {name = "Масло Теней", quality = 3, sellPrice = 90, bonding = 1, desc = "Масло, используемое хранителями."},
    [90053] = {name = "Медальон Ночи", quality = 3, sellPrice = 110, bonding = 1, desc = "Медальон ночного дозора."},

    -- Кампания 6: Забытый Храм
    [90061] = {name = "Разрушенные Скрижали", quality = 3, sellPrice = 130, bonding = 1, desc = "Фрагмент древней скрижали храма."},
    [90062] = {name = "Пыль Костей", quality = 2, sellPrice = 50, bonding = 1, desc = "Пыль скелетного жреца."},
    [90063] = {name = "Ключ Храма", quality = 4, sellPrice = 400, bonding = 1, desc = "Старинный ключ от Забытого Храма."},

    -- Кампания 7: Печать Тьмы
    [90071] = {name = "Осколок Пустоты", quality = 4, sellPrice = 350, bonding = 1, desc = "Осколок из Печати Тьмы."},
    [90072] = {name = "Кровь Демона", quality = 3, sellPrice = 100, bonding = 1, desc = "Темная кровь демона тени."},
    [90073] = {name = "Руна Печати", quality = 3, sellPrice = 120, bonding = 1, desc = "Древняя руна запечатывания."},

    -- Кампания 8: Вороновой Клинок
    [90081] = {name = "Клинок Ворона", quality = 4, sellPrice = 1000, bonding = 1, desc = "Легендарный клинок, кованый тенями."},
    [90082] = {name = "Искра Огня", quality = 3, sellPrice = 80, bonding = 1, desc = "Искра от огненного элементаля."},
    [90083] = {name = "Чешуя Теневого Ворона", quality = 4, sellPrice = 600, bonding = 1, desc = "Редкая чешуя Тени Ворона."},

    -- Кампания 9: Ночной Дозор
    [90091] = {name = "Знак Дозора", quality = 4, sellPrice = 700, bonding = 1, desc = "Знак капитана Ночного Дозора."},
    [90092] = {name = "Свисток Разведчика", quality = 3, sellPrice = 60, bonding = 1, desc = "Свисток теневого разведчика."},
    [90093] = {name = "Когти Ночного Хищника", quality = 3, sellPrice = 90, bonding = 1, desc = "Острые когти хищника ночи."},

    -- Кампания 10: Ворон и Луна
    [90101] = {name = "Слёза Луны", quality = 4, sellPrice = 800, bonding = 1, desc = "Чистая слеза Оракула Луны."},
    [90102] = {name = "Клык Луноstalker", quality = 3, sellPrice = 110, bonding = 1, desc = "Клык лунного хищника."},
    [90103] = {name = "Перо Аспекта Ворона", quality = 5, sellPrice = 1500, bonding = 1, desc = "Легендарное перо Аспекта Ворона."},

    -- Кампания 11: Конец Ночи (финале)
    [90111] = {name = "Сердце Темного Ворона", quality = 5, sellPrice = 5000, bonding = 1, desc = "Сердце финального босса."},
    [90112] = {name = "Крыло Ночи", quality = 5, sellPrice = 4000, bonding = 1, desc = "Крыло Ночного Стража."},
    [90113] = {name = "Плащ Ночного Ворона", quality = 5, sellPrice = 3000, bonding = 1, desc = "Легендарный плащ kampanii 11."},
}

-- Новые предметы (дополнительное оснащение)
ItemSystem.NewItems = {
    [91001] = {name = "Кольцо Ночного Ворона", quality = 4, sellPrice = 2000, bonding = 1, desc = "Кольцо из тени Ворона."},
    [91002] = {name = "Ожерелье Темного Ворона", quality = 4, sellPrice = 2000, bonding = 1, desc = "Ожерелье Ночного Ворона."},
    [91003] = {name = "Перстень Хранителя Ночи", quality = 3, sellPrice = 1200, bonding = 1, desc = "Перстень хранителей."},
    [91004] = {name = "Поножи Ночного Ворона", quality = 4, sellPrice = 3000, bonding = 1, desc = "Поножи из тени."},
    [91005] = {name = "Наручи Ворона", quality = 3, sellPrice = 1500, bonding = 1, desc = "Наручи Ночного Ворона."},
}

function ItemSystem.GetItemInfo(entry)
    local info = ItemSystem.Items[entry] or ItemSystem.NewItems[entry]
    return info
end

function ItemSystem.Init()
    print("|cff4B0082[NightDarkRaven]|r Система предметов: " .. (table.getn(ItemSystem.Items) + table.getn(ItemSystem.NewItems)) .. " предметов зарегистрировано.")
end

return ItemSystem