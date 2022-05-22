if not PlayerMaskOff then return end
function PlayerMaskOff:_update_check_actions( t, dt )
	local input = self:_get_input(t, dt, paused)
	self:_determine_move_direction()
	self:_update_throw_projectile_timers(t, input)
	self:_update_reload_timers(t, dt, input)
	self:_update_melee_timers(t, input)
	self:_update_charging_weapon_timers(t, input)
	self:_update_use_item_timers(t, input)
	self:_update_equip_weapon_timers(t, input)
	self:_update_running_timers(t)
	self:_update_zipline_timers(t, dt)
	self:_update_interaction_timers(t)
	if self._change_item_expire_t and self._change_item_expire_t <= t then
		self._change_item_expire_t = nil
	end
	if self._change_weapon_pressed_expire_t and self._change_weapon_pressed_expire_t <= t then
		self._change_weapon_pressed_expire_t = nil
	end
	self:_update_steelsight_timers(t, dt)
	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end
	self:_update_foley(t, input)
	local new_action = nil
	local anim_data = self._ext_anim
	new_action = new_action or self:_check_action_weapon_gadget(t, input)
	new_action = new_action or self:_check_action_weapon_firemode(t, input)
	new_action = new_action or self:_check_action_melee(t, input)
	new_action = new_action or self:_check_action_reload(t, input)
	new_action = new_action or self:_check_change_weapon(t, input)
	if not new_action then
		new_action = self:_check_action_primary_attack(t, input)
	end
	new_action = new_action or self:_check_action_equip(t, input)
	new_action = new_action or self:_check_use_item(t, input)
	new_action = new_action or self:_check_action_throw_projectile(t, input)
	new_action = new_action or self:_check_action_interact(t, input)
	self:_check_action_jump(t, input)
	self:_check_action_run(t, input)
	self:_check_action_ladder(t, input)
	self:_check_action_zipline(t, input)
	self:_check_action_cash_inspect(t, input)
	if not new_action then
		new_action = self:_check_action_deploy_bipod(t, input)
		new_action = new_action or self:_check_action_deploy_underbarrel(t, input)
	end
	self:_check_action_duck(t, input)
	self:_check_action_steelsight(t, input)
	self:_check_action_night_vision(t, input)
	self:_find_pickups(t)
end

function PlayerMaskOff:_check_action_run(t, input)
	if self._setting_hold_to_run and input.btn_run_release or self._running and not self._move_dir then
		self._running_wanted = false
		if self._running then
			self:_end_action_running(managers.player:player_timer():time())
			if input.btn_steelsight_state and not self._state_data.in_steelsight then
				self._steelsight_wanted = true
			end
		end
	elseif not self._setting_hold_to_run and input.btn_run_release and not self._move_dir then
		self._running_wanted = false
	elseif input.btn_run_press or self._running_wanted then
		if not self._running or self._end_running_expire_t then
			self:_start_action_running(t)
		elseif self._running and not self._setting_hold_to_run then
			self:_interupt_action_running(t)
			self:_end_action_running(managers.player:player_timer():time())
			if input.btn_steelsight_state and not self._state_data.in_steelsight then
				self._steelsight_wanted = true
			end
		end
	end
end

function PlayerMaskOff:_check_stop_shooting()
	if self._shooting then
		self._equipped_unit:base():stop_shooting()
		self._camera_unit:base():stop_shooting(self._equipped_unit:base():recoil_wait())
		local weap_base = self._equipped_unit:base()
		local fire_mode = weap_base:fire_mode()
		if fire_mode == "auto" and (not weap_base.akimbo or weap_base:weapon_tweak_data().allow_akimbo_autofire) then
			self._ext_network:send("sync_stop_auto_fire_sound", 0)
		end
		if fire_mode == "auto" and not self:_is_reloading() and not self:_is_meleeing() then
			self._unit:camera():play_redirect(self:get_animation("recoil_exit"))
		end
		self._shooting = false
		self._shooting_t = nil
		self._ext_camera:play_redirect(self:get_animation("unequip"))
		self._equipped_unit:base():tweak_data_anim_stop("equip")
		self._equipped_unit:base():tweak_data_anim_play("unequip")
	end
