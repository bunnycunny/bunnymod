local crosshair_fire = false								-- Set to true to fire when enemy reach the crosshair or false to target everyone in max_distance and fov_degree.
local exact_crosshair = false							-- Set to true to make bullet hit exact location of aim or false to auto aim at aim_for_head or aim_for_body of unit you point at. If enemy is behind walls or shields, it will aim at exact crosshair (Requires crosshair_fire true).

local shoot_through_wall = false							-- Set to true if you want to target enemies through walls (required to shot sentries).
local ignore_wall_thickness = true						-- Set to true if you want to ignore wall thickness, require shoot_through_wall = true.
local wall_thickness = 0								-- Set to value between 0-40 (0.1 you can't shoot throught glass).
local shoot_through_shield = true						-- Set to true to shoot through shields or it will shoot shields when using special ammo.
local shoot_through_enemies = false						-- Set to true to shoot through enemies.

local aim_for_head = true								-- Set to true to aim for head.
local aim_for_body = false								-- Set to true to aim for body.

local auto_shoot = true									-- Set to true to auto shoot.
local auto_reload = true								-- Set to true to reload weapon when emety.
local auto_replenish_ammo = false						-- Replenish ammo when emety by cheating ammo.
local silent_shooting = false							-- Set to true to fire gun silently.

local shoot_through_wall_damage = false					-- Custom damage (in number format) when enemy is behind wall or false.
local shoot_through_shield_damage = false				-- Custom damage (in number format) when enemy is shield or false.
local custom_damage_by_unit = false						-- Set to true to use defined damage by unit in table bellow or false. Priority 2.
local custom_damage = false								-- Custom damage in number format or false. Prioritizing custom_damage_by_unit, shoot_through_wall_damage and shoot_through_shield_damage first.

local direct_fire_delay = false								-- false or Seconds before shooting, this overwrites fire delays.
local max_fire_delay = 0.6								-- Max delay before fireing or false for default weapon fire rate.
local min_fire_delay = 0.1								-- Min delay before fireing or false for default weapon fire rate.
local max_fire_delay_by_unit = 0.1						-- Max delay before fireing rapidly at certain units like dozers.
local min_fire_delay_by_unit = 0.03						-- Min delay before fireing rapidly at certain units like dozers.
local max_distance = 1000								-- Distance to target units (higher distance lags more).
local fov_degree = 140									-- Set to a value between 1-360 if you want to target units within a certain amount of degrees. (Ignored with crosshair_fire true).

local shoot_civilians = false							-- Set to true to shoot civilians.
local shoot_turrets = true								-- Set to true to shoot turrets, shoot_through_wall is requires.
local shoot_enemies = true								-- Set to true to shoot enemies.

local shoot_when_moving = true							-- set to true to auto shoot when moving. 
local shoot_when_aiming = false							-- set to true to auto shoot when aiming down sight.
local shoot_when_running = false						-- set to true to auto shoot when running.
local shoot_when_crouching = true						-- set to true to auto shoot when crouching.
local shoot_when_keybind_is_pressed = false				-- set to false to disable this keybind or "left shift", "right shift", "left ctrl", "right ctrl", "left alt" and "t", "g" e.g to auto shoot. This overwrites options above for auto shoot.
														-- Units not to target.
local banlist = {
	["phalanx_vip"]  						= true,		-- captain
	["phalanx_minion"]						= false, 	-- Wintergoons
	["shield"]								= false,	-- shield
	["civilian"]							= false,
	["civilian_female"]						= false,
	["spooc"]								= false,	-- cloaker
	["taser"]								= false,
	["shield"]								= false,
	["tank"]								= false,
	["tank_mini"]							= false,	-- Minigundozer
	["tank_medic"]							= false,	-- Medic Dozer
	["tank_hw"]								= false,	-- Headless Titandozers
	["sniper"]								= false,
	["gangster"]							= false,
	["security"]							= false,
	["medic"]								= false,
	["gensec"]								= false,	-- Gensec guards (Transport DLC, GO Bank)
	["swat"]								= false,	-- Blue SWAT, low diff
	["heavy_swat"]							= false,	-- Yellow SWAT
	["fbi"]									= false,	-- Can refer to field, vet, or office agents
	["fbi_swat"]							= false,	-- Common Heavy Response Units seen on many diffs
	["fbi_heavy_swat"]						= false,	-- brown armored FBI
	["cop_female"]							= false,
	["city_swat"]							= false,	-- GenSec Elites or Murkywaters
	["mobster_boss"]						= false,	-- The Commissar
	["mobster"]								= false, 	-- Commissars goons
	["hector_boss"]							= false, 	-- miami
	["hector_boss_no_armor"]				= false, 	-- miami
	["biker_boss"]							= false, 	-- female MC on Day 2 Biker
	["chavez_boss"]							= false, 	-- panic room
	["biker"]								= false, 	-- Bikers
	["bolivians"]							= false, 	-- Bolivians
	["shadow_spooc"]						= false, 	-- wh secret
	["drug_lord_boss"]						= false,	-- scarface m
	["drug_lord_boss_stealth"]				= false,	-- scarface m
	["spa_vip"]								= true,		--brooklyn 10 10
	["spa_vip_hurt"]						= true, 	--?
	["captain"]								= false,	--?
	["civilian_mariachi"]					= false,	--san martin bank
	["mute_security_undominatable"]			= false,	--garret breaking feds e.g
	["security_undominatable"]				= false,
	["old_hoxton_mission"]					= true		--hoxton breakout, hoxton
}
														-- units to fire faster at
local fire_delay_mod_by_unit = {
	["phalanx_vip"]  						= false,	-- captain
	["phalanx_minion"]						= false, 	-- Wintergoons
	["shield"]								= false,	-- shield
	["civilian"]							= false,
	["civilian_female"]						= false,
	["spooc"]								= false,	-- cloaker
	["taser"]								= false,
	["shield"]								= false,
	["tank"]								= true,
	["tank_mini"]							= true,		-- Minigundozer
	["tank_medic"]							= true,		-- Medic Dozer
	["tank_hw"]								= true,		-- Headless Titandozers
	["sniper"]								= false,
	["gangster"]							= false,
	["security"]							= false,
	["medic"]								= false,
	["gensec"]								= false,	-- Gensec guards (Transport DLC, GO Bank)
	["swat"]								= false,	-- Blue SWAT, low diff
	["heavy_swat"]							= false,	-- Yellow SWAT
	["fbi"]									= false,	-- Can refer to field, vet, or office agents
	["fbi_swat"]							= false,	-- Common Heavy Response Units seen on many diffs
	["fbi_heavy_swat"]						= false,	-- brown armored FBI
	["cop_female"]							= false,
	["city_swat"]							= false,	-- GenSec Elites or Murkywaters
	["mobster_boss"]						= false,	-- The Commissar
	["mobster"]								= false, 	-- Commissars goons
	["hector_boss"]							= false, 	-- miami
	["hector_boss_no_armor"]				= false, 	-- miami
	["biker_boss"]							= false, 	-- female MC on Day 2 Biker
	["chavez_boss"]							= false, 	-- panic room
	["biker"]								= false, 	-- Bikers
	["bolivians"]							= false, 	-- Bolivians
	["shadow_spooc"]						= false, 	-- wh secret
	["drug_lord_boss"]						= false,	-- scarface m
	["drug_lord_boss_stealth"]				= false,	-- scarface m
	["spa_vip"]								= false,	--?
	["spa_vip_hurt"]						= false, 	--?
	["captain"]								= false,	--?
	["civilian_mariachi"]					= false,	--san martin bank
}
														-- custom damage by unit using numbers or false for default gun damage
local custom_damage_table = {
	["phalanx_vip"]  						= 1000,		-- captain
	["phalanx_minion"]						= 1000, 	-- Wintergoons
	["shield"]								= 10,		-- shield
	["civilian"]							= 10,
	["civilian_female"]						= 10,
	["spooc"]								= 10,		-- cloaker
	["taser"]								= 10,
	["shield"]								= 10,
	["tank"]								= false,
	["tank_mini"]							= false,	-- Minigundozer
	["tank_medic"]							= false,	-- Medic Dozer
	["tank_hw"]								= false,	-- Headless Titandozers
	["sniper"]								= 10,
	["gangster"]							= 10,
	["security"]							= 10,
	["medic"]								= 10,
	["gensec"]								= 10,		-- Gensec guards (Transport DLC, GO Bank)
	["swat"]								= 10,		-- Blue SWAT, low diff
	["heavy_swat"]							= 10,		-- Yellow SWAT
	["fbi"]									= 10,		-- Can refer to field, vet, or office agents
	["fbi_swat"]							= 10,		-- Common Heavy Response Units seen on many diffs
	["fbi_heavy_swat"]						= 10,		-- brown armored FBI
	["cop_female"]							= 10,
	["city_swat"]							= 10,		-- GenSec Elites or Murkywaters
	["mobster_boss"]						= 10,		-- The Commissar
	["mobster"]								= 10, 		-- Commissars goons
	["hector_boss"]							= 10, 		-- miami
	["hector_boss_no_armor"]				= 10, 		-- miami
	["biker_boss"]							= 10, 		-- female MC on Day 2 Biker
	["chavez_boss"]							= 10, 		-- panic room
	["biker"]								= 10, 		-- Bikers
	["bolivians"]							= 10, 		-- Bolivians
	["shadow_spooc"]						= 10, 		-- wh secret
	["drug_lord_boss"]						= 10,		-- scarface m
	["drug_lord_boss_stealth"]				= 10,		-- scarface m
	["spa_vip"]								= 10,		--?
	["spa_vip_hurt"]						= 10, 		--?
	["captain"]								= 10,		--?
	["civilian_mariachi"]					= 10,		--san martin bank
}
														-- Set to true to ban the player state (not shoot in that state)
local state_blacklist = {
	["standard"] 							= false,	-- masked
	["bleed_out"] 							= false,	-- on ground and able to shoot
	["bipod"] 								= false,	-- using lmg extension
	["driving"] 							= true,		-- driving
	["fatal"] 								= true,		-- on ground not able to shoot
	["jerry2"]								= true,		-- parachute
	["mask_off"]							= true,		-- mask off
	["tased"] 								= false,	-- when tased
	["incapacitated"] 						= true,		-- on ground not able to shoot
	["carry"] 								= false,	-- carrying bags
	["arrested"] 							= true,		-- cuffed
	["civilian"] 							= true,		-- mask off and can interact (start of golden grin casino heist)
	["clean"] 								= true		-- mask off and can't interact (start of panic room heist)
}


--	END
---------------------------------------------------------------------------------------------------------------------


if aimbot_shot and aimbot_shot["toggle_s"] then
	managers.chat:feed_system_message(ChatManager.GAME, "Turn off auto shoot first!")
	return
end

active = active or false
active = not active
--managers.hud:show_hint({text = active and "Aimbot Activated" or "Aimbot Deactivated"})
managers.mission._fading_debug_output:script().log(string.format("%s", (active and "Aimbot Activated" or "Aimbot Deactivated")), (active and Color.green or Color.red))


local dir = nil
local targeted_unit = nil
local unit_position = nil
local currect_shot_time = 0
local unit_part = {
	[1] = "head",
	[2] = "body"
}
local turret_names = {
	["Idstring(@ID3c4730f4268ada38@)"] = true, --vit celling
	["Idstring(@ID56c162b293c88d8d@)"] = true, --hell island
	["Idstring(@ID132676041d28bad4@)"] = true, --turret van
	["Idstring(@IDe6bfc34a5c60c351@)"] = true, --scarface celling
	["Idstring(@IDb2437dc46fdd6cf4@)"] = true, --san martin
	["Idstring(@IDfc730ad39ff3b1e9@)"] = true, --henry rock
	["Idstring(@IDc71d763cd8d33588@)"] = false --player sentry
}
math.randomseed(os.time())

local function get_player()
	if managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) then
		return managers.player:player_unit()
	end
