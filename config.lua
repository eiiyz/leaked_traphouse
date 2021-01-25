Config = {}
Config.ShowMarkerDistance = 20.0
Config.TimeBeforeNewRob =  120 -- in minutes
Config.MinChance = 1   -- Minumun chance for notify others when failed to rob
Config.MaxChance = 50  -- Maximum chance for notify others when failed to rob
Config.LimitSystem = true

Config.admins = {
	'Your steam hex'
}

Config.AutoStock = false -- Restocks items every time the resource/server starts

Config.TrapHouses = {
	[1] = {
		pos = vector3(312.14, -1764.30, 29.15),
		name = "Rancho Trap House",
		text = "[E] Trap House",
		lastRobbed = 0,
		items = {
			{ name = "door_lockpick ", label = "Door Lockpick", price = 5000, max = 2, stocks = 2, limit = 5 },
			{ name = "bolt_cutter", label = "Bolt Cutter", price = 3000, max = 3, stocks = 2, limit = 3 }
		}
	},

	[2] = {
		pos = vector3(1120.02, -639.69, 56.81),
		name = "East Vinewood Trap House",
		text = "[E] Trap House",
		lastRobbed = 0,
		items = {
			{ name = "electronickit", label = "Electronic Kit", price = 1000, max = 7, stocks = 2, limit = 5 },
			{ name = "thermite", label = "Thermite", price = 1000, max = 10, stocks = 2, limit = 5 },
			--{ name = "advancedlockpick", label = "Advanced Lockpick", price = 100, max = 2, stocks = 5, limit = 5 }
		}		
	},

	[3] = {
		pos = vector3(-510.75, -52.85, 42.11),
		name = "Burton Trap House",
		text = "[E] Trap House",
		lastRobbed = 0,
		items = {
			{ name = "security_card_01", label = "Security Card", price = 1000, max = 5, stocks = 2, limit = 5 },
			{ name = "prison_idcard", label = "Prison Card", price = 1000, max = 5, stocks = 2, limit = 5 },
			--{ name = "rebreather", label = "Rebreather", price = 500, max = 1, stocks = 3, limit = 3 }
		}		
	},

	[4] = {
		pos = vector3(-1104.07, -1059.89, 2.73),
		name = "Vespucci Canals Trap House",
		text = "[E] Trap House",
		lastRobbed = 0,
		items = {
			{ name = "lockpick", label = "Lockpick", price = 1000, max = 5, stocks = 2, limit = 5 },
			{ name = "trojan_usb", label = "Trojan USB", price = 5000, max = 5, stocks = 2, limit = 5 },
			--{ name = "sodium_hydroxide", label = "Sulfuric Acid", price = 125, max = 15, stocks = 420, limit = 420 }
		}		
	},	

	[5] = {
		pos = vector3(836.95, -2292.78, 30.51),
		name = "Cypress Flats Trap House",
		text = "[E] Trap House",
		lastRobbed = 0,
		items = {
			{ name = "door_lockpick ", label = "Door Lockpick", price = 5000, max = 2, stocks = 2, limit = 5 },
			{ name = "advancedlockpick", label = "Bolt Cutter", price = 3000, max = 3, stocks = 2, limit = 3 }
		}			
	},				
}