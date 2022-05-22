local class_name = "hook_mod_identifier1712"
local req_script = table.remove(RequiredScript:split("/"))
local loaded = rawget(_G, class_name)
local c = not loaded and rawset(_G, class_name, {}) and _G[class_name] or loaded

if not loaded then
	c.notify_on_join = true							-- Use notify_join_msg
	c.notify_color = Color("39FF14")				-- Color of the join message or false for default
	c.recived_peers = {}
end

if string.lower(req_script) == string.lower("NetworkPeer") and _G["NetworkPeer"] ~= nil then
	--send as client/host
	Hooks:PostHook(NetworkPeer, "send", class_name.."1", function(self, func_name, ...)
		local local_id = managers.network:session():local_peer()
		if self:id() ~= local_id:id() and func_name and func_name == "lobby_info" and self:ip_verified() then
			LuaNetworking:SendToPeer(self:id(), class_name, local_id:id())
		end
	end)

	--receive as client/host
	Hooks:Add("NetworkReceivedData", class_name.."2", function(peer_id, id, data)
		if id == class_name then
			local sender = data and managers.network:session():peer(tonumber(data))
			if c.notify_on_join and sender and not c.recived_peers[sender:user_id()] then
				c.recived_peers[sender:user_id()] = true
				managers.chat:_receive_message(1, "HOOK", string.format("Detection from %s.", sender:name()), (c.notify_color or tweak_data.system_chat_color))
			end
		end
	end)
end
