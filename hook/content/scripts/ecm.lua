local ecm_level = 3														--value btw 1-3, the ecm upgrade level
local remove_unit_after_time = false									--set to true to remove the jammer when the time is up (host only)
local get_equipment = false												--set to true to get equipment when not host instead of spawning ecm
local apply_feedback = false												--auto apply feedback on placement
local placement_distance = 10000										--how far do you want to be able to place the ecm def 250
if tweak_data then
	tweak_data.upgrades.ecm_jammer_base_battery_life = 20 					--ecm time def 20
	tweak_data.upgrades.ecm_jammer_base_low_battery_life = 8 				--ecm blinking point def 8
	tweak_data.upgrades.ecm_jammer_base_range = 10000 						--feedback range of effect def 2500
	tweak_data.upgrades.values.ecm_jammer.can_activate_feedback = {true}	--set to true to be able to activate feedback
	tweak_data.upgrades.values.ecm_jammer.affects_pagers = {true}			--set to true to affect unit pagers
	tweak_data.upgrades.values.ecm_jammer.affects_cameras = {true}			--set to true to affect cameras
	tweak_data.upgrades.values.ecm_jammer.can_retrigger = {true}			--set to true to be able to trigger ecm again
	tweak_data.upgrades.ecm_feedback_retrigger_interval = 5					--set amount of time before ecm is usable again def 60
	tweak_data.upgrades.values.ecm_jammer.quantity = {1,3}					--set amount of ecms to get when not host and get_equipment is set to true (1-3) def 1,3
end

local function remove_equipment(id)
	local slot = managers.player:equipment_slot(id)
	local equipped_deployable = managers.blackmarket:equipped_deployable(slot)
	if equipped_deployable then
		local upgr = managers.player:equiptment_upgrade_value(id, "quantity")
		local amount
		if upgr == 1 then
			amount = 2
		else
			amount = 1
		end
		local amt = upgr - amount
		managers.player:add_equipment_amount(id, amt, slot)
	end
end

if NetworkPeer then
	function NetworkPeer:custom_verify_ecm(equip)
		local max_amount = tweak_data.equipments.max_amount[equip]
		if max_amount then
			max_amount = managers.modifiers:modify_value("PlayerManager:GetEquipmentMaxAmount", max_amount)

			remove_equipment(equip)
			if max_amount < 0 then
				return true
			elseif not self._deployable or not self._deployable[equip] and table.size(self._deployable) < 2 then
				self._deployable = self._deployable or {}
				self._deployable[equip] = 1
				return true
			elseif self._deployable[equip] and self._deployable[equip] < max_amount then
				self._deployable[equip] = self._deployable[equip] + 1
				return true
			end
		end
		return false
	end

	local player_unit = managers.player:player_unit()
	local from = managers.player:player_unit():movement():m_head_pos()
	local to = from + managers.player:player_unit():movement():m_head_rot():y() * placement_distance
	local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
	if ray then 
		managers.mission:call_global_event("player_deploy_ecmjammer")
		managers.statistics:use_ecm_jammer()

		local duration_multiplier = managers.player:upgrade_level("ecm_jammer", "duration_multiplier", 0) + managers.player:upgrade_level("ecm_jammer", "duration_multiplier_2", 0) + ecm_level
		local relative_pos = ray.position - ray.body:position()

		mvector3.rotate_with(relative_pos, ray.body:rotation():inverse())

		local relative_rot = ray.body:rotation():inverse() * Rotation(ray.normal, math.UP)

		if Network:is_client() then
			if managers.hud and get_equipment then
				managers.player:clear_equipment()
				managers.player._equipment.selections = {}
				managers.player:add_equipment({silent = true, equipment = "ecm_jammer", slot = 1})
				managers.player:add_equipment({silent = true, equipment = "bodybags_bag", slot = 2})
			else
				local peer = managers.network:session():local_peer()
				if managers.network.matchmake.lobby_handler:get_lobby_data("auto_kick") then
					if not peer:custom_verify_ecm("ecm_jammer") then
						return
					end
				end
				managers.network:session():send_to_host("request_place_ecm_jammer", duration_multiplier, ray.body, relative_pos, relative_rot, managers.network:session():local_peer():id())
			end
		else
			local rot = Rotation(ray.normal, math.UP)
			local unit = ECMJammerBase.spawn(ray.position, rot, duration_multiplier, player_unit, managers.network:session():local_peer():id())

			unit:base():set_active(true)
			unit:base():link_attachment(ray.body, relative_pos, relative_rot)
			if apply_feedback then
				unit:base():_set_feedback_active(true)
			end
			managers.network:session():send_to_peers_synched("sync_deployable_attachment", unit, ray.body, relative_pos, relative_rot)
		end
		managers.mission._fading_debug_output:script().log('ECM - ACTIVATED', Color.green)
	end
end

if ECMJammerBase then
	local orig_func__set_battery_empty = ECMJammerBase._set_battery_empty
	function ECMJammerBase._set_battery_empty(self)
		orig_func__set_battery_empty(self)
		if remove_unit_after_time and (self._battery_life <= 0) and alive(self._unit) then
			World:delete_unit(self._unit)
		end
	end
end