end

function PlayerMaskOff:_check_use_item(t, input)
	local new_action
	local action_wanted = input.btn_use_item_press
	if action_wanted then
		local action_forbidden = self._use_item_expire_t or self:_changing_weapon() or self:_interacting()
		if not action_forbidden then
			self:_start_action_state_standard( t )
		end
	end
	
	if input.btn_use_item_release then
		self:_interupt_action_start_standard()
	end
end

function PlayerMaskOff:_interupt_action_start_standard( t, input, complete )
	if self._start_standard_expire_t then
		self._start_standard_expire_t = nil
		
		managers.hud:hide_progress_timer_bar( complete )
		managers.hud:remove_progress_timer()
		
		managers.network:session():send_to_peers_loaded( "sync_teammate_progress", 3, false, "mask_on_action", 0, complete and true or false )
	end
end

function PlayerMaskOff:_start_action_state_standard( t )
	self._start_standard_expire_t = t + tweak_data.player.put_on_mask_time
	managers.hud:show_progress_timer_bar( 0, tweak_data.player.put_on_mask_time )
	managers.hud:show_progress_timer( { text = managers.localization:text( "hud_starting_heist" ), icon = nil } )
	
	managers.network:session():send_to_peers_loaded( "sync_teammate_progress", 3, true, "mask_on_action", tweak_data.player.put_on_mask_time, false )
end
function PlayerMaskOff:_update_check_actions( t, dt )
	self:_update_start_standard_timers( t )
	return PlayerMaskOff.super._update_check_actions( self, t, dt )
end
function PlayerMaskOff:_end_action_start_standard()
	self:_interupt_action_start_standard( nil, nil, true )
	
	PlayerStandard.say_line( self, "a01x_any", true )
	managers.player:set_player_state( "standard" )
		
	managers.achievment:award( "no_one_cared_who_i_was" )
end

function PlayerMaskOff:_update_start_standard_timers( t )
	if self._start_standard_expire_t then
		managers.hud:set_progress_timer_bar_width( tweak_data.player.put_on_mask_time-(self._start_standard_expire_t - t), tweak_data.player.put_on_mask_time )
		if self._start_standard_expire_t <= t then
			self:_end_action_start_standard( t )
			self._start_standard_expire_t = nil
		end
	end
end

------------------------------------------------------

function PlayerMaskOff:_check_action_reload(t, input)
	local new_action = nil
	local action_wanted = input.btn_reload_press
	if action_wanted then
		local action_forbidden = self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self._use_item_expire_t or self:_interacting() or self:_is_throwing_projectile()
		if not action_forbidden and self._equipped_unit and not self._equipped_unit:base():clip_full() then
			self:_start_action_reload_enter(t)
			self._ext_camera:play_redirect(self:get_animation("unequip"))
			self._equipped_unit:base():tweak_data_anim_stop("equip")
			self._equipped_unit:base():tweak_data_anim_play("unequip")
			new_action = true
		end
	end
	return new_action
end

function PlayerMaskOff:_end_action_running(t)
	if not self._end_running_expire_t then
		local speed_multiplier = self._equipped_unit:base():exit_run_speed_multiplier()
		self._end_running_expire_t = t + 0.4 / speed_multiplier
		self._ext_camera:play_redirect(self:get_animation("unequip"), speed_multiplier)
		self._equipped_unit:base():tweak_data_anim_stop("equip")
		self._equipped_unit:base():tweak_data_anim_play("unequip")
	end
end

