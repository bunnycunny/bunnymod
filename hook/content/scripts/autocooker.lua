function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end

if not is_playing() then 
	return
end

--[[Bugs:
	secure bags client - kicks you after second bag on client side--]]
id_level = managers.job:current_level_id()
if not (id_level == 'nail' or id_level == 'cane' or id_level == 'mex_cooking' or id_level == 'alex_1' or id_level == 'rat' or id_level == 'crojob2' or id_level == 'mia_1') then
	return
end

function can_interact()
	return true
end

Color.labia = Color("E75480") --acid
Color.lilac = Color("D891EF") --caustic soda
Color.purple = Color("9932CC") --hydrogen chloride
Color.wip = Color("0D98BA") --take meth
Color.customyellow = Color("fbff00") --circuit
Color.customred = Color("ff8400") --flare
Color.customwhite = Color("ffffff") --waypoints

bag_amount = 1
local finish_first = 0
local spam_toggle = true
local meth_loop_check = 1
local cooking_waypoint = cooking_waypoint or nil
local msg = {'Muriatic Acid', 'Caustic Soda', 'Hydrogen Chloride', 'Circuit Box On', 'Flare Placed', 'Ephedrine Pill'}
local colormsg = {Color.labia, Color.lilac, Color.purple, Color.customyellow, Color.customred}
local addfake = {'acid', 'caustic_soda', 'hydrogen_chloride'}
local addreal = {'muriatic_acid', 'caustic_soda', 'hydrogen_chloride', 'circuit_breaker', 'place_flare'}
local needed_chem = {'methlab_bubbling', 'methlab_caustic_cooler', 'methlab_gas_to_salt', 'taking_meth'}
local nail_bag_table = {"nail_muriatic_acid", "nail_caustic_soda", "nail_hydrogen_chloride"}
local lab_rat_chem_loc = {
	[1] = Vector3(868.6, -754.2, 1578.6), 
	[2] = Vector3(-4116.9, 580.7, 1456.8), 
	[3] = Vector3(-5638.2, -821.3, 1213), 
	[4] = Vector3(1320, -52, 0)
} 

function load_secure_table()
	level_table = {
		["rat"] = {
			position = Vector3(5700, -10625, 100)
		},
		["alex_1"] = {
			position = Vector3(5700, -10625, 100)
		},
		["cane"] = {
			position = Vector3(7837, -991, -475.28)
		},
		["crojob2"] = {
			position = Vector3(-3907, 9638, -118)
		},
		["nail"] = {
			position = Vector3(-10356.9, -322.8, -3020.3)
		},
		["mia_1"] = {
			position = false
		},
		["mex_cooking"] = {
			position = false
		}
	}
end

if not global_unit_remove_backup then global_unit_remove_backup = ObjectInteractionManager.remove_unit end
function ObjectInteractionManager:remove_unit(unit)
	if (cooking_waypoint == unit:interaction().tweak_data) then
		managers.hud:remove_waypoint(tostring(unit:interaction().tweak_data))
		cooking_waypoint = nil
	end
	managers.hud:remove_waypoint(tostring(unit:interaction().tweak_data))
	global_unit_remove_backup(self, unit)
end

function interactbytweak(inter)
	if not alive(managers.player:player_unit()) then return end
	for _,unit in pairs(World:find_units_quick("all", 1)) do
		local interaction = unit:interaction()
		if interaction then
			if (interaction.tweak_data == inter) and interaction._active then
				interaction.can_interact = can_interact
				if not global_anti_spam_toggle_hook then
					interaction:interact(managers.player:player_unit())
				else
					local icon = tweak_data.interaction[interaction.tweak_data].icon
					for i = math.random(1,5),5 do
						managers.hud:add_waypoint(tostring(interaction.tweak_data), {icon = icon or 'wp_standard', distance = true, position = interaction:interact_position(), no_sync = true, present_timer = 0, state = "present", radius = 10000, color = colormsg[i] or Color.customwhite, blend_mode = "add"})
						break
					end
					cooking_waypoint = interaction.tweak_data
				end
				interaction.can_interact = nil
				break
			end
		end
	end
end

