DelayedCalls:Add("bag_bodies", 0.5, function()
	local player = managers.player._players[1]
	if not alive(player) then return end
	local interactions = {}
	for _,unit in pairs(managers.interaction._interactive_units) do
		if not alive(unit) then return end
		local interaction = unit:interaction()
		if interaction and interaction.tweak_data == 'corpse_dispose' then
			local vec3 = unit:position()+Vector3(0,0,50)
			interactions[vec3] = interaction
		end
	end

	for pos, interaction in pairs(interactions) do
		interaction.can_interact = can_interact
		interaction:interact(player)
		interaction.can_interact = nil
		local name = 'person'
		local carry_data = tweak_data.carry[name]
		local throw_force = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0)
		local unit = interaction._unit
		local u_id = managers.enemy:get_corpse_unit_data_from_key(unit:key()).u_id
		if Network:is_server() then
			managers.player:server_drop_carry(name, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, pos, Rotation(0,0,0), Vector3(0,0,0), throw_force, zipline_unit, managers.network:session():local_peer())
			unit:set_slot(0)
			managers.network._session:send_to_peers_synched("remove_corpse_by_id", u_id, true)
		else
			managers.network:session():send_to_host("server_drop_carry", name, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, pos, Rotation(0,0,0), Vector3(0,0,0), throw_force, zipline_unit)
			managers.network:session():send_to_host("sync_interacted_by_id", u_id, "corpse_dispose")
		end
		managers.player:clear_carry()
	end
	managers.mission._fading_debug_output:script().log('Bag People ACTIVATED', Color.green)
end)