function PlayerMaskOff:_do_action_melee(t, input, skip_damage)
	self._state_data.meleeing = nil
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local instant_hit = tweak_data.blackmarket.melee_weapons[melee_entry].instant
	local pre_calc_hit_ray = tweak_data.blackmarket.melee_weapons[melee_entry].hit_pre_calculation
	local melee_damage_delay = tweak_data.blackmarket.melee_weapons[melee_entry].melee_damage_delay or 0
	melee_damage_delay = math.min(melee_damage_delay, tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t)
	local primary = managers.blackmarket:equipped_primary()
	local primary_id = primary.weapon_id
	local bayonet_id = managers.blackmarket:equipped_bayonet(primary_id)
	local bayonet_melee = false
	if bayonet_id and self._equipped_unit:base():selection_index() == 2 then
		bayonet_melee = true
	end
	self._state_data.melee_expire_t = t + tweak_data.blackmarket.melee_weapons[melee_entry].expire_t
	self._state_data.melee_repeat_expire_t = t + math.min(tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t, tweak_data.blackmarket.melee_weapons[melee_entry].expire_t)
	if not instant_hit and not skip_damage then
		self._state_data.melee_damage_delay_t = t + melee_damage_delay
		if pre_calc_hit_ray then
			self._state_data.melee_hit_ray = self:_calc_melee_hit_ray(t, 20) or true
		else
			self._state_data.melee_hit_ray = nil
		end
	end
	local send_redirect = instant_hit and (bayonet_melee and "melee_bayonet" or "melee") or "melee_item"
	if instant_hit then
		managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, send_redirect)
	else
		self._ext_network:send("sync_melee_discharge")
	end
	if self._state_data.melee_charge_shake then
		self._ext_camera:shaker():stop(self._state_data.melee_charge_shake)
		self._state_data.melee_charge_shake = nil
	end
	self._melee_attack_var = 0
	if instant_hit then
		local hit = skip_damage or self:_do_melee_damage(t, bayonet_melee)
		if hit then
			self._ext_camera:play_redirect(bayonet_melee and self:get_animation("melee_bayonet") or self:get_animation("melee"))
		else
			self._ext_camera:play_redirect(bayonet_melee and self:get_animation("melee_miss_bayonet") or self:get_animation("melee_miss"))
		end
	else
		local state = self._ext_camera:play_redirect(self:get_animation("melee_attack"))
		local anim_attack_vars = tweak_data.blackmarket.melee_weapons[melee_entry].anim_attack_vars
		self._melee_attack_var = anim_attack_vars and math.random(#anim_attack_vars)
		self:_play_melee_sound(melee_entry, "hit_air", self._melee_attack_var)
		local melee_item_tweak_anim = "attack"
		local melee_item_prefix = ""
		local melee_item_suffix = ""
		local anim_attack_param = anim_attack_vars and anim_attack_vars[self._melee_attack_var]
		if anim_attack_param then
			self._camera_unit:anim_state_machine():set_parameter(state, anim_attack_param, 1)
			melee_item_prefix = anim_attack_param .. "_"
		end
		if self._state_data.melee_hit_ray and self._state_data.melee_hit_ray ~= true then
			self._camera_unit:anim_state_machine():set_parameter(state, "hit", 1)
			melee_item_suffix = "_hit"
		end
		melee_item_tweak_anim = melee_item_prefix .. melee_item_tweak_anim .. melee_item_suffix
		self._camera_unit:base():play_anim_melee_item(melee_item_tweak_anim)
	end
	self._ext_camera:play_redirect(self:get_animation("unequip"))
	self._equipped_unit:base():tweak_data_anim_stop("equip")
	self._equipped_unit:base():tweak_data_anim_play("unequip")
end

if CommandManager.config.double_jump then
	local _f_PlayerStandard_check_action_jump = PlayerStandard._check_action_jump
	local _jump_in_air_times = 9999
	local _jump_in_air_used = 0
	function PlayerStandard:_check_action_jump(t, input)
		if input and input.btn_jump_press and self._state_data and not self._state_data.in_air then
			_jump_in_air_used = 1
		end

		if input and input.btn_jump_press and self._jump_t and _jump_in_air_used < _jump_in_air_times then		
			_jump_in_air_used = _jump_in_air_used + 1
			local _tmp_t = self._jump_t
			local _tmp_bool = self._state_data.in_air
			self._jump_t = 0
			self._state_data.in_air = false
			local _result = _f_PlayerStandard_check_action_jump(self, t, input)
			self._jump_t = _tmp_t
			self._state_data.in_air = _tmp_bool
			return _result
		end
		return _f_PlayerStandard_check_action_jump(self, t, input)
	end

	function PlayerMaskOff:_check_action_jump( t, input )
		if input and input.btn_jump_press and self._state_data and not self._state_data.in_air then
			_jump_in_air_used = 1
		end

		if input and input.btn_jump_press and self._jump_t and _jump_in_air_used < _jump_in_air_times then	
			_jump_in_air_used = _jump_in_air_used + 1
			local _tmp_t = self._jump_t
			local _tmp_bool = self._state_data.in_air
			self._jump_t = 0
			self._state_data.in_air = false
			local _result = _f_PlayerStandard_check_action_jump(self, t, input)
			self._jump_t = _tmp_t
			self._state_data.in_air = _tmp_bool
			return _result
		end
		return _f_PlayerStandard_check_action_jump(self, t, input)
	end
end

function PlayerMaskOff:_check_action_duck( t, input )
	if self._setting_hold_to_duck and input.btn_duck_release then
		if self._state_data.ducking then
			self:_end_action_ducking( t )
		end
	elseif input.btn_duck_press then
		if not self._unit:base():stats_screen_visible() then
			if not self._state_data.ducking then
				self:_start_action_ducking( t )
			elseif self._state_data.ducking then
				self:_end_action_ducking( t )
			end
		end
	end
end

function PlayerMaskOff:_can_stand()
	local offset = 50
	local radius = 30
	local hips_pos = self._obj_com:position() + math.UP * offset
	local up_pos = math.UP * (160-offset)
	
	mvector3.add( up_pos, hips_pos )
	local ray = World:raycast( "ray", hips_pos, up_pos , "slot_mask",  self._slotmask_gnd_ray, "ray_type", "body mover", "sphere_cast_radius", radius, "bundle", 20 )
	if ray then
		managers.hint:show_hint( "cant_stand_up", 2 )
		return false
	end
	return true
end

function PlayerMaskOff:_start_action_ducking( t )
	if self:_interacting() then
		return
	end
	
	self._state_data.ducking = true
	self:_stance_entered()
	
	local velocity = self._unit:mover():velocity()
	
	self._unit:kill_mover()
	self._unit:activate_mover( Idstring( "duck" ), velocity )
	self._ext_network:send( "set_pose", 2 )
end

function PlayerMaskOff:_end_action_ducking( t )
	if not self:_can_stand() then
		return
	end
	
	self._state_data.ducking = false
	self:_stance_entered()
	
	local velocity = self._unit:mover():velocity()
	
	self._unit:kill_mover()
	self._unit:activate_mover( PlayerStandard.MOVER_STAND, velocity )
	self._ext_network:send( "set_pose", 1 )	--stand
end

function PlayerMaskOff:_interupt_action_ducking( t )
	if self._state_data.ducking then
		self:_end_action_ducking( t )
	end
end

function PlayerMaskOff:_stance_entered( unequipped )
	local stance_standard = tweak_data.player.stances.default[ managers.player:current_state() ] or tweak_data.player.stances.default.standard
	local head_stance = self._state_data.ducking and tweak_data.player.stances.default.crouched.head or stance_standard.head
	
	local weapon_id
	local stance_mod = { translation = Vector3( 0,0,0 ) }
	
	if not unequipped then
		weapon_id = self._equipped_unit:base():get_name_id()
		
		if self._state_data.in_steelsight then
			stance_mod = (self._equipped_unit:base().stance_mod and self._equipped_unit:base():stance_mod()) or stance_mod
		end
	end
		
	local stances = tweak_data.player.stances[ weapon_id ] or tweak_data.player.stances.default
	local misc_attribs = 	(self._state_data.in_steelsight and stances.steelsight) or (self._state_data.ducking and stances.crouched or stances.standard)
	local duration = tweak_data.player.TRANSITION_DURATION + (self._equipped_unit:base():transition_duration() or 0)
	local duration_multiplier = self._state_data.in_steelsight and 1/self._equipped_unit:base():enter_steelsight_speed_multiplier() or 1
	
	local new_fov = self:get_zoom_fov( misc_attribs ) + 0
	self._camera_unit:base():clbk_stance_entered( misc_attribs.shoulders, head_stance, misc_attribs.vel_overshot, new_fov, misc_attribs.shakers, stance_mod, duration_multiplier, duration )
	
	managers.menu:set_mouse_sensitivity( new_fov < (misc_attribs.FOV or 75) )
end

function PlayerMaskOff:_do_action_intimidate(t, interact_type, sound_name, skip_alert)
	if sound_name then
		self._intimidate_t = t
		self:say_line(sound_name, skip_alert)

		if interact_type and not self:_is_using_bipod() then
			self:_play_distance_interact_redirect(t, interact_type)
		end
	end
end

function PlayerMaskOff:_play_distance_interact_redirect(t, variant)
	managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, variant)
	if self._state_data.in_steelsight then
		return
	end
	if self._shooting or not self._equipped_unit:base():start_shooting_allowed() then
		return
	end
	if self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self._use_item_expire_t then
		return
	end
	if self._running then
		return
	end
	self._state_data.interact_redirect_t = t + 1
	self._ext_camera:play_redirect(Idstring(variant))
