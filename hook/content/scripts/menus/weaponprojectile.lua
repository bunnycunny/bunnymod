toggle_projectile = toggle_projectile or false
if not toggle_projectile then

	if not global_shotfired then global_shotfired = StatisticsManager.shot_fired end
	local shot_fired = StatisticsManager.shot_fired
	function StatisticsManager:shot_fired( data )
		if not data.weapon_unit or not data.name_id then
			return
		end

		return shot_fired( self, data )
	end

	if not global_toggle_wep_proj then global_toggle_wep_proj = RaycastWeaponBase._fire_raycast end
	function RaycastWeaponBase:_fire_raycast( user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul )
		local throw_proj = ProjectileBase.throw_projectile
		local mvec_spread_direction = direction * 5

		if Network:is_client() then
			managers.network:session():send_to_host( "request_throw_projectile", 2, from_pos, mvec_spread_direction )
		else
			if not from_pos or mvec_spread_direction then return end
			throw_proj('frag', from_pos, mvec_spread_direction, managers.network:session():local_peer():id())
		end
	end
	managers.mission._fading_debug_output:script().log(string.format("asd"), Color.red)
else
	managers.mission._fading_debug_output:script().log(string.format("asd"), Color.green)
	if global_shotfired then StatisticsManager.shot_fired = global_shotfired end
	if global_toggle_wep_proj then RaycastWeaponBase._fire_raycast = global_toggle_wep_proj end
end
toggle_projectile = not toggle_projectile