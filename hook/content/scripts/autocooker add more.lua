function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end

if not is_playing() then
	return
end

Color.gold = Color("FFD700")
if global_toggle_meth then
	bag_amount = bag_amount + 1
	managers.mission._fading_debug_output:script().log(tostring(bag_amount)..' More Meth - ACTIVATED',  Color.gold)
else
	managers.chat:_receive_message(1, "COOKER - MORE", "Enable Autocooker First", tweak_data.system_chat_color)
end