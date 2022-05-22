function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end

if not is_playing() then
	return
end

equipment_toggle = equipment_toggle or false
if not equipment_toggle then
	--Infinite equipments
	if not _rmEquipment then _rmEquipment = PlayerManager.remove_equipment end
	function PlayerManager:remove_equipment( equipment_id ) end
	if not _rmEquipment2 then _rmEquipment2 = PlayerManager.remove_equipment_possession end
	function PlayerManager:remove_equipment_possession( peer_id, equipment ) end
	
	if not _rmEquipment3 then _rmEquipment3 = PlayerManager.clear_equipment end
	function PlayerManager:clear_equipment() end
	if not _rmEquipment4 then _rmEquipment4 = PlayerManager.from_server_equipment_place_result end
	function PlayerManager:from_server_equipment_place_result( selected_index, unit ) end
	--if not _rmEquipment5 then _rmEquipment5 = HUDManager.remove_special_equipment end
	--function HUDManager:remove_special_equipment( equipment ) end
	
	--infinate granades
	if not _inf_grenades then _inf_grenades = PlayerManager.update_grenades_amount_to_peers end
	function PlayerManager:update_grenades_amount_to_peers(grenade, amount, register_peer_id)
		local peer_id = managers.network:session():local_peer():id()
		managers.network:session():send_to_peers_synched("sync_grenades", grenade, 3, register_peer_id or 0)
		self:set_synced_grenades(peer_id, grenade, 3, register_peer_id)
	end
	
	--inf body bags
	managers.player:add_body_bags_amount(1)
	if not infBodybags_on_used_body_bag then infBodybags_on_used_body_bag = PlayerManager.on_used_body_bag end
	function PlayerManager:on_used_body_bag()
		self:_set_body_bags_amount(self._local_player_body_bags)
	end
	
	--msg
	managers.mission._fading_debug_output:script().log('Inf Equipment - ACTIVATED', Color.green)
else
	--inf equip
	if _rmEquipment then PlayerManager.remove_equipment = _rmEquipment end
	if _rmEquipment2 then PlayerManager.remove_equipment_possession = _rmEquipment2 end
	if _rmEquipment3 then PlayerManager.clear_equipment = _rmEquipment3 end
	if _rmEquipment4 then PlayerManager.from_server_equipment_place_result = _rmEquipment4 end
	if _rmEquipment5 then HUDManager.remove_special_equipment = _rmEquipment5 end
	
	--inf grenade
	if _inf_grenades then PlayerManager.update_grenades_amount_to_peers = _inf_grenades end
	
	--inf body bags
	if infBodybags_on_used_body_bag then PlayerManager.on_used_body_bag = infBodybags_on_used_body_bag end

	managers.mission._fading_debug_output:script().log('Inf Equipment - DEACTIVATED', Color.red)
end
equipment_toggle = not equipment_toggle