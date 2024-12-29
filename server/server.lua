local resource = GetCurrentResourceName()

local taxes = {
    ["income"] = 5.0,  -- 10%
    ["sales"] = 2.5   -- 7.5%
}

local govmoney = {
    ["taxes"] = 0,      -- Money Made Per Resource Run From Taxes (Server Uptime Duration)
    ["police"] = 0      -- Money Made Per Resource Run From Policing (Server Uptime Duration)
}

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

RegisterCommand('adminpay', function (source, args)
	if IsPlayerAceAllowed(source, "command.adminpay") then
        if GetPlayerPing(args[1]) ~= 0 then
            local amount = tonumber(args[2])
            AddMoney(args[1], "cash", amount)
            TriggerClientEvent('chatMessage', source, Config.ServerName, {255, 0, 0}, "^3 You have admin paided ^7^* $" .. amount .. " ^7 to " .. GetPlayerName(args[1]))     
            TriggerClientEvent('chatMessage', args[1], Config.ServerName, {255, 0, 0}, "^3 You have received ^7^* $" .. amount .. " ^7 from " .. GetPlayerName(source))
        else
            TriggerClientEvent('chatMessage', source, Config.ServerName, {255, 0, 0}, "^3 Unknown Player. | ^7 Example: /pay ID amount")
        end
    else
        TriggerClientEvent('chatMessage', source, Config.ServerName, {255, 0, 0}, "^3 You do not have permission to use ^7^* /adminpay")
    end
end)

AddEventHandler("playerConnecting", function(name, setReason, deferrals)
    if string.find(GetPlayerIdentifiers(source)[1], "steam:") then
        local user = source
        local data = ReadFile('data')
        local count = 0
        local found = false
    
        for k, v in pairs(data) do
            count = count + 1
            if v.steamid == GetPlayerIdentifiers(user)[1] then
                found = true
            end
        end
    
        if not found then
            count = count + 1
            local userinfo = {
                ["name"] = GetPlayerName(user),
                ["steamid"] = GetPlayerIdentifiers(user)[1],
                ["cash"] = Config.StartingCash,
                ["bank"] = Config.StartingBank,
            }
            table.insert(data, userinfo)
            WriteFile('data', data)
        end
    
        if count == 0 then
            local userinfo = {
                ["name"] = GetPlayerName(user),
                ["steamid"] = GetPlayerIdentifiers(user)[1],
                ["cash"] = 0,
                ["bank"] = 0,
            }
            table.insert(data, userinfo)
            WriteFile('data', data)
        end
	else 
		setReason("Error! | Steam is required to play on this special FiveM server!!")
		CancelEvent()
	end
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

RegisterNetEvent("weeklyPayment")
AddEventHandler("weeklyPayment", function()
    local money = math.random(15,110)
    local taxed = money - (money * (taxes.income / 100))
    AddMoney(source, "bank", taxed)
    govmoney.taxes = govmoney.taxes + (money - taxed)
    TriggerClientEvent('chatMessage', source, Config.ServerName, {255, 0, 0}, "^3 You have received ^7^*$" .. money .. " ($" .. taxed .. " ^3 after taxes) from unemployment.")
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
    amount = tonumber(amount)
    if user == "self" then
        user = source
    end
    local userdata = GetUserData(user)
    local data = ReadFile('data')
    if type == "bank" then
        local newuserdata = {
            ["name"] = GetPlayerName(user),
            ["steamid"] = GetPlayerIdentifiers(user)[1],
            ["cash"] = userdata.cash,
            ["bank"] = math.floor(userdata.bank + amount),
        }
        for k, v in pairs(data) do
            if v.steamid == userdata.steamid then
                table.remove(data, k)
                table.insert(data, newuserdata)
                WriteFile('data', data)
            end
        end
        TriggerClientEvent("updateClientMoney", user, "bank", GetUserData(user).bank)  
    else
        local newuserdata = {
            ["name"] = GetPlayerName(user),
            ["steamid"] = GetPlayerIdentifiers(user)[1],
            ["cash"] = math.floor(userdata.cash + amount),
            ["bank"] = userdata.bank,
        }
        for k, v in pairs(data) do
            if v.steamid == userdata.steamid then
                table.remove(data, k)
                table.insert(data, newuserdata)
                WriteFile('data', data)
            end
        end
        TriggerClientEvent("updateClientMoney", user, "cash", GetUserData(user).cash)  
    end
end

function RemoveMoney(user, type, amount)
    amount = tonumber(amount)
    if user == "self" then
        user = source
    end
    local userdata = GetUserData(user)
    local data = ReadFile('data')
    if type == "bank" then
        if userdata.bank < amount then
            return false
        else
            local newuserdata = {
                ["name"] = GetPlayerName(user),
                ["steamid"] = GetPlayerIdentifiers(user)[1],
                ["cash"] = userdata.cash,
                ["bank"] = math.floor(userdata.bank - amount),
            }
            for k, v in pairs(data) do
                if v.steamid == userdata.steamid then
                    table.remove(data, k)
                    table.insert(data, newuserdata)
                    WriteFile('data', data)
                end
            end
            TriggerClientEvent("updateClientMoney", user, "bank", GetUserData(user).bank)  
            return true
        end
    else
        if userdata.cash < amount then
            return false
        else
            local newuserdata = {
                ["name"] = GetPlayerName(user),
                ["steamid"] = GetPlayerIdentifiers(user)[1],
                ["cash"] = math.floor(userdata.cash - amount),
                ["bank"] = userdata.bank,
            }
            for k, v in pairs(data) do
                if v.steamid == userdata.steamid then
                    table.remove(data, k)
                    table.insert(data, newuserdata)
                    WriteFile('data', data)
                end
            end
            TriggerClientEvent("updateClientMoney", user, "cash", GetUserData(user).cash)  
            return true
        end
    end
end

RegisterNetEvent("updateClientTaxesServer")
AddEventHandler("updateClientTaxesServer", function()
    TriggerClientEvent("updateClientTaxes", source, taxes)
end)

exports("GetTaxes", function()
    return taxes
end)

RegisterNetEvent("AddGovBalance")
AddEventHandler("AddGovBalance", function(type, amount)
    AddGovBalance(type, amount)
end)

exports("AddGovBalance", function(type, amount)
    AddGovBalance(type, amount)
end)

function AddGovBalance(type, amount)
    if type == "taxes" then
        govmoney.taxes = govmoney.taxes + amount
    elseif type == "police" then
        govmoney.police = govmoney.police + amount
    end
end

function GetUserData(user)
    if user == "self" then
        user = source
    end
    local returndata = nil
    for k, v in pairs(ReadFile('data')) do
        if v.steamid == GetPlayerIdentifiers(user)[1] then
            returndata = v
        end
    end
    return returndata
end

function ReadFile(file)
    local data = LoadResourceFile(resource, 'userdata/' .. file .. '.json')
    if data then
        return json.decode(data)
    else
        return false
    end
end

function WriteFile(file, data)
    SaveResourceFile(resource, 'userdata/' .. file .. '.json', json.encode(data), -1)
end

if not ReadFile('data') then
    WriteFile('data', {})
end

function format_thousand(v)
    local s = string.format("%d", math.floor(v))
    local pos = string.len(s) % 3
    if pos == 0 then pos = 3 end
    return string.sub(s, 1, pos) .. string.gsub(string.sub(s, pos+1), "(...)", ",%1")
end