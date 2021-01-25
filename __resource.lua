resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
    'server/server.lua',
    'config.lua'
}

client_scripts {
    'client/client.lua',
    'config.lua'
    
}

ui_page 'html/ui.html'
files {
	'html/ui.html',
	'html/pricedown.ttf',
	'html/cursor.png',
	'html/background.png',
	'html/styles.css',
	'html/scripts.js',
	'html/debounce.min.js'
}