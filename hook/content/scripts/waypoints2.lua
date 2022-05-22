if not rawget(_G, "waypoint_bags") then
	rawset(_G, "waypoint_bags", {})

	waypoint_bags.waypoint_items = {}
	waypoint_bags.file_name = "mods/hook/content/scripts/loc/waypoints_config3bags.lua"
	waypoint_bags.replace_items = {['pickup_keycard'] = "equipment_bank_manager_key",}
	
	function waypoint_bags:in_table(table, value)
		if type(table) == 'table' then
			for i,x in pairs(table) do
				if x == value then
					return true
				end
			end
		end
		return false
	end

	function waypoint_bags:file_io_lines(file)
		return io.lines(file)
	end

	function waypoint_bags.can_interact()
		return true
	end

	function waypoint_bags:add_waypoint(unit)
		self.tweak = unit:interaction().tweak_data
		self.icon = self.replace_items[self.tweak] or tweak_data.interaction[self.tweak].icon
		if not self.icon then
			self.interaction_tweak = tweak_data.interaction[self.tweak]
			self.special_equipment = self.interaction_tweak.special_equipment or self.interaction_tweak.special_equipment_block
			self.special_tweak = tweak_data.equipments.specials[self.special_equipment]
			self.icon = self.special_tweak and self.special_tweak.icon
		end	

		if self:in_table(waypoint_bags.waypoint_items, self.tweak) then
			managers.hud:add_waypoint(tostring(unit:key()), {icon = self.icon or 'wp_standard', distance = true, position = unit:position(), no_sync = true, present_timer = 0, state = "present", radius = 500, blend_mode = "add"})
		end
	end

	function waypoint_bags:add_waypoints()
		for line in self:file_io_lines(self.file_name) do
			table.insert(waypoint_bags.waypoint_items, line)
		end

		for _, unit in pairs( managers.interaction._interactive_units ) do
			self.interaction = unit:interaction()
			if self.interaction and self.interaction._active then
				if not type(unit) == 'string' then
					return
				end
				
				if not alive(unit) then 
					return 
				end
				
				self.interaction.can_interact = self.can_interact
				self:add_waypoint(unit)
				self.interaction.can_interact = nil
			end
		end
	end
	
	waypoint_bags._add_unit = ObjectInteractionManager.add_unit
	function ObjectInteractionManager:add_unit(obj)
		waypoint_bags.result_add = waypoint_bags._add_unit(self, obj)
		if obj:interaction().tweak_data ~= "corpse_dispose" then
			if not type(obj) == 'string' then
				return
			end
			
			if not alive(obj) then 
				return 
			end
			
			waypoint_bags.interaction = obj:interaction()
			waypoint_bags.interaction.can_interact = waypoint_bags.can_interact
			waypoint_bags:add_waypoint(obj)
			waypoint_bags.interaction.can_interact = nil
		end
		return waypoint_bags.result_add
	end
	
	function waypoint_bags:clear_waypoint(obj)
		managers.hud:remove_waypoint(tostring(obj:key()))
	end
	
	function waypoint_bags:clear_waypoints()
		for _, unit in pairs( managers.interaction._interactive_units ) do
			self.interaction = unit:interaction()
			if self.interaction and self.interaction._active then
				if not type(unit) == 'string' then
					return
				end
				
				if not alive(unit) then 
					return 
				end
				
				self.interaction.can_interact = self.can_interact
				self:clear_waypoint(unit)
				self.interaction.can_interact = nil
			end
		end
	end
	
	waypoint_bags._remove_unit = ObjectInteractionManager.remove_unit
	function ObjectInteractionManager:remove_unit(obj)
		waypoint_bags.result_rem = waypoint_bags._remove_unit(self, obj)
		if obj:interaction().tweak_data ~= "corpse_dispose" then
			if not type(obj) == 'string' then
				return
			end
			
			if not alive(obj) then 
				return 
			end
			
			waypoint_bags.interaction = obj:interaction()
			waypoint_bags.interaction.can_interact = waypoint_bags.can_interact
			waypoint_bags:clear_waypoint(obj)
			waypoint_bags.interaction.can_interact = nil
		end
		return waypoint_bags.result_rem
	end

	function waypoint_bags:_toggle()
		self.toggle = self.toggle or false
		if not self.toggle then
			self:add_waypoints()
			managers.mission._fading_debug_output:script().log('Bag Waypoints - ACTIVATED', Color.green)
		else
			if waypoint_secrets.toggle then
				waypoint_secrets.toggle = not waypoint_secrets.toggle
			end
			self:clear_waypoints()
			managers.mission._fading_debug_output:script().log('Bag Waypoints - DEACTIVATED',  Color.red)
		end
		self.toggle = not self.toggle
	end
	waypoint_bags:_toggle()
else
	waypoint_bags:_toggle()
end