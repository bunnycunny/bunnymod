function can_interact()
	return true
end

function ans_pager(unit)
	local player = managers.player:player_unit()
	if not player then return end
	
	unit:interaction().can_interact = can_interact
	if Network:is_server() then
		unit:interaction():interact(player)
	else
		local interactions = {}
		local interaction = unit:interaction()
		local vec3 = unit:position()
		interactions[vec3] = interaction
		for _, interaction in pairs(interactions) do
			local u_id = managers.enemy:get_corpse_unit_data_from_key(interaction._unit:key()).u_id
			managers.network:session():send_to_host("alarm_pager_interaction", u_id, interaction.tweak_data, 1) -- 1=start 2=interrupted, 3=complete
			unit:interaction():interact(player)
		end
	end
	unit:interaction().can_interact = nil
end

global_answer_pagers_toggle = global_answer_pagers_toggle or false
if not global_answer_pagers_toggle then
	BetterDelayedCalls:Add("ans_pager", 0.1, function()
		for _,unit in pairs(managers.interaction._interactive_units) do
			if not alive(unit) and not managers.groupai:state()._whisper_mode then break end
			local interaction = unit:interaction()
			if interaction and interaction.tweak_data == 'corpse_alarm_pager' then
				ans_pager(unit)
			end
		end
	end, true)
	if not managers.groupai:state()._whisper_mode then
		managers.mission._fading_debug_output:script().log(string.format("Answer Pagers - ACTIVATED"), Color.green)
	end
else
	BetterDelayedCalls:Remove("ans_pager")
	managers.mission._fading_debug_output:script().log(string.format("Answer Pagers - DEACTIVATED"), Color.red)
end
global_answer_pagers_toggle = not global_answer_pagers_toggle