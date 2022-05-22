function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end
if not is_playing() then 
	return
end

local function _activate_element( unit, name )
    if unit:damage() and unit:damage():has_sequence( name ) then
        unit:damage():run_sequence_simple( name ) 
		managers.network:session():send_to_peers_synched("run_mission_door_sequence", unit, name)
		managers.network:session():send_to_peers_synched("run_mission_door_device_sequence", unit, name)
		--managers.network:session():send_to_peers_synched("run_spawn_unit_sequence", unit, "spawn_manager", unit:id(), name)
    end
	managers.mission._fading_debug_output:script().log(string.format("%s - ACTIVATED - %s", name, unit), Color.green)
end

local function allelem()
	local from = managers.player:player_unit():movement():m_head_pos()
	local to = from + managers.player:player_unit():movement():m_head_rot():y() * 10000
	local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
	if not ray or not ray.unit then
		return
	end
	local elem = ray.unit.damage and ray.unit:damage() and ray.unit:damage()._unit_element
	if not elem then
		return
	end
	local elements = elem._sequence_elements
	for id in pairs( elements ) do
		for i = 1, 2 do
			_activate_element(ray.unit, id)
		end
	end
end

local function crosshair_menu()
	local dialog_data = {    
		title = "Crosshair Menu",
	    text = "Select Option",
		button_list = {}
	}
	local from = managers.player:player_unit():movement():m_head_pos()
	local to = from + managers.player:player_unit():movement():m_head_rot():y() * 10000
	local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
	if not ray or not ray.unit then
		return
	end
	local elem = ray.unit.damage and ray.unit:damage() and ray.unit:damage()._unit_element
	if not elem then
		return
	end
	local elements = elem._sequence_elements
	for id in pairs( elements ) do
		table.insert(dialog_data.button_list, {
			text = id,
			callback_func = function() _activate_element(ray.unit, id) end, 
		})
		table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )			
    end
	
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "------------------------- Use Scroll Wheel ------------------------",})
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {
		text = "Activate All Crosshair Single Element",        
		callback_func = function () allelem() end,        
	})
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}     
	table.insert(dialog_data.button_list, no_button)
	managers.system_menu:show_buttons(dialog_data)
end     
crosshair_menu()

