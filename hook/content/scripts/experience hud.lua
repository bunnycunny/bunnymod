if not CommandManager.config["show_experience_hud"] then
	return
end

local function get_total_xp()
	local num_alive_players = managers.network:session():amount_of_alive_players()
	return managers.experience:get_xp_dissected(true, num_alive_players, true)
end

local function xp_string(xp)
	return managers.experience:experience_string(xp)
end

local function update_hud(t, dt)
	local total_xp = xp_string(get_total_xp())
	local text = string.format("Total Experience: %s", total_xp)
	if managers.groupai and managers.groupai:state() then 
		PlayerManager.posText:set_color(managers.groupai:state()._hunt_mode and Color(1,0,0) or managers.groupai:state()._enemy_weapons_hot and Color(255,215,0) or managers.groupai:state()._whisper_mode and Color("4ca6ff") or Color("f5973b"))
	else
		PlayerManager.posText:set_color(Color(255,215,0))
	end
	PlayerManager.posText:set_text(text)
end

local function persist_exp()
	BetterDelayedCalls:Add("mission_xp_award_id", 1, function() 
		if PlayerManager.positionpanel then
			update_hud()
		end
	end, true)
end

local orig_func_mission_xp_award = ExperienceManager.mission_xp_award
function ExperienceManager.mission_xp_award(self, amount)
	orig_func_mission_xp_award(self, amount)
	if not PlayerManager.positionpanel and managers.hud then
		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
		if hud then
			PlayerManager.positionpanel = hud.panel:panel({
				name = "positionpanel",
				visible = true,
				w = 400,
				h = 100,
				color = Color.green
			})
			PlayerManager.posText_bg = HUDBGBox_create(PlayerManager.positionpanel, {
				w = 300,
				h = 24
			}, {
				visible = true,
				blend_mode = "add"
			})
			PlayerManager.posText = PlayerManager.posText_bg:text({
				name = "textname",
				text = "Total Experience: ",
				font = tweak_data.hud_corner.assault_font,
				font_size = tweak_data.hud.name_label_font_size,
				color = Color.green,
				valign = "center",
				align = "center",
				vertical = "center",
				layer = 1,
				w = PlayerManager.posText_bg:w(),
				h = PlayerManager.posText_bg:h(),
				x = 0,
				y = 0
			})
			PlayerManager.positionpanel:set_left(PlayerManager.positionpanel:left() + 500)
			update_hud()
			persist_exp()
		end
	end
end