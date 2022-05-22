global_afk_toggle = global_afk_toggle or false
if not rawget(_G, "moreafk") then
	rawset(_G, "moreafk", {
		table_list = {},
		orig_func_md = PlayerStandard._determine_move_direction,
		afk_toggle_on = false,
		start_delay = true,
		jail_time_min = CommandManager.config.afk.jailtime/60,
		total_time = CommandManager.config.afk.jailtime,
		timer_decimal = CommandManager.config.afk.timerdecimals,
		spam_timer = 0,
		antispam_timer = 60,
		
		gcs = managers.player._current_state,
		a_states = {
			"standard",
			"civilian",
			"clean",
			"mask_off",
			"carry"
		}
	})
	
	function moreafk:round(number, decimals)
		local int = number
		local power = 10^decimals
		if number <= 1 then
			int = int*60
			return string.format("'%s'sec", tostring(math.floor(int*power)/power))
		else
			return string.format("'%s'min", tostring(math.floor(int*power)/power))
		end
	end
	
	function moreafk:display_msg(msg)
		if CommandManager.config.afk.annoucechat then
			managers.chat:send_message(ChatManager.GAME, 1, msg)
		else
			managers.chat:_receive_message(1, "AFK", tostring(managers.network:session():local_peer():name()).." "..msg, tweak_data.system_chat_color)
		end
	end
	
	function moreafk:start_timer()
		self.start_delay = false
		BetterDelayedCalls:Add("afk_antiispam", self.antispam_timer, function() 
			self.table_list = {}
			self.start_delay = true
			managers.chat:_receive_message(1, "AFK", string.format("AFK is available again."), tweak_data.system_chat_color)
		end, false)
	end

	function PlayerStandard._determine_move_direction(self, ...)
		moreafk.orig_func_md(self, ...)
		if self._move_dir or self._normal_move_dir
		or (self._controller:get_input_bool("primary_attack")) 
		--or (self._controller:get_input_bool("secondary_attack")) 
		--or (self._controller:get_input_pressed("throw_grenade"))
		--or (self._controller:get_input_pressed("duck"))
		or (self._controller:get_input_pressed("reload")) 
		or (self._controller:get_input_pressed("switch_weapon")) 
		or (self._controller:get_input_pressed("jump")) 
		or (self._controller:get_input_pressed("interact")) 
		or (self._controller:get_input_pressed("use_item")) 
		or (self._controller:get_input_pressed("melee")) then
			if moreafk.afk_toggle_on then
				table.insert(moreafk.table_list, math.random(1, 10000))
				if global_invisible_toggle then
					dofile("mods/hook/content/scripts/invisibleplayer.lua")
				end
				BetterDelayedCalls:Remove("afk_idle")
				BetterDelayedCalls:Remove("afk_punish")
				BetterDelayedCalls:Remove("afk_mode_teleport")
				moreafk:display_msg("has come back and is no longer AFK.")
				global_afk_toggle = not global_afk_toggle
				moreafk.afk_toggle_on = false
			end
		end
	end
	
	function moreafk:dcall_idle()
		if tonumber(CommandManager.config.afk.jailtimenotify) then
			moreafk.notify_time_min = CommandManager.config.afk.jailtimenotify/60
			BetterDelayedCalls:Add("afk_idle", CommandManager.config.afk.jailtimenotify, function() 
				moreafk.total_time = moreafk.total_time + CommandManager.config.afk.jailtimenotify
				if CommandManager.config.afk.jail then
					self:display_msg(string.format("has been AFK more then %s. %s left before going to jail.",  moreafk:round(moreafk.notify_time_min, moreafk.timer_decimal), moreafk:round(moreafk.jail_time_min, moreafk.timer_decimal)))
				else
					self:display_msg(string.format("has been AFK more then %s. %s left before leaving the game.", moreafk:round(moreafk.notify_time_min, moreafk.timer_decimal), moreafk:round(moreafk.jail_time_min, moreafk.timer_decimal)))
				end
			end, false)
		end
	end
	
	function moreafk:dcall_punish()
		BetterDelayedCalls:Add("afk_punish", self.total_time, function()
			if CommandManager.config.afk.jail then
				local player = managers.player:local_player()
				managers.player:force_drop_carry()
				managers.statistics:downed({death = true})
				IngameFatalState.on_local_player_dead()
				game_state_machine:change_state_by_name("ingame_waiting_for_respawn")
				player:character_damage():set_invulnerable(true)
				player:character_damage():set_health(0)
				player:base():_unregister()
				player:base():set_slot(player, 0)
				self:display_msg("has been jailed for AFKing and will be released when back.")
			else
				self:display_msg("has left for AFKing too long.")
				MenuCallbackHandler:_dialog_end_game_yes()
			end
		end, false)
	end
	
	function moreafk:invisible()
		if not global_invisible_toggle then
			dofile("mods/hook/content/scripts/invisibleplayer.lua")
		end
		self.afk_toggle_on = true
	end
	
	function moreafk:teleport(id)
		BetterDelayedCalls:Add("afk_mode_teleport", CommandManager.config.afk.teleport, function()
			local ids = id
			for _, peer in pairs(managers.network:session():peers()) do
				if (peer:id() ~= id and peer and alive(peer:unit())) then
					ids = peer:id()
				end
			end
			moreafk.peer = managers.network:session():peer(ids)
			if self.peer and alive(self.peer:unit()) then
				moreafk.pos = self.peer:unit():position()
				managers.player:warp_to(Vector3(self.pos.x + 40, self.pos.y, self.pos.z + 50), self.peer:unit():rotation())
				managers.mission._fading_debug_output:script().log(string.format("Teleported to %s", self.peer:name()),  Color.green)
			end
		end, true)
		self:display_msg("has gone AFK. He will not be a targeted by enemies while gone and will keep close to a player.")
	end
	
	function moreafk:GetPlayer()
		moreafk.AlivePeers = {}
		for _, peer in pairs(managers.network:session():peers()) do
			if (peer and alive(peer:unit())) then
				if (peer:id() ~= managers.network:session():local_peer():id()) then
					table.insert(self.AlivePeers, peer:id())
				end
			end
		end
		return self.AlivePeers[math.random(1, #moreafk.AlivePeers)]
	end
	
	function moreafk:check_state()
		if (self.gcs == self.a_states[1] or self.gcs == self.a_states[2] or self.gcs == self.a_states[3] or self.gcs == self.a_states[4] or self.gcs == self.a_states[5]) then
			return true
		else
			return false
		end
	end
	
	function moreafk:toggleafk()
		BetterDelayedCalls:Remove("afk_antiispam")
		if not global_afk_toggle then
			if CommandManager:is_playing() then
				if alive(managers.player:player_unit()) and self:check_state() then
					if CommandManager.config.afk.teleport then
						if Network:is_server() then
							moreafk.players = self:GetPlayer()
							if (self.players == nil) then
								managers.chat:_receive_message(1, "AFK", "Could not find someone to teleport to, you will only be invisible.", tweak_data.system_chat_color)
								self:display_msg("has gone AFK. He will not be a targeted by enemies while gone.")
							else
								self:teleport(self.players)
							end
						else
							self:teleport(1)
						end
					else
						self:display_msg("has gone AFK. He will not be a targeted by enemies while gone.")
					end
					self:invisible()
					self:dcall_idle()
					self:dcall_punish()
				else
					managers.chat:_receive_message(1, "AFK", string.format("Can't AFK in %s state.", tostring(self.gcs)), tweak_data.system_chat_color)
					global_afk_toggle = not global_afk_toggle
				end
			else
				self:display_msg("has gone AFK.")
			end
		else
			table.insert(self.table_list, math.random(1, 10000))
			BetterDelayedCalls:Remove("afk_idle")
			BetterDelayedCalls:Remove("afk_punish")
			BetterDelayedCalls:Remove("afk_mode_teleport")
			if CommandManager:is_playing() then
				if not alive(managers.player:player_unit()) then
					IngameWaitingForRespawnState.request_player_spawn()
				end
				if global_invisible_toggle then
					dofile("mods/hook/content/scripts/invisibleplayer.lua")
				end
				self.afk_toggle_on = false
			end
			self:display_msg("has come back and is no longer AFK.")
		end
		global_afk_toggle = not global_afk_toggle
	end
	
	function moreafk:_toggle()
		if (self.table_list ~= nil and #moreafk.table_list >= 10) or ((Application:time() - self.spam_timer) < 0.3 and not self.toggle) then
			for i=1,10 do
				table.insert(self.table_list, math.random(1, 10000))
			end
			if BetterDelayedCalls._calls["afk_antiispam"] and BetterDelayedCalls._calls["afk_antiispam"].currentTime then
				moreafk.time_left = (BetterDelayedCalls:RemainingTime("afk_antiispam")) / 60
				managers.chat:_receive_message(1, "AFK", string.format("Wait %s before you can use it again.", self:round(self.time_left, self.timer_decimal)), tweak_data.system_chat_color)
			else
				managers.chat:_receive_message(1, "AFK", string.format("You have AFKed too many times or abused it. Wait '%s'sec before you can use it again.", self.antispam_timer), tweak_data.system_chat_color)
			end
			if self.start_delay then
				self:start_timer()
			end
		else
			self:toggleafk()
		end
		self.spam_timer = Application:time()
	end
	if not CommandManager:in_game() or CommandManager:is_playing() then
		moreafk:_toggle()
	else
		managers.chat:_receive_message(1, "AFK", string.format("You can't AFK in briefing rooms - ready up!"), tweak_data.system_chat_color)
	end
else
	if not CommandManager:in_game() or CommandManager:is_playing() then
		moreafk:_toggle()
	else
		managers.chat:_receive_message(1, "AFK", string.format("You can't AFK in briefing rooms - ready up!"), tweak_data.system_chat_color)
	end
end