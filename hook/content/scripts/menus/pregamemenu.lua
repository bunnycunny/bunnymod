function in_game()
	if not game_state_machine then return false end
	return string.find(game_state_machine:current_state_name(), "game")
end
function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end
function is_server() -- Is host check
	return Network.is_server(Network)
end

if not in_game() then return end

local assets = function()
	for _,asset_id in pairs(managers.assets:get_all_asset_ids( true )) do
		if Idstring(asset_id) == Idstring("none") then return end
		if not managers.assets:is_unlock_asset_allowed() then return end
		local get_asset_id = managers.assets:get_asset_unlocked_by_id(asset_id)
		if Network:is_server() and not get_asset_id then
			managers.assets:unlock_asset( asset_id )
		elseif managers.assets.ALLOW_CLIENTS_UNLOCK and not get_asset_id then
			managers.assets._money_spent = 0
			managers.network:session():send_to_host( "server_unlock_asset", asset_id )
			managers.assets:_on_asset_unlocked(asset_id)
		end
	end
	if managers.preplanning and in_game() and not is_playing() then
		local contains = table.contains
		local random = math.random
		local equipments = { 
			'bodybags_bag',
			'grenade_crate',
			'ammo_bag',
			'health_bag',
		}
		local reserve_mission_element = managers.preplanning.reserve_mission_element
		for type,array in pairs(managers.preplanning._mission_elements_by_type) do
			for _,element in pairs(array) do
				if contains(equipments, type) then
					type = equipments[random(2, #equipments)]
				end
				reserve_mission_element(managers.preplanning, type, element:id())
			end
		end
	end
	managers.mission._fading_debug_output:script().log(string.format("Assets ACTIVATED"), Color.green)
end

local function escape()
	if Network:is_server() then else 
		managers.chat:_receive_message(1, "Escape", "Host only!", tweak_data.system_chat_color)
		return
	end
	global_escape_timer_toggle = global_escape_timer_toggle or false
	if not global_escape_timer_toggle then
		if not global_no_esc_timer then global_no_esc_timer = ElementPointOfNoReturn.on_executed end
		function ElementPointOfNoReturn:on_executed()	end
		if not global_no_esc_timer2 then global_no_esc_timer2 = GroupAIStateBase._update_point_of_no_return end
		function GroupAIStateBase:_update_point_of_no_return(t, dt) return end
		managers.mission._fading_debug_output:script().log(string.format("Escape Timer ACTIVATED"), Color.green)
	else
		if global_no_esc_timer then ElementPointOfNoReturn.on_executed = global_no_esc_timer end
		if global_no_esc_timer2 then GroupAIStateBase._update_point_of_no_return = global_no_esc_timer2 end
		managers.mission._fading_debug_output:script().log(string.format("Escape Timer DEACTIVATED"), Color.red)
	end
	global_escape_timer_toggle = not global_escape_timer_toggle
end

local function force_start()
	if Network:is_server() then else 
		managers.chat:_receive_message(1, "ForceStart", "Host only!", tweak_data.system_chat_color)
		return
	end
	if game_state_machine and in_game() and not is_playing() then
		game_state_machine:current_state():start_game_intro()
		managers.chat:send_message(ChatManager.GAME, local_peer, "The game was forced to start.")
	end
end

local host_win_game = function(win_or_lose)
	if win_or_lose == "win" then
		if managers.platform:presence() == "Playing" then
			local num_winners = managers.network:session():amount_of_alive_players()
			managers.network:session():send_to_peers( "mission_ended", true, num_winners )
			game_state_machine:change_state_by_name( "victoryscreen", { num_winners = num_winners, personal_win = alive( managers.player:player_unit() ) } )
		end
	elseif win_or_lose == "lose" then
		if managers.platform:presence() == "Playing" then
			local num_winners = managers.network:session():amount_of_alive_players()
			managers.network:session():send_to_peers( "mission_ended", false, num_winners )
			game_state_machine:change_state_by_name( "gameoverscreen", { num_winners = num_winners, personal_win = true } )
		end
	end
end

local run_events = function(event)
	if not is_playing() then return end
	local player = managers.player:player_unit()
	if not player or not alive(player) then
		return
	end
	for _, script in pairs(managers.mission:scripts()) do
		for _, element in pairs(script:elements()) do
			if element._editor_name == event then
				if Network:is_server() then
					element:on_executed(player)
				else
					CommandManager:vis("event", element._id, player)
				end
			end
		end
	end
	managers.mission._fading_debug_output:script().log(string.format("Event: %s ACTIVATED", event),  Color.green)
end

local concealmentval = function(num, num2, num3, bool)
	tweak_data.upgrades.values.player.passive_concealment_modifier = {num}
	if bool then
		managers.mission._fading_debug_output:script().log(string.format("Concealment: %s ACTIVATED", num),  Color.green)
	elseif not bool then
		managers.mission._fading_debug_output:script().log(string.format("Concealment: %s DEACTIVATED", num),  Color.red)
	end
end

concealmentval_menu = function()
	local dialog_data = {    
		title = "Concealment Menu",
		text = "Select Option",
		button_list = {}
	}
	global_concealment_value = global_concealment_value or false
	if not global_concealment_value then
		for i=75, -25, -1 do
			table.insert(dialog_data.button_list, {
				text = i,
				callback_func = function() concealmentval(i, true) end,
			})
		end
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "------------------------- Use Scroll Wheel ------------------------",})
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() pregame_menu() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}     
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	else
		concealmentval(1, false)
	end
	global_concealment_value = not global_concealment_value
end

pregame_menu = function()
	local dialog_data = {    
		title = "Pregame Menu",
		text = "Select Option",
		button_list = {}
	}
	
	local pregame_table = {
		["input"] = {
			{ text = "Assets and Pre planning - ON", callback_func = function() assets() end },
			{ text = "No Escape timer - ON/OFF", callback_func = function() escape() end },
			{ text = "Force Start - ON", callback_func = function() force_start() end },
			{},
			{ text = "Concealment - ON/OFF", callback_func = function() concealmentval_menu() end },
			{},
			{ text = "Win - ON", callback_func = function() if is_server() then host_win_game("win") else run_events("func_endscreen_variant_001") run_events("func_mission_end_nightmare") run_events("Escape_Link") run_events("mission_end_success") run_events("func_mission_end_001") run_events("func_mission_end_002") run_events("func_mission_end") run_events("succes") run_events("success") run_events("endscreen1") run_events("mission_end") run_events("MissionEndArea") run_events("escape_victory") run_events("you_win") end end },
			{ text = "Lose - ON", callback_func = function() if is_server() then host_win_game("lose") else run_events("to_server_mission_element_trigger") end end },
		}
	}
	
	local pregame_array = "input"
	if pregame_table[pregame_array] then
		for _, dostuff in pairs(pregame_table[pregame_array]) do
			if pregame_table[pregame_array] then
				table.insert(dialog_data.button_list, dostuff)
			end
		end
	end
	
	table.insert(dialog_data.button_list, {})
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}     
	table.insert(dialog_data.button_list, no_button) 
	managers.system_menu:show_buttons(dialog_data)
end
pregame_menu()