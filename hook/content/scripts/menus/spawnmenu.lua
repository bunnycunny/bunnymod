function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end
if not is_playing() then 
	return 
end
function is_server() -- Is host check
	return Network.is_server(Network)
end
function unit_from_id(id)
	local unit = managers.network:session():peer(id):unit()
	if managers.network:session():peer(id) and alive(unit) then
		return unit
	end
end
function to_string( tbl )
	if "nil" == type( tbl ) then
		return tostring(nil)
	elseif "table" == type( tbl ) then
		return table_print(tbl)
	elseif "string" == type( tbl ) then
		return tbl
	else
		return tostring(tbl)
	end
end
function get_peers(code, unitcheck)
	local peerid = tonumber(code)
	local me = managers.network:session():local_peer():id()
	if not peerid or peerid and (peerid < 1 or peerid > 4) then
		local tab = {}
		for x = 1, 4 do
			if managers.network:session():peer(x) then
				if not (unitcheck or unitcheck and managers.network:session():peer(x):unit()) then
					table.insert(tab, x)
				end
			end
		end
		if code == "*" then -- everyone
			return tab
		elseif code == "?" then -- random
			peerid = tab[math.random(1, #tab)]
		elseif code == "!" then -- anyone except self
			table.remove(tab, me)
			--peerid = tab[math.random(1, #tab)]
			return tab
		else -- self
			peerid = me
		end

		tab = nil
	end
	if peerid and managers.network:session():peer(peerid) then
		if not unitcheck or (unitcheck and managers.network:session():peer(peerid):unit()) then
			return {peerid}
		end
	end
end
function unit_on_map(unit_name)
	local id = Idstring(unit_name)
	for _,x in pairs(PackageManager:all_loaded_unit_data()) do
		if x:name() == id then
			return true
		end
	end
end
function parse_unit_name( unit_name )
	local _,_,_,name = string.find(unit_name, "(.+)/(.+)$")
	return string.gsub(name, "_", " ")
end
function ray_pos()
	local unit = managers.player._players[1]
	if (alive(unit)) then
		local crosshairRay = Utils:GetCrosshairRay()
		if not crosshairRay then
			return
		end
		return crosshairRay.position
	end
end

function load_table()
	all_units = {
		all_civs = {
			"units/payday2/characters/civ_female_bank_1/civ_female_bank_1",
			"units/payday2/characters/civ_female_bank_manager_1/civ_female_bank_manager_1",
			"units/payday2/characters/civ_female_bikini_1/civ_female_bikini_1",
			"units/payday2/characters/civ_female_bikini_2/civ_female_bikini_2",
			"units/payday2/characters/civ_female_casual_1/civ_female_casual_1",
			"units/payday2/characters/civ_female_casual_10/civ_female_casual_10",
			"units/payday2/characters/civ_female_casual_2/civ_female_casual_2",
			"units/payday2/characters/civ_female_casual_3/civ_female_casual_3",
			"units/payday2/characters/civ_female_casual_4/civ_female_casual_4",
			"units/payday2/characters/civ_female_casual_5/civ_female_casual_5",
			"units/payday2/characters/civ_female_casual_6/civ_female_casual_6",
			"units/payday2/characters/civ_female_casual_7/civ_female_casual_7",
			"units/payday2/characters/civ_female_casual_8/civ_female_casual_8",
			"units/payday2/characters/civ_female_casual_9/civ_female_casual_9",
			"units/payday2/characters/civ_female_crackwhore_1/civ_female_crackwhore_1",
			"units/payday2/characters/civ_female_curator_1/civ_female_curator_1",
			"units/payday2/characters/civ_female_curator_2/civ_female_curator_2",
			"units/payday2/characters/civ_female_hostess_apron_1/civ_female_hostess_apron_1",
			"units/payday2/characters/civ_female_hostess_jacket_1/civ_female_hostess_jacket_1",
			"units/payday2/characters/civ_female_hostess_shirt_1/civ_female_hostess_shirt_1",
			"units/payday2/characters/civ_female_party_1/civ_female_party_1",
			"units/payday2/characters/civ_female_party_2/civ_female_party_2",
			"units/payday2/characters/civ_female_party_3/civ_female_party_3",
			"units/payday2/characters/civ_female_party_4/civ_female_party_4",
			"units/payday2/characters/civ_female_waitress_1/civ_female_waitress_1",
			"units/payday2/characters/civ_female_waitress_2/civ_female_waitress_2",
			"units/payday2/characters/civ_female_waitress_3/civ_female_waitress_3",
			"units/payday2/characters/civ_female_waitress_4/civ_female_waitress_4",
			"units/payday2/characters/civ_female_wife_trophy_1/civ_female_wife_trophy_1",
			"units/payday2/characters/civ_female_wife_trophy_2/civ_female_wife_trophy_2",
			"units/payday2/characters/civ_male_bank_1/civ_male_bank_1",
			"units/payday2/characters/civ_male_bank_2/civ_male_bank_2",
			"units/payday2/characters/civ_male_bank_manager_1/civ_male_bank_manager_1",
			"units/payday2/characters/civ_male_bank_manager_3/civ_male_bank_manager_3",
			"units/payday2/characters/civ_male_bank_manager_4/civ_male_bank_manager_4",
			"units/payday2/characters/civ_male_bank_manager_5/civ_male_bank_manager_5",
			"units/payday2/characters/civ_male_bartender_1/civ_male_bartender_1",
			"units/payday2/characters/civ_male_bartender_2/civ_male_bartender_2",
			"units/payday2/characters/civ_male_business_1/civ_male_business_1",
			"units/payday2/characters/civ_male_business_2/civ_male_business_2",
			"units/payday2/characters/civ_male_casual_1/civ_male_casual_1",
			"units/payday2/characters/civ_male_casual_12/civ_male_casual_12",
			"units/payday2/characters/civ_male_casual_13/civ_male_casual_13",
			"units/payday2/characters/civ_male_casual_14/civ_male_casual_14",
			"units/payday2/characters/civ_male_casual_2/civ_male_casual_2",
			"units/payday2/characters/civ_male_casual_3/civ_male_casual_3",
			"units/payday2/characters/civ_male_casual_4/civ_male_casual_4",
			"units/payday2/characters/civ_male_casual_5/civ_male_casual_5",
			"units/payday2/characters/civ_male_casual_6/civ_male_casual_6",
			"units/payday2/characters/civ_male_casual_7/civ_male_casual_7",
			"units/payday2/characters/civ_male_casual_8/civ_male_casual_8",
			"units/payday2/characters/civ_male_casual_9/civ_male_casual_9",
			"units/payday2/characters/civ_male_curator_1/civ_male_curator_1",
			"units/payday2/characters/civ_male_curator_2/civ_male_curator_2",
			"units/payday2/characters/civ_male_curator_3/civ_male_curator_3",
			"units/payday2/characters/civ_male_dj_1/civ_male_dj_1",
			"units/payday2/characters/civ_male_dog_abuser_1/civ_male_dog_abuser_1",
			"units/payday2/characters/civ_male_dog_abuser_2/civ_male_dog_abuser_2",
			"units/payday2/characters/civ_male_italian_robe_1/civ_male_italian_robe_1",
			"units/payday2/characters/civ_male_janitor_1/civ_male_janitor_1",
			"units/payday2/characters/civ_male_janitor_2/civ_male_janitor_2",
			"units/payday2/characters/civ_male_janitor_3/civ_male_janitor_3",
			"units/payday2/characters/civ_male_meth_cook_1/civ_male_meth_cook_1",
			"units/payday2/characters/civ_male_miami_store_clerk_1/civ_male_miami_store_clerk_1",
			"units/payday2/characters/civ_male_party_1/civ_male_party_1",
			"units/payday2/characters/civ_male_party_2/civ_male_party_2",
			"units/payday2/characters/civ_male_party_3/civ_male_party_3",
			"units/payday2/characters/civ_male_pilot_1/civ_male_pilot_1",
			"units/payday2/characters/civ_male_scientist_1/civ_male_scientist_1",
			"units/payday2/characters/civ_male_taxman/civ_male_taxman",
			"units/payday2/characters/civ_male_taxman/civ_male_taxman_civ",
			"units/payday2/characters/civ_male_trucker_1/civ_male_trucker_1",
			"units/payday2/characters/civ_male_worker_1/civ_male_worker_1",
			"units/payday2/characters/civ_male_worker_2/civ_male_worker_2",
			"units/payday2/characters/civ_male_worker_3/civ_male_worker_3",
			"units/payday2/characters/civ_male_worker_docks_1/civ_male_worker_docks_1",
			"units/payday2/characters/civ_male_worker_docks_2/civ_male_worker_docks_2",
			"units/payday2/characters/civ_male_worker_docks_3/civ_male_worker_docks_3",
			"units/pd2_dlc1/characters/civ_male_bank_manager_2/civ_male_bank_manager_2",
			"units/pd2_dlc1/characters/civ_male_casual_10/civ_male_casual_10",
			"units/pd2_dlc1/characters/civ_male_casual_11/civ_male_casual_11",
			"units/pd2_dlc1/characters/civ_male_firefighter_1/civ_male_firefighter_1",
			"units/pd2_dlc1/characters/civ_male_paramedic_1/civ_male_paramedic_1",
			"units/pd2_dlc1/characters/civ_male_paramedic_2/civ_male_paramedic_2",
			"units/pd2_dlc2/characters/civ_female_bank_assistant_1/civ_female_bank_assistant_1",
			"units/pd2_dlc2/characters/civ_female_bank_assistant_2/civ_female_bank_assistant_2",
			"units/pd2_dlc_arena/characters/civ_female_fastfood_1/civ_female_fastfood_1",
			"units/pd2_dlc_arena/characters/civ_female_party_alesso_1/civ_female_party_alesso_1",
			"units/pd2_dlc_arena/characters/civ_female_party_alesso_2/civ_female_party_alesso_2",
			"units/pd2_dlc_arena/characters/civ_female_party_alesso_3/civ_female_party_alesso_3",
			"units/pd2_dlc_arena/characters/civ_female_party_alesso_4/civ_female_party_alesso_4",
			"units/pd2_dlc_arena/characters/civ_female_party_alesso_5/civ_female_party_alesso_5",
			"units/pd2_dlc_arena/characters/civ_female_party_alesso_6/civ_female_party_alesso_6",
			"units/pd2_dlc_arena/characters/civ_male_alesso_booth/civ_male_alesso_booth",
			"units/pd2_dlc_arena/characters/civ_male_fastfood_1/civ_male_fastfood_1",
			"units/pd2_dlc_arena/characters/civ_male_fastfood_2/civ_male_fastfood_2",
			"units/pd2_dlc_arena/characters/civ_male_party_alesso_1/civ_male_party_alesso_1",
			"units/pd2_dlc_arena/characters/civ_male_party_alesso_2/civ_male_party_alesso_2",
			"units/pd2_dlc_born/characters/civ_male_scientist_01/civ_male_scientist_01",
			"units/pd2_dlc_born/characters/civ_male_scientist_02/civ_male_scientist_02",
			"units/pd2_dlc_cage/characters/civ_female_bank_2/civ_female_bank_2",
			"units/pd2_dlc_cane/characters/civ_male_helper_1/civ_male_helper_1",
			"units/pd2_dlc_cane/characters/civ_male_helper_2/civ_male_helper_2",
			"units/pd2_dlc_cane/characters/civ_male_helper_3/civ_male_helper_3",
			"units/pd2_dlc_cane/characters/civ_male_helper_4/civ_male_helper_4",
			"units/pd2_dlc_casino/characters/civ_female_casino_1/civ_female_casino_1",
			"units/pd2_dlc_casino/characters/civ_female_casino_2/civ_female_casino_2",
			"units/pd2_dlc_casino/characters/civ_female_casino_3/civ_female_casino_3",
			"units/pd2_dlc_casino/characters/civ_male_business_casino_1/civ_male_business_casino_1",
			"units/pd2_dlc_casino/characters/civ_male_business_casino_2/civ_male_business_casino_2",
			"units/pd2_dlc_casino/characters/civ_male_casino_1/civ_male_casino_1",
			"units/pd2_dlc_casino/characters/civ_male_casino_2/civ_male_casino_2",
			"units/pd2_dlc_casino/characters/civ_male_casino_3/civ_male_casino_3",
			"units/pd2_dlc_casino/characters/civ_male_casino_4/civ_male_casino_4",
			"units/pd2_dlc_casino/characters/civ_male_casino_pitboss/civ_male_casino_pitboss",
			"units/pd2_dlc_casino/characters/civ_male_impersonator/civ_male_impersonator",
			"units/pd2_dlc_dinner/characters/civ_male_butcher_1/civ_male_butcher_1",
			"units/pd2_dlc_dinner/characters/civ_male_butcher_2/civ_male_butcher_2",
			"units/pd2_dlc_holly/characters/civ_male_hobo_1/civ_male_hobo_1",
			"units/pd2_dlc_holly/characters/civ_male_hobo_2/civ_male_hobo_2",
			"units/pd2_dlc_holly/characters/civ_male_hobo_3/civ_male_hobo_3",
			"units/pd2_dlc_holly/characters/civ_male_hobo_4/civ_male_hobo_4",
			"units/pd2_dlc_lxy/characters/civ_female_guest_gala_1/civ_female_guest_gala_1",
			"units/pd2_dlc_lxy/characters/civ_female_guest_gala_2/civ_female_guest_gala_2",
			"units/pd2_dlc_lxy/characters/civ_male_camera_crew_1/civ_male_camera_crew_1",
			"units/pd2_dlc_lxy/characters/civ_male_guest_gala_1/civ_male_guest_gala_1",
			"units/pd2_dlc_lxy/characters/civ_male_guest_gala_2/civ_male_guest_gala_2",
			"units/pd2_dlc_mad/characters/civ_male_scientist_01/civ_male_scientist_01",
			"units/pd2_dlc_mad/characters/civ_male_scientist_02/civ_male_scientist_02",
			"units/pd2_dlc_moon/characters/civ_male_pilot_2/civ_male_pilot_2",
			"units/pd2_dlc_pal/characters/civ_male_mitch/civ_male_mitch",
			"units/pd2_dlc_peta/characters/civ_male_boris/civ_male_boris",
			"units/pd2_dlc_red/characters/civ_female_inside_man_1/civ_female_inside_man_1",
			"units/pd2_dlc_rvd/characters/ene_female_civ_undercover/ene_female_civ_undercover",
			"units/pd2_rain_1/characters/civ_male_escort_prisoner/civ_male_escort_prisoner",
			"units/payday2/characters/npc_getaway_driver_1/npc_getaway_driver_1",
			"units/payday2/characters/npc_old_hoxton_prisonsuit_1/npc_old_hoxton_prisonsuit_1",
			"units/payday2/characters/npc_old_hoxton_prisonsuit_2/npc_old_hoxton_prisonsuit_2",
			"units/pd2_dlc_berry/characters/npc_locke/npc_locke",
			"units/pd2_dlc_born/characters/npc_male_mechanic/npc_male_mechanic",
			"units/pd2_dlc_dah/characters/npc_male_cfo/npc_male_cfo",
			"units/pd2_dlc_dah/characters/npc_male_ralph/npc_male_ralph",
			"units/pd2_dlc_flat/characters/npc_chavez/npc_chavez",
			"units/pd2_dlc_flat/characters/npc_jamaican/npc_jamaican",
			"units/pd2_dlc_glace/characters/npc_chinese_prisoner/npc_chinese_prisoner",
			"units/pd2_dlc_glace/characters/npc_prisoner_1/npc_prisoner_1",
			"units/pd2_dlc_glace/characters/npc_prisoner_2/npc_prisoner_2",
			"units/pd2_dlc_glace/characters/npc_prisoner_3/npc_prisoner_3",
			"units/pd2_dlc_glace/characters/npc_prisoner_4/npc_prisoner_4",
			"units/pd2_dlc_glace/characters/npc_prisoner_5/npc_prisoner_4",
			"units/pd2_dlc_glace/characters/npc_prisoner_6/npc_prisoner_6",
			"units/pd2_dlc_glace/characters/npc_yakuza_prisoner/npc_yakuza_prisoner",
			"units/pd2_dlc_run/characters/npc_matt/npc_matt",
			"units/pd2_dlc_rvd/characters/npc_cop/npc_cop",
			"units/pd2_dlc_rvd/characters/npc_cop_01/npc_cop_01",
			"units/pd2_dlc_rvd/characters/npc_mr_blonde/npc_mr_blonde",
			"units/pd2_dlc_rvd/characters/npc_mr_brown/npc_mr_brown",
			"units/pd2_dlc_rvd/characters/npc_mr_orange/npc_mr_orange",
			"units/pd2_dlc_rvd/characters/npc_mr_pink/npc_mr_pink",
			"units/pd2_dlc_rvd/characters/npc_mr_pink_escort/npc_mr_pink_escort",
			"units/pd2_dlc_slu/characters/npc_sophia/npc_sophia",
			"units/pd2_dlc_slu/characters/npc_vlad/npc_vlad",
			"units/pd2_dlc_spa/characters/npc_gage/npc_gage",
			"units/pd2_dlc_spa/characters/npc_spa/npc_spa",
			"units/pd2_dlc_spa/characters/npc_spa_2/npc_spa_2",
			"units/pd2_dlc_spa/characters/npc_spa_3/npc_spa_3",
		},
		all_swats	=	{	
			"units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1",
			"units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2",
			"units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3",
			"units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4",
			"units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36",
			"units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870",
			"units/payday2/characters/ene_city_shield/ene_city_shield",
			"units/payday2/characters/ene_city_swat_1/ene_city_swat_1",
			"units/payday2/characters/ene_city_swat_2/ene_city_swat_2",
			"units/payday2/characters/ene_city_swat_3/ene_city_swat_3",
			"units/payday2/characters/ene_city_swat_4/ene_city_swat_4",
			"units/payday2/characters/ene_city_swat_r870/ene_city_swat_r870",
			"units/payday2/characters/ene_gensec_heavygunner/ene_gensec_heavygunner",
			"units/payday2/characters/ene_gensec_heavygunner2/ene_gensec_heavygunner2",
			"units/payday2/characters/ene_gensec_sgt/ene_gensec_sgt",
			"units/payday2/characters/ene_groundsniper_1/ene_groundsniper_1",
			"units/payday2/characters/ene_groundsniper_2/ene_groundsniper_2",
			"units/payday2/characters/ene_heavymedic_1/ene_heavymedic_1",
			"units/payday2/characters/ene_hvyspooc_1/ene_hvyspooc_1",
			"units/payday2/characters/ene_medic_m4/ene_medic_m4",
			"units/payday2/characters/ene_medic_r870/ene_medic_r870",
			"units/payday2/characters/ene_police_heavygunner/ene_police_heavygunner",
			"units/payday2/characters/ene_shield_1/ene_shield_1",
			"units/payday2/characters/ene_shield_2/ene_shield_2",
			"units/payday2/characters/ene_sniper_1/ene_sniper_1",
			"units/payday2/characters/ene_sniper_2/ene_sniper_2",
			"units/payday2/characters/ene_spook_1/ene_spook_1",
			"units/pd2_dlc_uno/characters/ene_shadow_cloaker_1/ene_shadow_cloaker_1",
			"units/pd2_dlc_uno/characters/ene_shadow_cloaker_2/ene_shadow_cloaker_2",
			"units/payday2/characters/ene_swat_1/ene_swat_1",
			"units/payday2/characters/ene_swat_2/ene_swat_2",
			"units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1",
			"units/payday2/characters/ene_swat_heavy_r870/ene_swat_heavy_r870",
			"units/payday2/characters/ene_tazer_1/ene_tazer_1",
			"units/payday2/characters/ene_tazer_2/ene_tazer_2",
			"units/pd2_dlc_arena/characters/ene_guard_security_heavy_1/ene_guard_security_heavy_1",
			"units/pd2_dlc_arena/characters/ene_guard_security_heavy_2/ene_guard_security_heavy_2",
			"units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic",
			"units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun",
			"units/pd2_dlc_drm/characters/ene_zeal_swat_heavy_sniper/ene_zeal_swat_heavy_sniper",
			"units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer",
			"units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2",
			"units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3",
			"units/pd2_dlc_gitgud/characters/ene_zeal_cloaker/ene_zeal_cloaker",
			"units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat",
			"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy",
			"units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield/ene_zeal_swat_shield",
			"units/pd2_dlc_help/characters/ene_zeal_bulldozer_halloween/ene_zeal_bulldozer_halloween",
			"units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1",
			"units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2",
			"units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3",
			"units/pd2_dlc_hvh/characters/ene_medic_hvh_m4/ene_medic_hvh_m4",
			"units/pd2_dlc_hvh/characters/ene_medic_hvh_r870/ene_medic_hvh_r870",
			"units/pd2_dlc_hvh/characters/ene_shield_hvh_1/ene_shield_hvh_1",
			"units/pd2_dlc_hvh/characters/ene_shield_hvh_2/ene_shield_hvh_2",
			"units/pd2_dlc_hvh/characters/ene_sniper_hvh_2/ene_sniper_hvh_2",
			"units/pd2_dlc_hvh/characters/ene_spook_hvh_1/ene_spook_hvh_1",
			"units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_1/ene_swat_heavy_hvh_1",
			"units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_r870/ene_swat_heavy_hvh_r870",
			"units/pd2_dlc_hvh/characters/ene_swat_hvh_1/ene_swat_hvh_1",
			"units/pd2_dlc_hvh/characters/ene_swat_hvh_2/ene_swat_hvh_2",
			"units/pd2_dlc_hvh/characters/ene_tazer_hvh_1/ene_tazer_hvh_1",
			"units/pd2_dlc_mad/characters/ene_akan_cs_heavy_ak47_ass/ene_akan_cs_heavy_ak47_ass",
			"units/pd2_dlc_mad/characters/ene_akan_cs_heavy_r870/ene_akan_cs_heavy_r870",
			"units/pd2_dlc_mad/characters/ene_akan_cs_shield_c45/ene_akan_cs_shield_c45",
			"units/pd2_dlc_mad/characters/ene_akan_cs_swat_ak47_ass/ene_akan_cs_swat_ak47_ass",
			"units/pd2_dlc_mad/characters/ene_akan_cs_swat_r870/ene_akan_cs_swat_r870",
			"units/pd2_dlc_mad/characters/ene_akan_cs_swat_sniper_svd_snp/ene_akan_cs_swat_sniper_svd_snp",
			"units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass",
			"units/pd2_dlc_spa/characters/ene_sniper_3/ene_sniper_3",
			"units/pd2_dlc_bph/characters/ene_murkywater_cloaker/ene_murkywater_cloaker", --new
			"units/pd2_dlc_mad/characters/ene_acc_bulldozer_back_akan_1/ene_acc_bulldozer_back_akan_1", --new
			"units/pd2_dlc_mad/characters/ene_acc_bulldozer_chest_akan_1/ene_acc_bulldozer_chest_akan_1",
			"units/pd2_dlc_mad/characters/ene_acc_bulldozer_helmet_plate_akan_1/ene_acc_bulldozer_helmet_plate_akan_1",
			"units/pd2_dlc_mad/characters/ene_acc_bulldozer_neck_akan_1/ene_acc_bulldozer_neck_akan_1",
			"units/pd2_dlc_mad/characters/ene_acc_bulldozer_stomache_akan_1/ene_acc_bulldozer_stomache_akan_1",
			"units/pd2_dlc_mad/characters/ene_acc_bulldozer_throat_akan_1/ene_acc_bulldozer_throat_akan_1",
			"units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic",
			"units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1",
			"units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2",
			"units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3",
			"units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4",
			"units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_medic/ene_murkywater_bulldozer_medic",
			"units/pd2_dlc_mad/characters/ene_acc_shield_akan/ene_acc_shield_akan",
			"units/pd2_dlc_mad/characters/ene_akan_cs_shield_c45/ene_akan_cs_shield_c45",
			"units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield",
			"units/payday2/characters/ene_sm_shield/ene_sm_shield",
			"units/pd2_dlc_bph/characters/ene_murkywater_tazer/ene_murkywater_tazer",
			"units/pd2_dlc_gitgud/characters/ene_zeal_tazer/ene_zeal_tazer",
			"units/pd2_dlc_mad/characters/ene_akan_medic_ak47_ass/ene_akan_medic_ak47_ass",
			"units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic",
		},
		all_fbi		=	{	
			"units/payday2/characters/ene_fbi_1/ene_fbi_1",
			"units/payday2/characters/ene_fbi_2/ene_fbi_2",
			"units/payday2/characters/ene_fbi_3/ene_fbi_3",
			"units/payday2/characters/ene_fbi_4/ene_fbi_4",
			"units/payday2/characters/ene_fbi_5/ene_fbi_5",
			"units/payday2/characters/ene_fbi_boss_1/ene_fbi_boss_1",
			"units/payday2/characters/ene_fbi_female_1/ene_fbi_female_1",
			"units/payday2/characters/ene_fbi_female_2/ene_fbi_female_2",
			"units/payday2/characters/ene_fbi_female_3/ene_fbi_female_3",
			"units/payday2/characters/ene_fbi_female_4/ene_fbi_female_4",
			"units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1",
			"units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870",
			"units/payday2/characters/ene_fbi_office_1/ene_fbi_office_1",
			"units/payday2/characters/ene_fbi_office_2/ene_fbi_office_2",
			"units/payday2/characters/ene_fbi_office_3/ene_fbi_office_3",
			"units/payday2/characters/ene_fbi_office_4/ene_fbi_office_4",
			"units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1",
			"units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2",
			"units/payday2/characters/ene_secret_service_1/ene_secret_service_1",
			"units/payday2/characters/ene_secret_service_2/ene_secret_service_2",
			"units/payday2/characters/ene_security_1/ene_security_1",
			"units/payday2/characters/ene_security_2/ene_security_2",
			"units/payday2/characters/ene_security_3/ene_security_3",
			"units/payday2/characters/ene_security_4/ene_security_4",
			"units/payday2/characters/ene_security_5/ene_security_5",
			"units/payday2/characters/ene_security_6/ene_security_6",
			"units/payday2/characters/ene_security_7/ene_security_7",
			"units/payday2/characters/ene_security_8/ene_security_8",
			"units/pd2_dlc_casino/characters/ene_secret_service_1_casino/ene_secret_service_1_casino",
			"units/pd2_dlc_friend/characters/ene_security_manager/ene_security_manager",
			"units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1",
			"units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870",
			"units/pd2_dlc_hvh/characters/ene_fbi_hvh_1/ene_fbi_hvh_1",
			"units/pd2_dlc_hvh/characters/ene_fbi_hvh_2/ene_fbi_hvh_2",
			"units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3",
			"units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1",
			"units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2",
			"units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36",
			"units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870/ene_akan_fbi_heavy_r870",
			"units/pd2_dlc_mad/characters/ene_akan_fbi_shield_dw_sr2_smg/ene_akan_fbi_shield_dw_sr2_smg",
			"units/pd2_dlc_mad/characters/ene_akan_fbi_shield_sr2_smg/ene_akan_fbi_shield_sr2_smg",
			"units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg",
			"units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass",
			"units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass",
			"units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_r870/ene_akan_fbi_swat_dw_r870",
			"units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870",
			"units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870",
			"units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg",
			"units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga",
			"units/pd2_dlc_mad/characters/ene_akan_medic_m4/ene_akan_medic_m4",
			"units/pd2_dlc_mad/characters/ene_akan_medic_r870/ene_akan_medic_r870",
			"units/payday2/characters/ene_vip_1/ene_vip_1",
			"units/pd2_dlc_vip/characters/ene_vip_1/ene_vip_1",
			"units/payday2/characters/ene_phalanx_1/ene_phalanx_1",
			"units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1",
			"units/pd2_dlc_wwh/characters/ene_captain/ene_captain",
		},
		all_cops		=	{	
			"units/payday2/characters/ene_cop_1/ene_cop_1",
			"units/payday2/characters/ene_cop_2/ene_cop_2",
			"units/payday2/characters/ene_cop_3/ene_cop_3",
			"units/payday2/characters/ene_cop_4/ene_cop_4",
			"units/payday2/characters/ene_guard_national_1/ene_guard_national_1",
			"units/payday2/characters/ene_hoxton_breakout_guard_1/ene_hoxton_breakout_guard_1",
			"units/payday2/characters/ene_hoxton_breakout_guard_2/ene_hoxton_breakout_guard_2",
			"units/payday2/characters/ene_murkywater_1/ene_murkywater_1",
			"units/payday2/characters/ene_murkywater_2/ene_murkywater_2",
			"units/payday2/characters/ene_prisonguard_female_1/ene_prisonguard_female_1",
			"units/payday2/characters/ene_prisonguard_male_1/ene_prisonguard_male_1",
			"units/payday2/characters/ene_veteran_cop_1/ene_veteran_cop_1",
			"units/pd2_dlc1/characters/ene_security_gensec_1/ene_security_gensec_1",
			"units/pd2_dlc1/characters/ene_security_gensec_2/ene_security_gensec_2",
			"units/pd2_dlc_berry/characters/ene_murkywater_no_light/ene_murkywater_no_light",
			"units/pd2_dlc_hvh/characters/ene_cop_hvh_1/ene_cop_hvh_1",
			"units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2",
			"units/pd2_dlc_hvh/characters/ene_cop_hvh_3/ene_cop_hvh_3",
			"units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4",
			"units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass",
			"units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg",
			"units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg",
			"units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870",
			"units/pd2_dlc_rvd/characters/ene_la_cop_1/ene_la_cop_1",
			"units/pd2_dlc_rvd/characters/ene_la_cop_2/ene_la_cop_2",
			"units/pd2_dlc_rvd/characters/ene_la_cop_3/ene_la_cop_3",
			"units/pd2_dlc_rvd/characters/ene_la_cop_4/ene_la_cop_4",
			"units/pd2_mcmansion/characters/ene_hoxton_breakout_guard_1/ene_hoxton_breakout_guard_1",
			"units/pd2_mcmansion/characters/ene_hoxton_breakout_guard_2/ene_hoxton_breakout_guard_2",
			"units/payday2/characters/ene_male_tgt_1/ene_male_tgt_1",
		},
		all_gangs	=	{	
			"units/payday2/characters/ene_biker_1/ene_biker_1",
			"units/payday2/characters/ene_biker_2/ene_biker_2",
			"units/payday2/characters/ene_biker_3/ene_biker_3",
			"units/payday2/characters/ene_biker_4/ene_biker_4",
			"units/payday2/characters/ene_biker_escape/ene_biker_escape",
			"units/payday2/characters/ene_gang_black_1/ene_gang_black_1",
			"units/payday2/characters/ene_gang_black_2/ene_gang_black_2",
			"units/payday2/characters/ene_gang_black_3/ene_gang_black_3",
			"units/payday2/characters/ene_gang_black_4/ene_gang_black_4",
			"units/payday2/characters/ene_gang_mexican_1/ene_gang_mexican_1",
			"units/payday2/characters/ene_gang_mexican_2/ene_gang_mexican_2",
			"units/payday2/characters/ene_gang_mexican_3/ene_gang_mexican_3",
			"units/payday2/characters/ene_gang_mexican_4/ene_gang_mexican_4",
			"units/payday2/characters/ene_gang_mobster_1/ene_gang_mobster_1",
			"units/payday2/characters/ene_gang_mobster_2/ene_gang_mobster_2",
			"units/payday2/characters/ene_gang_mobster_3/ene_gang_mobster_3",
			"units/payday2/characters/ene_gang_mobster_4/ene_gang_mobster_4",
			"units/payday2/characters/ene_gang_mobster_boss/ene_gang_mobster_boss",
			"units/payday2/characters/ene_gang_russian_1/ene_gang_russian_1",
			"units/payday2/characters/ene_gang_russian_2/ene_gang_russian_2",
			"units/payday2/characters/ene_gang_russian_3/ene_gang_russian_3",
			"units/payday2/characters/ene_gang_russian_4/ene_gang_russian_4",
			"units/payday2/characters/ene_gang_russian_5/ene_gang_russian_5",
			"units/pd2_dlc_born/characters/ene_biker_female_1/ene_biker_female_1",
			"units/pd2_dlc_born/characters/ene_biker_female_2/ene_biker_female_2",
			"units/pd2_dlc_born/characters/ene_biker_female_3/ene_biker_female_3",
			"units/pd2_dlc_born/characters/ene_gang_biker_boss/ene_gang_biker_boss",
			"units/pd2_dlc_friend/characters/ene_bolivian_thug_outdoor_01/ene_bolivian_thug_outdoor_01",
			"units/pd2_dlc_friend/characters/ene_bolivian_thug_outdoor_02/ene_bolivian_thug_outdoor_02",
			"units/pd2_dlc_friend/characters/ene_drug_lord_boss/ene_drug_lord_boss",
			"units/pd2_dlc_friend/characters/ene_thug_indoor_01/ene_thug_indoor_01",
			"units/pd2_dlc_friend/characters/ene_thug_indoor_02/ene_thug_indoor_02",
			"units/pd2_dlc_holly/characters/ene_gang_hispanic_1/ene_gang_hispanic_1",
			"units/pd2_dlc_holly/characters/ene_gang_hispanic_2/ene_gang_hispanic_2",
			"units/pd2_dlc_holly/characters/ene_gang_hispanic_3/ene_gang_hispanic_3",
			"units/pd2_dlc_wwh/characters/ene_female_crew/ene_female_crew",
			"units/pd2_dlc_wwh/characters/ene_male_crew_01/ene_male_crew_01",
			"units/pd2_dlc_wwh/characters/ene_male_crew_02/ene_male_crew_02",
			"units/pd2_mcmansion/characters/ene_male_hector_1/ene_male_hector_1",
			"units/pd2_mcmansion/characters/ene_male_hector_2/ene_male_hector_2",
			"units/payday2/characters/ene_fisher_1/ene_fisher_1",
			"units/pd2_dlc_wwh/characters/ene_locke/ene_locke",
		},
	}
	car_names = { 
		"units/payday2/vehicles/str_vehicle_car_police_washington/str_vehicle_car_police_washington",
		"units/payday2/vehicles/str_vehicle_car_taxi/str_vehicle_car_taxi", 
		"units/payday2/vehicles/str_vehicle_suburban_fbi/str_vehicle_suburban_fbi",
		"units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport", 
		"units/payday2/vehicles/str_vehicle_van_player/str_vehicle_van_player",
		"units/pd2_dlc_peta/vehicles/anim_vehicle_truck_semi/anim_vehicle_truck_semi",
		"units/pd2_dlc_jerry/vehicles/fps_vehicle_boat_rib_1/fps_vehicle_boat_rib_1",
		"units/pd2_dlc_jolly/vehicles/fps_vehicle_box_truck_1/fps_vehicle_box_truck_1",
		"units/pd2_dlc_born/vehicles/fps_vehicle_bike_2/fps_vehicle_bike_2",
		"units/pd2_dlc_born/vehicles/fps_vehicle_bike_1/fps_vehicle_bike_1",
		"units/pd2_dlc_shoutout_raid/vehicles/fps_vehicle_forklift_1/fps_vehicle_forklift_1",
		"units/pd2_dlc_shoutout_raid/vehicles/fps_vehicle_muscle_1/fps_vehicle_muscle_1",
		"units/pd2_dlc_cage/vehicles/fps_vehicle_falcogini_1/fps_vehicle_falcogini_1",
		"units/pd2_dlc_cage/vehicles/apartment/bmw/low",
		"units/pd2_dlc_cage/vehicles/apartment/charger/charger_apartment_animated_low/charger_apartment_animated_low",
		"units/pd2_dlc_cage/vehicles/apartment/police/apartment_police_animated",
		"units/pd2_dlc_cage/vehicles/apartment/mercedes/vehicle_mercedes_animated_low/mercedes_apartment_animated_low",
		"units/pd2_dlc_cage/vehicles/apartment/maserati/maserati_apartment_animated_low/maserati_apartment_animated_low",
		"units/vehicles/taxi/low/vehicle_taxi_low",
		"units/vehicles/helicopter/apartment_helicopter/apartment_helicopter",
		"units/vehicles/helicopter/helicopter_ranger/helicopter_cops",
		"units/payday2/vehicles/anim_vehicle_van_swat/anim_vehicle_van_swat"
		
		--[["units/payday2/vehicles/air_cart_baggage_1/air_cart_baggage_1",
		"units/payday2/vehicles/air_cart_baggage_2/air_cart_baggage_2",
		"units/payday2/vehicles/air_interactable_fuel_hose/air_interactable_fuel_hose",
		"units/payday2/vehicles/air_interactable_vehicle_cessna_206/air_interactable_vehicle_cessna_206",
		"units/payday2/vehicles/air_truck_baggage/air_truck_baggage",
		"units/payday2/vehicles/air_vehicle_blackhawk/helicopter_cops_ref",
		"units/payday2/vehicles/air_vehicle_blackhawk/helicopter_cops_ref_bag_catcher",
		"units/payday2/vehicles/air_vehicle_blackhawk/vehicle_blackhawk",
		"units/payday2/vehicles/air_vehicle_cessna_206/air_vehicle_cessna_206",
		"units/payday2/vehicles/air_vehicle_truck_firetruck/air_vehicle_truck_firetruck",
		"units/payday2/vehicles/bdrop_boat_01/bdrop_boat_01",
		"units/payday2/vehicles/bdrop_vehicles_cars/bdrop_vehicles_cars",
		"units/payday2/vehicles/bdrop_vehicles_cars_bridge/bdrop_vehicles_cars_bridge",
		"units/payday2/vehicles/bdrop_vehicles_cars_duo/bdrop_vehicles_cars_duo",
		"units/payday2/vehicles/bnk_vehicle_car_police_anim_1/bnk_vehicle_car_police_anim_1",
		"units/payday2/vehicles/bnk_vehicle_car_police_anim_2/bnk_vehicle_car_police_anim_2",
		"units/payday2/vehicles/bnk_vehicle_car_police_anim_3/bnk_vehicle_car_police_anim_3",
		"units/payday2/vehicles/bnk_vehicle_car_police_anim_4/bnk_vehicle_car_police_anim_4",
		"units/payday2/vehicles/bnk_vehicle_police_animated/bnk_vehicle_police_animated",
		"units/payday2/vehicles/bnk_vehicle_truck_police_anim_1/bnk_vehicle_truck_police_anim_1",
		"units/payday2/vehicles/bnk_vehicle_truck_police_anim_2/bnk_vehicle_truck_police_anim_2",
		"units/payday2/vehicles/dia_vehicle_car_mercedes_anim_qdia/dia_vehicle_car_mercedes_anim_qdia",
		"units/payday2/vehicles/dia_vehicle_car_police_anim_qdia/dia_vehicle_car_police_anim_qdia",
		"units/payday2/vehicles/dia_vehicle_van_player_anim_qdia/dia_vehicle_van_player_anim_qdia",
		"units/payday2/vehicles/eus_vehicle_train/eus_interactable_door_cargo",
		"units/payday2/vehicles/eus_vehicle_train/eus_interactable_door_carriage_static",
		"units/payday2/vehicles/eus_vehicle_train/eus_interactable_train_door_end",
		"units/payday2/vehicles/eus_vehicle_train/eus_static_door_carriage",
		"units/payday2/vehicles/eus_vehicle_train/eus_vehicle_train_cargo_carriage",
		"units/payday2/vehicles/eus_vehicle_train/eus_vehicle_train_locomotive",
		"units/payday2/vehicles/gen_vehicle_cocaineboat/gen_vehicle_cocaineboat",
		"units/payday2/vehicles/gen_vehicle_cocaineboat/gen_vehicle_cocaineboat_no_water",
		"units/payday2/vehicles/gen_vehicle_explosives_boat/gen_vehicle_explosives_boat",
		"units/payday2/vehicles/gen_vehicle_loot_boat/gen_vehicle_loot_boat",
		"units/payday2/vehicles/ind_vehicle_truck_forklift/ind_vehicle_truck_forklift",
		"units/payday2/vehicles/ind_vehicle_truck_forklift/ind_vehicle_truck_forklift_raised",
		"units/payday2/vehicles/ind_vehicle_truck_reachstacker/ind_vehicle_truck_reachstacker",
		"units/payday2/vehicles/str_backdrop_vehicles_animated/str_backdrop_vehicles_animated",
		"units/payday2/vehicles/str_vehicle_big_truck/str_vehicle_big_truck",
		"units/payday2/vehicles/str_vehicle_bus_metro/str_vehicle_bus_metro",
		"units/payday2/vehicles/str_vehicle_car_charger/str_vehicle_car_charger",
		"units/payday2/vehicles/str_vehicle_car_compact/str_vehicle_car_compact",
		"units/payday2/vehicles/str_vehicle_car_compact_anim_shouse/str_vehicle_car_compact_anim_shouse",
		"units/payday2/vehicles/str_vehicle_car_ford/str_vehicle_car_ford",
		"units/payday2/vehicles/str_vehicle_car_ford_graffiti/str_vehicle_car_ford_graffiti",
		"units/payday2/vehicles/str_vehicle_car_modernsedan/str_vehicle_car_modernsedan",
		"units/payday2/vehicles/str_vehicle_car_modernsedan/str_vehicle_car_modernsedan_red",
		"units/payday2/vehicles/str_vehicle_car_modernsedan2/str_vehicle_car_modernsedan2",
		"units/payday2/vehicles/str_vehicle_car_mondeo/str_vehicle_car_mondeo",
		"units/payday2/vehicles/str_vehicle_car_police_anim_mllcrsh_1/str_vehicle_car_police_anim_mllcrsh_1",
		"units/payday2/vehicles/str_vehicle_car_police_anim_mllcrsh_2/str_vehicle_car_police_anim_mllcrsh_2",
		"units/payday2/vehicles/str_vehicle_car_police_anim_mllcrsh_3/str_vehicle_car_police_anim_mllcrsh_3",
		"units/payday2/vehicles/str_vehicle_car_police_washington/str_vehicle_car_police_washington",
		"units/payday2/vehicles/str_vehicle_car_sport/str_vehicle_car_sport1",
		"units/payday2/vehicles/str_vehicle_car_sport/str_vehicle_car_sport2",
		"units/payday2/vehicles/str_vehicle_car_sport/str_vehicle_car_sport_showroom",
		"units/payday2/vehicles/str_vehicle_car_suburban/str_vehicle_car_suburban",
		"units/payday2/vehicles/str_vehicle_car_taxi/str_vehicle_car_taxi",
		"units/payday2/vehicles/str_vehicle_logging_machine/str_vehicle_logging_machine",
		"units/payday2/vehicles/str_vehicle_motorcycle_chopper/str_vehicle_motorcycle_chopper",
		"units/payday2/vehicles/str_vehicle_motorcycle_motorcross/str_vehicle_motorcycle_motorcross",
		"units/payday2/vehicles/str_vehicle_motorcycle_motorcross/str_vehicle_motorcycle_motorcross_left",
		"units/payday2/vehicles/str_vehicle_pickup_sportcab_anim_nightclub/str_vehicle_pickup_sportcab_anim_nightclub",
		"units/payday2/vehicles/str_vehicle_pickup_sportcab_anim_shouse/str_vehicle_pickup_sportcab_anim_shouse",
		"units/payday2/vehicles/str_vehicle_pickup_sportcab_anim_wdog/str_vehicle_pickup_sportcab_anim_wdog",
		"units/payday2/vehicles/str_vehicle_pickup_truck/str_vehicle_pickup_truck",
		"units/payday2/vehicles/str_vehicle_pickuptruck_sportcab/str_vehicle_pickuptruck_sportcab",
		"units/payday2/vehicles/str_vehicle_pickuptruck_sportcab/str_vehicle_pickuptruck_sportcab_open",
		"units/payday2/vehicles/str_vehicle_sedan_dmg/str_vehicle_sedan_dmg_alt_burnt",
		"units/payday2/vehicles/str_vehicle_sedan_dmg/str_vehicle_sedan_dmg_burnt",
		"units/payday2/vehicles/str_vehicle_sedan_dmg/str_vehicle_sedan_dmg_dented",
		"units/payday2/vehicles/str_vehicle_suburban_fbi/str_vehicle_suburban_fbi",
		"units/payday2/vehicles/str_vehicle_swat_van/str_vehicle_swat_van",
		"units/payday2/vehicles/str_vehicle_swat_van_gensec/str_vehicle_swat_van_gensec",
		"units/payday2/vehicles/str_vehicle_truck/str_vehicle_truck",
		"units/payday2/vehicles/str_vehicle_truck_ambulance/str_vehicle_truck_ambulance",
		"units/payday2/vehicles/str_vehicle_truck_boxvan/str_vehicle_truck_boxvan",
		"units/payday2/vehicles/str_vehicle_truck_boxvan/str_vehicle_truck_boxvan_player_edition",
		"units/payday2/vehicles/str_vehicle_truck_boxvan_eday/str_vehicle_truck_boxvan_eday",
		"units/payday2/vehicles/str_vehicle_truck_frontloader/str_vehicle_truck_frontloader",
		"units/payday2/vehicles/str_vehicle_truck_tanker/str_vehicle_truck_tanker",
		"units/payday2/vehicles/str_vehicle_van_anim_shouse/str_vehicle_van_anim_shouse",
		"units/payday2/vehicles/str_vehicle_van_dest/str_vehicle_van_dest_crashed",
		"units/payday2/vehicles/str_vehicle_van_dest/str_vehicle_van_dest_wrecked",
		"units/payday2/vehicles/str_vehicle_van_escape_cafe/str_vehicle_van_escape_cafe",
		"units/payday2/vehicles/str_vehicle_van_escape_overpass/str_vehicle_van_escape_overpass",
		"units/payday2/vehicles/str_vehicle_van_escape_park_1/str_vehicle_van_escape_park_1",
		"units/payday2/vehicles/str_vehicle_van_escape_park_2/str_vehicle_van_escape_park_2",
		"units/payday2/vehicles/str_vehicle_van_escape_park_3/str_vehicle_van_escape_park_3",
		"units/payday2/vehicles/str_vehicle_van_escape_park_4/str_vehicle_van_escape_park_4",
		"units/payday2/vehicles/str_vehicle_van_family_jewels_1/str_vehicle_van_family_jewels_1",
		"units/payday2/vehicles/str_vehicle_van_family_jewels_2/str_vehicle_van_family_jewels_2",
		"units/payday2/vehicles/str_vehicle_van_family_jewels_3/str_vehicle_van_family_jewels_3",
		"units/payday2/vehicles/str_vehicle_van_family_jewels_4/str_vehicle_van_family_jewels_4",
		"units/payday2/vehicles/str_vehicle_van_family_jewels_5/str_vehicle_van_family_jewels_5",
		"units/payday2/vehicles/str_vehicle_van_fourstores/str_vehicle_van_fourstores",
		"units/payday2/vehicles/str_vehicle_van_mallcrasher_anim_1/str_vehicle_van_mallcrasher_anim_1",
		"units/payday2/vehicles/str_vehicle_van_player/str_vehicle_van_player",
		"units/payday2/vehicles/sub_vehicle_train_frontdoor/sub_vehicle_train_frontdoor",
		"units/payday2/vehicles/sub_vehicle_train_halfdmg/sub_vehicle_train_halfdmg",
		"units/payday2/vehicles/sub_vehicle_train_halfdmg/sub_vehicle_train_hatch",
		"units/payday2/vehicles/sub_vehicle_train_heavydmg/sub_vehicle_train_heavydmg",
		"units/payday2/vehicles/sub_vehicle_train_seata_dmg/sub_vehicle_train_seata_dmg",
		"units/payday2/vehicles/sub_vehicle_train_seatc_dmg/sub_vehicle_train_seatc_dmg",
		"units/payday2/vehicles/sub_vehicle_train_sidedoor_left_dmg/sub_vehicle_train_sidedoor_left_dmg",
		"units/payday2/vehicles/sub_vehicle_train_sidedoor_right/sub_vehicle_train_sidedoor_right",
		"units/payday2/vehicles/sub_vehicle_train_sidedoors/sub_vehicle_train_sidedoors",
		"units/payday2/vehicles/tst_cargoship/tst_cargoship",--]]
	}
	
	loot_units = {
		"units/payday2/props/com_prop_jewelry_jewels/com_prop_jewelry_box_01",
		"units/payday2/props/com_prop_jewelry_jewels/com_prop_jewelry_box_02",
		"units/payday2/props/com_prop_jewelry_jewels/com_prop_jewelry_box_03",
		"units/payday2/props/com_prop_jewelry_jewels/com_prop_jewelry_box_04",
		"units/payday2/equipment/gen_interactable_weapon_case_2x1/gen_interactable_weapon_case_2x1",
		"units/payday2/pickups/gen_pku_circuit_board/gen_pku_circuit_board",
		"units/payday2/pickups/gen_pku_cocaine/gen_pku_cocaine",
		"units/payday2/props/gen_prop_methlab_meth/gen_prop_methlab_meth",
		"units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_special_money",
		"units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_special_gold",
		"units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_value_a",
		"units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_value_b",
		"units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_value_c",
		"units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_value_d",
		"units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_value_e",
		"units/payday2/props/com_prop_jewelry_jewels/spawn_prop_jewelry_box_01",
		"units/payday2/props/com_prop_jewelry_jewels/spawn_prop_jewelry_box_02",
		"units/payday2/props/com_prop_jewelry_jewels/spawn_prop_jewelry_box_03",
		"units/payday2/props/com_prop_jewelry_jewels/spawn_prop_jewelry_box_04",
		"units/pd2_dlc_dark/equipment/drk_interactable_weapon_case_1x1/drk_interactable_weapon_case_1x1",
		"units/pd2_dlc_dark/equipment/drk_interactable_weapon_case_2x1/drk_interactable_weapon_case_2x1",
		"units/pd2_dlc_dark/props/drk_prop_bomb_rack/drk_prop_bomb_rack_lower",
		"units/pd2_dlc_dark/props/drk_prop_bomb_rack/drk_prop_bomb_rack_upper",
		"units/payday2/equipment/ind_interactable_hardcase_loot/ind_interactable_hardcase_loot_cocaine",
		"units/pd2_mcmansion/props/mcm_prop_evidence_box/mcm_prop_evidence_box",
		"units/pd2_indiana/props/mus_prop_exhibit_b_pottery_a/mus_prop_exhibit_b_pottery_a",
		"units/pd2_indiana/props/mus_prop_exhibit_b_pottery_b/mus_prop_exhibit_b_pottery_b",
		"units/pd2_indiana/props/mus_prop_exhibit_b_pottery_c/mus_prop_exhibit_b_pottery_c",
		"units/pd2_indiana/props/mus_prop_exhibit_c_pottery/mus_prop_exhibit_c_pottery_a",
		"units/pd2_indiana/props/mus_prop_exhibit_d_pottery/mus_prop_exhibit_d_pottery_a",
		"units/pd2_indiana/props/mus_prop_exhibit_d_pottery/mus_prop_exhibit_d_pottery_b",
		"units/pd2_indiana/props/mus_prop_exhibit_d_pottery/mus_prop_exhibit_d_pottery_c",
		"units/pd2_dlc_sah/props/sah_prop_navigation_device/sah_prop_navigation_device",
		"units/pd2_dlc_sah/props/sah_prop_survivors_pickaxe/sah_prop_survivors_pickaxe",
		"units/pd2_indiana/props/mus_prop_caeser_bust/mus_prop_caeser_bust",
		"units/pd2_dlc_jfr/props/jfr_crate_wine/jfr_crate_wine",
		
	}
end

function get_peers(code, unitcheck)
	local peerid = tonumber(code)
	local me = managers.network:session():local_peer():id()
	if not peerid or peerid and (peerid < 1 or peerid > 4) then
		local tab = {}
		for x = 1, 4 do
			if managers.network:session():peer(x) then
				if not (unitcheck or unitcheck and managers.network:session():peer(x):unit()) then
					table.insert(tab, x)
				end
			end
		end
		if code == "*" then -- everyone
			return tab
		elseif code == "?" then -- random
			peerid = tab[math.random(1, #tab)]
		elseif code == "!" then -- anyone except self
			table.remove(tab, me)
			--peerid = tab[math.random(1, #tab)]
			return tab
		else -- self
			peerid = me
		end

		tab = nil
	end
	if peerid and managers.network:session():peer(peerid) then
		if not unitcheck or (unitcheck and managers.network:session():peer(peerid):unit()) then
			return {peerid}
		end
	end
	return
end

local run_element_with_chance = function(name)
	local position = player:position()
	if not PackageManager:has(Idstring("unit"), Idstring(name)) then return end
	safe_spawn_unit(Idstring(name), position, Rotation(managers.player:player_unit():camera():rotation():yaw(), 0, 0))
end


--[[
local id_table = { 
	local id_table = { 
			"units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_special_money"
		}
		local pos = player:position()
		local rot = Rotation(managers.player:local_player():movement():m_head_rot():yaw(),0,0)
		if not pos or not rot then
			return
		end
		local unit = safe_spawn_unit("units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_special_money", pos, rot)
		if unit and unit:interaction() then
			unit:interaction():set_active(true, true)
		end
function ServerSpawnBag(name, zipline_unit)
    local carry_data
    carry_data = tweak_data.carry[name]
    local player = managers.player:player_unit()
    if player then
        player:sound():play("Play_bag_generic_throw", nil, false)
    end
    local camera_ext = player:camera()
    local dye_initiated = carry_data.dye_initiated
    local has_dye_pack = carry_data.has_dye_pack
    local dye_value_multiplier = carry_data.dye_value_multiplier
    local throw_distance_multiplier_upgrade_level = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0)
    if isClient() then
        managers.network:session():send_to_host("server_drop_carry", name, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, camera_ext:position(), camera_ext:rotation(), player:camera():forward(), throw_distance_multiplier_upgrade_level, zipline_unit)
    else
        managers.player:server_drop_carry(name, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, camera_ext:position(), camera_ext:rotation(), player:camera():forward(), throw_distance_multiplier_upgrade_level, zipline_unit, managers.network:session():local_peer())
    end
    managers.hud:temp_show_spawn_bag(name, managers.loot:get_real_value(name, carry_data.multiplier or 1))
end--]]
local function _spawn_bag(name, rain, zipline_unit)
	local player = managers.player:player_unit()
	if not alive(player) then return end
	player:sound():play("Play_bag_generic_throw", nil, false)
	local forward = player:camera():forward()
	local throw_force = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0)
	local carry_data = tweak_data.carry[name]
	--local carry_type = carry_data.type
	if rain == false then
		local rotation = Rotation(player:camera():rotation():yaw(), 0, 0)
		local position = player:camera():position()
		if Network:is_server() then
			managers.player:drop_carry()
			--managers.player:server_drop_carry(name, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, throw_force, zipline_unit, managers.network:session():local_peer())
			managers.player:set_carry(name, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier)
			managers.player:drop_carry()
			managers.mission._fading_debug_output:script().log('Spawn Bag Host Side ACTIVATED', Color.green)
			--player:movement():current_state():set_tweak_data(carry_type)
		else
			managers.network:session():send_to_host("server_drop_carry", name, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, throw_force, zipline_unit)
			managers.mission._fading_debug_output:script().log(string.format("Spawn Bag Client Side %s %s %s %s ACTIVATED", name, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, dye_value_multiplier), Color.green)
		end
		managers.hud:temp_show_carry_bag(name, managers.loot:get_real_value(name, carry_data.multiplier or 1))
	elseif rain == true then
		local rotation = Rotation(math.random(-180,180), math.random(-180,180),0)
		local pos = player:camera():position()
		local randpos = function()
			return Vector3(math.random(pos.x-10000,pos.x+10000), math.random(pos.z-10000, pos.z+10000), pos.y+18000)
		end
		if Network:is_server() then
			managers.player:server_drop_carry(name, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, randpos(), rotation, forward, throw_force, zipline_unit, managers.network:session():local_peer())
			managers.mission._fading_debug_output:script().log('Spawn Bag Host Side ACTIVATED', Color.green)
		else
			managers.network:session():send_to_host("server_drop_carry", name, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, randpos(), rotation, forward, throw_force, zipline_unit)
			managers.mission._fading_debug_output:script().log('Spawn Bag Client Side ACTIVATED', Color.green)
		end
	end
end

local function turretstop()
	global_toggle_turret_on_off = global_toggle_turret_on_off or false
	if not global_toggle_turret_on_off then
		if not set_animated_vehicle_base_spawn_original then set_animated_vehicle_base_spawn_original = AnimatedVehicleBase.spawn_module end
		local set_animated_vehicle_base_spawn_original = AnimatedVehicleBase.spawn_module
		function AnimatedVehicleBase.spawn_module(self, module_unit_name, ...)
			if type_name(module_unit_name) == "asdsdgrsg" then
				return set_animated_vehicle_base_spawn_original(self, module_unit_name, ...)
			end
		end
		managers.mission._fading_debug_output:script().log('Turret Modules - ACTIVATED', Color.green)
	else
		if set_animated_vehicle_base_spawn_original then AnimatedVehicleBase.spawn_module = set_animated_vehicle_base_spawn_original end
		managers.mission._fading_debug_output:script().log('Turret Modules - DEACTIVATED', Color.red)
	end
	global_toggle_turret_on_off = not global_toggle_turret_on_off
end

local function civdance()
	local poses = { "cf_sp_dance_slow", "cf_sp_dance_sexy", "cf_sp_pole_dancer_expert", "cf_sp_pole_dancer_basic" }
	local poses2 = { "e_sp_dizzy_walk_inplace"}
	local poses3 = { "e_sp_dizzy_look_around"}
	local poses4 = { "e_sp_dizzy_fall_get_up"}
	local poses5 = { "e_so_walk_investigate_unarmed"}

	start_anim = function()
		for k,v in pairs(managers.enemy:all_enemies()) do
			local act = { type = "act", variant = poses2[math.random(1, #poses2)], body_part = 1, align_sync = true }
			v.unit:movement():action_request(act)
			DelayedCalls:Add( "start_anim3", 10, function() start_anim3() end)
		end
	end
	start_anim2 = function()
		for k,v in pairs(managers.enemy:all_enemies()) do
			local act = { type = "act", variant = poses3[math.random(1, #poses3)], body_part = 1, align_sync = true }
			v.unit:movement():action_request(act)
			DelayedCalls:Add( "start_anim", 10, function() start_anim() end)
		end
	end
	start_anim3 = function()
		for k,v in pairs(managers.enemy:all_enemies()) do
			local act = { type = "act", variant = poses4[math.random(1, #poses4)], body_part = 1, align_sync = true }
			v.unit:movement():action_request(act)
			DelayedCalls:Add( "start_anim4", 16, function() start_anim4() end)
		end
	end
	start_anim4 = function()
		for k,v in pairs(managers.enemy:all_enemies()) do
			local act = { type = "act", variant = poses5[math.random(1, #poses5)], body_part = 1, align_sync = true }
			v.unit:movement():action_request(act)
		end
	end
	for k,v in pairs(managers.enemy:all_civilians()) do
		local act = { type = "act", variant = poses[math.random(1, #poses)], body_part = 1, align_sync = true }
		v.unit:movement():action_request(act)
	end
	managers.mission._fading_debug_output:script().log('Boogie ACTIVATED', Color.green)
	start_anim2()
end

local function spawn_car(car_name)
	local rotation = Rotation(managers.player:player_unit():camera():rotation():yaw(), 0, 0)
	local position = ray_pos()
	safe_spawn_unit(Idstring(car_name), position, rotation)
	--[[for i, v in ipairs(managers.vehicle._vehicles) do
		local v_ext = v:vehicle_driving()
		local driver = v_ext._seats.driver.occupant
		local passenger_front = v_ext._seats.passenger_front.occupant
		local passenger_back_left = v_ext._seats.passenger_back_left.occupant
		local passenger_back_right = v_ext._seats.passenger_back_right.occupant
		local is_trunk_open = v_ext._trunk_open
		--local locator = ElementVehicleBoarding:get_vehicle():vehicle_driving():get_seat_by_name(1)
		--local seat = v:vehicle_driving():get_available_seat(locator:position())
		managers.network:session():send_to_peers_synched("sync_vehicle_data", v_ext._unit, v_ext._current_state_name, driver, passenger_front, passenger_back_left, passenger_back_right, is_trunk_open)
		for x=1,4 do
			local peer = managers.network:session():peer(x)
			if peer then
				local char_unit = managers.criminals:character_unit_by_peer_id(peer:id())
				--v:interaction():sync_interacted(peer, char_unit, UseInteractionExt.interaction)
				managers.network:session():send_to_peers_synched("sync_vehicle_player", "enter", v, peer:id(), managers.player:local_player(), "driver")
				--managers.network:session():send_to_peers_synched("sync_interacted", peer, peer:id(), UseInteractionExt.tweak_data, 1)
				--managers.vehicle:update_vehicles_data_to_peer(peer)
			end
		end
	end--]]
	--[[for x=1,4 do
		local peer = managers.network:session():peer(x)
		if peer then
			--managers.vehicle:update_vehicles_data_to_peer(peer)
			--NetworkPeer:sync_data(peer)
			--local char_unit = managers.criminals:character_unit_by_peer_id(peer:id())
			--car_name:interaction():sync_interacted(peer, char_unit, tweak_data.interaction)
		end
	end
	--]]
	managers.chat:feed_system_message(ChatManager.GAME, "Entering a drivable vehicle will crash everyone in your lobby!")
	managers.mission._fading_debug_output:script().log('Car Spawn - ACTIVATED', Color.green)
end

local function spawn_turret(group, id)
	local rotation = Rotation(managers.player:player_unit():camera():rotation():yaw(), 0, 0)
	local position = ray_pos()
	local unit_name = "units/payday2/vehicles/gen_vehicle_turret/gen_vehicle_turret"
	local unit_car = safe_spawn_unit(Idstring(id), position, rotation)
	managers.mission._fading_debug_output:script().log('Turret ACTIVATED', Color.green)
	local module_id = math.random()
	unit_car:base():spawn_module( unit_name, "spawn_turret", module_id )
	unit_car:base():run_module_function( module_id, "base", "activate_as_module", group, "swat_van_turret_module" )
end

local function SpawnCiv(name)
	local spawn_pos = ray_pos()--managers.player:player_unit():position()
	local spawn_rot = Rotation(managers.player:player_unit():camera():rotation():yaw(), 0, 0)
	local spawnamount = 1
	for i = 1, spawnamount do
		local unit = safe_spawn_unit( Idstring(name), spawn_pos, spawn_rot )
		local AIState = managers.groupai:state()
		local team_id = tweak_data.levels:get_default_team_ID( "non_combatant" )
		unit:movement():set_team( AIState:team_data( team_id ) )
		if unit:brain() then
			unit:brain():set_spawn_ai( { init_state = "idle" } )
		end
		local variant = ( "cf_sp_pole_dancer_expert" ) or ( "cm_sp_stand_idle" ) or ( "idle" )
		local action_data = { type = "act", body_part = 1, variant = variant, align_sync = true }
		unit:brain():action_request( action_data )
	end
end

function SpawnSwat(name, spawnamount, ene_type)
	-- removes questionmark over ai
	function GroupAIStateBase:on_criminal_suspicion_progress( u_suspect, u_observer, status ) end
	local spawn_pos = ray_pos()
	local spawn_rot = Rotation(managers.player:player_unit():camera():rotation():yaw(), 0, 0)
	for i = 1, spawnamount do
		local unit = safe_spawn_unit( Idstring(name), spawn_pos, spawn_rot )
		local AIState = managers.groupai:state()
		if ene_type == "friendly" then
			team_id = tweak_data.levels:get_default_team_ID( "player" )
			unit:movement():set_team( AIState:team_data( team_id ) )
		elseif ene_type == "enemy" then
			team_id = tweak_data.levels:get_default_team_ID( "combatant" )
			unit:movement():set_team( AIState:team_data( team_id ) )
		end
		--unit:movement():set_character_anim_variables()
		--unit:remove_interact()
		unit:set_active(true)
		if unit:brain() then
			unit:brain():set_spawn_ai( { init_state = "idle" } )
		end
		if ene_type == "friendly" then
			managers.groupai:state():convert_hostage_to_criminal( unit )
			managers.groupai:state():sync_converted_enemy( unit )
		elseif ene_type == "enemy" then
			local variant = ( "idle" )
			local action_data = { type = "act", body_part = 1, variant = variant, align_sync = true }
			unit:brain():action_request( action_data )
		end
	end
end

local function add(name)
	managers.player:add_special({ name = name, silent = true, amount = 1 })
	managers.mission._fading_debug_output:script().log(string.format("%s added", name),  Color.green)
end

local function remove_special_equip()
	for id, item_data in pairs(tweak_data.equipments.specials) do
		for i=1,10 do
			managers.player:remove_special(id)
		end
		managers.mission._fading_debug_output:script().log(string.format("Removed %s ", id),  Color.green)
	end
end

local function give_item_to_all_peers(item_name, peer_id, peer_name)
	if Network:is_server() then else 
		managers.chat:_receive_message(1, "GiveItemsToPeer", "Host only!", tweak_data.system_chat_color)
		return
	end
	local player = unit_from_id( peer_id )
	local peer = managers.network:session():peer(peer_id)
	local network = peer:unit():network()
	local send = network.send
	if player and alive(peer:unit()) then
		player:network():send_to_unit({ "give_equipment", item_name, 1, player:id() })
		--managers.network:session():send_to_peers_loaded("sync_remove_equipment_possession", player:id(), name)
	end
	managers.mission._fading_debug_output:script().log(string.format("%s got %s ", peer_name, item_name),  Color.green)
end

special_menu = function()
	local dialog_data = {    
		title = "Spawn Special Menu",
		text = "Select Option Item",
		button_list = {}
	}

	for id, item_data in pairs( tweak_data.equipments.specials ) do
		if item_data.text_id and managers.localization.exists( managers.localization, item_data.text_id ) then
			table.insert(dialog_data.button_list, {
				text = managers.localization.text( managers.localization, item_data.text_id ),
				callback_func = function() if id == "gold" then id = "" add(id) else add(id) end end,    
			})
			table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
		end
	end
	
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {
		text = "Give Comon To Self",
		callback_func = function()
			local spec_items = {
				"planks",
				"crowbar",
				"harddrive",
				"blow_torch",
				"thermite",
				"circle_cutter",
				"blood_sample",
				"bank_manager_key",
				"thermite_paste"
			}
			for _, item_data in pairs( spec_items ) do
				add(item_data)
			end
		end,     
	})
	
	table.insert(dialog_data.button_list, {
		text = "Give All To Players",
		callback_func = function() 
			local lpeer_id = managers.network._session._local_peer._id
			for _, peer in pairs( managers.network._session._peers ) do
				local peer_id = peer._id
				if peer_id ~= lpeer_id then
					local peer_name = peer._name
					for id, item_data in pairs( tweak_data.equipments.specials ) do
						if not (id == "gold") then give_item_to_all_peers(id, peer_id, peer_name) end
						if not (id == "gold") then managers.player:add_special({name = id, silent = true, amount = 1}) end
					end
				end
			end
		end,  
	})
	
	table.insert(dialog_data.button_list, {
		text = "Remove All From Self",
		callback_func = function() remove_special_equip() end,     
	})
	
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "------------------------- Use Scroll Wheel ------------------------",})
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu() end,})
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}    
	table.insert(dialog_data.button_list, no_button) 
	managers.system_menu:show_buttons(dialog_data)
end

bag_amount_menu = function(bag_id, bag_type)
	local dialog_data = {    
		title = "Spawn Amount Menu",
		text = "Select Option",
		button_list = {}
	}
	
	if bag_type == "spawn" then
		for i=500, 1, -1 do
			table.insert(dialog_data.button_list, {
				text = i,
				callback_func = function()
					for amount=1, i do
						_spawn_bag(bag_id, false)
					end
				end,      
			})
		end     
	elseif bag_type == "secure" then
		for i=500, 1, -1 do
			table.insert(dialog_data.button_list, {
				text = i,
				callback_func = function() 
					for stuff=1, i do
						managers.loot:secure(bag_id, managers.money:get_bag_value(bag_id), true)
					end
				end,     
			})
		end
	elseif bag_type == "rain" then
		_spawn_bag(bag_id, 150, true)
		DelayedCalls:Add( "rainbags_id1", 1, function() _spawn_bag(bag_id, 150, true) end)
		DelayedCalls:Add( "rainbags_id2", 2, function() _spawn_bag(bag_id, 150, true) end)
		DelayedCalls:Add( "rainbags_id3", 3, function() _spawn_bag(bag_id, 150, true) end)
	end
	
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "------------------------- Use Scroll Wheel ------------------------",})
	table.insert(dialog_data.button_list, {})
	if bag_type == "spawn" then
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() bag_menu("spawn") end,})
	elseif bag_type == "secure" then
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() bag_menu("secure") end,})
	end
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}     
	table.insert(dialog_data.button_list, no_button)
	if (bag_type == "secure" or bag_type == "spawn") then
		managers.system_menu:show_buttons(dialog_data)
	end
end

bag_menu = function(bag_type)
	local dialog_data = {    
		title = "Spawn Bag Menu",
		text = "Select Option",
		button_list = {}
	}

	for bag_id, bag_data in pairs( tweak_data.carry ) do
		if not (string.startswith(bag_id, "vehicle")) then
			local name_id = bag_data.name_id
			if name_id and managers.localization:exists(name_id) then
				if bag_type == "spawn" then
					table.insert(dialog_data.button_list, {
						text = managers.localization:text(name_id), --parse_unit_name(name_id)
						callback_func = function() bag_amount_menu(bag_id, "spawn") end,
						table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
					})
				elseif bag_type == "secure" then
					table.insert(dialog_data.button_list, {
						text = managers.localization:text(name_id),
						callback_func = function() bag_amount_menu(bag_id, "secure") end,
						table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
					})
				elseif bag_type == "rain" then
					table.insert(dialog_data.button_list, {
						text = managers.localization:text(name_id),
						callback_func = function() bag_amount_menu(bag_id, "rain") end,
						table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
					})
				end
			end
		end
	end
	
	if (bag_type == "rain" or bag_type == "spawn") then
		managers.chat:feed_system_message(ChatManager.GAME, "Only spawn bags that can be acquired in the heist!")
	end
	
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "------------------------- Use Scroll Wheel ------------------------",})
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu() end,})
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}    
	table.insert(dialog_data.button_list, no_button) 
	managers.system_menu:show_buttons(dialog_data)
end

carmenu = function()
	local dialog_data = {    
		title = "Spawn Car Menu",
		text = "Select Option",
		button_list = {}
	}

	for _,id in pairs(car_names) do
		if unit_on_map(id) then
			if not (id == "units/payday2/vehicles/anim_vehicle_van_swat/anim_vehicle_van_swat") then
				table.insert(dialog_data.button_list, {
					text = parse_unit_name(id),
					callback_func = function() spawn_car(id) end,
					table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
				})
			else
				table.insert(dialog_data.button_list, {
					text = "Friendly Turret",
					callback_func = function() spawn_turret("player", id) end,
				})
				table.insert(dialog_data.button_list, {
					text = "Enemy Turret",
					callback_func = function() spawn_turret("combatant", id) end,
				})
			end
		end
	end
		
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "------------------------- Use Scroll Wheel ------------------------",})
	table.insert(dialog_data.button_list, {})	
	table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu() end,})
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}    
	table.insert(dialog_data.button_list, no_button) 
	managers.system_menu:show_buttons(dialog_data)
