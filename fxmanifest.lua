fx_version "bodacious"
game "gta5"

ui_page "interface/index.html"

client_scripts {
	"@vrp/lib/utils.lua",
	"utils/*",
	"client/*"
}

server_scripts {
	"@vrp/lib/utils.lua",
	"utils/*",
	"server/*"
}

files {
	"interface/*",
	"interface/**/*",
	"config/config.json",
}