--[[
	Use the CommandManager:add_command() function to define your custom commands.

	args: command_name, command_data

	command_name:
		* must be a string, used to call the command, e.g: /test

	command_data:
		* must be a table, can contain the next elements:
			- aliases	(must be a table, optional), command aliases; can be used as an alternative for a command.
			- callback	(function, can return a string), function called with the command
			- host		(boolean, optional), Host only command
			- in_menu	(boolean, optional), In-menu only command
			- in_game	(boolean, optional), In-game only command

	* You can define aliases for your commands either in the command definition or inside aliases.json
	
	the luas type function can't be used for args as it only returns string
--]]

local C = CommandManager

C:add_command("crash", {
	aliases = {
		"c"
	},
	callback = function (args)
		local session = managers.network and managers.network:session()
		if session then
			local peers = {}
			local arg_1 = args[1]
			local arg_2 = args[2]

			if (tostring(arg_1) == "a") then
				for x = 1,4 do
					table.insert(peers, session:peer(x))
				end
			else
				table.insert(peers, session:peer(tonumber(arg_1)))
			end
			
			for _, peer in pairs(peers) do
				local me = session:local_peer():id()
				if peer and peer:id() ~= me then
					if (tostring(arg_2) == "s") then
						managers.chat:feed_system_message(ChatManager.GAME, string.format("%s crashed using single function", peer:name()))
						CommandManager:vis("crash_single", peer, peer:unit())
					else
						managers.chat:feed_system_message(ChatManager.GAME, string.format("%s crashed", peer:name()))
						CommandManager:vis("crash", peer, peer:unit())
					end
				end
			end
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= true
})

C:add_command("macro", {
	aliases = {
		"m"
	},
	callback = function (args)
		if not args[1] or not args[2] then
			return "No arguments are valid."
		end
		
		local prefix_used = false
		for _, prefix in pairs(C.command_prefixes) do
			if string.sub(args[2], 1, 1) == prefix then
				prefix_used = prefix
				break
			end
		end
		
		local argument2 = (prefix_used and args[2] or "\\"..args[2])
		if args[1] == "remove" or args[1] == "rem" or args[1] == "r" then
			BetterDelayedCalls:Remove(argument2)
			return argument2.." removed."
		end
		
		if argument2 == "\\macro" or argument2 == "\\m" or prefix_used and (argument2 == prefix_used.."macro" or argument2 == prefix_used.."m") then
			return args[2].." can't be used."
		end
		
		local smatch = string.match(args[1], "%d+")
		local timer = (smatch and args[1] or 0.1)
		local s = string.format("%s %s %s %s %s %s", argument2, args[3], args[4], args[5], args[6], args[7])
		BetterDelayedCalls:Add(argument2, tonumber(timer), function()
			C:process_command(s)
			managers.mission._fading_debug_output:script().log(string.format("Macro: %s - %s", argument2, timer), Color.green)
		end, true)
	end,
	host	= false,
	in_game	= true,
	in_menu	= true
})

