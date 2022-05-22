function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end
if is_playing() then
	managers.mission._fading_debug_output:script().log(string.format("Secure - ACTIVATED"),  Color.green)
	local amount = 50
	local amount2 = 0
	local name = "meth"
	for i=1,amount do
		amount2 = amount2 + 1
		managers.loot:secure(name, managers.money:get_bag_value(name), true)
	end
	DelayedCalls:Add( "secure_loot_delay"..amount2, 2, function()
		if not alive(managers.player:player_unit()) then return end
		local secured_bags_on_map = (managers.loot:get_secured_mandatory_bags_amount()) + (managers.loot:get_secured_bonus_bags_amount())
		managers.mission._fading_debug_output:script().log(string.format("Secured: %s %s Total: %s", amount, name, secured_bags_on_map),  Color.green)
	end)
end