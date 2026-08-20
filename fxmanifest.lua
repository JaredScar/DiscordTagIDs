fx_version 'cerulean'
game 'gta5'

author 'JaredScar'
description 'Badger\'s DiscordTagIDs'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

client_scripts {
    'config.lua',
    'client.lua'
}
server_scripts {
    "config.lua",
    "server.lua"
}

server_exports {
    "HideUserTag",
    "ShowUserTag",
    "GetActiveUserTag",
    "GetUserTags",
    "SetUserTag",
}
