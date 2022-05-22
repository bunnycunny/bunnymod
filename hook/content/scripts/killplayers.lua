function get_peers(code, unitcheck)
	local peerid = tonumber(code)
	local me = managers.network:session():local_peer():id()
	if not peerid or peerid and (peerid < 1 or peerid > 4) then
		local tab = {}
		for x = 1, 4 do
			if managers.network:session():peer(x) then
				if not (unitcheck or unitcheck and managers.network:session():peer(x):unit()) then
					table.insert(tab, x)
				end
			end
		end
		if code == "*" then -- everyone
			return tab
		elseif code == "?" then -- random
			peerid = tab[math.random(1, #tab)]
		elseif code == "!" then -- anyone except self
			table.remove(tab, me)
			peerid = tab[math.random(1, #tab)]
		else -- self
			peerid = me
		end

		tab = nil
	end
	if peerid and managers.network:session():peer(peerid) then
		if not unitcheck or (unitcheck and managers.network:session():peer(peerid):unit()) then
			return {peerid}
		end
	end
	return
end

CommandManager:vis("kill_players")

local killplayers = function(state)
	if managers.player and alive( managers.player:player_unit() ) then
		managers.player:set_player_state("bleed_out")
		local player = get_peers('*')
		if player then
			for _, id in pairs(player) do
				local peer = managers.network:session():peer(id)
				local unit = peer:unit()
				local network = unit:network()
				local send = network.send
				send(network, "sync_player_movement_state", "standard", 0, id )
				send(network, "sync_player_movement_state", state, 0, id )
				send(network, "set_health", 0)
				network:send_to_unit( { "spawn_dropin_penalty", true, nil, 0, nil, nil } )
				managers.groupai:state():on_player_criminal_death( id )
			end
			for _, data in pairs(managers.criminals:characters()) do
				if data.data.ai and alive(data.unit) then
					data.unit:character_damage():clbk_exit_to_dead()
				end
			end
		end
		managers.mission._fading_debug_output:script().log('Kill Players ACTIVATED',  Color.green)
	end
end
killplayers("incapacitated")