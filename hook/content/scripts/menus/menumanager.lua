color_table = {
	["hover"] = {
		{ text = "Neongreen", callback_func = function() change_color_func({57, 255, 20}, "hover_color") end },
		{ text = "Lilac", callback_func = function() change_color_func({216, 145, 239}, "hover_color") end },
		{ text = "Sky Blue", callback_func = function() change_color_func({135, 206, 235}, "hover_color") end },
		{ text = "Royal Blue", callback_func = function() change_color_func({65, 105, 225}, "hover_color") end },
		{ text = "Coral", callback_func = function() change_color_func({255, 127, 80}, "hover_color") end },
		{ text = "Sandy Brown", callback_func = function() change_color_func({244, 164, 96}, "hover_color") end },
		{ text = "Wheat", callback_func = function() change_color_func({245, 222, 179}, "hover_color") end },
		{ text = "Silver", callback_func = function() change_color_func({192, 192, 192}, "hover_color") end },
		{ text = "Rosy Brown", callback_func = function() change_color_func({188, 143, 143}, "hover_color") end },
		{ text = "Orange", callback_func = function() change_color_func({255, 165, 0}, "hover_color") end },
		{ text = "Indigo", callback_func = function() change_color_func({75, 0, 130}, "hover_color") end },
		{ text = "Dark Green", callback_func = function() change_color_func({0, 100, 0}, "hover_color") end },
		{ text = "Fire Brick", callback_func = function() change_color_func({178, 34, 34}, "hover_color") end },
		{},
		{ text = "Default", callback_func = function() change_color_func({255, 77, 198, 255}, "hover_color") end },
	},
	["button"] = {
		{ text = "Neongreen", callback_func = function() change_color_func({57, 255, 20}, "button_color") end },
		{ text = "Lilac", callback_func = function() change_color_func({216, 145, 239}, "button_color") end },
		{ text = "Sky Blue", callback_func = function() change_color_func({135, 206, 235}, "button_color") end },
		{ text = "Royal Blue", callback_func = function() change_color_func({65, 105, 225}, "button_color") end },
		{ text = "Coral", callback_func = function() change_color_func({255, 127, 80}, "button_color") end },
		{ text = "Sandy Brown", callback_func = function() change_color_func({244, 164, 96}, "button_color") end },
		{ text = "Wheat", callback_func = function() change_color_func({245, 222, 179}, "button_color") end },
		{ text = "Silver", callback_func = function() change_color_func({192, 192, 192}, "button_color") end },
		{ text = "Rosy Brown", callback_func = function() change_color_func({188, 143, 143}, "button_color") end },
		{ text = "Orange", callback_func = function() change_color_func({255, 165, 0}, "button_color") end },
		{ text = "Indigo", callback_func = function() change_color_func({75, 0, 130}, "button_color") end },
		{ text = "Dark Green", callback_func = function() change_color_func({0, 100, 0}, "button_color") end },
		{ text = "Fire Brick", callback_func = function() change_color_func({178, 34, 34}, "button_color") end },
		{},
		{ text = "Default", callback_func = function() change_color_func({127, 0, 170, 255}, "button_color") end },
	}
}

function loadcolor()
	dofile("mods/hook/content/scripts/menumanagerload.lua")
end

function Save(color_type, menu_type)
	local r, g, b = tonumber(color_type[1]), tonumber(color_type[2]), tonumber(color_type[3])
	if (menu_type == "hover_color") then
		CommandManager.config.menucolors_hover.r = r
		CommandManager.config.menucolors_hover.g = g
		CommandManager.config.menucolors_hover.b = b
		if tonumber(color_type[4]) then
			CommandManager.config.menucolors_hover.t = tonumber(color_type[4])
		else
			CommandManager.config.menucolors_hover.t = nil
		end
		CommandManager:Save()
		managers.mission._fading_debug_output:script().log(string.format("Saved Hover Color: %s %s %s", r, g, b), Color.green)
	elseif (menu_type == "button_color") then
		CommandManager.config.menucolors_button.r = r
		CommandManager.config.menucolors_button.g = g
		CommandManager.config.menucolors_button.b = b
		if tonumber(color_type[4]) then
			CommandManager.config.menucolors_button.t = tonumber(color_type[4])
		else
			CommandManager.config.menucolors_button.t = nil
		end
		CommandManager:Save()
		managers.mission._fading_debug_output:script().log(string.format("Saved Button Color: %s %s %s", r, g, b), Color.green)
	end
end

