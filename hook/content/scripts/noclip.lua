function in_chat()
	if managers.hud._chat_focus == true then
		return true
	end
	if ( managers.network.account and managers.network.account._overlay_opened ) then
		return true
	end
end

global_toggle_noclip = global_toggle_noclip or false
if not global_toggle_noclip then
	noclip = {
		axis_move = { 
			x = 0, 
			y = 0, 
			z = 0 
		}
	}

	local function update_position()
		local player = managers.player:player_unit()
		local camera_rot = player:camera():rotation()
		local move_dir = camera_rot:x() * noclip.axis_move.y + camera_rot:y() * noclip.axis_move.x + player:rotation():z() * noclip.axis_move.z
		local move_delta = move_dir * 10
		local pos_new = managers.player:player_unit():position() + move_delta

		managers.player:warp_to( pos_new, camera_rot, 1, Rotation(0, 0, 0) )
	end
	
	local function noclip_update()
		local kb = Input:keyboard()
		local kb_down = kb.down
		local player = managers.player:player_unit()

		if not managers.player:player_unit() then
			return
		end
		
		update_position()
		
		if not in_chat() then
			noclip.axis_move.x = (kb_down( kb, Idstring("w") ) and CommandManager.config.noclip.speed) or (kb_down( kb, Idstring("s") ) and -CommandManager.config.noclip.speed) or 0
			noclip.axis_move.y = (kb_down( kb, Idstring("d") ) and CommandManager.config.noclip.speed) or (kb_down( kb, Idstring("a") ) and -CommandManager.config.noclip.speed) or 0
			noclip.axis_move.z = (kb_down( kb, Idstring("space") ) and CommandManager.config.noclip.speed) or (kb_down( kb, Idstring("left ctrl") ) and -CommandManager.config.noclip.speed) or 0
		end
	 end
	
	--no fall dmg
	if not global_fall_dmg then global_fall_dmg = PlayerDamage.damage_fall end
	function PlayerDamage:damage_fall(data)
		return false
	end
	BetterDelayedCalls:Add("no_clip_loop", 0, function() noclip_update() end, true)
	managers.chat:_receive_message(1, "NoClip", "NoClip - ACTIVATED", tweak_data.system_chat_color)
else
	DelayedCalls:Add( "fall_dmg_off", 10, function()
		if not global_toggle_noclip then
			if global_fall_dmg then PlayerDamage.damage_fall = global_fall_dmg end
		end
	end)
	BetterDelayedCalls:Remove("no_clip_loop")
	managers.chat:_receive_message(1, "NoClip", "NoClip - DEACTIVATED", tweak_data.system_chat_color)
end
global_toggle_noclip = not global_toggle_noclip