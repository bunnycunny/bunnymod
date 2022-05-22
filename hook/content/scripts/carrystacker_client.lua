if rawget(_G, "CarryScript") then -- this allows us to reload the script in case we made some changes in-game.
	rawset(_G, "CarryScript", nil)
end

if not rawget(_G, "CarryScript") then
	rawset(_G, "CarryScript", {
		BagList = {},
		menu_mode = true,
		carrystack_lastpress = 0
	})
	
	for _,unit in pairs(managers.interaction._interactive_units) do
		local interaction = (alive(unit) and (unit['interaction'] ~= nil)) and unit:interaction()
		local carry = (alive(unit) and (unit['interaction'] ~= nil)) and unit:carry_data()
		if interaction and carry then
			table.insert(CarryScript.BagList, carry:carry_id())
		end
	end
	table.sort(CarryScript.BagList)
	
	function CarryScript:secure_carry_toggle()
		local count_table = managers.player:is_carrying() and 1 or 0
		for i = 1, count_table do
			dofile("mods/hook/content/scripts/securecarrybags.lua")
		end
		managers.player:clear_carry()
	end
	
	function CarryScript:DropCarry()
		local rotation = managers.player:player_unit():camera():rotation()
		local position = managers.player:player_unit():camera():position()
		local forward =  managers.player:player_unit():camera():forward()
		local throw_force = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0)
		local carry_data = managers.player:get_my_carry_data()
		if carry_data then
			managers.player:clear_carry()
			if Network:is_server() then
				managers.player:server_drop_carry(carry_data.carry_id, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, throw_force, zipline_unit, managers.network:session():local_peer())
			else
				if carry_data.carry_id then
					local peer = managers.network:session():peer(1)
					peer._carry_id = carry_data.carry_id
					managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, throw_force, nil, peer)
				end
			end
		end
	end

	function CarryScript:InteractBySpecificBag(id)
		if not alive(managers.player:player_unit()) then
			return
		end
		
		if global_secure_carry then
			self:secure_carry()
		end
		
		self:DropCarry()
		
		for _,unit in pairs(managers.interaction._interactive_units) do
			local interaction = (alive(unit) and (unit['interaction'] ~= nil)) and unit:interaction()
			local carry = (alive(unit) and (unit['interaction'] ~= nil)) and unit:carry_data()
			if interaction and carry then
				if carry:carry_id() == id then
					interaction:interact(managers.player:player_unit())
					break
				end
			end
		end
		
		if global_secure_carry then
			self:secure_carry()
		end
	end
	
	function CarryScript:menu(BagList)
		local dialog_data = {    
			title = "Carrystacker Menu",
			text = "Select Option",
			button_list = {}
		}
		
		table.insert(dialog_data.button_list, {})
		for _, carry_id in pairs(BagList) do
			local carry_data = tweak_data.carry[carry_id]
			local type_text = managers.localization:text(carry_data.name_id)
			table.insert(dialog_data.button_list, { 
				text = type_text, 
				callback_func = function()
					self:InteractBySpecificBag(carry_id)
				end
			})
		end
		
		if not dialog_data.button_list.text == type_text then 
			table.insert(dialog_data.button_list, {text = "No bags on the map",}) 
		end
		
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {
			text = "Drop All - ON", 
			callback_func = function()
				for _, carry_id in pairs(BagList) do
					CarryScript:InteractBySpecificBag(carry_id)
				end
				managers.mission._fading_debug_output:script().log(string.format("Drop All - ACTIVATED"),  Color.green)
			end
		})
		table.insert(dialog_data.button_list, {
			text = "Drop One By One - ON", 
			callback_func = function()
				CarryScript.menu_mode = not CarryScript.menu_mode
				CarryScript:InteractBySpecificBag(CarryScript.BagList[1])
				managers.mission._fading_debug_output:script().log(string.format("One By One - ACTIVATED"),  Color.green)
				managers.chat:feed_system_message(ChatManager.GAME, "Carrystacker - Double Tap Fast To Enter Menu")
			end
		})
		table.insert(dialog_data.button_list, {
			text = "Secure Carried - ON", 
			callback_func = function()
				CarryScript:secure_carry_toggle()
			end
		})
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {
			text = "Carrystacker (Host)", 
			callback_func = function()
				dofile("mods/hook/content/scripts/carrystacker.lua")
			end
		})
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {
			text = managers.localization:text("dialog_cancel"),
			focus_callback_func = function() end, 
			cancel_button = true 
		})
		managers.system_menu:show_buttons(dialog_data)
	end
	
	function CarryScript:_toggle()
		local unit = managers.player:player_unit()
		if alive(unit) then
			if CarryScript.menu_mode then
				CarryScript:menu(CarryScript.BagList)
			else
				if (Application:time() - self.carrystack_lastpress) < 0.2 then
					CarryScript.menu_mode = not CarryScript.menu_mode
					CarryScript:menu(CarryScript.BagList)
					managers.mission._fading_debug_output:script().log(string.format("One By One - DEACTIVATED"),  Color.red)
				else
					CarryScript:InteractBySpecificBag(CarryScript.BagList[1])
				end
			end
			self.carrystack_lastpress = Application:time()
		end
	end
	CarryScript:_toggle()
else
	CarryScript:_toggle()
end

local orig = ObjectInteractionManager.update
function ObjectInteractionManager:update(t, dt)
	orig(self, t, dt)
	if #CarryScript.BagList ~= self._interactive_count then
		CarryScript.BagList = {}
		for _, unit in pairs(self._interactive_units) do
			local interaction = (alive(unit) and (unit['interaction'] ~= nil)) and unit:interaction()
			local carry = (alive(unit) and (unit['interaction'] ~= nil)) and unit:carry_data()
			if interaction and carry then
				table.insert( CarryScript.BagList, carry:carry_id() )
			end
		end
 
		table.sort(CarryScript.BagList)
	end
end