global_toggle_meth = global_toggle_meth or false
if not global_toggle_meth then
	--disable bain dialog
	if not (id_level == "mia_1") then
		if not dialog_bain then dialog_bain = DialogManager.queue_dialog end
		function DialogManager:queue_dialog( id, params )
			return
		end
	end

	function semi_auto_msgs(name)
		if (name == "pku_pills") then
			if not global_anti_spam_toggle_hook then
				managers.mission._fading_debug_output:script().log(string.format('%s Added', msg[6]), Color.wip)
			elseif global_announce_toggle then
				if Network:is_server() then
					managers.chat:send_message(1, managers.network.system, string.format("%s Needed", msg[6]))
				else
					managers.chat:send_message(ChatManager.GAME, 1, string.format("%s Needed", msg[6]))
				end
			elseif not global_announce_toggle then
				managers.chat:_receive_message(1, "COOKER", string.format("%s Needed", msg[6]), tweak_data.system_chat_color)
			end
		else
			for i=1,3 do
				if (name == addreal[i]) then
					if not global_anti_spam_toggle_hook then
						managers.mission._fading_debug_output:script().log(string.format('%s Added', msg[i]), colormsg[i])
					elseif global_announce_toggle then
						if Network:is_server() then
							managers.chat:send_message(1, managers.network.system, string.format("%s Needed", msg[i]))
						else
							managers.chat:send_message(ChatManager.GAME, 1, string.format("%s Needed", msg[i]))
						end
					elseif not global_announce_toggle then
						managers.chat:_receive_message(1, "COOKER", string.format("%s Needed", msg[i]), tweak_data.system_chat_color)
					end
				end
			end
		end
	end
	
	function check_if_added()
		for _,unit in pairs(World:find_units_quick("all", 1)) do
			local interaction = unit:interaction()
			local carry = unit:carry_data()
			if interaction then
				for i=1,3 do
					if (interaction.tweak_data == needed_chem[i]) then
						if interaction._active then
							spam_toggle = false
						else
							spam_toggle = true
						end
					end
				end
			end
		end
	end

	function addchem_and_announce(name, cook)
		for i=1,3 do
			if (name == addreal[i]) then
				local can_pickup = managers.player:can_pickup_equipment(addfake[i])
				if can_pickup then
					--adds wp to chems on ground too
					interactbytweak(addreal[i])
				end
				interactbytweak(cook)
				semi_auto_msgs(name)
			end
		end
	end

	function announce_bagged()
		local BagList = {}
		local bags_on_map
		
		for _,unit in pairs(managers.interaction._interactive_units) do
			if not alive(unit) then 
				bags_on_map = ""
				break
			end
			local interaction = unit:interaction()
			local carry = unit:carry_data()
			if unit and interaction and carry then
				table.insert(BagList, carry:carry_id())
			end
		end
		
		if not (bags_on_map or bags_on_map == "???") then 
			bags_on_map = string.format(". %s Bag(s) On The Ground", #BagList)
		end
		
		DelayedCalls:Add("annouce_delay", 1, function()
			if not alive(managers.player:player_unit()) then return end
			local secured_bags_on_map = (managers.loot:get_secured_mandatory_bags_amount()) + (managers.loot:get_secured_bonus_bags_amount())
			local bags_secured_msg = string.format(". %s Secured", secured_bags_on_map)
			if global_announce_toggle and bags_on_map then
				if secure_bagged then
					if Network:is_server() then
						managers.chat:send_message(1, managers.network.system, string.format("%s Secured Meth Done%s%s", tostring(bag_amount), bags_on_map, bags_secured_msg))
					else
						managers.chat:send_message(ChatManager.GAME, 1, string.format("%s Secured Meth Done%s%s", tostring(bag_amount), bags_on_map, bags_secured_msg))
					end
				else
					if Network:is_server() then
						managers.chat:send_message(1, managers.network.system, string.format("%s Bagged Meth Done%s%s", tostring(bag_amount), bags_on_map, bags_secured_msg))
					else
						managers.chat:send_message(ChatManager.GAME, 1, string.format("%s Bagged Meth Done%s%s", tostring(bag_amount), bags_on_map, bags_secured_msg))
					end
				end
			else
				if secure_bagged then
					managers.mission._fading_debug_output:script().log(string.format("%s Secured Meth Done%s", tostring(bag_amount), bags_on_map), Color.wip)
				else
					managers.mission._fading_debug_output:script().log(string.format("%s Bagged Meth Done%s", tostring(bag_amount), bags_on_map), Color.wip)
				end
			end
		end)
	end
	
	if not toggle_meth_orig then toggle_meth_orig = ObjectInteractionManager.add_unit end
	function ObjectInteractionManager.add_unit(self, unit)
		toggle_meth_orig(self, unit)

		local interaction = unit:interaction()
		if unit and interaction then
			if not alive(managers.player:player_unit()) then return end
			local set_take_bag_type
			local set_take_stationary
			local pos = interaction:interact_position()
			local carry_data = managers.player:get_my_carry_data()
			local position2 = Vector3(pos.x + (-50 or 0), pos.y, pos.z + 40)
			local position = position2 or managers.player:player_unit():camera():position()
			local rotation = managers.player:player_unit():camera():rotation()
			local forward = managers.player:player_unit():camera():forward()
		
			interaction.can_interact = can_interact
			
			if (id_level == 'mex_cooking' or id_level == 'alex_1' or id_level == 'rat') then
				for i=4,5 do
					if (interaction.tweak_data == addreal[i]) and not (interaction.tweak_data == needed_chem[1] or interaction.tweak_data == needed_chem[2] or interaction.tweak_data == needed_chem[3]) then
						interaction:interact(managers.player:player_unit())
						managers.mission._fading_debug_output:script().log(string.format('%s', msg[i]), colormsg[i])
					end						
				end
			end
			
			if interaction.tweak_data == 'pku_pills' then set_take_bag_type = "nail_euphadrine_pills" set_take_stationary = "pku_pills" end
			if interaction.tweak_data == 'taking_meth_huge' then set_take_bag_type = "meth_half" set_take_stationary = "taking_meth_huge" end
			if interaction.tweak_data == 'taking_meth' then set_take_bag_type = "meth" set_take_stationary = "taking_meth" end
			if interaction.tweak_data == 'hold_pku_present' then set_take_bag_type = "present" set_take_stationary = "hold_pku_present" end
			if not set_take_bag_type and not set_take_stationary then return end
			
			local timer
			if id_level == "nail" then
				timer = 2.1
			else
				timer = 0.4
			end
			
			DelayedCalls:Add("interact_meth_flare_circuit", timer, function()
				if not alive(managers.player:player_unit()) then return end --if exit game btw 0-0.4s
				
				if carry_data and (set_take_stationary == "taking_meth") and (carry_data.carry_id == "equipment_bag") then
					managers.player:drop_carry()
				elseif (set_take_stationary == "taking_meth_huge") and (interaction.tweak_data == set_take_stationary) then
					BetterDelayedCalls:Add("drop_bags_3_times_meth_done", 1.3, function()
						if secure_bagged then
							managers.player:drop_carry()
							interactbytweak(set_take_stationary)
							managers.player:clear_carry()
							for i = 1, bag_amount do
								managers.loot:secure(set_take_bag_type, managers.money:get_bag_value(set_take_bag_type), true)
							end
						else
							managers.player:drop_carry()
							interactbytweak(set_take_stationary)
							drop_bag("meth_half", position)
						end
						announce_bagged()
					end, 4)
					return
				elseif (set_take_stationary == "pku_pills") and (interaction.tweak_data == set_take_stationary) then
					managers.player:drop_carry()
					interactbytweak(set_take_stationary)
					find_drop_bag("nail_euphadrine_pills", lab_rat_chem_loc[4], false, 1)
					semi_auto_msgs("pku_pills")
					return
				end
				
				carry_data = managers.player:get_my_carry_data() --updates carry data
			
				if interaction.tweak_data == set_take_stationary then
					if Network:is_server() then
						interaction:interact(managers.player:player_unit())
						if carry_data then
							if secure_bagged then
								managers.hud:remove_special_equipment("carrystacker")
								managers.player:clear_carry()
								bag_amount = bag_amount + 1
								for i = 1, bag_amount do
									managers.loot:secure(set_take_bag_type, managers.money:get_bag_value(set_take_bag_type), true)
								end
								bag_amount = bag_amount - 1
							else
								if id_level == "nail" then
									managers.player:server_drop_carry(set_take_bag_type, 1, false, false, 1, position, Vector3(math.random(-180, 180), math.random(-180, 180), 0), Vector3(0, 0, 1), 100, nil)
								else
									for i = 1, bag_amount do
										managers.player:server_drop_carry(set_take_bag_type, 1, false, false, 1, position, Vector3(math.random(-180, 180), math.random(-180, 180), 0), Vector3(0, 0, 1), 100, nil)
									end
								end
							end
						else
							managers.hud:remove_special_equipment("carrystacker")
							managers.player:clear_carry()
							if secure_bagged then
								for i = 1, bag_amount do
									managers.loot:secure(set_take_bag_type, managers.money:get_bag_value(set_take_bag_type), true)
								end
							else
								if id_level == "nail" then
									managers.player:server_drop_carry(set_take_bag_type, 1, false, false, 1, position, Vector3(math.random(-180, 180), math.random(-180, 180), 0), Vector3(0, 0, 1), 100, nil)
								else
									for i = 1, bag_amount do
										managers.player:server_drop_carry(set_take_bag_type, 1, false, false, 1, position, Vector3(math.random(-180, 180), math.random(-180, 180), 0), Vector3(0, 0, 1), 100, nil)
									end
								end
							end
						end
						announce_bagged()
					else
						if carry_data then
							if secure_bagged then
								load_secure_table()
								if (level_table[id_level].position == false) then
									managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, Vector3(math.random(30000, 78000), math.random(-30000, -110000), 0), Vector3(math.random(-180, 180), math.random(-180, 180), 0), Vector3(0, 0, 1), 1, nil)
									interaction:interact(managers.player:player_unit())
									managers.player:clear_carry()
									managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, Vector3(math.random(30000, 78000), math.random(-30000, -110000), 0), Vector3(math.random(-180, 180), math.random(-180, 180), 0), Vector3(0, 0, 1), 1, nil)
									bag_amount = bag_amount + 1
									for i = 1, bag_amount do
										managers.loot:secure(set_take_bag_type, managers.money:get_bag_value(set_take_bag_type), true) 
									end
									announce_bagged()
									bag_amount = bag_amount - 1
								else
									local secure_position = level_table[id_level].position
									managers.network:session():send_to_host('server_drop_carry', set_take_bag_type, 1, false, false, 1, secure_position, Vector3(math.random(-180, 180), math.random(-180, 180), 0), Vector3(0, 0, 1), 1, nil)
									interaction:interact(managers.player:player_unit())
									managers.player:clear_carry()
									managers.network:session():send_to_host('server_drop_carry', set_take_bag_type, 1, false, false, 1, secure_position, Vector3(math.random(-180, 180), math.random(-180, 180), 0), Vector3(0, 0, 1), 1, nil)
									if bag_amount > 1 then
										bag_amount = bag_amount - 1
										for i = 1, bag_amount do
											managers.loot:secure(set_take_bag_type, managers.money:get_bag_value(set_take_bag_type), true) 
										end
										bag_amount = bag_amount + 1
									end
									announce_bagged()
								end
							else
								managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, 1, nil)
								managers.player:clear_carry()
								interaction:interact(managers.player:player_unit())
								announce_bagged()
							end
						else
							if secure_bagged then
								load_secure_table()
								if (level_table[id_level].position == false) then--works
									interaction:interact(managers.player:player_unit())
									managers.player:clear_carry()
									managers.network:session():send_to_host('server_drop_carry', set_take_bag_type, 1, false, false, 1, Vector3(math.random(20000, 78000), math.random(-20000, -110000), 0), Vector3(math.random(-180, 180), math.random(-180, 180), 0), Vector3(0, 0, 1), 100, nil)
									for i = 1, bag_amount do
										managers.loot:secure(set_take_bag_type, managers.money:get_bag_value(set_take_bag_type), true) 
									end
								else
									local secure_position = level_table[id_level].position
									interaction:interact(managers.player:player_unit())
									managers.player:clear_carry()
									managers.network:session():send_to_host('server_drop_carry', set_take_bag_type, 1, false, false, 1, secure_position, Vector3(math.random(-180, 180), math.random(-180, 180), 0), Vector3(0, 0, 1), 1, nil)
									if bag_amount > 1 then
										bag_amount = bag_amount - 1
										for i = 1, bag_amount do
											managers.loot:secure(set_take_bag_type, managers.money:get_bag_value(set_take_bag_type), true) 
										end
										bag_amount = bag_amount + 1
									end
								end
							else
								interaction:interact(managers.player:player_unit())
								managers.player:clear_carry()
								managers.network:session():send_to_host('server_drop_carry', set_take_bag_type, 1, false, false, 1, position, Vector3(math.random(-180, 180), math.random(-180, 180), 0), Vector3(0, 0, 1), 100, nil)
							end
							announce_bagged()
						end
					end
					meth_loop_check = 1
				end
				interaction.can_interact = nil
			end)
		end
	end

	function drop_bag(name, position)
		local player = managers.player:player_unit()
		if not alive(player) then return end
		local carry_data = managers.player:get_my_carry_data()
		if carry_data and (carry_data.carry_id == name) then
			local forward = player:camera():forward()
			local throw_force = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0) - 1.5
			local carry_data = tweak_data.carry[name]
			local rotation = Rotation(player:camera():rotation():yaw(), 0, 0)
			if Network:is_server() then
				managers.player:server_drop_carry(name, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, throw_force, nil, managers.network:session():local_peer())
			else
				managers.network:session():send_to_host("server_drop_carry", name, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, throw_force, nil)
			end
			managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
			managers.hud:temp_hide_carry_bag()
			managers.player:update_removed_synced_carry_to_peers()
			if managers.player._current_state == "carry" then
				managers.player:set_player_state("standard")
			end
			carry_data = managers.player:get_my_carry_data()
		end
	end
	
	function find_drop_bag(id, pos, toggle, counter, msg)
		if not global_anti_spam_toggle_hook then
			local carry_data = managers.player:get_my_carry_data()
			if carry_data and (carry_data.carry_id ~= "nail_euphadrine_pills") then
				managers.player:drop_carry()
			end
			BetterDelayedCalls:Add("drop_bags_3_times", 1.3, function()
				for _,unit in pairs(managers.interaction._interactive_units) do
					if not alive(unit) then 
						managers.mission._fading_debug_output:script().log(string.format("Can't find bag, because conflict with sentry."),  colormsg[5])
						return 
					end
					local interaction = unit:interaction()
					local carry = unit:carry_data()
					local carry_data = managers.player:get_my_carry_data()
					if unit and interaction and interaction._active then
						if (unit:position() == pos) and carry_data and (carry_data.carry_id == "nail_euphadrine_pills") then
							interaction:interact(managers.player:player_unit())
							break
						elseif carry and (carry:carry_id() == id) and not carry_data then
							interaction:interact(managers.player:player_unit())
							break
						end
					end
				end
				if toggle then 
					drop_bag(id, pos)
				end
			end, counter)
		end
		if (id ~= "nail_euphadrine_pills") then
			semi_auto_msgs(msg)
		end
	end
	
	local function goto_ids(id)
		if (id_level == "nail") then
			if (id == "pln_rat_stage1_20" or id == "pln_rt1_20") then
				find_drop_bag(nail_bag_table[1], lab_rat_chem_loc[1], true, 3, "muriatic_acid")
			elseif (id == "pln_rat_stage1_22" or id == "pln_rt1_22") then
				find_drop_bag(nail_bag_table[2], lab_rat_chem_loc[2], true, 3, "caustic_soda")
			elseif (id == "pln_rat_stage1_24" or id == "pln_rt1_24") then
				find_drop_bag(nail_bag_table[3], lab_rat_chem_loc[3], true, 3, "hydrogen_chloride")
			end
		else
			if (id == 'pln_rt1_20' or id == "Play_loc_mex_cook_03") then -- acid
				addchem_and_announce("muriatic_acid", "methlab_bubbling")
			elseif (id == 'pln_rt1_22' or id == "Play_loc_mex_cook_04") then -- caustic soda 
				addchem_and_announce("caustic_soda", "methlab_caustic_cooler")
			elseif (id == 'pln_rt1_24' or id == "Play_loc_mex_cook_05") then -- chloride 
				addchem_and_announce("hydrogen_chloride", "methlab_gas_to_salt")
			end
		end
	end
	
	local queue_dialog_original = DialogManager.queue_dialog
	function DialogManager:queue_dialog(id, params)
		if global_anti_spam_toggle and spam_toggle then
			goto_ids(id)
		elseif not global_anti_spam_toggle then
			goto_ids(id)
		end
		if global_anti_spam_toggle then --if anti spam is on, check if chem added
			check_if_added()
		end
		return queue_dialog_original(self, id, params)
	end

	function other_meth_func()
		for _, tracked_interaction in pairs({'methlab_bubbling', 'taking_meth'}) do 
			for _, unit in pairs(managers.interaction._interactive_units) do
				if not alive(unit) then 
					managers.mission._fading_debug_output:script().log(string.format("Can't find bag, because conflict with sentry."),  Color.green)
					return 
				end
				local interaction = unit:interaction()
				if interaction and (interaction.tweak_data == tracked_interaction) then
					if meth_loop_check ~= 4 then
						if meth_loop_check <= 3 then
							addchem_and_announce(addreal[meth_loop_check])
						end
						interactbytweak(needed_chem[meth_loop_check])
						meth_loop_check = meth_loop_check + 1
						break
					end
				end
			end
		end
	end
	
	--santa workshop
	local function auto_cooker_santa()
		for _, data in pairs(managers.enemy:all_civilians()) do
			if not alive(managers.player:player_unit()) then return end
			data.unit:brain():on_intimidated(100, managers.player:player_unit())
		end
	end
	
	--nail crack meth
	local path = "units/pd2_dlc_nails/props/nls_prop_methlab_meth/%s"
	local UnitPaths = {
		string.format( path, "nls_prop_methlab_meth" ),
		string.format( path, "nls_prop_methlab_meth_a" ),
		string.format( path, "nls_prop_methlab_meth_b" ),
		string.format( path, "nls_prop_methlab_meth_c" ),
		string.format( path, "nls_prop_methlab_meth_d" )
	}

	function killobjectunit(unit)
		for i = 0, unit:num_bodies() do
			local body = unit:body(i)
			if ( body and body:enabled() ) and ( body:unit():id() ~= -1 ) then
				local center = body:center_of_mass()
				local pos = body:position()
				local unit_damage = body:extension() and body:extension().damage
				local damage_val = 5000
				local user_unit = managers.player:player_unit()
				if unit_damage and Network:is_server() then
					if finish_first <= 5 then
						unit_damage:damage_explosion( user_unit, center, pos, Vector3(0,0,0), damage_val )
						unit_damage:damage_damage( user_unit, center, pos, center, damage_val )
						finish_first = finish_first + 1
					else
						unit_damage:damage_explosion( user_unit, center, nil, pos, Vector3(0,0,0), damage_val )
						unit_damage:damage_damage( user_unit, center, pos, center, damage_val )
					end
					
					local session = managers.network:session()
					local pUnit = managers.player:player_unit()
					if alive(pUnit) then
						session:send_to_peers_synched( "sync_body_damage_explosion", body, pUnit, center, pos, center, damage_val )
					else
						session:send_to_peers_synched( "sync_body_damage_explosion_no_attacker", body, center, pos, center, damage_val )
					end
					managers.network:session():send_to_peers_synched( "remove_unit", body )
				end
			end
		end
	end
	
	local function crack_meth()
		for _, unit in ipairs( World:find_units_quick( "all" ) ) do
			for _, u_data in pairs(UnitPaths) do
				if (unit:name() == Idstring(u_data)) then
					killobjectunit(unit)
				end
			end
		end
	end
	
	if (id_level == 'nail') then BetterDelayedCalls:Add("crack_meth", 2.5, function() crack_meth() end, true) end
	if (id_level == 'crojob2' or id_level == 'mia_1') then BetterDelayedCalls:Add("hotcounter_spawn_meth_chemica", 1.5, function() other_meth_func() end, true) end
	if (id_level == "cane") then BetterDelayedCalls:Add("santa_workshop_spawn_meth_chemica", 0.5, function() auto_cooker_santa() end, true) end
	managers.mission._fading_debug_output:script().log('Cooker ACTIVATED', Color.green)
