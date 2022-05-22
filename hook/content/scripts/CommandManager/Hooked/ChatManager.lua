local orig_send = ChatManager.send_message
function ChatManager:send_message(channel_id, sender, message)
	if managers.network:session() then
		sender = managers.network:session():local_peer()
		if rawget(_G, "CommandManager") then
			if CommandManager:prefixes(message) and sender then
				if sender and CommandManager.process_input then
					CommandManager:process_input(message, sender:id())
					return
				end
			end
		end
		orig_send(self, channel_id, sender, message)
	end
end

local orig_receive = ChatManager.receive_message_by_peer
function ChatManager:receive_message_by_peer(channel_id, peer, message)
	if rawget(_G, "CommandManager") then
		if message:sub(1, 11) == "[PRIVATE]: " then
			CommandManager.peer_to_reply = peer
		end
	end

	orig_receive(self, channel_id, peer, message)
end

ChatGui.selected_command = 0
local orig = ChatGui.key_press
function ChatGui:key_press(o, k)
	orig(self, o, k)

	local text = self._input_panel:child("input_text")
	if self._key_pressed == Idstring("up") then
		self.selected_command = (self.selected_command + 1) % (#CommandManager.history + 1)
		local _text = CommandManager.history[self.selected_command] or ''

		text:set_text(_text)
	elseif self._key_pressed == Idstring("down") then
		self.selected_command = ( self.selected_command - 1 ) % -1

		local _text = CommandManager.history[self.selected_command] or ''
		text:set_text(_text)
	elseif (self._key_pressed == Idstring("enter")) or (self._key_pressed == Idstring("escape")) then
		self.selected_command = 0
		text:set_text('')
	end
end
function ChatManager:feed_system_message(channel_id, message)
	if not Global.game_settings.single_player then
		local time = os.date("*t")

		local add_zero_hour = ""
		local add_zero_minutes = ""
		local add_zero_seconds = ""

		if string.len(time.hour) == 1 then
			add_zero_hour = "0"
		end

		if string.len(time.min) == 1 then
			add_zero_minutes = "0"
		end

		if string.len(time.sec) == 1 then
			add_zero_seconds = "0"
		end

		local concatenate_system_and_hour = "[" .. add_zero_hour .. time.hour .. ":" .. add_zero_minutes .. time.min .. ":" .. add_zero_seconds .. time.sec .. "] " .. managers.localization:to_upper_text("menu_system_message")

		self:_receive_message(channel_id, concatenate_system_and_hour, message, tweak_data.system_chat_color)
	end
end

function ChatGui:receive_message(name, message, color, icon)
	if not alive(self._panel) or not managers.network:session() then
		return
	end
	local output_panel = self._panel:child("output_panel")
	local scroll_panel = output_panel:child("scroll_panel")
	local local_peer = managers.network:session():local_peer()
	local peers = managers.network:session():peers()
	local len = utf8.len(name) + 1
	local x = 0
	local icon_bitmap
	local time = os.date("*t")

	local add_zero_hour = ""
	local add_zero_minutes = ""
	local add_zero_seconds = ""

	if string.len(time.hour) == 1 then
		add_zero_hour = "0"
	end

	if string.len(time.min) == 1 then
		add_zero_minutes = "0"
	end

	if string.len(time.sec) == 1 then
		add_zero_seconds = "0"
	end
	local hour = add_zero_hour .. time.hour .. ":" .. add_zero_minutes .. time.min .. ":" .. add_zero_seconds .. time.sec .. " "
	if icon then
		local icon_texture, icon_texture_rect = tweak_data.hud_icons:get_icon_data(icon)
		icon_bitmap = scroll_panel:bitmap({
			texture = icon_texture,
			texture_rect = icon_texture_rect,
			color = color,
			y = 1
		})
		x = icon_bitmap:right()
	end

	local name2 = name .. " | " .. hour

	local line = scroll_panel:text({
		text = name2 .. ": " .. message,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		x = x,
		y = 0,
		align = "left",
		halign = "left",
		vertical = "top",
		hvertical = "top",
		blend_mode = "normal",
		wrap = true,
		word_wrap = true,
		w = scroll_panel:w() - x,
		color = color,
		layer = 0
	})

	local total_len = utf8.len(line:text())
	line:set_range_color(0, len, color)
	line:set_range_color(len, total_len, Color.white)
	local _, _, w, h = line:text_rect()
	line:set_h(h)
	local line_bg = scroll_panel:rect({
		color = Color.black:with_alpha(0.5),
		layer = -1,
		halign = "left",
		hvertical = "top"
	})
	line_bg:set_h(h)
	line:set_kern(line:kern())
	table.insert(self._lines, {
		line,
		line_bg,
		icon_bitmap
	})
	self:_layout_output_panel()
	if not self._focus then
		output_panel:stop()
		output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
		output_panel:animate(callback(self, self, "_animate_fade_output"))
		self:start_notify_new_message()
	end
end