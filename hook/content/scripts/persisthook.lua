--dlc unlock
if CommandManager.config["unlock_dlcs"] then
	local orig_func__verify_dlcs = WINDLCManager._verify_dlcs
	function WINDLCManager._verify_dlcs(self, ...)
		orig_func__verify_dlcs(self, ...)
		for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
			if not dlc_data.verified then
				dlc_data.verified = true
			end
			if not dlc_name.no_install then
				dlc_name = {app_id = dlc_name.app_id, no_install = true}
			end
		end
	end
end--]]


-- Unlock Armor/style/glove Skins
if CommandManager.config.armor_skins and BlackMarketManager then
	function BlackMarketManager:_remove_unowned_armor_skin()
		local armor_skins = {}
		local player_styles = {}
		local player_gloves = {}
		
		for id, skin in pairs(tweak_data.economy.armor_skins) do
			if id then
				armor_skins[id] = {unlocked = true}
			end
		end
		Global.blackmarket_manager.armor_skins = armor_skins

		for player_style, data in pairs(tweak_data.blackmarket.player_styles) do
			if player_style then
				player_styles[player_style] = Global.blackmarket_manager.player_styles and Global.blackmarket_manager.player_styles[player_style] or {}
				player_styles[player_style].unlocked = true
				for var_id, var_data in pairs(data.material_variations or {}) do
					if var_id and var_data and player_styles[player_style].material_variations and player_styles[player_style].material_variations[var_id] then
						player_styles[player_style].material_variations[var_id].unlocked = false
					end
				end
			end
		end
		Global.blackmarket_manager.player_styles = player_styles
		
		for glove_id, data in pairs(tweak_data.blackmarket.gloves) do
			if glove_id and data then
				player_gloves[glove_id] = Global.blackmarket_manager.gloves and Global.blackmarket_manager.gloves[glove_id] or {}
				player_gloves[glove_id].unlocked = true
			end
		end
		Global.blackmarket_manager.gloves = player_gloves
		return false
	end
end


--anti anti cheat
local cheater = {}
if ProjectileBase then
	function ProjectileBase.check_time_cheat() return true end 
end

if HUDManager then
	local orig_func_h_mark_cheater = HUDManager.mark_cheater
	function HUDManager:mark_cheater(peer_id, ...)
		if peer_id ~= managers.network:session():local_peer():id() then
			orig_func_h_mark_cheater(self, peer_id, ...)
		elseif not cheater[peer_id] then
			cheater[peer_id] = true
			managers.chat:_receive_message(1, "AACheat", "You might have been marked as a cheater...", Color.red)
		end
	end
end

if PlayerManager then
	--bagcooldown
	function PlayerManager:carry_blocked_by_cooldown() return false end
	if CommandManager.config["trainer_buffs"] then
		function PlayerManager:body_armor_movement_penalty() return 1 end
	end
	
	if Network:is_server() and CommandManager.config["intimidate_units"] then
		local orig_func_upgrade_value = PlayerManager.upgrade_value
		function PlayerManager:upgrade_value(category, upgrade, ...) 
			if category == "player" and upgrade == "convert_enemies_max_minions" then
				return 1000
			end
			return orig_func_upgrade_value(self, category, upgrade, ...) 
		end
	end
end

if NetworkPeer then
	--anti anti cheat
	local orig_func_mark_cheater = NetworkPeer.mark_cheater
	function NetworkPeer:mark_cheater(...)
		if self:id() ~= managers.network:session():local_peer():id() then
			return orig_func_mark_cheater(self, ...)
		elseif not cheater[self:id()] then
			cheater[self:id()] = true
			managers.chat:_receive_message(1, "AACheat", "You might have been marked as a cheater...", Color.red)
		end
	end
	
	local orig_func_is_cheater = NetworkPeer.is_cheater
	function NetworkPeer:is_cheater(...) 
		if self:id() ~= managers.network:session():local_peer():id() then
			return orig_func_is_cheater(self, ...)
		end
	end
	function NetworkPeer:begin_ticket_session() return true end
	function NetworkPeer:on_verify_ticket() end
	function NetworkPeer:end_ticket_session() end
	function NetworkPeer:change_ticket_callback() end
	function NetworkPeer:tradable_verify_outfit() end
	function NetworkPeer:on_verify_tradable_outfit() end
	function NetworkPeer:verify_grenade() return true end
	function NetworkPeer:verify_deployable() return true end
end

