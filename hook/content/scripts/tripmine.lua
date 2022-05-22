if not Network.is_server(Network) then
	if managers.hud and (managers.player:player_unit()) then
		managers.player:clear_equipment()
		managers.player._equipment.selections = {}
		managers.player:add_equipment({ silent = true, equipment = "trip_mine" })
	end
	managers.mission._fading_debug_output:script().log(string.format("Trip Mines - Equiped"), Color.green)
else
	local from = managers.player:player_unit():movement():m_head_pos()
	local to = from + managers.player:player_unit():movement():m_head_rot():y() * 10000
	local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
	if ray then
		local pos = ray.position
		local unit2 = managers.player:player_unit()
		local sensor_upgrade = managers.player:has_category_upgrade( "trip_mine", "sensor_toggle" )
		local rot = Rotation( ray.normal, math.UP )
		local unit = TripMineBase.spawn( pos, rot, sensor_upgrade )
		unit:base():set_active( true, unit2 )
	end
	managers.mission._fading_debug_output:script().log('Tripmine spawn ACTIVATED', Color.green)
end