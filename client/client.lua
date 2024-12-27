RegisterNetEvent("updateClientMoney")
AddEventHandler("updateClientMoney", function(type, amount)
    if type == "bank" then
        SendNUIMessage({
            action = "updateBank",
            amount = amount
        })
    elseif type == "cash" then
        SendNUIMessage({
            action = "updateCash",
            amount = amount
        })
    end
end)