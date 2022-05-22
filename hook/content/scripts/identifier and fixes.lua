--mod match identifier
if _G["NetworkPeer"] ~= nil then
	--add you in player list
	local orig_peer_init = NetworkPeer.init
	function NetworkPeer:init(...)
		orig_peer_init(self, ...)
		
		local local_peer = false
		if self._rpc then
			if self._rpc:ip_at_index(0) == Network:self("TCP_IP"):ip_at_index(0) then
				local_peer = true
			end
		elseif self._steam_rpc and self._steam_rpc:ip_at_index(0) == Network:self("STEAM"):ip_at_index(0) then
			local_peer = true
		end
		
		if local_peer and MenuCallbackHandler.build_mods_list then
			self._mods = self._mods or {}
			for k,v in ipairs(MenuCallbackHandler:build_mods_list() or {}) do
				self:register_mod(v[2], v[1])
			end
		end
	end
	
	function NetworkPeer:real_name()
		if not self._real_name then
			self._real_name = Steam:username(self._user_id)
		end
		return self._real_name
	end
end

--fix arrow bounce on low charge
if _G["BowWeaponBase"] then
	function BowWeaponBase:charge_fail()
		return false
	end
end

--displays the real name of people
if _G["ConnectionNetworkHandler"] then
	ConnectionNetworkHandler.stored_names = {}
	function ConnectionNetworkHandler:request_player_name_reply(name, sender)
		local peer = self._verify_sender(sender)
		if not peer then
			return
		end

		if self.stored_names[peer._user_id] == nil then
			local real_name = peer:real_name()
			self.stored_names[peer._user_id] = real_name
			if real_name and tostring(name) ~= tostring(real_name) then
				DelayedCalls:Add('real2', 2, function()
					if _G["GameSetupUpdate"] == nil and _G["MenuUpdate"] == nil then return end
					if managers.chat then
						local s_f = string.format("%s's steam name did not match with their game username: %s", real_name, name)
						managers.chat:_receive_message(1, "Name Spoof", s_f, tweak_data.system_chat_color)
					end
				end)
				local string_F = string.format("%s (%s)", real_name, name)
				peer:set_name(string_F)
			else
				peer:set_name(real_name)
			end
		end
	end
end

--[string "lib/network/base/handlers/basenetworkhandler.lua"]:46: attempt to index local 'rpc' (a nil value)
if _G["BaseNetworkHandler"] then
	function BaseNetworkHandler._verify_sender(rpc)
		local session = managers.network:session()
		local peer = nil

		if session and type(rpc) == "userdata" then
			if rpc:protocol_at_index(0) == "STEAM" then
				peer = session:peer_by_user_id(rpc:ip_at_index(0))
			else
				peer = session:peer_by_ip(rpc:ip_at_index(0))
			end

			if peer then
				return peer
			end
		end

		print("[BaseNetworkHandler._verify_sender] Discarding message", session, peer and peer:id())
		Application:stack_dump()
	end
end

--[string "lib/network/matchmaking/networkvoicechatsteam..."]:113: attempt to perform arithmetic on field 'time' (a nil value)
if _G["NetworkVoiceChatSTEAM"] then
	local orig_func_NetworkVoiceChatSTEAM_update = NetworkVoiceChatSTEAM.update
	function NetworkVoiceChatSTEAM:update()
		local playing = self.handler:get_voice_receivers_playing()
		for id, pl in pairs(playing) do
			if pl and self._users_talking[id] and self._users_talking[id].time then
				orig_func_NetworkVoiceChatSTEAM_update(self)
			end
		end
	end
end

--[string "lib/managers/menu/lootdropscreengui.lua"]:360: attempt to call method 'set_selected' (a nil value)
if _G["LootDropScreenGui"] then
	function LootDropScreenGui:set_selected(selected)
		local new_selected = math.clamp(selected, 1, 3)

		if new_selected ~= self._selected and self._lootscreen_hud and self._id and self._lootscreen_hud.set_selected then
			self._selected = new_selected
			
			self._lootscreen_hud:set_selected(self._id, self._selected)
			managers.menu_component:post_event("highlight")

			return true
		end

		return false
	end
