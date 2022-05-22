--kingpin
local auto_use_king_flash = true

--stoic
local auto_use_stoic_flash = true 			--auto uses stoic flask at 45% of remaining armor when damage over time is active
local damage_over_time_percentage = 0.45	--percentage of when flask will be used. Lower meaning later flask use value between 0 and 1
local prevent_miss_press = true				--set to true so you cant use stoic flask when damage over time is not active





--kingpin
if PlayerDamage then
	local orig_func_update = PlayerDamage.update
	function PlayerDamage.update(self, ...)
		if managers.player:has_category_upgrade("temporary", "chico_injector") and not managers.player:has_category_upgrade("player", "damage_control_passive") then
			if auto_use_king_flash then
				if self:get_real_armor() < 2 and self:get_real_armor() >= 0 and managers.player:can_throw_grenade() then
					managers.player:attempt_ability("chico_injector")
				end
			end
		end
		orig_func_update(self, ...)
	end
	
	local orig_func_max_armor = PlayerDamage._max_armor
	function PlayerDamage:_max_armor(...)
		if CommandManager.config["custom_stoic"] then
			local max_armor = self:_raw_max_armor()
			if managers.player:has_category_upgrade("player", "armor_to_health_conversion") then
				pre_max_health = self:_raw_max_health() + max_armor
				max_armor = pre_max_health
			end

			return max_armor
		end
		return orig_func_max_armor(self, ...)
	end

	local orig_func_max_health = PlayerDamage._max_health
	function PlayerDamage:_max_health(...)
		if CommandManager.config["custom_stoic"] then
			local max_health = self:_raw_max_health()
			if managers.player:has_category_upgrade("player", "armor_to_health_conversion") then
				max_health = 0.000001
			end

			return max_health
		end
		return orig_func_max_health(self, ...)
	end
end

--stoic
if LocalizationManager then
	local orig_func_LocalizationManager_init = LocalizationManager.init
	function LocalizationManager:init(...)
		orig_func_LocalizationManager_init(self, ...)
		if CommandManager.config["custom_stoic"] then
			LocalizationManager:add_localized_strings({
				["menu_deck19_3_desc"] = "All of your health is converted and applied to your armor.",
				["menu_deck19_9_desc"] = "When damage-over-time is removed you will be gaining armor for additional ##50%## of the damage-over-time remaining at that point.",
			})
		end
	end
end

if PlayerManager then
	local orig_func_attempt_ability = PlayerManager.attempt_ability
	function PlayerManager.attempt_ability(self, ...)
		local player_unit = managers.player:player_unit()
		local player_damage = player_unit:character_damage()
		local remaining = player_damage:remaining_delayed_damage()
		if (not managers.player:has_category_upgrade("player", "damage_control_passive") or managers.player:has_category_upgrade("player", "damage_control_passive") and managers.player:has_category_upgrade("temporary", "chico_injector")) then
			orig_func_attempt_ability(self, ...)
		elseif not prevent_miss_press or (remaining > 0) then
			orig_func_attempt_ability(self, ...)
		end
	end
end

if PlayerAction then
	PlayerAction.DamageControl = {
		Priority = 1,
		Function = function ()
			local timer = TimerManager:game()
			local auto_shrug_time = nil
			local cooldown_drain = managers.player:upgrade_value("player", "damage_control_cooldown_drain")
			local damage_delay_values = managers.player:has_category_upgrade("player", "damage_control_passive") and managers.player:upgrade_value("player", "damage_control_passive")
			local auto_shrug_delay = managers.player:has_category_upgrade("player", "damage_control_auto_shrug") and managers.player:upgrade_value("player", "damage_control_auto_shrug")
			local shrug_healing = managers.player:has_category_upgrade("player", "damage_control_healing") and managers.player:upgrade_value("player", "damage_control_healing") * 0.01

			if not damage_delay_values then
				return
			end

			damage_delay_values = {
				delay_ratio = damage_delay_values[1] * 0.01,
				tick_ratio = damage_delay_values[2] * 0.01
			}
			cooldown_drain = {
				health_ratio = cooldown_drain[1] * 0.01,
				seconds_below = cooldown_drain[2],
				seconds_above = managers.player:upgrade_value_by_level("player", "damage_control_cooldown_drain", 1)[2]
			}

			local function shrug_off_damage()
				local player_unit = managers.player:player_unit()

				if player_unit then
					local player_damage = player_unit:character_damage()
					local remaining_damage = player_damage:clear_delayed_damage()
					local is_downed = game_state_machine:verify_game_state(GameStateFilters.downed)
					local swan_song_active = managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier")

					if is_downed or swan_song_active then
						return
					end

					if shrug_healing then
						if CommandManager.config["custom_stoic"] then
							player_damage:restore_armor(remaining_damage * shrug_healing, true)
						else
							player_damage:restore_health(remaining_damage * shrug_healing, true)
						end
					end
				end

				auto_shrug_time = nil
			end

			local function modify_damage_taken(amount, attack_data)
				local is_downed = game_state_machine:verify_game_state(GameStateFilters.downed)

				if attack_data.variant == "delayed_tick" or is_downed then
					return
				end

				local player_unit = managers.player:player_unit()
				local player_damage = player_unit:character_damage()
				local removed = amount * damage_delay_values.delay_ratio
				local duration = 1 / damage_delay_values.tick_ratio
				local remaining = player_damage:remaining_delayed_damage()
				local armor_percentage = damage_over_time_percentage * player_damage:get_real_armor()
				
				if auto_use_stoic_flash then
					if remaining >= armor_percentage and managers.player:can_throw_grenade() then
						managers.player:attempt_ability("damage_control")
					end
				end

				player_damage:delay_damage(removed, duration)

				if auto_shrug_delay then
					auto_shrug_time = timer:time() + auto_shrug_delay
				end

				return -removed
			end

			local function on_ability_activated(ability_name)
				if ability_name == "damage_control" then
					shrug_off_damage()
				end
			end

			local function on_enemy_killed(weapon_unit, variant, enemy_unit)
				local player = managers.player:player_unit()
				local low_health = player:character_damage():health_ratio() <= cooldown_drain.health_ratio
				local seconds = low_health and cooldown_drain.seconds_below or cooldown_drain.seconds_above

				if player then
					managers.player:speed_up_grenade_cooldown(seconds)
				end
			end

			local on_check_skills_key = {}
			local on_enemy_killed_key = {}
			local on_ability_activated_key = {}

			managers.player:register_message(Message.OnEnemyKilled, on_enemy_killed_key, on_enemy_killed)
			managers.player:register_message("ability_activated", on_ability_activated_key, on_ability_activated)

			local damage_taken_key = managers.player:add_modifier("damage_taken", modify_damage_taken)

			local function remove_listeners()
				managers.player:unregister_message("check_skills", on_check_skills_key)
				managers.player:unregister_message(Message.OnEnemyKilled, on_enemy_killed_key)
				managers.player:unregister_message("ability_activated", on_ability_activated_key)
				managers.player:remove_modifier("damage_taken", damage_taken_key)
			end

			managers.player:register_message("check_skills", on_check_skills_key, remove_listeners)

			while true do
				coroutine.yield()

				local now = timer:time()

				if auto_shrug_time and auto_shrug_time <= now then
					shrug_off_damage()
				end
			end
		end
	}
end