else
	if (id_level == 'nail') then
		BetterDelayedCalls:Remove("drop_bags_3_times")
		BetterDelayedCalls:Remove("crack_meth")
		BetterDelayedCalls:Remove("drop_bags_3_times_meth_done")
	end
	if (id_level == 'rat') then BetterDelayedCalls:Remove( "rats_ac_anti_spam") end
	if (id_level == 'crojob2' or id_level == 'mia_1') then BetterDelayedCalls:Remove( "hotcounter_spawn_meth_chemica") end
	if (id_level == 'cane') then BetterDelayedCalls:Remove( "santa_workshop_spawn_meth_chemica") end
	if global_unit_remove_backup then ObjectInteractionManager.remove_unit = global_unit_remove_backup end
	if toggle_meth_orig then ObjectInteractionManager.add_unit = toggle_meth_orig end
	if global_toggle_secure_meth then secure_bagged = false global_toggle_secure_meth = not global_toggle_secure_meth end
	if global_semi_auto_hook then global_anti_spam_toggle_hook = false global_semi_auto_hook_hook = not global_semi_auto_hook end
	if global_announce then global_announce_toggle = false global_announce = not global_announce end
	if global_spam_ac then global_anti_spam_toggle = false global_spam_ac = not global_spam_ac end
	if dialog_bain then DialogManager.queue_dialog = dialog_bain end
	managers.mission._fading_debug_output:script().log('Cooker DEACTIVATED', Color.red)
end
global_toggle_meth = not global_toggle_meth