local CTD_init_missions = CrimeSpreeTweakData.init_missions
function CrimeSpreeTweakData:init_missions(tweak_data)
	CTD_init_missions(self,tweak_data)
	if CommandManager.config["trainer_buffs"] then
		global_cs_value = 12
		local debug_short_add = global_cs_value
		local debug_med_add = global_cs_value
		local debug_long_add = global_cs_value
		for i,v in pairs(self.missions) do
			for i2,v in pairs(self.missions[i]) do
				if self.missions[i][i2].add then
					self.missions[i][i2].add = global_cs_value
				end
			end
		end
	end
	--managers.mission._fading_debug_output:script().log(string.format("Crimespree Points - %s", global_cs_value), Color.green)
end

local CTD_init_missions2 = CrimeSpreeTweakData.init_modifiers
function CrimeSpreeTweakData:init_modifiers(tweak_data)
	CTD_init_missions2(self,tweak_data)
	if CommandManager.config["trainer_buffs"] then
		if Network:is_server() then
			local health_increase = 25
			local damage_increase = 25
			self.max_modifiers_displayed = 5
			self.modifier_levels = {
				loud = 2000,
				forced = 500,
				stealth = 456
			}
		end
	end
end

local CTD_init_missions3 = CrimeSpreeTweakData.init_rewards
function CrimeSpreeTweakData:init_rewards(tweak_data)
	CTD_init_missions3(self,tweak_data)
	if CommandManager.config["trainer_buffs"] then
		self.loot_drop_reward_pay_class = 40
		local offshore_rate = tweak_data.money_manager.offshore_rate
		self.rewards = {
			{
				id = "experience",
				always_show = true,
				max_cards = 10,
				card_inc = 200000,
				name_id = "menu_challenge_xp_drop",
				icon = "upcard_xp",
				amount = 100000
			},
			{
				id = "cash",
				max_cards = 10,
				cash_string = "$",
				card_inc = 4000000,
				name_id = "menu_challenge_cash_drop",
				icon = "upcard_cash",
				always_show = true,
				amount = 1000000
			},
			{
				id = "continental_coins",
				max_cards = 5,
				card_inc = 4,
				name_id = "menu_cs_coins",
				icon = "upcard_coins",
				amount = 8
			},
			{
				id = "loot_drop",
				max_cards = 5,
				card_inc = 5,
				name_id = "menu_challenge_loot_drop",
				icon = "upcard_random",
				amount = 1
			},
			{
				id = "random_cosmetic",
				max_cards = 5,
				card_inc = 1,
				name_id = "menu_challenge_cosmetic_drop",
				icon = "upcard_cosmetic",
				amount = 10
			}
		}
		self.all_cosmetics_reward = {
			amount = 15,
			type = "continental_coins"
		}

		self.cosmetic_rewards = {
			{
				id = "cvc_green",
				type = "armor"
			},
			{
				id = "cvc_black",
				type = "armor"
			},
			{
				id = "cvc_grey",
				type = "armor"
			},
			{
				id = "cvc_tan",
				type = "armor"
			},
			{
				id = "cvc_navy_blue",
				type = "armor"
			},
			{
				id = "drm_tree_stump",
				type = "armor"
			},
			{
				id = "drm_gray_raider",
				type = "armor"
			},
			{
				id = "drm_desert_twilight",
				type = "armor"
			},
			{
				id = "drm_navy_breeze",
				type = "armor"
			},
			{
				id = "drm_woodland_tech",
				type = "armor"
			},
			{
				id = "drm_khaki_eclipse",
				type = "armor"
			},
			{
				id = "drm_desert_tech",
				type = "armor"
			},
			{
				id = "drm_misted_grey",
				type = "armor"
			},
			{
				id = "drm_khaki_regular",
				type = "armor"
			},
			{
				id = "drm_somber_woodland",
				type = "armor"
			}
		}
	end
