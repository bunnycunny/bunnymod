--https://github.com/mwSora/payday-2-luajit-line-number/blob/master/pd2-lua/lib/tweak_data/skilltreetweakdata.lua
--https://github.com/mwSora/payday-2-luajit-line-number/blob/master/pd2-lua/lib/tweak_data/skilltreetweakdata.lua
--dont add player_passive_health_multiplier modifiers
local orig = SkillTreeTweakData.init
function SkillTreeTweakData:init(tweak_data)
    orig(self, tweak_data)
	table.insert(self.specializations,
		{
			name_id = "stels", 					
			desc_id = "stels_desc", 			
			{
			upgrades = 
			{ 		
				--stoic
				"damage_control",
				"player_damage_control_passive",
				"player_damage_control_cooldown_drain_1",
				--"player_armor_to_health_conversion",
				"player_damage_control_auto_shrug",
				"player_damage_control_cooldown_drain_2",
				"player_passive_loot_drop_multiplier",
				"player_damage_control_healing"
			},
				cost = 4000,									
				icon_xy = {2, 0},
				texture_bundle_folder = "opera",				
				name_id = "stels_1",					
				desc_id = "stels_1_desc"				
			},
			{
			upgrades = 
			{
				--kingpin
				"temporary_chico_injector_1",
				"chico_injector",
				"player_chico_preferred_target",
				"player_chico_injector_low_health_multiplier",
			--"player_passive_health_multiplier_1",
				"player_chico_injector_health_to_speed"					
			},
				cost = 4500,
				icon_xy = {1, 4},
				name_id = "menu_deckall_2_stels",
				desc_id = "menu_deckall_2_desc_stels"
			},
			{	
			upgrades = 
			{
				--tag team
				"tag_team",
				"player_tag_team_base",
				"player_tag_team_cooldown_drain_1",
				"player_tag_team_damage_absorption",
			--"player_passive_health_multiplier_2",
				"player_tag_team_cooldown_drain_2",
				--[[gambler
				"player_loose_ammo_restore_health_give_team",
				"temporary_loose_ammo_restore_health_1",
				"temporary_loose_ammo_restore_health_2",
				"temporary_loose_ammo_restore_health_3",
				"temporary_loose_ammo_give_team",
				"player_gain_life_per_players"--]]
			},
				cost = 5500,
				icon_xy = {0, 4},
				name_id = "stels_2",
				desc_id = "stels_2_desc"						
			},
			{
			upgrades = 
			{
				--sicario
				"smoke_screen_grenade",
				"player_dodge_shot_gain",
				"player_dodge_replenish_armor",
				"player_smoke_screen_ally_dodge_bonus",
				"player_sicario_multiplier"
			},
				cost = 7000,
				icon_xy = {3, 0},
				name_id = "menu_deckall_4_stels",
				desc_id = "menu_deckall_4_desc_stels"
			},		
			{
			upgrades = 
			{
				--hacker
				"pocket_ecm_jammer",
				"player_pocket_ecm_jammer_base",
			--"player_passive_health_multiplier_3",
			--"player_passive_health_multiplier_4",
				"player_pocket_ecm_heal_on_kill_1",
				"player_pocket_ecm_kill_dodge_1",
				"team_pocket_ecm_heal_on_kill_1",
				--"player_passive_dodge_chance_2"
			},
				cost = 10000,
				icon_xy = {1, 0},
				name_id = "stels_3",
				desc_id = "stels_3_desc"
			},
			{
			upgrades = 
			{
				--crew chief
				"team_damage_reduction_1",
				"player_passive_damage_reduction_1",
				"player_damage_dampener_close_contact_1",
				"team_passive_health_multiplier",
				"player_tier_armor_multiplier_1",
				"team_passive_armor_multiplier",
				"team_hostage_health_multiplier",
				"team_hostage_stamina_multiplier",
				"team_hostage_damage_dampener_multiplier"
			},
				cost = 15000,
				icon_xy = {5, 0},
				name_id = "menu_deckall_6_stels",
				desc_id = "menu_deckall_6_desc_stels"
			},		
			{
			upgrades = 
			{
				--burglar
				"player_stand_still_crouch_camouflage_bonus_1",
				"player_tier_dodge_chance_2",
				"player_stand_still_crouch_camouflage_bonus_2",
				"player_pick_lock_speed_multiplier",
				"player_tier_dodge_chance_3",
				"player_stand_still_crouch_camouflage_bonus_3",
				"player_alarm_pager_speed_multiplier",
				"player_armor_regen_timer_stand_still_multiplier",
				"player_crouch_speed_multiplier_2"					
			},
				cost = 20000,
				icon_xy = {4, 2},
				name_id = "stels_4",
				desc_id = "stels_4_desc"
			},
			{
			upgrades = 
			{
				--maniac
				"player_killshot_close_panic_chance",
				"player_cocaine_stack_absorption_multiplier_1",
				"player_sync_cocaine_upgrade_level_1",
				"player_cocaine_stacks_decay_multiplier_1",
				"player_sync_cocaine_stacks",
				"player_cocaine_stacking_1"
			},
				cost = 30000,
				icon_xy = {7, 0},
				name_id = "menu_deckall_8_stels",
				desc_id = "menu_deckall_8_desc_stels"
			},
			{
			upgrades = 
			{	
				"weapon_passive_damage_multiplier",
				"passive_doctor_bag_interaction_speed_multiplier",
                "weapon_passive_swap_speed_multiplier_1",
				"armor_kit",
				"player_pick_up_ammo_multiplier",
				"player_corpse_dispose_speed_multiplier",
				"passive_player_xp_multiplier",
				"player_passive_suspicion_bonus",
				"player_passive_armor_movement_penalty_multiplier",
				"team_passive_stamina_multiplier_1",
				"weapon_passive_headshot_damage_multiplier",
				"player_passive_intimidate_range_mul",
				"player_alarm_pager_speed_multiplier",
				--rogue
				"weapon_passive_armor_piercing_chance",
				--grinder
				"player_armor_piercing_chance_1",
				"player_armor_piercing_chance_2"
			},
				cost = 50000,
				icon_xy = {3, 5},
				name_id = "stels_5",
				desc_id = "stels_5_desc"
			}
		}
	)
	--puts skills in perks
    -- table.insert(self.specializations[PERK][CARD], "skill_id")
	local skills = {
	--combat medic
		"temporary_revive_damage_reduction_1",
		"player_revive_damage_reduction_1",
		"player_revive_health_boost",
	--painkillers
		"player_revive_damage_reduction_level_1",
		"player_revive_damage_reduction_level_2",
	--quickfix
		"first_aid_kit_deploy_time_multiplier",
		"first_aid_kit_damage_reduction_upgrade",
	--combat doctor
		"doctor_bag_quantity",
		"doctor_bag_amount_increase1",
	--uppers
		"first_aid_kit_quantity_increase_1",
		"first_aid_kit_quantity_increase_2",
		"first_aid_kit_auto_recovery_1",
	--inspire
		"player_morale_boost",
		"player_revive_interaction_speed_multiplier",
		"cooldown_long_dis_revive",
		
	--[[--stable shot
		"player_stability_increase_bonus_1",
		"player_not_moving_accuracy_increase_bonus_1",
	--rifleman
		"weapon_enter_steelsight_speed_multiplier",
		"player_steelsight_normal_movement_speed",
		"assault_rifle_zoom_increase",
		"snp_zoom_increase",
		"smg_zoom_increase",
		"lmg_zoom_increase",
		"pistol_zoom_increase",
		"assault_rifle_move_spread_index_addend",
		"snp_move_spread_index_addend",
		"smg_move_spread_index_addend",
	--marksman
		"weapon_single_spread_index_addend",
		"single_shot_accuracy_inc_1",
	--aggressive reload (dont work)
		"assault_rifle_reload_speed_multiplier",
		"smg_reload_speed_multiplier",
		"snp_reload_speed_multiplier",
		"temporary_single_shot_fast_reload_1",
	--ammo efficiency (crashes)
		"head_shot_ammo_return_1",
		"head_shot_ammo_return_2",
	--graze (dont work)
		"snp_graze_damage_1",
		"snp_graze_damage_2",--]]
		
		--causes minion mark crash
	--[[stockholm_syndrome
		"player_civ_calming_alerts",
		"player_super_syndrome_1",
	--partners in crime
		"player_minion_master_speed_multiplier",
		"player_passive_convert_enemies_health_multiplier_1",
		"player_minion_master_health_multiplier",
		"player_passive_convert_enemies_health_multiplier_2",
	--hostage taker
		"player_hostage_health_regen_addend_1",
		"player_hostage_health_regen_addend_2",--]]
		
	--overkill
		"player_overkill_damage_multiplier",
		"player_overkill_all_weapons",
		"weapon_swap_speed_multiplier",
		
		
	--resilience
		"player_armor_regen_time_mul_1",
		"player_flashbang_multiplier_1",
		"player_flashbang_multiplier_2",
	--transporter
		"carry_throw_distance_multiplier",
		"player_armor_carry_bonus_1",
	--die hard
		"player_interacting_damage_multiplier",
		"player_level_2_armor_addend",
		"player_level_3_armor_addend",
		"player_level_4_armor_addend",
	--shock and awe
		"team_armor_regen_time_multiplier",
		"player_shield_knock",
	--bullseye
		"player_headshot_regen_armor_bonus_1",
		"player_headshot_regen_armor_bonus_2",
	--iron man
		"player_armor_multiplier",
		"body_armor6",
		
	--scavanger
		"player_increased_pickup_area_1",
		"player_double_drop_1",
	--bulletstorm
		"temporary_no_ammo_cost_1",
		"temporary_no_ammo_cost_2",
	--portable saw
		"saw_secondary",
		"saw_extra_ammo_multiplier",
		"player_saw_speed_multiplier_2",
		"saw_lock_damage_multiplier_2",
	--extra lead
		"ammo_bag_quantity",
		"ammo_bag_ammo_increase1",
	--saw_massacre
		"saw_enemy_slicer",
		"saw_ignore_shields_1",
		"saw_panic_when_kill_1",
	--fully loaded
		"extra_ammo_multiplier1",
		"player_pick_up_ammo_multiplier",
		"player_pick_up_ammo_multiplier_2",
		"player_regain_throwable_from_ammo_1",
		
	--hardware expert
		"player_drill_fix_interaction_speed_multiplier",
		"player_trip_mine_deploy_time_multiplier_2",
		"player_drill_alert",
		"player_silent_drill",
		"player_drill_autorepair_1",
	--drillsawgeant
		"player_drill_speed_multiplier1",
		"player_drill_speed_multiplier2",
	--combat engineering
		"trip_mine_explosion_size_multiplier_1",
		"trip_mine_damage_multiplier_1",
	--more fire power
		"shape_charge_quantity_increase_1",
		"trip_mine_quantity_increase_1",
		"shape_charge_quantity_increase_2",
		"trip_mine_quantity_increase_2",
	--kickstarter
		"player_drill_autorepair_2",
		"player_drill_melee_hit_restart_chance_1",
	--fire trap
		"trip_mine_fire_trap_1",
		"trip_mine_fire_trap_2",
		
	--steady_grip
		"player_weapon_accuracy_increase_1",
		"player_stability_increase_bonus_2",
	--heavy_impact
		"weapon_knock_down_1",
		"weapon_knock_down_2",
	--fire_control
		"player_hip_fire_accuracy_inc_1",
		"player_weapon_movement_stability_1",
	--surefire
		"player_automatic_mag_increase_1",
		"player_ap_bullets_1",
	--lock n load
		"player_run_and_shoot_1",
		"player_automatic_faster_reload_1",
	--body_expertise
		"weapon_automatic_head_shot_add_1",
		"weapon_automatic_head_shot_add_2",
		
	--chameleon
		"player_suspicion_bonus",
		"player_sec_camera_highlight_mask_off",
		"player_special_enemy_highlight_mask_off",
		"player_mask_off_pickup",
		"player_small_loot_multiplier_1",
	--cleaner
		"player_corpse_dispose_amount_2",
		"player_extra_corpse_dispose_amount",
		"bodybags_bag_quantity",
	--sixth sense
		"player_standstill_omniscience",
		"player_buy_bodybags_asset",
		"player_additional_assets",
		"player_cleaner_cost_multiplier",
		"player_buy_spotter_asset",
	--nimble
		"player_tape_loop_duration_1",
		"player_tape_loop_duration_2",
		"player_pick_lock_hard",
		"player_pick_lock_easy_speed_multiplier",
	--ecm overdrive
		"ecm_jammer_duration_multiplier",
		"ecm_jammer_feedback_duration_boost",
		"ecm_jammer_can_open_sec_doors",
	--ecm specialist
		"ecm_jammer_quantity_increase_1",
		"ecm_jammer_duration_multiplier_2",
		"ecm_jammer_feedback_duration_boost_2",
		"ecm_jammer_affects_pagers",
		
	--duck and cover
		"player_stamina_regen_timer_multiplier",
		"player_stamina_regen_multiplier",
		"player_run_speed_multiplier",
		"player_run_dodge_chance",
	--parkour
		"player_movement_speed_multiplier",
		"player_climb_speed_multiplier_1",
		"player_can_free_run",
		"player_run_and_reload",
	--inner pockets
		"player_melee_concealment_modifier",
		"player_ballistic_vest_concealment_1",
	--shockproof
		"player_taser_malfunction",
		"player_taser_self_shock",
		"player_escape_taser_1",
	--dire need
		"player_armor_depleted_stagger_shot_1",
		"player_armor_depleted_stagger_shot_2",
	--sneaky bastard
		"player_detection_risk_add_dodge_chance_1",
		"player_detection_risk_add_dodge_chance_2",

	--trigger happy
	"pistol_stacking_hit_damage_multiplier_1",
	"pistol_stacking_hit_damage_multiplier_2",
		
	--nine_lives
		"player_bleed_out_health_multiplier",
		"player_additional_lives_1",
	--up_you_go
		"player_revived_damage_resist_1",
		"player_revived_health_regain_1",
	--running from death
		"player_temp_swap_weapon_faster_1",
		"player_temp_reload_weapon_faster_1",
		"player_temp_increased_movement_speed_1",
	--swan song
		"temporary_berserker_damage_multiplier_1",
		"temporary_berserker_damage_multiplier_2",
		"player_berserker_no_ammo_cost",
	--feign_death
		"player_cheat_death_chance_1",
		"player_cheat_death_chance_2",
	--messiah
		"player_messiah_revive_from_bleed_out_1",
		"player_recharge_messiah_1",
		
	--[[second wind
		"temporary_damage_speed_multiplier",
		"player_team_damage_speed_multiplier_send",
	--optical illusions
		"player_camouflage_bonus_1",
		"player_camouflage_bonus_2",
		"player_silencer_concealment_penalty_decrease_1",
		"player_silencer_concealment_increase_1",
	--the professional
		"weapon_silencer_recoil_index_addend",
		"weapon_silencer_enter_steelsight_speed_multiplier",
		"weapon_silencer_spread_index_addend",
	--low blow
		"player_detection_risk_add_crit_chance_1",
		"player_detection_risk_add_crit_chance_2",
	--high value target
		"player_marked_enemy_extra_damage",
		"player_marked_inc_dmg_distance_1",
		"weapon_steelsight_highlight_specials",
		"player_mark_enemy_time_multiplier",
		"player_marked_distance_mul",
	--unseen_strike
		"player_unseen_increased_crit_chance_1",
		"player_unseen_temp_increased_crit_chance_1",
		"player_unseen_increased_crit_chance_2",
		"player_unseen_temp_increased_crit_chance_2",--]]
	}
	
	local sentry_skills = {
	--third law
		"sentry_gun_cost_reduction_1",
		"sentry_gun_shield",
	--sentry targeting package
		"sentry_gun_spread_multiplier",
		"sentry_gun_rot_speed_multiplier",
		"sentry_gun_extra_ammo_multiplier_1",
	--eco sentry
		"sentry_gun_cost_reduction_2",
		"sentry_gun_armor_multiplier",
	--jack of all trades
		"deploy_interact_faster_1",
		"second_deployable_1",
	--engineering
		"sentry_gun_silent",
		"sentry_gun_ap_bullets",
		"sentry_gun_fire_rate_reduction_1",
	--tower defence
		"sentry_gun_quantity_1",
		"sentry_gun_quantity_2"
	}

	local perk_upgrade_all_skills = 1 --give upgrades to last perk card 1-5
	for _, skill in pairs(sentry_skills) do
		for k,v in pairs(self.specializations) do
			if CommandManager.config["unlock_sentry_skills"] then
				-- self.default_upgrades
				table.insert(self.specializations[k][perk_upgrade_all_skills].upgrades, skill)
			end
		end
	end
	
	for _, skill in pairs(skills) do
		for k,v in pairs(self.specializations) do
			if CommandManager.config["unlock_all_skills"] then
				--self.default_upgrades
				table.insert(self.specializations[k][perk_upgrade_all_skills].upgrades, skill)
			end
		end
	end
end