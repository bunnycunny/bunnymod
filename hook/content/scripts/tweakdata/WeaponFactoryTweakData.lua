--add lmg scope mods
local _initorig = WeaponFactoryTweakData._init_rpk
function WeaponFactoryTweakData:_init_rpk()
	_initorig(self)
	for _,part in ipairs(self.parts.wpn_fps_shot_r870_s_folding.forbids) do
		if ( part ~= "wpn_fps_upg_o_acog" and part ~= "wpn_fps_shot_r870_ris_special" ) then
			table.insert(self.wpn_fps_lmg_rpk.uses_parts, part)
		end
	end
end

local _initorig2 = WeaponFactoryTweakData._init_m249
function WeaponFactoryTweakData:_init_m249()
	_initorig2(self)
	for _,part in ipairs(self.parts.wpn_fps_shot_r870_s_folding.forbids) do
		if ( part ~= "wpn_fps_upg_o_acog" and part ~= "wpn_fps_shot_r870_ris_special" ) then
			table.insert(self.wpn_fps_lmg_m249.uses_parts, part)
		end
	end
end

local _initorig3 = WeaponFactoryTweakData._init_hk21
function WeaponFactoryTweakData:_init_hk21()
	_initorig3(self)
	for _,part in ipairs(self.parts.wpn_fps_shot_r870_s_folding.forbids) do
		if ( part ~= "wpn_fps_upg_o_acog" and part ~= "wpn_fps_shot_r870_ris_special" ) then
			table.insert(self.wpn_fps_lmg_hk21.uses_parts, part)
		end
	end
end

local _initorig4 = WeaponFactoryTweakData._init_mg42
function WeaponFactoryTweakData:_init_mg42()
	_initorig4(self)
	for _,part in ipairs(self.parts.wpn_fps_shot_r870_s_folding.forbids) do
		if ( part ~= "wpn_fps_upg_o_acog" and part ~= "wpn_fps_shot_r870_ris_special" ) then
			table.insert(self.wpn_fps_lmg_mg42.uses_parts, part)
		end
	end
end

local _initorig5 = WeaponFactoryTweakData._init_par
function WeaponFactoryTweakData:_init_par()
	_initorig5(self)
	for _,part in ipairs(self.parts.wpn_fps_shot_r870_s_folding.forbids) do
		if ( part ~= "wpn_fps_upg_o_acog" and part ~= "wpn_fps_shot_r870_ris_special" ) then
			table.insert(self.wpn_fps_lmg_par.uses_parts, part)
		end
	end
end

--all ammo and boosts to all weps
local orig_func_init = WeaponFactoryTweakData.create_bonuses
function WeaponFactoryTweakData:create_bonuses(tweak_data, ...)
	orig_func_init(self, tweak_data, ...)
	local wep_excluded_ammo = {
		["wpn_fps_bow_plainsrider"] = true,
		["wpn_fps_bow_hunter"] = true,
		["wpn_fps_bow_arblast"] = true,
		["wpn_fps_bow_frankish"] = true,
		["wpn_fps_bow_long"] = true,
		["wpn_fps_bow_ecp"] = true,
		["wpn_fps_bow_elastic"] = true
	}
	
	for _, data in pairs(tweak_data.upgrades.definitions) do
		local factory_id = data.factory_id
		if data.weapon_id and tweak_data.weapon[data.weapon_id] and factory_id and self[factory_id] and self[factory_id].uses_parts then
			if not wep_excluded_ammo[factory_id] then
				table.insert(self[factory_id].uses_parts, "wpn_fps_upg_a_slug")
				table.insert(self[factory_id .. "_npc"].uses_parts, "wpn_fps_upg_a_slug")
				table.insert(self[factory_id].uses_parts, "wpn_fps_upg_a_custom")
				table.insert(self[factory_id .. "_npc"].uses_parts, "wpn_fps_upg_a_custom")
				table.insert(self[factory_id].uses_parts, "wpn_fps_upg_a_explosive")
				table.insert(self[factory_id .. "_npc"].uses_parts, "wpn_fps_upg_a_explosive")
				table.insert(self[factory_id].uses_parts, "wpn_fps_upg_a_piercing")
				table.insert(self[factory_id .. "_npc"].uses_parts, "wpn_fps_upg_a_piercing")
				table.insert(self[factory_id].uses_parts, "wpn_fps_upg_a_dragons_breath")
				table.insert(self[factory_id .. "_npc"].uses_parts, "wpn_fps_upg_a_dragons_breath")
			end
		end
	end
end




