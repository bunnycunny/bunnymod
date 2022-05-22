local orig_func_init_pd2_values = UpgradesTweakData._init_pd2_values
function UpgradesTweakData:_init_pd2_values()
	orig_func_init_pd2_values(self)
	--graze
	self.values.snp.graze_damage = {
		{radius = 300,damage_factor = 0.2,damage_factor_headshot = 0.2},
		{radius = 300,damage_factor = 1,damage_factor_headshot = 1}
	}

	--burglar
	--self.values.player.pick_lock_speed_multiplier = {0.2}
	self.values.player.alarm_pager_speed_multiplier = {0.75}
	self.values.player.player_corpse_dispose_speed_multiplier = {0.1}
	--drillsawgeant
	if Network:is_server() then
		self.values.player.drill_speed_multiplier = {0.3,0.3}
	end
	if CommandManager.config["trainer_buffs"] then
	--inspire
	self.values.cooldown.long_dis_revive = {{1,1}}
	--anarchist
	self.values.temporary.armor_break_invulnerable = {{2, 5}}
	self.values.player.armor_grinding = {{
		{1,2},
		{2,3},
		{4,6},
		{5.5,7},
		{6.5,8},
		{7.5,9},
		{8.5,10}
	}}
	--no skill
	self.values.player.passive_concealment_modifier = {3}
	self.values.player.pick_lock_easy_speed_multiplier = {0.25} --deff0.25
	--fully loaded
	self.values.player.regain_throwable_from_ammo = {{chance = 1, chance_inc = 100}}
	--parkour
	self.values.player.movement_speed_multiplier = { 1.2, 1.3, 1.4 }
	--frenzy
	self.values.player.health_damage_reduction = {0.9,0.55}
	--bullseye
	self.values.player.headshot_regen_armor_bonus = {0.5,2.5}
	--cleaner
	self.values.player.extra_corpse_dispose_amount = {99}
	self.values.player.corpse_dispose_amount = {5,5}
	end
	
	if CommandManager.config["perk_buff"] then
	--sociopath
		self.values.player.melee_kill_life_leech = {10}
	--infiltrator
		self.values.temporary.melee_life_leech = {{100,200}}
	--crew chief, armorer, sociopath
		--self.values.player.tier_armor_multiplier = {1.15,1.2,1.25,1.3,1.35,1.4}
	--crew chief
		-- Brute Strength
		self.values.team.damage_dampener.team_damage_reduction = { 0.90 } --0.92 is (1.00-0.92)*100%=8%damage reduction for crew, default {0.92) %
		self.values.player.passive_damage_reduction = { 0.5 } --% health required to double damage reduction
		-- Wolf Pack
		self.values.team.health.passive_multiplier = { 1.5 } --1.1 is 10% more health for crewmates, default 1.1
		-- Testudo
		self.values.team.armor.multiplier = { 1.5 } --1.05 is 5% more armor for crewmates, dafault 1.05
		-- Hostage Situation
		self.values.team.health.hostage_multiplier = { 1.25 } --1.06 is 6% more health for the whole crew, default 1.06
		self.values.team.stamina.hostage_multiplier = { 1.90 } --1.12 is 12% more stamine for the whole crew, default 1.12
	--maniac perk
		self.cocaine_stacks_dmg_absorption_value = 0.25
		self.cocaine_stacks_decay_t = 10
		self.cocaine_stacks_decay_amount_per_tick = 60
		self.values.player.sync_cocaine_stacks = {true}
	end
	--no skill
	--self.values.player.passive_concealment_modifier = {15, 20, 25}
	if CommandManager.config["armor_buff"] then
		--iron man
		self.values.player.armor_multiplier = {7}
		self.values.player.body_armor.armor	= {5, 10, 20, 30, 40, 50, 60} -- Default = { 0, 3, 4, 5, 7, 9, 15 }
	end
	self.values.player.body_armor.damage_shake = {0, 0, 0, 0, 0, 0, 0} -- Default = { 1, 0.96, 0.92, 0.85, 0.8, 0.7, 0.5 }

	if CommandManager.config["sentry_buffs"] then
	--sentry
	self.values.sentry_gun.shield = {true}
	self.values.sentry_gun.less_noisy = {true}
	self.values.sentry_gun.can_revive = {true}
	self.values.sentry_gun.can_reload = {true}
	self.values.sentry_gun.armor_piercing_chance = {100} --100%
	self.values.sentry_gun.rot_speed_multiplier = {2}
	self.values.sentry_gun.spread_multiplier = {2} --def 2
	self.values.sentry_gun.armor_multiplier = {20.0} --def 1.25
	self.values.sentry_gun.armor_piercing_chance_2 = {100} --def 0.05
	self.values.sentry_gun.quantity = {1,5}
	--self.values.sentry_gun.extra_ammo_multiplier = {5}
	--self.sentry_gun_base_ammo = 100 --host only
	--self.sentry_gun_base_armor = 300 --host side
	--self.values.sentry_gun.armor_multiplier = {6.5} --health host side
	end
end