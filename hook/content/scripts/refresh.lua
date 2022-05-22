local function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[game_state_machine:last_queued_state_name()]
end

local function in_chat()
	if managers.hud._chat_focus == true then
		return true
	end
	if (managers.network.account and managers.network.account._overlay_opened) then
		return true
	end
	return false
end

if not is_playing() and not in_chat() then
	return
end

if alive(managers.player:player_unit()) then
	--health, ammo
	managers.player:player_unit():base():replenish()
	--player state
	managers.player:set_player_state('standard')
	--body bags
	managers.player:add_body_bags_amount(3)
	--cable tie
	if (managers.player._global.synced_cable_ties[managers.network:session():local_peer():id()].amount < 5) then
		managers.player:add_special({name = "cable_tie", silent = true, amount = 1})
	end
	if managers.hud then
		--granade amount/timers
		local timer = managers.player._timers.replenish_grenades
		if timer then
			managers.player:speed_up_grenade_cooldown(timer.t)
		end
		managers.player:add_grenade_amount(3)
		--deployable
		if Network:is_server() then
			managers.player:clear_equipment()
			managers.player._equipment.selections = {}
			managers.player:add_equipment({silent = true, equipment = managers.player:equipment_in_slot(1), slot = 1})
			if managers.player:has_category_upgrade("player", "second_deployable") then
				managers.player:add_equipment({silent = true, equipment = managers.player:equipment_in_slot(2), slot = 2})
			end
	   end
	end
else
	IngameWaitingForRespawnState.request_player_spawn()
end