end

--[string "lib/units/enemies/cop/logics/coplogicbase.lua"]:1551: attempt to index local 'data' (a nil value)
if _G["TeamAIDamage"] then
	local orig_func_inc_dodge_count = TeamAIDamage.inc_dodge_count
	function TeamAIDamage:inc_dodge_count(n)
		if alive(self._unit) and self._unit:brain() and self._unit:brain()._logic_data then
			orig_func_inc_dodge_count(self, n)
		end
		return
	end
end

if _G["PrePlanningManager"] then
	--[string "lib/managers/preplanningmanager.lua"]:1005: attempt to index a nil value
	local orig_get_element_name_by_type_index = PrePlanningManager.get_element_name_by_type_index
	function PrePlanningManager:get_element_name_by_type_index(type, index)
		if not type then
			return "error"
		end
		if not index then
			return "error"
		end
		if self._mission_elements_by_type[type] == nil or self._mission_elements_by_type[type][index] == nil then
			return "error"
		end
		if managers.localization:exists("menu_" .. self._mission_elements_by_type[type][index]:editor_name()) then
			return managers.localization:text("menu_" .. self._mission_elements_by_type[type][index]:editor_name())
		end
		return orig_get_element_name_by_type_index(self, type, index)
	end
end

--fixes lib/managers/gameplaycentralmanager.lua"]:634: attempt to call method 'flashlight_state_changed' (a nil value)
if _G["GamePlayCentralManager"] then
	function GamePlayCentralManager:set_flashlights_on(flashlights_on)
		if self._flashlights_on == flashlights_on then
			return
		end

		self._flashlights_on = flashlights_on
		local weapons = World:find_units_quick("all", 13)

		for _, weapon in ipairs(weapons) do
			if weapon:base().flashlight_state_changed then
				weapon:base():flashlight_state_changed()
			end
		end
	end
end

if SentryGunFireModeInteractionExt then
	--"lib/units/interactions/interactionext.lua"]:1304: attempt to index field '_sentry_gun_weapon' (a nil value)
	local orig_func_interact = SentryGunFireModeInteractionExt.interact
	function SentryGunFireModeInteractionExt:interact(player)
		if not self._sentry_gun_weapon then return false end
		orig_func_interact(self, player)
	end
	
	local function sentry_gun_interaction_add_string_macros(macros, ammo_ratio)
		macros.BTN_INTERACT = managers.localization:btn_macro("interact", true)

		if ammo_ratio == 1 then
			macros.AMMO_LEFT = 100
		elseif ammo_ratio > 0 then
			local ammo_left = string.format("%.2f", tostring(ammo_ratio))
			ammo_left = string.sub(ammo_left, 3, 4)
			macros.AMMO_LEFT = ammo_left
		else
			macros.AMMO_LEFT = 0
		end
	end
	
	function SentryGunFireModeInteractionExt:_add_string_macros(macros)
		if self._sentry_gun_weapon then
			local ammo_ratio = Network:is_server() and self._sentry_gun_weapon:ammo_ratio() or self._sentry_gun_weapon:get_virtual_ammo_ratio()
			sentry_gun_interaction_add_string_macros(macros, ammo_ratio)
		end
	end
end

--fixes "lib/units/beings/player/states/playerdriving.lua"]:38: attempt to index local 'enter_data' (a nil value)
--try enter vehicle when civ mode
if _G["PlayerDriving"] then
	function PlayerDriving:enter(state_data, enter_data)
		PlayerDriving.super.enter(self, state_data, enter_data)
		for _, ai in pairs(managers.groupai:state():all_AI_criminals()) do
			if ai.unit:movement() and ai.unit:movement()._should_stay then
				ai.unit:movement():set_should_stay(false)
			end
		end

		if enter_data then
			self._was_unarmed = enter_data.was_unarmed
		else
			self._was_unarmed = false
			managers.chat:feed_system_message(ChatManager.GAME, "State: Standard")
		end
	end
