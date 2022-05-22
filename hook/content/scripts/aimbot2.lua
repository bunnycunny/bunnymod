--auto shoot
if active then
	managers.chat:feed_system_message(ChatManager.GAME, "Turn off auto shoot/aim first!")
	return
end

if not managers.player then return end
if not rawget(_G, "aimbot_shot") then
	rawset(_G, "aimbot_shot", {
		["toggle_s"] = false
	})

	aimbot_shot.instant_hit = false
	aimbot_shot.silent_gun = true
	aimbot_shot.turret_data = "@ID1326760"
	aimbot_shot.pl_cam_pos = managers.player:player_unit():camera():position()

	function aimbot_shot:get_safe_ray()
		aimbot_shot.mvecTo = Vector3()
		mvector3.set(aimbot_shot.mvecTo, managers.player:player_unit():camera():rotation():y())
		mvector3.multiply(aimbot_shot.mvecTo, 999999)
		mvector3.add(aimbot_shot.mvecTo, aimbot_shot.pl_cam_pos)
		aimbot_shot.enemy_table ={
			"sentry_gun",
			"enemies",
		}
		for _, enemies in pairs(aimbot_shot.enemy_table) do
			aimbot_shot.ray = World:raycast("ray", aimbot_shot.pl_cam_pos, aimbot_shot.mvecTo, "slot_mask", managers.slot:get_mask(enemies))
			aimbot_shot.ray_unit = self.ray and self.ray.unit
			if self.ray_unit and alive(self.ray_unit) then
				aimbot_shot.in_slot = self.ray_unit:in_slot(managers.slot:get_mask(enemies))
				if self.in_slot then
					return self.ray
				end
			end
		end
		return nil
	end

	function aimbot_shot:hit_target()
		aimbot_shot.equipped_unit_base = managers.player:player_unit():inventory():equipped_unit():base()
		aimbot_shot.ammo = self.equipped_unit_base:ammo_info()
		
		if not self.silent_gun then
			managers.rumble:play("weapon_fire")
			self.equipped_unit_base:_fire_sound()
			SoundDevice:create_source("fire") --check
		end
		
		if self.equipped_unit_base:get_ammo_remaining_in_clip() <= 1 then
			self.equipped_unit_base:replenish()
		end
		
		if self.equipped_unit_base:get_ammo_total() <= 0 then
			return
		end
		
		if self.instant_hit then
			if not global_toggle_hit_backup then global_toggle_hit_backup = RaycastWeaponBase._get_current_damage end
			function RaycastWeaponBase:_get_current_damage(dmg_mul)
				return math.huge
			end
		end
		
		self.equipped_unit_base:trigger_held(aimbot_shot.pl_cam_pos, managers.player:player_unit():camera():forward(), self.equipped_unit_base:damage_multiplier(), nil, 0, 0, 0)
		managers.player:player_unit():camera():play_shaker("fire_weapon_rot", 1)
		managers.player:player_unit():camera():play_shaker("fire_weapon_kick", 1, 1, 0.15)
		self.equipped_unit_base:tweak_data_anim_play("fire", 20)
		managers.hud:set_ammo_amount(self.equipped_unit_base:selection_index(), self.equipped_unit_base:ammo_info())
	end

	function aimbot_shot:auto_shoot()
		for _,data in pairs(managers.enemy:all_enemies()) do
			aimbot_shot.unit_as = data.unit
			if self.unit_as and not (self.unit_as:brain():surrendered() and self.unit_as:brain()._logic_data.is_tied) and self:get_safe_ray() then
				self:hit_target()
				break
			end
		end
		
		for _, x in pairs(World:find_units_quick('all')) do
			aimbot_shot.id = string.sub(x:name():t(), 1, 10)
			if self.id == self.turret_data then
				if x and self:get_safe_ray() then
					self:hit_target()
					break
				end
			end
		end
	end

	function aimbot_shot:start_aimbot_shot()
		if not alive(managers.player:player_unit()) then
			return
		end
		
		for _,selection in pairs(managers.player:player_unit():inventory()._available_selections) do
			selection.unit:base().old_mask = selection.unit:base()._bullet_slotmask
			selection.unit:base()._bullet_slotmask = World:make_slot_mask(7, 8, 11, 12, 14, 16, 17, 18, 21, 22, 25, 26, 33, 34, 35)
		end

		BetterDelayedCalls:Add("aimbot_shoot_loop_id_1", 0.3, function()
			managers.player:player_unit():inventory():equipped_unit():base():play_tweak_data_sound("stop_fire")
			--PlayerStandard:_is_reloading() and not PlayerStandard:_is_meleeing()
			if not Input:keyboard():down(Idstring("r"):id()) and not Input:keyboard():down(Idstring("e"):id()) and not Input:mouse():down(Idstring("0"):id()) and not Input:mouse():down(Idstring("1"):id()) and not Input:mouse():down(Idstring("2"):id()) and not Input:mouse():down(Idstring("3"):id()) then
			--if not (managers.menu:get_controller():get_input_bool("primary_attack") and managers.menu:get_controller():get_input_bool("secondary_attack") and managers.menu:get_controller():get_input_pressed("reload") and managers.menu:get_controller():get_input_pressed("switch_weapon")) then
				self:auto_shoot()
			end
		end, true)
	end

	function aimbot_shot:_toggle()
		if not self["toggle_s"] then
			managers.mission._fading_debug_output:script().log('Aimbot (Shoot) - ACTIVATED', Color.green)
			self:start_aimbot_shot()
		else
			BetterDelayedCalls:Remove("aimbot_shoot_loop_id_1")
			managers.player:player_unit():inventory():equipped_unit():base()._sound_fire:stop()
			if not godmodeextra then
				if global_toggle_hit_backup then RaycastWeaponBase._get_current_damage = global_toggle_hit_backup end
			end
			managers.mission._fading_debug_output:script().log('Aimbot (Shoot) - DEACTIVATED', Color.red)
		end
		self["toggle_s"] = not self["toggle_s"]
	end
	aimbot_shot:_toggle()
else
	aimbot_shot:_toggle()
end