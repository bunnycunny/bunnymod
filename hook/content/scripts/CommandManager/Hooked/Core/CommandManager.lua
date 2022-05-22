if rawget(_G, "CommandManager") then
	if (not CommandManager:in_chat()) then
		rawset(_G, "CommandManager", nil)
	end
end

if (not rawget(_G, "CommandManager")) then
	rawset(_G, "CommandManager", {
		aliases	= {},
		config	= {},
		config2 = {},
		history	= {},
		path	= "mods/hook/content/scripts/CommandManager/%s",
		path2	= "mods/hookloc/%s",
		path3	= "mods/hook/content/scripts/loc/%s",
		command_prefixes = { "/", "\\", "!" }
	})

	function CommandManager:LoadConfig()
		if JSON then
			local file = JSON:jsonFile(string.format(self.path2, "config.json"))
			local data = JSON:decode(file)
			for _, v in pairs(data) do
				if type(v) == "table" then
					self.config = v
				end
			end
		end
	end
	
	function CommandManager:Save()
		if JSON then
			local file = io.open(string.format(self.path2, "config.json"), "w")
			local data = {
				["config"] = self.config
			}

			if file then
				local contents = JSON:encode_pretty(data)
				file:write( contents )
				io.close( file )
			else
				return
			end
		end 
	end
	
	function CommandManager:load_config()
		if JSON then
			local file = JSON:jsonFile(string.format(self.path2, "mod list.json"))
			local data = JSON:decode(file)
			for _, v in pairs(data) do
				if type(v) == "table" then
					self.config2 = v
				end
			end
		end
	end
	
	function CommandManager:save_config()
		if JSON then
			local file = io.open(string.format(self.path2, "mod list.json"), "w")
			local data = {
				["config"] = self.config2
			}

			if file then
				local contents = JSON:encode_pretty(data)
				file:write( contents )
				io.close( file )
			else
				return
			end
		end 
	end

	function CommandManager:prefixes(str)
		for _, prefix in pairs(self.command_prefixes) do
			if string.sub(str, 1, 1) == prefix then
				return true
			end
		end
	end

	function CommandManager:init()
		--* Load Utils *--
		dofile(string.format(self.path, "Hooked/Core/requirements/JSON.lua"))
		dofile(string.format(self.path, "Hooked/Core/requirements/Utils.lua"))
		--* Load Config *--
		self:LoadConfig()
		self:load_config()
		--* Setup Commands *--
		dofile(string.format(self.path, "Hooked/Core/commands.lua"))
		dofile(string.format(self.path, "Addons/Custom.lua"))
	end

	CommandManager:init()
end
