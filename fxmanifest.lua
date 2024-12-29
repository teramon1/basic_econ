fx_version 'cerulean'
game 'gta5'

author 'blurry'

client_scripts {
    'client/client.lua',
    'jobs/**/cl_deliveryjob.lua'
}

server_script {
    'server/server.lua',
    'jobs/**/sv_deliveryjob.lua'
}

shared_scripts {
    'config.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

server_exports {'GetUserData', 'AddMoney', 'RemoveMoney',}