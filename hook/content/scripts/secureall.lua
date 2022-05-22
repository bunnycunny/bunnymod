local function in_game() -- In lobby check
	return string.find(game_state_machine.current_state_name(game_state_machine), "game")
end
function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end
if not is_playing() and not in_game() then
	return
end
can_interact = function()
	return true
end
local secureall = function()
	--[[ Small loot value multiplier (extra jewelry cash value in jewelry store, deposit boxes in bank heist, etc)
	if not _uvSmallLoot then _uvSmallLoot = PlayerManager.upgrade_value end 
	function PlayerManager:upgrade_value( category, upgrade, default ) 
		if category == "player" and upgrade == "small_loot_multiplier" then 
			return 20
		else 
			return _uvSmallLoot(self, category, upgrade, default) 
		end 
	end
	if not _uvlSmallLoot then _uvlSmallLoot = PlayerManager.upgrade_value_by_level end 
	function PlayerManager:upgrade_value_by_level( category, upgrade, level, default ) 
		if category == "player" and upgrade == "small_loot_multiplier" then 
			return 20
		else 
			return _uvlSmallLoot(self, category, upgrade, level, default) 
		end 
	end--]]

	--secure small loot
	local _project_instigators = ElementAreaTrigger.project_instigators
	function ElementAreaTrigger:project_instigators()	
		local instigators = _project_instigators( self )
		if self._values.instigator == "loot" or self._values.instigator == "unique_loot" then
			local all_found = World:find_units_quick("all", 14)
			for _, unit in pairs( all_found ) do
				local carry_data = unit:carry_data()
				if carry_data then
					table.insert(instigators, unit)
				end
			end
		end
		return instigators
	end

	--grabs small loot
	local function interactbytweak(...)
		local player = managers.player._players[1]
		if not player then return end

		if not equipment_toggle then
			dofile("mods/hook/content/scripts/equipment.lua")
		end
		
		local interactives = {}
		
		local tweaks = {}
		for _,arg in pairs({...}) do
			tweaks[arg] = true
		end
		
		for key,unit in pairs(managers.interaction._interactive_units) do
			if not alive(unit) then return end
			local interaction = unit.interaction
			interaction = interaction and interaction( unit )
			if interaction and tweaks[interaction.tweak_data] then
				table.insert(interactives, interaction)
			end
		end
		for _,i in pairs(interactives) do
			i.can_interact = can_interact
			i:interact(player)    
			i.can_interact = nil
		end
		
		if equipment_toggle then
			dofile("mods/hook/content/scripts/equipment.lua")
		end
	end

	local function grabloot()
		--if Network:is_Server() then
			interactbytweak('requires_ecm_jammer_atm','winning_slip','cas_chips_pile','money_wrap_single_bundle_active','cash_register','safe_loot_pickup','diamond_pickup','tiara_pickup','mus_pku_artifact')
			DelayedCalls:Add( "start_vote", 2, function() 
				interactbytweak('press_pick_up','money_wrap_active','invisible_interaction_open','money_wrap_single_bundle') 
				--if not global_carry_stacker then
				--	dofile("mods/hook/content/scripts/securecarrybags.lua")
				--end
			end)
		--end
	end
	managers.mission._fading_debug_output:script().log(string.format("Secure Small Loot ACTIVATED"),  Color.green)
	grabloot()
end
secureall()