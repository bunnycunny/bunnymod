function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end

if not is_playing() then
	return
end

global_toggle_drill_off = global_toggle_drill_off or false
if not global_toggle_drill_off then	
	local player = managers.player:player_unit()
	if not alive(player) then return end
	
	--set drill timer
	local function start_drill()
		for _,unit in pairs(World:find_units_quick("all", 1)) do
			local timer = unit:base() and unit:timer_gui() and unit:timer_gui()._current_timer
			if timer and math.floor(timer) ~= -1 then
				local newvalue = 0.1
				unit:timer_gui():_start(newvalue)
				if managers.network:session() then
					managers.network:session():send_to_peers_synched("start_timer_gui", unit:timer_gui()._unit, newvalue)
				end
				if not unit:timer_gui()._jammed then
					unit:timer_gui():set_jammed(true)
				end
				if unit:timer_gui()._jammed then
					unit:timer_gui():set_jammed(false)
				end
			end
		end
	end
	
	--drill doesnt jam
	if not _jamValue then _jamValue = TimerGui._set_jamming_values end
	function TimerGui:_set_jamming_values() return end
	
	--drill timer started
	if not _jamTimer then _jamTimer = TimerGui.start end
	function TimerGui:start( timer )
		timer = 1
		DelayedCalls:Add( "antidrill_stackoverflow2", 0.5, function() start_drill() end)
		if self._jammed then
			self:_set_jammed( false )
			return
		end
		if not self._powered then
			self:_set_powered( true )
			return
		end
		if self._started then
			return
		end
		self:_start( timer )
		if managers.network:session() then
			managers.network:session():send_to_peers_synched( "start_timer_gui", self._unit, timer )
		end 
	end
	
	--unjam drill
	if not _unjam then _unjam = Drill.set_jammed end
	function Drill:set_jammed(jammed)
		_unjam(self, jammed)
		if self._unit:interaction() and not (self._unit:interaction().tweak_data == "hack_suburbia_outline" or self._unit:interaction().tweak_data == "hack_suburbia_jammed_axis") then
			self._unit:interaction():interact(player)
		end
		if not Network:is_server() then
			DelayedCalls:Add( "antidrill_stackoverflow", 1.5, function() start_drill() end)
		end
	end
	DelayedCalls:Add( "antidrill_stackoverflow2", 0.5, function() start_drill() end)
	managers.mission._fading_debug_output:script().log('Instant Timer - ACTIVATED',  Color.green)
else
	if _jamValue then TimerGui._set_jamming_values = _jamValue end
	if _jamTimer then TimerGui.start = _jamTimer end
	if _unjam then Drill.set_jammed = _unjam end
	managers.mission._fading_debug_output:script().log('Instant Timer - DEACTIVATED',  Color.red)
end
global_toggle_drill_off = not global_toggle_drill_off