function change_color_func(color_type, menu_type)
	local r, g, b = tonumber(color_type[1])/255, tonumber(color_type[2])/255, tonumber(color_type[3])/255
	local _color
	if tonumber(color_type[4]) then
		local t = tonumber(color_type[4])/255
		_color = Color(r, g, b, t)
	else
		_color = Color(r, g, b)
	end
	if menu_type == "hover_color" then
		tweak_data.screen_colors.button_stage_2 = _color
		Save(color_type, menu_type)
	elseif menu_type == "button_color" then
		tweak_data.screen_colors.button_stage_3 = _color
		Save(color_type, menu_type)
	end
	--managers.mission._fading_debug_output:script().log(string.format("%s", _color), Color.green)
end

function button_color_menu(color_type)
	local dialog_data = {    
		title = string.gsub(color_type, "_", " ").." Menu",
		text = "Select option                                                                                             Restart game to let changes take full effect",
		button_list = {}
	}
	
	if color_type == "hover_color" then
		local color_array = "hover"
		if color_table[color_array] then
			for _, dostuff in pairs(color_table[color_array]) do
				if color_table[color_array] then
					table.insert(dialog_data.button_list, dostuff)
				end
			end
		end
	elseif color_type == "button_color" then
		local color_array = "button"
		if color_table[color_array] then
			for _, dostuff in pairs(color_table[color_array]) do
				if color_table[color_array] then
					table.insert(dialog_data.button_list, dostuff)
				end
			end
		end
	end
	
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "back", callback_func = function() color_menu() end,})
	table.insert(dialog_data.button_list, { text = managers.localization:text("dialog_cancel"), focus_callback_func = function () end, cancel_button = true }) 
	managers.system_menu:show_buttons(dialog_data)
end

function color_menu()
	local dialog_data = {    
		title = "Color Menu",
		text = "Select Option",
		button_list = {}
	}
	
	local menu_table = {
		["absolute"] = {
			{ text = "Button Color - ON", callback_func = function() button_color_menu("button_color") end },
			{ text = "Button Hover - ON", callback_func = function() button_color_menu("hover_color") end },
			--{ text = "Load Last Save- ON", callback_func = function() loadcolor() end },
		}
	}
	
	local menu_array = "absolute"
	if menu_table[menu_array] then
		for _, dostuff in pairs(menu_table[menu_array]) do
			if menu_table[menu_array] then
				table.insert(dialog_data.button_list, dostuff)
			end
		end
	end

	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "back", callback_func = function() dofile("mods/hook/content/scripts/menus/mainmenu.lua") end,})
	table.insert(dialog_data.button_list, { text = managers.localization:text("dialog_cancel"), focus_callback_func = function () end, cancel_button = true }) 
	managers.system_menu:show_buttons(dialog_data)
end
color_menu()

