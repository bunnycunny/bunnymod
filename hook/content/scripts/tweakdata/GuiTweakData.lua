local orig = GuiTweakData.init
function GuiTweakData:init(tweak_data)
	orig(self, tweak_data)
	self.crime_net.job_vars = {
		max_active_jobs = (CommandManager.config["remove_free_jobs"] and 0 or 12), --def 10
		active_job_time = 25,
		new_job_min_time = 0.01, --def 1.5
		new_job_max_time = 0.02, --def 3.5
		refresh_servers_time = SystemInfo:platform() == Idstring("PS4") and 10 or 5,
		total_active_jobs = 40, --def 40
		max_active_server_jobs = 100
	}
end