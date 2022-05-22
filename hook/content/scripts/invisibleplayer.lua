local mod_name = "invisible player attention"
local not_exist = not rawget(_G, mod_name)
local c = not_exist and rawset(_G, mod_name, {toggle = false}) and _G[mod_name] or _G[mod_name]
if not_exist then
	function c:update_invisible_state(state)
		managers.player:player_unit():movement():set_attention_settings(state)
	end
	
	Hooks:PostHook(HUDManager, "update", mod_name.."1", function()
		if c.toggle then
			pcall(c.update_invisible_state, c, {"pl_civilian"})
		else
			Hooks:RemovePostHook(class_name)
			pcall(c.update_invisible_state, c, {"pl_mask_on_foe_combatant_whisper_mode_stand", "pl_mask_on_foe_combatant_whisper_mode_crouch"})
		end
	end)
	
	function c:toggle_mod()
		if not Utils:IsInHeist() then
			pcall(managers.mission._fading_debug_output:script().log, "In heist only!", Color.red)
		end
		self.toggle = not self.toggle
		pcall(managers.mission._fading_debug_output:script().log, string.format("%s: %s", mod_name, (self.toggle and "Activated" or "Deactivated")), (self.toggle and Color.green or Color.red))
	end
end
c:toggle_mod()
