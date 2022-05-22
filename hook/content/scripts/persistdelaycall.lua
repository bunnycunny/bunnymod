rawset(_G, "BetterDelayedCalls", {
	_calls = {}
})

function BetterDelayedCalls:Update(t, dt)
	for k, v in pairs(self._calls) do
		if self._calls[k] ~=  nil then
			v.currentTime = v.currentTime + dt
			if v.currentTime >= v.timeToWait then
				if v.loop then
					if tonumber(v.loop) then
						if v.loop >= 1 then
							self._calls[k].loop = self._calls[k].loop - 1
						else
							return self:Remove(k)
						end
					end
					v.currentTime = 0
				else
					self:Remove(k)
				end

				if v.functionCall then
					pcall(v.functionCall)
				end
			end
		end
	end
end


function BetterDelayedCalls:Add(id, time, func, loop)
	local data = self._calls[id]
	if data == nil then
		self._calls[id] = {
			functionCall = func,
			timeToWait = time,
			currentTime = 0,
			loop = (loop or false)
		}
	else
		-- Do not create a new table if an entry already exists (memory efficiency)
		data.functionCall = func
		data.timeToWait = time
		data.currentTime = 0
		data.loop = (loop or false)
	end
end


function BetterDelayedCalls:Remove(id)
	if self._calls[id] then
		self._calls[id] = nil
	end
end


function BetterDelayedCalls:RemainingTime(id)
	local data = self._calls[id]
	if data then
		return ( data.timeToWait - data.currentTime )
	end
	return 0
end

if RequiredScript == "lib/managers/menumanager" then
	local __orig = MenuManager.update
	function MenuManager.update(self, t, dt)
		__orig(self, t, dt)
		BetterDelayedCalls:Update(t, dt)
	end
end
--BetterDelayedCalls:Add("main_persist", 0.1, function() end, true) run every 0.1 sec
--BetterDelayedCalls:Add("main_persist", 6, function() end, false) wait 6 sec then run again
--BetterDelayedCalls:Add("main_persist", 3, function() end, 5) run 5 times every 3 sec
--BetterDelayedCalls:Remove("main_persist") stop loop