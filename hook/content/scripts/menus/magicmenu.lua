--if you crash with secure on kill script, remove 'grenades' in loot table
function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end
if not is_playing() then 
	return
end

local function interactbytweak(...)
	local player = managers.player._players[1] --or managers.player:player_unit()
	if not player then
		return
	end
	
	if not equipment_toggle then
		dofile("mods/hook/content/scripts/equipment.lua")
	end
	
	local can_interact = function()
		return true
	end
	
	local tweaks = {}
	for _,arg in pairs({...}) do
		if type(arg) == 'string' then
			tweaks[arg] = true
			managers.mission._fading_debug_output:script().log(string.format("Hack %s ACTIVATED", arg),  Color.green)
		end
	end
	
	local interacts = {}
	local interaction
	for _,unit in pairs(managers.interaction._interactive_units) do
		if not alive(unit) then break end
		interaction = unit:interaction()
		if interaction and tweaks[interaction.tweak_data] then
			table.insert(interacts, interaction)
		end
	end
	
	for _,unit in pairs(World:find_units_quick("all", 1)) do
		interaction = unit:interaction()
		if interaction and tweaks[interaction.tweak_data] then
			table.insert(interacts, interaction)
		end
	end
	
	for _,int in pairs(interacts) do
		int.can_interact = can_interact
		int:interact(player)
		int.can_interact = nil
	end
	
	if equipment_toggle then
		dofile("mods/hook/content/scripts/equipment.lua")
	end
end

local cameraoff = function()
	global_toggle_cam_off = global_toggle_cam_off or false
	if not global_toggle_cam_off then
		if Network:is_server() then
			local function toggle_cameras(state)
				for _,unit in pairs( SecurityCamera.cameras ) do
					if unit:base()._last_detect_t ~= nil then 
						unit:base():set_update_enabled( state )
					end
				end
			end
			toggle_cameras(false)
		else
			local function dmg_cam(unit)
				local position = unit:position()
				local body
				do
					local i = -1
					repeat
						i = i+1
						body = unit:body(i)
					until (body and body:extension()) or i >= 5
					if not body then
						return
					end
				end
				body:extension().damage:damage_melee( unit, nil, position, nil, 10000 )
				managers.network:session():send_to_peers_synched( "sync_body_damage_melee", body, unit, nil, position, nil, 10000 )
			end
			for _,unit in pairs(SecurityCamera.cameras) do
				pcall(dmg_cam,unit)
			end
		end
		managers.mission._fading_debug_output:script().log('Cameras ACTIVATED', Color.green)
	else
		if Network:is_server() then
			local function toggle_cameras( state )
				for _,unit in pairs( SecurityCamera.cameras ) do
					if unit:base()._last_detect_t ~= nil then 
						unit:base():set_update_enabled( state )
					end
				end
			end
			toggle_cameras( true )
		end
		managers.mission._fading_debug_output:script().log('Cameras DEACTIVATED', Color.red)
	end
	global_toggle_cam_off = not global_toggle_cam_off
end

local function graballbigloot()
	if Network:is_server() then else 
		managers.chat:_receive_message(1, "BigLoot", "Host only!", tweak_data.system_chat_color)
		return
	end
	if not global_carry_stacker then
		dofile("mods/hook/content/scripts/carrystacker.lua")
	end
	interactbytweak('money_wrap','bex_pku_treasure','bex_prop_faberge_egg','hold_take_server','samurai_armor','hold_search_drawer','hold_search_shower','hold_search_luggage','hold_search_steel_cabinet','hold_search_drawers','hold_search_cigar_boxes','hold_search_cart','hold_search_fridge','hold_search_capsule','hold_search_bookshelf','cas_take_fireworks_bag','cas_take_unknown','gold_pile','requires_ecm_jammer_atm','cut_glass','gen_atm','invisible_interaction_open','weapon_case','gage_assignment','pick_lock_deposit_transport','pick_lock_easy_no_skill','pick_lock_hard_no_skill','pick_lock_hard','open_from_inside','open_train_cargo_door')
	DelayedCalls:Add( "take_carry_loot", 2, function()
		interactbytweak('diamonds_pickup','diamond_pickup_axis','diamond_single_pickup_axis','roman_armor','mex_pickup_meth_bag','gen_pku_cocaine_directional','money_wrap_updating_directional','hold_grab_goat','money_small','samurai_armor','hold_take_server','money_wrap_updating','pku_pig','invisible_interaction_open','goat','invisible_interaction_open','cash_register','safe_loot_pickup','diamond_pickup','tiara_pickup','money_wrap_single_bundle','mus_pku_artifact','gen_pku_artifact','gen_pku_artifact_statue','gen_pku_artifact_painting','carry_drop','painting_carry_drop','money_wrap','gen_pku_jewelry','taking_meth','gen_pku_cocaine','take_weapons','gold_pile','goat_carry_drop','safe_carry_drop','hold_take_painting','gen_pku_evidence_bag','evidence_bag')
		--dofile("mods/hook/content/scripts/secureall.lua")
		--dofile("mods/hook/content/scripts/carrystacker.lua")
	end)