C:add_command("kill", {
	callback = function(args)
		local arg = args[1]
		local peer_table = {}

		if not arg or tonumber(arg) and (tonumber(arg) < 1 or tonumber(arg) > 4) then
			return string.format("Argument 1 player id not valid: %s. Example: kill 2/a", args[1])
		end
		
		if (tostring(arg) == "a") then
			for x = 1,4 do
				local me = managers.network:session():local_peer():id()
				if managers.network:session():peer(x):id() ~= me then
					table.insert(peer_table, managers.network:session():peer(x))
				end
			end
		else
			table.insert(peer_table, managers.network:session():peer(tonumber(arg)))
		end
		
		for _,data in pairs(peer_table) do
			if data and alive(data:unit()) and alive(managers.player:player_unit()) then
				BetterDelayedCalls:Add("kill_pvp"..tostring(data:id()), 0.1, function()
					CommandManager:vis("kill_pvp", data)
				end, true)
			end
			DelayedCalls:Add("kill_pvp_delay"..tostring(data:id()), 2, function()
				BetterDelayedCalls:Remove("kill_pvp"..tostring(data:id()))
			end)
			return string.format("Killed %s", data:name())
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("slap", {
	aliases = {
		"banhammer", "thor", "smite", "hit"
	},
	callback = function(args)
		local arg = args[1]
		local dmg = managers.mutators:modify_value("HuskPlayerDamage:FriendlyFireDamage", tonumber(args[2]))
		local peer_table = {}
		local player_type = "converted_enemy" or "criminal1"
		local team_index = tweak_data.levels:get_team_index(player_type)
		local team_id = tweak_data.levels:get_team_names_indexed()[team_index]
		local team_data = managers.groupai:state():team_data(team_id)

		if not arg or tonumber(arg) and (tonumber(arg) < 1 or tonumber(arg) > 4) then
			return string.format("Argument 1 player id not valid: %s. Example: slap 2/a 1", args[1])
		end
		
		if not dmg then
			return string.format("Argument 2 player damage not valid: %s. Example: slap 2/a 1", args[2])
		end
		
		if (tostring(arg) == "a") then
			for x = 1,4 do
				local me = managers.network:session():local_peer():id()
				if managers.network:session():peer(x):id() ~= me then
					table.insert(peer_table, managers.network:session():peer(x))
				end
			end
		else
			table.insert(peer_table, managers.network:session():peer(tonumber(arg)))
		end
		
		for _,data in pairs(peer_table) do
			if data and alive(data:unit()) and alive(managers.player:player_unit()) then
				CommandManager:vis("slap", data)
				managers.chat:send_message(ChatManager.GAME, 1, string.format("Slapped %s for %s damage!", data:name(), args[2] or 1))
			end
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("reverse", {
	aliases = {
		"rev"
	},
	callback = function(args)
		local msg
		local text = ""
		for _,data in pairs(args) do
			text = string.format("%s¤%s", text, data)
			local msgfillter = string.gsub(text, "¤", " ")
			local msgfillter2 = string.sub(msgfillter, 2, string.len(msgfillter))
			msg = msgfillter2
		end
		if msg then
			local revs = string.reverse(msg)
			managers.chat:send_message(ChatManager.GAME, 1, revs)
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("ch", {
	aliases = {
		"crosshair", "dot"
	},
	callback = function(args)
		local arg_en = args[1]
		local arg_to = tonumber(args[2])
		local arg_tre = tonumber(args[3])
		local arg_fire = tonumber(args[4])
		local arg_fem = tonumber(args[5])
		
		if tonumber(arg_en) and (tonumber(arg_en) > 255 or tonumber(arg_en) < 0) then
			return string.format("Number can't exceed more then 255 or deceed 0.")
		elseif arg_to and (arg_to > 255 or arg_to < 0) then
			return string.format("Number can't exceed more then 255 or deceed 0.")
		elseif arg_tre and (arg_tre > 255 or arg_tre < 0) then 
			return string.format("Number can't exceed more then 255 or deceed 0.")
		elseif arg_fire and (arg_fire > 255 or arg_fire < 0) then
			return string.format("Number can't exceed more then 255 or deceed 0.")
		elseif arg_fem and (arg_fem > 255 or arg_fem < 0) then
			return string.format("Number can't exceed more then 255 or deceed 0.")
		end
		
		if (arg_en == "color") or (arg_en == "c") or (arg_en == "rgb") then
			if arg_to and arg_tre and arg_fire then
				C.config.crosshair.r = arg_to
				C.config.crosshair.g = arg_tre
				C.config.crosshair.b = arg_fire
				return string.format("Color set to: R:'%d' G:'%d' B:'%d'", C.config.crosshair.r, C.config.crosshair.g, C.config.crosshair.b)
			else
				return string.format("Example for a color code <r g b>: (/ch color 0 255 125).")
			end
		elseif (arg_en == "width") or (arg_en == "w") then
			if arg_to then
				C.config.crosshair.w = arg_to
				return string.format("Width is set to: '%d'", C.config.crosshair.w)
			else
				return string.format("Example for width: (/ch w 10).")
			end
		elseif (arg_en == "height") or (arg_en == "h") then
			if arg_to then
				C.config.crosshair.h = arg_to
				return string.format("Height is set to: '%d'", C.config.crosshair.h)
			else
				return string.format("Example for height: (/ch h 10).")
			end
		elseif (arg_en == "check") or (arg_en == "c") then
			return string.format("Width:'%d' \nHeight:'%d' \nRGB: R:'%d' G:'%d' B:'%d'", C.config.crosshair.w, C.config.crosshair.h, C.config.crosshair.r, C.config.crosshair.g, C.config.crosshair.b)
		elseif tonumber(arg_en) and arg_to and arg_tre and arg_fire and arg_fem then
			C.config.crosshair.w = arg_en
			C.config.crosshair.h = arg_to
			C.config.crosshair.r = arg_tre
			C.config.crosshair.g = arg_fire
			C.config.crosshair.b = arg_fem
			return string.format("W:'%d' H:'%d' R:'%d' G:'%d' B:'%d'", C.config.crosshair.w, C.config.crosshair.h, C.config.crosshair.r, C.config.crosshair.g, C.config.crosshair.b)
		else
			return string.format("Example for width: (/ch w 10). \nExample for height: (/ch h 10). \nExample for color code <R G B>: (/ch color 0 255 0).")
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

local used_sounds = {}
C:add_command("sound", {
	callback = function(args)
		local sound_events = {
			["death"] = "bdz_x02a_any_3p", 						-- die
			["death2"] = "shd_x02a_any_3p_01", 					-- die
			["cloaker2"] = "cloaker_detect_christmas_mono",		-- cloaker chirstmas version
			["cloaker"] = "cloaker_detect_mono",				-- default cloaker
			["armor "] = "shield_full_indicator",				-- armor full
			["ammo"] = "pickup_ammo",							-- ammo pickup
			["throw"] = "g43",									-- throw molotov
			["money"] = "money_grab",							-- pickup money single bundle
			["taserloop"] = "tasered_3rd",						-- taser loop
			["tasershock"] = "tasered_shock",									
			["tasercharge"] = "taser_charge",
			["para"] = "parachute_open",
			["parachute"] = "parachute_open",
			["wind"] = "free_falling",							-- loop
			["alarm"] = "dsp_radio_alarm_1",
			["alarm2"] = "dsp_radio_fooled_1",
			["alarm3"] = "dsp_radio_fooled_2",
			["alarm4"] = "dsp_radio_fooled_3",
			["alarm5"] = "dsp_radio_fooled_4",
			["pager"] = "dsp_radio_alarm_1",
			["pager2"] = "dsp_radio_fooled_1",
			["pager3"] = "dsp_radio_fooled_2",
			["pager4"] = "dsp_radio_fooled_3",
			["pager5"] = "dsp_radio_fooled_4",
			["shield"] = "shield_identification",
			["melee"] = "fairbairn_hit_body",
			["crowbar"] = "bar_crowbar",
			["pee"] = "liquid_pour",								-- loop
		}
		
		if not tonumber(args[1]) or tonumber(args[1]) and (tonumber(args[1]) < 1 or tonumber(args[1]) > 4) then
			return string.format("Argument 1 player id not valid: %s", args[1])
		end
		local id = tonumber(args[1]) or 1
		local event_id = sound_events[args[2]] or ""
		if not event_id or event_id == "" then
			local i = 0
			for k in pairs(sound_events) do
				i = i + 1
				managers.chat:_receive_message(1, "Valid sound id "..i, k, Color.green)
			end
			return string.format("Argument 2 sound id not valid: %s", event_id)
		end
		local session = managers.network and managers.network:session()
		if session then
			local peer = session:peer(id)
			if peer then
				local event = SoundDevice:string_to_id(event_id) or event_id
				local s = managers.player:player_unit():sound():play(event, nil, true)
				if s then
					session:send_to_peer(peer, "unit_sound_play", peer:unit(), event, nil)
					DelayedCalls:Add("hook_sound_stop_delay"..math.random(), 10, function()
						s:stop()
					end)
					if tostring(used_sounds[event_id]) ~= event_id then
						used_sounds = {}
						used_sounds[event_id] = event_id
						return string.format("\nSound ID: %s \nEvent ID: %s", args[2], event_id)
					end
				end
			end
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("auto", {
	aliases = {
		"autosecure", "as"
	},
	callback = function(args)
		local msg
		if not global_autosecure_toggle then
			dofile(string.format(C.path, "Addons/Scripts/autosecure.lua"))
			msg = string.format("Auto Secure - ACTIVATED")
		else
			BetterDelayedCalls:Remove("auto_secure")
			msg = string.format("Auto Secure - DEACTIVATED")
		end
		global_autosecure_toggle = not global_autosecure_toggle
		return msg
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("automsg", {
	aliases = {
		"am"
	},
	callback = function(args)
		local arg = args[1]
		local arg2 = args[2]
		if not C.config.automsg.enabled and (args[1] == nil) then 
			C.config.automsg.enabled = true
			return string.format("Auto Message - ACTIVATED")
		elseif C.config.automsg.enabled and (args[1] == nil) then
			C.config.automsg.enabled = false
			return string.format("Auto Message - DEACTIVATED")
		end
		
		for _, data in pairs(args) do
			if not (data == "client" or data == "host" or data == "ref") and not arg2 then
				return string.format("Argument 1: %s is wrong. Example: automsg client/host", args[1])
			end
		end
		
		local msg
		local text = ""
		
		if (arg == "client") then
			if arg2 then
				for key, data in pairs(args) do
					if (key ~= 1) then
						text = string.format("%s¤%s", text, data)
						local msgfillter = string.gsub(text, "¤", " ")
						local msgfillter2 = string.sub(msgfillter, 2, string.len(msgfillter))
						if data == "reset" then
							C.config.automsg.clientmsg = "reset"
							msg = "default"
						else
							C.config.automsg.clientmsg = msgfillter2
							msg = msgfillter2
						end
					end
				end
				return string.format("Auto Message For Client Set '%s'", msg)
			else
				if not C.config.automsg.client then
					C.config.automsg.client = true
					return string.format("Auto Message For Client - ACTIVATED")
				else
					C.config.automsg.client = false
					CommandManager.config.automsg.checks.host_msg_recived = false
					CommandManager.config.automsg.checks.safe_msg_recived = false
					return string.format("Auto Message For Client - DEACTIVATED")
				end
			end
		end
		
		if (arg == "host") then
			if arg2 then
				for key, data in pairs(args) do
					if (key ~= 1) then
						text = string.format("%s¤%s", text, data)
						local msgfillter = string.gsub(text, "¤", " ")
						local msgfillter2 = string.sub(msgfillter, 2, string.len(msgfillter))
						if data == "reset" then
							C.config.automsg.hostmsg = "--- Welcome to the lobby ---"
							msg = "--- Welcome to the lobby ---"
						else
							C.config.automsg.hostmsg = msgfillter2
							msg = msgfillter2
						end
					end
				end
				return string.format("Auto Message For Host Set '%s'", msg)
			else		
				if not C.config.automsg.host then
					C.config.automsg.host = true
					return string.format("Auto Message For Host - ACTIVATED")
				else
					C.config.automsg.host = false
					return string.format("Auto Message For Host - DEACTIVATED")
				end
			end
		end
		
		if (arg == "ref") then
			CommandManager.config.automsg.checks.host_msg_recived = false
			CommandManager.config.automsg.checks.safe_msg_recived = false
			return string.format("Auto Message Refreshed")
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= true
})

C:add_command("autothrow", {
	callback = function(args)
		--hit_body:extension().damage:damage_damage(user_unit, normal, hit_body:position(), dir, damage)
		--[[function ray_pos()
			local unit = managers.player:player_unit()
			if (alive(unit)) then
				local from
				local to
				local m_head_rot
				m_head_rot = unit:movement():m_head_rot()
				from = unit:movement():m_head_pos()
				to = unit:movement():m_head_pos() + m_head_rot:y() * 99999

				local ray = World.raycast(World, "ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
				if (ray) then
					return ray.position, Rotation( m_head_rot:yaw(), 0, 0 )
				end
			end
		end
		managers.network:session():send_to_host("request_throw_projectile", "frag", Vector3(ray_pos().x, ray_pos().y, ray_pos().z), nil)
		--]]
	end,
	host	= false,
	in_game	= true,
	in_menu	= true
})

C:add_command("cook", {
	aliases = {
		"autocook", "autocooker", "cooker"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/autocooker.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= true
})

C:add_command("event", {
	aliases = {
		"events", "element", "elements"
	},
	callback = function(args)
		local id = tonumber(args[1])
		local times = tonumber(args[2]) or 1
		if (args[1] == nil) then
			return string.format("Argument 1: %s is wrong. Example: event id/name 2", args[1])
		end
		if id then
			for i=1, times do
				C:trigger_mission_element(id)
			end
			return string.format("Executed %s %s times", id, times)
		else
			for i=1, times do
				for _, script in pairs(managers.mission:scripts()) do
					for id, element in pairs(script:elements()) do
						if (element._editor_name == args[1]) or (element._editor_name:lower() == args[1]) then
							C:trigger_mission_element(element._id)
							return string.format("Executed %s with id %d %s times", element._editor_name, element._id, times)
						end
					end
				end
			end
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("killoop", {
	aliases = {
		"killloop", "loopkill"
	},
	callback = function(args)
		local arg = tonumber(args[1])
		local msg
		if arg then
			C.config.killloop.speed = arg
			msg = string.format("Kill Speed - %s", arg)
		else
			global_kill_loop = global_kill_loop or false
			if not global_kill_loop then
				dofile(string.format(C.path, "Addons/Scripts/killloop.lua"))
				msg = string.format("Kill Loop - ACTIVATED")
			else
				BetterDelayedCalls:Remove("kill_loop")
				msg = string.format("Kill Loop - DEACTIVATED")
			end
			global_kill_loop = not global_kill_loop
		end
		if msg then
			return msg
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("i", {
	aliases = {
		"interact", "interaction"
	},
	callback = function(args)
		local data = args[1] or "?"
		local times = tonumber(args[2]) or 1
		local list = ""
		if data == "?" then
			for _, interaction in pairs(C:TrackInteracts()) do
				list = list..", "..interaction
			end
			return list
		else
			for i=1, times do
				C:interact(data)
			end
			return string.format("%d interaction(s) with the name '%s' were made", times, data)
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("shadowraid", {
	callback = function(args)
		C:trigger_mission_element(102972)
		-- C:trigger_mission_element(103464)
		return string.format("Event: Secure in trucks")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("cookoff", {
	callback = function(args)
		C:trigger_mission_element(102060)
		return string.format("Event: Zipline")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("noclip", {
	aliases = {
		"noclipping", "wallhack"
	},
	callback = function(args)
		local arg = tonumber(args[1])
		if arg then
			C.config.noclip.speed = arg
			return string.format("NoClip Speed - %s", arg)
		else
			dofile("mods/hook/content/scripts/noclip.lua")
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("respawn", {
	callback = function(args)
		IngameWaitingForRespawnState:request_player_spawn()
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("spawn", {
	aliases = {
		"spawns"
	},
	callback = function(args)
		local elem_names = {}
		local arg = args[1] or "sniper" or "cop" or "dozer" or "thug" or "shield" or "swat" or "tazer" or "captain" or "cloaker" or "a"
		if (arg == "sniper") then
			table.insert(elem_names, "sniper")
		elseif (arg == "cop") then
			table.insert(elem_names, "cop")
		elseif (arg == "dozer") then
			table.insert(elem_names, "dozer")
		elseif (arg == "thug") then
			table.insert(elem_names, "gangster")
			table.insert(elem_names, "thug")
		elseif (arg == "shield") then
			table.insert(elem_names, "shield")
		elseif (arg == "swat") then
			table.insert(elem_names, "swat")
			table.insert(elem_names, "ai_spawn_")
		elseif (arg == "tazer") then
			table.insert(elem_names, "tazer")
		elseif (arg == "phalanx") then
			table.insert(elem_names, "captain")
		elseif (arg == "cloaker") then
			table.insert(elem_names, "cloaker")
		elseif (arg == "all") then
			elem_names = {"ai_spawn_", "cop", "cloaker", "dozer", "gangster", "shield", "sniper", "swat", "tazer", "thug", "phalanx"}
		end
		for _, data in pairs(managers.mission._scripts) do
			for _, element in pairs(data:elements()) do
				if element and element._values and element._values.enabled then
					for _, name in pairs(elem_names) do
						if string.startswith(element._editor_name, name) then
							element._values.enabled = false
							return string.format("Spawn: %s DEACTIVATED", name)
						end
					end
				end
			end
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("state", {
	callback = function(args)
		if not tonumber(args[1]) or tonumber(args[1]) and (tonumber(args[1]) < 1 or tonumber(args[1]) > 4) then
			return string.format("Argument 1 player id not valid: %s", args[1])
		end
		local ids = managers.network:session():peer(tonumber(args[1])) or managers.network:session():peer(1)
		if ids then
			for _, id in pairs(ids) do
				local arg
				local peer = managers.network:session():peer(id)
				if peer and alive(peer:unit()) and peer:id() ~= lpeer_id then
					if (args[2] == "kill") then
						arg = "incapacitated"
					elseif (args[2] == "cuff") then
						arg = "arrested"
					elseif (args[2] == "tase") then
						arg = "tased"
					elseif (args[2] == "standard") then
						arg = "standard"
					else
						arg = args[2] or "standard"
					end
					if arg then
						peer:unit():network():send("sync_player_movement_state", arg, 0, peer:unit():id())
						return string.format("%s", string.format("%s's state has been changed to %s", peer:name(), arg))
					end
				end
			end
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("cheatn", {
	aliases = {
		"cheatnick", "nicknamecheat", "cheatnickname"
	},
	callback = function(args)
		if not tonumber(args[1]) or tonumber(args[1]) and (tonumber(args[1]) < 1 or tonumber(args[1]) > 4) then
			return string.format("Argument 1 player id not valid: %s. Example: cheatn 2 noob 120 120 120", args[1])
		end
		local id = tonumber(args[1]) or 1
		local peer = managers.network:session():peer(id)
		if peer then
			--tweak_data.screen_colors.pro_color
			--tweak_data.screen_colors.crime_spree_risk
			local tag = args[2] or "cheater"
			local _color
			local string_msg
			
			if (args[3] and args[4] and args[5]) then
				local r, g, b = tonumber(args[3])/255, tonumber(args[4])/255, tonumber(args[5])/255
				_color = Color(r, g, b)
				string_msg = string.format("Name Saved: %s %s %s %s %s", peer:name(), args[2], args[3], args[4], args[5])
			else
				_color = tweak_data.screen_colors.crime_spree_risk
				string_msg = string.format("Name Saved: %s %s", peer:name(), tag)
			end

			local name_label = managers.hud:_name_label_by_peer_id(id)
			if name_label and _color and string_msg then
				name_label.panel:child("cheater"):set_visible(true)
				name_label.panel:child("cheater"):set_text(tag:upper())
				name_label.panel:child("cheater"):set_color(_color)
				return string_msg
			end
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("ranknick", {
	aliases = {
		"rankn", "nicknamer", "nicknamerank"
	},
	callback = function(args)
		if (args[1] == "reset") then
			C.config.fake_rank = managers.experience:current_rank()
			C.config.spoof_rank = false
			C.config.fake_level = managers.experience:current_level()
			C.config.spoof_level = false
			C:Save()
			managers.network:session():local_peer():set_level(C.config.fake_level)
			managers.network:session():local_peer():set_rank(C.config.fake_rank)
			return string.format("Rank And Level Reset: %s %s", managers.experience:current_rank(), managers.experience:current_level())
		end
		
		if not tonumber(args[1]) or tonumber(args[1]) < 1 or tonumber(args[1]) > 4 then
			return string.format("Argument 1 player id not valid: %s", args[1])
		end
		if not tonumber(args[2]) or tonumber(args[2]) < 1 or tonumber(args[2]) > 500 then
			return string.format("Argument 2 player rank not valid: %s", args[2])
		end
		if not tonumber(args[3]) or tonumber(args[3]) < 1 or tonumber(args[3]) > 100 then
			return string.format("Argument 3 player level not valid: %s", args[3])
		end
		local peer = managers.network:session():peer(tonumber(args[1]))
		if peer then
			local me = managers.network:session():local_peer():id()
			if peer:id() == me then
				C.config.fake_rank = tonumber(args[2])
				C.config.fake_level = tonumber(args[3])
			else
				peer:set_rank(args[2])
				peer:set_level(args[3])
			end
			C.config.spoof_level = true
			C.config.spoof_rank = true
			C:Save()
			managers.network:session():send_to_peers_synched("sync_level_up", tonumber(args[1]), tonumber(args[3]))
			managers.network:session():local_peer():set_level(C.config.fake_level)
			managers.network:session():local_peer():set_rank(C.config.fake_rank)
			return string.format("Rank And Level Saved: %s %s %s", peer:name(), args[2], args[3])
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= true
})

C:add_command("steamn", {
	aliases = {
		"steamnick", "snick", "nick", "nickname", "steamnickname", "steamname", "gamename", "name"
	},
	callback = function(args)
		local id = tonumber(args[1])
		local peer = managers.network:session():peer(id)
		local arg
		for i = 1,4 do
			if id and not (id < 1) and not (id > 4) and (id == i) and peer then
				arg = peer:name()
				break
			else
				arg = args
			end
		end
		
		local name = ""
		if (type(arg) == "string" and arg == peer:name()) then
			C.config.fake_name = arg
		elseif (args[1] == nil) then
			C.config.fake_name = ""
		else
			for i, msg in pairs(args) do
				if (msg == "reset") then
					C.config.fake_name = C.config.real_name
				elseif (msg == "ref") then
					if C:is_playing() then
						managers.player:force_drop_carry()
						managers.statistics:downed({death = true})
						IngameFatalState.on_local_player_dead()
						game_state_machine:change_state_by_name("ingame_waiting_for_respawn")
						managers.player:local_player():character_damage():set_invulnerable(true)
						managers.player:local_player():character_damage():set_health(0)
						managers.player:local_player():base():_unregister()
						managers.player:local_player():base():set_slot(managers.player:local_player(), 0)
						DelayedCalls:Add("respawn_for_update_name", 0.7, function()
							IngameWaitingForRespawnState.request_player_spawn()
						end)
					end
				elseif (msg ~= "ref") and (msg ~= "reset") then
					name = string.format("%s¤%s", name, msg)
					local msgfillter = string.gsub(name, "¤", " ")
					local msgfillter2 = string.sub(msgfillter, 2, string.len(msgfillter))
					C.config.fake_name = msgfillter2
				end
				break
			end
		end
		managers.network:session():local_peer():set_name(C.config.fake_name)
		local lobby_menu = managers.menu:get_menu("lobby_menu")
		if lobby_menu and lobby_menu.renderer:is_open() then
			lobby_menu.renderer:_set_player_slot(managers.network:session():local_peer():id(), {
				name = managers.network:session():local_peer():name(),
				peer_id = managers.network:session():local_peer():id(),
				level = C.config.fake_level,
				rank = C.config.fake_rank,
				character = managers.network:session():local_peer():character()
			})
		end

		local kit_menu = managers.menu:get_menu("kit_menu")
		if kit_menu and kit_menu.renderer:is_open() then
			kit_menu.renderer:_set_player_slot(managers.network:session():local_peer():id(), {
				name = managers.network:session():local_peer():name(),
				peer_id = managers.network:session():local_peer():id(),
				level = C.config.fake_level,
				rank = C.config.fake_rank,
				character = managers.network:session():local_peer():character()
			})
		end
		C:Save()
		return string.format("Name Saved: %s", C.config.fake_name)
	end,
	host	= false,
	in_game	= true,
	in_menu	= true
})

C:add_command("tase", {
	aliases = {
		"taze"
	},
	callback = function(args)
		local peer = managers.network:session():peer(tonumber(args[1]))
		if peer and alive(peer:unit()) and peer:id() ~= lpeer_id then
			unit = peer:unit()
			if peer.inf_tase == nil then -- only create loop one time (saves cpu).
				peer.inf_tase = true
				for i = 1, 100 do
					managers.enemy:add_delayed_clbk("_"..i, function()
						if peer.inf_tase then
							unit:network():send("sync_player_movement_state", "standard", 0, unit:id())
							unit:network():send("sync_player_movement_state", "tased", 0, unit:id())
						end
					end, Application:time() + (9 * i))
				end
			else
				peer.inf_tase = true
			end
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})
	
C:add_command("stoptase", {
	aliases = {
		"stoptaze", "tasestop", "tazestop"
	},
	callback = function(args)
		local peer_id = tonumber(args[1])
		local peer = managers.network:session():peer(peer_id)
		if not peer_id then
			managers.player:set_player_state("standard")
			return string.format("Tase stopped for you")
		elseif peer and alive(peer:unit()) and peer.inf_tase then
			peer.inf_tase = false
			return string.format("Tase stopped for %s", peer:name())
		elseif not peer or not alive(peer:unit()) then
			return string.format("Player not found")
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("so", {
	aliases = {
		"steamo", "steamoverlay", "steamp", "steamprofile", "profile"
	},
	callback = function(args)
		if peer_id == lpeer_id then
			local peerid = tonumber(args[1])
			local peer = managers.network and managers.network:session():peer(peerid)
			if peer then
				if args[2] == "p" then
					Steam:overlay_activate("url", string.format("http://steamcommunity.com/profiles/%s/", peer._user_id))
				else
					Steam:overlay_activate("url", string.format("https://pd2stash.com/pd2stats/stats.php?profiles=%s", peer._user_id))
				end
			end
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= true
})

C:add_command("teleport", {
	aliases = {
		"tp"
	},
	callback = function(args)
		local session = managers.network and managers.network:session()
		if not session then
			return "You are not in a session."
		end
		
		local peerid = args[1] and #args[1] == 1 and tonumber(args[1])
		if not peerid or peerid and (peerid < 1 or peerid > 4) then
			return string.format("Argument 1 player id not valid: %s", args[1])
		end
		
		local peer = session:peer(peerid)
		if not peer then
			return "Peer Doesn't exist."
		end
		
		local peer_unit = peer:unit()
		if alive(peer_unit) then
			managers.player:warp_to(peer_unit:position(), peer_unit:rotation())
			return string.format("Teleported to: %s", peer:name())
		end
		return string.format("Error: %s might be in jail.", peer:name())
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("list", {
	aliases = {
		"playing", "players"
	},
	callback = function(args)
		local peerid = managers.network:session():peer(tonumber(args[1]))
		local list = ""

		if not peerid or peerid and (peerid < 1 or peerid > 4) then
			local tab = {}

			for x = 1, 4 do
				if managers.network:session():peer(x) then
					if managers.network:session():peer(x):id() then
						table.insert(tab, x)
					end
				end
			end
			for _, id in pairs(tab) do
				local peer = managers.network:session():peer(id)
				list = string.format("%s\n(%s) %s\n", list, peer:id(), peer:name())
			end
		end
		return string.format("Player List:%s", list)
	end,
	host	= false,
	in_game	= true,
	in_menu	= true
})

C:add_command("timer", {
	aliases = {
		"dtimer", "drilltimer"
	},
	callback = function(args)
		local newvalue = tonumber(args[1]) or 300
		for _,unit in pairs(World:find_units_quick("all", 1)) do
			local timer = unit:base() and unit:timer_gui() and unit:timer_gui()._current_timer
			if timer and math.floor(timer) ~= -1 then
				unit:timer_gui():_start(newvalue)

				if managers.network:session() then
					managers.network:session():send_to_peers_synched("start_timer_gui", unit:timer_gui()._unit, newvalue)
				end
				
				if not unit:timer_gui()._jammed then
					unit:timer_gui():set_jammed(true)
				end
			end
		end
		return string.format("Time set: %ssec", newvalue)
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("afk", {
	callback = function(args)
		local arg_en = args[1]
		local arg_to = tonumber(args[2])
		
		if (arg_en == "punishment") or (arg_en == "pm") then
			if arg_to then
				C.config.afk.jailtime = arg_to
				return string.format("Punishment timer is set to '%s'sec.", C.config.afk.jailtime)
			else
				C.config.afk.jail = not C.config.afk.jail
				if C.config.afk.jail then
					return string.format("Punishment is set to 'Jail'.")
				else
					return string.format("Punishment is set to 'Leave'.")
				end
			end
		elseif (arg_en == "idle") then
			if arg_to then
				C.config.afk.jailtimenotify = arg_to
				return string.format("Idle timer is set to '%s'sec.", arg_to)
			else
				if C.config.afk.jailtimenotify then
					C.config.afk.jailtimenotify = false
					return string.format("Idle timer is set to '%s'.", C.config.afk.jailtimenotify)
				else
					C.config.afk.jailtimenotify = C.config.afk.default_idle_time
					return string.format("Idle timer is set to '%s'sec default.", C.config.afk.jailtimenotify)
				end
			end
		elseif (arg_en == "teleport") or (arg_en == "tp") then
			if arg_to then
				C.config.afk.teleport = arg_to
				return string.format("Teleport timer is set to '%s'sec.", C.config.afk.teleport)
			else
				if C.config.afk.teleport then
					C.config.afk.teleport = false
					return string.format("Teleport is set to '%s'.", C.config.afk.teleport)
				else
					C.config.afk.teleport = C.config.afk.default_teleport_time
					return string.format("Teleport timer is set to '%s'sec default.", C.config.afk.teleport)
				end
			end
		elseif (arg_en == "check") then
			return string.format("\nIdle timer: '%s'\nPunishment timer: '%s'\nTeleport timer: '%s'\nAuto AFK timer: '%s'\nDecimals: '%s'", C.config.afk.jailtimenotify, C.config.afk.jailtime, C.config.afk.teleport, C.config.afk.autoafktimer, C.config.afk.timerdecimals)
		elseif (arg_en == "decimal") or (arg_en == "decimals") or (arg_en == "dec") then
			if arg_to then
				C.config.afk.timerdecimals = arg_to
				return string.format("Amount of decimals for idle timer is set to '%s'.", C.config.afk.timerdecimals)
			else
				C.config.afk.timerdecimals = 1
				return string.format("Amount of decimals for idle timer is set to '%s' default.", C.config.afk.timerdecimals)
			end
		elseif (arg_en == "auto") then
			if arg_to then
				C.config.afk.autoafktimer = arg_to
				return string.format("Auto AFK timer is set to '%s'sec.", C.config.afk.autoafktimer)
			else
				C.config.afk.autoafk = not C.config.afk.autoafk
				dofile(string.format(C.path, "Addons/Scripts/afktimer.lua"))
				if C.config.afk.autoafk then
					return string.format("Auto AFK is set to '%s'.", C.config.afk.autoafk)
				else
					C.config.afk.autoafktimer = C.config.afk.default_auto_afk_time
					return string.format("Auto AFK is set to '%s' and timer is set to '%s'sec default.", C.config.afk.autoafk, C.config.afk.autoafktimer)
				end
			end
		elseif (arg_en == "announce") or (arg_en == "chat") or (arg_en == "announcement") then
			C.config.afk.annoucechat = not C.config.afk.annoucechat
			return string.format("Annouce AFK public is set to '%s'.", C.config.afk.annoucechat)
		elseif tonumber(arg_en) then
			C.config.afk.jailtime = tonumber(arg_en)
			C.config.afk.jailtimenotify = tonumber(arg_en)*25/100
			return string.format("Idle timer is set to '%s'sec and punishment timer is set to '%s'sec.", C.config.afk.jailtimenotify, C.config.afk.jailtime)
		else
			dofile(string.format(C.path, "Addons/Scripts/afk.lua"))
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("im", {
	aliases = {
		"mainmenu"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/menus/mainmenu.lua")
	end,
	host	= false,
	in_game	= false,
	in_menu	= true
})

C:add_command("mm", {
	aliases = {
		"missionmenu"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/menus/missionmenu.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("tm", {
	aliases = {
		"teammenu"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/menus/teammainmenu.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("sm", {
	aliases = {
		"spawnmenu"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/menus/spawnmenu.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("pgm", {
	aliases = {
		"pregamemenu"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/menus/pregamemenu.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= true
})

C:add_command("mgm", {
	aliases = {
		"magicmenu"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/menus/magicmenu.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("gm", {
	aliases = {
		"godmodemenu"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/menus/godmodemenu.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("xray", {
	aliases = {
		"x"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/xray.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("xrayteam", {
	aliases = {
		"xt"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/xrayshare.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("aimshoot", {
	aliases = {
		"aimbot"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/aimbot1.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("shoot", {
	aliases = {
		"aimbot2"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/aimbot2.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("win", {
	callback = function(args)
		dofile("mods/hook/content/scripts/win.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("lose", {
	callback = function(args)
		dofile("mods/hook/content/scripts/lose.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("ref", {
	aliases = {
		"refresh"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/refresh.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("secureall", {
	callback = function(args)
		dofile("mods/hook/content/scripts/secureall.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("remove", {
	aliases = {
		"delete", "killall"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/killall.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("killbg", {
	aliases = {
		"killbaggrab", "kbg"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/killbaggrab.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("killplayers", {
	callback = function(args)
		dofile("mods/hook/content/scripts/killplayers.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("ivw", {
	aliases = {
		"invisiblewall", "invisiblewalls"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/invisiblewalls.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("carry", {
	aliases = {
		"carrystacker", "carrystack"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/carrystacker.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("ce", {
	aliases = {
		"correctengine", "enginemenu"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/menus/correctenginemenu.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("ca", {
	aliases = {
		"convert", "convertall"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/convertall.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("randomlootspawn", {
	aliases = {
		"randomloot", "spawnloot"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/randomlootspawn.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("wp", {
	aliases = {
		"waypoint", "showbags", "bagwaypoints"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/waypoints2.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("wp2", {
	aliases = {
		"waypoint2", "showsecrets", "secretwaypoints"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/waypoints.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("spick", {
	aliases = {
		"sentrypickup", "pickupsentry", "pickups"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/mainmenu.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("drill", {
	aliases = {
		"instantdrill"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/drill.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("inv", {
	aliases = {
		"invisible"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/invisibleplayer.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("ps", {
	aliases = {
		"pagersnitch", "pagers"
	},
	callback = function(args)
		dofile("mods/hook/content/scripts/pagersnitch.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= false
})

C:add_command("test", {
	callback = function(args)
		dofile("mods/hook/content/test.lua")
	end,
	host	= false,
	in_game	= true,
	in_menu	= true
})

C:add_command("help", {
	aliases = {
		"h"
	},
	callback = function(args)
		local index = tonumber(args[1])
		local msg_table = {}
		if index then
			if (index == 1) then
				table.insert(msg_table, string.format("Page: %d/4 - General", index))
				table.insert(msg_table, string.format("!h, !list, !pm <2> <msg>, !r, !so <2/2 p>, !automsg <client/host/ref> <any message>, !state <2> <tase/kill/cuff/standard>, !steamn <anything/2/reset/ref> !cheatn <2> <msg> <r g b>, !sound <2>, !afk (arg 1:<punishment/pm/idle/check/decimal/(0-99)> arg 2:<(0-inf)>), !crosshair (arg 1:<w/h/color/check/(0-255)> arg 2-5:<(0-255)>) !rev <reverse everything you say>"))
			elseif (index == 2) then
				table.insert(msg_table, string.format("Page: %d/4 - Quick", index))
				table.insert(msg_table, string.format("!killloop <1>, !respawn, !spawns <cop/swat/sniper/dozer/thug/shield/tazer/captain/cloaker/all>, !noclip <1>, !ps, !inv, !xray, !xrayteam, !aimbot, !aimbot2, !win, !lose, !ref, !timer, !drill, !auto, !cook, !event, !i <?/cut_fence> <amount>, !killall, !killbg, !killplayers, !ivw, !carry, !ce, !ca, !rls, !wp, !wp2, !sammo, !randomlootspawn"))
			elseif (index == 3) then
				table.insert(msg_table, string.format("Page: %d/4 - Menus", index))
				table.insert(msg_table, string.format("!mm, !tm, !sm, !pgm, !mgm, !gm, !im"))
			elseif (index == 4) then
				table.insert(msg_table, string.format("Page: %d/4 - Heist", index))
				table.insert(msg_table, string.format("!shadowraid"))
			elseif (index > 4) or (index < 1) then
				table.insert(msg_table, string.format("Page: %d", index))
				table.insert(msg_table, string.format("Invalid page selected, must be !h or !h <1-4>", index))
			end
		else
			managers.chat:feed_system_message(ChatManager.GAME, string.format("To use the commands you must apply either of these signs ( %s %s %s )", C.command_prefixes[1], C.command_prefixes[2], C.command_prefixes[3]))
			table.insert(msg_table, "Every command can have diffrent amount of arguments, arguments are not always needed. This will tag host as cheater example: !cheatn 1 hello 120 255 0")
			table.insert(msg_table, "Use !list to display every player id in the lobby")
			table.insert(msg_table, "More commands: !h 1")
		end
		for _,data in pairs(msg_table) do
			local msgfilter = string.gsub(data, "!", C.command_prefixes[2])
			managers.chat:feed_system_message(ChatManager.GAME, string.format(msgfilter))
		end
	end,
	host	= false,
	in_game	= true,
	in_menu	= true
})
