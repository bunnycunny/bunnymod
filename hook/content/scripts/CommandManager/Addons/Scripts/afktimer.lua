if not rawget(_G, "moreafk_timer") then
	rawset(_G, "moreafk_timer", {
		camera_mm = {},
		toggle = false
	})

	function moreafk_timer:dcall_start()
		self.toggle = false
		BetterDelayedCalls:Add("auto_afk_timer", CommandManager.config.afk.autoafktimer, function()
			if not CommandManager:in_endscreen() and not CommandManager:in_lobby() then
				dofile(CommandManager.config.afk.path.."Addons/afk.lua")
				managers.chat:_receive_message(1, "AFK", "You were automatically put into AFK for idling too long.", tweak_data.system_chat_color)
			end
			self.toggle = true
		end, false)
		
		BetterDelayedCalls:Add("auto_afk_timer_check", 1, function()
			self:check()
		end, true)
	end
	
	function moreafk_timer:dcall_stop()
		BetterDelayedCalls:Remove("auto_afk_timer")
		self.toggle = true
	end
	
	function moreafk_timer:check()
		table.insert(self.camera_mm, tostring(managers.player:player_unit():camera():rotation()))
		if not CommandManager.config.afk.autoafk then
			BetterDelayedCalls:Remove("auto_afk_timer")
			BetterDelayedCalls:Remove("auto_afk_timer_check")
		end
		
		if self.toggle then
			self:dcall_start()
		end
		
		if (self.camera_mm[1] ~= tostring(managers.player:player_unit():camera():rotation()))
		or not (alive(managers.player:player_unit()))
		or (global_afk_toggle) 
		or (CommandManager:in_chat()) 
		or (managers.player:player_unit():base():controller():get_any_input_pressed())
		or (managers.player:player_unit():base():controller():get_any_input_released()) 
		or (managers.player:player_unit():base():controller():get_any_input()) then
			self.camera_mm[1] = nil
			self:dcall_stop()
		end
	end
	
	function moreafk_timer:_toggle()
		self:dcall_start()
	end
	
	moreafk_timer:_toggle()
else
	moreafk_timer:_toggle()
end