local bypass_chance = false

if SentryGunWeapon then

	if CommandManager.config["sentry_crit"] then
		math.randomseed(os.time())
		function SentryGunWeapon:crit_chance()
			local peer_id = managers.network:session():local_peer():id() or 1
			local unit = self._unit
			local interaction = (alive(unit) and (unit['interaction'] ~= nil)) and unit:interaction()
			if interaction and (interaction._owner_id == peer_id) then
				local name = managers.blackmarket:equipped_armor()
				local detection_risk = managers.blackmarket:get_suspicion_offset_from_custom_data({armors = name}, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
				detection_risk = math.round(detection_risk * 100)
				local detection_risk_add_crit_chance = managers.player:upgrade_value("player", "detection_risk_add_crit_chance")
				local chance = managers.player:get_value_from_risk_upgrade(detection_risk_add_crit_chance, detection_risk)
				
				if managers.player:has_category_upgrade("player", "unseen_increased_crit_chance") and managers.player:has_activate_temporary_upgrade("temporary", "unseen_strike") then
					local data = managers.player:upgrade_value("player", "unseen_increased_crit_chance", 0)
					if data ~= 0 then
						chance = (chance + data.crit_chance) - 1
					end
				end
				local rng = math.random(100)/100
				if (not bypass_chance and rng <= chance) or bypass_chance then
					local crit_damage = managers.player:critical_hit_chance(detection_risk)
					return crit_damage
				end
			end
			return 1
		end

		function SentryGunWeapon:_apply_dmg_mul(damage, col_ray, from_pos)
			local damage_out = damage * self._current_damage_mul

			if tweak_data.weapon[self._name_id].DAMAGE_MUL_RANGE then
				local ray_dis = col_ray.distance or mvector3.distance(from_pos, col_ray.position)
				local ranges = tweak_data.weapon[self._name_id].DAMAGE_MUL_RANGE
				local i_range = nil

				for test_i_range, range_data in ipairs(ranges) do
					if ray_dis < range_data[1] or test_i_range == #ranges then
						i_range = test_i_range

						break
					end
				end

				if i_range == 1 or ranges[i_range][1] < ray_dis then
					damage_out = damage_out * ranges[i_range][2]
				else
					local dis_lerp = (ray_dis - ranges[i_range - 1][1]) / (ranges[i_range][1] - ranges[i_range - 1][1])
					damage_out = damage_out * math.lerp(ranges[i_range - 1][2], ranges[i_range][2], dis_lerp)
				end
			end
			return damage_out * self:crit_chance()
		end
	end
end