--update spoofname

if not CommandManager or not CommandManager.config or not CommandManager.config.fake_name then
	return
end

CommandManager.config.real_name = Steam:username()
CommandManager:Save()

local spoofname = CommandManager.config.fake_name
local spooflvl = CommandManager.config.fake_level
local spoofrank = CommandManager.config.fake_rank
local delay = 0.1

local function load_data()
	CommandManager.config.real_level = managers.experience:current_level()
	CommandManager.config.real_rank = managers.experience:current_rank()
	CommandManager:Save()
	
	if CommandManager.config["first_load"] then		
		spoofname = CommandManager.config.real_name
		spoofrank = CommandManager.config.real_rank
		spooflvl = CommandManager.config.real_level
		
		CommandManager.config.first_load = not CommandManager.config.first_load
		CommandManager.config.fake_name = spoofname
		CommandManager.config.fake_level = spooflvl
		CommandManager.config.fake_rank = spoofrank
		
		CommandManager:Save()
	end
end

local function replace_lobby_name()
	local SteamClass = getmetatable(Steam)
	if SteamClass then
		local orig_username = SteamClass.username
		function SteamClass:username(userid, ...)
			if not CommandManager.config.first_load and (not userid or (userid and userid == SteamClass.userid(Steam))) then
				return spoofname
			end
			return orig_username(self, userid, ...)
		end
	end
end

local function get_peer_info(peer, peer_id)
	DelayedCalls:Add("hook_spoofer_get_peer_info_id"..tostring(math.random()), delay, function()
		local session = managers.network and managers.network:session()
		if session then
			if not peer and peer_id then
				peer = session:peer(peer_id)
			end
			
			local me = session:local_peer()
			if peer and peer:id() ~= me:id() then
				peer:send("request_player_name_reply", spoofname)
				if managers.hud then
					managers.hud:update_name_label_by_peer(me)
				end
				local join_stinger_index = managers.infamy:selected_join_stinger_index()
				local character = me:character()
				local mask_set = "remove"
				peer:send("lobby_info", (CommandManager.config.spoof_level and spooflvl or managers.experience:current_level()), (CommandManager.config.spoof_rank and spoofrank or managers.experience:current_rank()), join_stinger_index, character, mask_set)
			else
				me:set_name(spoofname)
			end
		end
	end)
end

if BetterDelayedCalls then
	BetterDelayedCalls:Add("persist_delay_call_spoofname", delay, function()
		if Utils:IsInHeist() then
			return
		end
		if (CommandManager.config["real_name"] ~= CommandManager.config["fake_name"] or CommandManager.config["real_level"] ~= CommandManager.config["fake_level"] or CommandManager.config["real_rank"] ~= CommandManager.config["fake_rank"]) then
			local session = managers.network and managers.network:session()
			if session then
				local me = session:local_peer()
				local join_stinger_index = managers.infamy:selected_join_stinger_index()
				local character = me:character()
				local mask_set = "remove"
				me:set_name(CommandManager.config.fake_name)
				for _, peer in pairs(session:peers()) do
					if peer then
						if peer:id() ~= me:id() then
							peer:send("request_player_name_reply", spoofname)
						end
						peer:send("lobby_info", (CommandManager.config.spoof_level and spooflvl or managers.experience:current_level()), (CommandManager.config.spoof_rank and spoofrank or managers.experience:current_rank()), join_stinger_index, character, mask_set)
					end
				end
				if managers.hud then
					managers.hud:update_name_label_by_peer(me)
				end
			end
		end
	end, true)
end