end

local clear_carry = function()
	local pos = Vector3(0, 0, 0)
	local carry_data = managers.player:get_my_carry_data()
	local rotation = managers.player:player_unit():camera():rotation()
	local position = pos or managers.player:player_unit():camera():position()
	local forward = Vector3(0, 0, 0)
	local throw_distance = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0)
	if carry_data then
		if Network:is_server() then
			managers.player:server_drop_carry(carry_data.carry_id, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, throw_distance, zipline_unit, managers.network:session():local_peer())
		else
			managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, throw_distance, zipline_unit)
		end
		managers.player:clear_carry()
		if global_carry_stacker then
			dofile("mods/hook/content/scripts/carrystacker.lua")
		end
	end
end

local _timeEffectExpired
function Slow_Peer(id)
	if not managers.network:session() then
		return
	end
	
	local peer = managers.network._session:peer(id)
	
	global_slow_single_peers = global_slow_single_peers or false
	if not global_slow_single_peers then
		if peer then
			peer:send("start_timespeed_effect", "pause", "pausable", "player;game_animation", 0.05, 1, 3600, 1)
		end
		managers.mission._fading_debug_output:script().log('Single Unit ACTIVATED',  Color.green)
	else
		if peer then
			peer:send("stop_timespeed_effect", "pause", 1)
		end
		managers.mission._fading_debug_output:script().log('Single Unit DEACTIVATED',  Color.red)	
	end
	global_slow_single_peers = not global_slow_single_peers
end

function Slow_Peers()
	if not managers.network:session() then
		return
	end
	
	function stop_slow_time()
		if is_playing() then
			for peer_id, peer in pairs(managers.network._session._peers) do
				peer:send("stop_timespeed_effect", "pause", 1)
			end
		end
		if _timeEffectExpired then
			TimeSpeedManager._on_effect_expired = _timeEffectExpired
			_timeEffectExpired = nil
			if managers.time_speed._playing_effects then
				for id,_ in pairs(managers.time_speed._playing_effects) do
					local our_id = "_MaskOn_Peer"..tostring( managers.network:session():local_peer():id() )
					if string.find(id, our_id) then
						managers.time_speed:stop_effect(id)
					end
				end
			end
			SoundDevice:set_rtpc( "game_speed", 1 )
		end
	end
	
	global_slow_all_peers = global_slow_all_peers or false
	if not global_slow_all_peers then
		--others
		if is_playing() then
			for peer_id, peer in pairs(managers.network._session._peers) do
				peer:send("start_timespeed_effect", "pause", "pausable", "player;game;game_animation", 0.5, 1, 10, 1)
				--peer:send("start_timespeed_effect", id, effect_desc.timer, affect_timers_str, effect_desc.speed, effect_desc.fade_in or 0, effect_desc.sustain or 0, effect_desc.fade_out or 0)
			end
		end
		--player
		local SLOWMO_WORLD_ONLY = true --'nil' or 'true'
		local our_id = "_MaskOn_Peer"..tostring( managers.network:session():local_peer():id() )
		local slowmo_id_world = "world" .. our_id
		local slowmo_id_player = "player" .. our_id
		if not _timeEffectExpired then
			--this func crashes when leave
			_timeEffectExpired = TimeSpeedManager._on_effect_expired
			function TimeSpeedManager:_on_effect_expired(effect_id)
				if is_playing() then
					local ret = _timeEffectExpired(self, effect_id)
					if effect_id == slowmo_id_world and not SLOWMO_WORLD_ONLY then
						managers.time_speed:play_effect( slowmo_id_world, tweak_data.timespeed.mask_on )
					elseif effect_id == slowmo_id_player and not SLOWMO_WORLD_ONLY then
						managers.time_speed:play_effect( slowmo_id_player, tweak_data.timespeed.mask_on_player )
					end
					return ret
				else
					stop_slow_time()
				end
			end
			tweak_data.timespeed.mask_on.fade_in_delay = 0
			tweak_data.timespeed.mask_on.fade_out = 0
			tweak_data.timespeed.mask_on_player.fade_in_delay = 0
			tweak_data.timespeed.mask_on_player.fade_out = 0
			managers.time_speed:play_effect( slowmo_id_world, tweak_data.timespeed.mask_on )
			if not SLOWMO_WORLD_ONLY then 
				managers.time_speed:play_effect( slowmo_id_player, tweak_data.timespeed.mask_on_player ) 
			end
		end
		
		managers.mission._fading_debug_output:script().log('All Unit ACTIVATED',  Color.green)
	else
		stop_slow_time()
		managers.mission._fading_debug_output:script().log('All Unit DEACTIVATED',  Color.red)	
	end
	global_slow_all_peers = not global_slow_all_peers
