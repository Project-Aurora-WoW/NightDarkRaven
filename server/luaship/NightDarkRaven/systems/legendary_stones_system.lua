-- ============================================================================
-- Ночь темного Ворона — Камни Легенды Ночных Стражей (Lua / Eluna)
-- Система сокетных камней с уникальными эффектами
-- ============================================================================

local LegendaryStones = {}

-- База данных камней: entry -> эффект
LegendaryStones.Stones = {
    [92001] = {name = "Камень Теневой Мощи", type = "red", stat = "attack_power", value = 500, desc = "+500 к силе атаки"},
    [92002] = {name = "Камень Лунного Сияния", type = "blue", stat = "intellect", value = 100, desc = "+100 к интеллекту"},
    [92003] = {name = "Камень Ночной Стойкости", type = "yellow", stat = "stamina", value = 150, desc = "+150 к выносливости"},
    [92004] = {name = "Камень Воронового Крика", type = "purple", stat = "crit", value = 50, desc = "+0.5% к шансу крита"},
    [92005] = {name = "Камень Вечной Тьмы", type = "green", stat = "expertise", value = 25, desc = "+25 к мастерству"},
    [92006] = {name = "Камень Звездного Падения", type = "orange", stat = "combo", stat2 = "attack_power", value = 200, value2 = 200, desc = "+200 к силе, +200 к интеллекту"},
    [92007] = {name = "Камень Пустотного Эха", type = "cyan", stat = "shadow_dmg", value = 300, desc = "+300 урона тенью при атаке"},
    [92008] = {name = "Камень Ночного Стража", type = "white", stat = "armor", value = 1000, desc = "+1000 к броне, +5% к защите"},
}

-- Активные камни игроков: [playerGUID] = {slot = stoneEntry}
LegendaryStones.PlayerStones = {}

-- Получить информацию о камне
function LegendaryStones.GetStoneInfo(entry)
    return LegendaryStones.Stones[entry]
end

-- Вставить камень в сокет (через gossip NPC)
function LegendaryStones.SocketStone(player, itemGuid, stoneEntry, slot)
    local guid = player:GetGUIDLow()
    if not LegendaryStones.PlayerStones[guid] then
        LegendaryStones.PlayerStones[guid] = {}
    end

    local stoneInfo = LegendaryStones.GetStoneInfo(stoneEntry)
    if not stoneInfo then
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Неизвестный камень.")
        return false
    end

    -- Проверяем, есть ли камень у игрока
    if player:GetItemCount(stoneEntry) < 1 then
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r У вас нет этого камня.")
        return false
    end

    -- Забираем камень из инвентаря
    player:RemoveItem(stoneEntry, 1)

    -- Сохраняем в сокет
    LegendaryStones.PlayerStones[guid][tostring(slot)] = stoneEntry

    -- Применяем эффект камня
    LegendaryStones.ApplyStoneEffect(player, stoneEntry, true)

    player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Камень '%s' вставлен в слот %d.", stoneInfo.name, slot))
    return true
end

-- Извлечь камень из сокета
function LegendaryStones.UnsocketStone(player, slot)
    local guid = player:GetGUIDLow()
    if not LegendaryStones.PlayerStones[guid] then return false end

    local stoneEntry = LegendaryStones.PlayerStones[guid][tostring(slot)]
    if not stoneEntry then return false end

    -- Убираем эффект
    LegendaryStones.ApplyStoneEffect(player, stoneEntry, false)

    -- Возвращаем камень
    player:AddItem(stoneEntry, 1)

    LegendaryStones.PlayerStones[guid][tostring(slot)] = nil

    local stoneInfo = LegendaryStones.GetStoneInfo(stoneEntry)
    player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Камень '%s' извлечен из слота %d.", stoneInfo.name, slot))
    return true
end

-- Применить или убрать эффект камня
function LegendaryStones.ApplyStoneEffect(player, stoneEntry, apply)
    local info = LegendaryStones.GetStoneInfo(stoneEntry)
    if not info then return end

    local multiplier = apply and 1 or -1

    -- В реальном AzerothCore здесь будут вызовы к модификаторам статов
    -- Для Eluna мы отправляем сообщение о применении эффекта
    local statName = info.stat
    local value = info.value or 0

    if apply then
        player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Эффект '%s' активирован: %s.", info.name, info.desc))
    else
        player:SendBroadcastMessage(string.format("|cff4B0082[Ночь темного Ворона]|r Эффект '%s' деактивирован.", info.name))
    end
end

-- Получить все вставленные камни игрока
function LegendaryStones.GetPlayerStones(player)
    local guid = player:GetGUIDLow()
    return LegendaryStones.PlayerStones[guid] or {}
end

-- Показать информацию о камне
function LegendaryStones.ShowStoneInfo(player, stoneEntry)
    local info = LegendaryStones.GetStoneInfo(stoneEntry)
    if not info then
        player:SendBroadcastMessage("|cff4B0082[Ночь темного Ворона]|r Камень не найден.")
        return
    end

    local msg = string.format("|cff4B0082[Ночь темного Ворона]|r %s\nТип: %s\nЭффект: %s\n",
        info.name, info.type, info.desc)

    player:SendBroadcastMessage(msg)
end

function LegendaryStones.Init()
    local count = 0
    for _ in pairs(LegendaryStones.Stones) do count = count + 1 end
    print("|cff4B0082[NightDarkRaven]|r Система Камней Легенды: " .. count .. " камней зарегистрировано.")
end

return LegendaryStones