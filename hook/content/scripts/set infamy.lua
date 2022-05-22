local mod_name = "add one more infamy"
local not_exist = not rawget(_G, mod_name)
local c = not_exist and rawset(_G, mod_name, {toggle = false}) and _G[mod_name] or _G[mod_name]
if not_exist then
	c.last_press = 0
	function c:infamy(num)
		managers.experience:set_current_rank(num)
		managers.infamy:_set_points(num)
		managers.mission._fading_debug_output:script().log(string.format("%s", num), Color.green)
	end
end

if (Application:time() - c.last_press) < 0.2 then
	local current = managers.experience:current_rank() + 1
	c:infamy(current)
end
c.last_press = Application:time()

--[[local function lvl(num)
	managers.experience:_set_current_level(num)
	managers.experience:_set_next_level_data(num)
	managers.mission._fading_debug_output:script().log(string.format("%s", num), Color.green)
end

local current_lvl = managers.experience:current_level() - 99
lvl(current_lvl)--]]