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
	global_toggle_secure_meth = global_toggle_secure_meth or false
	if not global_toggle_secure_meth then
		secure_bagged = true
		managers.mission._fading_debug_output:script().log(tostring'Secure Meth - ACTIVATED',  Color.green)
	else
		secure_bagged = false
		managers.mission._fading_debug_output:script().log(tostring'Secure Meth - DEACTIVATED',  Color.red)
	end
	global_toggle_secure_meth = not global_toggle_secure_meth
else
	managers.chat:_receive_message(1, "COOKER - SECURE", "Enable Autocooker First", tweak_data.system_chat_color)
end