if Network:is_server() and CopBrain and CopInventory and CopLogicAttack and CopLogicIntimidated and CopLogicArrest and CopLogicIdle and CopLogicSniper then
	--intimidate specials
	if CommandManager.config["intimidate_units"] then
		local surrender = CopLogicIdle._surrender
		local on_intimidated = CopLogicIdle.on_intimidated
		local function run_function(data, amount, aggressor_unit, ...)
			if (data.unit:base()._tweak_table == "phalanx_vip") or (data.unit:base()._tweak_table == "phalanx_minion") then
				return on_intimidated(data, amount, aggressor_unit, ...)
			end
			return surrender(data, amount, aggressor_unit)
		end
		CopLogicIdle.on_intimidated = run_function
		CopLogicArrest.on_intimidated = run_function
		CopLogicSniper.on_intimidated = run_function

		--Shield logic
		CopBrain._logic_variants.shield.intimidated = CopLogicIntimidated
		local _do_tied = CopLogicIntimidated._do_tied
		local _chk_spawn_shield = CopInventory._chk_spawn_shield
		local on_intimidated = CopLogicIntimidated.on_intimidated
		function CopLogicIntimidated.on_intimidated(data, amount, aggressor_unit, ...) 
			if data.unit:base()._tweak_table == "shield" then
				_do_tied(data, aggressor_unit)
				_chk_spawn_shield(data.unit:inventory())
			else
				on_intimidated(data, amount, aggressor_unit, ...)
			end
		end
	end
	
	--hostages always follow
	local old_set_objective = CopBrain.set_objective
	function CopBrain:set_objective(new_objective, params)
		if new_objective and new_objective.lose_track_dis then new_objective.lose_track_dis = 5000000 end
		old_set_objective(self, new_objective, params)
	end
end--]]

if GroupAIStateBase and CommandManager.config["intimidate_units"] then
	function GroupAIStateBase:has_room_for_police_hostage()
		return 9999 > self._police_hostage_headcount + table.size(self._converted_police)
	end
end

-- Remove loot cap
if tweak_data and LootManager then
	tweak_data.money_manager.max_small_loot_value = 9999999999999999	
	local LootManager_get_secured_bonus_bags_value = LootManager.get_secured_bonus_bags_value
	function LootManager:get_secured_bonus_bags_value( level_id )
		local mandatory_bags_amount = self._global.mandatory_bags.amount or 0
		local value = 0
		for _,data in ipairs( self._global.secured ) do
			if not tweak_data.carry.small_loot[ data.carry_id ] then
				if mandatory_bags_amount > 0 and (self._global.mandatory_bags.carry_id == "none" or self._global.mandatory_bags.carry_id == data.carry_id) then
					mandatory_bags_amount = mandatory_bags_amount - 1
				end
				value = value + managers.money:get_bag_value( data.carry_id, data.multiplier )
		end	end
		return value
	end
end

--job heat
if CommandManager.config["trainer_job_heat"] and JobManager then
	function JobManager:on_buy_job() return end
end

--dropin p
if BaseNetworkSession and MenuManager then
	_networkgameLoadOriginal = _networkgameLoadOriginal or BaseNetworkSession.load
	function BaseNetworkSession:load( ... )
		_networkgameLoadOriginal(self, ...)
		Application:set_pause( false )
	end
	_dropInOriginal = _dropInOriginal or BaseNetworkSession.on_drop_in_pause_request_received
	function BaseNetworkSession:on_drop_in_pause_request_received( peer_id, ... )
		if state then
			if not managers.network:session():closing() then
				managers.hud:show_hint( { text = managers.localization:text( "dialog_dropin_title", { USER = string.upper( nickname ) } ) } )
			end
		elseif self._dropin_pause_info[ peer_id ] then
			managers.hud:show_hint( { text = "Player Joined" } ) 
		end
		_dropInOriginal(self, peer_id, ... )
		Application:set_pause( false )
		SoundDevice:set_rtpc( "ingame_sound", 1 )
	end
	function MenuManager:show_person_joining( ... ) end
end
 
--display cleaner cost
if MoneyManager then
	counter = counter or 0
	old_civ_killed = old_civ_killed or MoneyManager.civilian_killed
	function MoneyManager:civilian_killed() 
		old_civ_killed(self)
		counter = counter + 1
		amount = self:get_civilian_deduction() * counter
		managers.hud:show_hint({text = "Killed "..tostring(counter).." civilians, paid $"..tostring(amount).." cleaner costs."})
	end
	
	-- no civ penalty
	--MoneyManager.get_civilian_deduction = function(self) return 0 end
