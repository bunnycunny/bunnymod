function can_interact()
	return true
end

local function interactbytweak(inter)
	for _, unit in pairs(managers.interaction._interactive_units) do
		if not alive(unit) then return end
		local interaction = unit:interaction()
		if (interaction.tweak_data == inter) and interaction._active then
			interaction.can_interact = can_interact
			interaction:interact(managers.player:player_unit())
			interaction.can_interact = nil
			break
		end
	end
end

local function convertallenem(ud)
	if Network:is_server() then
		managers.groupai:state():convert_hostage_to_criminal(ud.unit)
	else
		for i=1,6 do
			ud.unit:brain():on_intimidated(math.huge, managers.player:player_unit(), true)
			interactbytweak("hostage_trade")
			interactbytweak("hostage_convert")
			DelayedCalls:Add("convert_hostage_dc_id"..i, 1.2, function()
				if not alive(managers.player:player_unit()) then return end
				interactbytweak("hostage_convert")
			end)
			managers.network:session():send_to_host("long_dis_interaction", ud.unit, math.huge, managers.player:player_unit(), nil)
		end
	end
end

local function dmg_cam(unit)
	local body
	do
		local i = -1
		repeat
			i = i+1
			body = unit:body(i)
		until (body and body:extension()) or (i >= 5)
	end
	if not body then return end
	body:extension().damage:damage_melee(unit, nil, unit:position(), nil, 10000)
	managers.network:session():send_to_peers_synched("sync_body_damage_melee", body, unit, nil, unit:position(), nil, 10000)
end

if Network:is_server() then
	-- removes questionmark over ai
	function GroupAIStateBase:on_criminal_suspicion_progress(u_suspect, u_observer, status) end
	--destroy cameras to prevent alarm on stealth
	for _,unit in pairs(SecurityCamera.cameras) do
		pcall(dmg_cam,unit)
	end
	for _,ud in pairs(managers.enemy:all_enemies()) do
		if not ud.unit:brain()._logic_data.is_converted then
			convertallenem(ud)
		end
	end
else
	if not managers.groupai:state():whisper_mode() then
		for _,ud in pairs(managers.enemy:all_enemies()) do
			if ud.unit and not (ud.unit.brain and ud.unit:brain().is_hostage and ud.unit:brain():is_hostage()) then
				local action_data = {damage = 0.1, attacker_unit = managers.player:player_unit(), attack_dir = Vector3(0,0,0), name_id = 'cqc', armor_piercing = true, critical_hit = false, shield_knock = false, knock_down = false, stagger = false, col_ray = {position = ud.unit:position(), body = ud.unit:body("body")}}
				ud.unit:character_damage():damage_melee(action_data)
				convertallenem(ud)
			end
		end
	end
end
managers.mission._fading_debug_output:script().log('Convert - ACTIVATED',  Color.green)