if CommandManager.config["show_experience_hud"] then
	return
end

local previous_total_xp = 0

local function get_current_total_xp()
	local num_alive_players = managers.network:session():amount_of_alive_players()
	return managers.experience:get_xp_dissected(true, num_alive_players, true)
end

local function xp_string(xp)
	return managers.experience:experience_string(xp)
end

local orig_func_mission_xp_award = ExperienceManager.mission_xp_award
function ExperienceManager.mission_xp_award(self, amount)
	previous_total_xp = get_current_total_xp()
	
	orig_func_mission_xp_award(self, amount)
	
	local new_total_xp = get_current_total_xp()
	local xp_added = new_total_xp - previous_total_xp
	local notification_text = string.format("%s XP gained (Total XP: %s)", xp_string(xp_added), xp_string(new_total_xp))
	managers.hud:show_hint({ text = notification_text })
end