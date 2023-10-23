
fx_version 'cerulean'

game 'gta5'


server_scripts {
    'server/main.lua',
    "config.lua",
}

client_scripts{
    'client/main.lua',
    "config.lua",

} 

ui_page 'web/index.html'

files{
    'web/index.html',
    'web/style.css',
    'web/script.js',
    'web/image/*',
}