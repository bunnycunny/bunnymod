-- give fak
-- spawn ecm
--https://github.com/mwSora/payday-2-luajit/blob/master/pd2-lua/lib/units/equipment/ecm_jammer/ecmjammerbase.lua
if not Network.is_server(Network) then
	if managers.hud and (managers.player:player_unit()) then
		managers.player:clear_equipment()
		managers.player._equipment.selections = {}
		managers.player:add_equipment({ silent = true, equipment = "first_aid_kit" })
	end
	managers.mission._fading_debug_output:script().log(string.format("First Aid Kit - Equiped"), Color.green)
else
	local from = managers.player:player_unit():movement():m_head_pos()
	local to = from + managers.player:player_unit():movement():m_head_rot():y() * 10000
	local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
	if ray then
		local pos = ray.position
		local rot = Rotation(managers.player:player_unit():camera():rotation():yaw(), 0, 0)
		World:spawn_unit(Idstring("units/pd2_dlc_old_hoxton/equipment/gen_equipment_first_aid_kit/gen_equipment_first_aid_kit"), pos, rot)
	end
	managers.mission._fading_debug_output:script().log('First Aid Spawn ACTIVATED', Color.green)
end