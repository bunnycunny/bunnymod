function string.startswith(String, Start)
	return string.sub(String, 1, string.len(Start)) == Start
end

function CommandManager:Drop_Carry(pos)
	local carry_data = managers.player:get_my_carry_data()
	local rotation = managers.player:player_unit():camera():rotation()
	local position = pos or managers.player:player_unit():camera():position()
	local forward = Vector3(0, 0, 0)
	if carry_data then
		if Network:is_server() then
			managers.player:server_drop_carry(carry_data.carry_id, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, 0, zipline_unit, managers.network:session():local_peer())
		else
			managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, 0, zipline_unit)
		end
		managers.hud:remove_teammate_carry_info( HUDManager.PLAYER_PANEL )
		managers.hud:temp_hide_carry_bag()
		managers.hud:remove_special_equipment("carrystacker")
		managers.player:update_removed_synced_carry_to_peers()
		managers.player:set_player_state("standard")
		managers.chat:feed_system_message(ChatManager.GAME, string.format("%s secured", carry_data.carry_id))
	end
end

function CommandManager:get_peer_list(unitcheck, ignore_local)
	local session = managers.network:session()
	local peers = {}
	for i=1, 4 do
		local peer = session:peer(i)
		if peer then
			if ignore_local and ( peer:id() == session:local_peer():id()) then
			else
				if unitcheck and (not alive(peer:unit())) then
				else
					peers[peer:id()] = peer
				end
			end
		end
	end
	return peers
end

function CommandManager:get_peer(id, unitcheck, ignore_local)
	local session = managers.network:session()
	if session then
		if tonumber(id) then
			local peer = session:peer(tonumber(id))
			if peer then
				if ( unitcheck and ( not alive(peer:unit())) )
					or (ignore_local and (peer:id() == session:local_peer():id()))
				then
				else
					return true, peer
				end
			end
		end

		-- if the peer does not exist, return a list with all availible peers
		return false, self:get_peer_list( unitcheck, ignore_local)
	end
end

function CommandManager:in_chat()
	if managers.hud and managers.hud._chat_focus == true then
		return true
	end
end

function CommandManager:in_game()
	if not game_state_machine then
		return false
	else
		return string.find(game_state_machine:current_state_name(), "game")
	end
end

function CommandManager:is_playing()
	if not BaseNetworkHandler then 
		return false
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end

function CommandManager:in_endscreen()
	if (game_state_machine:current_state_name() == "victoryscreen" or game_state_machine:current_state_name() == "gameoverscreen") then
		return true
	end
	return false
end

function CommandManager:in_lobby()
	if (game_state_machine:current_state_name() == "ingame_lobby_menu") then
		return true
	end
	return false
end

function CommandManager:in_mainmenu()
	if (game_state_machine:current_state_name() == "menu_main") then
		return true
	end
	return false
end

function can_interact()
	return true
end

function CommandManager:vis(target, data, data2, data3, data4)
	if data2 and data2 == "check" then
		local file = io.open((target and data), "r")
		if file then
			file:close()
			return true
		end
	end
	
	local path = "mods/hook/content/scripts/vis.lua"
	local file = io.open(path, "r")
    if file then
		dofile(path)
		vis:run_func(target, data, data2, data3, data4)
		file:close()
		return true
	end
end

function CommandManager:trigger_mission_element(element_id)
	local player = managers.player:player_unit()
	if not player or not alive(player) then
		return
	end

	for _, data in pairs(managers.mission._scripts) do
		for id, element in pairs(data:elements()) do
			if (id == element_id) then
				if Network:is_server() then
					element:on_executed(player)
				else
					CommandManager:vis("event", id, player)
				end
				break
			end
		end
	end
end

function CommandManager:interact(interaction_name)
	local player = managers.player:player_unit()
	if alive(player) then
		if type(interaction_name) == 'string' then
			for _, unit in pairs(managers.interaction._interactive_units) do
				if not alive(unit) then return end
				local interaction = unit:interaction()
				if interaction.tweak_data == interaction_name then
					if not equipment_toggle then
						dofile("mods/hook/content/scripts/equipment.lua")
					end
					interaction.can_interact = can_interact
					interaction:interact(player)
					interaction.can_interact = nil
					if equipment_toggle then
						dofile("mods/hook/content/scripts/equipment.lua")
					end
				end
			end
		end
	end
end

local _InteractsTable = {}
function CommandManager:interactionExists(int)
	for _, v in pairs(_InteractsTable) do
		if v == int then
			return true
		end
	end
	return
end

function CommandManager:TrackInteracts()
	for _,unit in pairs(managers.interaction._interactive_units) do
		if not alive(unit) then return end
		if not self:interactionExists(unit:interaction().tweak_data) then
			table.insert(_InteractsTable, unit:interaction().tweak_data)
		end
	end
	return _InteractsTable
end

function CommandManager:message(text, title)
	if text and type(text) == "string" then
		managers.chat:_receive_message(1, (title or "SYSTEM"), text, tweak_data.system_chat_color)
	end
end

function CommandManager:send_message(peer_id, message)
	if (not message) or (message == "") then
		return
	end

	local peer = managers.network:session():peer(peer_id)
	if peer_id == managers.network:session():local_peer():id() then 
		managers.chat:feed_system_message(ChatManager.GAME, message)
	else
		if peer then
			managers.network:session():send_to_peer(peer, "send_chat_message", 1, message)
		end
	end
end