end

--No flashbangs
if CoreEnvironmentControllerManager then
	function CoreEnvironmentControllerManager.set_flashbang() end
end

--stamina
if CommandManager.config["trainer_buffs"] then
	if PlayerMovement then
		--inf stamina
		function PlayerMovement:_change_stamina( value ) end
		function PlayerMovement:is_stamina_drained() return false end
		
		--bleedout when cloaker
		function PlayerMovement:on_SPOOCed(enemy_unit)
			if managers.player:has_category_upgrade("player", "counter_strike_spooc") and self._current_state.in_melee and self._current_state:in_melee() then
				self._current_state:discharge_melee()
				return "countered"
			end

			if self._unit:character_damage()._god_mode or self._unit:character_damage():get_mission_blocker("invulnerable") then
				return
			end

			if self._current_state_name == "standard" or self._current_state_name == "carry" or self._current_state_name == "bleed_out" or self._current_state_name == "tased" or self._current_state_name == "bipod" then
				managers.player:set_player_state(managers.modifiers:modify_value("PlayerMovement:OnSpooked", "incapacitated"))
				managers.player:set_player_state(managers.modifiers:modify_value("PlayerMovement:OnSpooked", "bleed_out"))
				managers.achievment:award(tweak_data.achievement.finally.award)
				return true
			end
		end
	end
	if PlayerStandard then
		--run any direction
		function PlayerStandard:_can_run_directional() return true end
	end
	--bleedout when tased
	if PlayerTased then
		function PlayerTased:clbk_exit_to_fatal()
			self._fatal_delayed_clbk = nil

			managers.player:set_player_state("incapacitated")
			managers.player:set_player_state("bleed_out")
		end
	end
end

-- Interact through walls
if ObjectInteractionManager then
	function ObjectInteractionManager._raycheck_ok() return true end
end

--remove bullet delay
if GamePlayCentralManager then
	function GamePlayCentralManager:play_impact_sound_and_effects( params )
		self:_play_bullet_hit(params)
	end

	local orig_GPCMP = GamePlayCentralManager.start_heist_timer
	function GamePlayCentralManager.start_heist_timer(self)
		orig_GPCMP(self)
		--open dupsters that cant be opened
		local dumpsters = { 	
			["1cbee76c179b5192"] = true, --units/pd2_dlc_brb/props/brb_prop_alley_trash_container/brb_prop_alley_trash_container
			["cfe6b1dca77ba461"] = true, --units/payday2/props/str_prop_alley_trash_container/str_prop_alley_trash_container
			["421a4ea84848010c"] = true,  --units/world/street/trash_container/trash_container
		}
		for i,unit in pairs(World:find_units_quick("all", 1)) do
			if type(unit) ~= "number" and unit:name() and dumpsters[unit:name():key()] then 
				unit:interaction():set_active(true)
			end
		end
	end
end


--can interact with multiple cams
if Network:is_server() and SecurityCameraInteractionExt then
	function SecurityCameraInteractionExt:_interact_blocked(player)
		SecurityCamera.active_tape_loop_unit = false
	end
end

-- Carry mods (throwing distance, movement speed, jumping, running)
local car_arr = {'slightly_very_heavy', 'slightly_heavy', 'very_heavy', 'being', 'mega_heavy', 'heavy', 'medium', 'light', 'coke_light', 'cloaker_explosives'}
for i, name in ipairs(car_arr) do
	if tweak_data then
		tweak_data.carry.types[name].throw_distance_multiplier = 1
		tweak_data.carry.types[name].move_speed_modifier = 1
		tweak_data.carry.types[name].jump_modifier = 1
		tweak_data.carry.types[name].can_run = true
	end
end--]]
if tweak_data then
	tweak_data.interaction.open_from_inside.axis = nil
	tweak_data.character.civilian.hostage_move_speed = 3
end

--deploy bipod anywhere
if WeaponLionGadget1 then
	function WeaponLionGadget1:_is_deployable() 
		return not (self._is_npc or not self:_get_bipod_obj() or self:_is_in_blocked_deployable_state())
	end
end
if NewRaycastWeaponBase then
	function NewRaycastWeaponBase:is_bipod_usable() return true end
end

