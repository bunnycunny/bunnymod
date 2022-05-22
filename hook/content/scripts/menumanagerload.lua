local ColorList = {
	r = nil,
	g = nil,
	b = nil,
	t = nil
}

function getColor(color_type, hb)
	local r, g, b = tonumber(color_type[1])/255, tonumber(color_type[2])/255, tonumber(color_type[3])/255
	local formated = string.format("%i, %i, %i", ColorList.r, ColorList.g, ColorList.b)
	if tonumber(color_type[4]) then
		local t = tonumber(color_type[4])/255
		return Color(r, g, b, t)
	else
		return Color(r, g, b)
	end
	--managers.mission._fading_debug_output:script().log(string.format("loaded %s: %s %s", hb, formated, Color(r, g, b)), Color.red)
end

function load_hover()
	ColorList.r = CommandManager["config"]["menucolors_hover"]["r"]
	ColorList.g = CommandManager["config"]["menucolors_hover"]["g"]
	ColorList.b = CommandManager["config"]["menucolors_hover"]["b"]
	ColorList.t = CommandManager["config"]["menucolors_hover"]["t"]
	--managers.mission._fading_debug_output:script().log(string.format("%s %s %s %s", ColorList.r, ColorList.g, ColorList.b, ColorList.t), Color.red)
	tweak_data.screen_colors.button_stage_2 = getColor({ColorList.r, ColorList.g, ColorList.b, ColorList.t}, "h")
end

function load_button()
	ColorList.r = CommandManager["config"]["menucolors_button"]["r"]
	ColorList.g = CommandManager["config"]["menucolors_button"]["g"]
	ColorList.b = CommandManager["config"]["menucolors_button"]["b"]
	ColorList.t = CommandManager["config"]["menucolors_button"]["t"]
	--managers.mission._fading_debug_output:script().log(string.format("%s %s %s %s", ColorList.r, ColorList.g, ColorList.b, ColorList.t), Color.green)
	tweak_data.screen_colors.button_stage_3 = getColor({ColorList.r, ColorList.g, ColorList.b, ColorList.t}, "b")
end
load_hover()
load_button()