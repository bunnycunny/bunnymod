--no favor lost
if MoneyManager and CommandManager.config["preplanning_cost"] then
	function MoneyManager.get_preplanning_type_cost()
		return 0
	end
	function MoneyManager.can_afford_preplanning_type()
		return true
	end
	function MoneyManager.get_preplanning_votes_cost()
		return 0
	end
end

if PrePlanningManager then
	if CommandManager.config["preplanning_cost"] then
		function PrePlanningManager.get_type_budget_cost()
			return 0
		end
		function PrePlanningManager.can_reserve_mission_element()
			return true
		end
		function PrePlanningManager.can_vote_on_plan()
			return true
		end
	end
	
	if CommandManager.config["preplanning_matter"] then
		local PPM_umv_orig = PrePlanningManager._update_majority_votes
		function PrePlanningManager:_update_majority_votes(...)
			if Network:is_server() then
				local local_peer_id = managers.network:session():local_peer():id()
				local vote_council = self:get_vote_council()
				local plan_data = vote_council[local_peer_id]
				if plan_data and type(plan_data) == "table" then
					local winners = {}
					for plan, data in pairs(plan_data) do
						winners[plan] = {data[1], data[2]}
					end
					self._saved_majority_votes = winners
					return winners
				end
			end
			return PPM_umv_orig(self, ...)
		end
	
		local PPM_umv_orig = PrePlanningManager._update_majority_votes
		function PrePlanningManager:_update_majority_votes(...)
			if Network:is_server() then
				local your_id = managers.network:session():local_peer():id()
				local players_ids = self:get_vote_council()
				local plan_data = players_ids[your_id]
				if type(plan_data) == "table" then
					for plan, data in pairs(plan_data) do
						self._saved_majority_votes = {
							[plan] = {data[1], data[2]}
						}
						return self._saved_majority_votes
					end
				end
			end
			return PPM_umv_orig(self, ...)
		end
	end
end