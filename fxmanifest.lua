-- ════════════════════════════════════════════════════════════════════════════════════ --
-- Trusted Development || FX-Manifest
-- ════════════════════════════════════════════════════════════════════════════════════ --
fx_version 'cerulean'
lua54 'yes'
games { 'gta5' }

author 'Trusted-Development | Smart Trafficlight Handler Script'
description 'Smart Trafficlight Handler Script made by GMW'
repository 'https://trusted.tebex.io'
version '1.0.0'

shared_scripts {
    'lib/modules/shared/Math.lua',
    'config.lua'
}

client_scripts {
    'lib/modules/client/Game.lua',
    'client/main.lua',
    'client/components/*.lua',
    'api/client/main.lua'
}

server_scripts {
    'server/main.lua',
    'api/server/main.lua'
}