function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end
if not is_playing() then 
	return
end

printengine = function()
	local script = managers.mission:script("default")
	local fusion_engine = script._elements[103718]._values.on_executed[1].id
	local engines = { 
		{id = 103703, text = "Engine: 1", unit_id = "f0e7a7f29fc87c44"},
		{id = 103704,text = "Engine: 2", unit_id = "db218f98a571c0b1"},
		{id = 103705, text = "Engine: 3", unit_id = "c717770fadc88e04"},
		{id = 103706, text = "Engine: 4", unit_id = "5fb0a3191c4b8202"},
		{id = 103707, text = "Engine: 5", unit_id = "0b2ecebcf49765b9"},
		{id = 103708, text = "Engine: 6", unit_id = "b531a6b7026ad84f"},
		{id = 103709, text = "Engine: 7", unit_id = "e191b6d86e655e23"},
		{id = 103711, text = "Engine: 8", unit_id = "5aabe6e626f00bd4"} ,
		{id = 103714, text = "Engine: 9", unit_id = "5afbe85d94046cbe"},
		{id = 103715, text = "Engine: 10", unit_id = "9f316997306803b9"},
		{id = 103716, text = "Engine: 11", unit_id = "b2560b63edcda138"},
		{id = 103717, text = "Engine: 12", unit_id = "ee644ab092313077"}
	}

	for v, engine in pairs(engines) do
		if engine.id == fusion_engine then
			managers.chat:feed_system_message(ChatManager.GAME, string.format("%s | %s", engine.text, engine.unit_id))
		end
	end
end

printengineclient = function(engines, engineid, loceng, loceng2)
	if engines and engineid and loceng then
		local waypoint_1, waypoint_2 = "", ""
		local function add_waypoint(name, position, id)
			if name and position and id then
				waypoint_1 = string.format("%s_%s_1", name, id)
				managers.hud:add_waypoint(
					waypoint_1, {
					icon = 'equipment_vial',
					distance = true,
					position = position,
					no_sync = true,
					present_timer = 0,
					state = "present",
					radius = 800,
					color = Color.white,
					blend_mode = "add"
				})
			end
		end
		local function add_waypoint2(name, position, id)
			if name and position and id then
				waypoint_2 = string.format("%s_%s_2", name, id)
				managers.hud:add_waypoint(
					waypoint_2, {
					icon = 'equipment_vial',
					distance = true,
					position = position,
					no_sync = true,
					present_timer = 0,
					state = "present",
					radius = 800,
					color = Color.white,
					blend_mode = "add",
				})
			end
		end

		if loceng2 then
			add_waypoint(engines, loceng, engineid)
			add_waypoint2(engines, loceng2, engineid)
			DelayedCalls:Add("remove_waypoints_timer2", 20, function() 
				managers.hud:remove_waypoint(waypoint_1) 
				managers.hud:remove_waypoint(waypoint_2) 
			end)
		else
			add_waypoint(engines, loceng, engineid)
			DelayedCalls:Add("remove_waypoints_timer", 20, function() 
				managers.hud:remove_waypoint(waypoint_1) 
			end)
		end
		
		local function show_message(str)
			if managers.chat then
				managers.chat:feed_system_message(ChatManager.GAME, (str or "error"))
			end
		end
		local _name = string.gsub(engines, "_", " ")
		show_message(string.format("Correct one is: %s", _name))
	end
end