end

local function aimbot_rng_decimal(min, max, pthis)
	local name = pthis._name_id
	local min_rate = min
	local max_rate = max
	if not min then
		if tweak_data.weapon[name].FIRE_MODE == "auto" and tweak_data.weapon[name]["auto"] then
			if not max_rate then
				min_rate = 0.25 * tweak_data.weapon[name]["auto"]["fire_rate"]
			else
				min_rate = tweak_data.weapon[name]["auto"]["fire_rate"]
			end
		elseif tweak_data.weapon[name].FIRE_MODE == "single" and tweak_data.weapon[name]["single"] then
			if not max_rate then
				min_rate = 0.50 * tweak_data.weapon[name]["single"]["fire_rate"]
			else
				min_rate = tweak_data.weapon[name]["single"]["fire_rate"]
			end
		else
			min_rate = 0.1
		end
	end
	if not max then
		if tweak_data.weapon[name].FIRE_MODE == "auto" and tweak_data.weapon[name]["auto"] then
			if not min_rate then
				max_rate = tweak_data.weapon[name]["auto"]["fire_rate"] + tweak_data.weapon[name]["auto"]["fire_rate"]
			else
				max_rate = tweak_data.weapon[name]["auto"]["fire_rate"]
			end
		elseif tweak_data.weapon[name].FIRE_MODE == "single" and tweak_data.weapon[name]["single"] then
			if not min_rate then
				max_rate = tweak_data.weapon[name]["single"]["fire_rate"] + tweak_data.weapon[name]["single"]["fire_rate"]
			else
				max_rate = tweak_data.weapon[name]["single"]["fire_rate"]
			end
		else
			max_rate = 0.8
		end
	end
	if targeted_unit and alive(targeted_unit) and fire_delay_mod_by_unit[targeted_unit:base()._tweak_table] then
		min_rate, max_rate = 0.04, 0.07
	end
	return math.random()*(max_rate-min_rate) + min_rate
