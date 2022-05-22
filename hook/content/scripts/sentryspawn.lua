if Network:is_server() then
	tweak_data.upgrades.values.sentry_gun.quantity = {0,0}
	if managers.hud and (managers.player:player_unit()) then
		managers.player:clear_equipment()
		managers.player._equipment.selections = {}
		managers.player:add_equipment({ silent = true, equipment = "sentry_gun" })
	end

	local from = managers.player:player_unit():movement():m_head_pos()
	local to = from + managers.player:player_unit():movement():m_head_rot():y() * 10000
	local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
	if ray then
		local pos = ray.position
		local rot = Rotation(managers.player:player_unit():camera():rotation():yaw(), 0, 0)
		local shield = managers.player:has_category_upgrade( "sentry_gun", "shield" )
		local sentry_gun_unit = SentryGunBase.spawn(managers.player:player_unit(), pos, rot)
		if not sentry_gun_unit then return end
		managers.network:session():send_to_peers_synched("from_server_sentry_gun_place_result", managers.network:session():local_peer():id(), 1, sentry_gun_unit, sentry_gun_unit:movement()._rot_speed_mul, sentry_gun_unit:weapon()._setup.spread_mul, shield)
		managers.mission._fading_debug_output:script().log('Sentry spawn ACTIVATED', Color.green)
	end
else
	tweak_data.upgrades.values.sentry_gun.quantity = {99,99}
	if managers.hud and (managers.player:player_unit()) then
		managers.player:clear_equipment()
		managers.player._equipment.selections = {}
		managers.player:add_equipment({ silent = true, equipment = "sentry_gun" })
	end
	managers.mission._fading_debug_output:script().log(string.format("Sentry Gun - Equiped"), Color.green)
end