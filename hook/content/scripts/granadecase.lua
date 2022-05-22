if not Network:is_server() then
	return
end
-- give granade
local from = managers.player:player_unit():movement():m_head_pos()
local to = from + managers.player:player_unit():movement():m_head_rot():y() * 10000
local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
if ray then
	local pos = ray.position
	local rot = Rotation(managers.player:player_unit():camera():rotation():yaw(), 0, 0)
	World:spawn_unit(Idstring("units/payday2/equipment/gen_equipment_grenade_crate/gen_equipment_grenade_crate"), pos, rot)
end
managers.mission._fading_debug_output:script().log('Granade Case Spawn ACTIVATED', Color.green)