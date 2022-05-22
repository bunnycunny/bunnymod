function PlayerManager:_attempt_tag_team()
	local player = managers.player:player_unit()
	local player_eye = player:camera():position()
	local player_fwd = player:camera():rotation():y()
	local tagged = nil
	local heisters_slot_mask = World:make_slot_mask(1, 2, 3, 4, 5, 11, 16, 24, 39)
	local cone_camera = player:camera():camera_object()
	local cone_center = Vector3(0, 0)
	local cone_radius = managers.player:upgrade_value("player", "tag_team_base").radius
	local tag_distance = managers.player:upgrade_value("player", "tag_team_base").distance * 100
	local heisters = World:find_units("camera_cone", cone_camera, cone_center, cone_radius, tag_distance, heisters_slot_mask)
	local best_dot = -1

	for _, heister in ipairs(heisters) do
		local heister_center = heister:oobb():center()
		local heister_dir = heister_center - player_eye
		local distance_pass = mvector3.length_sq(heister_dir) <= tag_distance * tag_distance
		local raycast = nil

		if distance_pass then
			mvector3.normalize(heister_dir)

			local heister_dot = Vector3.dot(player_fwd, heister_dir)

			if best_dot < heister_dot then
				best_dot = heister_dot
				raycast = World:raycast(player_eye, heister_center)
				tagged = raycast and raycast.unit:in_slot(heisters_slot_mask) and heister
			end
		end
	end

	if not tagged or self._coroutine_mgr:is_running("tag_team") then
		return false
	end

	self:add_coroutine("tag_team", PlayerAction.TagTeam, tagged, player)

	return true
end