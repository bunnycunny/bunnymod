if not StatisticsManager or not managers.mission then
	return
end

if not rawget(_G, "spoof_statestic") then
	rawset(_G, "spoof_statestic", {
		["_toggle"] = false
	})
	
	local orig_func_send_statistics = StatisticsManager.send_statistics
	function StatisticsManager:send_statistics()
		if not spoof_statestic["_toggle"] then
			if not managers.network:session() then
				return
			end

			local peer_id = managers.network:session():local_peer():id()
			local total_kills = self:session_total_kills() + 3558
			local total_specials_kills = self:session_total_specials_kills() + 1724
			local total_head_shots = self:session_total_head_shots() + 3516
			local accuracy = 209
			local downs = 0

			if Network:is_server() then
				managers.network:session():on_statistics_recieved(peer_id, total_kills, total_specials_kills, total_head_shots, accuracy, downs)
			else
				managers.network:session():send_to_host("send_statistics", total_kills, total_specials_kills, total_head_shots, accuracy, downs)
			end
		else
			orig_func_send_statistics(self)
		end
	end
	
	function spoof_statestic:message(msg, color)
		managers.mission._fading_debug_output:script().log(string.format("%s", msg), color)
	end
	
	function spoof_statestic:toggle()
		if spoof_statestic["_toggle"] then
			self:message("Statestics - ACTIVATED", Color('00FF00'))
		else
			self:message("Statestics - DEACTIVATED", Color('FF4500'))
		end
		spoof_statestic["_toggle"] = not spoof_statestic["_toggle"]
	end
	
	spoof_statestic:toggle()
else
	spoof_statestic:toggle()
end