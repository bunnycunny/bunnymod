--not in use
BetterDelayedCalls:Add("fakename_persist", 2, function()
	function is_playing()
		if not BaseNetworkHandler then 
			return false 
		end
		return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
	end
	
	local name = CommandManager.config.fake_name
	if not managers.network:session() then
		return
	end
	managers.network:session():local_peer():set_name(name)
	for _, peer in pairs(managers.network:session():peers()) do
		peer:send("request_player_name_reply", name)
	end
	
	if is_playing() then
		HUDManaher.update(self, t, dt) end
	end
end, true)

CommandManager:Module("NameSpoof")