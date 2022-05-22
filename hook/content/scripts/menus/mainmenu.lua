local function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end

local function in_mainmenu()
	if (game_state_machine:current_state_name() == "menu_main") then
		return true
	end
	return false
end

local dialog_data = {    
	title = "Trainer Buff Menu",
	text = "Select Option",
	button_list = {}
}

local buff_table = {
	{ text = string.format("Toggle buffs from trainer - ON/OFF - %s", (CommandManager.config["trainer_buffs"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.trainer_buffs = not CommandManager.config.trainer_buffs
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["trainer_buffs"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Filter modded lobbies - ON/OFF - %s", (CommandManager.config["filter_modded_lobbies"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.filter_modded_lobbies = not CommandManager.config.filter_modded_lobbies
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["filter_modded_lobbies"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle experience hud - ON/OFF - %s", (CommandManager.config["show_experience_hud"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.show_experience_hud = not CommandManager.config.show_experience_hud
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["show_experience_hud"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle sixth sense range/update time - ON/OFF - %s", (CommandManager.config["sixth_sense_buff"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.sixth_sense_buff = not CommandManager.config.sixth_sense_buff
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["sixth_sense_buff"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle buffs for melee weapons - ON/OFF - %s", (CommandManager.config["trainer_melee_damage_buffs"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.trainer_melee_damage_buffs = not CommandManager.config.trainer_melee_damage_buffs
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["trainer_melee_damage_buffs"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle buffs for snipers - ON/OFF - %s", (CommandManager.config["weapon_tweak_sniper_shake_buffs"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.weapon_tweak_sniper_shake_buffs = not CommandManager.config.weapon_tweak_sniper_shake_buffs
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["weapon_tweak_sniper_shake_buffs"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle buffs for weapon ammo - ON/OFF - %s", (CommandManager.config["weapon_tweak_ammo_buffs"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.weapon_tweak_ammo_buffs = not CommandManager.config.weapon_tweak_ammo_buffs
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["weapon_tweak_ammo_buffs"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle buffs for weapons stats - ON/OFF - %s", (CommandManager.config["weapon_tweak_buffs"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.weapon_tweak_buffs = not CommandManager.config.weapon_tweak_buffs
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["weapon_tweak_buffs"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle buffs for armor - ON/OFF - %s", (CommandManager.config["armor_buff"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.armor_buff = not CommandManager.config.armor_buff
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["armor_buff"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle buffs for perks - ON/OFF - %s", (CommandManager.config["perk_buff"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.perk_buff = not CommandManager.config.perk_buff
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["perk_buff"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle auto pickup sentries - ON/OFF - %s", (CommandManager.config["sentry_auto_pickup"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.sentry_auto_pickup = not CommandManager.config.sentry_auto_pickup
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["sentry_auto_pickup"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle buffs for sentries - ON/OFF - %s", (CommandManager.config["sentry_buffs"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.sentry_buffs = not CommandManager.config.sentry_buffs
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["sentry_buffs"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle armor for stoic - ON/OFF - %s", (CommandManager.config["custom_stoic"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.custom_stoic = not CommandManager.config.custom_stoic
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["custom_stoic"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle auto flask for kingpin - ON/OFF - %s", (CommandManager.config["auto_kingpin"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.auto_kingpin = not CommandManager.config.auto_kingpin
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["auto_kingpin"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle heat for jobs - ON/OFF - %s", (CommandManager.config["trainer_job_heat"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.trainer_job_heat = not CommandManager.config.trainer_job_heat
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["trainer_job_heat"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle remove free crimenet jobs - ON/OFF - %s", (CommandManager.config["remove_free_jobs"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.remove_free_jobs = not CommandManager.config.remove_free_jobs
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["remove_free_jobs"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle carry more special items - ON/OFF - %s", (CommandManager.config["trainer_carry_specials_buffs"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.trainer_carry_specials_buffs = not CommandManager.config.trainer_carry_specials_buffs
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["trainer_carry_specials_buffs"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Unlock all skills (undetectable) - ON/OFF - %s", (CommandManager.config["unlock_all_skills"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.unlock_all_skills = not CommandManager.config.unlock_all_skills
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["unlock_all_skills"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Unlock sentry skills (undetectable) - ON/OFF - %s", (CommandManager.config["unlock_sentry_skills"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.unlock_sentry_skills = not CommandManager.config.unlock_sentry_skills
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["unlock_sentry_skills"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle low blow skill for sentries - ON/OFF - %s", (CommandManager.config["sentry_crit"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.sentry_crit = not CommandManager.config.sentry_crit
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["sentry_crit"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Spoof Equipment client side - ON/OFF - %s", (CommandManager.config["spoofinventory"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.spoofinventory = not CommandManager.config.spoofinventory
		CommandManager:Save()
		trainer_buffs()
		dofile("mods/hook/content/scripts/spoofequipment.lua") 
	end },
	{ text = string.format("Intimidate All Units (Host) - ON/OFF - %s", (CommandManager.config["intimidate_units"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.intimidate_units = not CommandManager.config.intimidate_units
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["intimidate_units"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Double Jump - ON/OFF - %s", (CommandManager.config["double_jump"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.double_jump = not CommandManager.config.double_jump
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["double_jump"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle Asset spawning on all heists - ON/OFF - %s", (CommandManager.config["package_loading"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.package_loading = not CommandManager.config.package_loading
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["package_loading"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Unlock weapon skins - ON/OFF - %s", (CommandManager.config["weapon_skins"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.weapon_skins = not CommandManager.config.weapon_skins
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["weapon_skins"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Unlock armor skins - ON/OFF - %s", (CommandManager.config["armor_skins"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.armor_skins = not CommandManager.config.armor_skins
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["armor_skins"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Unlock dlcs - ON/OFF - %s", (CommandManager.config["unlock_dlcs"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.unlock_dlcs = not CommandManager.config.unlock_dlcs
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["unlock_dlcs"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle free preplanning - ON/OFF - %s", (CommandManager.config["preplanning_cost"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.preplanning_cost = not CommandManager.config.preplanning_cost
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["preplanning_cost"] and "(ON)" or "(OFF)")), Color.green)
	end },
	{ text = string.format("Toggle preplanning host plan only - ON/OFF - %s", (CommandManager.config["preplanning_matter"] and "(ON)" or "(OFF)")), callback_func = function() 
		CommandManager.config.preplanning_matter = not CommandManager.config.preplanning_matter
		CommandManager:Save()
		trainer_buffs()
		managers.mission._fading_debug_output:script().log(string.format("%s", (CommandManager.config["preplanning_matter"] and "(ON)" or "(OFF)")), Color.green)
	end },
}

if is_playing() then
	local pickup_sentrys = function()
		local sentryOwner, peerID, mySentry, sentrySilentName, sentryLoudName
		sentrySilentName = "Idstring(@IDc71d763cd8d33588@)"
		sentryLoudName = "Idstring(@IDb1f544e379409e6c@)"
		peerID = managers.network:session()._local_peer._id or 1

		for _,unit in ipairs(World:find_units_quick("all")) do 
			if unit:interaction() then
				sentryOwner = unit:interaction()._owner_id
				mySentry = sentryOwner == peerID
				if mySentry then
					if tostring(unit:name()) == sentryLoudName or tostring(unit:name()) == sentrySilentName then
						unit:interaction():interact()
						managers.network:session():send_to_peers_synched("remove_unit", unit)
					end
				end
			end
		end
		managers.mission._fading_debug_output:script().log('Pickup ACTIVATED', Color.green)
	end
	
	local function sentryammo()
		local sentryOwner, peerID, mySentry, sentryChangeAmmo
		sentryChangeAmmo = "Idstring(@IDcd80f34f2777d102@)"
		peerID = managers.network:session()._local_peer._id or 1

		for _,unit in ipairs(World:find_units_quick("all")) do 
			if unit:interaction() then
				sentryOwner = unit:interaction()._owner_id
				mySentry = sentryOwner == peerID
				if mySentry then
					if tostring(unit:name()) == sentryChangeAmmo then
						unit:interaction():interact()
					end
				end
			end
		end
		managers.mission._fading_debug_output:script().log('Change Ammo ACTIVATED', Color.green)
	end
	
	local equip_equipment = function(item, name, number)
		if managers.hud and (managers.player:player_unit()) then
			managers.blackmarket:equip_deployable({name = item, target_slot = number})
			managers.player:_add_equipment({silent = true, equipment = item, slot = number})
		end
		managers.mission._fading_debug_output:script().log(string.format("%s - Equiped", name), Color.green)
	end

	local clear_equipment = function()
		if managers.hud and (managers.player:player_unit()) then
			managers.player:clear_equipment()
			--managers.player._equipment.selections = {}
		end
		managers.mission._fading_debug_output:script().log(string.format("Cleared Equipment - ACTIVATED"), Color.green)
	end
	
	local equip_armor =  function(id, name)
		if managers.hud and (managers.player:player_unit()) then
			local armor = managers.blackmarket:equip_armor(id)
			if armor then
				managers.blackmarket:equip_armor(id, name)
				managers.network:session():send_to_peers_synched("set_unit", managers.player:player_unit(), managers.network:session():local_peer():character(), managers.blackmarket:outfit_string(), managers.network:session():local_peer():outfit_version(), managers.network:session():local_peer():id())
				managers.dyn_resource:load(Idstring("unit"), Idstring(tweak_data.blackmarket.armors[armor.armor_id].unit), "packages/dyn_resources", false)
				managers.player:player_unit():inventory():set_character_armor(armor.armor_id)
				MenuCallbackHandler:_update_outfit_information()
			end 
		end
		managers.mission._fading_debug_output:script().log(string.format("%s - Equiped", name), Color.green)
	end
	
	local equip_projectile =  function(item, name, amount)
		if managers.hud and (managers.player:player_unit()) then
			local projectile = Global.blackmarket_manager.grenades[item]
			if projectile then
				managers.blackmarket:equip_grenade(item)
				managers.player:add_grenade_amount(amount)
				managers.network:session():send_to_peers_synched("sync_grenades", item, amount, managers.network:session():local_peer())
				managers.hud:set_teammate_grenades(HUDManager.PLAYER_PANEL, {amount = amount,icon = tweak_data.blackmarket.projectiles[item].icon})
				MenuCallbackHandler:_update_outfit_information()
			end
		end
		managers.mission._fading_debug_output:script().log(string.format("%s(%s) - Equiped", name, amount), Color.green)
	end

	local equip_melee =  function(item, name)
		if managers.hud and (managers.player:player_unit()) then
			local melee = Global.blackmarket_manager.melee_weapons[item]
			if melee then
				managers.blackmarket:equip_melee_weapon(item)
				managers.network:session():send_to_peers_synched("set_unit", managers.player:player_unit(), managers.network:session():local_peer():character(), managers.blackmarket:outfit_string(), managers.network:session():local_peer():outfit_version(), managers.network:session():local_peer():id())
				MenuCallbackHandler:_update_outfit_information()
			end
		end
		managers.mission._fading_debug_output:script().log(string.format("%s - Equiped", name), Color.green)
	end
	
	local equip_mask =  function(item, name)
		if managers.hud and (managers.player:player_unit()) then
			local mask = Global.blackmarket_manager.unlocked_mask_slots[item]
			if mask then
				managers.blackmarket:equip_mask(item)
				managers.network:session():send_to_peers_synched("set_unit", managers.player:player_unit(), managers.network:session():local_peer():character(), managers.blackmarket:outfit_string(), managers.network:session():local_peer():outfit_version(), managers.network:session():local_peer():id())
				managers.blackmarket:_verfify_equipped_category("masks")
				MenuCallbackHandler:_update_outfit_information()
			end
		end
		managers.mission._fading_debug_output:script().log(string.format("%s - Slot: %s - Equiped", name, item), Color.green)
	end
	
	local equip_armor_skin =  function(id, name)
		if managers.hud and (managers.player:player_unit()) then
			local armor = Global.blackmarket_manager.armor_skins[id]
			if armor then
				managers.blackmarket:set_equipped_armor_skin(id)
				managers.network:session():send_to_peers_synched("set_unit", managers.player:player_unit(), managers.network:session():local_peer():character(), managers.blackmarket:outfit_string(), managers.network:session():local_peer():outfit_version(), managers.network:session():local_peer():id())
				MenuCallbackHandler:_update_outfit_information()
			end 
		end
		managers.mission._fading_debug_output:script().log(string.format("%s - Equiped", name), Color.green)
	end
	
	local equip_player_stype =  function(id, name)
		if managers.hud and (managers.player:player_unit()) then
			local player_stype = Global.blackmarket_manager.player_styles[id]
			if player_stype then
				managers.blackmarket:set_equipped_player_style(id)
				managers.network:session():send_to_peers_synched("set_unit", managers.player:player_unit(), managers.network:session():local_peer():character(), managers.blackmarket:outfit_string(), managers.network:session():local_peer():outfit_version(), managers.network:session():local_peer():id())
				MenuCallbackHandler:_update_outfit_information()
			end 
		end
		managers.mission._fading_debug_output:script().log(string.format("%s - Equiped", name), Color.green)
	end
	
	local equip_van_skins =  function(skin, name)
		if managers.hud and (managers.player:player_unit()) and Network:is_server() then
			managers.blackmarket:equip_van_skin(skin)
		end
		managers.mission._fading_debug_output:script().log(string.format("%s - Equiped", name), Color.green)
	end
	
	local equip_primary = function(item, name, type_wep)
		if managers.hud and (managers.player:player_unit()) then
			if type_wep == "prim" then
				local weapon = Global.blackmarket_manager.crafted_items.primaries[item]
				if weapon then
					managers.blackmarket:equip_weapon("primaries", item)
					managers.network:session():send_to_peers_synched("set_unit", managers.player:player_unit(), managers.network:session():local_peer():character(), managers.blackmarket:outfit_string(), managers.network:session():local_peer():outfit_version(), managers.network:session():local_peer():id())
					managers.dyn_resource:load(Idstring("unit"), Idstring(tweak_data.weapon.factory[weapon.factory_id].unit), "packages/dyn_resources", false)
					managers.player:player_unit():inventory():add_unit_by_factory_name( weapon.factory_id, false, false, weapon.blueprint, weapon.texture_switches )
				end
			elseif type_wep == "sec" then
				local weapon = Global.blackmarket_manager.crafted_items.secondaries[item]
				if weapon then
					managers.blackmarket:equip_weapon("secondaries", item)
					managers.network:session():send_to_peers_synched("set_unit", managers.player:player_unit(), managers.network:session():local_peer():character(), managers.blackmarket:outfit_string(), managers.network:session():local_peer():outfit_version(), managers.network:session():local_peer():id())
					managers.dyn_resource:load(Idstring("unit"), Idstring(tweak_data.weapon.factory[weapon.factory_id].unit), "packages/dyn_resources", false)
					managers.player:player_unit():inventory():add_unit_by_factory_name( weapon.factory_id, false, false, weapon.blueprint, weapon.texture_switches )
				end
			end
		end
		managers.mission._fading_debug_output:script().log(string.format("%s - Equiped", name), Color.green)
	end
	
	local weapon_menu2 = function(prim_sec)
		local dialog_data = {    
			title = "Weapon Menu",
			text = "Select Option",
			button_list = {}
		}

		if prim_sec == "primary" then
			for prim_id, prim_data in pairs(Global.blackmarket_manager.crafted_items.primaries) do
				local name_exists = managers.localization:exists(tweak_data.weapon[prim_data.weapon_id].name_id)
				if name_exists and prim_data then
					local name = managers.localization:text(tweak_data.weapon[prim_data.weapon_id].name_id)
					table.insert(dialog_data.button_list, {
						text = name,
						callback_func = function() equip_primary(prim_id, name, "prim") end, 
					})
					table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
				end
			end
		elseif prim_sec == "secondary" then
			for prim_id, prim_data in pairs(Global.blackmarket_manager.crafted_items.secondaries) do
				local name_exists = managers.localization:exists(tweak_data.weapon[prim_data.weapon_id].name_id)
				if name_exists and prim_data then
					local name = managers.localization:text(tweak_data.weapon[prim_data.weapon_id].name_id)
					table.insert(dialog_data.button_list, {
						text = name,
						callback_func = function() equip_primary(prim_id, name, "sec") end, 
					})
					table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
				end
			end
		end
		
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() weapon_menu() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}    
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end
	
	weapon_menu = function()
		local dialog_data = {    
			title = "Weapon Menu",
			text = "Select Option",
			button_list = {}
		}
		table.insert(dialog_data.button_list, {text = "Primary",callback_func = function() weapon_menu2("primary") end,})
		table.insert(dialog_data.button_list, {text = "Secondary",callback_func = function() weapon_menu2("secondary") end,})
		
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu_playing() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}    
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end

	local throw_menu = function()
		local dialog_data = {    
			title = "Throwable Menu",
			text = "Select Option",
			button_list = {}
		}
		
		for throw_id, throw_data in pairs(Global.blackmarket_manager.grenades) do
			local name_exists = managers.localization:exists(tweak_data.blackmarket.projectiles[throw_id].name_id)
			if name_exists then
				local name = managers.localization:text(tweak_data.blackmarket.projectiles[throw_id].name_id)
				table.insert(dialog_data.button_list, {
					text = name,
					callback_func = function() equip_projectile(throw_id, name, throw_data.amount) end, 
					table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
				})
			end
		end
		
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu_playing() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}    
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end

	local melee_menu = function()
		local dialog_data = {    
			title = "Melee Menu",
			text = "Select Option",
			button_list = {}
		}
		
		for melee_id, melee_data in pairs(Global.blackmarket_manager.melee_weapons) do
			local name_exists = managers.localization:exists(tweak_data.blackmarket.melee_weapons[melee_id].name_id)
			if name_exists then
				local name = managers.localization:text(tweak_data.blackmarket.melee_weapons[melee_id].name_id)
				table.insert(dialog_data.button_list, {
					text = name,
					callback_func = function() equip_melee(melee_id, name) end, 
					table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
				})
			end
		end
		
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu_playing() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}    
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end
	
	local mask_menu = function()
		local dialog_data = {    
			title = "Mask Menu",
			text = "Select Option",
			button_list = {}
		}
		
		for masks_id, masks_data in pairs(Global.blackmarket_manager.crafted_items.masks) do
			local mask = managers.blackmarket:equipped_mask()
			local name_exists = managers.localization:exists(tweak_data.blackmarket.masks[masks_data.mask_id].name_id)
			if name_exists then
				local name = managers.localization:text(tweak_data.blackmarket.masks[masks_data.mask_id].name_id)
				table.insert(dialog_data.button_list, {
					text = name,
					callback_func = function() equip_mask(masks_id, name) end, 
					table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
				})
			end
		end
		
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu_playing() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}    
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end
	
	local equipment_menu = function()
		local dialog_data = {    
			title = "Equipment Menu",
			text = "Select Option",
			button_list = {}
		}

		table.insert(dialog_data.button_list, {text = "Primary",})
		for deployable_id, deployable_data in pairs(tweak_data.blackmarket.deployables) do
			if table.contains(managers.player:availible_equipment(1), deployable_id) then
				local name_exists = managers.localization:exists(tweak_data.blackmarket.deployables[deployable_id].name_id)
				if name_exists then
					local name = managers.localization:text(tweak_data.blackmarket.deployables[deployable_id].name_id)
					table.insert(dialog_data.button_list, {
						text = name,
						callback_func = function() equip_equipment(deployable_id, name, 1) end, 
					})
				end
			end
		end
		
		table.insert(dialog_data.button_list, {})
		
		table.insert(dialog_data.button_list, {text = "Secondary",})
		for deployable_id, deployable_data in pairs(tweak_data.blackmarket.deployables) do
			if table.contains(managers.player:availible_equipment(1), deployable_id) then
				local name_exists = managers.localization:exists(tweak_data.blackmarket.deployables[deployable_id].name_id)
				if name_exists then
					local name = managers.localization:text(tweak_data.blackmarket.deployables[deployable_id].name_id)
					table.insert(dialog_data.button_list, {
						text = name,
						callback_func = function() equip_equipment(deployable_id, name, 2) end,
					})
				end
			end
		end
		
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {
			text = "Clear Equipment",
			callback_func = function() clear_equipment() end, 
		})
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu_playing() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}     
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end

	local armor_menu = function()
		local dialog_data = {    
			title = "Armor Menu",
			text = "Select Option",
			button_list = {}
		}

		for armor_id, armor_data in pairs(Global.blackmarket_manager.armors) do
			local name_exists = managers.localization:exists(tweak_data.blackmarket.armors[armor_id].name_id)
			if name_exists then
				local name = managers.localization:text(tweak_data.blackmarket.armors[armor_id].name_id)
				table.insert(dialog_data.button_list, {
					text = name,
					callback_func = function() equip_armor(armor_id, name) end, 
				})
			end
		end
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu_playing() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}    
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end
	
	local armor_skins_menu = function()
		local dialog_data = {    
			title = "Armor Skin Menu",
			text = "Select Option",
			button_list = {}
		}

		for armor_id, armor_data in pairs(Global.blackmarket_manager.armor_skins) do
			local name_exists = managers.localization:exists(tweak_data.economy.armor_skins[armor_id].name_id)
			if name_exists then
				local name = managers.localization:text(tweak_data.economy.armor_skins[armor_id].name_id)
				table.insert(dialog_data.button_list, {
					text = name,
					callback_func = function() equip_armor_skin(armor_id, name) end, 
				})
			end
		end
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu_playing() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}    
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end
	
	local player_stype_menu = function()
		local dialog_data = {    
			title = "Player Style Menu",
			text = "Select Option",
			button_list = {}
		}

		for ps_id, ps_data in pairs(Global.blackmarket_manager.player_styles) do
			local name_exists = managers.localization:exists(tweak_data.blackmarket.player_styles[ps_id].name_id)
			if name_exists then
				local name = managers.localization:text(tweak_data.blackmarket.player_styles[ps_id].name_id)
				table.insert(dialog_data.button_list, {
					text = name,
					callback_func = function() equip_player_stype(ps_id, name) end, 
				})
			end
		end
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu_playing() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}    
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end
	
	local van_menu = function()
		local dialog_data = {    
			title = "Van Menu",
			text = "Select Option",
			button_list = {}
		}

		local van_table = {
			{id = 'default', name = "Default"},
			{id = 'overkill', name = "Overkill"},
			{id = 'brown', name = "Brown"},
			{id = 'green', name = "Green"},
			{id = 'grey', name = "Gray"},
			{id = 'red', name = "Red"},
			{id = 'white', name = "White"},
			{id = 'yellow', name = "Yellow"},
			{id = 'icecream', name = "Iceream"},
			{id = 'spooky', name = "Spooky"},
		}
		
		for _,skin_id in ipairs(van_table) do
			table.insert(dialog_data.button_list, {
				text = skin_id.name,
				callback_func = function() equip_van_skins(skin_id.id, skin_id.name) end, 
			})
		end
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu_playing() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}    
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end
	
	trainer_buffs = function()
		local dialog_data = {    
			title = "Trainer Buff Menu",
			text = "Select Option",
			button_list = {}
		}
		
		for _, action in pairs(buff_table) do
			if action then
				table.insert(dialog_data.button_list, action)
			end
		end
		
		
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu_playing() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}  
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end
	
	main_menu_playing = function()
		local dialog_data = {    
			title = "Inventory Menu",
			text = "Select Option",
			button_list = {}
		}

		local sentrymenu_table = {
			["input"] = {
				{ text = "Trainer Buff menu", callback_func = function() trainer_buffs() end },
				{},
				{ text = "Pickup Sentries - ON", callback_func = function() pickup_sentrys() end },
				{ text = "Change Ammo On Sentries - ON", callback_func = function() sentryammo() end },
				{},
				{ text = "Change Van Skin - ON", callback_func = function() van_menu() end },
				{ text = "Change Mask - ON", callback_func = function() mask_menu() end },
				{ text = "Change Player Style - ON", callback_func = function() player_stype_menu() end },
				{ text = "Change Armor Skins - ON", callback_func = function() armor_skins_menu() end },
				{},
				{ text = "Change Armor - ON", callback_func = function() armor_menu() end },
				{ text = "Change Equipment - ON", callback_func = function() equipment_menu() end },
				{ text = "Change Throwable - ON", callback_func = function() throw_menu() end },
				{ text = "Change melee - ON", callback_func = function() melee_menu() end },
				{ text = "Change Weapon - ON", callback_func = function() weapon_menu() end },
			}
		}
		
		local sentrymenu_array = "input"
		if sentrymenu_table[sentrymenu_array] then
			for _, dostuff in pairs(sentrymenu_table[sentrymenu_array]) do
				if sentrymenu_table[sentrymenu_array] then
					table.insert(dialog_data.button_list, dostuff)
				end
			end
		end
		table.insert(dialog_data.button_list, {})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true} 
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end
	main_menu_playing()
else
	local function reconnect()
		local room_id = CommandManager["config"]["reconnect_id"]
		if room_id ~= "" then
			managers.network.matchmake:join_server(room_id)
			return
		end
		managers.mission._fading_debug_output:script().log(string.format("No server found by %s..", room_id), Color.red)
	end

	local function reset_points()
		managers.skilltree._global.specializations = {
			points_present = managers.skilltree:digest_value(0, true),
			points = managers.skilltree:digest_value(0, true),
			total_points = managers.skilltree:digest_value(0, true),
			xp_present = managers.skilltree:digest_value(0, true),
			xp_leftover = managers.skilltree:digest_value(0, true),
			current_specialization = managers.skilltree:digest_value(1, true)
		}
		managers.skilltree._global.specializations.max_points = managers.skilltree:digest_value(max_specialization_points, true)
		MenuCallbackHandler:save_progress()
		managers.mission._fading_debug_output:script().log(string.format("Reset Perks - ACTIVATED"),  Color.green)
	end
	local function set_perk_points( points )
		--Global.skilltree_manager.specializations.points_present = points
		Global.skilltree_manager.specializations.total_points = points
		Global.skilltree_manager.specializations.points = points
		managers.skilltree._global.specializations.total_points =  points
		managers.skilltree._global.specializations.points = points
		--managers.skilltree._global.specializations.points_present = points
		MenuCallbackHandler:save_progress()
		MenuCallbackHandler:_update_outfit_information()
		if SystemInfo:distribution() == Idstring("STEAM") then
			managers.statistics:publish_skills_to_steam()
		end
		managers.mission._fading_debug_output:script().log(string.format("%s - ACTIVATED", points),  Color.green)
	end

	local function unlocks_perks()
		Global.skilltree_manager.specializations.total_points = 433700
		Global.skilltree_manager.specializations.points = 433700
		Global.skilltree_manager.specializations.max_points = 433700
		managers.skilltree._global.specializations.total_points =  433700
		managers.skilltree._global.specializations.points = 433700
		for spec,_ in pairs(Global.skilltree_manager.specializations) do
			if type(spec) == 'number' then
				managers.skilltree:spend_specialization_points(13700, spec)
			end
		end
		--managers.skilltree._global.specializations.points_present = 433700
		MenuCallbackHandler:save_progress()
		MenuCallbackHandler:_update_outfit_information()
		if SystemInfo:distribution() == Idstring("STEAM") then
			managers.statistics:publish_skills_to_steam()
		end
		managers.mission._fading_debug_output:script().log('Unlock Perks ACTIVATED',  Color.green)
	end

	--open safes
	local r_index_armor = {"uncommon", "rare", "epic"}
	local r_index_weapon = {"rare", "epic", "legendary"} --"common", "uncommon", 
	local q_index = {"mint"} --"poor", "fair", "good", "fine", 
	local sim_chances = {
		r = {65, 20, 10, 4, 1},
		q = {20, 20, 20, 20, 20},
		stat = 10
	}

	local function get_total(index, t)
		local total = 0
		for i, n in pairs(index) do
			total = total + (sim_chances[t][i])
		end
		return total
	end

	local function random_choice(index, t)
		local total = get_total(index, t)
		local rand_n = math.random(total)
		local track = 0
		for i, n in pairs(index) do
			local prob = sim_chances[t][i]
			if prob > 0 and rand_n > track and rand_n <= track + prob then
				return n
			end
			track = track + prob
		end
		return index[1]
	end

	local function choose_item(safe)
		local is_weapon = tweak_data.economy.contents[safe.content].contains.weapon_skins
		local r_index_over = is_weapon and safe.content == "overkill_01" and {"rare", "epic", "legendary"} or nil
		local data = {amount = 1, category = is_weapon and "weapon_skins" or "armor_skins"}
		local now = os.date("!*t")
		math.randomseed(now.yday * (now.hour + 1) * (now.min + 1) * (now.sec + 1))
		data.bonus = is_weapon and math.random(100) <= (sim_chances.stat)
		local rarity = random_choice(is_weapon and r_index_weapon or r_index_over or r_index_armor, "r")
		local skin_index = {}
		if rarity == "legendary" then
			local legend_contents = tweak_data.economy.contents[safe.content].contains.contents
			for _, skin in pairs(tweak_data.economy.contents[legend_contents[math.random(#legend_contents)]].contains[data.category]) do
				table.insert(skin_index, skin)
			end
		else
			local group = is_weapon and tweak_data.blackmarket.weapon_skins or tweak_data.economy.armor_skins
			for _, skin in pairs(tweak_data.economy.contents[safe.content].contains[data.category]) do
				if group[skin].rarity == rarity then
					table.insert(skin_index, skin)
				end
			end
		end
		data.entry = skin_index[math.random(#skin_index)]
		data.quality = is_weapon and random_choice(q_index, "q") or nil
		data.def_id = 101
		local i = 1
		while managers.blackmarket._global.inventory_tradable[tostring(i)] ~= nil do
			i = i + 1
		end
		data.instance_id = tostring(i)
		return data
	end

	local function start_open(name, data)
		local function ready_clbk()
			managers.menu:back()
			managers.system_menu:force_close_all()
			managers.menu_component:set_blackmarket_enabled(false)
			managers.menu:open_node("open_steam_safe", {data.content})
		end
		managers.menu_component:set_blackmarket_disable_fetching(true)
		managers.menu_component:set_blackmarket_enabled(false)
		managers.menu_scene:create_economy_safe_scene(name, ready_clbk)
		local item = choose_item(data)
		MenuCallbackHandler:_safe_result_recieved(nil, {item}, {})
		managers.blackmarket:tradable_add_item(item.instance_id, item.category, item.entry, item.quality, item.bonus, 1)
		managers.mission._fading_debug_output:script().log(string.format("ACTIVATED"),  Color.green)
	end

	-- Crimespree set level
	local function set_crimespree_spree_level(level, reward, bonus, streak)
		function CrimeSpreeManager:spree_level()
			return self:in_progress() and (self._global.spree_level and level) or -1
		end
		function CrimeSpreeManager:reward_level()
			return self:in_progress() and (self._global.reward_level and reward) or -1
		end
		function CrimeSpreeManager:catchup_bonus()
			return math.floor(self._catchup_bonus and bonus or 0)
		end
		function CrimeSpreeManager:winning_streak_bonus()
			return math.floor(self._winning_streak and streak or 0)
		end
		managers.crime_spree._global.in_progress = true
		managers.crime_spree._global.spree_level = level
		managers.crime_spree._global.reward_level = reward
		managers.crime_spree._global.winning_streak = streak
		local data = {
			crime_spree = {
				in_progress = managers.crime_spree._global.in_progress or false,
				spree_level = managers.crime_spree._global.spree_level or 0,
				reward_level = managers.crime_spree._global.reward_level or 0
			}
		}
		MenuCallbackHandler:save_progress()
		managers.crime_spree:save(data)
		managers.mission._fading_debug_output:script().log(string.format("Crimespree Level Set - %s / %s / %s / %s", level, reward, bonus, streak), Color.green)
	end

	local free_crimespree = function()
		function CrimeSpreeManager.randomization_cost()
			return 0
		end
		function CrimeSpreeManager.get_start_cost()
			return 0
		end
		function CrimeSpreeManager.get_continue_cost()
			return 0
		end
		managers.mission._fading_debug_output:script().log('Free Crimespree ACTIVATED',  Color.green)
	end

	local function free_crime_coins(value)
		local current = Application:digest_value(managers.custom_safehouse._global.total)
		local future = value --current
		Global.custom_safehouse_manager.total = Application:digest_value(future, true)
		managers.mission._fading_debug_output:script().log(string.format("%s - ACTIVATED", value), Color.green)
	end

	local function Auto_Complete_Safehouse_Challenge()
		if not CustomSafehouseManager then return end
		function CustomSafehouseManager:set_active_daily(id)
			if self:get_daily_challenge() and self:get_daily_challenge().id ~= id then
				self:generate_daily(id)
			end
			self:complete_daily(id)
		end
		managers.mission._fading_debug_output:script().log(string.format("ACTIVATED"),  Color.green)
	end
	
	local function Auto_Complete_All_Challenges()
		local AutoCompleteChallenge = AutoCompleteChallenge or ChallengeManager.activate_challenge
		function ChallengeManager:activate_challenge(id, key, category)
			if self:has_active_challenges(id, key) then
				local active_challenge = self:get_active_challenge(id, key)
				active_challenge.completed = true
				active_challenge.category = category
				return true
			end
			return AutoCompleteChallenge(self, id, key, category)
		end
		managers.mission._fading_debug_output:script().log(string.format("ACTIVATED"),  Color.green)
	end
	
	local function unlock_safehouse_trophies()
		--[[for _, trophy in pairs(managers.custom_safehouse:trophies()) do
			for objective_id in pairs (trophy.objectives) do
				local objective = trophy.objectives[objective_id]
				objective.verify = false
				managers.custom_safehouse:on_achievement_progressed(objective.progress_id, objective.max_progress)
			end
		end--]]

		for _, trophy in pairs(managers.custom_safehouse._global.trophies) do
			trophy.displayed = true
			trophy.completed = true
		end
		--managers.custom_safehouse:reset()
		managers.mission._fading_debug_output:script().log(string.format("ACTIVATED"),  Color.green)
	end
	
	local function max_rooms_tier()
		for room_id, data in pairs(Global.custom_safehouse_manager.rooms) do
			local current_tier = managers.custom_safehouse:get_room_current_tier(room_id)
			while data.tier_max > current_tier do
				current_tier = current_tier + 1
				
				local unlocked_tiers = managers.custom_safehouse._global.rooms[room_id].unlocked_tiers
				table.insert(unlocked_tiers, current_tier)
			end
			managers.custom_safehouse:set_room_tier(room_id, data.tier_max)
		end
		managers.mission._fading_debug_output:script().log(string.format("ACTIVATED"),  Color.green)
	end
	
	local skills_menu = function()
		local dialog_data = {    
			title = "ACED Skills Menu",
			text = "For some individual skills to work,                                                                   you need points enough to reach them.                                                ACED skills unlock on perk completion.                                                        All skills unlocked at perk 1.",
			button_list = {}
		}
		
		local all_skills_aced_table = {
			{name = "----- Medic -----"},
			{name = "All - ACED"},
			{},
			{name = "----- Shotgunner -----"},
			{name = "Overkill - ACED"},
			{},
			{name = "----- Tank -----"},
			{name = "All - ACED"},
			{},
			{name = "----- Ammo Specialist -----"},
			{name = "All - ACED"},
			{},
			{name = "----- Engineer -----"},
			{name = "Engineering - ACED"},
			{name = "Jack of All trades - ACED"},
			{name = "Tower Defence - ACED"},
			{},
			{name = "----- Breacher -----"},
			{name = "All - ACED"},
			{},
			{name = "----- Oppressor -----"},
			{name = "All - ACED"},
			{},
			{name = "----- Shinobi -----"},
			{name = "All - ACED"},
			{},
			{name = "----- Artful Dodger -----"},
			{name = "All - ACED"},
			{},
			{name = "----- Gunslinger -----"},
			{name = "Trigger Happy - ACED"},
			{},
			{name = "----- Revenant -----"},
			{name = "All - ACED"},
		}
		for _,all_skills_aced in pairs(all_skills_aced_table) do
			table.insert(dialog_data.button_list, {
				text = all_skills_aced.name,
				callback_func = function() managers.mission._fading_debug_output:script().log(string.format("%s is already ACED", all_skills_aced.name),  Color.green) end,	
			})
		end
		
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "------------------------- Use Scroll Wheel ------------------------",})
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu_ingame() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}     
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end
	
	local coins_menu = function()
		local dialog_data = {    
			title = "Crimespree Coins Menu",
			text = "Select Option",
			button_list = {}
		}
			
		for i=10000, 0, -1 do
			table.insert(dialog_data.button_list, {
				text = i,
				callback_func = function()
					free_crime_coins(i)
				end,
	        
			})
		end
		
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "100000", callback_func = function() free_crime_coins(100000) end,})
		table.insert(dialog_data.button_list, {text = "1000000", callback_func = function() free_crime_coins(1000000000) end,})
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "------------------------- Use Scroll Wheel ------------------------",})
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu_ingame() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}  
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end

	local level_menu = function()
		local dialog_data = {    
			title = "Crimespree Level Menu",
			text = "Select Option",
			button_list = {}
		}
			
		for i=10000, 0, -1 do
			table.insert(dialog_data.button_list, {
				text = i,
				callback_func = function()
					set_crimespree_spree_level(i, i, i, i)
				end,
			})
		end
		
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "100000", callback_func = function() set_crimespree_spree_level(100000) end,})
		table.insert(dialog_data.button_list, {text = "1000000", callback_func = function() set_crimespree_spree_level(1000000) end,})
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "------------------------- Use Scroll Wheel ------------------------",})
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu_ingame() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}  
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end

	local safe_menu = function()
		local dialog_data = {    
			title = "Safe Menu",
			text = "Select Option",
			button_list = {}
		}
		
		for safe, safe_d in pairs(tweak_data.economy.safes) do
			table.insert(dialog_data.button_list, {
				text = managers.localization:text(safe_d.name_id),
				callback_func = function() start_open(safe, safe_d) end,
			})
		end
		
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu_ingame() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}     
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end
	
	local hof_menu = function()
		local dialog_data = {    
			title = "Hall Of Fame Menu",
			text = "Select Option",
			button_list = {}
		}

		for id in pairs(managers.achievment.achievments) do
			table.insert(dialog_data.button_list, {
				text = id,
				callback_func = function() managers.achievment.award(managers.achievment, id) managers.mission._fading_debug_output:script().log(string.format("ACTIVATED"),  Color.green) end,
			})
		end
		
		local mainmenu_table = {
			["input"] = {
				{},
				{ text = "Complete All Challanges", callback_func = function() Auto_Complete_All_Challenges() end },
				{ text = "Complete Safehouse Challange", callback_func = function() Auto_Complete_Safehouse_Challenge() end },
				{ text = "Unlock All Safehouse Trophies", callback_func = function() unlock_safehouse_trophies() end },
				{ text = "Unlock All Safehouse Rooms", callback_func = function() max_rooms_tier() end },
				{ text = "Unlock All Achievements", callback_func = function() for id in pairs(managers.achievment.achievments) do managers.achievment.award(managers.achievment, id) end managers.mission._fading_debug_output:script().log(string.format("ACTIVATED"),  Color.green) end },
				{ text = "Lock All Achievements", callback_func = function() managers.achievment:clear_all_steam() managers.mission._fading_debug_output:script().log(string.format("ACTIVATED"),  Color.green) end },
			}
		}
		
		local mainmenu_array = "input"
		if mainmenu_table[mainmenu_array] then
			for _, dostuff in pairs(mainmenu_table[mainmenu_array]) do
				if mainmenu_table[mainmenu_array] then
					table.insert(dialog_data.button_list, dostuff)
				end
			end
		end
		
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu_ingame() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}   
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end
	
	trainer_buffs = function()
		local dialog_data = {    
			title = "Trainer Buff Menu",
			text = "Select Option",
			button_list = {}
		}
		
		for _, action in pairs(buff_table) do
			if action then
				table.insert(dialog_data.button_list, action)
			end
		end
		
		
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu_ingame() end,})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}  
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end
	
	main_menu_ingame = function()
		local dialog_data = {    
			title = "Main Menu",
			text = "Select Option",
			button_list = {}
		}

		local mainmenu_table = {
			["input"] = {
				{ text = "Hidden ACED Skills", callback_func = function() skills_menu() end },
				{},
				{ text = "Trainer Buff menu", callback_func = function() trainer_buffs() end },
				{},
				{ text = "Give All Items - ON", callback_func = function() dofile("mods/hook/content/scripts/items.lua") end },
				{},
				{ text = "Unlock All Perks - ON", callback_func = function() unlocks_perks() end },
				{ text = "Give Perk Points - 566000 - ON", callback_func = function() set_perk_points( 566000 ) end },
				{ text = "Give Perk Points - 0 - ON", callback_func = function() set_perk_points( 0 ) end },
				{ text = "Reset Perks - ON", callback_func = function() reset_points() end },
				{},
				{ text = "Get Crimespree Free - ON", callback_func = function() free_crimespree() end },
				{ text = "Set Crimespree Coins - ON", callback_func = function() coins_menu() end },
				{ text = "Set Crimespree Level - ON", callback_func = function() level_menu() end },
				{ text = "Reset Crimespree - ON", 
					callback_func = function() 
						managers.mission._fading_debug_output:script().log(string.format("Crimespree Reset"), Color.green)
						managers.crime_spree:reset_crime_spree() 
					end },
				{},
				{ text = "Open Safes", callback_func = function() safe_menu() end },
				{},
				{ text = "Achievement/Trophy", callback_func = function() hof_menu() end },
				{ text = "Change Menu Color", callback_func = function() dofile("mods/hook/content/scripts/menus/menumanager.lua") end },
				{},
				{ text = "Re-connect", callback_func = function() 
					if in_mainmenu() then
						reconnect() 
					else
						MenuCallbackHandler:_dialog_end_game_yes()
					end
				end },
			}
		}
		
		local mainmenu_array = "input"
		if mainmenu_table[mainmenu_array] then
			for _, dostuff in pairs(mainmenu_table[mainmenu_array]) do
				if mainmenu_table[mainmenu_array] then
					table.insert(dialog_data.button_list, dostuff)
				end
			end
		end
		table.insert(dialog_data.button_list, {})
		local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}   
		table.insert(dialog_data.button_list, no_button) 
		managers.system_menu:show_buttons(dialog_data)
	end
	main_menu_ingame()
end
