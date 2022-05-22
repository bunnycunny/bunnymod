function is_playing() -- Is playing check
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine.last_queued_state_name(game_state_machine) ]
end
if not is_playing() then
	return
end

global_fireeff = global_fireeff or false
if not global_fireeff then
	player_movement_effect_func = function(name_id, effect_string)
		if not _playermovupd then _playermovupd = PlayerMovement.update end
		local _f_PlayerMovement_update = PlayerMovement.update
		local _last_t = 0
		local _id = 0
		function PlayerMovement:update(unit, t, dt)
			_f_PlayerMovement_update(self, unit, t, dt)
			if self._current_state_name == "standard" and self._m_pos and t > _last_t then
				_last_t = t + 0.2
				local params = {}
				local current_effect_param = effect_string or "effects/payday2/particles/character/taser_thread"
				params.effect = Idstring(current_effect_param)
				params.position = self._m_pos
				params.rotation = Rotation(0, 0, 0)
				params.base_time = 15
				params.random_time = 3
				params.max_amount = 10
				_id = _id + 1
				if _id > 10 then
					_id = 1
				end
				local _idx = self._unit:id() .. "_" .._id
				managers.environment_effects:spawn_mission_effect(_idx, params)
			end
		end
		managers.mission._fading_debug_output:script().log(string.format("Effect %s ACTIVATED", name_id), Color.green)
	end

	effecttable = {
		["effects"] = {
			{ text = "Molotov", callback_func = function() player_movement_effect_func("Molotov", "effects/payday2/particles/explosions/molotov_grenade") end },
			{ text = "Flamethrower", callback_func = function() player_movement_effect_func("Flamethrower", "effects/payday2/particles/explosions/flamethrower") end },
			{ text = "Smoke", callback_func = function() player_movement_effect_func("Smoke", "effects/payday2/particles/weapons/grenade_smoke_trail") end },
			{ text = "Taser", callback_func = function() player_movement_effect_func("Taser", "effects/payday2/particles/character/taser_thread") end },
			{ text = "Sparks", callback_func = function() player_movement_effect_func("Sparks", "effects/payday2/particles/impacts/sparks/sparks_partical_random") end },
			{ text = "Nothing", callback_func = function() player_movement_effect_func("Nothing", "") end },
		},
	}

	local effect_menu = function()
		local dialog_data = {    
			title = "Effect Menu",
			text = "Select Option",
			button_list = {}
		}

		local effect_list = "effects"
		if effecttable[effect_list] then
			for _, dostuff in pairs(effecttable[effect_list]) do
				if effecttable[effect_list] then
					table.insert(dialog_data.button_list, dostuff)
					table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
				end
			end
		end

		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() magic_menu() end,})
		table.insert(dialog_data.button_list, { text = managers.localization:text("dialog_cancel"), focus_callback_func = function () end, cancel_button = true }) 
		managers.system_menu:show_buttons(dialog_data)
	end
	effect_menu()
else
	if _playermovupd then PlayerMovement.update = _playermovupd end
	managers.mission._fading_debug_output:script().log(string.format("Effect DEACTIVATED"), Color.red)
end
global_fireeff = not global_fireeff