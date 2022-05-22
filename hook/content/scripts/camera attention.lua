
local class_name = "camera_attention"
local string_f = string.format("G_%s", class_name)

if not rawget(_G, string_f) then
	rawset(_G, string_f, {toggle = true})
else
	_G[string_f].toggle = not _G[string_f].toggle
end

local c = _G[string_f]
local settings = {
	yaw = 0,													--def -5-75
	pitch = -20,												--def -20
	fov = 360,													--def 60
	detection_range = (c.toggle and 0 or 15) * 100,				--def 15
	suspicion_range = (c.toggle and 0 or 7) * 100,				--def 7
	detection_delay = {
		2,														--def min 2
		3														--def max 3
	}
}

local function set_camera_attention(unit)
	unit:base():set_detection_enabled(true, settings)
end

for _, unit in pairs(SecurityCamera.cameras) do
	local ran, error_msg = pcall(set_camera_attention, unit)
	if error_msg and managers.mission and managers.mission._fading_debug_output then
		managers.mission._fading_debug_output:script().log(string.format("Camera %s failed to run: %s", unit, error_msg), Color.red)
	end
end

if managers.mission and managers.mission._fading_debug_output then
	managers.mission._fading_debug_output:script().log(string.format("%s", (c.toggle and "Camera Attention Activated" or "Camera Attention Deactivated")), (c.toggle and Color.green or Color.red))
end