end

local function aimbot_keypressed()
	if managers.hud and managers.hud._chat_focus == true then
		return true
	end
	
	if managers.network.account and managers.network.account._overlay_opened then
		return true
	end
	
	if shoot_when_keybind_is_pressed and Input:keyboard():down(Idstring(shoot_when_keybind_is_pressed):id()) then
		return false
	end
	
	local current_state = managers.player._current_state
	if current_state and state_blacklist[current_state] then
		return true
	end
	
	if get_player() and get_player().base and get_player():base() and get_player():base().controller then
		local controller = get_player():base():controller()
		if controller:get_input_bool("secondary_attack") and not shoot_when_aiming then
			return true
		elseif controller:get_input_bool("run") and not shoot_when_running then
			return true
		elseif controller:get_input_bool("duck") and not shoot_when_crouching then
			return true
		elseif mvector3.length(controller:get_input_axis("move")) > PlayerStandard.MOVEMENT_DEADZONE and not shoot_when_moving then
			return true
		end
		
		if (controller:get_input_bool("primary_attack")) 
		or (controller:get_input_pressed("throw_grenade"))
		or (controller:get_input_pressed("reload")) 
		or (controller:get_input_pressed("switch_weapon")) 
		or (controller:get_input_pressed("jump")) 
		or (controller:get_input_pressed("interact")) 
		or (controller:get_input_pressed("use_item")) 
		or (controller:get_input_pressed("melee")) then
			return true
		end
	end
