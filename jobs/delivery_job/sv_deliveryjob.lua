RegisterServerEvent("requestDeliveryJob")
AddEventHandler("requestDeliveryJob", function()
    local source = source
    local userData = GetUserData(source)
    if userData then
        TriggerClientEvent("startDeliveryJob", source)
    else
        TriggerClientEvent("chat:addMessage", source, { args = { "^1Error starting the job. Please try again later." } })
    end
end)

RegisterServerEvent("completeDeliveryJob")
AddEventHandler("completeDeliveryJob", function(totalPay)
    local source = source
    AddMoney(source, "cash", totalPay)
    TriggerClientEvent("chat:addMessage", source, { args = { "^2You have been paid: $" .. totalPay .. " for completing the delivery job." } })
end)