--trade delay
if CommandManager.config["trainer_buffs"] then
	if TradeManager then
		TradeManager.TRADE_DELAY = 2
		TradeManager._STOCKHOLM_SYNDROME_DELAY = 2 
	end
end

--free camera anywhere. works when interact too
if FPCameraPlayerBase then
	function FPCameraPlayerBase:set_limits(spin, pitch) end
end

--dont take dmg when in vehicle
if PlayerDamage and CommandManager.config["trainer_buffs"] then
	local old_check_dmg = PlayerDamage._chk_can_take_dmg
	function PlayerDamage:_chk_can_take_dmg()
		return not managers.player:get_vehicle() and old_check_dmg(self)
	end
end

--fast zipline, host only
if Network:is_server() and ZipLine then
	function ZipLine:update(unit, t, dt)
		if not self._enabled then
			return
		end
		if self._usage_type == "bag" then
			self._speed = 3000
		else
			self._speed = 1000
		end
		self:_update_total_time()
		self:_update_sled(t, dt)
		self:_update_sounds(t, dt)
		if ZipLine.DEBUG then
			self:debug_draw(t, dt)
		end
	end
end

--anti slow time
if UnitNetworkHandler then
	local slowmo_reverse = true
	local heist_lock = true
	local bounce_lock = {0, 0, 0, 0}
	local reset_bounce = function(id)
		bounce_lock[id] = 1
	end

	local start_time_effect = UnitNetworkHandler.start_timespeed_effect
	function UnitNetworkHandler:start_timespeed_effect(effect_id, timer_name, affect_timer_names_str, speed, fade_in, sustain, fade_out, sender)
		if heist_lock and sustain <= 10 and Global.game_settings.level_id == 'mia_2' and (affect_timer_names_str == nil or affect_timer_names_str == "player;") then
			start_time_effect(self, effect_id, timer_name, affect_timer_names_str, speed, fade_in, sustain, fade_out, sender)
			heist_lock = false
			managers.chat:_receive_message(1, "anti_slow_time", "Slow Time Disabled", tweak_data.system_chat_color)
		else
			local peer = self._verify_sender(sender)
			if not peer then
				managers.chat:_receive_message(1, "anti_slow_time2", "Someone tried use slow time on you...", tweak_data.system_chat_color)
				return
			end
			local id = peer:id()
			local cur_bounce = bounce_lock[id]
			if slowmo_reverse then
				if cur_bounce < 4 then
					bounce_lock[id] = cur_bounce + 1
					peer:send('start_timespeed_effect', effect_id, timer_name, affect_timer_names_str, speed, fade_in, sustain, fade_out)
					DelayedCalls:Add( "bounce_lock_reset_", 10, function() reset_bounce(id) end)
				else
					reset_bounce(id)
				end
			end
			if cur_bounce == 0 then
				managers.chat:_receive_message(1, "anti_slow_time3", peer:name().." tried to use slowmotion on you...Revenge ACTIVATED", tweak_data.system_chat_color) 
			end
		end
	end
end

if not SystemFS:exists("mods/TheCooker/mod.txt") and string.lower(RequiredScript) == "core/lib/managers/mission/coremissionscriptelement" and MissionScriptElement and CommandManager.config["trainer_buffs"] then
	local orig_MissionScriptElement_init = MissionScriptElement.init
	function MissionScriptElement.init(self, ...)
		orig_MissionScriptElement_init(self, ...)
		local id_level = managers.job:current_level_id()
		if (id_level == "rat") then
			--top floor
			if (self._id == 100329) then
				--self._values.rotation = Rotation(-90, 0, -0)
				--self._values.position = Vector3(1964.79, 700.00, 2100.00)
			end
			--basement
			if (self._id == 100332) then
				--self._values.rotation = Rotation(-90, 0, -0)
				--self._values.position = Vector3(1964.79, 700.00, 2100.00)
			end
			--middle floor spawn roof
			if (self._id == 100330) then
				self._values.rotation = Rotation(-90, 0, -0)
				self._values.position = Vector3(1964.79, 700.00, 2100.00)
			end
			--enable basement lab
			if (self._id == 100486) then
				self._values.enabled = true
			end
			--disable middle upper floors
			if (self._id == 100483) or (self._id == 100485) then
				--self._values.enabled = false
				--self._values.enabled = false
			end
		elseif level_id == "kosugi" then
			--enable spawn container all the time shadow raid
			if (self._id == 100303) then
				self._values.enabled = false
			end
		end
	end
end
dofile("mods/hook/content/scripts/persist.lua")