end

local function aimbot_round(number)
	if (number - (number % 0.1)) - (number - (number % 1)) < 0.5 then
		number = number - (number % 1)
	else
		number = (number - (number % 1)) + 1
	end
	return number
end

local function aimbot_get_pos(unit, part)
	if unit:body(part) then
		if alive(unit:body(part)) and unit:body(part):unit() and unit:body(part):enabled() and (unit:body(part):unit():id() ~= -1) then
			local part_pos = unit:body(part):position()
			if part_pos then
				return unit:body(part):position()
			end
		end
	elseif unit:movement() and unit:movement():m_head_pos() then
		return unit:movement():m_head_pos()
	end
end

local function aimbot_get_unit_pos(unit)
	local to = nil
	
	if not unit and not alive(unit) then
		return to
	end
	
	if not aim_for_body and not aim_for_head then
		return to
	end
	
	if aim_for_head and aim_for_body then
		math.randomseed(os.time())
		local rng_part = math.floor(aimbot_round(math.random(1, #unit_part)))
		if not unit_part[rng_part] then
			return to
		end
		local part = unit_part[rng_part]
		to = aimbot_get_pos(unit, part)
	elseif aim_for_head then
		to = aimbot_get_pos(unit, unit_part[1])
	elseif aim_for_body then
		to = aimbot_get_pos(unit, unit_part[2])
	end
	return to
end

local function aimbot_check_immortal(unit)
	local character_dmg = unit:parent() and unit:parent():character_damage()
	if character_dmg and (character_dmg._invulnerable or character_dmg._immortal) then
		return true
	end
end

local function aimbot_check_level()
	local level = managers.job:current_level_id()
	if string.match(level, "skm") then
		return true
	end
end

local function aimbot_is_hostage(unit)
	if alive(unit) then
		local brain = unit.brain and unit.brain(unit)
		if brain then
			if aimbot_check_immortal(unit) then
				return false
			end
		
			if aimbot_check_level() and (unit:base()._tweak_table == "civilian" or unit:base()._tweak_table == "civilian_female") then
				return false
			end
		
			if brain.is_hostage and brain.is_hostage(brain) then
				return false
			end
		
			local anim_data = unit.anim_data and unit.anim_data(unit)
			if anim_data then
				if anim_data.tied or anim_data.hands_tied then
					return false
				end
			end
		
			if Network:is_server() and brain._logic_data then
				if (brain._logic_data.is_tied or brain._logic_data.is_converted and unit.is_converted) then
					return false
				end
			else
				if brain.converted and brain:converted() or brain.is_hostile and not brain:is_hostile() or brain.surrendered and brain:surrendered() then
					return false
				end
			end
			
			if not banlist[unit:base()._tweak_table] then
				return true
			end
		end
	end
end

local function aimbot_calculate_angle(unit, fov)
	if get_player() then
		local enemy = Vector3()
		local player = Vector3()
		local pre_dir = Vector3()
		
		if not aimbot_get_unit_pos(unit) then
			return
		end
		
		-- Set units vector
		mvector3.set(player, get_player():camera():position())
		mvector3.set(enemy, (fov and aimbot_get_unit_pos(unit) or unit_position))

		-- difference vector
		mvector3.set(pre_dir, player)
		mvector3.subtract(pre_dir, enemy)
		mvector3.normalize(pre_dir)
	 
		-- find direction
		local newx, newy, newz = pre_dir.x, pre_dir.y, pre_dir.z
		if player.x > enemy.x or (player.x < enemy.x and newx < 0) then newx = newx * -1 end
		if player.y > enemy.y or (player.y < enemy.y and newy < 0) then newy = newy * -1 end
		if player.z > enemy.z or (player.z < enemy.z and newz < 0) then newz = newz * -1 end
		mvector3.set(pre_dir, Vector3(newx, newy, newz))
		return pre_dir
	end
end

local function aimbot_check_fov(ray_hit)
	if get_player() then
		local dir = aimbot_calculate_angle(ray_hit, true)
		if not dir then 
			return false
		end
		local current = get_player():camera():forward()
		local distance = mvector3.distance(current, dir)
		local fov_math = (distance / 2 * 360)
		if crosshair_fire and (fov_math <= 360) or (fov_math <= fov_degree) then
			return true
		end
	end
end

local function aimbot_check_distance(ray_hit)
	if get_player() then
		local current = get_player():position()
		if not ray_hit and not ray_hit:position() then
			return false
		end
		local distance = mvector3.distance(current, ray_hit:position())
		if distance and (distance <= max_distance) then
			return true
		end
	end
end

local function aimbot_get_target(ray_hit)
	local best = nil
	if not (ray_hit) then
		return
	end

	local to = aimbot_calculate_angle(ray_hit)
	
	if not to then
		return
	end

	for key, unit in ipairs(World:find_units_quick("all", managers.slot:get_mask("enemies", "civilians", "sentry_gun"))) do
		if (ray_hit:key() == unit:key()) then
			if alive(ray_hit) then
				best = to
				break
			end
		end
	end
	return best
end

local function aimbot_get_tweak_unit(unit)
	if unit and unit:base() and unit:base()._tweak_table then
		local unit_name = tostring(unit:base()._tweak_table)
		local get_string = string.gsub(unit_name, "_", " ")
		return get_string
	end
	return ""
end

local function aimbot_get_unit_slots()
	local slots
	if shoot_civilians then
		slots = {"all", "civilians"}
	else
		slots = {"all"}
	end
	return slots
end

local function aimbot_exact_crosshair()
	local player = get_player()
	local look_ray = Vector3()
	mvector3.set(look_ray, player:camera():rotation():y())
	mvector3.multiply(look_ray, max_distance)
	mvector3.add(look_ray, player:camera():position())
	return look_ray
end

local function aimbot_check_crosshair_unit(r_unit)
	local ray = Utils:GetCrosshairRay(false, aimbot_exact_crosshair())
	if not ray then
		return
	end
	 
	local unit = ray.unit
	if unit then
		if tostring(unit:name()) == "Idstring(@IDc71d763cd8d33588@)" then --player sentry
			return
		elseif r_unit and r_unit:key() == unit:key() then
			return unit
		elseif turret_names[tostring(unit:name())] then
			return unit
		elseif shoot_through_shield and unit:in_slot(managers.slot:get_mask("enemy_shield_check")) then
			return unit
		elseif shoot_through_wall and unit:in_slot(managers.slot:get_mask("world_geometry", "vehicles")) then
			return unit
		elseif aimbot_is_hostage(unit) then
			return unit
		end
	end
end

local function aimbot_get_units(pthis)
	if get_player() then
		local ray = nil
		local all_units = {}
		local from = get_player():camera():position()
		
		if shoot_civilians then
			for k, v in pairs(managers.enemy:all_civilians()) do
				if aimbot_is_hostage(v.unit) and aimbot_check_distance(v.unit) and aimbot_check_fov(v.unit) then
					all_units[k] = v
				end
			end
		end
		
		if shoot_enemies then
			for k, v in pairs(managers.enemy:all_enemies()) do
				if aimbot_is_hostage(v.unit) and aimbot_check_distance(v.unit) and aimbot_check_fov(v.unit) then
					all_units[k] = v
				end
			end
		end
		
		if shoot_turrets then
			for k, v in pairs(World:find_units_quick("all", managers.slot:get_mask("sentry_gun"))) do
				if turret_names[tostring(v:name())] and aimbot_check_distance(v) then
					all_units[k] = v
				end
			end
		end
		
		for key, units in pairs(all_units) do
			local to = nil
			local ray_hits = {}
			local vec = Vector3()
			
			if crosshair_fire then
				if exact_crosshair then
					to = aimbot_exact_crosshair()
				else
					local ch_unit = type(units) ~= "table" and aimbot_check_crosshair_unit(units) or aimbot_check_crosshair_unit(units.unit)
					if ch_unit and not ch_unit:in_slot(managers.slot:get_mask("enemy_shield_check", "world_geometry", "vehicles"))then
						to = aimbot_get_unit_pos(ch_unit)
					else
						to = aimbot_exact_crosshair()
					end
				end
			elseif type(units) ~= "table" then
				mvector3.set(vec, units:position())
				mvector3.set(vec, Vector3(vec.x, vec.y, vec.z + 150))
				to = vec
			else
				to = aimbot_get_unit_pos(units.unit)
			end

			if not to then
				return
			end

			if crosshair_fire and not aimbot_check_crosshair_unit() then
				return
			end
			
			unit_position = to

			if table.contains(tweak_data.weapon[pthis._name_id].categories, "grenade_launcher") then 
				pthis._can_shoot_through_shield = true
			end
			
			if pthis._bullet_class.id == "explosive" or pthis._bullet_class.id == "dragons_breath" or pthis._bullet_class.id == "flame" then 
				pthis._can_shoot_through_shield = true
			end
			
			if shoot_through_wall then
				pthis._can_shoot_through_wall = true
				if ignore_wall_thickness then
					pthis._bullet_slotmask = World:make_slot_mask(7, 11, 12, 14, 16, 17, 18, 21, 22, 25, 26, 33, 34, 35)
					pthis.old_mask = pthis._bullet_slotmask
				end
			end
			
			if shoot_through_shield then
				pthis._can_shoot_through_shield = true
			end
			
			if shoot_through_enemies then
				pthis._can_shoot_through_enemy = true
			end
			
			if shoot_through_wall and pthis._can_shoot_through_wall then
				ray_hits = World:raycast_wall("ray", from, unit_position, "slot_mask", pthis._bullet_slotmask, "ignore_unit", pthis._setup.ignore_units, "thickness", wall_thickness, "thickness_mask", managers.slot:get_mask("world_geometry", "vehicles"))
			else
				ray_hits = World:raycast_all("ray", from, unit_position, "slot_mask", pthis._bullet_slotmask, "ignore_unit", pthis._setup.ignore_units, "slot_mask", managers.slot:get_mask(unpack(aimbot_get_unit_slots())))
			end

			for _, hit in ipairs(ray_hits) do
				if alive(hit.unit) then
					if not shoot_through_wall and (not string.match(aimbot_get_tweak_unit(hit.unit), "tank") or not string.match(aimbot_get_tweak_unit(hit.unit), "bulldozer")) then
						if not pthis._can_shoot_through_wall and hit.unit:in_slot(managers.slot:get_mask("world_geometry", "vehicles")) then 
							break
						elseif pthis._can_shoot_through_wall and hit.unit:in_slot(managers.slot:get_mask("world_geometry", "vehicles")) then
							break
						elseif not pthis._can_shoot_through_shield and string.match(aimbot_get_tweak_unit(hit.unit), "shield") or (alive(hit.unit:parent()) and hit.unit:parent():character_damage().is_immune_to_shield_knockback and hit.unit:parent():character_damage():is_immune_to_shield_knockback() ~= nil) then 
							break
						end
					end

					local t_units = aimbot_get_target(hit.unit)
					if crosshair_fire and unit_position == t_units or t_units then
						ray = t_units
						targeted_unit = hit.unit
						break
					end
				end
			end
		end
		return ray
	end
end


local function aimbot_instant_hit(dmg)
	if shoot_through_shield_damage and targeted_unit:in_slot(managers.slot:get_mask("enemy_shield_check")) then
		return shoot_through_shield_damage / 100
	elseif shoot_through_wall_damage and targeted_unit:in_slot(managers.slot:get_mask("world_geometry", "vehicles")) then
		return shoot_through_wall_damage / 100
	elseif custom_damage_by_unit and targeted_unit:base() and targeted_unit:base()._tweak_table and custom_damage_table[targeted_unit:base()._tweak_table] then
		return custom_damage_table[targeted_unit:base()._tweak_table] / 100
	elseif custom_damage then
		return custom_damage / 100
	end
	return dmg
end

if not rawget(_G, "aimbot") then
	rawset(_G, "aimbot", {})
	
	-- Auto aim update
	local old_enemy_update = EnemyManager.update
	function EnemyManager:update(t, dt)
		old_enemy_update(self, t, dt)
		
		if not active then 
			return
		end
		
		if not get_player() then
			return
		end
			
		local state = managers.player:get_current_state()
		
		if not state then 
			return
		end
		
		local wep_base = state._equipped_unit:base()
		
		if wep_base:get_ammo_total() <= 0 then
			return
		end
		
		if wep_base:get_ammo_remaining_in_clip() <= 1 then
			if auto_replenish_ammo then
				wep_base:replenish()
			elseif auto_reload then
				-- Press
				local input = state:_get_input(0, 0, false)
				input.btn_primary_attack_press = true
				input.btn_primary_attack_state = true
				state:_check_action_primary_attack(Application:time(), input)
			 
				-- Release
				input = state:_get_input(0, 0, false)
				input.btn_primary_attack_release = true
				state:_check_action_primary_attack(Application:time(), input)
			end
		end

		currect_shot_time = currect_shot_time + dt
		if auto_shoot and not aimbot_keypressed() and (currect_shot_time >= (direct_fire_delay or aimbot_rng_decimal(min_fire_delay, max_fire_delay, wep_base))) then 
			currect_shot_time = 0	
			
			-- See if we have a valid target to shoot at, if so then press the shoot button once
			dir = aimbot_get_units(wep_base)
			if not dir then 
				return 
			end
			
			if not silent_shooting then
				-- Press
				local input = state:_get_input(0, 0, false)
				input.btn_primary_attack_press = true
				input.btn_primary_attack_state = true
				state:_check_action_primary_attack(Application:time(), input)

				-- Release
				input = state:_get_input(0, 0, false)
				input.btn_primary_attack_release = true
				state:_check_action_primary_attack(Application:time(), input)
			elseif silent_shooting then
				local pl_cam_pos = get_player():camera():position()
				if wep_base._current_stats and wep_base._current_stats.damage then
					wep_base:trigger_held(pl_cam_pos, dir, aimbot_instant_hit(wep_base._current_stats and wep_base._current_stats.damage or 0), nil, 0, 0, 0)
					managers.hud:set_ammo_amount(wep_base:selection_index(), wep_base:ammo_info())
				end
			end
		end
	end

	local old_fire = NewRaycastWeaponBase.fire
	function NewRaycastWeaponBase.fire(self, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
		if not silent_shooting and dir and active and not aimbot_keypressed() and get_player() and self._setup.user_unit and (self._setup.user_unit == get_player()) then
			return old_fire(self, from_pos, dir, aimbot_instant_hit(dmg_mul), shoot_player, 0, autohit_mul, suppr_mul, target_unit)
		end
		return old_fire(self, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit) 
	end
end