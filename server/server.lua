local resource = GetCurrentResourceName()

RegisterCommand("bankinfo", function(source, args)
    TriggerClientEvent('chatMessage', source, Config.ServerName, {255, 0, 0}, " ^*^_Bank Commands:")
    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, " ^2/pay ^7ID Amount")
end)

RegisterCommand('pay', function (source, args)
    if args[1] == nil or args[2] == nil then
        TriggerClientEvent('chatMessage', source, Config.ServerName, {255, 0, 0}, "^3 Missing Parameter! ^7 | Example: /pay ID amount")
        return
    end
    if GetPlayerPing(args[1]) ~= 0 then
        local amount = tonumber(args[2])
        if amount < 1 then    
            TriggerClientEvent('chatMessage', source, Config.ServerName, {255, 0, 0}, "^3 The minimum amount to pay is: ^7^*$1")      
        else
            if RemoveMoney(source, "cash", amount) then
                AddMoney(args[1], "cash", amount)
                TriggerClientEvent('chatMessage', source, Config.ServerName, {255, 0, 0}, "^3 You have paid: ^7^* $" .. amount .. " ^7 to " .. GetPlayerName(args[1]))   
                TriggerClientEvent('chatMessage', args[1], Config.ServerName, {255, 0, 0}, "^3 You have received: ^7^*$" .. amount .. " ^7 from " .. GetPlayerName(source))
            else
                TriggerClientEvent('chatMessage', source, Config.ServerName, {255, 0, 0}, "^3 Not enough money!")
            end
        end
    else
        TriggerClientEvent('chatMessage', source, Config.ServerName, {255, 0, 0}, "^3 Unknown Player. ^7 Example: /pay ID amount")
    end
end)

AddEventHandler("playerConnecting", function(name, setReason, deferrals)
    local user = source
    local identifiers = GetPlayerIdentifiers(user)
    
    if not identifiers or not identifiers[1] or not identifiers[1]:find("steam:") then
        setReason("Steam is required to play on this server.")
        CancelEvent()
        return
    end

    local steamid = identifiers[1]
    local userData = ReadPlayerFile(steamid)
    if not userData then
        userData = {
            name = GetPlayerName(user),
            steamid = steamid,
            cash = Config.StartingCash,
            bank = Config.StartingBank,
        }
        WritePlayerFile(steamid, userData)
    end
end)

RegisterServerEvent("automaticPayment")
AddEventHandler("automaticPayment", function()
    local src = source
    local amount = Config.AutoPayment
    AddMoney(src, "bank", amount)
    TriggerClientEvent('chat:addMessage', src, { args = { Config.ServerName, " ^2You have received an automatic payment of $" .. amount .. "." } })
end)

RegisterNetEvent("requestPlayerMoney")
AddEventHandler("requestPlayerMoney", function()
    local src = source
    local userData = GetUserData(src)
    if userData then
        TriggerClientEvent("updateHUD", src, userData.cash, userData.bank)
    end
end)

RegisterNetEvent("getPlayerMoney")
AddEventHandler("getPlayerMoney", function()
    local src = source
    local userData = GetUserData(src)
    if userData then
        TriggerClientEvent("updateMoneyUI", src, userData.cash, userData.bank)
    end
end)

RegisterServerEvent("customDeposit")
AddEventHandler("customDeposit", function(amount)
    local src = source
    local userData = GetUserData(src)
    if userData and userData.cash >= amount then
        RemoveMoney(src, "cash", amount)
        AddMoney(src, "bank", amount)
        TriggerClientEvent("updateMoneyUI", src, userData.cash - amount, userData.bank + amount)
        TriggerClientEvent('chatMessage', src, Config.ServerName, {255, 0, 0}, " ^2Deposit successful: $" .. amount)
    else
        TriggerClientEvent('chatMessage', src, Config.ServerName, {255, 0, 0}, " ^1Not enough cash to deposit!")
    end
end)

RegisterServerEvent("customWithdraw")
AddEventHandler("customWithdraw", function(amount)
    local src = source
    local userData = GetUserData(src)
    if userData and userData.bank >= amount then
        RemoveMoney(src, "bank", amount)
        AddMoney(src, "cash", amount)
        TriggerClientEvent("updateMoneyUI", src, userData.cash + amount, userData.bank - amount)
        TriggerClientEvent('chatMessage', src, Config.ServerName, {255, 0, 0}, " ^2Withdrawal successful: $" .. amount)
    else
        TriggerClientEvent('chatMessage', src, Config.ServerName, {255, 0, 0}, " ^1Not enough money in the bank!")
    end
end)

RegisterNetEvent("BankingAddMoney")
AddEventHandler("BankingAddMoney", function(user, type, amount)
    local Source = source
    AddMoney(user, type, amount)
end)

RegisterNetEvent("BankingRemoveMoney")
AddEventHandler("BankingRemoveMoney", function(user, type, amount)
    RemoveMoney(user, type, amount)
end)

RegisterServerEvent('chat:init')
AddEventHandler('chat:init', function()
    TriggerClientEvent("updateClientMoney", source, "cash", GetUserData(source).cash)  
    TriggerClientEvent("updateClientMoney", source, "bank", GetUserData(source).bank)  
end)

function AddMoney(user, type, amount)
    local userdata = GetUserData(user)
    if userdata then
        userdata[type] = math.floor(userdata[type] + amount)
        UpdateUserData(user, userdata)
        TriggerClientEvent("updateClientMoney", user, type, userdata[type])
    end
end

function RemoveMoney(user, type, amount)
    local userdata = GetUserData(user)
    if userdata and userdata[type] >= amount then
        userdata[type] = math.floor(userdata[type] - amount)
        UpdateUserData(user, userdata)
        TriggerClientEvent("updateClientMoney", user, type, userdata[type])
        return true
    end
    return false
end

local resource = GetCurrentResourceName()

function ReadPlayerFile(steamid)
    local safeSteamID = steamid:gsub(":", "_")
    local data = LoadResourceFile(resource, 'userdata/' .. safeSteamID .. '.json')
    if data then
        return json.decode(data)
    else
        return nil
    end
end

function WritePlayerFile(steamid, data)
    local safeSteamID = steamid:gsub(":", "_")
    SaveResourceFile(resource, 'userdata/' .. safeSteamID .. '.json', json.encode(data), -1)
end

function GetUserData(user)
    if user == "self" then
        user = source
    end

    local identifiers = GetPlayerIdentifiers(user)
    if not identifiers or not identifiers[1] then
        print("Error: Could not retrieve SteamID for user " .. tostring(user))
        return nil
    end

    local steamid = identifiers[1]
    return ReadPlayerFile(steamid)
end

function UpdateUserData(user, data)
    if user == "self" then
        user = source
    end
    local steamid = GetPlayerIdentifiers(user)[1]
    WritePlayerFile(steamid, data)
end

function format_thousand(v)
    local s = string.format("%d", math.floor(v))
    local pos = string.len(s) % 3
    if pos == 0 then pos = 3 end
    return string.sub(s, 1, pos) .. string.gsub(string.sub(s, pos+1), "(...)", ",%1")
end
