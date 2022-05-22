local function is_converted(unit)
	if Network:is_client() and unit.is_converted and managers.groupai:state()._police[unit:key()] then
		return true
	end
	return false
end

function UnitNetworkHandler:reload_weapon_cop(unit, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(unit, sender) then
		return
	end

	local inventory = alive(unit) and unit:inventory()
	local weapon = inventory and inventory:equipped_unit()
	local weapon_base = weapon and weapon:base()
	local ammo_base = weapon_base and weapon_base:ammo_base()

	if ammo_base and is_converted(unit) then
		ammo_base:set_ammo_remaining_in_clip(math.huge)
	else
		ammo_base:set_ammo_remaining_in_clip(0)
	end
end