
local localkeys = {}

Citizen.CreateThread(function()
    while true do 
        if IsControlJustReleased(0, Config.Keybind) then 
            toggle(true)
        end 
        Citizen.Wait(1)
    end 
end)

function toggle()
    ESX.TriggerServerCallback('fcarlock:getKeys', function(xKeys)
        check(xKeys, localkeys)
    end)
end 

function check(xKeys, localkeys)
    local near_veh = ESX.Game.GetClosestVehicle()
    local near_plate = ESX.Game.GetVehicleProperties(near_veh).plate
    if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(near_veh)) < Config.CheckDist then 
        for k,v in pairs(localkeys) do 
            if string.gsub(v.plate, "%s+", "") == string.gsub(near_plate, "%s+", "") then
                openVehicle(near_veh, v.label)
                break
            end 
        end 
        for k,v in pairs(xKeys) do 
            if string.gsub(json.decode(v.vehicle).plate, "%s+", "") == string.gsub(near_plate, "%s+", "") then
                openVehicle(near_veh, GetLabelFromVehicle(json.decode(v.vehicle).model))
                break
            end 
        end 
    end 
end

function openVehicle(vehicle, label)
    local dict = "anim@mp_player_intmenu@key_fob@"
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(0)
	end

    if not IsPedInAnyVehicle(PlayerPedId(), true) then
        TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
    end

    local lockstate = GetVehicleDoorLockStatus(vehicle)
    Config.Notifcation({(Config.Notify[lockstate][1]):format(label), Config.Notify[lockstate][2]})

    if lockstate == 1 or lockstate == 0 then
		SetVehicleDoorShut(vehicle, 0, false)
		SetVehicleDoorShut(vehicle, 1, false)
		SetVehicleDoorShut(vehicle, 2, false)
		SetVehicleDoorShut(vehicle, 3, false)
		SetVehicleDoorsLocked(vehicle, 2)
		PlayVehicleDoorCloseSound(vehicle, 1)
		FlashLights(vehicle)
	elseif lockstate == 2 then
		SetVehicleDoorsLocked(vehicle, 1)
		PlayVehicleDoorOpenSound(vehicle, 0)
		FlashLights(vehicle)
	end

end 

function FlashLights(vehicle)
	SetVehicleLights(vehicle, 2)
	Citizen.Wait(150)
	SetVehicleLights(vehicle, 0)
	Citizen.Wait(150)
	SetVehicleLights(vehicle, 2)
	Citizen.Wait(150)
	SetVehicleLights(vehicle, 0)
end 

function GetLabelFromVehicle(vehicle)
    local vehicleLabel = GetDisplayNameFromVehicleModel(vehicle)
    local showName = vehicleLabel
    if Config.ShowLuaName then 
        local vehLabel = GetLabelText(vehicleLabel)
        showName = vehLabel
    end 
    return(showName)
end 

RegisterCommand(Config.Command, function()
    openKeys()
end)

function openKeys()
    ESX.TriggerServerCallback('fcarlock:getKeys', function(xKeys)
        lib.registerContext({
            id = 'f_keys',
            title = Config.Menu.header,
            options = {
                {
                    title = Config.Menu.steal,
                    description = Config.Menu.steal_desc,
                    icon = 'hand',
                    onSelect = function()
                        if IsPedInAnyVehicle(PlayerPedId(), false) then 
                            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            local label = GetLabelFromVehicle(GetEntityModel(vehicle))
                            local plate = ESX.Game.GetVehicleProperties(vehicle).plate
                            local exist = false 
                            for k,v in pairs(localkeys) do 
                                if v.plate == plate then 
                                    exist = true 
                                end 
                            end 
                            for k,v in pairs(xKeys) do 
                                if json.decode(v.vehicle).plate == plate then 
                                    exist = true 
                                end 
                            end 
                            if not exist then 

                                lib.progressBar({
                                    duration = 3000,
                                    label = Config.Menu.stealing_in_progress,
                                })

                                table.insert(localkeys, {label = label, plate = plate})
                                Config.Notifcation(Config.Message.stole_key)
                            else 
                                Config.Notifcation(Config.Message.already_own)
                            end 
                        else 
                            Config.Notifcation(Config.Message.not_in_car)
                        end 
                    end 
                },
                {
                    title = Config.Menu.keys,
                    description = Config.Menu.keys_desc,
                    icon = 'hand',
                    onSelect = function()
                        local insertkeys = {}
                        for k,v in pairs(localkeys) do 
                            table.insert(insertkeys, {
                                title = v.label,
                                description = v.plate,
                                icon = 'key',
                                onSelect = function()
                                    giveKey(v.plate, v.label)
                                end 
                            })
                        end 
                        for k,v in pairs(xKeys) do 
                            table.insert(insertkeys, {
                                title = GetLabelFromVehicle(json.decode(v.vehicle).model),
                                description = json.decode(v.vehicle).plate,
                                icon = 'key',
                                onSelect = function()
                                    giveKey(json.decode(v.vehicle).plate, GetLabelFromVehicle(json.decode(v.vehicle).model))
                                end     
                            })
                        end 
                        lib.registerContext({
                            id = 'f_keys_mangage',
                            title = Config.Menu.keys,
                            options = insertkeys,
                            onExit = function()
                                openKeys()
                            end,
                        })
                        lib.showContext('f_keys_mangage')
                    end 
                },
            }
        })
        lib.showContext('f_keys')
    end)   
end 

function giveKey(plate, label)
    local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
        TriggerServerEvent('fcarlock:giveKeysServer', GetPlayerServerId(closestPlayer), plate, label)
        Config.Notifcation(Config.Message.give_keys)
    else 
        Config.Notifcation(Config.Message.no_player)
    end 
end 

RegisterNetEvent('fcarlock:giveKeysClient')
AddEventHandler('fcarlock:giveKeysClient', function(plate, label)
    ESX.TriggerServerCallback('fcarlock:getKeys', function(xKeys)
        local exist = false 

        for k,v in pairs(localkeys) do 
            if v.plate == plate then 
                exist = true 
                break
            end 
        end 
        if not exist then 
            for k,v in pairs(xKeys) do 
                if plate == json.decode(v.vehicle).plate then 
                    exist = true 
                    break
                end 
            end 
        end 
        
        if not exist then 
            insertkey(plate, label)
            Config.Notifcation(Config.Message.get_keys)
        else 
            Config.Notifcation(Config.Message.already_own)
        end 
    end)
end)

function insertkey(plate, label)
    table.insert(localkeys, {label = label, plate = plate})
end 
