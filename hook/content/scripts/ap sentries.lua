local function hit_unit(self, col_ray, weapon_unit, user_unit, damage)
	local hit_unit = col_ray.unit
	local shield = hit_unit and hit_unit:in_slot(8) and alive(hit_unit:parent()) and hit_unit:parent()

	if shield and user_unit:base() and user_unit:base().sentry_gun then
		local owner = user_unit:base():get_owner()
		local session = managers.network:session()
		local player_unit = session and session:local_peer():unit() or managers.player:player_unit()
		if alive(owner) and owner == player_unit and shield:character_damage() and shield:character_damage().damage_bullet then
			local action_data = {
				variant = "bullet",
				damage = damage,
				weapon_unit = weapon_unit,
				attacker_unit = user_unit,
				col_ray = col_ray,
				origin = user_unit:position(),
				armor_piercing = true,
				shield_knock = false,
				knock_down = false,
				stagger = false
			}
			shield:character_damage():damage_bullet(action_data)
		end
	end
end

if InstantBulletBase then
	local orig_func_on_collision = InstantBulletBase.on_collision
	function InstantBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, ...)
		hit_unit(self, col_ray, weapon_unit, user_unit, damage)
		return orig_func_on_collision(self, col_ray, weapon_unit, user_unit, damage, ...)
	end
end