end

civ = function()
	local dialog_data = {    
		title = "Spawn Stripper Menu",
		text = "Select Option",
		button_list = {}
	}

	local unit_table = all_units.all_civs
	
	for _,unit_name in pairs( unit_table ) do
		if unit_on_map( unit_name ) then
			table.insert(dialog_data.button_list, {
				text = parse_unit_name(unit_name),
				callback_func = function() SpawnCiv(unit_name) end,
				table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
			})
		end
	end
	
	if #dialog_data.button_list == 0 then table.insert(dialog_data.button_list, {text = "No units on the map",}) end
	
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "------------------------- Use Scroll Wheel ------------------------",})
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu() end,})
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}     
	table.insert(dialog_data.button_list, no_button) 
	managers.system_menu:show_buttons(dialog_data)
end

SpawnSwatAmountmenu = function(unit_name, unit_type)
	local dialog_data = {    
		title = "Spawn Amount Menu",
		text = "Select Option",
		button_list = {}
	}
	
	for i=500, 1, -1 do
		if unit_type == "enemy" then
			table.insert(dialog_data.button_list, {
				text = i,
				callback_func = function() SpawnSwat(unit_name, i, unit_type) end,     
			})
		elseif unit_type == "friendly" then
			table.insert(dialog_data.button_list, {
				text = i,
				callback_func = function() SpawnSwat(unit_name, i, unit_type) end,    
			})
		end
	end
	
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "------------------------- Use Scroll Wheel ------------------------",})
	table.insert(dialog_data.button_list, {})
	if unit_type == "enemy" then
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() spawnswatmenu("enemy") end,})
	elseif unit_type == "friendly" then
		table.insert(dialog_data.button_list, {text = "back", callback_func = function() spawnswatmenu("friendly") end,})
	end
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}    
	table.insert(dialog_data.button_list, no_button) 
	managers.system_menu:show_buttons(dialog_data)
