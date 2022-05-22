BetterDelayedCalls:Add("kill_loop", CommandManager.config.killloop.speed, function()
	if CommandManager:is_playing() then
		dofile("mods/hook/content/scripts/killall.lua")
	else
		BetterDelayedCalls:Remove("kill_loop")
	end
end, true)

CommandManager:Module("killloop")