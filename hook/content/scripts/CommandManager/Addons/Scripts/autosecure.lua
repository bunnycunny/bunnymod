if rawget(_G, "CommandManager") then
	if CommandManager.modules["Globals"] then
		CommandManager.level = Global.level_data and Global.level_data.level_id

		function CommandManager:get_pos()
			if self.level and self.config.autosecure.level_list[self.level] then
				local data = self.config.autosecure.level_list[self.level].position
				x, z, y = data[1],  data[2], data[3]
				return x, z, y
			end
		end

		function CommandManager:autosecure()
			local x, z, y = self:get_pos()
			local pos = Vector3(x, z, y)
			if (pos == Vector3(nil, nil, nil)) then
				BetterDelayedCalls:Remove("auto_secure")
				global_autosecure_toggle = not global_autosecure_toggle
				managers.chat:feed_system_message(ChatManager.GAME, string.format("This heist doesn't support auto secure yet!"))
				return
			end
			self:Drop_Carry(pos)
			if self.config.autosecure.level_list[self.level].interaction then
				self:interact(self.config.autosecure.level_list[self.level].interaction)
			end
			self:Drop_Carry(pos)
		end

		BetterDelayedCalls:Add("auto_secure", 0.5, function()
			if not CommandManager:is_playing() then return end
			CommandManager:autosecure()
		end, true)

		CommandManager:Module("AutoSecure")
	end
end