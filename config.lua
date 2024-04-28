Config = {}

Config.ColorScheme = 'blue'

Config.Keybind = 47
Config.Command = 'keys'
Config.ShowLuaName = true 
Config.CheckDist = 10

Config.Notify = {
    {'Du hast dein Fahrzeug abgeschlossen.', 'error'},
    {'Du hast dein Fahrzeug aufgeschlossen.', 'success'},
}

Config.Message = {
    not_in_car = {'Du bist in keinem Fahrzeug.', 'error'},
    already_own = {'Du besitzt den Schlüssel des Fahrzeugs schon.', 'error'},
    no_player = {'Es ist kein Spieler in deiner Nähe.', 'error'},
    stole_key = {'Du hast den Schlüssel gestohlen.', 'success'},
    give_keys = {'Du hast den Schlüssel übergeben.', 'success'},
    get_keys = {'Du hast einen Schlüssel bekommen.', 'success'},
}

Config.Menu = {
    header = 'Schlüsselbund',
    steal = 'Schlüssel Stehlen',
    steal_desc = 'Klaue den Schlüssel des derzeigen Autos.',
    stealing_in_progress = 'Schlüssel wird gestohlen...',
    keys = 'Schlüsselbund',
    keys_desc = 'Verwalte deine derzeigen Schlüssel',
}


Config.Notifcation = function(notify)
    local message = notify[1]
    local notify_type = notify[2]
    lib.notify({
        position = 'top-right',
        description = message,
        type = notify_type,
    })
end 