end
--secure and spawn bags when ppl die
bag_amount = 1
bag_secure = "diamonds"
money_and_bags_per_sec = 3.0
local bag_values
local bag_table = {
--[['meth'
'money',
'gold',
'diamonds',
'weapon',
'yayo',
'turret',
'roman_armor',
'samurai_suit',
'red_diamond',
'hope_diamond',
'safe_ovk',
'coke_pure',
'painting',
'toothbrush',
'cloaker_gold',
'sandwich',
'din_pig',
'women_shoes',
'goat',
'expensive_vine',
'robot_toy',
--'grenades'--]]
}

global_anti_spam_bag_spawns = global_anti_spam_bag_spawns or 0
local function bagspawn(_position)
	local player = managers.player:player_unit()
	if not alive(player) then return end
	local bag_pop = bag_table[math.random(#bag_table)]
	local position = mvector3.copy(_position) --Vector3(position.x + (-50 or 0), position.y, position.z + 10000)
	local rotation = player:camera():rotation() --Rotation(math.UP, math.random() * 360)--Vector3(math.random(-180, 180), math.random(-180, 180), 0)
	local forward = player:camera():forward()
	local throw_force = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0)
	local carry_data = tweak_data.carry[bag_pop]
	if Network:is_server() then
		if global_anti_spam_bag_spawns > 1 then
			return
		else
			for i=1, bag_amount do
				managers.loot:secure(bag_pop, managers.money:get_bag_value(bag_pop), true)
				managers.mission._fading_debug_output:script().log(string.format("%s", bag_pop), Color.green)
				managers.player:server_drop_carry(bag_pop, managers.money:get_bag_value(bag_pop), nil, nil, 0, Vector3(position.x + (-50 or 0), position.y, position.z + 10000), rotation, forward, nil, zipline_unit, managers.network:session():local_peer())
			end
			DelayedCalls:Add( "reset_spawn_bag", money_and_bags_per_sec, function()
				if not alive(managers.player:player_unit()) then return end
				global_anti_spam_bag_spawns = 0
			end)
		end
	else
		managers.loot:secure(bag_pop, managers.money:get_bag_value(bag_pop), true)
	end
end

_orig_death_drop = _orig_death_drop or CopActionHurt.on_death_drop
_hacked_death_drop = _hacked_death_drop or function ( self, unit, stage )
	global_anti_spam_bag_spawns = global_anti_spam_bag_spawns + 1
	bagspawn(self._unit:position())
	
    if self._weapon_dropped then
        return
    end
    if self._delayed_shooting_hurt_clbk_id then
        managers.enemy:remove_delayed_clbk( self._delayed_shooting_hurt_clbk_id )
        self._delayed_shooting_hurt_clbk_id = nil
    end
    if self._shooting_hurt then
        if stage == 2 then
            self._weapon_unit:base():stop_autofire()
            self._ext_inventory:drop_weapon()
            self._weapon_dropped = true
            self._shooting_hurt = false
            end
    elseif self._ext_inventory then
        self._ext_inventory:drop_weapon()
        self._weapon_dropped = true
    end
    return
end

local money_value = function()
	if not get_bag_value_original then get_bag_value_original = MoneyManager.get_bag_value end
	function MoneyManager:get_bag_value(carry_id, multiplier)    
		local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
		local difficulty_index = tweak_data:difficulty_to_index(difficulty)
		if difficulty_index == 1 then
			if carry_id == bag_secure then
				return bag_values
			end  
		elseif difficulty_index == 2 then
			if carry_id == bag_secure then
				return bag_values
			end  
		elseif difficulty_index == 3 then
			if carry_id == bag_secure then
				return bag_values
			end  
		elseif difficulty_index == 4 then
			if carry_id == bag_secure then
				return bag_values
			end    
		elseif difficulty_index == 5 then
			if carry_id == bag_secure then
				return bag_values
			end    
		elseif difficulty_index == 6 then
			if carry_id == bag_secure then
				return bag_values
			end
		end            
		return get_bag_value_original(self, carry_id, multiplier)
	end
end

local function grinder(bagdata)
	global_grinder_toggle = global_grinder_toggle or false
    if not global_grinder_toggle then
		CopActionHurt.on_death_drop = _hacked_death_drop
		money_value()
		table.insert(bag_table, bagdata)
        managers.mission._fading_debug_output:script().log('Grinder ACTIVATED', Color.green)
    else
		CopActionHurt.on_death_drop = _orig_death_drop
		if get_bag_value_original then MoneyManager.get_bag_value = get_bag_value_original end
        managers.mission._fading_debug_output:script().log('Grinder DEACTIVATED', Color.red)
	end
	global_grinder_toggle = not global_grinder_toggle
end

local function push_enemies()
	--push force when shot enemy
	global_push_kill_toggle = global_push_kill_toggle or false
    if not global_push_kill_toggle then
		local push_scale 		= 2	-- 0.0 - 10.0, sets the force of the push, 1.0 is normal shotgun push
		local push_direction 	= 0.5	-- 0.0 - 1.0, sets the height direction of the push, 1.0 is all the way up, 0.0 is all the way down
		local dmgmul = 0.1
		if not global_toggle_push_kill then global_toggle_push_kill = RaycastWeaponBase._collect_hits end
		local old_collect = RaycastWeaponBase._collect_hits
		function RaycastWeaponBase:_collect_hits(from, to)
			local unique_hits, hit_enemy = old_collect(self, from, to)
			if hit_enemy and unique_hits[1] then
				local p_unit = managers.player:player_unit()
				local dam = self:get_damage_falloff(self:_get_current_damage(dmgmul), unique_hits[1], p_unit)
				local hit_result = self._bullet_class:on_collision(unique_hits[1], self._unit, p_unit, dam)
				if hit_result and hit_result.type == "death" then
					local unit = unique_hits[1].unit
					if unit:movement()._active_actions[1] and unit:movement()._active_actions[1]:type() == "hurt" then
						unit:movement()._active_actions[1]:force_ragdoll() end
					
					for i = 0, unit:num_bodies() - 1 do
						local u_body = unit:body(i)
						
						if u_body:enabled() and u_body:dynamic() then
							World:play_physic_effect(Idstring("physic_effects/shotgun_hit"), u_body, 
							Vector3(unique_hits[1].ray.x, unique_hits[1].ray.y, unique_hits[1].ray.z + push_direction) * 600 * push_scale, 4 * u_body:mass(), 
							(unique_hits[1].ray:cross(math.UP) + math.UP * 0.5) * -1000 * math.sign(mvector3.distance(unique_hits[1].hit_position, unit:position()) - 100), 2)
						end
					end
				end
			end
			return unique_hits, hit_enemy
		end
		if not global_toggle_push_kill2 then global_toggle_push_kill2 = RaycastWeaponBase._fire_raycast end
		local old_fire = RaycastWeaponBase._fire_raycast
		function RaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
			dmgmul = dmg_mul
			return old_fire(self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
		end
		managers.mission._fading_debug_output:script().log('Push Kill ACTIVATED', Color.green)
	else
		if global_toggle_push_kill then RaycastWeaponBase._collect_hits = global_toggle_push_kill end
		if global_toggle_push_kill2 then RaycastWeaponBase._fire_raycast = global_toggle_push_kill2 end
		managers.mission._fading_debug_output:script().log('Push Kill DEACTIVATED', Color.red)
	end
	global_push_kill_toggle = not global_push_kill_toggle
end

bag_value_menu2 = function()
	local dialog_data = {    
		title = "Bag Menu",
		text = "Select Option",
		button_list = {}
	}
	
	for bag_id, bag_data in pairs( tweak_data.carry ) do
		if not (string.startswith(bag_id, "vehicle")) then
			local name_id = bag_data.name_id
			if name_id and managers.localization:exists(name_id) then
				table.insert(dialog_data.button_list, {
					text = managers.localization:text(name_id), --parse_unit_name(name_id)
					callback_func = function() 
						grinder(bag_id)
						managers.mission._fading_debug_output:script().log(string.format('Ginder Bag %s', managers.localization:text(name_id)), Color.green)
					end,
					table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
				})
			end
		end
	end
	
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "------------------------- Use Scroll Wheel ------------------------",})
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "back", callback_func = function() bag_value_menu() end,})
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}
	table.insert(dialog_data.button_list, no_button) 
	managers.system_menu:show_buttons(dialog_data)
