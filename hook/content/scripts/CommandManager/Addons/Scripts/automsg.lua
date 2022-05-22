--auto talk to players on join
local check_peer_exist = {0,0,0,0}
local orig_nm_opa = NetworkManager.on_peer_added
function NetworkManager.on_peer_added(self, peer, peer_id)
	orig_nm_opa(self, peer, peer_id)
	if CommandManager.config.automsg.enabled then
		if Network:is_client() and CommandManager.config.automsg.client then
			local stealth_level_table = {
				"tag",
				"cage", 
				"fish", --stealth only
				"dark",
				"kosugi",
				
				"galley",
				"framing_frame_1", 
				"framing_frame_2", 
				"framing_frame_3", 
				--"branchbank",
				--"welcome_to_the_jungle_1",
				--"family", 
				"election_day_1", 
				--"election_day_2", 
				"firestarter_1",
				--"firestarter_2",
				--"firestarter_3",
				--"red2",
				--"four_stores", 
				--"roberts",
				--"kenaz", 
				--"hox_3",
				--"jewelry_store",
				--"Nightclub", 
				--"friend", 
				--"sah",
				--"arena", 
				"big",
				--"crojob2",
				"mus",
				--"arm_for",
				--"ukrainian_job",
				--"mex",
			}
			
			if managers.network:session() then
				DelayedCalls:Add("client_auto_msg"..peer_id, 2, function()
					local welcomemsg = {
						"Hey", "Whaddup",
						"Hello", "WHAZZUP", 
						"How are things", 
						"Howdy", "Hi", 
						"YO", "Whats up", 
						"Whats kickin", 
						"Howdy-doody",
						"BONJOUR", "Hola",
						"Ciao", "Aloha!"
					}
					local peer_host = managers.network:session():peer(1)
					local generate_msg
					if CommandManager.config.automsg.clientmsg == "reset" then
						generate_msg = welcomemsg[math.random(1, #welcomemsg)]
					else
						generate_msg = CommandManager.config.automsg.clientmsg
					end
					local welcomemessage = string.format("%s %s", generate_msg, peer:name())
					local welcomemessage2 = string.format("%s %s", generate_msg, peer_host:name())

					if peer_host:id() then
						if not CommandManager.config.automsg.checks.host_msg_recived then
							managers.chat:send_message(ChatManager.GAME, 1, welcomemessage2)
							CommandManager.config.automsg.checks.host_msg_recived = true
							CommandManager:Save()
						end
					end
					
					local id = peer:id()
					local cpe = check_peer_exist[id]
					if peer and not (peer_id == peer_host:id()) and (cpe < 4) then
						managers.chat:send_message(ChatManager.GAME, peer_id, welcomemessage)
						check_peer_exist[id] = cpe + 1
					end
				end)
				
				if not is_playing() and game_state_machine then
					for _, data in pairs(stealth_level_table) do
						if (managers.job:current_level_id() == data) then
							global_toggle_msg2 = false
							if not CommandManager.config.automsg.checks.safe_msg_recived then
								DelayedCalls:Add("stealth_auto_msg", 4, function()
									managers.chat:send_message(ChatManager.GAME, 1, "Is it safe to join?")
								end)
								CommandManager.config.automsg.checks.safe_msg_recived = true
								CommandManager:Save()
							end
						end
					end
				end
			else
				CommandManager.config.automsg.checks.host_msg_recived = false
				CommandManager.config.automsg.checks.safe_msg_recived = false
			end
		elseif Network:is_server() and CommandManager.config.automsg.host then
			local peer1 = managers.network:session() and managers.network:session():peer(peer_id)
			if peer1 then
				DelayedCalls:Add("host_auto_msg", 5, function()
					managers.chat:send_message(1, managers.network.system, CommandManager.config.automsg.hostmsg..peer:name().." ---")
				end)
			end
		end
	end
end