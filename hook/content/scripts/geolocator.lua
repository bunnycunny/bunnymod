local mod_name = "Geolocator"
local loaded = rawget(_G, mod_name)
local c = not loaded and rawset(_G, mod_name, {}) and _G[mod_name] or loaded
if not loaded then
	Color.brown = Color("a16b57")
	Color.orange = Color("fc933d")
	Color.blue = Color("3db9fc")
	
	function c:init()
		dofile("mods/Geolocator/JSON.lua")
		self.api_key = ""
		self.url = "https://api.ipdata.co/"
		self.url2 = "https://reallyfreegeoip.org/json/"
		self.spacer = "> "
		self.show_in_chat = CommandManager.config.automsg.enabled
		self.json = JSON
		self.dialog_closing_time = 0
		self.found_peers = {}
	end
	c:init()

	function c:get(t)
		return "" .. (t or "")
	end

	function c:set_api_key(api_key)
		self.api_key = api_key
	end

	function c:get_peer_data(wanted_peer)
		local peer_data = {}
		local t = wanted_peer and {[wanted_peer:id()] = wanted_peer} or self.session:peers()
		
		for peer_id, peer in pairs(t) do
			local user_id = peer:user_id()
			local ip = Network:get_ip_address_from_user_id(user_id)
			self.split_data = string.split(ip, ":")
			local a, b, c, d = self.split_data[1]:match("^(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)$")
			local tracker = (self.split_data[1] == "0.0.0.0" or string.begins(self.split_data[1], "192.168.")) and true

			if tracker and tonumber(a) == 192 and tonumber(c) < 128 then
				tracker = false
			end
			
			local username = managers.network.account:username_by_id(user_id)
			local alias = peer:name()
			local rank = peer:rank()
			local rpc = peer:steam_rpc() or peer:rpc()
			
			table.insert(peer_data, {
				peer = peer,
				name = alias == username and username or "Alias" .. self.spacer .. alias,
				rank = (rank <= 0 and "" or string.format("Rank%s%s", self.spacer, rank)),
				ip = "IP" .. self.spacer .. self.split_data[1], 
				port = self.split_data[2], 
				protocol = rpc:protocol_at_index(0),	-- "TCP_IP", "STEAM"
				tracker = (tracker and string.format("VPN%s%s", self.spacer, tracker) or ""), 
				peer_color = tweak_data.peer_colors[peer_id]:gsub("mr", ""):lower()
			})
		end
		return peer_data
	end

	function c:formated_result(data_result, keywords, sub_keywords)
		local country, city, region, time_zone, continent, call_code, asn, currency, threat = unpack(keywords)
		local result = {}

		for _, v in pairs(keywords) do
			if self.found_search[v] then
				if v == country then
					result[country] = {country = data_result[country] .. " "}
				elseif v == city then
					result[city] = {city = data_result[city] .. " "}
				elseif v == region then
					result[region] = {region = "Region" .. self.spacer .. data_result[region]}
				elseif v == continent then
					result[continent] = {continent = data_result[continent] .. " "}
				elseif v == call_code then
					result[call_code] = {code = "Calling Code" .. self.spacer .. data_result[call_code]}
				elseif v == asn then
					result[asn] = {type = data_result[asn].type .. " "}
				elseif v == currency then
					result[currency] = {name = "Currency" .. self.spacer .. data_result[currency].name}
				elseif v == time_zone then
					local a, b, c, d = data_result[time_zone].current_time:match("(%d+%D)(%d+%:%d+)(%:%d+)(%+%d+%:%d+)")
					result[time_zone] = {current_time = "Time Zone" .. self.spacer .. b .. " " .. d}
				elseif v == threat then
					result[threat] = {is_threat = "Ban" .. self.spacer .. "False"}
					for _, v in pairs(sub_keywords) do
						if self.found_search[threat][v] then
							result[threat] = {is_threat = "Ban" .. self.spacer .. "True"}
						end
					end
				end
			end
		end
		return result
	end

	function c:callback_data(http_data, url, keywords, sub_keywords)
		local sorted = {}
		local data = {}
		self.found_search = {}

		if not http_data or #http_data < 1 then
			self:print(string.format("Server is down> %s |%s %s|", url, self.last_ip_search, self.url))
			if url == self.url then
				self.req_denied.server1 = self.req_denied.server1 + 1
			else
				self.req_denied.server2 = self.req_denied.server2 + 1
			end
		elseif self.json then
			data = self.json:decode(http_data)
		end

		for _, keyword in pairs(keywords) do
			if data[keyword] then
				if type(data[keyword]) == "table" then
					for _, sub_keyword in pairs(sub_keywords) do
						if (type(data[keyword][sub_keyword]) == "boolean" or data[keyword][sub_keyword] and #data[keyword][sub_keyword] > 0) then
							self.found_search[keyword] = self.found_search[keyword] or {}
							self.found_search[keyword][sub_keyword] = true
						end
					end
				elseif #data[keyword] > 0 then
					self.found_search[keyword] = true
				end
				sorted[keyword] = data[keyword]
			else
				sorted[keyword] = {}
			end
		end
		return self:formated_result(sorted, keywords, sub_keywords)
	end

	function c:try_server_1(index, wanted_peer)
		dohttpreq(
			self.url .. self.last_ip_search .. "?api-key=" .. self.api_key,
			function(http_data)
				local keywords = {
					"country_name", "city", "region", "time_zone", "continent_name", "calling_code", "asn",
					"currency", "threat"
				}
				local sub_keywords = {
					"type", "name", "current_time", "is_tor", "is_proxy", "is_anonymous", "is_known_attacker",
					"is_known_abuser", "is_threat", "is_bogon"
				}
				local country, city, region, time_zone, continent, call_code, asn, currency, threat = unpack(keywords)
				local f = self:callback_data(http_data, self.url, keywords, sub_keywords)

				self:print(
					string.format("%s %s", index.protocol, index.rank),
					(self:get(f[asn].type) == "hosting" and nil or self:get(f[continent].continent) .. self:get(f[time_zone].current_time)),
					(self:get(f[asn].type) == "hosting" and nil or self:get(f[country].country) .. self:get(f[call_code].code)),
					(self:get(f[asn].type) == "hosting" and nil or self:get(f[city].city) .. self:get(f[region].region)),
					(self:get(f[asn].type) == "hosting" and nil or self:get(f[currency].name)),
					self:get(f[asn].type) .. self:get(f[threat].is_threat),
					{
						server = 1,
						wanted_peer = wanted_peer,
						color = index.peer_color,
						name = string.format("%s (%s)", index.name, index.peer:id())
					}
				)
			end
		)
	end

	function c:try_server_2(index, wanted_peer)
		dohttpreq(
			self.url2 .. self.last_ip_search,
			function(http_data)
				local keywords = {
					"country_name", "city", "region_name"
				}
				local sub_keywords = {}
				local country, city, region = unpack(keywords)
				local f = self:callback_data(http_data, self.url, keywords, sub_keywords)
				
				self:print(
					string.format("%s %s", index.protocol, index.rank),
					(index.tracker and nil or self:get(f[country].country) .. self:get(f[region].region)),
					(index.tracker and nil or self:get(f[city].city) .. index.ip),
					index.tracker,
					{
						server = 2,
						wanted_peer = wanted_peer,
						color = index.peer_color,
						name = string.format("%s (%s)", index.name, index.peer:id())
					}
				)
			end
		)
	end
	
	function c:request(wanted_peer)
		self.req_denied = {server1 = 0, server2 = 0}
		local peer_data = self:get_peer_data(wanted_peer)
		
		for i= 1, #peer_data do
			local index = peer_data[i]
			self.last_ip_search = self.split_data[1]

			if CommandManager:vis("get_api_key") or #self.api_key > 0 then
				self:try_server_1(index, wanted_peer)
				
				if self.req_denied.server1 > 0 then
					self:print("Request denied from server: 1")
					self:try_server_2(index, wanted_peer)
				end
			else
				self:try_server_2(index, wanted_peer)
				
				if self.req_denied.server2 > 0 then
					self:print("Request denied from server: 2")
					self:try_server_1(index, wanted_peer)
				end
			end
		end
		
		if self.req_denied.server1 > 0 and self.req_denied.server2 > 0 then
			self:print("Both servers are down - " .. (self.req_denied.server2 + self.req_denied.server1) .. " tries")
		end
	end
	
	function c:keybind_request()
		self.session = BaseNetworkHandler._verify_in_session()
		if self.session then
			local is_active = managers.system_menu:is_active()
			if is_active and not managers.system_menu:is_closing() and (Application:time() - self.dialog_closing_time) < 0.2 then
				managers.system_menu:force_close_all()
			elseif not is_active then
				self:request()
			end
			self.dialog_closing_time = Application:time()
		end
	end
	
	function c:hook_request(peer)
		self.session = self.session or BaseNetworkHandler._verify_in_session()
		local user_id = peer:user_id()
		
		if not self.found_peers[user_id] and self.session then
			local local_id = self.session:local_peer()
			if local_id and peer:id() ~= local_id:id() then
				self.found_peers[user_id] = true
				self:request(peer)
			end
		end
	end
	
	function c:print(...)
		local targs = {...}
		
		if #targs == 0 then
			return
		end

		local last_index = select("#", ...)
		local t = type(targs[last_index]) == "table" and targs[last_index]
		local args = ""
		
		for k, v in pairs(targs) do
			if t and k == #targs then
				break
			end
			
			args = string.format("%s\n%s", args, v)
		end	
		args = args:sub(2, #args)
		
		if t then
			local chat = t.wanted_peer and managers.chat
			
			if chat then
				local chat_color = Color[t.color] or Color.green
				
				chat:_receive_message(1, t.name, args, chat_color)
			else
				self:open_menu(t, args)
			end
		else
			managers.mission._fading_debug_output:script().log(args, Color.red)
		end
	end
	
	function c:open_menu(t, args)
		local dialog_data = {
			title = string.format("%s (%s)%s", t.name, t.color, (t.server == 1 and self.spacer .. self.last_ip_search or "")),
			text = "\n" .. args,
			button_list = {
				{},
				{
					text = managers.localization:text("dialog_cancel"),
					cancel_button = true
				}
			}
		}
		managers.system_menu:show_buttons(dialog_data)
	end

	local orig_func_send = NetworkPeer.send
	function NetworkPeer:send(func, ...)
		orig_func_send(self, func, ...)
		if c.show_in_chat and func and (func == "sync_profile" or func == "lobby_info") then
			DelayedCalls:Add(tostring(TimerManager:game():time()), 5, function()
				c:hook_request(self)
			end)
		end
	end
end

if RequiredScript ~= "lib/network/base/networkpeer" then
	c:keybind_request()
end