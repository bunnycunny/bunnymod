-- Lobotomize all AI
local function toggle_ai_state(state)
	local state = not state
	for u_key, u_data in pairs(managers.enemy:all_enemies()) do
		u_data.unit:brain():set_active(state)
	end
	for u_key, u_data in pairs(managers.enemy:all_civilians()) do
		u_data.unit:brain():set_active(state)
	end
	for _,unit in pairs(SecurityCamera.cameras) do
		if unit:base()._last_detect_t ~= nil then
			unit:base():set_update_enabled(state)
		end
	end
end

local function bug_fix()
	function CopBrain:set_followup_objective( followup_objective )
		if not self._logic_data.objective then return end
		local old_followup = self._logic_data.objective.followup_objective
		self._logic_data.objective.followup_objective = followup_objective
		if followup_objective and followup_objective.interaction_voice then
			self._unit:network():send( "set_interaction_voice", followup_objective.interaction_voice )
		elseif old_followup and old_followup.interaction_voice then
			self._unit:network():send( "set_interaction_voice", "" )
		end
	end
end

local function patch_ai()
	--freeze update
	if not global_toggle_set_logic then global_toggle_set_logic = CopBrain.set_logic end
	orig_logic = CopBrain.set_logic
	function CopBrain:set_logic(name, enter_params)
		local r = orig_logic(self, name, enter_params)
		self:set_active( false )
		return r
	end
	
	if not global_toggle_set_init_logic then global_toggle_set_init_logic = CopBrain.set_init_logic end
	orig_init_logic = CopBrain.set_init_logic
	function CopBrain:set_init_logic(name, enter_params)
		local r = orig_init_logic(self, name, enter_params)
		self:set_active( false )
		return r
	end
end

global_stop_lobo = false
freezeall = freezeall or false
if not freezeall then
	if Network:is_server() then
		toggle_ai_state( true )
		bug_fix()
		patch_ai()
	else
		local run_persist_lobo_client = function()
			local enemy_data
			if managers.groupai:state():whisper_mode() then
				enemy_data = "idle"--"e_sp_loop_aim_shout"
			else
				enemy_data = "e_sp_loop_aim_shout"
			end
			if not enemy_data then return end
			local civ_data = "cm_sp_dj_loop"
			for u_key, u_data in pairs(managers.enemy:all_enemies()) do
				u_data.unit:play_redirect(Idstring(enemy_data))
				managers.network:session():send_to_peers("play_distance_interact_redirect", u_data.unit, enemy_data)
			end
			for u_key, u_data in pairs(managers.enemy:all_civilians()) do
				u_data.unit:play_redirect(Idstring(civ_data))
				managers.network:session():send_to_peers("play_distance_interact_redirect", u_data.unit, civ_data)
			end
		end
		if not global_stop_lobo then
			BetterDelayedCalls:Add("weird_lobo_client", 0.01, function()
				run_persist_lobo_client()
			end, true)
		end
	end
	managers.mission._fading_debug_output:script().log('Freeze - ACTIVATED', Color.green)
else
	if Network:is_server() then
		if global_toggle_set_logic then CopBrain.set_logic = global_toggle_set_logic end
		if global_toggle_set_init_logic then CopBrain.set_init_logic = global_toggle_set_init_logic end
		toggle_ai_state( false )
	else
		BetterDelayedCalls:Remove("weird_lobo_client")
		global_stop_lobo = true
	end
	managers.mission._fading_debug_output:script().log('Freeze - DEACTIVATED', Color.red)
end
freezeall = not freezeall
