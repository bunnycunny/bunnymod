-- give bodybag
if Network:is_server() then
	local from = managers.player:player_unit():movement():m_head_pos()
	local to = from + managers.player:player_unit():movement():m_head_rot():y() * 10000
	local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
	if ray then
		local pos = ray.position
		local rot = Rotation(managers.player:player_unit():camera():rotation():yaw(), 0, 0)
		BodyBagsBagBase.spawn(pos, rot)
	end
	managers.player:add_body_bags_amount(3)
	managers.mission._fading_debug_output:script().log('Body Bag Case Spawned ACTIVATED', Color.green)
else
	managers.player:add_body_bags_amount(3)
	managers.mission._fading_debug_output:script().log('Body Bags Added ACTIVATED', Color.green)
end