end

if not SystemFS:exists("mods/Advanced Movement Standalone/mod.txt") then
	local SLIDE_DURATION = 0.95 -- Max slide duration in seconds
	local SLIDE_SPEED_MULTIPLIER = 1.1 -- Speed multiplier
	local VELOCITY_THRESHOLD = 400 -- Minimum movement speed required for slide to trigger 400def

	local enter_original = PlayerStandard.enter
	local _start_action_ducking_original = PlayerStandard._start_action_ducking
	local _end_action_ducking_original = PlayerStandard._end_action_ducking
	local _update_foley_original = PlayerStandard._update_foley
	local _determine_move_direction_original = PlayerStandard._determine_move_direction
	local _get_max_walk_speed_original = PlayerStandard._get_max_walk_speed
	local update_original = PlayerStandard.update

	function PlayerStandard:enter(...)
		self:_stop_slide()
		return enter_original(self, ...)
	end

	function PlayerStandard:_start_action_ducking(...)
		if not managers.groupai:state()._whisper_mode and self._running and self._move_dir and not self._state_data.in_air then
			self:_start_slide()
		end
		return _start_action_ducking_original(self, ...)
	end

	function PlayerStandard:_end_action_ducking(...)
		self:_stop_slide()
		return _end_action_ducking_original(self, ...)
	end

	function PlayerStandard:_update_foley(...)
		if not managers.groupai:state()._whisper_mode and self._gnd_ray and self._state_data.in_air and not self._state_data.on_ladder and self._state_data.ducking then
			self:_start_slide(true)
		end
		return _update_foley_original(self, ...)
	end

	function PlayerStandard:_determine_move_direction(...)
		_determine_move_direction_original(self, ...)
		if self._slide_expire then
			self._move_dir = self._slide_dir
		end
	end

	function PlayerStandard:_get_max_walk_speed(...)
		return self._slide_speed or _get_max_walk_speed_original(self, ...)
	end

	function PlayerStandard:update(t, dt, ...)
		update_original(self, t, dt, ...)
		if self._slide_expire then
			self._slide_expire = self._slide_expire - dt
			if self._slide_expire <= 0 then
				self:_stop_slide()
			end
		end
	end

	local slide_dir = Vector3()
	function PlayerStandard:_start_slide(from_air)
		if not self._slide_expire then
			mvector3.set(slide_dir, self._last_velocity_xy)
			local speed = mvector3.normalize(slide_dir) * SLIDE_SPEED_MULTIPLIER
			if speed > VELOCITY_THRESHOLD then
				self._slide_speed = speed
				self._slide_expire = SLIDE_DURATION
				self._slide_dir = slide_dir
				self._unit:camera():camera_unit():base():set_limits(100, nil)
			end
		end
	end

	function PlayerStandard:_stop_slide()
		if self._slide_expire then
			self._slide_expire = nil
			self._slide_speed = nil
			self._slide_dir = nil
			self._unit:camera():camera_unit():base():remove_limits()
			--printf("Stop slide\n")
		end
	end
