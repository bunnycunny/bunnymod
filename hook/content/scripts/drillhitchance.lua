if CommandManager.config["trainer_buffs"] then
	--You dont require kickstarter skill to hit drill with melee
	local orig_func_init = PlayerStandard.init
	function PlayerStandard:init(unit)
		orig_func_init(self, unit)
		self._on_melee_restart_drill = true
	end

	--Gives all drill upgrades except kickstarter
	local orig_func_Drill_init = Drill.init
	function Drill:init(unit)
		orig_func_Drill_init(self, unit)
		self._skill_upgrades = {
			auto_repair_level_1 = 1,
			auto_repair_level_2 = 1,
			speed_upgrade_level = 2,
			silent_drill = true,
			reduced_alert = true
		}
		managers.network:session():send_to_peers_synched("sync_drill_upgrades", self._unit, self._skill_upgrades.auto_repair_level_1, self._skill_upgrades.auto_repair_level_2, self._skill_upgrades.speed_upgrade_level, self._skill_upgrades.silent_drill, self._skill_upgrades.reduced_alert)
	end

	function Drill.get_upgrades(drill_unit, player)
		local is_drill = drill_unit:base() and drill_unit:base().is_drill
		local is_saw = drill_unit:base() and drill_unit:base().is_saw

		if is_drill or is_saw then
			return {
				auto_repair_level_1 = 1,
				auto_repair_level_2 = 1,
				speed_upgrade_level = 2,
				silent_drill = true,
				reduced_alert = true
			}
		end
	end
	
	--you get 100% chance repair/upgrade drill on melee hit
	function Drill:on_melee_hit(peer_id)
		if self._disable_upgrades then
			return
		end
		
		if not self:_does_peer_exist(peer_id) then
			table.insert(self._peer_ids, peer_id)
			self._unit:interaction():interact(managers.player:player_unit())

			self._unit:set_skill_upgrades(self._skill_upgrades)
		end
		managers.network:session():send_to_peers_synched("sync_drill_upgrades", self._unit, self._skill_upgrades.auto_repair_level_1, self._skill_upgrades.auto_repair_level_2, self._skill_upgrades.speed_upgrade_level, self._skill_upgrades.silent_drill, self._skill_upgrades.reduced_alert)
	end
end