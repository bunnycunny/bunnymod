local req_script = table.remove(RequiredScript:split("/"))
	
--enable to find lobbies with these mods in crimenet or false to ignore
if string.lower(req_script) == string.lower("networkmatchmakingsteam") then
	local mods_to_find_on_crimenet = {
		["SuperBLT"] = CommandManager.config.filter_modded_lobbies,
		["p3d"] = false,
		["Silent Assassin"] = true,
		["the cooker"] = false,
		["AntiCheat"] = false,
		["kicker"] = false,
		["hud"] = false
	}

	local orig_func_is_server_ok = NetworkMatchMakingSTEAM.is_server_ok
	function NetworkMatchMakingSTEAM:is_server_ok(friends_only, room, attributes_list, ...)
		local result, error = orig_func_is_server_ok(self, friends_only, room, attributes_list, ...)
		if CommandManager.config.filter_modded_lobbies then
			if attributes_list.mods then
				for filter_name, enabled in pairs(mods_to_find_on_crimenet) do 
					if enabled then
						local s_s = string.split(attributes_list.mods, "|")
						for _, server_mod_name in pairs(s_s) do 
							if (server_mod_name:lower() == filter_name:lower()) or server_mod_name:lower():match(filter_name:lower()) then
								return result, error
							end
						end
					end
				end
			else
				return result, error
			end
		else
			return result, error
		end
	end
end

--add to crash players with these mods on joining them or they join you
if string.lower(req_script) == string.lower("connectionnetworkhandler") then
	local mods_to_find_on_crimenet = {
		"PD AntiCheat"
	}
	
	local function terminate(peer, mod_friendly_name)
		local name = peer:name()
		local user_id = peer:user_id()
		local unit = peer:unit()
		local id = peer:id()
		local session = managers.network and managers.network:session()
		
		if not session then
			return
		end
		
		managers.chat:send_message(1, managers.network.account:username(), string.format("%s is using '%s' mod, terminating him...", name, mod_friendly_name))
		
		if not managers.ban_list:banned(user_id) then
			managers.ban_list:ban(user_id, name)
		end
		
		session:send_to_peer(peer, "first_aid_kit_sync", unit, true, "2")
		session:send_to_peer(peer, "sync_interaction_anim", unit, true, {})
		session:send_to_peer(peer, "set_pose", unit, 123456)
		session:send_to_peer(peer, "set_equipped_weapon", unit, "wpn_fps_pis_ppk", 0, 0)
		session:send_to_peer(peer, "set_weapon_gadget_state", unit, true)
		session:send_to_peer(peer, "set_weapon_gadget_color", unit, true, true, true)
		session:send_to_peer(peer, "set_look_dir", unit, true, true)
		session:send_to_peer(peer, "suppression", managers.player._players[id], {""})
		session:send_to_peer(peer, "sentrygun_sync_armor_piercing",  nil, true)
		
		if not Network:is_server() then
			if session:_local_peer_in_lobby() then
				MenuCallbackHandler:_dialog_leave_lobby_yes()
			elseif game_state_machine:current_state_name() ~= "menu_main" then
				MenuCallbackHandler:_dialog_end_game_yes()
			end
		end
	end
	
	function ConnectionNetworkHandler:sync_player_installed_mod(peer_id, mod_id, mod_friendly_name, sender)
		local peer = self._verify_sender(sender)
		
		if not peer then
			return
		end
		
		if type(mod_id) ~= "string" or type(mod_friendly_name) ~= "string" then
			return terminate(peer, mod_friendly_name)
		end
		
		if peer:name():find("^%[P3DHack]") then
			return terminate(peer, "P3DHack")
		end
		
		for _, v in pairs(mods_to_find_on_crimenet) do
			local value = v:lower()
			local matched = mod_friendly_name:lower():match(value) or mod_id:lower():match(value)
			if matched then
				return terminate(peer, mod_friendly_name)
			end
		end
		peer:register_mod(mod_id, mod_friendly_name)
	end
end

--remove hook mod from player lists
if string.lower(req_script) == string.lower("menumanager") then
	local mod_to_hide = {
		["HD Masks"] = true
	}
	local mods_to_hide = _G["CommandManager"].config2 and _G["CommandManager"].config2.mod_list
	local orig_func_build_mods_list = MenuCallbackHandler.build_mods_list
	function MenuCallbackHandler:build_mods_list(...)
		local mods = orig_func_build_mods_list(self, ...)
		for k, data in ipairs(mods) do
			if type(mods_to_hide) == "table" and mods_to_hide[k] and mods_to_hide[k].enable or mod_to_hide[data[1]] then 
				mods[k] = {[1] = "", [2] = ""}
			end
		end
		return mods
	end
	
	--[[no modded lobby
	function MenuCallbackHandler:is_modded_client()
		return false
	end
	function MenuCallbackHandler:is_not_modded_client()
		return true
	end--]]
end