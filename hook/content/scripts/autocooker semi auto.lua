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
	global_semi_auto_hook = global_semi_auto_hook or false
	if not global_semi_auto_hook then
		global_semi_auto_toggle_hook = true
		managers.mission._fading_debug_output:script().log(tostring'Semi Auto - ACTIVATED',  Color.green)
	else
		global_semi_auto_toggle_hook = false
		managers.mission._fading_debug_output:script().log(tostring'Semi Auto - DEACTIVATED',  Color.red)
	end
	global_semi_auto_hook = not global_semi_auto_hook
else
	managers.chat:_receive_message(1, "COOKER - SEMI", "Enable Autocooker First", tweak_data.system_chat_color)
end