end

--no interact delay
function PlayerStandard:_action_interact_forbidden() return false end

--inspire when bleedout
if PlayerBleedOut then
	function PlayerBleedOut:_long_dis_revive(t)
		local voice_type, plural, prime_target = self:_get_unit_intimidation_action(true, true, true, false, true, nil, nil, nil)
		if voice_type == "come" or voice_type == "revive" then
			local is_human_player, record = false, {}
			record = managers.groupai:state():all_criminals()[prime_target.unit:key()]
			if record.ai then
				if not prime_target.unit:brain():player_ignore() then
					prime_target.unit:movement():set_cool(false)
					prime_target.unit:brain():on_long_dis_interacted(0, self._unit, false)
				end
			else
				is_human_player = true
			end

			local amount = 0
			local rally_skill_data = self._ext_movement:rally_skill_data()
			if rally_skill_data and rally_skill_data.range_sq > mvector3.distance_sq(self._pos, record.m_pos) then
				local needs_revive, is_arrested, action_stop
				if prime_target.unit:base().is_husk_player and prime_target.unit:movement() and prime_target.unit:movement():current_state_name() then
					is_arrested = prime_target.unit:movement():current_state_name() == "arrested"
					needs_revive = prime_target.unit:interaction():active() and prime_target.unit:movement():need_revive() and not is_arrested
				else
					is_arrested = prime_target.unit:character_damage():arrested()
					needs_revive = prime_target.unit:character_damage():need_revive()
				end
				if needs_revive and managers.player:has_enabled_cooldown_upgrade("cooldown", "long_dis_revive") then
					voice_type = "revive"
					managers.player:disable_cooldown_upgrade("cooldown", "long_dis_revive")
				elseif not is_arrested and not needs_revive and rally_skill_data.morale_boost_delay_t and managers.player:player_timer():time() > rally_skill_data.morale_boost_delay_t then
					voice_type = "boost"
					amount = 1
				end

				if is_human_player then
					prime_target.unit:network():send_to_unit({"long_dis_interaction", prime_target.unit, amount, self._unit, false})
				end
				
				if not voice_type then
					voice_type = "ai_stay" and "come"
				end

				plural = false			
				if voice_type == "revive" then
					local static_data = managers.criminals:character_static_data_by_unit(prime_target.unit)
					if not static_data then
						return
					end
					if math.random() < self._ext_movement:rally_skill_data().revive_chance then
						prime_target.unit:interaction():interact(self._unit)
					end
					self._ext_movement:rally_skill_data().morale_boost_delay_t = managers.player:player_timer():time() + (self._ext_movement:rally_skill_data().morale_boost_cooldown_t or 3.5)
					self:_do_action_intimidate(t, "cmd_get_up", "f36x_any", false)
					return true
				end
			end
		end
		return false
	end
