if _G["PlayerManager"] ~= nil then
	local orig_func_add_sentry_gun = PlayerManager.add_sentry_gun
	function PlayerManager:add_sentry_gun(num, sentry_type, ...)
		local equipment, index = self:equipment_data_by_name(sentry_type)
		if equipment and index then
			orig_func_add_sentry_gun(self, num, sentry_type, ...)
		end
	end
end

if _G["SentryGunBase"] ~= nil then
	if CommandManager.config["sentry_buffs"] and Network:is_server() then
		SentryGunBase.AMMO_MUL = {15,15} --host side
		SentryGunBase.ROTATION_SPEED_MUL = {3} --host side only or crash
	end
	if CommandManager.config["sentry_auto_pickup"] then
		SentryGunBase.DEPLOYEMENT_COST = {1,1,1}
		SentryGunBase.MIN_DEPLOYEMENT_COST = 0
		local orig_func_on_death = SentryGunBase.on_death
		function SentryGunBase:on_death(...)
			local session = managers.network:session()
			local peer_id = session and (session:local_peer():id() or 1)
			local interaction = (alive(self._unit) and (self._unit['interaction'] ~= nil)) and self._unit:interaction()
			if interaction and interaction.tweak_data and peer_id and interaction._owner_id and (interaction._owner_id == peer_id) then
				interaction:interact()
			else
				orig_func_on_death(self, ...)
			end 
		end
	end
end
 
if _G["SentryGunBrain"] ~= nil then
	if CommandManager.config["sentry_auto_pickup"] then
		function SentryGunBrain:switch_off()
			local is_server = Network:is_server()
			
			if is_server then
				self._ext_movement:set_attention()
			end
	 
			self:set_active(false)
			self._ext_movement:switch_off()
			self._unit:set_slot(26)
	 
			local groupai = managers.groupai:state()
			if groupai:all_criminals()[self._unit:key()] then
				groupai:on_criminal_neutralized(self._unit)
			end
	 
			if is_server then
				PlayerMovement.set_attention_settings(self, nil)
			end

			local session = managers.network:session()
			local peer_id = session and (session:local_peer():id() or 1)
			local interaction = (alive(self._unit) and (self._unit['interaction'] ~= nil)) and self._unit:interaction()
			if interaction and interaction.tweak_data and peer_id and interaction._owner_id and (interaction._owner_id == peer_id) then
				interaction:interact()
			end 
			
			self._unit:base():unregister()
			self._attention_obj = nil
		end
	end
end