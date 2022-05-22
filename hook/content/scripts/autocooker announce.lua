function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end

if not is_playing() then
	return
end

if global_toggle_meth then
	global_announce = global_announce or false
	if not global_announce then
		global_announce_toggle = true
		managers.mission._fading_debug_output:script().log(tostring'Announce - ACTIVATED',  Color.green)
	else
		global_announce_toggle = false
		managers.mission._fading_debug_output:script().log(tostring'Announce - DEACTIVATED',  Color.red)
	end
	global_announce = not global_announce
else
	managers.chat:_receive_message(1, "COOKER - ANNOUNCE", "Enable Autocooker First", tweak_data.system_chat_color)
end