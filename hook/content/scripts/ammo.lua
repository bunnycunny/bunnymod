tweak_data.upgrades.values.ammo_bag.ammo_increase = {128}
if Network:is_server() then
	local from = managers.player:player_unit():movement():m_head_pos()
	local to = from + managers.player:player_unit():movement():m_head_rot():y() * 10000
	local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
	if ray then
		local pos = ray.position
		local rot = Rotation(managers.player:player_unit():camera():rotation():yaw(), 0, 0)
		local amount_upgrade_lvl = managers.player:upgrade_level( "ammo_bag", "amount_increase" )
		AmmoBagBase.spawn( pos, rot, amount_upgrade_lvl )
		managers.mission._fading_debug_output:script().log('Ammo Spawn ACTIVATED', Color.green)
	end
else
	if managers.hud and (managers.player:player_unit()) then
		managers.player:clear_equipment()
		managers.player._equipment.selections = {}
		managers.player:add_equipment({ silent = true, equipment = "ammo_bag" })
	end
	managers.mission._fading_debug_output:script().log(string.format("Ammo Bag - Equiped"), Color.green)
end