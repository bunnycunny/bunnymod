--kills bags and grabs everyone
local function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end

if not is_playing() then 
	return
end

local function can_interact()
	return true
end

local function interactbytweak(...)
	local player = managers.player._players[1]
	if not player then
		return
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
end

local function dmg_melee(unit)
	local action_data = {
		damage = unit:character_damage()._HEALTH_INIT,
		raw_damage = 1,
		attacker_unit = managers.player:player_unit(),
		attack_dir = Vector3(0,0,0),
		weapon_unit = managers.player:player_unit():inventory():equipped_unit(),
		variant = "fire",
		critical_hit = true,
		fire_dot_data = {
			dot_trigger_max_distance = 1300,
			dot_trigger_chance = 1,
			dot_length = 1,
			dot_damage = 10,
			start_dot_dance_antimation = false,
			dot_tick_period = 0.5
		},
		col_ray = {
			position = unit:position(),
			body = unit:body("body"),
			unit = unit,
			normal = Vector3(0,0,0)
		}
	}
	unit:character_damage():damage_fire(action_data)
end

local startkbgs = function()
	
	for _,ud in pairs(managers.enemy:all_civilians()) do
		pcall(dmg_melee,ud.unit)
	end

	dofile("mods/hook/content/scripts/killall.lua")
	
	if not global_carry_stacker and Network:is_server() then
		dofile("mods/hook/content/scripts/carrystacker.lua")
	end
end

local function bag_people()
	dofile("mods/hook/content/scripts/bagbodies.lua")
end

startkbgs()
bag_people()
DelayedCalls:Add("take_bags", 0.6, function()
	managers.chat:send_message( 1, managers.network.system, "Kill" )
	managers.chat:send_message( 1, managers.network.system, "Bag" )
	if Network:is_server() then
		interactbytweak('painting_carry_drop','goat_carry_drop','safe_carry_drop','carry_drop')
		managers.chat:send_message( 1, managers.network.system, "Grab" )
		managers.chat:send_message( 1, managers.network.system, "Stack" )
	end
	managers.chat:send_message( 1, managers.network.system, "Complete" )
end)