if _G["ExperienceManager"] and _G["ExperienceManager"] ~= nil then
	function ExperienceManager:gui_string(level, rank, offset, peer)
		load_data()
		replace_lobby_name()
		local current_rank = managers.experience:current_rank()
		local current_level = managers.experience:current_level()
		local session = managers.network and managers.network:session()
		local me = session and session:local_peer()
		offset = offset or 0
		local gui_string
		local rank_string
		
		if (peer and me and peer:id() == me:id()) or CommandManager.config.spoof_level and CommandManager.config.spoof_rank then
			rank_string = rank > 0 and string.format("%s (%s)", self:rank_string(rank), self:rank_string(spoofrank, false)) or ""
			if rank > 0 then
				gui_string = string.format("%s - %s (%s)", rank_string, tostring(level), tostring(spooflvl))
			else
				gui_string = string.format("%s (%s)", tostring(level), tostring(spooflvl))
			end
		else
			rank_string = rank > 0 and string.format("%s (%s)", self:rank_string(rank), self:rank_string(rank, false)) or ""
			if rank > 0 then
				gui_string = string.format("%s - %s", rank_string, tostring(level))
			else
				gui_string = tostring(level)
			end
		end
		local rank_color_range = {{
			start = offset,
			stop = offset+utf8.len(rank_string),
			color = tweak_data.screen_colors.infamy_color
		}}
		return gui_string, rank_color_range
	end
end

if _G["HUDManager"] and _G["HUDManager"] ~= nil then
	function HUDManager:update_name_label_by_peer(self, peer, ...)
		local hud = self._hud and self._hud.name_labels or {}
		for _, data in pairs(hud) do
			if data then
				local me = managers.network:session():local_peer()
				local name = data.character_name
				if peer:level() then
					local color_range_offset = utf8.len(name) + 2
					local experience, color_ranges = managers.experience:gui_string(peer:level(), peer:rank(), color_range_offset, peer)
					data.name_color_ranges = color_ranges
					name = name .. " (" .. experience .. ")"
				end
				data.text:set_text(name)
				for _, color_range in ipairs(data.name_color_ranges or {}) do
					data.text:set_range_color(color_range.start, color_range.stop, color_range.color)
				end
				self:align_teammate_name_label(data.panel, data.interact)
				break
			end
		end
	end
end

if _G["NetworkManager"] and _G["NetworkManager"] ~= nil then
	Hooks:PostHook(NetworkManager, "on_peer_added", "hook_name_spoofer_on_peer_added", function(self, peer, peer_id)
		get_peer_info(peer, peer_id)
	end)
end

if _G["NetworkPeer"] and _G["NetworkPeer"] ~= nil then
	Hooks:PostHook(NetworkPeer, "sync_lobby_data", "hook_name_spoofer_sync_lobby_data", function(self, peer)
		get_peer_info(peer, peer_id)
	end)
	
	function NetworkPeer:real_name()
		if not self._real_name then
			self._real_name = Steam:username(self._user_id)
		end
		return self._real_name
	end
end

if _G["GamePlayCentralManager"] and _G["GamePlayCentralManager"] ~= nil then
	Hooks:PostHook(GamePlayCentralManager, "start_heist_timer", "hook_name_spoofer_start_heist_timer", function(self)
		for _, peer in pairs(managers.network:session():peers()) do
			get_peer_info(peer, peer:id())
		end
	end)
end

if _G["ConnectionNetworkHandler"] and _G["ConnectionNetworkHandler"] ~= nil then
	Hooks:PreHook(ConnectionNetworkHandler, "kick_peer", "hook_name_spoofer_kick_peer", function(self, peer_id, message_id, sender)
		get_peer_info(peer, peer_id)
	end)
	
	ConnectionNetworkHandler.stored_names = {}
	function ConnectionNetworkHandler:request_player_name_reply(name, sender)
		local peer = self._verify_sender(sender)
		if peer and self.stored_names[peer._user_id] == nil then
			local real_name = peer:real_name()
			self.stored_names[peer._user_id] = real_name
			if real_name and tostring(name) ~= tostring(real_name) then
				DelayedCalls:Add('real2', 2, function()
					if _G["GameSetupUpdate"] == nil and _G["MenuUpdate"] == nil then return end
					if managers.chat then
						local s_f = string.format("%s's steam name did not match with their game username: %s", real_name, name)
						managers.chat:_receive_message(1, "Name Spoof", s_f, tweak_data.system_chat_color)
					end
				end)
				local string_F = string.format("%s (%s)", real_name, name)
				peer:set_name(string_F)
			else
				peer:set_name(real_name)
			end
		end
	end
end