printengineclientmenu = function()
	local dialog_data = {    
		title = "Engine Menu For Client",
		text = "Select Correct Clue",
		button_list = {}
	}

	local all_engines = {
		{id = '1',  gastext = "Nitrogen - 2xH - >5783", 		enginetext = "engine_04",               loc = Vector3(-1200, -1735, -313.492)},
		{id = '2',  gastext = "Nitrogen - 3xH - >5783", 		enginetext = "engine_11",               loc = Vector3(-175, -1350, -313.492)},
		{id = '3',  gastext = "Nitrogen - 3xH - <5812", 		enginetext = "engine_08",               loc = Vector3(24.9999, -1350, -313.492)},
		{id = '4',  gastext = "Nitrogen - H - <5812",   		enginetext = "engine_01",               loc = Vector3(-1830, -2182, -313.492)},
		{id = '5',  gastext = "Nitrogen - 2xH - <5812", 		enginetext = "engine_04",               loc = Vector3(-1200, -1735, -313.492)},
		{id = '6',  gastext = "",   enginetext = "", loc = "", 		loc2 = ""},
		{id = '7',  gastext = "Deterium - H - >5783",   		enginetext = "engine_02",               loc = Vector3(-1200, -2050, -313.492)},
		{id = '8',  gastext = "Deterium - 3xH - >5783", 		enginetext = "engine_12",               loc = Vector3(25, -2050, -313.492)},
		{id = '9',  gastext = "Deterium - 3xH - <5812", 		enginetext = "engine_09",               loc = Vector3(-175, -1675, -313.492)},
		{id = '10', gastext = "Deterium - 2xH - <5812", 		enginetext = "engine_05",               loc = Vector3(-1849, -1429, -313.492)},
		{id = '11', gastext = "",   enginetext = "", loc = "", 		loc2 = ""},
        {id = '12', gastext = "Helium - 2xH - >5783",   		enginetext = "engine_06_or_engine_03",  loc = Vector3(-1200, -1415, -313.492), 	 loc2 = Vector3(-1849, -1869, -313.492)},
        {id = '13', gastext = "Helium - 3xH - >5783",   		enginetext = "engine_10",               loc = Vector3(35, -1733, -314)},
		{id = '14', gastext = "Helium - 3xH - <5812",   		enginetext = "engine_07_or_engine_10",  loc = Vector3(-175, -2025, -313.492), 	 loc2 = Vector3(35, -1733, -314)},
		{id = '15', gastext = "Helium - 2xH - <5812",   		enginetext = "engine_03",               loc = Vector3(-1849, -1869, -313.492)},
		{id = '16', gastext = "",   enginetext = "", loc = "", 		loc2 = ""},
		{id = '17', gastext = "Nitrogen - H - ?",   	 		enginetext = "engine_01", 			 	loc = Vector3(-1830, -2182, -313.492)},
		{id = '18', gastext = "Nitrogen - 2xH - ?",     		enginetext = "engine_04", 			 	loc = Vector3(-1200, -1735, -313.492)},
		{id = '19', gastext = "Nitrogen - 3xH - ?",     		enginetext = "engine_08_or_engine_11",  loc = Vector3(24.9999, -1350, -313.492), loc2 = Vector3(-175, -1350, -313.492)},
		{id = '20', gastext = "",   enginetext = "", loc = "", 		loc2 = ""},
		{id = '21', gastext = "Deterium - H - ?",   	  		enginetext = "engine_02", 			 	loc = Vector3(-1200, -2050, -313.492)},
		{id = '22', gastext = "Deterium - 2xH - ?",    		enginetext = "engine_05", 			 	loc = Vector3(-1849, -1429, -313.492)},
		{id = '23', gastext = "Deterium - 3xH - ?",     		enginetext = "engine_12_or_engine_09",  loc = Vector3(25, -2050, -313.492), 	 loc2 = Vector3(-175, -1675, -313.492)},
		{id = '24', gastext = "",   enginetext = "", loc = "", 		loc2 = ""},
		{id = '25', gastext = "Helium - 2xH - ?",   	  		enginetext = "engine_03_or_engine_06",  loc = Vector3(-1849, -1869, -313.492), 	 loc2 = Vector3(-1200, -1415, -313.492)},
		{id = '26', gastext = "Helium - 3xH - ?",   	  		enginetext = "engine_07_or_engine_10",  loc = Vector3(-175, -2025, -313.492), 	 loc2 = Vector3(35, -1733, -314)},
	}

	for _, engine in pairs(all_engines) do
		if engine then
			table.insert(dialog_data.button_list, {
				text = engine.gastext,
				callback_func = function()
					printengineclient(engine.enginetext, engine.id, engine.loc, engine.loc2)
				end,
			})
		end
	end

	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "back", callback_func = function() menu() end,})
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}    
	table.insert(dialog_data.button_list, no_button) 
	managers.system_menu:show_buttons(dialog_data)
end
local level = managers.job:current_level_id()
if (level == 'welcome_to_the_jungle_2') then
	if Network:is_server() then
		printengine()
	else
		printengineclientmenu()
	end
end