if not managers.mission or not PlayerDamage then
	return
end

if not rawget(_G, "dmg_reflect") then
	rawset(_G, "dmg_reflect", {
		["toggle_reflect"] = false,
		["reflection_damage"] =  20, 		--higher = higher unit dmg%
		["reflection_damage_special"] = 38,	--higher = higher unit dmg%
		["Haoshoku_Haki"] = false,			--dead with health
		["unit_reflection_damage"] = nil,
		["unit_table"] = {					--units affected
			"spooc",
			"taser",
			"shield",
			"tank",
			"tank_mini",
			"tank_medic",
			"tank_hw",
			"sniper",
			"gangster",
			"cop",
			"security",
			"medic",
			"gensec",
			"swat",
			"heavy_swat",
			"fbi",
			"fbi_swat",
			"fbi_heavy_swat",
			"cop_female",
			"city_swat",
			"mobster_boss",
			"mobster",
			"hector_boss",
			"hector_boss_no_armor",
			"biker_boss",
			"chavez_boss",
			"biker",
			"bolivians",
			"phalanx_vip",
			"phalanx_minion",
			"shadow_spooc",
			"drug_lord_boss",
			"drug_lord_boss_stealth",
			"drunk_pilot",
			"spa_vip",
			"spa_vip_hurt",
			"captain",
			"civilian_mariachi",
			"mute_security_undominatable",
			"security_undominatable",
			"escort",
			"escort_criminal",
			"escort_undercover"
		}
	})
	
	function dmg_reflect:message(msg, color)
		managers.mission._fading_debug_output:script().log(string.format("%s", msg), color)
	end
	
	function dmg_reflect:reflect(attack_data)
		local attacker_unit = attack_data.attacker_unit
		local attacker_unit_dmg = attack_data.damage
		if not (attacker_unit or alive(attacker_unit) or attacker_unit_dmg) then
			return
		end
		
		local unit_damage = attacker_unit:character_damage()
		local all_enemies = managers.enemy:all_enemies()
		for _,data in pairs(all_enemies) do
			local unit = data.unit
			if unit and alive(unit) and (attacker_unit == unit) then
				local enemy = unit:base()._tweak_table
				for k,v in pairs(self["unit_table"]) do
					if (v == enemy) then
						if tweak_data.character[enemy] and tweak_data.character[enemy].tags and tweak_data.character[enemy].tags[3] and (tweak_data.character[enemy].tags[3] == "special") then
							self["unit_reflection_damage"] = (attacker_unit_dmg * self["reflection_damage_special"]) / 100
						else
							self["unit_reflection_damage"] = (attacker_unit_dmg * self["reflection_damage"]) / 100
						end

						local action_data = {
							damage = dmg_reflect["unit_reflection_damage"],
							attacker_unit = managers.player:player_unit(),
							attack_dir = Vector3(0,0,0),
							variant = "melee", 
							name_id = 'cqc',
							col_ray = {
								position = unit:position(),
								body = unit:body("body"),
							}
						}
						unit_damage:damage_melee(action_data)
						
						if self["Haoshoku_Haki"] and not Network:is_server() then
							unit:network():send("damage_melee", action_data.attacker_unit, self["unit_reflection_damage"], nil, nil, nil, action_data.variant, true or false)
						end
						
						if not alive(attacker_unit) then
							managers.network:session():send_to_peers_synched("remove_unit", unit)
						end
						break
					end
				end
			end
		end
	end
	
	local orig_func_damage_bullet = PlayerDamage.damage_bullet
	function PlayerDamage.damage_bullet(self, attack_data)
		if dmg_reflect["toggle_reflect"] then	
			dmg_reflect:reflect(attack_data)
		end
		orig_func_damage_bullet(self, attack_data)
	end
	
	function dmg_reflect:toggle()
		if not dmg_reflect["toggle_reflect"] then
			self:message("Damage Reflection - ACTIVATED", Color('00FF00'))
		else
			self:message("Damage Reflection - DEACTIVATED", Color('FF4500'))
		end
		dmg_reflect["toggle_reflect"] = not dmg_reflect["toggle_reflect"]
	end
	
	dmg_reflect:toggle()
else
	dmg_reflect:toggle()
end