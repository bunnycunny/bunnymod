local orig = NetworkMatchMakingSTEAM.join_server
function NetworkMatchMakingSTEAM.join_server(self, room_id, skip_showing_dialog, quickplay)
	if room_id then
		CommandManager["config"]["reconnect_id"] = room_id
		CommandManager:Save()
	end
	orig(self, room_id, skip_showing_dialog, quickplay)
end