end
--tweak_data.crime_spree.max_assets_unlocked = 999
local CTD_init_missions4 = CrimeSpreeTweakData.init_gage_assets
function CrimeSpreeTweakData:init_gage_assets(tweak_data)
	CTD_init_missions4(self,tweak_data)
	if CommandManager.config["trainer_buffs"] then
		local asset_cost = 0
		self.max_assets_unlocked = 999
		self.assets = {
			increased_health = {}
		}
		self.assets.increased_health.name_id = "menu_cs_ga_increased_health"
		self.assets.increased_health.unlock_desc_id = "menu_cs_ga_increased_health_desc"
		self.assets.increased_health.icon = "csb_health"
		self.assets.increased_health.cost = asset_cost
		self.assets.increased_health.data = {
			health = 250
		}
		self.assets.increased_health.class = "GageModifierMaxHealth"
		self.assets.increased_armor = {
			name_id = "menu_cs_ga_increased_armor",
			unlock_desc_id = "menu_cs_ga_increased_armor_desc",
			icon = "csb_armor",
			cost = asset_cost,
			data = {
				armor = 250
			},
			class = "GageModifierMaxArmor"
		}
		self.assets.increased_stamina = {
			name_id = "menu_cs_ga_increased_stamina",
			unlock_desc_id = "menu_cs_ga_increased_stamina_desc",
			icon = "csb_stamina",
			cost = asset_cost,
			data = {
				stamina = 1000
			},
			class = "GageModifierMaxStamina"
		}
		self.assets.increased_ammo = {
			name_id = "menu_cs_ga_increased_ammo",
			unlock_desc_id = "menu_cs_ga_increased_ammo_desc",
			icon = "csb_ammo",
			cost = asset_cost,
			data = {
				ammo = 100
			},
			class = "GageModifierMaxAmmo"
		}
		self.assets.increased_lives = {
			name_id = "menu_cs_ga_increased_lives",
			unlock_desc_id = "menu_cs_ga_increased_lives_desc",
			icon = "csb_lives",
			cost = asset_cost,
			data = {
				lives = 6
			},
			class = "GageModifierMaxLives"
		}
		self.assets.increased_throwables = {
			name_id = "menu_cs_ga_increased_throwables",
			unlock_desc_id = "menu_cs_ga_increased_throwables_desc",
			icon = "csb_throwables",
			cost = asset_cost,
			data = {
				throwables = 200
			},

			class = "GageModifierMaxThrowables"
		}
		self.assets.increased_deployables = {
			name_id = "menu_cs_ga_increased_deployables",
			unlock_desc_id = "menu_cs_ga_increased_deployables_desc",
			icon = "csb_deployables",
			cost = asset_cost,
			data = {
				deployables = 100
			},
			class = "GageModifierMaxDeployables"
		}
		self.assets.increased_absorption = {
			name_id = "menu_cs_ga_increased_absorption",
			unlock_desc_id = "menu_cs_ga_increased_absorption_desc",
			icon = "csb_absorb",
			cost = asset_cost,
			data = {
				absorption = 5
			},
			class = "GageModifierDamageAbsorption"
		}
		self.assets.quick_reload = {
			name_id = "menu_cs_ga_quick_reload",
			unlock_desc_id = "menu_cs_ga_quick_reload_desc",
			icon = "csb_reload",
			cost = asset_cost,
			data = {
				speed = 50
			},
			class = "GageModifierQuickReload"
		}
		self.assets.quick_switch = {
			name_id = "menu_cs_ga_quick_switch",
			unlock_desc_id = "menu_cs_ga_quick_switch_desc",
			icon = "csb_switch",
			cost = asset_cost,
			data = {
				speed = 70
			},
			class = "GageModifierQuickSwitch"
		}
		self.assets.melee_invulnerability = {
			name_id = "menu_cs_ga_melee_invulnerability",
			unlock_desc_id = "menu_cs_ga_melee_invulnerability_desc",
			icon = "csb_melee",
			cost = asset_cost,
			data = {
				time = 5
			},
			class = "GageModifierMeleeInvincibility"
		}
		self.assets.explosion_immunity = {
			name_id = "menu_cs_ga_explosion_immunity",
			unlock_desc_id = "menu_cs_ga_explosion_immunity_desc",
			icon = "csb_explosion",
			cost = asset_cost,
			data = {},
			class = "GageModifierExplosionImmunity"
		}
		self.assets.life_steal = {
			name_id = "menu_cs_ga_life_steal",
			unlock_desc_id = "menu_cs_ga_life_steal_desc",
			icon = "csb_lifesteal",
			cost = asset_cost,
			data = {
				cooldown = 1,
				armor_restored = 0.50,
				health_restored = 0.50
			},
			class = "GageModifierLifeSteal"
		}
		self.assets.quick_pagers = {
			name_id = "menu_cs_ga_quick_pagers",
			unlock_desc_id = "menu_cs_ga_quick_pagers_desc",
			icon = "csb_pagers",
			cost = asset_cost,
			data = {
				speed = 90
			},
			stealth = true,
			class = "GageModifierQuickPagers"
		}
		self.assets.increased_body_bags = {
			name_id = "menu_cs_ga_increased_body_bags",
			unlock_desc_id = "menu_cs_ga_increased_body_bags_desc",
			icon = "csb_bodybags",
			cost = asset_cost,
			data = {
				bags = 10
			},
			stealth = true,
			class = "GageModifierMaxBodyBags"
		}
		self.assets.quick_locks = {
			name_id = "menu_cs_ga_quick_locks",
			unlock_desc_id = "menu_cs_ga_quick_locks_desc",
			icon = "csb_locks",
			cost = asset_cost,
			data = {
				speed = 50
			},
			stealth = true,
			class = "GageModifierQuickLocks"
		}
	end
end

local CTD_init_missions5 = CrimeSpreeTweakData.init
function CrimeSpreeTweakData:init(tweak_data)
	CTD_init_missions5(self,tweak_data)
	if CommandManager.config["trainer_buffs"] then
		self.unlock_level = 0
		self.base_difficulty = "sm_wish"
		self.base_difficulty_index = 6
		self.initial_cost = 0
		self.cost_per_level = 0.1
		self.randomization_cost = 0
		self.randomization_multiplier = 0
		self.catchup_bonus = 0.035
		self.winning_streak = 0.005
		self.continue_cost = {
			1,
			0.7
		}
	end
	self.allow_highscore_continue = true
	self.winning_streak_reset_on_failure = false
	self.crash_causes_loss = false
end