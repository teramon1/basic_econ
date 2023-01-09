local resource = GetCurrentResourceName()

local taxes = {
    ["income"] = 5.0,  -- 10%
    ["sales"] = 2.5   -- 7.5%
}

local govmoney = {
    ["taxes"] = 0,      -- Money Made Per Resource Run From Taxes (Server Uptime Duration)
    ["police"] = 0      -- Money Made Per Resource Run From Policing (Server Uptime Duration)
}

RegisterCommand("balance", function(source, args)
    if args[1] == nil then
        local userdata = GetUserData(source)
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Player Name: ^7" .. GetPlayerName(source))
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Cash Balance: ^7^* $" .. format_thousand(userdata.cash))
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Bank Balance: ^7^* $" .. format_thousand(userdata.bank))
    else
        if GetPlayerPing(args[1]) ~= 0 then
            local userdata = GetUserData(args[1])
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Player Name: ^7" .. GetPlayerName(source))
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Cash Balance: ^7^* $" .. format_thousand(userdata.cash))
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Bank Balance: ^7^* $" .. format_thousand(userdata.bank))
        else 
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^7 Unknown Player. Example: /balance ID")        
        end
    end
end)

RegisterCommand("serverbalance", function(source, args)
    local cash = 0
    local bank = 0
    for k, v in pairs(ReadFile('data')) do
        cash = cash + v.cash
        bank = bank + v.bank
    end
    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Total Server Balance:")
    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Cash Balance: ^7^*$" .. format_thousand(cash))
    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Bank Balance: ^7^*$" .. format_thousand(bank))
end)

RegisterCommand('pay', function (source, args)
    if args[1] == nil or args[2] == nil then
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Missing Parameter! ^7 | Example: /pay ID amount")
        return
    end
    if GetPlayerPing(args[1]) ~= 0 then
        local amount = tonumber(args[2])
        if amount < 1 then    
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 The minimum amount to pay is: ^7^*$1")      
        else
            if RemoveMoney(source, "cash", amount) then
                AddMoney(args[1], "cash", amount)
                TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 You have paid: ^7^* $" .. amount .. " ^7 to " .. GetPlayerName(args[1]))   
                TriggerClientEvent('chatMessage', args[1], "", {255, 0, 0}, "^3 You have received: ^7^*$" .. amount .. " ^7 from " .. GetPlayerName(source))
            else
                TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Not enough money!")
            end
        end
    else
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Unknown Player. ^7 Example: /pay ID amount")
    end
end)

RegisterCommand('adminpay', function (source, args)
	if IsPlayerAceAllowed(source, "command.adminpay") then
        if GetPlayerPing(args[1]) ~= 0 then
            local amount = tonumber(args[2])
            AddMoney(args[1], "cash", amount)
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 You have admin paided ^7^* $" .. amount .. " ^7 to " .. GetPlayerName(args[1]))     
            TriggerClientEvent('chatMessage', args[1], "", {255, 0, 0}, "^3 You have received ^7^* $" .. amount .. " ^7 from " .. GetPlayerName(source))
        else
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Unknown Player. | ^7 Example: /pay ID amount")
        end
    else
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 You do not have permission to use ^7^* /adminpay")
    end
end)

RegisterCommand('banktransfer', function (source, args)
    if args[1] == nil or args[2] == nil then
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Missing Parameter! ^7 | Example: /banktransfer ID amount")
        return
    end
    if GetPlayerPing(args[1]) ~= 0 then
        local amount = tonumber(args[2])
        if amount < 1 then    
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 The minimum amount to transfer is: ^7^*$1")      
        else
            if RemoveMoney(source, "bank", amount) then
                AddMoney(args[1], "bank", amount)
                TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 You have transfered: ^7^* $" .. amount .. " ^7 to " .. GetPlayerName(args[1]))   
                TriggerClientEvent('chatMessage', args[1], "", {255, 0, 0}, "^3 You have received: ^7^*$" .. amount .. " ^7 from " .. GetPlayerName(source))
            else
                TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Not enough money!")
            end
        end
    else
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Unknown Player. ^7 Example: /banktransfer ID amount")
    end
end)

RegisterCommand('deposit', function (source, args)
    if args[1] == nil then
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Missing Parameter! | ^7 Example: /deposit amount")
        return
    end
    if GetPlayerPing(source) ~= 0 then
        local amount = tonumber(args[1])
        if amount < 1 then
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 The minimum amount to transfer is: ^7^* $1")        
        else
            if RemoveMoney(source, "cash", amount) then
                AddMoney(source, "bank", amount) 
                TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 You have deposited: ^7^* $" .. amount .. " to the bank ")  
            else 
                TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Not enough money!")
            end
        end
    else
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Unknown Player. | ^7 Example: /deposit amount")
    end
end)

RegisterCommand('withdraw', function (source, args)
    if args[1] == nil then
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Missing Parameter! ^7 | Example: /withdraw amount")
        return
    end
    if GetPlayerPing(source) ~= 0 then
        local amount = tonumber(args[1])
        if amount < 1 then  
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 The minimum amount to withdraw is: ^7^*$1")      
        else
            if RemoveMoney(source, "bank", amount) then
                AddMoney(source, "cash", amount)
                TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 You have withdrawn: ^7^* $" .. amount .. " ^7 to your pocket!")   
            else 
                TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Not enough money!")
            end
        end
    else
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 Unknown Player. ^7 Example: /withdraw amount")
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
                ["cash"] = 5000,
                ["bank"] = 50000,
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

RegisterNetEvent("weeklyPayment")
AddEventHandler("weeklyPayment", function()
    local money = math.random(15,450)
    local taxed = money - (money * (taxes.income / 100))
    AddMoney(source, "cash", taxed)
    govmoney.taxes = govmoney.taxes + (money - taxed)
    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^3 You have received ^7^*$" .. money .. " ($" .. taxed .. " ^3 after taxes) from unemployment.")
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
    local data = LoadResourceFile(resource, file .. '.json')
    if data then
        return json.decode(data)
    else
        return false
    end
end

function WriteFile(file, data)
    SaveResourceFile(resource, file .. '.json', json.encode(data), -1)
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