end

bag_value_menu = function()
	local dialog_data = {    
		title = "Relative Value Menu",
		text = "Select Option",
		button_list = {}
	}
	
	for i = 1000, 1, -1 do
		table.insert(dialog_data.button_list, {
			text = i.."00",
			callback_func = function() 
				bag_values = i
				bag_value_menu2() 
				managers.mission._fading_debug_output:script().log(string.format("Securing - %s00", i), Color.green) 
				managers.chat:feed_system_message(ChatManager.GAME, "Only spawn bags that can be acquired in the heist!")
			end,      
		})
	end
	
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {
		text = "1000000",
		callback_func = function() 
			bag_values = 10000
			bag_value_menu2() 
			managers.mission._fading_debug_output:script().log(string.format("Securing - 1000000"), Color.green) 
			managers.chat:feed_system_message(ChatManager.GAME, "Only spawn bags that can be acquired in the heist!")
		end,    
	})
	table.insert(dialog_data.button_list, {
		text = "2000000",
		callback_func = function() 
			bag_values = 20000
			bag_value_menu2() 
			managers.mission._fading_debug_output:script().log(string.format("Securing - 2000000"), Color.green) 
			managers.chat:feed_system_message(ChatManager.GAME, "Only spawn bags that can be acquired in the heist!")
		end,     
	})
	
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "------------------------- Use Scroll Wheel ------------------------",})
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "back", callback_func = function() magic_menu() end,})
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}
	table.insert(dialog_data.button_list, no_button) 
	managers.system_menu:show_buttons(dialog_data)
