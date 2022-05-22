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
	local player = managers.player._players[1] or managers.player:player_unit()
	if not player then
		return
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
		if not alive(player) then break end
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
end

function run_events(event)
	function ray_pos()
		local unit = managers.player:player_unit()
		if not (alive(unit)) then return end
		local m_head_rot = unit:movement():m_head_rot()
		local from = unit:movement():m_head_pos()
		local to = unit:movement():m_head_pos() + m_head_rot:y() * 99999

		local ray = World:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
		if (ray) then
			return ray.position, Rotation(m_head_rot:yaw(), 0, 0)
		end
	end
	local player = managers.player:player_unit()
	if not player or not alive(player) then
		return
	end
	local element_table_pos = { --add elements with vectors
		"spawn_gold",
		100329, --top lab
		100330, --middle lab
		100332,	--basement lab
		102491, --spawn 1 meth rat
		102468,	--spawn 1 meth rat
		102467,	--spawn 1 meth rat
		100678	--spawn 1 meth rat
	}
	for _, data in pairs(managers.mission._scripts) do
		for id, element in pairs(data:elements()) do
			local m_head_rot = managers.player:player_unit():movement():m_head_rot()
			local from = managers.player:player_unit():movement():m_head_pos()
			local to = managers.player:player_unit():movement():m_head_pos() + m_head_rot:y() * 99999
			local ray = World:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
			if not ray then return end
			local ray_found = ray.position, Rotation(m_head_rot:yaw(), 0, 0)
			local pos = Vector3(ray_found.x, ray_found.y, ray_found.z)
			local pos2 = (player):camera():position() + Vector3(math.random(20000*-1,20000),math.random(20000*-1,20000),6000)
			if element._editor_name == event then
				if Network:is_server() then
					if element._values.position then
						if not pos then return end
						for _, ele_table in pairs(element_table_pos) do
							if (event == ele_table) then
								for amount=1,1 do
									element._values.rotation = player:camera():rotation()
									element._values.position = pos
								end
							end
						end
					end
					element:on_executed(player)
				else
					CommandManager:vis("event", element._id, player)
				end
				break
			elseif id == event then
				if Network:is_server() then
					if element._values.position then
						if not pos then return end
						for _, ele_table in pairs(element_table_pos) do
							if (event == ele_table) then
								for amount=1,1 do
									element._values.rotation = player:camera():rotation()--Rotation(-90, 0, -0)
									element._values.position = pos
								end
							end
						end
					end
					element:on_executed(player)
				else
					managers.network:session():send_to_host("to_server_mission_element_trigger", element._id, player)
				end
				break
			end
		end
	end
	managers.mission._fading_debug_output:script().log(string.format("Event: %s activated", event),  Color.green)
end

function event_turn_off_draw()
	global_draw_elements = global_draw_elements or false
	if not global_draw_elements then
		if not global_element_draw then global_element_draw = MissionManager.update end
		local orig = MissionManager.update
		function MissionManager:update( t, dt )
			orig(self, t, dt)
			for _,script in pairs( self._scripts ) do
				script:update( t, dt )
				script:_debug_draw( t, dt )
			end
		end
		
		if not global_element_draw2 then global_element_draw2 = MissionScript._debug_draw end
		function MissionScript:_debug_draw()
			event_table = {}
			local name_brush = Draw:brush( Color.red )
			name_brush:set_font( Idstring( "fonts/font_medium" ), 16 )
			name_brush:set_render_template( Idstring( "OverlayVertexColorTextured" ) )
			for _,element in pairs( self._elements ) do
				local elen = element._editor_name
				if not (string.startswith(elen, "anim")) and not (string.startswith(elen, "point")) and not (string.startswith(elen, "WP_")) and not (string.startswith(elen, "sound")) then
					name_brush:set_color( element:enabled() and Color.green or Color("7A7A7A") )
					if true then
						if element:value( "position" ) then	
							if managers.viewport:get_current_camera() then
								local cam_up = managers.viewport:get_current_camera():rotation():z()
								local cam_right = managers.viewport:get_current_camera():rotation():x()
								local screenmsg = string.format("%s / %s", element:editor_name(), element:id())
								name_brush:center_text( element:value( "position" ) + Vector3(0, 0, 30), screenmsg, cam_right, -cam_up )
							end
						end
					end
				end
			end
		end
		managers.mission._fading_debug_output:script().log(string.format("Draw - ACTIVATED"),  Color.green)
	else
		if global_element_draw then MissionManager.update = global_element_draw end
		if global_element_draw2 then MissionScript._debug_draw = global_element_draw2 end
		managers.mission._fading_debug_output:script().log(string.format("Draw - DEACTIVATED"),  Color.red)
	end
	global_draw_elements = not global_draw_elements
end