end

if PlayerBleedOut then
	function PlayerBleedOut:_check_action_interact(t, input)
		if input.btn_interact_press and (not self._intimidate_t or t - self._intimidate_t > tweak_data.player.movement_state.interaction_delay) then
			self._intimidate_t = t
			local _bool = self:_long_dis_revive(t)
			if not _bool and not PlayerArrested.call_teammate(self, "f11", t) then
				self:call_civilian("f11", t, false, true, self._revive_SO_data)
			end
		end
	end
end

--throw cooldown after take bag 0
local old_check_use = PlayerStandard._check_use_item
function PlayerStandard:_check_use_item(t, input)
	if input.btn_use_item_release and self._throw_time and t and t < self._throw_time then
		managers.player:drop_carry()
		self._throw_time = nil
		return true
	else return old_check_use(self, t, input) end
end



--mark enemies
function mark_ppl(unit, forward, my_head_pos)
	local u_head_pos = unit:movement():m_head_pos() + math.UP * 30
	local vec = u_head_pos - my_head_pos
	local ray = World:raycast("ray", my_head_pos, u_head_pos, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", forward or "ai_vision", "ignore_unit", my_head_pos or {})
	local dis = mvector3.normalize(vec)
	local spotting_mul = managers.player:upgrade_value("player", "marked_distance_mul", 1)
	local range_mul = managers.player:upgrade_value("player", "intimidate_range_mul", 1) * managers.player:upgrade_value("player", "passive_intimidate_range_mul", 1)
	local max_dis = tweak_data.player.long_dis_interaction.highlight_range * range_mul * spotting_mul
	local max_angle = math.max(8, math.lerp(false and 30 or 90, false and 10 or 30, dis / 1200))
	local angle = vec:angle(forward)
	if unit.contour and (dis < max_dis) and (angle < max_angle) then
		if not ray or mvector3.distance_sq(ray.position, u_head_pos) < 400 then
			unit:contour():add("mark_enemy", true, mark_time)
		end
	end
end
function PlayerCivilian:mark_units(line, t, no_gesture, skip_alert)
	local mark_time = managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1)
	local forward = self._ext_camera:forward()
	local my_head_pos = self._ext_movement:m_head_pos()
	local amount = managers.player:upgrade_value("player", "civ_intimidation_mul", 1) * managers.player:team_upgrade_value("player", "civ_intimidation_mul", 1)
	
	if managers.groupai:state():whisper_mode() then
		for _, ud in pairs(managers.enemy:all_enemies()) do
			mark_ppl(ud.unit, forward, my_head_pos)
		end
		
		for _, ud in pairs(managers.enemy:all_civilians()) do
			mark_ppl(ud.unit, forward, my_head_pos)
		end
		
		for _, ud in ipairs(SecurityCamera.cameras) do
			if alive(ud) and ud:enabled() and not ud:base():destroyed() then
				ud:contour():add("mark_unit", true)
			end
		end
	else
		if not self:_is_using_bipod() then
			for _, ud in pairs(managers.enemy:all_enemies()) do
				ud.unit:brain():on_intimidated((amount or tweak_data.player.long_dis_interaction.intimidate_strength), self._unit)
			end
		end
	end
