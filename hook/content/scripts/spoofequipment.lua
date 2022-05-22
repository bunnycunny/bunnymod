if not Network:is_server() then
	if RequiredScript == "lib/network/base/basenetworksession" then
		local o_check_send_outfit = BaseNetworkSession.check_send_outfit
		function BaseNetworkSession:check_send_outfit(peer)
			if CommandManager["config"]["spoofinventory"] then
				Global.IS_SENDING_OUTFIT = true
				o_check_send_outfit(self, peer)
				Global.IS_SENDING_OUTFIT = false
			else
				o_check_send_outfit(self, peer)
			end
		end
	elseif RequiredScript == "lib/managers/blackmarketmanager" then
		local o_equipped_primary = BlackMarketManager.equipped_primary
		function BlackMarketManager:equipped_primary()
			if CommandManager["config"]["spoofinventory"] then
				local amcar = {
					["weapon_id"] = "amcar",
					["equipped"] = true,
					["global_values"] = {},
					["factory_id"] = "wpn_fps_ass_amcar",
					["blueprint"] = {
						[1] = "wpn_fps_m4_uupg_b_medium_vanilla",
						[2] = "wpn_fps_m4_lower_reciever",
						[3] = "wpn_fps_amcar_uupg_body_upperreciever",
						[4] = "wpn_fps_amcar_uupg_fg_amcar",
						[5] = "wpn_fps_upg_m4_m_straight_vanilla",
						[6] = "wpn_fps_upg_m4_s_standard_vanilla",
						[7] = "wpn_fps_upg_m4_g_standard_vanilla",
						[8] = "wpn_fps_amcar_bolt_standard",
					}
				}
				return Global.IS_SENDING_OUTFIT and amcar or o_equipped_primary(self)
			end
			return o_equipped_primary(self)
		end
	 
		local o_equipped_secondary = BlackMarketManager.equipped_secondary
		function BlackMarketManager:equipped_secondary()
			if CommandManager["config"]["spoofinventory"] then
				local glock = {
					["weapon_id"] = "glock_17",
					["equipped"] = true,
					["global_values" ] = {},
					["factory_id"] = "wpn_fps_pis_g17",
					["blueprint"] = {
						[1] = "wpn_fps_pis_g17_body_standard",
						[2] = "wpn_fps_pis_g17_b_standard",
						[3] = "wpn_fps_pis_g17_m_standard",
					}
				}
				return Global.IS_SENDING_OUTFIT and glock or o_equipped_secondary(self)
			end
			return o_equipped_secondary(self)
		end
	 
		local o_equipped_melee_weapon = BlackMarketManager.equipped_melee_weapon
		function BlackMarketManager:equipped_melee_weapon()
			if CommandManager["config"]["spoofinventory"] then
				return Global.IS_SENDING_OUTFIT and "weapon" or o_equipped_melee_weapon(self)
			end
			return o_equipped_melee_weapon(self)
		end
	 
		local o_equipped_grenade = BlackMarketManager.equipped_grenade
		function BlackMarketManager:equipped_grenade()
			if CommandManager["config"]["spoofinventory"] and Global.IS_SENDING_OUTFIT then 
				return "concussion", 6
			end
			return o_equipped_grenade(self) 
		end
	 
		local o_equipped_deployable = BlackMarketManager.equipped_deployable
		function BlackMarketManager:equipped_deployable(slot)
			if CommandManager["config"]["spoofinventory"] then
				return Global.IS_SENDING_OUTFIT and nil or o_equipped_deployable(self, slot)
			end
			return o_equipped_deployable(self, slot)
		end
	 
		local o_outfit_string_mask = BlackMarketManager._outfit_string_mask
		function BlackMarketManager:_outfit_string_mask()
			if CommandManager["config"]["spoofinventory"] then
				return Global.IS_SENDING_OUTFIT and "character_locked nothing-nothing no_color_no_material plastic" or o_outfit_string_mask(self)
			end
			return o_outfit_string_mask(self)
		end
	 
		local o_equipped_armor = BlackMarketManager.equipped_armor
		function BlackMarketManager:equipped_armor(chk_armor_kit, chk_player_state)
			if CommandManager["config"]["spoofinventory"] then
				return Global.IS_SENDING_OUTFIT and "level_1" or o_equipped_armor(self, chk_armor_kit, chk_player_state)
			end
			return o_equipped_armor(self, chk_armor_kit, chk_player_state)
		end
	 
		local o_equipped_armor_skin = BlackMarketManager.equipped_armor_skin
		function BlackMarketManager:equipped_armor_skin()
			if CommandManager["config"]["spoofinventory"] then
				return Global.IS_SENDING_OUTFIT and "none" or o_equipped_armor_skin(self)
			end
			return o_equipped_armor_skin(self)
		end
	 
		local o_equipped_player_style = BlackMarketManager.equipped_player_style
		function BlackMarketManager:equipped_player_style()
			if CommandManager["config"]["spoofinventory"] then
				return Global.IS_SENDING_OUTFIT and "none" or o_equipped_player_style(self)
			end
			return o_equipped_player_style(self)
		end
	 
		local o_get_suit_variation = BlackMarketManager.get_suit_variation
		function BlackMarketManager:get_suit_variation(player_style)
			if CommandManager["config"]["spoofinventory"] then
				return Global.IS_SENDING_OUTFIT and "default" or o_get_suit_variation(self)
			end
			return o_get_suit_variation(self)
		end
	 
		local o_equipped_glove_id = BlackMarketManager.equipped_glove_id
		function BlackMarketManager:equipped_glove_id()
			if CommandManager["config"]["spoofinventory"] then
				return Global.IS_SENDING_OUTFIT and "default" or o_equipped_glove_id(self)
			end
		return	o_equipped_glove_id(self)
		end--]]
	elseif RequiredScript == "lib/units/beings/player/playerinventory" then
		--hide weapon skins
		local orig_func_send_equipped_weapon = PlayerInventory._send_equipped_weapon
		function PlayerInventory:_send_equipped_weapon()
			if CommandManager["config"]["spoofinventory"] then
				local eq_weap_name = self:equipped_unit():base()._factory_id or self:equipped_unit():name()
				local index = self._get_weapon_sync_index(eq_weap_name)

				if not index then
					debug_pause("[PlayerInventory:_send_equipped_weapon] cannot sync weapon", eq_weap_name, self._unit)
					return
				end

				self._unit:network():send("set_equipped_weapon", index, "", "nil-1-0")
			else
				orig_func_send_equipped_weapon(self)
			end
		end
	end
else
	if managers.chat then
		managers.chat:_receive_message(1, "SpoofInv", string.format("Client Only!"), tweak_data.system_chat_color)
	end
end

if managers.mission then
	if not CommandManager["config"]["spoofinventory"] then
		managers.mission._fading_debug_output:script().log(string.format('SpoofInv - %s', (CommandManager.config["spoofinventory"] and "(ON)" or "(OFF)")), Color.red)
	else
		managers.mission._fading_debug_output:script().log(string.format('SpoofInv - %s', (CommandManager.config["spoofinventory"] and "(ON)" or "(OFF)")), Color.green)
	end
end