end

spawnswatmenu = function(unit_type)
	local dialog_data = {    
		title = "Spawn "..unit_type.." Menu",
		text = "Select Option",
		button_list = {}
	}
	load_table()
	local unit_table_menu = {
		unit_table = all_units.all_swats,
		unit_table2 = all_units.all_fbi,
		unit_table3 = all_units.all_cops,
		unit_table4 = all_units.all_gangs,
	}
	for _,unit_var in pairs( unit_table_menu ) do
		for _,unit_name in pairs( unit_var ) do
			if unit_on_map( unit_name ) then
				if unit_type == "friendly" then
					table.insert(dialog_data.button_list, {
						text = parse_unit_name(unit_name),
						callback_func = function() SpawnSwatAmountmenu(unit_name, "friendly") end,
						table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
					})
				elseif unit_type == "enemy" then
					table.insert(dialog_data.button_list, {
						text = parse_unit_name(unit_name),
						callback_func = function() SpawnSwatAmountmenu(unit_name, "enemy") end,
						table.sort( dialog_data.button_list, function(x,y) if x.text and y.text then return x.text < y.text end end )
					})
				end
			end
		end
	end

	if #dialog_data.button_list == 0 then table.insert(dialog_data.button_list, {text = "No units on the map",}) end
	
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "------------------------- Use Scroll Wheel ------------------------",})
	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, {text = "back", callback_func = function() main_menu() end,})
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}     
	table.insert(dialog_data.button_list, no_button) 
	managers.system_menu:show_buttons(dialog_data)
