if CommandManager.config["trainer_melee_damage_buffs"] then
	for _,wep in pairs(tweak_data.blackmarket.melee_weapons) do
		if wep then
			wep.special_weapon = "taser"
			--wep.stats.concealment = 30 --def 30
			--wep.min_damage = 3 --def 2-7
			--wep.max_damage = 8 --def 2-45
			wep.charge_time = 2 --def 1-4
			wep.stats.range = 1000 --def 150-250
			wep.dot_data = {
				type = "poison",
				custom_data = {
					dot_length = 3.1,
					hurt_animation_chance = 1
				}
			}
			wep.fire_dot_data = {
				dot_trigger_chance = "100",
				dot_damage = "10",
				dot_length = "3.1",
				dot_trigger_max_distance = "3000",
				dot_tick_period = "0.5"
			}
		end
	end
end