end

--lib/units/beings/player/playerdamage.lua"]:1839: attempt to perform arithmetic on field '_downed_paused_counter' (a nil value)
if _G["PlayerDamage"] then
	function PlayerDamage:pause_downed_timer(timer, peer_id)
		if not self._downed_paused_counter or self._downed_paused_counter == nil then
			self._downed_paused_counter = tweak_data.player.damage.DOWNED_TIME
		end
		self._downed_paused_counter = self._downed_paused_counter + 1

		self:set_peer_paused_counter(peer_id, "downed")

		if self._downed_paused_counter == 1 then
			managers.hud:pd_pause_timer()
			managers.hud:pd_start_progress(0, timer or tweak_data.interaction.revive.timer, "debug_interact_being_revived", "interaction_help")
		end

		if Network:is_server() then
			managers.network:session():send_to_peers("pause_downed_timer", self._unit)
		end
	end
end

if _G["PlayerManager"] then
	--fixes [string "lib/managers/playermanager.lua"]:333: attempt to index field '_ammo_efficiency' (a number value)
	function PlayerManager:damage_absorption()
		local total = 0

		if not managers.network:session() or not managers.network:session():local_peer() or not alive(managers.player:player_unit()) then
			return total
		end
		
		if not self:get_best_cocaine_damage_absorption(managers.network:session():local_peer():id()) or not managers.modifiers:modify_value("PlayerManager:GetDamageAbsorption", total) then
			return total
		end
		
		for _, absorption in pairs(self._damage_absorption) do
			if absorption then
				total = total + Application:digest_value(absorption, false)
			end
		end
		
		total = total + self:get_best_cocaine_damage_absorption(managers.network:session():local_peer():id())
		total = managers.modifiers:modify_value("PlayerManager:GetDamageAbsorption", total)

		return total
	end
	
	--[string "lib/managers/playermanager.lua"]:4012: attempt to index local 'equipment' (a nil value)
	local orig_func_add_sentry_gun = PlayerManager.add_sentry_gun
	function PlayerManager:add_sentry_gun(num, sentry_type, ...)
		local equipment, index = self:equipment_data_by_name(sentry_type)
		if equipment and index then
			orig_func_add_sentry_gun(self, num, sentry_type, ...)
		end
	end
end

if _G["UnitNetworkHandler"] then
	
	--[string "lib/units/beings/player/playerdamage.lua"]:1839: attempt to perform arithmetic on field '_downed_paused_counter' (a nil value)
	local origfunc_start_revive_player = UnitNetworkHandler.start_revive_player
	function UnitNetworkHandler:start_revive_player(timer, sender, ...)
		if timer and not (timer == nil) then
			origfunc_start_revive_player(self, timer, sender, ...)
		end
	end

	--[string "lib/network/handlers/unitnetworkhandler.lua"]:3503: attempt to index local 'unit' (a nil value)
	local origfunc_sync_drill_upgrades = UnitNetworkHandler.sync_drill_upgrades
	function UnitNetworkHandler:sync_drill_upgrades(unit, autorepair_level_1, autorepair_level_2, drill_speed_level, silent, reduced_alert, ...)
		if not unit then
			return
		end
		origfunc_sync_drill_upgrades(self, unit, autorepair_level_1, autorepair_level_2, drill_speed_level, silent, reduced_alert, ...)
	end

	--[string "lib/network/handlers/unitnetworkhandler.lua"]:264: attempt to call method 'sync_action_change_pose' (a nil value)
	local origfunc_action_change_pose = UnitNetworkHandler.action_change_pose
	function UnitNetworkHandler:action_change_pose(unit, pose_code, pos, ...)
		-- Unit must exist and be alive, unit must have a movement environment and must have a variable named sync_action_change_pose.
		-- pose_code and pos must be non-null values
		if (unit and alive(unit)) and (unit:movement() and unit:movement().sync_action_change_pose and pose_code and pos) then
			origfunc_action_change_pose(self, unit, pose_code, pos, ...)
		end
	end
	CommandManager:vis("anticrash")
end