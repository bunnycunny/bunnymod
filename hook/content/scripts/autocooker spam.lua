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
if global_toggle_meth and global_announce and global_semi_auto then
	global_spam_ac = global_spam_ac or false
	if not global_spam_ac then
		global_anti_spam_toggle = true
		managers.mission._fading_debug_output:script().log(tostring'Less Spam In Chat - ACTIVATED',  Color.green)
		managers.chat:_receive_message(1, "COOKER - SPAM", "Does not work well with 'Cook Faster' mod", tweak_data.system_chat_color)
	else
		global_anti_spam_toggle = false
		global_anti_spam = false
		managers.mission._fading_debug_output:script().log(tostring'Less Spam In Chat - DEACTIVATED',  Color.red)
	end
	global_spam_ac = not global_spam_ac
else
	managers.chat:_receive_message(1, "COOKER - SPAM", "Enable Autocooker, Announcement And Semi Auto First", tweak_data.system_chat_color)
end