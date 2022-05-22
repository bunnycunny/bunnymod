function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	if game_state_machine then
		return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
	end
end
if not is_playing() then 
	return
end
function get_peers(code, unitcheck)
	local peerid = tonumber(code)
	local me = managers.network:session():local_peer():id()
	if not peerid or peerid and (peerid < 1 or peerid > 4) then
		local tab = {}
		for x = 1, 4 do
			if managers.network:session():peer(x) then
				if not (unitcheck or unitcheck and managers.network:session():peer(x):unit()) then
					table.insert(tab, x)
				end
			end
		end
		if code == "*" then -- everyone
			return tab
		elseif code == "?" then -- random
			peerid = tab[math.random(1, #tab)]
		elseif code == "!" then -- anyone except self
			table.remove(tab, me)
			--peerid = tab[math.random(1, #tab)]
			return tab
		else -- self
			peerid = me
		end

		tab = nil
	end
	if peerid and managers.network:session():peer(peerid) then
		if not unitcheck or (unitcheck and managers.network:session():peer(peerid):unit()) then
			return {peerid}
		end
	end
	return
end


local godmode = function()
	--God Mode Toggle
    global_invulerability11 = global_invulerability11 or false
	if not global_invulerability11 then
		--God Mode
		managers.player:player_unit():base():replenish()
		managers.player:player_unit():character_damage():set_invulnerable( true )
		managers.player:player_unit():character_damage():set_god_mode( true )
	
		--anti cuff
		if not global_player_movement_cuff then global_player_movement_cuff = PlayerMovement.on_cuffed end
		local orig_state = PlayerMovement.on_cuffed
		function PlayerMovement:on_cuffed()
			orig_state(self)
			if alive( managers.player:player_unit() ) then
				if (managers.player._current_state == "arrested") or (managers.player._current_state == "bleed_out") then
					managers.player:set_player_state("standard")
				end
			end
		end
		
		-- Infinite ammo resets ammo on reload
		if not _onReload then _onReload = RaycastWeaponBase.on_reload end
		function RaycastWeaponBase:on_reload()
			if managers.player:player_unit() == self._setup.user_unit then
				self.set_ammo(self, 1.0)
			else
				_onReload(self)
			end
		end
		
		--No hit distraction
		function CoreEnvironmentControllerManager:set_health_effect_value(health_effect_value)
			self._hit_amount = 0 --Yellow/white armor impact flash per hit increment
			self._health_effect_value = health_effect_value * 0 --Red health impact flash
		end
		
		if not global_toggle_no_hit then global_toggle_no_hit = managers.environment_controller._hit_amount end
		managers.environment_controller._hit_amount = 0
		
		if not global_toggle_no_hit2 then global_toggle_no_hit2 = PlayerCamera.play_shaker end
		function PlayerCamera:play_shaker(effect, amplitude, frequency, offset)
			if _G.IS_VR then
				return
			end
			return self._shaker:play(effect, amplitude or 0, frequency or 0, offset or 0)
		end
		for k, v in pairs(tweak_data.weapon) do
			v.shake = {
				fire_multiplier = 0,
				fire_steelsight_multiplier = 0
			}
		end
		--accuracy
		if not global_toggle_get_spread then global_toggle_get_spread = NewRaycastWeaponBase._get_spread_from_number end
		function NewRaycastWeaponBase._get_spread_from_number() return 0 end
		
		--No headbob
		if not global_toggle_get_walk_headbob then global_toggle_get_walk_headbob = PlayerStandard._get_walk_headbob end
		function PlayerStandard._get_walk_headbob() return 0 end
		if not global_toggle_get_walk_headbob2 then global_toggle_get_walk_headbob2 = PlayerMaskOff._get_walk_headbob end
		function PlayerMaskOff:_get_walk_headbob() return 0 end
		if not global_toggle_get_walk_headbob3 then global_toggle_get_walk_headbob3 = PlayerCivilian._get_walk_headbob end
		function PlayerCivilian:_get_walk_headbob() return 0 end
		
		--Notalkdelay
		if not global_toggle_interaction_delay then global_toggle_interaction_delay = tweak_data.player.movement_state.interaction_delay end
		if not global_toggle_morale_boost_base_cooldown then global_toggle_morale_boost_base_cooldown = tweak_data.upgrades.morale_boost_base_cooldown end
		tweak_data.player.movement_state.interaction_delay = 0
		tweak_data.upgrades.morale_boost_base_cooldown = 0
		if managers.groupai:state()._whisper_mode then
			managers.groupai:state()._whisper_mode = true
		end
		
		if not global_toggle_rally_skill_data then global_toggle_rally_skill_data = PlayerMovement.rally_skill_data end
		function PlayerMovement.rally_skill_data() 
			return { range_sq = 1400*1400,
				morale_boost_delay_t = 0,
				long_dis_revive = true,
				revive_chance = 1,
				morale_boost_cooldown_t = 0,
			}
		end
		
		-- Increase melee damage
		if not global_toggle_CopDamage_melee then global_toggle_CopDamage_melee = CopDamage.damage_melee end
		local damage_melee_original = CopDamage.damage_melee
		function CopDamage:damage_melee( attack_data, ... )
			attack_data.damage = attack_data.damage * 2254
			return damage_melee_original( self, attack_data, ... )
		end
		
		if not global_toggle_TankCopDamage_melee then global_toggle_TankCopDamage_melee = TankCopDamage.damage_melee end
		local super_damage_melee = TankCopDamage.super.damage_melee
		function TankCopDamage.damage_melee( ... )
			return super_damage_melee( ... )
		end
		
		if not global_toggle_HuskTankCopDamage_melee then global_toggle_HuskTankCopDamage_melee = HuskTankCopDamage.damage_melee end
		local super_damage_melee = HuskTankCopDamage.super.damage_melee
		function HuskTankCopDamage.damage_melee( ... )
			return super_damage_melee( ... )
		end
		
		--Cloaker auto counter on
		if not global_anti_cloaker then global_anti_cloaker = PlayerMovement.on_SPOOCed end
		function PlayerMovement:on_SPOOCed(enemy_unit)
			return "countered"
		end
		if not global_anti_cloaker_ai then global_anti_cloaker_ai = TeamAIMovement.on_SPOOCed end
		function TeamAIMovement:on_SPOOCed(enemy_unit)
			return "countered"
		end
		
		-- taze off
		function PlayerTased:enter( state_data, enter_data )
			PlayerTased.super.enter( self, state_data, enter_data )
			self._next_shock = Application:time() + 10
			self._taser_value = 1
			self._recover_delayed_clbk = "PlayerTased_recover_delayed_clbk"
			managers.enemy:add_delayed_clbk( self._recover_delayed_clbk, callback( self, self, "clbk_exit_to_std" ), Application:time() )
		end
		
		--MSG
		managers.mission._fading_debug_output:script().log('Godmode Player ACTIVATED',  Color.green)
		managers.chat:feed_system_message(ChatManager.GAME, "Anti taser/cloaker/cuff, more melee damage, shout faster, removed headbob, infinate ammo when reload, no hit flash and full accuracy")
	else
		--God Mode
		managers.player:player_unit():character_damage():set_invulnerable( false )
		managers.player:player_unit():character_damage():set_god_mode( false )
		
		--anti cuff
		if global_player_movement_cuff then PlayerMovement.on_cuffed = global_player_movement_cuff end
		
		--inf reload
		if _onReload then RaycastWeaponBase.on_reload = _onReload end
		
		--accuracy
		if global_toggle_get_spread then NewRaycastWeaponBase._get_spread_from_number = global_toggle_get_spread end

		--No headbob
		if global_toggle_get_walk_headbob then PlayerStandard._get_walk_headbob = global_toggle_get_walk_headbob end
		if global_toggle_get_walk_headbob2 then PlayerMaskOff._get_walk_headbob = global_toggle_get_walk_headbob2 end
		if global_toggle_get_walk_headbob3 then PlayerCivilian._get_walk_headbob = global_toggle_get_walk_headbob3 end

		--Notalkdelay
		if managers.groupai:state() then
			managers.groupai:state()._whisper_mode = false
		end
		if global_toggle_interaction_delay then tweak_data.player.movement_state.interaction_delay = global_toggle_interaction_delay end
		if global_toggle_morale_boost_base_cooldown then tweak_data.upgrades.morale_boost_base_cooldown = global_toggle_morale_boost_base_cooldown end
		if global_toggle_rally_skill_data then PlayerMovement.rally_skill_data = global_toggle_rally_skill_data end
		--no hit
		if global_toggle_no_hit then managers.environment_controller._hit_amount = global_toggle_no_hit end
		if global_toggle_no_hit2 then PlayerCamera.play_shaker = global_toggle_no_hit2 end
		--melee
		if global_toggle_CopDamage_melee then CopDamage.damage_melee = global_toggle_CopDamage_melee end
		if global_toggle_TankCopDamage_melee then TankCopDamage.damage_melee = global_toggle_TankCopDamage_melee end
		if global_toggle_HuskTankCopDamage_melee then HuskTankCopDamage.damage_melee = global_toggle_HuskTankCopDamage_melee end
		
		-- taze on
		function PlayerTased:enter( state_data, enter_data )
			PlayerTased.super.enter( self, state_data, enter_data )
			self._next_shock = 0.5
			self._taser_value = 1
			self._num_shocks = 0
			state_data.non_lethal_electrocution = nil
			local recover_time = Application:time() + tweak_data.player.damage.TASED_TIME * managers.player:upgrade_value("player", "electrocution_resistance_multiplier", 1)
			self._recover_delayed_clbk = "PlayerTased_recover_delayed_clbk"
			managers.enemy:add_delayed_clbk(self._recover_delayed_clbk, callback(self, self, "clbk_exit_to_std"), recover_time)
		end
		
		-- Cloaker auto counter off
		if global_anti_cloaker then PlayerMovement.on_SPOOCed = global_anti_cloaker end
		if global_anti_cloaker_ai then TeamAIMovement.on_SPOOCed = global_anti_cloaker_ai end
		
		--MSG
		managers.mission._fading_debug_output:script().log('Godmode Player DEACTIVATED',  Color.red)
	end
	global_invulerability11 = not global_invulerability11
end

local godmodeextra = function()
	global_invulerability3 = global_invulerability3 or false
	if not global_invulerability3 then
		--movspeed
		if not PlayerManager.movement_speed_multiplier2 then 
			PlayerManager.movement_speed_multiplier2 = PlayerManager.movement_speed_multiplier 
		end 
		function PlayerManager:movement_speed_multiplier( speed_state, bonus_multiplier ) 
			if not bonus_multiplier then 
				bonus_multiplier = 1 
			end 
			bonus_multiplier = bonus_multiplier * 2 
			return self:movement_speed_multiplier2( speed_state, bonus_multiplier ) 
		end
		
		--replenish health, ammo
		managers.player:player_unit():base():replenish()
		
		--no fall dmg
		if not global_fall_dmg then global_fall_dmg = PlayerDamage.damage_fall end
		function PlayerDamage:damage_fall(data)
			return false
		end
		
		-- high jump
		if not global_toggle_start_action_jump then global_toggle_start_action_jump = PlayerStandard._start_action_jump end 
		local local_toggle_start_action_jump = PlayerStandard._start_action_jump
		function PlayerStandard:_start_action_jump( t, action_start_data, ... )
			if self._running then
				action_start_data.jump_vel_z = action_start_data.jump_vel_z * (2)
			end
			return local_toggle_start_action_jump(self, t, action_start_data, ... )
		end
		
		-- Unlimited messiah charges (self-revive)
		function PlayerDamage:consume_messiah_charge() return true end
		function PlayerDamage:got_messiah_charges() return true end
		
		--inf ammo and speed
		if not _fireWep then _fireWep = NewRaycastWeaponBase.fire end
		function NewRaycastWeaponBase:fire( from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit )
			local result = _fireWep( self, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit )
			if managers.player:player_unit() == self._setup.user_unit then
				self.set_ammo(self, 1.0)
			end
			return result
		end
		
		--insta hit
		--NewRaycastWeaponBase.damage_multiplier = function(self) return 999 end
		if not global_toggle_instahit then global_toggle_instahit = RaycastWeaponBase._get_current_damage end
		function RaycastWeaponBase:_get_current_damage()
			return math.huge
		end
		
		--enable explosives damage multiplier, crashes game when others spam projectiles
		if not global_toggle_damage_explosion_origional then global_toggle_damage_explosion_origional = CopDamage.damage_explosion end
		function CopDamage:damage_explosion( attack_data )
			attack_data.damage = attack_data.damage * 50000
			return global_toggle_damage_explosion_origional( self, attack_data )
		end
		
		-- instant deploy
		PlayerManager.selected_equipment_deploy_timer = function(self) return 0 end
	
		--Weapon fire rate
		NewRaycastWeaponBase.fire_rate_multiplier = function(self) return 6 end

		--Weapon swap speed
		PlayerStandard._get_swap_speed_multiplier = function(self) return 7 end

		-- RECOIL
		if not global_toggle_recoil_multiplier then global_toggle_recoil_multiplier = NewRaycastWeaponBase.recoil_multiplier end
		NewRaycastWeaponBase.recoil_multiplier = function(self) return 0 end
		
		--camera shake
		if not global_toggle_play_shaker then global_toggle_play_shaker = PlayerCamera.play_shaker end
		local local_toggle_camera_shake = PlayerCamera.play_shaker
		function PlayerCamera:play_shaker( effect, ... )
			if effect == 'fire_weapon_kick' or effect == 'fire_weapon_rot' then
				return
			end
			return local_toggle_camera_shake(self, effect, ...) 
		end

		--instant interact
		interact_blacklist = {
			"driving_drive",
			"hold_place_sentry",
			"sentry_gun"
		}
		if not _getTimer then _getTimer = BaseInteractionExt._get_timer end
		function BaseInteractionExt:_get_timer()
			for _, interactbl in pairs(interact_blacklist) do
				if self.tweak_data == interactbl then
					return _getTimer(self)
				end
			end
			if self.tweak_data == "corpse_alarm_pager" then
				return 0.1
			end
			return 0
		end
			
		--interact with everything
		if not global_toggle_has_required_upgrade then global_toggle_has_required_upgrade = BaseInteractionExt._has_required_upgrade end
		BaseInteractionExt._has_required_upgrade = function(self) return true end 
		if not global_toggle_has_required_deployable then global_toggle_has_required_deployable = BaseInteractionExt._has_required_deployable end
		BaseInteractionExt._has_required_deployable = function(self) return true end 
		if not global_toggle_can_interact then global_toggle_can_interact = BaseInteractionExt.can_interact end
		BaseInteractionExt.can_interact = function(self, player) return true end 
		
		--Infinite equipments
		if not equipment_toggle then
			dofile("mods/hook/content/scripts/equipment.lua")
		end
		
		--msg
		managers.mission._fading_debug_output:script().log('Godmode Extra ACTIVATED',  Color.green)
		managers.chat:feed_system_message(ChatManager.GAME, "No fall damage, jump high when run, infinate ammo, interact with everything, interact fast, one hit kill, infinate messiah charges, remove recoil, faster swap, fast firerate, fast deploy and more explosive damage")
	else
		--movspeed
		if not PlayerManager.movement_speed_multiplier2 then 
			PlayerManager.movement_speed_multiplier2 = PlayerManager.movement_speed_multiplier 
		end 
		function PlayerManager:movement_speed_multiplier( speed_state, bonus_multiplier ) 
			return self:movement_speed_multiplier2( speed_state, bonus_multiplier ) 
		end	
		
		--no fall dmg
		if global_fall_dmg then PlayerDamage.damage_fall = global_fall_dmg end
		
		-- high jump
		if global_toggle_start_action_jump then PlayerStandard._start_action_jump = global_toggle_start_action_jump end

		-- Unlimited messiah charges (self-revive)
		function PlayerDamage:consume_messiah_charge() return false end
		function PlayerDamage:got_messiah_charges() return false end
		
		--inf ammo and speed
		if _fireWep then NewRaycastWeaponBase.fire = _fireWep end

		--insta hit
		--NewRaycastWeaponBase.damage_multiplier = function(self) return end
		if global_toggle_instahit then RaycastWeaponBase._get_current_damage = global_toggle_instahit end
		
		--disable explosives damage multiplier
		if global_toggle_damage_explosion_origional then CopDamage.damage_explosion = global_toggle_damage_explosion_origional end

		-- instant deploy
		function PlayerManager.selected_equipment_deploy_timer() return 0.4 end
		
		--infinate equipment
		if equipment_toggle then
			dofile("mods/hook/content/scripts/equipment.lua")
		end
		
		--Weapon fire rate
		NewRaycastWeaponBase.fire_rate_multiplier = function(self) return 1.5 end

		--Weapon swap speed
		PlayerStandard._get_swap_speed_multiplier = function(self) return 2 end
		
		--recoil
		if global_toggle_recoil_multiplier then NewRaycastWeaponBase.recoil_multiplier = global_toggle_recoil_multiplier end
		NewRaycastWeaponBase.recoil_multiplier = function(self) return 1 end
		
		--shake
		if global_toggle_play_shaker then PlayerCamera.play_shaker = global_toggle_play_shaker end

		--instant interact
		if _getTimer then BaseInteractionExt._get_timer = _getTimer end
		
		--interact with everything
		if global_toggle_has_required_upgrade then BaseInteractionExt._has_required_upgrade = global_toggle_has_required_upgrade end
		if global_toggle_has_required_deployable then BaseInteractionExt._has_required_deployable = global_toggle_has_required_deployable end
		if global_toggle_can_interact then BaseInteractionExt.can_interact = global_toggle_can_interact end

		--msg
		managers.mission._fading_debug_output:script().log('Godmode Extra DEACTIVATED',  Color.red)
	end
	global_invulerability3 = not global_invulerability3
end

local godmodeteam = function()
	managers.player:player_unit():base():replenish()
	
	function verify_player_id(id)
		if not managers.network:session() then return false end
		return managers.network:session():peer(id) and managers.criminals:character_name_by_peer_id(id)
	end

	can_interact = function()
		return true
	end
	
	rev_player = function(id)
		local lunit = managers.player._players[1]
		local peer = managers.network:session():peer(id)
		local id = peer:id()
		local pname = peer:name()
		if not peer then return end
		if managers.trade:is_peer_in_custody(id) then
			if verify_player_id(id) then
				if Network:is_server() then
					IngameWaitingForRespawnState.request_player_spawn(id)
				end
			end
		else
			local unit2 = managers.network:session():peer(id):unit()
			if unit2 and (unit2:movement():current_state_name() == "arrested" or unit2:movement():current_state_name() == "incapacitated" or unit2:movement():current_state_name() == "bleed_out" or unit2:movement():current_state_name() == "fatal") then
				local isArrest = (unit2:movement():current_state_name() == "arrested")
				if unit2 == lunit then
					lunit:character_damage():replenish()
					managers.player:set_player_state("standard")
					if not isArrest then
						lunit:character_damage():set_health(lunit:character_damage():_max_health() * 0.8)
						lunit:character_damage():_send_set_health()
					end
					managers.mission._fading_debug_output:script().log(string.format("Revived Yourself"),  Color.green)
				else
					if lunit then
						unit2:interaction():interact(lunit)
						unit2:interaction():interact_start(lunit)
						managers.network:session():send_to_peers_synched("sync_teammate_helped_hint",  isArrest and 3 or 2, unit2, unit2)
					end
					managers.mission._fading_debug_output:script().log(string.format("Revived %s", pname), Color.green)
				end
			end
			for u_key, u_data in pairs(managers.groupai:state():all_player_criminals()) do
				if u_data and u_data.unit then
					local interaction
					for _, unit in pairs(managers.interaction._interactive_units) do
						if not alive(unit) then return end
						interaction = unit:interaction()
						if interaction.tweak_data == "revive" then
							interaction.can_interact = can_interact
							interaction:interact(managers.player._players[1])
							interaction.can_interact = nil
							break
						end
					end
				end
			end
		end
	end
	
	-- godmode team
	if Network:is_server() then
		global_toggle_team_godmode = global_toggle_team_godmode or false
		if not global_toggle_team_godmode then
			--godmode player
			if not global_invulerability11 then godmode() end
			
			BetterDelayedCalls:Add("rev_players", 1, function()
				if not alive(managers.player:player_unit()) then return end
				for _, peer in pairs( managers.network._session._peers ) do
					rev_player(peer._id)
				end
			end, true)
			managers.mission._fading_debug_output:script().log('Revive Team ACTIVATED', Color.green)
				
			--team godmode
			if not global_toggle_tm_godmode then global_toggle_tm_godmode = UnitNetworkHandler.set_health end
			local local_toggle_tm_godmode = UnitNetworkHandler.set_health
			function UnitNetworkHandler:set_health( unit, percent, max_mul, sender )
				local peer = self._verify_sender(sender)
				local peer_id = peer:id()
				if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
					return
				end
				if not peer or not unit or not alive( unit ) then
					--unjail
					DelayedCalls:Add( "unjail_dead", 2, function()
						if not alive(managers.player:player_unit()) then return end
						local lpeer_id = managers.network._session._local_peer._id
						for _, peer in pairs( managers.network._session._peers ) do
							local peer_id = peer._id
							if peer_id ~= lpeer_id then
								local peer = managers.network:session():peer(peer_id)
								if not alive(peer:unit()) then
									if verify_player_id(id) then
										IngameWaitingForRespawnState.request_player_spawn(peer:id())
									end
								end
							end
							for id, data in pairs(managers.criminals._characters) do
								local spawn_on_unit = managers.player:player_unit():camera():position()
								local unit = data.unit
								local bot = data.data.ai
								local name = data.name
								if unit ~= null and bot and not alive(unit) then
								managers.trade:remove_from_trade(name) 
								managers.groupai:state():spawn_one_teamAI(false, name, spawn_on_unit)
								end
							end
						end
					end)
					return
				end
				if (percent == 0 or percent == nil) then
					return
				end
	
				if percent < 100 then
					unit:network():send_to_unit( { "spawn_dropin_penalty", false, false, 99, nil, nil, nil } )
				end
				
				return local_toggle_tm_godmode( self, unit, percent, max_mul, sender )
			end
			
			local ids = get_peers('!')
			if ids then
				for _, id in pairs(ids) do
					local peer = managers.network:session():peer(id)
					local network, send
					if alive(peer:unit()) then
						network = peer:unit():network()
						send = network.send
					end
					
					local unit = peer:unit()
					if peer then
						if network and send then
							BetterDelayedCalls:Add("godmode_team_", 0.1, function()
								send(network, "set_health", peer:id(), 1, 100)
								send(network, "set_armor", peer:id(), 1, 100)
							end, true)
						end
					end
				end
			end--]]
			--msg
			managers.mission._fading_debug_output:script().log('Godmode Team ACTIVATED', Color.green)
		else
			BetterDelayedCalls:Remove("godmode_team_")
			--godmode player
			if global_invulerability11 then godmode() end
			--remove revive
			BetterDelayedCalls:Remove("rev_players", nil, false)
			--team godmode
			if global_toggle_tm_godmode then UnitNetworkHandler.set_health = global_toggle_tm_godmode end
			
			managers.mission._fading_debug_output:script().log('Revive Team ACTIVATED', Color.red)
			managers.mission._fading_debug_output:script().log('Godmode Team DEACTIVATED', Color.red)
		end
		global_toggle_team_godmode = not global_toggle_team_godmode
	else --if client
		global_toggle_team_godmode = global_toggle_team_godmode or false
		if not global_toggle_team_godmode then
			--godmode player
			if not global_invulerability11 then godmode() end
			
			local upg_table = {
				["team"] = {
					armor = {regen_time_multiplier = 0.75},
					armor = {passive_regen_time_multiplier = 0.9},
					stamina = {multiplier = 1.5},
					damage = {hostage_absorption = 0.05},
					damage = {hostage_absorption_limit = 8},
					stamina = {passive_multiplier = 1.5},
					health = {passive_multiplier = 1.1},
					health = {hostage_multiplier = 1.06},
					stamina = {hostage_multiplier = 1.12},
					weapon = {move_spread_multiplier = 1.1},
					player = {civ_intimidation_mul = 1.15},
					xp = {stealth_multiplier = 1.5},
					cash = {stealth_money_multiplier = 1.5},
					cash = {stealth_bags_multiplier = 1.5},
					damage_dampener = {hostage_multiplier = 0.92},
					damage_dampener = {team_damage_reduction = 0.92}
				}
			}
			local orig_pm_tug = PlayerManager.team_upgrade_value
			function PlayerManager.team_upgrade_value(self, category, upgrade, ...)
				local original_value = orig_pm_tug(self, category, upgrade, ...)
				if global_toggle_team_godmode and ((upg_table["team"][category]) and (upg_table["team"][category][upgrade])) then
					if managers.network and managers.network:session() then
						for _, peer in pairs(managers.network:session():all_peers()) do
							local peer_id = peer:id()
							local me = managers.network:session():local_peer():id()
							if peer and self._global and self._global.synced_team_upgrades and self._global.synced_team_upgrades[peer_id] ~= nil and not self._global.synced_team_upgrades[peer_id][category] and not self._global.synced_team_upgrades[peer_id][category][upgrade] then
								self:add_synced_team_upgrade(peer_id, category, upgrade, 1)
								if peer_id ~= me then
									peer:send_queued_sync("add_synced_team_upgrade", category, upgrade, 1)
								end
							end
						end
						original_value = upg_table["team"][category][upgrade]
					end
				end
				return original_value
			end
			
			BetterDelayedCalls:Add("rev_players", 1, function()
				if not alive(managers.player:player_unit()) then return end
				for _, peer in pairs( managers.network._session._peers ) do
					rev_player(peer._id)
				end
			end, true)
			managers.mission._fading_debug_output:script().log('Revive Team ACTIVATED', Color.green)
			managers.mission._fading_debug_output:script().log('Godmode Team ACTIVATED', Color.green)
		else
			--godmode player
			if global_invulerability11 then godmode() end
			--revive
			BetterDelayedCalls:Remove("rev_players", nil, false)
			managers.mission._fading_debug_output:script().log('Revive Team DEACTIVATED', Color.red)
			managers.mission._fading_debug_output:script().log('Godmode Team DEACTIVATED', Color.red)
		end
		global_toggle_team_godmode = not global_toggle_team_godmode
	end
end

local godmodesentry = function()
	if Network:is_server() then else 
		managers.chat:_receive_message(1, "GodmodeSentry", "Host only!", tweak_data.system_chat_color)
		return
	end
	managers.player:player_unit():base():replenish()
	global_sentry_toggle = global_sentry_toggle or false
	if not global_sentry_toggle then
		-- Infinite ammo for sentry
		if not global_toggle_sentry_fire then global_toggle_sentry_fire = SentryGunWeapon.fire end
		local local_toggle_sentry_fire = SentryGunWeapon.fire
		function SentryGunWeapon:fire( blanks, expend_ammo, ... )
			return local_toggle_sentry_fire( self, blanks, false, ... )
		end
		-- God mode for sentry gun
		if not global_toggle_damage_bullet then global_toggle_damage_bullet = SentryGunDamage.damage_bullet end
		--local local_toggle_sentry_damage = SentryGunWeapon.damage_bullet
		function SentryGunDamage.damage_bullet() end
		
		managers.mission._fading_debug_output:script().log('Sentry godmode ACTIVATED', Color.green)
		managers.chat:feed_system_message(ChatManager.GAME, "Ammo and health")
	else
		-- Infinite ammo for sentry
		if global_toggle_sentry_fire then SentryGunWeapon.fire = global_toggle_sentry_fire end
		-- God mode for sentry gun
		if global_toggle_damage_bullet then SentryGunDamage.damage_bullet = global_toggle_damage_bullet end
		managers.mission._fading_debug_output:script().log('Sentry godmode DEACTIVATED', Color.red)
	end
	global_sentry_toggle = not global_sentry_toggle
end

local godmodebots = function()
	if Network:is_server() then else 
		managers.chat:_receive_message(1, "GodmodeBots", "Host only!", tweak_data.system_chat_color)
		return
	end
	kill_bots_global = kill_bots_global or false
	if not kill_bots_global then
		tweak_data.character.presets.gang_member_damage.REGENERATE_TIME = 0                    --Amount of time to pass before regenerate
		tweak_data.character.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0            --   Amount of time to pass before regenerate when this criminal is far away from players
		tweak_data.character.presets.gang_member_damage.HEALTH_INIT = 100000            --Amount of health Team Ai have before getting downed.  (Default is 75)
		tweak_data.character.presets.gang_member_damage.DOWNED_TIME = 120                       --  Amount of time in down until "dead" (Default is 30)
		tweak_data.character.presets.gang_member_damage.ARRESTED_TIME = 120              --  Amount of time in arrest before "dead" (Default is 60)
		tweak_data.character.presets.gang_member_damage.INCAPACITATED_TIME = 120             --  Amount of time in down until "dead" (Default is 30) 
		tweak_data.character.russian.SPEED_WALK = 10000
		tweak_data.character.american.SPEED_WALK = 10000
		tweak_data.character.german.SPEED_WALK = 10000
		tweak_data.character.spanish.SPEED_WALK = 10000
		tweak_data.character.russian.SPEED_RUN = 10000
		tweak_data.character.american.SPEED_RUN = 10000
		tweak_data.character.german.SPEED_RUN = 10000
		tweak_data.character.spanish.SPEED_RUN = 10000
		tweak_data.character.russian.SPEED_SPRINT = 10000
		tweak_data.character.american.SPEED_SPRINT = 10000
		tweak_data.character.german.SPEED_SPRINT = 10000
		tweak_data.character.spanish.SPEED_SPRINT = 10000
		if globa_toggle_ai_godmode then TeamAIDamage._apply_damage = globa_toggle_ai_godmode end
		if globa_toggle_ai_godmode2 then TeamAIDamage.damage_melee = globa_toggle_ai_godmode2 end
		managers.mission._fading_debug_output:script().log('Godmode Bots ACTIVATED', Color.green)
		managers.chat:feed_system_message(ChatManager.GAME, "AI Health Only")
	else
		tweak_data.character.presets.gang_member_damage.REGENERATE_TIME = 10000                    --Amount of time to pass before regenerate
		tweak_data.character.presets.gang_member_damage.REGENERATE_TIME_AWAY = 10000            --   Amount of time to pass before regenerate when this criminal is far away from players
		tweak_data.character.presets.gang_member_damage.HEALTH_INIT = 1            --Amount of health Team Ai have before getting downed.  (Default is 75)
		tweak_data.character.presets.gang_member_damage.DOWNED_TIME = 1                       --  Amount of time in down until "dead" (Default is 30)
		tweak_data.character.presets.gang_member_damage.ARRESTED_TIME = 1                     --  Amount of time in arrest before "dead" (Default is 60)
		tweak_data.character.presets.gang_member_damage.INCAPACITATED_TIME = 1                --  Amount of time in down until "dead" (Default is 30) 
		tweak_data.character.russian.SPEED_WALK = 0
		tweak_data.character.american.SPEED_WALK = 0
		tweak_data.character.german.SPEED_WALK = 0
		tweak_data.character.spanish.SPEED_WALK = 0
		tweak_data.character.russian.SPEED_RUN = 0
		tweak_data.character.american.SPEED_RUN = 0
		tweak_data.character.german.SPEED_RUN = 0
		tweak_data.character.spanish.SPEED_RUN = 0
		tweak_data.character.russian.SPEED_SPRINT = 0
		tweak_data.character.american.SPEED_SPRINT = 0
		tweak_data.character.german.SPEED_SPRINT = 0
		tweak_data.character.spanish.SPEED_SPRINT = 0

		--kill in one hit
		if not globa_toggle_ai_godmode then globa_toggle_ai_godmode = TeamAIDamage._apply_damage end
		function TeamAIDamage:_apply_damage(attack_data, result)
			local damage = attack_data.damage
			damage = math.clamp(damage, self._HEALTH_TOTAL_PERCENT, self._HEALTH_TOTAL)
			local damage_percent = math.ceil(100000 / self._HEALTH_TOTAL_PERCENT)
			damage = damage_percent * self._HEALTH_TOTAL_PERCENT
			attack_data.damage = damage
			attack_data.pos = attack_data.pos or attack_data.col_ray.position
			attack_data.result = result
			local health_subtracted = nil
			if self._bleed_out then
				health_subtracted = self._bleed_out_health
				self._bleed_out_health = self._bleed_out_health - damage
				self:_check_fatal()
				if self._fatal then
					result.type = "fatal"
					self._health_ratio = 0
				else
					health_subtracted = damage
					result.type = "fatal"
					self._health_ratio = 0
				end
			else
				health_subtracted = self._health
				self._health = self._health - damage
				self:_check_bleed_out()
				if self._bleed_out then
					result.type = "fatal"
					self._health_ratio = 0
				else
					health_subtracted = damage
					result.type = self:get_damage_type(damage_percent, "bullet") or "none"
					self:_on_hurt()
					self._health_ratio = self._health / self._HEALTH_INIT
				end
			end
			managers.hud:set_mugshot_damage_taken(self._unit:unit_data().mugshot_id)
			return damage_percent, health_subtracted
		end

		--[[kill using guns
		function TeamAIDamage:damage_bullet(attack_data)
			local result = {variant = "bullet", type = "none"}
			attack_data.result = result
			local damage_percent, health_subtracted = self:_apply_damage(attack_data, result)
			local t = TimerManager:game():time()
			self._next_allowed_dmg_t = t + self._dmg_interval
			self._last_received_dmg_t = t
			self._last_received_dmg = health_subtracted
			if health_subtracted > 0 then
				self:_send_damage_drama(attack_data, health_subtracted)
			elseif self._dead then
				self:_unregister_unit()
			end
			self:_call_listeners(attack_data)
			self:_send_bullet_attack_result(attack_data)
			return result
		end--]]

		--kill using melee
		if not globa_toggle_ai_godmode2 then globa_toggle_ai_godmode2 = TeamAIDamage.damage_melee end
		function TeamAIDamage:damage_melee(attack_data)
			local result = {
				variant = "melee"
			}
			local damage_percent, health_subtracted = self:_apply_damage(attack_data, result)
			local t = TimerManager:game():time()
			self._next_allowed_dmg_t = t + self._dmg_interval
			self._last_received_dmg_t = t
			if health_subtracted > 0 then
				self:_send_damage_drama(attack_data, health_subtracted)
			elseif self._dead then
				self:_unregister_unit()
			end
			self:_call_listeners(attack_data)
			self:_send_melee_attack_result(attack_data)
			return result
		end
		managers.mission._fading_debug_output:script().log('Godmode Bots DEACTIVATED', Color.red)
	end
	kill_bots_global = not kill_bots_global
end

local godmodeconverts = function()
	global_godmode_converts = global_godmode_converts or false
	local old_convert = old_convert or CopDamage.convert_to_criminal
	if not global_godmode_converts then
		if Network:is_server() then
			local old_convert = old_convert or CopDamage.convert_to_criminal
			function CopDamage:convert_to_criminal(health_multiplier)
				old_convert(self, health_multiplier)
				self:set_invulnerable(true)
			end
		else
			CopDamage:set_invulnerable(true)
		end
		managers.mission._fading_debug_output:script().log('Godmode Converts ACTIVATED', Color.green)
	else
		if Network:is_server() then
			local old_convert = old_convert or CopDamage.convert_to_criminal
			function CopDamage:convert_to_criminal(health_multiplier)
				old_convert(self, health_multiplier)
				self:set_invulnerable(false)
			end
		else
			--find function to work client side?
			CopDamage:set_invulnerable(false)
		end
		managers.mission._fading_debug_output:script().log('Godmode Converts DEACTIVATED', Color.red)
	end
	global_godmode_converts = not global_godmode_converts
end

local function godmodecivilians()
	if Network:is_server() then else 
		managers.chat:_receive_message(1, "GodmodeBots", "Host only!", tweak_data.system_chat_color)
		return
	end
	
	function CivilianDamage:is_friendly_fire(unit)
		if not unit then
			return false
		end
		if global_godmode_civs then
			return true
		else
			return false
		end
	end
	
	global_godmode_civs = global_godmode_civs or false
	if not global_godmode_civs then
		managers.mission._fading_debug_output:script().log('Godmode Civilians ACTIVATED', Color.green)
	else
		managers.mission._fading_debug_output:script().log('Godmode Civilians DEACTIVATED', Color.red)
	end
	global_godmode_civs = not global_godmode_civs
end

local set_cops_on_fire = function()
	--burn civ enemy
	local weapon_unit = managers.player._players[1]:inventory():unit_by_selection(1)
	for u_key, u_data in pairs( managers.enemy:all_enemies()) do
		managers.fire:add_doted_enemy( u_data.unit, TimerManager:game():time(), weapon_unit, 10, 10 )
	end
	for u_key, u_data in pairs(managers.enemy:all_civilians()) do
		managers.fire:add_doted_enemy( u_data.unit, TimerManager:game():time(), weapon_unit, 10, 10 )
	end
	managers.mission._fading_debug_output:script().log('Burn Everyone ACTIVATED',  Color.green)
end

local dodge_menu = function()
	local dialog_data = {    
		title = "Dodge Menu",
		text = "Adding dodge to current dodge",
		button_list = {}
	}
	
	dodgeall = dodgeall or false
	if not dodgeall then
		function round(number, decimals)
			local power = 10^decimals
			return math.floor(number * power) / power
		end
		for i = 0, 150 do
			table.insert(dialog_data.button_list, {
				text = i.."%",
				callback_func = function() 
					managers.player:_dodge_shot_gain(i/100) --current dodge - 30% dodge if current dodge is -25 then you get 5 dodge
					managers.mission._fading_debug_output:script().log(string.format("Dodge %s - ACTIVATED", i), Color.green)
				end, 
			})
		end
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() menu() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"),cancel_button = true}     
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	else
		managers.player:_dodge_shot_gain(0)
		managers.mission._fading_debug_output:script().log(string.format("Dodge - DEACTIVATED"), Color.red)
	end
	dodgeall = not dodgeall
end

menu = function()
	local dialog_data = {    
		title = "Godmode Menu",
		text = "Select Option",
		button_list = {}
	}
		
	local godmode_menu_table = {
		["input"] = {
			{ text = "Godmode - ON/OFF", callback_func = function() godmode() end },
			{ text = "Godmode Extra - ON/OFF", callback_func = function() godmodeextra() end },
			{ text = "Godmode Team - ON/OFF", callback_func = function() godmodeteam() end },
			{ text = "Godmode Sentry - ON/OFF", callback_func = function() godmodesentry() end },
			{ text = "Godmode Bots - ON/OFF", callback_func = function() godmodebots() end },
			{ text = "Godmode Converts - ON/OFF", callback_func = function() godmodeconverts() end },
			{ text = "Godmode Civilians - ON/OFF", callback_func = function() godmodecivilians() end },
			{},
			{ text = "Infinate Equipment - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/equipment.lua") end },
			{ text = "Invisible - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/invisibleplayer.lua") end },
			{ text = "Freeze Everyone - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/lobotimize.lua") end },
			{ text = "Convert Everyone - ON", callback_func = function() dofile("mods/hook/content/scripts/convertall.lua") end },
			{ text = "Burn Everyone - ON", callback_func = function() set_cops_on_fire() end },
			{},
			{ text = "Aimbot Auto Shoot/Aim - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/aimbot1.lua") end },
			{ text = "Aimbot Auto Shoot - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/aimbot2.lua") end },
			{},
			{ text = "Snatch Pager - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/pagersnitch.lua") end },
			{ text = "Dodge - ON/OFF", callback_func = function() dodge_menu() end },
		}
	}
	
	local godmode_menu_array = "input"
	if godmode_menu_table[godmode_menu_array] then
		for _, dostuff in pairs(godmode_menu_table[godmode_menu_array]) do
			if godmode_menu_table[godmode_menu_array] then
				table.insert(dialog_data.button_list, dostuff)
			end
		end
	end
	
	table.insert(dialog_data.button_list, {})
	local no_button = {text = managers.localization:text("dialog_cancel"),cancel_button = true}     
	table.insert(dialog_data.button_list, no_button)
	managers.system_menu:show_buttons(dialog_data)
end
menu()