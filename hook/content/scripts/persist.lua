if BetterDelayedCalls then
	BetterDelayedCalls:Add("persist_delay_call_heat", 1, function()
		if CommandManager.config["trainer_job_heat"] then
			if Utils:IsInHeist() or Utils:IsInGameState() then
				return
			end
			if Global.job_manager and Global.job_manager.heat then
				local heat = {}
				for k, v in pairs(tweak_data.narrative:get_jobs_index()) do
					heat[v] = 100
				end
				Global.job_manager.heat = heat
			end
		end
	end, false)
end