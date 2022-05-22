local orig_GPCM = GamePlayCentralManager.start_heist_timer
function GamePlayCentralManager.start_heist_timer(self)
	orig_GPCM(self)
	
	if CommandManager then
		local path = CommandManager.config.afk.path.."Addons/afktimer.lua"
		local file = io.open(path, "rb")
		if file then 
			dofile(path)
		end
		
		if CommandManager.config.automsg.checks.host_msg_recived then
			CommandManager.config.automsg.checks.host_msg_recived = false
		end
		if CommandManager.config.automsg.checks.safe_msg_recived then
			CommandManager.config.automsg.checks.safe_msg_recived = false
		end
		CommandManager:Save()
	end
end