event_menu_list = function()
	local dialog_data = {    
		title = "Event List Menu",
		text = "Select Option",
		button_list = {}
	}
	for _, data in pairs(managers.mission._scripts) do
		for _, element in pairs(data:elements()) do
			if element._editor_name then
				table.insert(dialog_data.button_list, {
					text = element._editor_name,
					callback_func = function() run_events(element._editor_name) end,
				})
			end
		end
	end
	table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "back", callback_func = function() event_menu() end, })
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}     
	table.insert(dialog_data.button_list, no_button) 
	managers.system_menu:show_buttons(dialog_data)
end

local events_table = {
	["kosugi"] = {
		{ text = "Open Vault", callback_func = function() run_events("two_keys_used") end },
		{ text = "Escape", callback_func = function() run_events("start_escape") end },
		{ text = "Spawn Thermite", callback_func = function() run_events("pp_shadow_raid_deaddrop001") run_events("pp_shadow_raid_deaddrop002") run_events("pp_shadow_raid_deaddrop003") run_events("pp_shadow_raid_deaddrop004") run_events("pp_shadow_raid_deaddrop005") run_events("pp_shadow_raid_deaddrop006") run_events("pp_shadow_raid_deaddrop017") run_events("pp_shadow_raid_deaddrop018") end },
		{ text = "Loot Drop Off", callback_func = function() run_events("enable_zipline33") run_events("enable_zipline") run_events("pp_shadow_raid_loot_drop_off004") run_events("pp_shadow_raid_loot_drop_off003") run_events("pp_shadow_raid_loot_drop_off002") run_events("pp_shadow_raid_loot_drop_off001") end },
		{ text = "Spawn Chopper", callback_func = function() run_events("blackhawk_sequence") end },
		{ text = "Secure Trucks", callback_func = function() run_events("logic_toggle_009") run_events("logic_toggle_012") end },
		{ text = "Secure Bag", callback_func = function() run_events("securedBag") end },
		{ text = "Spawn Samurai Armor", callback_func = function() for i=1,60 do run_events("samurai_armor") end end },
		{ text = "spawn Artifact", callback_func = function() for i=1,60 do run_events("spawn_artifact") end end },
		{ text = "Spawn Weapons", callback_func = function() for i=1,60 do run_events("spawn_weapons") end end },
		{ text = "Spawn Gold", callback_func = function() for i=1,60 do run_events("spawn_gold") end end },
		{ text = "Spawn Money", callback_func = function() for i=1,60 do run_events("spawn_money") end end },
		{ text = "Spawn Painting", callback_func = function() for i=1,60 do run_events("spawn_painting") end end },
		{ text = "Spawn Foreman", callback_func = function() for i=1,2 do run_events("spawn_foreman") end end },
		{ text = "Spawn Patrol", callback_func = function() run_events("patroling_guard_spawn_001") run_events("patroling_guard_spawn_007") end },
		{ text = "Spawn Chopper Guards", callback_func = function() for i=1,5 do run_events("spawn_chopper_guards") end end },
	},
	["rat"] = {
		{ text = "No Return timer", callback_func = function() run_events("func_point_no_return_001") end },
		{ text = "Explode Lab", callback_func = function() run_events("failNowExplode") run_events("instant_failend") end },
		{ text = "Van Arrive", callback_func = function() run_events(101128) end },
		{ text = "Place Zipline", callback_func = function() run_events(102060) end },
		{ text = "Secure Van bags", callback_func = function() run_events(102460) end },
		{ text = "Spawn Lab Top", callback_func = function() run_events(100329) run_events(100483) end },
		{ text = "Spawn Lab Middle", callback_func = function() run_events(100330) run_events(100485) end },
		{ text = "Spawn Lab Basement", callback_func = function() run_events(100332) run_events(100486) end },
		{ text = "Spawn Meth Bags", callback_func = function() run_events(102491) run_events(102468) run_events(102467) run_events(100678) end },
		{ text = "Spawn Meth Table", callback_func = function() run_events("show_meth") end },
		{ text = "Assets", callback_func = function() run_events("point_spawn_deployable_grenade005") run_events("point_spawn_deployable_grenade004") run_events("point_spawn_deployable_grenade003") run_events("point_spawn_deployable_grenade002") run_events("point_spawn_deployable_grenade001") run_events("point_spawn_deployable_008") run_events("point_spawn_deployable_007") run_events("point_spawn_deployable_006") run_events("point_spawn_deployable_005") run_events("point_spawn_deployable_004") run_events("point_spawn_deployable_003") run_events("point_spawn_deployable_002") run_events("point_spawn_deployable_001") run_events("point_spawn_deployable_health005") run_events("point_spawn_deployable_health004") run_events("point_spawn_deployable_health003") run_events("point_spawn_deployable_health002") run_events("point_spawn_deployable_health001") end },
		{ text = "Spawn Chemicals", callback_func = function() run_events("spawnmuraids") run_events("spawnLiquidMeth") end },
		{ text = "Spawn Planks", callback_func = function() run_events("spawnPlanks") run_events("spawnPlanks") run_events("spawnPlanks") run_events("spawnPlanks") run_events("spawnPlanks") run_events("spawnPlanks") end },
		{ text = "Spawn Dozer", callback_func = function() run_events("ai_spawn_enemy_054") run_events("ai_spawn_enemy_070") end },
		{ text = "Spawn Sniper/Spook", callback_func = function() run_events("sniper001") run_events("sniper002") run_events("sniper003") run_events("sniper004") run_events("sniper005") run_events("spooc") end },
		{ text = "Spawn Gangsters", callback_func = function() run_events("pre1") run_events("pre2") run_events("pre3") run_events("pre4") end },
		{ text = "Spawn Cooks", callback_func = function() run_events("spawn_cooks") end },
	},
	["alex_1"] = { --meth table, van arrive is diffrent then rat
		{ text = "No Return timer", callback_func = function() run_events("func_point_no_return_001") end },
		{ text = "Explode Lab", callback_func = function() run_events("failNowExplode") run_events("instant_failend") end },
		{ text = "Van Arrive", callback_func = function() run_events("van_done_arrive") end },
		{ text = "Secure Van bags", callback_func = function() run_events(102460) end },
		{ text = "Place Zipline", callback_func = function() run_events(102060) end },
		{ text = "Spawn Lab Top", callback_func = function() run_events(100329) run_events(100483) end },
		{ text = "Spawn Lab Middle", callback_func = function() run_events(100330) run_events(100485) end },
		{ text = "Spawn Lab Basement", callback_func = function() run_events(100332) run_events(100486) end },
		{ text = "Spawn Meth Bags", callback_func = function() run_events(102491) run_events(102468) run_events(102467) run_events(100678) end },
		{ text = "Spawn Meth Table", callback_func = function() run_events("enableMeth") end },
		{ text = "Assets", callback_func = function() run_events("point_spawn_deployable_grenade005") run_events("point_spawn_deployable_grenade004") run_events("point_spawn_deployable_grenade003") run_events("point_spawn_deployable_grenade002") run_events("point_spawn_deployable_grenade001") run_events("point_spawn_deployable_008") run_events("point_spawn_deployable_007") run_events("point_spawn_deployable_006") run_events("point_spawn_deployable_005") run_events("point_spawn_deployable_004") run_events("point_spawn_deployable_003") run_events("point_spawn_deployable_002") run_events("point_spawn_deployable_001") run_events("point_spawn_deployable_health005") run_events("point_spawn_deployable_health004") run_events("point_spawn_deployable_health003") run_events("point_spawn_deployable_health002") run_events("point_spawn_deployable_health001") end },
		{ text = "Spawn Chemicals", callback_func = function() run_events("spawnmuraids") run_events("spawnLiquidMeth") end },
		{ text = "Spawn Planks", callback_func = function() run_events("spawnPlanks") run_events("spawnPlanks") run_events("spawnPlanks") run_events("spawnPlanks") run_events("spawnPlanks") run_events("spawnPlanks") end },
		{ text = "Spawn Dozer", callback_func = function() run_events("ai_spawn_enemy_054") run_events("ai_spawn_enemy_070") end },
		{ text = "Spawn Sniper/Spook", callback_func = function() run_events("sniper001") run_events("sniper002") run_events("sniper003") run_events("sniper004") run_events("sniper005") run_events("spooc") end },
		{ text = "Spawn Gangsters", callback_func = function() run_events("pre1") run_events("pre2") run_events("pre3") run_events("pre4") end },
		{ text = "Spawn Cooks", callback_func = function() run_events("spawn_cooks") end },
	},
	["nail"] = {
		{ text = "Spawn Spider", callback_func = function() run_events("exec_spawn_spider") end },
		{ text = "Open Safe", callback_func = function() run_events("Open the safe") end },
		{ text = "Spawn Meth?", callback_func = function() run_events(100273) run_events(100169) run_events(100272) run_events(100101) end },
	},
	["brb"] = {
		{ text = "Blow Up After Saw", callback_func = function() run_events("blow_up") end },
		{ text = "Thermite Done", callback_func = function() run_events("thermite_melt_finished") run_events("thermite_finished") end },
		{ text = "Winch Done", callback_func = function() run_events("winch_started") run_events("enable winch") end },
		{ text = "Shake Screen or open medalion", callback_func = function() run_events("point_shake") end },
	},
	["watchdogs_1"] = {
		{ text = "Spawn Coke", callback_func = function() run_events("spawnCoke") end },
	},
	["mus"] = {
		{ text = "Disable Lasers", callback_func = function() run_events("disable_laser") run_events("disable_alarm_cases_and_extra_lasers") end },
		{ text = "Open Barrier", callback_func = function() run_events("open_barrier") end },
		{ text = "Assets", callback_func = function() run_events("pp_mus_spotter001") run_events("pp_mus_spotter002") run_events("pp_mus_spotter003") run_events("pp_mus_spotter004") run_events("pp_mus_spotter005") run_events("pp_mus_spotter006") run_events("pp_mus_lootdropoff002")	run_events("pp_mus_lootdropoff001") run_events("pp_mus_extra_cam001") run_events("pp_mus_extra_cam002") run_events("pp_mus_extra_cam003") run_events("pp_mus_extra_cam004") run_events("pp_mus_extra_cam005") run_events("pp_mus_extra_cam006") run_events("pp_mus_extra_cam007") run_events("pp_mus_glasscutter001")	run_events("pp_mus_paste001") end },
		{ text = "Diamond Path", callback_func = function() 
		interactbytweak('invisible_interaction_open')
		DelayedCalls:Add( "hack_box", 1, function()interactbytweak('hack_electric_box') end)
		for i=1, 3, 1 do run_events("select_path001") run_events("select_path002") run_events("select_path003") run_events("select_path004") run_events("select_path005") run_events("select_path006") run_events("select_path007") run_events("select_path008") run_events("select_path009") run_events("select_path010") run_events("select_path011") run_events("select_path012") run_events("select_path013") run_events("select_path014") run_events("select_path015") run_events("select_path016") run_events("select_path017") run_events("select_path018") run_events("select_path019") run_events("select_path020") run_events("select_path021") run_events("select_path022") run_events("select_path023") run_events("select_path024") run_events("select_path025") run_events("select_path026") run_events("select_path027") run_events("select_path028") run_events("select_path029") run_events("select_path030") run_events("select_path031") run_events("select_path032") run_events("select_path033") run_events("select_path034") run_events("select_path035") run_events("select_path036") run_events("select_path037") run_events("select_path038") run_events("select_path039") run_events("select_path040") run_events("select_path041") run_events("select_path042") end end },
		{ text = "Place Circuit Boxes", callback_func = function() run_events("set_circuit_box") end },
		{ text = "Spawn Guard", callback_func = function() run_events("patroling_guard_spawn_017") end },
	},
	["cage"] = {
		{ text = "Finish Hack Computer", callback_func = function() run_events("timer_is_correct") end },
		{ text = "Hack Correct Computer", callback_func = function() run_events("correct_computer") end },
		{ text = "Computer ECM Off", callback_func = function() run_events("ecm_OFF") end },
		{ text = "Spawn Body Bags", callback_func = function() run_events("body_bag_001") run_events("body_bag_002") run_events("body_bag_003") run_events("body_bag_004") run_events("body_bag_005") end },
		{ text = "Spawn Managers", callback_func = function() run_events("spawn_walking_manager") run_events("spawn_manager_top_office") run_events("spawn_manager_at_top_sitting") run_events("spawn_manager_at_top_front") run_events("spawn_manager_at_prints") run_events("spawn_manager_at_conf") run_events("spawn_manager_single_office") end },
		{ text = "Spawn Pedestrian", callback_func = function() run_events("spawn_pedestrians") end },
		{ text = "Spawn Guard", callback_func = function() run_events("patroling_guard_spawn_001") end },
		{ text = "Unlock Cars", callback_func = function() run_events("car_unlocked_001") run_events("car_unlocked_002") run_events("car_unlocked_003") run_events("car_unlocked_004") end },
		{ text = "Explode Hole", callback_func = function() run_events("c4_exploded") run_events("blow_up_c4") end },
	},
	["tag"] = {
		{ text = "Open Gate", callback_func = function() run_events(101211) run_events(101183) end },
		{ text = "Lure Phone", callback_func = function() run_events(101885) end },
		{ text = "Lure Lights", callback_func = function() run_events(101407) end },
		{ text = "Lure Computer", callback_func = function() run_events(101531) end },
		{ text = "Show Boxes", callback_func = function() 
			local sec_boxes = {
				136863, --1
				137063, --2
				137263, --3
				137463, --4
				137663, --5
				137863, --6
				138063, --7
				131363, --8
				131563, --9
				131763, --10
				131963, --11
				132163, --12
				132363, --13
				132563 --14
			}
			for k, v in pairs(sec_boxes) do
				run_events(v) 
			end
		end },
		{ text = "Show Computer", callback_func = function() 
			local computers = {
				136770, --3
				138570, --5
				142220, --6
				148370, --9
				148270, --8
				153070, --12
				153170, --13
				153270, --14
				156070, --18
				156370, --21
				156470 --22
			}
			for k, v in pairs(computers) do
				run_events(v) 
			end
		end },
		{ text = "Open Garretts Door", callback_func = function() run_events("lured_garrett") end },
		{ text = "Open Safe", callback_func = function() run_events("input_open_safe") end },
		{ text = "Garrett Goes Out/Inn", callback_func = function() run_events("input_grab_garrett") end },
		{ text = "Add Secure Zipline", callback_func = function() run_events("link_secure_loot_skylight001") run_events("WP_secure_loot_skylight001") run_events("interacted_zipline_escape001") end },
		{ text = "Spawn Bodybags", callback_func = function() run_events("deployable_bodybags_bag001") run_events("deployable_bodybags_bag002") run_events("deployable_bodybags_bag003") end },
		{ text = "Spawn Loot", callback_func = function() run_events("random_loot") end },
	},
	["election_day_1"] = {
		{ text = "Tag Right Truck", callback_func = function() run_events("tag_right_truck") run_events("tagged") end },
	},
	["election_day_2"] = {
		{ text = "Bonus Gold", callback_func = function() run_events("enablebonusmoney") end },
		{ text = "More guards", callback_func = function() run_events("extra_spawn_patrolguard") end },
	},
	["chas"] = {
		{ text = "Vault door stealth", callback_func = function() run_events(101681) end },
		{ text = "Vault door loud", callback_func = function() run_events(101139) end },
	},
	["dah"] = {
		{ text = "Add Zipline", callback_func = function() run_events("zipline_interacted") end },
		{ text = "Spot All Laptops And Hack SecBoxes", callback_func = function() interactbytweak('hack_ipad') run_events("spot_laptop_001") run_events("spot_laptop_002") run_events("spot_laptop_003") end },
		{ text = "Disable Lasers", callback_func = function() run_events("Deactivate_laser_triggers") end },
		{ text = "Open Main Vault", callback_func = function() run_events("Open_the_Vault") end },
		{ text = "Spawn red diamond 20% chance", callback_func = function() run_events("red_diamond_chance_dw") end },
		{ text = "Open Red Diamond Vault", callback_func = function() run_events("Open_red_diamond_vault") end },
		{ text = "Spawn Cops", callback_func = function() run_events("spawn_cops") end },
		{ text = "Spawn Patrols", callback_func = function() run_events("spawn_patrols") end },
	},
	["red2"] = {
		{ text = "Spawn Circuit Boxes", callback_func = function() run_events("set_circuit_box") end },
		{ text = "Correct Vault Code", callback_func = function() run_events("code_success") end },
		{ text = "Open Vault 1", callback_func = function() run_events(136037) run_events(136237) run_events(105825) end },
		{ text = "Open Vault 2", callback_func = function() run_events("open_vault") end },
		{ text = "Open Vault 2 (Loud Thermite)", callback_func = function() run_events("thermite_done") run_events("show_thermite_hole") end },
		{ text = "Overdrill Light On", callback_func = function() run_events(104136) run_events(104349) end },
		{ text = "Overdrill Open Gate", callback_func = function() run_events(104180) end },
		{ text = "Overdrill Open Vault", callback_func = function() run_events(104192) run_events(104198) run_events(104303) end },
		{ text = "Open Keypad door", callback_func = function() run_events(100769) end },
		{ text = "Blow Up Wall", callback_func = function() run_events("hide_C4_show_hole") end },
		{ text = "Spawn Inside Man (Stealth)", callback_func = function() run_events("spawn_inside_man") end },
		{ text = "Spawn Guards Everywhere", callback_func = function() run_events("guards_vault001") run_events("guard_patrolling_upstairs002") run_events("guard_patrolling_downstairs003") end },
		{ text = "Spawn Enemy In Vault", callback_func = function() run_events("ai_spawn_enemy_elevator008") run_events("ai_spawn_enemy_elevator001") run_events("ai_spawn_enemy_elevator005") run_events("ai_spawn_enemy_after_vault009") run_events("ai_spawn_enemy_after_vault001") run_events("ai_spawn_enemy_after_vault002") run_events("ai_spawn_enemy_after_vault003") run_events("ai_spawn_enemy_after_vault004") run_events("ai_spawn_enemy_after_vault005") run_events("ai_spawn_enemy_after_vault006") run_events("ai_spawn_enemy_after_vault007") run_events("ai_spawn_enemy_after_vault008") run_events("ai_spawn_enemy_elevator003") end },
	},
	["branchbank"] = {
		{ text = "Open Vault", callback_func = function() run_events("open_vault") end },
		{ text = "Unmask Team", callback_func = function() for i=1,4 do run_events("logic_random_024") end end },
		{ text = "Remove Roof", callback_func = function() run_events("no_skylight") end },
		{ text = "Remove Skylight", callback_func = function() run_events("disable_skylights") end },
		{ text = "Assets", callback_func = function() run_events("pp_branchbank_safe_escape001") run_events("pp_branchbank_sniper_spot001") run_events("pp_branchbank_camera_access002") run_events("pp_branchbank_disable_alarm_button001") run_events("pp_branchbank_disable_alarm_button002") run_events("pp_branchbank_ammo_bag001") run_events("pp_branchbank_ammo_bag001") run_events("pp_branchbank_spycam001") run_events("pp_branchbank_spycam002") run_events("pp_branchbank_spycam003") run_events("pp_branchbank_spycam003") run_events("pp_branchbank_keycard001") run_events("pp_branchbank_health_bag002") run_events("pp_branchbank_keycard002") run_events("pp_branchbank_vault_key001") end },
		{ text = "Spawn Cloaker", callback_func = function() run_events("cloaker_spawn001") run_events("cloaker_spawn002") run_events("cloaker_spawn003") run_events("cloaker_spawn004") run_events("cloaker_spawn005") run_events("cloaker_spawn006") run_events("cloaker_spawn007") run_events("cloaker_spawn008") run_events("cloaker_spawn009") run_events("cloaker_spawn010") run_events("cloaker_spawn011") run_events("cloaker_spawn012") run_events("cloaker_spawn013") end },
		{ text = "Spawn Guard", callback_func = function() for i=1,5 do run_events("spawnGuards001") end end },
		{ text = "Spawn Money", callback_func = function() for i=1,3 do run_events("gold") run_events("gold/money") end end },
		{ text = "Spawn Turrets", callback_func = function() run_events("spawn_turret001") run_events("spawn_turret002") end },
		{ text = "Spawn Civilians", callback_func = function() run_events("spawnTellers") run_events("spawnCivs") end },	
	},
	["big"] = {
		{ text = "Open Vault 1", callback_func = function() run_events("start_timer") end },
		{ text = "Remove Vault 2", callback_func = function() run_events("disable_all_vault_doors") end },
		{ text = "Set Vault Doors", callback_func = function() run_events("vault_door_003") run_events("vault_door_002") run_events("vault_door_001") run_events("vault_door_004") end },
		{ text = "Disable Laser", callback_func = function() run_events("disable_laser") end },
		{ text = "Interact Server Computer", callback_func = function() run_events("interacted_server_keyboard") end },
		{ text = "Assets", callback_func = function() run_events("pp_keycard001") run_events("pp_keycard002") run_events("pp_keycard003") run_events("pp_keycard004") run_events("secure_bag_area_001") run_events("pp_extra_zipline") run_events("pp_zipline001") run_events("pp_highlight_keybox") run_events("pp_reduce_timelock001") run_events("pp_unlocked_door001") run_events("pp_unlocked_door002") run_events("pp_unlocked_door003") run_events("pp_unlocked_door004") run_events("pp_unlocked_door005") run_events("pp_spotter001") run_events("pp_spotter002") run_events("pp_spotter003") run_events("pp_spotter004") run_events("pp_spotter005") run_events("pp_spotter006") run_events("pp_spotter007") run_events("enable_elevator_interaction") end },
		{ text = "Spawn Zipline", callback_func = function() run_events("show_zipline") end },
		{ text = "Spawn Guards Room 1", callback_func = function() run_events("patroling_guard_spawn_elevator_002") end },
		{ text = "Spawn Guards Room 2", callback_func = function() run_events("patroling_guards_inner001") end },
	},
	["roberts"] = {
		{ text = "Open Vault", callback_func = function() run_events("open_vault") end },
		{ text = "Spawn Guards", callback_func = function() run_events("patroling_guards002") end },
		{ text = "Spawn Cops", callback_func = function() run_events("spawn_cops") end },
	},
	["framing_frame_1"] = {
		{ text = "Remove Laser", callback_func = function() run_events("randLaser") end },
		{ text = "Open Bars And Barriers", callback_func = function() run_events("openDoors") run_events("barsOpen") end },
		{ text = "Assets", callback_func = function() run_events("pp_framing_frame_1_keycard001") run_events("pp_framing_frame_1_entry_point001") run_events("pp_framing_frame_1_entry_point002") run_events("pp_framing_frame_1_entry_point003") run_events("pp_framing_frame_1_spycam001") run_events("pp_framing_frame_1_spycam002") run_events("pp_framing_frame_1_spycam003") run_events("pp_framing_frame_1_spycam004") run_events("pp_framing_frame_1_spycam005") run_events("pp_framing_frame_1_spycam006") run_events("pp_framing_frame_1_truck001") run_events("pp_framing_frame_1_camera_access001") end },
		{ text = "Spawn Paintings", callback_func = function() run_events("randomPaintings") run_events("randomPaintings") run_events("randomPaintings") run_events("randomPaintings") run_events("randomPaintings") run_events("randomPaintings") run_events("randomPaintings") run_events("randomPaintings") end },
		{ text = "Spawn Guard", callback_func = function() run_events("cloaker_spawn004") end },
	},
	["framing_frame_2"] = {
		{ text = "Trade Done", callback_func = function() run_events("tradeDone") end },
		{ text = "Spawn Bags", callback_func = function() run_events("start_4_throw_bags") run_events("1BagTraded") end },
	},
	["framing_frame_3"] = {
		{ text = "Disable Lasers", callback_func = function() run_events("deactivateLasers") end },
		{ text = "Open Vault", callback_func = function() run_events("test_open_vault") end },
		{ text = "Escape", callback_func = function() run_events("startEscape") run_events("activateZipLine") run_events("complete_11") run_events("complete_13") end },
		{ text = "Spawn Coke", callback_func = function() run_events("throwCoke") end },
		{ text = "Find Items", callback_func = function() run_events("all5Items") end },
	},
	["gallery"] = {
		{ text = "Remove Laser", callback_func = function() run_events("randLaser") end },
		{ text = "Open Bars And Barriers", callback_func = function() run_events("openDoors") run_events("barsOpen") end },
		{ text = "Assets", callback_func = function() run_events("pp_framing_frame_1_keycard001") run_events("pp_framing_frame_1_entry_point001") run_events("pp_framing_frame_1_entry_point002") run_events("pp_framing_frame_1_entry_point003") run_events("pp_framing_frame_1_spycam001") run_events("pp_framing_frame_1_spycam002") run_events("pp_framing_frame_1_spycam003") run_events("pp_framing_frame_1_spycam004") run_events("pp_framing_frame_1_spycam005") run_events("pp_framing_frame_1_spycam006") run_events("pp_framing_frame_1_truck001") run_events("pp_framing_frame_1_camera_access001") end },
		{ text = "Spawn Paintings", callback_func = function() run_events("randomPaintings") run_events("randomPaintings") run_events("randomPaintings") run_events("randomPaintings") run_events("randomPaintings") run_events("randomPaintings") run_events("randomPaintings") run_events("randomPaintings") end },
		{ text = "Spawn Guard", callback_func = function() run_events("cloaker_spawn004") end },
	},
	["skm_red2"] = {
		{ text = "Trade Hostage", callback_func = function() run_events("trigger_anim_complete") end },
		{ text = "Win", callback_func = function() run_events("win_link") end },
		{ text = "assault start", callback_func = function() run_events("assault_start") end },
		{ text = "assault end", callback_func = function() run_events("assault_end") end },
	},
	["skm_arena"] = {
		{ text = "Trade Hostage", callback_func = function() run_events("trigger_anim_complete") end },
		{ text = "Win", callback_func = function() run_events("win_link") end },
		{ text = "assault start", callback_func = function() run_events("assault_start") end },
		{ text = "assault end", callback_func = function() run_events("assault_end") end },
	},
	["skm_mus"] = {
		{ text = "Trade Hostage", callback_func = function() run_events("trigger_anim_complete") end },
		{ text = "Win", callback_func = function() run_events("win_link") end },
		{ text = "assault start", callback_func = function() run_events("assault_start") end },
		{ text = "assault end", callback_func = function() run_events("assault_end") end },
	},
	["crojob2"] = {
		{ text = "Start Methlab", callback_func = function() run_events("show_interactions") end },
		{ text = "spawn meth", callback_func = function() run_events("SHOW_ENDPRODUCT") end },
	},
	["kenaz"] = {
		{ text = "Open Vault", callback_func = function() run_events(100843) end },
		{ text = "Disable Vault Laser", callback_func = function() run_events(144379) end },
	},
	["welcome_to_the_jungle_2"] = {
		{ text = "All Engines Correct", callback_func = function() run_events("engine001") run_events("engine002") run_events("engine003") run_events("engine004") run_events("engine005") run_events("engine006") run_events("engine007") run_events("engine008") run_events("engine009") run_events("engine010") run_events("engine011") run_events("engine012") end },
		{ text = "Enable Door Pad", callback_func = function() run_events("enableVaultPad") end },
	},
	["vit"] = {
	{ text = "Cut Yellow", callback_func = function() run_events("yellow_wire_cut") run_events("yellow_cable_cut") end },
	{ text = "Cut blue", callback_func = function() run_events("blue_wire_cut") run_events("blue_cable_cut") end },
	{ text = "Cut red", callback_func = function() run_events("red_wire_cut") run_events("red_cable_cut") end },
	{ text = "Cut Green", callback_func = function() run_events("green_wire_cut") run_events("green_cable_cut") end },
	{ text = "Get Safe Code", callback_func = function() run_events("disable_objective_clues") run_events("disable_objective_USB") run_events("add_usb_stick") run_events("disable_usb_interactions") end },
	{ text = "Spawn turrets", callback_func = function() run_events("spawn_peoc_turrets") run_events("start_turret_humvee") end },
	{ text = "Open Vault", callback_func = function() run_events("player_nearby_vault") run_events("hack_1_done") run_events("hack_2_done") run_events("hack_3_done") run_events("open_the_vault") end },
	{ text = "Enable painting", callback_func = function() run_events("seq_painting_glow") run_events("enable_painting_interaction") run_events("seq_enable_c4_interactions") run_events("give_player_c4") end },
	{ text = "Enable elevator", callback_func = function() run_events("area_all_player_inside_elevator") end },
	{ text = "Open Puzzle Vault", callback_func = function() run_events("solved_ze_puzzle") end },
	},
	["bex"] = {
	{ text = "Cut Yellow", callback_func = function() run_events("yellow_wire_cut") run_events("yellow_cable_cut") end },
	{ text = "Cut blue", callback_func = function() run_events("blue_wire_cut") run_events("blue_cable_cut") end },
	{ text = "Cut red", callback_func = function() run_events("red_wire_cut") run_events("red_cable_cut") end },
	{ text = "Cut Green", callback_func = function() run_events("green_wire_cut") run_events("green_cable_cut") end },
	{ text = "Open Vault", callback_func = function() run_events("open_vault") end },
	{ text = "Lasers Off", callback_func = function() run_events("laser_off") end },
	},
	["firestarter_2"] = {
	{ text = "Open Safe", callback_func = function() run_events("chanceOf1") end },
	},
	["mex_cooking"] = {
	{ text = "Spawn meth table", callback_func = function() run_events("spawn_meth") end },
	{ text = "Secure Area", callback_func = function() for i=1,25 do run_events(102302) end end },
	},
	["mex"] = {
	{ text = "phase 2", callback_func = function() run_events("link_all_players_in_area") end },
	{ text = "present", callback_func = function() run_events("randomize_xmas_locatioin") end },
	},
	["arm_for"] = {
	{ text = "Open Vault 1 from boat side", callback_func = function() run_events("open_vault_1_door") end },
	{ text = "Open Vault 2", callback_func = function() run_events("open_vault_2_door") end },
	{ text = "Open Vault 3", callback_func = function() run_events("open_vault_3_door") end },
	{ text = "Open Vault 4", callback_func = function() run_events("open_vault_4_door") end },
	{ text = "Open Vault 5", callback_func = function() run_events("open_vault_5_door") end },
	{ text = "Open Vault 6", callback_func = function() run_events("open_vault_6_door") end },
	},
	["fex"] = {
	{ text = "Open Mayan Door", callback_func = function() run_events(140488) end },
	{ text = "Open Bookshelf Door", callback_func = function() run_events(157329) end },
	{ text = "Open Bookshelf", callback_func = function() run_events(150595) end },
	{ text = "Open Statue", callback_func = function() run_events(135437) end },
	{ text = "Open Keycard Door", callback_func = function() run_events(134966) end },
	{ text = "Open Winecellar", callback_func = function() run_events(134119) run_events(103507) run_events(135699) end },
	{ text = "Give random guard keycard", callback_func = function() run_events(144705) end },
	},
	["friend"] = {
	{ text = "Activate Turrets", callback_func = function() run_events("activate_turret001") run_events("activate_turret002") run_events("activate_turret003") run_events("activate_turret004") run_events("activate_turret005") end },
	},
	["pal"] = {
	{ text = "Spawn Money", callback_func = function() run_events("done_print_money") end },
	{ text = "Finish Safe Water", callback_func = function() run_events(101229) end }
	},
}
--[[
for _, data in pairs(managers.mission._scripts) do
		for _, element in pairs(data:elements()) do
			if element._id == 104051 then
				for _, elem in pairs(element._values.on_executed) do
					element:trigger_mission_element(elem.id)
				end
			end
		end
	end
--]]
function event_menu()
	local dialog_data = {    
		title = "Event Menu",
		text = "Select Option",
		button_list = {}
	}

	local lvl_id = managers.job:current_level_id()
	if events_table[lvl_id] then
		for _, event in pairs(events_table[lvl_id]) do
			if events_table[lvl_id] then
				table.insert(dialog_data.button_list, event)
			end
		end
	end
	
	if #dialog_data.button_list == 0 then
		for _, data in pairs(managers.mission._scripts) do
			for _, element in pairs(data:elements()) do
				if element._editor_name then
					table.insert(dialog_data.button_list, {
						text = element._editor_name,
						callback_func = function() run_events(element._editor_name) end,
					})
				end
			end
		end
		table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {
			text = "Draw Events ON/OFF",
			callback_func = function() event_turn_off_draw() end,
		})
	else
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {
			text = "Draw Events ON/OFF",
			callback_func = function() event_turn_off_draw() end,
		})
		table.insert(dialog_data.button_list, {
			text = "Event List",
			callback_func = function() event_menu_list() end,
		})
	end
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, { text = managers.localization:text("dialog_cancel"), focus_callback_func = function () end, cancel_button = true }) 
	managers.system_menu:show_buttons(dialog_data)
end
event_menu()