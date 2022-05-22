if not rawget(_G, "xray_manager") then
	managers.mission._fading_debug_output:script().log('Enable x-ray first.', Color.red)
	return
end

if not Utils:IsInHeist() or not Utils:IsInGameState() then
	return
end

if not rawget(_G, "xray_share_manager") then
	rawset(_G, "xray_share_manager", {})
	
	function xray_share_manager:_toggle()
		if not xray_manager.toggle then
			return
		end
		
		self.toggle = self.toggle or false
		if not self.toggle then
			xray_manager:markToggle_on(true)
			managers.mission._fading_debug_output:script().log('Xray Team - ACTIVATED', Color.green)
		else
			xray_manager:markToggle_off(false)
			managers.mission._fading_debug_output:script().log('Xray Team - DEACTIVATED', Color.red)
		end
		self.toggle = not self.toggle
	end
	xray_share_manager:_toggle()
else
	xray_share_manager:_toggle()
end