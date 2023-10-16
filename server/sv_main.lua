ESX = exports["es_extended"]:getSharedObject()
local redeemKeys = {}

-- Befehl zum Generieren des Geld-Codes
RegisterCommand("generate_money_key", function(source, args, rawCommand)
    -- Überprüfen, ob der Spieler die erforderlichen Rechte hat (z.B. ist er ein Admin?)
    if source == 0 then
        local amount = tonumber(args[1])
        if amount then
            local code = tostring(math.random(100000, 999999))
            redeemKeys[code] = {type = "money", value = amount}
            print("Geld-Code generiert: " .. code .. " für $" .. amount)
        else
            print("Ungültiger Betrag!")
        end
    else
        print("Du hast nicht die erforderlichen Rechte, um diesen Befehl auszuführen!")
    end
end, false)

-- Befehl zum Generieren des Waffen-Codes
RegisterCommand("generate_weapon_key", function(source, args, rawCommand)
    if source == 0 then
        local weaponName = args[1]
        if weaponName then
            local code = tostring(math.random(100000, 999999))
            redeemKeys[code] = {type = "weapon", value = weaponName}
            print("Waffen-Code generiert: " .. code .. " für " .. weaponName)
        else
            print("Ungültiger Waffenname!")
        end
    else
        print("Du hast nicht die erforderlichen Rechte, um diesen Befehl auszuführen!")
    end
end, false)




RegisterCommand("generate_item_key", function(source, args, rawCommand)
    if source == 0 then
        local itemName = args[1]
        local itemCount = tonumber(args[2])
        
        if itemName and itemCount then
            local code = tostring(math.random(100000, 999999))
            redeemKeys[code] = {type = "item", value = itemName, count = itemCount}
            print("Item-Code generiert: " .. code .. " für " .. itemCount .. "x " .. itemName)
        else
            print("Ungültige Eingabe für Item-Namen oder Anzahl!")
        end
    else
        print("Du hast nicht die erforderlichen Rechte, um diesen Befehl auszuführen!")
    end
end, false)



RegisterCommand("generate_car_key", function(source, args, rawCommand)
    if source == 0 then
        local carName = args[1]
        
        if carName then
            local code = tostring(math.random(100000, 999999))
            redeemKeys[code] = {type = "car", value = carName}
            print("Auto-Code generiert: " .. code .. " für " .. carName)
        else
            print("Ungültige Eingabe für Auto-Namen!")
        end
    else
        print("Du hast nicht die erforderlichen Rechte, um diesen Befehl auszuführen!")
    end
end, false)



-- Befehl zum Einlösen des Geld- oder Waffen-Codes
RegisterCommand("redeem", function(source, args, rawCommand)
    local code = args[1]
    if redeemKeys[code] then
        local player = source
        if redeemKeys[code].type == "money" then
            AddMoneyToPlayer(player, redeemKeys[code].value)
        elseif redeemKeys[code].type == "weapon" then
            GiveWeaponToPlayer(player, redeemKeys[code].value)
        elseif redeemKeys[code].type == "item" then
            GiveItemToPlayer(player, redeemKeys[code].value, redeemKeys[code].count)
        elseif redeemKeys[code].type == "car" then
            GiveCarToPlayer(player, redeemKeys[code].value)
        end
        
        
        --redeemKeys[code] = nil
    else
        print("Ungültiger Code!")
    end
end, false)




function AddMoneyToPlayer(player, amount)
    local xPlayer = ESX.GetPlayerFromId(player)
    if xPlayer then
        xPlayer.addMoney(amount)
        xPlayer.showNotification("Du hast ".. amount .." Money erhalten")
    else
        print("Spieler nicht gefunden!")
    end
end

function GiveWeaponToPlayer(player, weaponName)
    local xPlayer = ESX.GetPlayerFromId(player)
    if xPlayer then
        xPlayer.addWeapon(weaponName, 250)
        xPlayer.showNotification("Du hast erfolgreich die Waffe bekommen")
    else
        print("Spieler nicht gefunden!")
    end
end


function GiveItemToPlayer(player, itemName, itemCount)
    local xPlayer = ESX.GetPlayerFromId(player)
    if xPlayer then
        xPlayer.addInventoryItem(itemName, itemCount)
        xPlayer.showNotification("Du hast das item " .. itemName .. " " .. "erhalten")
    else
        print("Spieler nicht gefunden!")
    end
end


function GiveCarToPlayer(player, carName)
    local xPlayer = ESX.GetPlayerFromId(player)
    if xPlayer then
        -- Hier generieren wir eine zufällige Nummernschild-Nummer. Dies kann nach Bedarf angepasst werden.
        local plate = "ESX" .. math.random(1000, 9999)

        local vehicleData = json.encode({
            model = carName,
            plate = plate
        })

        MySQL.Async.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (?, ?, ?, ?, ?)', {
            xPlayer.identifier,
            plate,
            vehicleData,
            1, -- Angenommen, das Fahrzeug wird im Parkhaus abgestellt (stored). Ändern Sie dies, falls erforderlich.
            'car' -- Angenommen, der Typ für Autos ist 'car'. Ändern Sie dies, falls erforderlich.
        }, function(insertId)
            if insertId then
                xPlayer.showNotification("Du hast ein neues Fahrzeug erhalten: " .. carName)
            else
                xPlayer.showNotification("Ein Fehler ist aufgetreten!")
            end
        end)
    else
        print("Spieler nicht gefunden!")
    end
end
