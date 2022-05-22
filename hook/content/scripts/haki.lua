local function lobo(data)
	local unit = data.unit
	if unit and alive(unit) then
		local action_data = {
			damage = 0.1,
			attacker_unit = managers.player:player_unit(),
			attack_dir = Vector3(0,0,0),
			variant = "melee", 
			name_id = 'cqc',
			col_ray = {
				position = unit:position(),
				body = unit:body("body"),
			}
		}
		unit:character_damage():damage_melee(action_data)
		unit:network():send("damage_melee", action_data.attacker_unit, 0.1, nil, nil, nil, action_data.variant, true or false)
		if not alive(unit) then
			managers.network:session():send_to_peers_synched("remove_unit", unit)
		end
	end
end

for _,data in pairs(managers.enemy:all_enemies()) do
	lobo(data)
end
for _,data in pairs(managers.enemy:all_civilians()) do
	lobo(data)
end

if managers.mission then
	managers.mission._fading_debug_output:script().log('Haki ACTIVATED',  Color.green)
end