end


--interact and hold, interact and look, interact and do anything but bipod, interact and move
if BaseInteractionExt then
	local origfunc__is_in_required_state = BaseInteractionExt._is_in_required_state
	function BaseInteractionExt:_is_in_required_state() return true end
end

local toggle_int_move = false
local PlayerStandard__check_action_interact_original = PlayerStandard._check_action_interact
function base_int_dis() function BaseInteractionExt.interact_distance(self)
		if toggle_int_move then return math.huge end
		return tweak_data.interaction.INTERACT_DISTANCE
end end
function PlayerStandard:_check_action_interact(t, input)
	if input.btn_interact_press and self:_interacting() then
		self:_interupt_action_interact()
		return false
	elseif input.btn_interact_release and self._interact_params then
		if self._interact_params.timer >= 0 then
			self:_play_equip_animation()
			return false
		end
	end
	self._ext_camera:camera_unit():base():remove_limits()
	return PlayerStandard__check_action_interact_original(self, t, input)
end
function PlayerStandard:_interacting()
	--(managers.interaction:active_unit())
	if (self._interact_expire_t) then
		if (mvector3.length(self._controller:get_input_axis("move")) < 0.1) or (mvector3.length(self._controller:get_input_axis("move")) > 0.1) then
			toggle_int_move = true
			base_int_dis()
		end
		if (self._controller:get_input_pressed("interact")) then
			toggle_int_move = false
		end
	else
		toggle_int_move = false
	end
	if toggle_int_move or (self._controller:get_input_bool("primary_attack")) or (self._controller:get_input_pressed("reload")) or (self._controller:get_input_pressed("switch_weapon")) then
		return nil
	end
	return self._interact_expire_t
