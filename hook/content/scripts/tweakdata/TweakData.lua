Arrows_and_Throwable = { 
	"elastic_arrow", "elastic_arrow_poison", 
	"elastic_arrow_exp", "ecp_arrow", 
	"ecp_arrow_poison", "ecp_arrow_exp", 
	"long_arrow_exp", "long_poison_arrow", 
	"long_arrow", "frankish_arrow_exp", 
	"frankish_poison_arrow", "frankish_arrow", 
	"wpn_prj_four", "wpn_prj_ace", 
	"wpn_prj_jav", "wpn_prj_hur",
	"wpn_prj_target", "arblast_arrow", 
	"arblast_poison_arrow", "arblast_arrow_exp", 
	"west_arrow", "west_arrow_exp", 
	"bow_poison_arrow", "crossbow_arrow", 
	"crossbow_poison_arrow", "crossbow_arrow_exp"
}
grenades = { 
	"smoke_screen_grenade", "dada_com",
	"frag_com", "dynamite", 
	"fir_com", "molotov", 
	"frag", "launcher_frag"
}
fire_poison_mod = { 
	"fir_com", "molotov",
	"crossbow_poison_arrow", "bow_poison_arrow",
	"arblast_poison_arrow", "frankish_poison_arrow",
	"long_poison_arrow", "ecp_arrow_poison",
	"elastic_arrow_poison"
}

if CommandManager.config["trainer_buffs"] and tweak_data then
	for _, projectile in pairs(tweak_data.blackmarket:get_projectiles_index() or {}) do
		if type(projectile) == "string" and projectile:lower():match("arrow") and type(tweak_data.projectiles[projectile]) == "table" then
			tweak_data.projectiles[projectile].no_cheat_count = true
			tweak_data.projectiles[projectile].launch_speed = (tweak_data.projectiles[projectile].launch_speed or 2000) * 1.6
		end
	end
	for _, projectile in ipairs(grenades) do
		if projectile == "smoke_screen_grenade" then
			tweak_data.projectiles[projectile].duration = 60
			tweak_data.projectiles[projectile].dodge_chance = 1
		end
		tweak_data.projectiles[projectile].no_cheat_count = true
		tweak_data.projectiles[projectile].damage = 2000
		if not tweak_data.projectiles[projectile].launch_speed then
			tweak_data.projectiles[projectile].launch_speed = 500
		end
		if tweak_data.projectiles[projectile].player_damage then
			tweak_data.projectiles[projectile].player_damage = tweak_data.projectiles[projectile].player_damage - 10
		end
	end
	for _, projectile in ipairs(fire_poison_mod) do
		if tweak_data.projectiles[projectile].fire_dot_data then
			tweak_data.projectiles[projectile].fire_dot_data.dot_trigger_chance = tweak_data.projectiles[projectile].fire_dot_data.dot_trigger_chance * 4
			tweak_data.projectiles[projectile].fire_dot_data.dot_damage = tweak_data.projectiles[projectile].fire_dot_data.dot_damage * 4
			tweak_data.projectiles[projectile].fire_dot_data.dot_lenght = 6
			tweak_data.projectiles[projectile].fire_dot_data.dot_tick_period = 0.1
		end
	end
	if tweak_data.projectiles.chico_injector then
		tweak_data.projectiles.chico_injector.base_cooldown = 5
	end
end
