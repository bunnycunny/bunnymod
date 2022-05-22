--https://github.com/mwSora/payday-2-luajit/blob/master/pd2-lua/lib/tweak_data/playertweakdata.lua
local old_ptd = PlayerTweakData.init
function PlayerTweakData:init()
	old_ptd(self)
	self.put_on_mask_time = 1.1 --def 2
	self.max_nr_following_hostages = 5
	if CommandManager.config["trainer_buffs"] then
		self.damage.TASED_RECOVER_TIME = 0
		self.damage.BLEED_OUT_HEALTH_INIT = 500
		self.damage.automatic_assault_ai_trade_time = 2
		self.damage.automatic_assault_ai_trade_time_max = 2
		self.movement_state.standard.movement.speed.CROUCHING_MAX = 280
		self.movement_state.standard.movement.speed.STEELSIGHT_MAX = 350
		self.movement_state.standard.movement.speed.CLIMBING_MAX = 350
		self.movement_state.standard.movement.speed.STANDARD_MAX = 350
		self.movement_state.standard.movement.speed.RUNNING_MAX = 575
	end
	if CommandManager.config["sixth_sense_buff"] then
		self.omniscience = {
			start_t = 0.1,			-- Time in seconds before marking units
			interval_t = 0,			-- Time in seconds you have to wait before counting start_t after marking unit
			sense_radius = 1500,	-- Distance to find units 2000 = 20m
			target_resense_t = 0	-- Time in seconds you have to wait before you can mark marked units again
		}
	end
end