--[[
--https://www.google.com/search?q=color+picker&ie=&oe=
--custom colors
Color.purple = Color("9932CC")
Color.labia = Color("E75480")
Color.gold = Color("FFD700")
Color.silver = Color("CFCFC4")
Color.bronze = Color("CD7F32")
Color.neongreen = Color("39FF14")
Color.lilac = Color("D891EF")
Color.brown = Color("6B4423")
Color.grey = Color("B2BEB5")
Color.limited = Color("4F7942")
Color.unlimited = Color("FDEE00")
Color.pro = Color("7BB661")
Color.wip = Color("0D98BA")

--global colors
Color.AliceBlue = Color('F0F8FF')          
Color.AntiqueWhite = Color('FAEBD7')           
Color.Aqua = Color('00FFFF')           
Color.Aquamarine = Color('7FFFD4')           
Color.Azure = Color('F0FFFF')           
Color.Beige = Color('F5F5DC')           
Color.Bisque = Color('FFE4C4')                     
Color.BlanchedAlmond = Color('FFEBCD')                     
Color.BlueViolet = Color('8A2BE2')           
Color.Brown = Color('A52A2A')           
Color.BurlyWood = Color('DEB887')           
Color.CadetBlue = Color('5F9EA0')           
Color.Chartreuse = Color('7FFF00')           
Color.Chocolate = Color('D2691E')           
Color.Coral = Color('FF7F50')           
Color.CornflowerBlue = Color('6495ED')           
Color.Cornsilk = Color('FFF8DC')           
Color.Crimson = Color('DC143C')           
Color.Cyan = Color('00FFFF')           
Color.DarkBlue = Color('00008B')           
Color.DarkCyan = Color('008B8B')           
Color.DarkGoldenRod = Color('B8860B')          
Color.DarkGray = Color('A9A9A9')           
Color.DarkGreen = Color('006400')           
Color.DarkKhaki = Color('BDB76B')           
Color.DarkMagenta = Color('8B008B')           
Color.DarkOliveGreen = Color('556B2F')           
Color.DarkOrange = Color('FF8C00')           
Color.DarkOrchid = Color('9932CC')           
Color.DarkRed = Color('8B0000')           
Color.DarkSalmon = Color('E9967A')           
Color.DarkSeaGreen = Color('8FBC8F')           
Color.DarkSlateBlue = Color('483D8B')           
Color.DarkSlateGray = Color('2F4F4F')           
Color.DarkTurquoise = Color('00CED1')           
Color.DarkViolet = Color('9400D3')           
Color.DeepPink = Color('FF1493')           
Color.DeepSkyBlue = Color('00BFFF')           
Color.DimGray = Color('696969')           
Color.DodgerBlue = Color('1E90FF')           
Color.FireBrick = Color('B22222')                     
Color.ForestGreen = Color('228B22')           
Color.Fuchsia = Color('FF00FF')           
Color.Gainsboro = Color('DCDCDC')                     
Color.Gold = Color('FFD700')           
Color.GoldenRod = Color('DAA520')           
Color.Gray = Color('808080')                      
Color.GreenYellow = Color('ADFF2F')           
Color.HoneyDew = Color('F0FFF0')           
Color.HotPink = Color('FF69B4')           
Color.IndianRed = Color('CD5C5C')           
Color.Indigo = Color('4B0082')                     
Color.Khaki = Color('F0E68C')           
Color.Lavender = Color('E6E6FA')           
Color.LavenderBlush = Color('FFF0F5')           
Color.LawnGreen = Color('7CFC00')           
Color.LemonChiffon = Color('FFFACD')           
Color.LightBlue = Color('ADD8E6')           
Color.LightCoral = Color('F08080')           
Color.LightCyan = Color('E0FFFF')           
Color.LightGoldenRodYellow = Color('FAFAD2')           
Color.LightGray = Color('D3D3D3')           
Color.LightGreen = Color('90EE90')           
Color.LightPink = Color('FFB6C1')           
Color.LightSalmon = Color('FFA07A')           
Color.LightSeaGreen = Color('20B2AA')           
Color.LightSkyBlue = Color('87CEFA')           
Color.LightSlateGray = Color('778899')           
Color.LightSteelBlue = Color('B0C4DE')           
Color.LightYellow = Color('FFFFE0')           
Color.Lime = Color('00FF00')           
Color.LimeGreen = Color('32CD32')           
Color.Linen = Color('FAF0E6')           
Color.Magenta = Color('FF00FF')           
Color.Maroon = Color('800000')           
Color.MediumAquaMarine = Color('66CDAA')           
Color.MediumBlue = Color('0000CD')           
Color.MediumOrchid = Color('BA55D3')           
Color.MediumPurple = Color('9370DB')           
Color.MediumSeaGreen = Color('3CB371')           
Color.MediumSlateBlue = Color('7B68EE')           
Color.MediumSpringGreen = Color('00FA9A')           
Color.MediumTurquoise = Color('48D1CC')           
Color.MediumVioletRed = Color('C71585')           
Color.MidnightBlue = Color('191970')           
Color.MintCream = Color('F5FFFA')           
Color.MistyRose = Color('FFE4E1')           
Color.Moccasin = Color('FFE4B5')                     
Color.Navy = Color('000080')           
Color.OldLace = Color('FDF5E6')           
Color.Olive = Color('808000')           
Color.OliveDrab = Color('6B8E23')           
Color.Orange = Color('FFA500')           
Color.OrangeRed = Color('FF4500')           
Color.Orchid = Color('DA70D6')           
Color.PaleGoldenRod = Color('EEE8AA')           
Color.PaleGreen = Color('98FB98')           
Color.PaleTurquoise = Color('AFEEEE')           
Color.PaleVioletRed = Color('DB7093')           
Color.PapayaWhip = Color('FFEFD5')     
Color.PeachPuff = Color('FFDAB9')          
Color.Peru = Color('CD853F')          
Color.Pink = Color('FFC0CB')           
Color.Plum = Color('DDA0DD')      
Color.PowderBlue = Color('B0E0E6')           
Color.RosyBrown = Color('BC8F8F')           
Color.RoyalBlue = Color('4169E1')           
Color.SaddleBrown = Color('8B4513')           
Color.Salmon = Color('FA8072')           
Color.SandyBrown = Color('F4A460')           
Color.SeaGreen = Color('2E8B57')           
Color.SeaShell = Color('FFF5EE')           
Color.Sienna = Color('A0522D')           
Color.Silver = Color('C0C0C0')           
Color.SkyBlue = Color('87CEEB')           
Color.SlateBlue = Color('6A5ACD')           
Color.SlateGray = Color('708090')                     
Color.SpringGreen = Color('00FF7F')           
Color.SteelBlue = Color('4682B4')           
Color.Tan = Color('D2B48C')           
Color.Teal = Color('008080')
Color.Thistle = Color('D8BFD8')           
Color.Tomato = Color('FF6347')           
Color.Turquoise = Color('40E0D0')           
Color.Violet = Color('EE82EE')           
Color.Wheat = Color('F5DEB3')                                
Color.YellowGreen = Color('9ACD32') 
--]]