end

main_menu = function()
	local dialog_data = {    
		title = "Spawn Menu",
		text = "Select Option",
		button_list = {}
	}
	
	local main_spawn_menu_table = {
		["input"] = {
			{ text = "Spawn Bag Menu", callback_func = function() bag_menu("spawn") end },
			{ text = "Secure Bag Menu", callback_func = function() bag_menu("secure") end },
			{ text = "Rain Bag Menu", callback_func = function() bag_menu("rain") end },
			{ text = "Spawn Special Items Menu", callback_func = function() special_menu() end },
			{},
			{ text = "Spawn Friendly Menu", callback_func = function() 
				if Network:is_server() and alive(managers.player:player_unit()) then
					spawnswatmenu("friendly") 
				else
					managers.chat:_receive_message(1, "SpawnFriendly", "Host only!", tweak_data.system_chat_color)
				end
			end },
			{ text = "Spawn Enemy Menu", callback_func = function() 
				if Network:is_server() and alive(managers.player:player_unit()) then
					spawnswatmenu("enemy") 
				else
					managers.chat:_receive_message(1, "SpawnEnemy", "Host only!", tweak_data.system_chat_color)
				end
			end },
			{ text = "Spawn Vehicle Menu", callback_func = function() 
				if Network:is_server() and alive(managers.player:player_unit()) then
					carmenu() 
				else
					managers.chat:_receive_message(1, "SpawnVehicle", "Host only!", tweak_data.system_chat_color)
				end
			end },
			{ text = "Spawn Stripper Menu", callback_func = function() 
				if Network:is_server() and alive(managers.player:player_unit()) then
					civ()
				else
					managers.chat:_receive_message(1, "SpawnStripper", "Host only!", tweak_data.system_chat_color)
				end
			end },
			{},
			{ text = "Spawn Random Loot On Map - ON", callback_func = function() 
				if Network:is_server() and alive(managers.player:player_unit())then
					dofile("mods/hook/content/scripts/randomlootspawn.lua")
				else
					managers.chat:_receive_message(1, "SpawnLoot", "Host only!", tweak_data.system_chat_color)
				end
			end },
			{ text = "Everyone Boogie - ON", callback_func = function() civdance() end },
			{ text = "Turret Modules - ON/OFF", callback_func = function() 
				dofile("mods/hook/content/scripts/kill sentries.lua")
			end },
		}
	}
	
	local spawn_menu_array = "input"
	if main_spawn_menu_table[spawn_menu_array] then
		for _, dostuff in pairs(main_spawn_menu_table[spawn_menu_array]) do
			if main_spawn_menu_table[spawn_menu_array] then
				table.insert(dialog_data.button_list, dostuff)
			end
		end
	end
	
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}    
	table.insert(dialog_data.button_list, no_button) 
	managers.system_menu:show_buttons(dialog_data)
end
load_table()
main_menu()
