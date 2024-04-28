
ESX.RegisterServerCallback('fcarlock:getKeys', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner', {
        ['@owner'] = xPlayer.identifier,
    }, function(data)
        cb(data)
    end)
end)

RegisterServerEvent('fcarlock:giveKeysServer')
AddEventHandler('fcarlock:giveKeysServer', function(id, plate, label)
    TriggerClientEvent('fcarlock:giveKeysClient', id, plate, label)
end)
