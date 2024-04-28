fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'fabzhii'
description 'F-CarlockV2 by fabzhii'
version '2.0.0'

shared_script '@es_extended/imports.lua'
shared_script '@ox_lib/init.lua'

server_scripts {
    'config.lua',
    "@mysql-async/lib/MySQL.lua",
    'server.lua',
}

client_scripts {
    'config.lua',
    'client.lua',
} 

dependencies {
	'ox_lib',
}