end
local PlayerMaskOff__check_action_interact_original = PlayerMaskOff._check_action_interact
function PlayerMaskOff:_check_action_interact(t, input)
	if input.btn_interact_press and self:_interacting() then
		self:_interupt_action_interact()
		return false
	elseif input.btn_interact_release and self._interact_params then
		if self._interact_params.timer >= 0 then
			self:_play_equip_animation()
			return false
		end
	end
	self._ext_camera:camera_unit():base():remove_limits()
	return PlayerMaskOff__check_action_interact_original(self, t, input)
end
function PlayerMaskOff:_interacting()
	if (self._interact_expire_t) then
		if (mvector3.length(self._controller:get_input_axis("move")) < 0.1) or (mvector3.length(self._controller:get_input_axis("move")) > 0.1) then
			toggle_int_move = true
			base_int_dis()
		end
		if (self._controller:get_input_pressed("interact")) then
			toggle_int_move = false
		end
	else
		toggle_int_move = false
	end
	if toggle_int_move or (self._controller:get_input_bool("primary_attack")) or (self._controller:get_input_pressed("reload")) or (self._controller:get_input_pressed("switch_weapon")) then
		return nil
	end
	return self._interact_expire_t
end
local PlayerCivilian__check_action_interact_original = PlayerCivilian._check_action_interact
function PlayerCivilian:_check_action_interact(t, input)
	if input.btn_interact_press and self:_interacting() then
		self:_interupt_action_interact()
		return false
	elseif input.btn_interact_release and self._interact_params then
		if self._interact_params.timer >= 0 then
			self:_play_equip_animation()
			return false
		end
	elseif input.btn_interact_press and not managers.interaction:interact(self._unit, input.data, self._interact_hand) then
		self:mark_units("f11", t, true)
	end
	self._ext_camera:camera_unit():base():remove_limits()
	return PlayerCivilian__check_action_interact_original(self, t, input)
end
function PlayerCivilian:_interacting()
	if (self._interact_expire_t) then
		if (mvector3.length(self._controller:get_input_axis("move")) < 0.1) or (mvector3.length(self._controller:get_input_axis("move")) > 0.1) then
			toggle_int_move = true
			base_int_dis()
		end
		if (self._controller:get_input_pressed("interact")) then
			toggle_int_move = false
		end
	else
		toggle_int_move = false
	end
	if toggle_int_move or (self._controller:get_input_bool("primary_attack")) or (self._controller:get_input_pressed("reload")) or (self._controller:get_input_pressed("switch_weapon")) then
		return nil
	end
	return self._interact_expire_t
end
if ObjectInteractionManager then
	_ObjectInteractUpdate = _ObjectInteractUpdate or ObjectInteractionManager.update
	function ObjectInteractionManager:update( t, dt ) 
		if self._active_object_locked_data then
			if alive(self._active_object) and self._active_object:interaction():active() then
				return
			end
		end
		_ObjectInteractUpdate(self, t, dt)
	end
end

local stop_loop = true
function PlayerMaskOff:get_zoom_fov( stance_data )
	local level = managers.job:current_level_id()
	if stop_loop and alive(managers.player:player_unit()) and (level == 'vit') and (managers.player:current_state() ~= "standard") then
		stop_loop = false
		DelayedCalls:Add( "mask_off_state_run", 15, function()
			managers.player:player_unit():base():replenish()
			managers.player:set_player_state("mask_off")
		end)
	end
	
	local fov = stance_data and stance_data.FOV or 75
	local fov_multiplier = managers.user:get_setting( "fov_multiplier" )
	if( self._state_data.in_steelsight ) then
		fov = self._equipped_unit:base():zoom()
		fov_multiplier = 1 + (fov_multiplier - 1)/2
	end
	
	return fov * fov_multiplier
end