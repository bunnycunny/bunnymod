if not rawget(_G, "xray_manager") then
	rawset(_G, "xray_manager", {
		file_name = "mods/hook/content/scripts/loc/waypoints_config1xray.lua",
		Color_waypoint = Color("FFFFFF"), --white
		waypoint_items = {},
		replace_items = {
			['pickup_keycard'] = "equipment_bank_manager_key"
		},
		outline_behind_walls = true,
		ColorList = {	--color contours
			default								= 'DD0000', -- LIGHT BLUE 336699/00E1FA
			friendly							= '1e6cff', -- dark blue default 1e6cff LIGHT GREEN 00E100/39FF14
			camera								= 'E0A3C2', -- DARK RED FF0000
			hostage								= '00E1FA', -- DARK GREEN 009933
			pickup								= 'E1E100', -- DARK BLUE 003399/00C8FA/0096FF
			civilian							= '0096FF', -- WHITE FFFFFF
			civilian_female						= '0096FF', -- LIGHT PINK E0A3C2
			spooc								= 'FF64FF', -- NAVY BLUE 0000FF
			taser								= 'E100E1', -- PINK FF66FF/FF64FF
			shield								= 'E100E1', -- RED CC0000/DD0000
			tank								= 'E100E1', -- YELLOW FFFF00
			tank_mini							= 'E100E1', -- Minigundozer
			tank_medic							= 'E100E1', -- Medic Dozer
			tank_hw								= 'E100E1', -- Headless Titandozers
			sniper								= 'FF64FF', -- GOLD FF9933/E1E100/FFDF00
			gangster							= '39FF14', -- PURPLE 660066/E100E1
			security							= '39FF14', -- DARK ORCHID 9932CC
			medic								= 'E100E1', -- SHOCKING PINK E00AB9
			gensec								= '39FF14', -- Gensec guards (Transport DLC, GO Bank)
			swat								= 'DD0000', -- Blue SWAT, low diff
			heavy_swat							= 'DD0000', -- Yellow SWAT
			fbi									= 'DD0000', -- Can refer to field, vet, or office agents
			fbi_swat							= 'DD0000', -- Common Heavy Response Units seen on many diffs
			fbi_heavy_swat						= 'DD0000', -- brown armored FBI
			cop_female							= '39FF14',
			city_swat							= '39FF14', -- GenSec Elites or Murkywaters
			mobster_boss						= 'E1E100', -- The Commissar
			mobster								= '39FF14', -- Commissars goons
			hector_boss							= 'E1E100', -- miami
			hector_boss_no_armor				= 'E1E100', -- miami
			biker_boss							= 'E1E100', -- female MC on Day 2 Biker
			chavez_boss							= 'E1E100', -- panic room
			biker								= '39FF14', -- Bikers
			bolivians							= '39FF14', -- Bolivians
			phalanx_vip							= 'E1E100', -- Captain Winters
			phalanx_minion						= 'FFFFFF', -- Wintergoons
			shadow_spooc						= 'E1E100', -- wh secret
			drug_lord_boss						= 'E1E100',	-- scarface m
			drug_lord_boss_stealth				= 'E1E100',	-- scarface m
			drunk_pilot							= 'E1E100',	-- stealing xmas santa
			spa_vip								= 'FFFFFF',	--?
			spa_vip_hurt						= 'FFFFFF', --?
			captain								= 'FFFFFF',	--?
			civilian_mariachi					= 'FFFFFF',	--san martin bank
			mute_security_undominatable			= 'E1E100',	--garret breaking feds e.g
			security_undominatable				= 'E1E100',	--?
			escort								= 'E1E100',	--?
			escort_criminal						= 'E1E100',	--?
			escort_undercover					= 'E1E100',	--undercover
			
			--AIs (updates on state change)
			ecp_male							= '009933',	--ethan
			chico								= '009933',	--scarface
			max									= '009933',	--sangres
			joy									= '009933',	--joy
			myh									= '009933',	--duke
			ecp_female							= '009933',	--hila
			russian								= '009933',	--dallas
			german								= '009933',	--wolf
			spanish								= '009933',	--chains
			american							= '009933',	--houston
			jowi								= '009933',	--wick
			old_hoxton							= '009933',	--hoxton
			female_1							= '009933', --clover
			dragan								= '009933',	--dragan
			jacket								= '009933',	--jacket
			bonnie								= '009933',	--bonnie
			sokol								= '009933',	--sokol
			dragon								= '009933',	--jiro
			bodhi								= '009933',	--bodhi
			jimmy								= '009933',	--jimmy
			sydney								= '009933',	--sydney
			wild								= '009933'	--rust
		},
		update_delay = 0,
		multi = managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1) or 2,
		id_level = managers.job:current_level_id()
	})
	
	function xray_manager:is_host()
		if Network:is_server() then
			return true
		else
			return false
		end
	end
	
	function xray_manager:is_hostage(unit, converted_only)
		if alive(unit) then
			local brain = unit.brain and unit.brain(unit)
			if brain then
				if not converted_only then
					if brain.is_hostage and brain.is_hostage(brain) then
						return true
					end
				
					local anim_data = unit.anim_data and unit.anim_data(unit)
					if anim_data then
						if anim_data.tied or anim_data.hands_tied then
							return true
						end
					end
				end
				
				if Network:is_server() and brain._logic_data then
					if (brain._logic_data.is_tied or brain._logic_data.is_converted and unit.is_converted) then
						return true
					end
				else
					if brain:surrendered() then
						return true
					end
				end
			end
		end
		return false
	end

	local function can_interact()
		return true
	end
	
	function xray_manager:add_waypoint(unit)
		self.tweak = unit:interaction().tweak_data
		self.icon = self.replace_items[self.tweak] or tweak_data.interaction[self.tweak].icon
		if not self.icon then
			self.interaction_tweak = tweak_data.interaction[self.tweak]
			self.special_equipment = self.interaction_tweak.special_equipment or self.interaction_tweak.special_equipment_block
			self.special_tweak = tweak_data.equipments.specials[self.special_equipment]
			self.icon = self.special_tweak and self.special_tweak.icon
		end	
		
		if table.contains(xray_manager.waypoint_items, self.tweak) then
			managers.hud:add_waypoint(tostring( unit:key() ), { icon = self.icon or 'wp_standard', distance = true, position = unit:position(), no_sync = true, present_timer = 0, state = "present", radius = 500, color = self.Color_waypoint, blend_mode = "add" })
		end
	end
	
	function xray_manager:RefreshItemWaypoints()
		-- update COPS and civs with keycard without update all because annoying
		if self:is_host() then
			self.player_pos = Vector3(0,0,0)
			for u_key, u_data in pairs(managers.enemy:all_enemies()) do
				self.unit_pos = u_data.unit:movement():m_head_pos()
				if u_data.unit.contour and alive(u_data.unit) and u_data.unit:character_damage():pickup() and u_data.unit:character_damage():pickup() ~= "ammo" then
					self.ray = World:raycast("ray", self.player_pos, self.unit_pos, "slot_mask", managers.slot:get_mask( "AI_visibility" ), "ray_type", "ai_vision", "ignore_unit", { u_data.unit } )
					if (self.ray and self.ray.unit) then
						self.cHealth = u_data.unit:character_damage() and u_data.unit:character_damage()._health
						if self.cHealth then
							self.full = u_data.unit:character_damage()._HEALTH_INIT
							if self.full and (self.cHealth > 0.1) then 
								managers.hud:add_waypoint('hudz_cop_'..tostring(self.unit_pos), { icon = 'equipment_bank_manager_key', distance = bShowDistance, position = self.unit_pos, no_sync = true, present_timer = 0, state = "present", radius = 10000, color = self.Color_waypoint, blend_mode = "add" })
							end
						end
					end
				end
			end
			
			for u_key, u_data in pairs(managers.enemy:all_civilians()) do
				self.unit_pos = u_data.unit:movement():m_head_pos()
				if u_data.unit.contour and alive(u_data.unit) and u_data.unit:character_damage():pickup() and u_data.unit:character_damage():pickup() ~= "ammo" then
					self.ray = World:raycast("ray", self.player_pos, self.unit_pos, "slot_mask", managers.slot:get_mask( "AI_visibility" ), "ray_type", "ai_vision", "ignore_unit", { u_data.unit } )
					if (self.ray and self.ray.unit) then
						self.cHealth = u_data.unit:character_damage() and u_data.unit:character_damage()._health
						if self.cHealth then
							self.full = u_data.unit:character_damage()._HEALTH_INIT
							if self.full and (self.cHealth > 0.1) then 
								managers.hud:add_waypoint('hudz_cop_'..tostring(self.unit_pos), { icon = 'equipment_bank_manager_key', distance = bShowDistance, position = self.unit_pos, no_sync = true, present_timer = 0, state = "present", radius = 10000, color = self.Color_waypoint, blend_mode = "add" })
							end
						end
					end
				end
			end
		end
	end
	
	function xray_manager:toggle_waypoints_on()
		--Load file waypoints
		for line in io.lines(self.file_name) do
			table.insert(xray_manager.waypoint_items, line)
		end

		--add waypoints
		for _,unit in pairs(managers.interaction._interactive_units) do
			local interaction = (alive(unit) and (unit['interaction'] ~= nil)) and unit:interaction()
			if interaction and interaction._active then	
				interaction.can_interact = can_interact
				xray_manager:add_waypoint(unit)
				interaction.can_interact = nil
			end
		end

		-- show cops and civs with keycard
		self:RefreshItemWaypoints()
	end

	function xray_manager:getUnitColor(unit)
		if not (unit:contour() and alive(unit) and unit:base()) then 
			return 
		end
		
		xray_manager.unitType = unit:base()._tweak_table
		if unit:base().security_camera then self.unitType = 'camera' end
		if unit:base().is_converted then self.unitType = 'friendly' end
		if unit:base().is_hostage then self.unitType = 'hostage' end
		if unit:base().has_pickup then self.unitType = 'pickup' end
		
		if not (self.unitType) then 
			return
		end
		return Color(self.ColorList[self.unitType] and self.ColorList[self.unitType] or self.ColorList['default'])
	end
	
	function xray_manager:markMissionItems_on()
		self.outline_table_on = {
			"state_outline_enabled",
			"enable_outline",
			"state_contour_enabled"
		}
		for _,unit in pairs(managers.interaction._interactive_units) do
			local interaction = (alive(unit) and (unit['interaction'] ~= nil)) and unit:interaction()
			local elem = interaction and unit.damage and unit:damage() and unit:damage()._unit_element
			if elem then
				local elements = elem._sequence_elements or {}
				for id in pairs(elements) do
					if id and unit:damage():has_sequence(id) and table.contains(self.outline_table_on, id) then
						unit:damage():run_sequence_simple(id) 
						managers.network:session():send_to_peers_synched("run_mission_door_device_sequence", unit, id)
					end
				end
			end
		end
	end
	
	function xray_manager:markMissionItems_off()
		self.outline_table_off = {
			"state_outline_disabled",
			"disable_outline",
			"state_contour_disabled"
		}
		for _,unit in pairs(managers.interaction._interactive_units) do
			local interaction = (alive(unit) and (unit['interaction'] ~= nil)) and unit:interaction()
			local elem = interaction and unit.damage and unit:damage() and unit:damage()._unit_element
			if elem then
				local elements = elem._sequence_elements or {}
				for id in pairs(elements) do
					if id and unit:damage():has_sequence(id) and table.contains(self.outline_table_off, id) then
						unit:damage():run_sequence_simple(id) 
						managers.network:session():send_to_peers_synched("run_mission_door_device_sequence", unit, id)
					end
				end
			end
		end
	end

	function xray_manager:mark_converted()
		for u_key,u_data in pairs(managers.enemy:all_enemies()) do
			if alive(u_data.unit) and u_data.unit.contour and self.multi then
				if self:is_hostage(u_data.unit, true) then
					u_data.unit:contour():setData({is_converted = true})
					u_data.unit:contour():add("friendly", nil)
				end
			end
		end
	end
	
	function xray_manager:check_wall(unit)
		local player_unit = managers.player:player_unit()
		if self.outline_behind_walls then
			return true
		end
		if not alive(player_unit) or not alive(unit) then
			return
		end
		local from = player_unit:camera():position()
		local to = unit:movement():m_head_pos()
		local vis_ray = World:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("bullet_impact_targets"), "ignore_unit", {}, "thickness", 40, "thickness_mask", managers.slot:get_mask("world_geometry", "vehicles"))
		if vis_ray and vis_ray.unit and vis_ray.unit:key() == unit:key() then
			return true
		end
	end
	
	function xray_manager:markEnemies()
		if managers.groupai:state()._whisper_mode then
			self:markClear()
		end
		
		for _, unit in ipairs(SecurityCamera.cameras) do
			if alive(unit) and unit:contour() and unit:base() and not unit:base():destroyed() and self.multi and managers.groupai:state()._whisper_mode then
				if self.toggleSync then
					unit:contour():add( "mark_unit", self.toggleSync, self.multi )
				else
					unit:contour():add( "mark_unit", nil, self.multi )
				end
			end
		end

		for u_key,u_data in pairs(managers.enemy:all_civilians()) do
			if alive(u_data.unit) and u_data.unit.contour and self.multi and self:check_wall(u_data.unit) then
				if self:is_hostage(u_data.unit) then 
					u_data.unit:contour():setData({is_hostage = true}) 
				end
				if self:is_host() and u_data.unit:character_damage():pickup() then 
					u_data.unit:contour():setData({has_pickup = true}) 
				end
				if self.toggleSync then
					u_data.unit:contour():add("mark_enemy", self.toggleSync, self.multi)
				else
					u_data.unit:contour():add("mark_enemy", nil, self.multi)
				end
			end
		end

		for u_key,u_data in pairs(managers.enemy:all_enemies()) do
			if alive(u_data.unit) and u_data.unit.contour and self.multi and self:check_wall(u_data.unit) then
				if u_data.is_converted then
					u_data.unit:contour():setData({is_converted = true})
					if self.toggleSync then
						u_data.unit:contour():add("friendly", self.toggleSync)
					else
						u_data.unit:contour():add("friendly", nil)
					end
				else
					if self:is_hostage(u_data.unit) then
						u_data.unit:contour():setData({is_hostage = true}) 
					end
					if self:is_host() and u_data.unit:character_damage():pickup() and u_data.unit:character_damage():pickup() ~= "ammo" then
						u_data.unit:contour():setData({has_pickup = true})
					end
					if self.toggleSync then
						u_data.unit:contour():add("mark_enemy", self.toggleSync, self.multi)
					else
						u_data.unit:contour():add("mark_enemy", nil, self.multi)
					end
				end
			end
		end
	end
	
	-- Clear mark
	function xray_manager:markClear()
		for _, unit in ipairs(SecurityCamera.cameras) do 
			if unit and unit:contour() then
				unit:contour():removeAll() 
			end
		end
		
		for u_key,u_data in pairs(managers.enemy:all_civilians()) do
			if u_data.unit and u_data.unit.contour then 
				u_data.unit:contour():removeAll()
			end
		end
		
		for u_key,u_data in pairs(managers.enemy:all_enemies()) do
			if u_data.unit and u_data.unit.contour then 
				u_data.unit:contour():removeAll()
			end
		end
	end
	
	--Clear waypoints
	function xray_manager:markClearWaypoint()
		for _,unit in pairs(managers.interaction._interactive_units) do
			local interaction = (alive(unit) and (unit['interaction'] ~= nil)) and unit:interaction()
			if interaction and interaction._active then
				interaction.can_interact = can_interact
				self:clear_waypoint(unit)
				interaction.can_interact = nil
			end
		end
	end

	function xray_manager:clear_waypoint(obj)		
		-- remove other waypoint
		managers.hud:remove_waypoint(tostring(obj:key()))
		
		-- remove civ and cop keycard waypoint
		self:clear_keycard_wp()	

		DelayedCalls:Add( "refresh_kc_xray", 0.3, function()
			if alive(managers.player:player_unit()) then
				self:RefreshItemWaypoints()
			end
		end)
	end
	
	function xray_manager:clear_keycard_wp()
		if self:is_host() then
			for id,_ in pairs( clone( managers.hud._hud.waypoints ) ) do
				id = tostring(id)
				if id:sub(1,5)=='hudz_' then
					managers.hud:remove_waypoint(id) 
				end
			end
		end
	end
	
	xray_manager._remove_unit = ObjectInteractionManager.remove_unit
	xray_manager._add_unit = ObjectInteractionManager.add_unit
	xray_manager._nhUpdateColor = ContourExt._upd_color
	xray_manager._copDamageDie = CopDamage.die
	xray_manager._huskDamageDie = HuskCopDamage.die
	xray_manager._cameraDestroyed = ElementSecurityCamera.on_destroyed
	
	--updates waypoints
	function ObjectInteractionManager.remove_unit(self, unit)
		local interaction = (alive(unit) and (unit['interaction'] ~= nil)) and unit:interaction()
		if interaction and interaction.tweak_data ~= "corpse_dispose" then
			interaction.can_interact = can_interact
			xray_manager:clear_waypoint(unit)
			interaction.can_interact = nil
		end
		return xray_manager._remove_unit(self, unit)
	end
	
	function ObjectInteractionManager.add_unit(self, unit)
		local interaction = (alive(unit) and (unit['interaction'] ~= nil)) and unit:interaction()
		if interaction and interaction.tweak_data ~= "corpse_dispose" then
			interaction.can_interact = can_interact
			xray_manager:clear_waypoint(unit)
			xray_manager:add_waypoint(unit)
			interaction.can_interact = nil
		end
		return xray_manager._add_unit(self, unit)
	end
	
	--update contour
	function ContourExt:_upd_color()
		if xray_manager.toggle then
			if self._unit and self._unit:name() ~= Idstring("units/pickups/ammo/ammo_pickup") then
				local color = xray_manager:getUnitColor(self._unit)
				if color then
					self._materials = self._materials or self._unit:get_objects_by_type(Idstring("material"))
					for _, material in ipairs(self._materials) do
						material:set_variable(Idstring( "contour_color" ), color)
					end
					return
				end
			end
		end
		xray_manager._nhUpdateColor(self)
	end

	--custom func
	function ContourExt:removeAll(sync)
		if not self._contour_list or not type(self._contour_list) == 'table' then 
			return 
		end
		for id, setup in ipairs(self._contour_list) do 
			self:remove(setup.type, sync) 
		end
	end

	--custom func
	function ContourExt:setData(data)
		if not data or not type(data) == 'table' then 
			return 
		end
		for k, v in pairs(data) do 
			self._unit:base()[k] = v 
		end
	end
	
	function CopDamage.die(self, variant)
		if xray_manager.toggle and self._unit:contour() then 
			self._unit:contour():removeAll() 
		end
		xray_manager._copDamageDie(self, variant)
	end
	
	function HuskCopDamage.die(self, variant)
		if xray_manager.toggle and self._unit:contour() then 
			self._unit:contour():removeAll() 
		end
		xray_manager._huskDamageDie(self, variant)
	end

	function ElementSecurityCamera.on_destroyed(self)
		local camera_unit = self:_fetch_unit_by_unit_id(self._values.camera_u_id)
		if xray_manager.toggle and camera_unit:contour() then
			camera_unit:contour():removeAll() 
		end
		xray_manager._cameraDestroyed(self)
	end
	
	if GameSetup then
		local orig_func_update = GameSetup.update
		function GameSetup.update(self, t, dt)
			orig_func_update(self, t, dt)
			if xray_manager.toggle then
				xray_manager.update_delay = xray_manager.update_delay + dt
				if (xray_manager.outline_behind_walls and xray_manager.update_delay >= 3 or xray_manager.update_delay >= 0.7) and Utils:IsInHeist() and Utils:IsInGameState() then
					xray_manager.update_delay = 0
					xray_manager:markEnemies() --update contour every 3 sec
				end
			end
		end
	end
	
	function xray_manager:markToggle_on(toggleSync)
		if toggleSync then
			self.toggleSync = true
		end
		self:markEnemies()
	end
	
	function xray_manager:markToggle_off(toggleSync)
		if not toggleSync then
			self.toggleSync = false
		end
		self:markClear()
	end
	
	function xray_manager:_toggle()
		if not Utils:IsInHeist() or not Utils:IsInGameState() then
			return
		end

		self.toggle = self.toggle or false
		if not self.toggle then
			self:markToggle_on()
			self:toggle_waypoints_on()
			self:markMissionItems_on()
			managers.mission._fading_debug_output:script().log('Xray - ACTIVATED', Color.green)
		else
			if xray_share_manager and xray_share_manager.toggle then
				xray_share_manager.toggle = not xray_share_manager.toggle
			end
			self:markToggle_off()
			self:markClearWaypoint()
			DelayedCalls:Add( "remove_kc_xray", 0.35, function()
				if alive(managers.player:player_unit()) then
					self:clear_keycard_wp()
				end
			end)
			self:markMissionItems_off()
			self:mark_converted()
			managers.mission._fading_debug_output:script().log('Xray - DEACTIVATED',  Color.red)
		end
		self.toggle = not self.toggle
	end
	xray_manager:_toggle()
else
	xray_manager:_toggle()
end