end

magic_menu = function()
	local dialog_data = {    
		title = "Magic Menu",
		text = "Select Option",
		button_list = {}
	}
	
	local main_magic_menu_table = {
		["input"] = {
			{ text = "Mask Off - ON/OFF", callback_func = function() if alive( managers.player:player_unit() ) then if (managers.player._current_state == "standard") then managers.player:set_player_state("civilian") else managers.player:set_player_state("standard") end end end },
			{ text = "Cameras  - ON/OFF", callback_func = function() cameraoff() end },
			{ text = "End Screen Statestics - ON", callback_func = function() dofile("mods/hook/content/scripts/statestic.lua") end },
			{},
			{ text = "Push On Kill - ON", callback_func = function() push_enemies() end },
			{ text = "Secure On Kill - ON/OFF", callback_func = function() if global_grinder_toggle then grinder() else if Network:is_server() then bag_value_menu() else grinder() end end end },
			{ text = "Secure Big Loot - ON", callback_func = function() graballbigloot() end },
			{ text = "Secure Small Loot - ON", callback_func = function() dofile("mods/hook/content/scripts/secureall.lua") end },
			{},
			{ text = "Bag Bodies - ON", callback_func = function() dofile("mods/hook/content/scripts/bagbodies.lua") end },
			{ text = "Kill/Bag/Grab/Carry Bags - ON", callback_func = function() dofile("mods/hook/content/scripts/killbaggrab.lua") end },
			{ text = "Clear Carry Bags - ON", callback_func = function() clear_carry() end },
			{},
			{ text = "Haki ON", callback_func = function() dofile("mods/hook/content/scripts/haki.lua") end },
			{ text = "Damage Reflect ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/damage reflect.lua") end },
			{ text = "Movement Effect ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/movementeffect.lua") end },
			{ text = "No Clip ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/noclip.lua") end },
			{},
			{ text = "Slow - All Players - ON/OFF", callback_func = function() Slow_Peers() end },
		}
	}
	
	local main_magic_menu_array = "input"
	local spam = true
	if main_magic_menu_table[main_magic_menu_array] then
		for _, dostuff in pairs(main_magic_menu_table[main_magic_menu_array]) do
			if main_magic_menu_table[main_magic_menu_array] then
				if CommandManager:vis(true, "mods/hook/content/scripts/pvp.lua", "check") and spam then
					spam = false
					table.insert(dialog_data.button_list, { text = "PvP - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/pvp.lua") end })
				end
				table.insert(dialog_data.button_list, dostuff)
			end
		end
	end
	
	if not managers.network:session() then
		return
	end
	for _, peer in pairs( managers.network._session._peers ) do
		local peer_id = peer._id
		if peer_id ~= managers.network._session._local_peer._id then
			local peer_name = peer._name
			table.insert(dialog_data.button_list, {
				text = "Slow - " .. peer_name .. " - ON/OFF",
				callback_func = function() Slow_Peer( peer_id ) end,     
			})
		end
	end
	
	table.insert(dialog_data.button_list, {})
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}     
	  
	table.insert(dialog_data.button_list, no_button) 
	managers.system_menu:show_buttons(dialog_data)
end
magic_menu()
