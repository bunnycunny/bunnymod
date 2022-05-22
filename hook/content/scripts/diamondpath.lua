if not managers.mission then return end
if managers.job and (managers.job:current_level_id() ~= 'mus') then return end
if managers.chat then
	managers.chat:feed_system_message(ChatManager.GAME, "P.S Activate after the full path is shown in terminal")
end

_path_tile = _path_tile or 0
_path_terminated = _path_terminated or false

Color.purple = Color("9932CC")
Color.labia = Color("E75480")
Color.gold = Color("FFD700")
Color.silver = Color("CFCFC4")
Color.bronze = Color("CD7F32")
Color.neongreen = Color("39FF14")
Color.lilac = Color("D891EF")
Color.brown = Color("6B4423")
Color.grey = Color("B2BEB5")
Color.limited = Color("4F7942")
Color.unlimited = Color("FDEE00")
Color.pro = Color("7BB661")
Color.wip = Color("0D98BA")

--change color of path
mark_color_changer = Color.gold

function in_table(table, value) -- Is element in table
	if type(table) == 'table' then
		for i,x in pairs(table) do
			if x == value then
				return true
			end
		end
	end
	return false
end

local function clear_path()
	for id,_ in pairs( clone( managers.hud._hud.waypoints ) ) do
		id = tostring(id)
		if id:sub(1,9) == 'dia_path_' then
			managers.hud:remove_waypoint( id ) 
		end
	end
end

local function check_path()
	for id, unit in pairs( managers.interaction._interactive_units ) do
		if unit:interaction().tweak_data == 'hack_electric_box' then
			BetterDelayedCalls:Add("diamond_path_loop", 0.01, function() check_path() end, true)
			clear_path()
			showpath = not showpath
		end
	end
end
local function dia_path()
	--local _path_ok = _script_activated - _path_created
	local _path_ok = 15
	local Color = Color
	_path_terminated = false
	local tiles_all = {
-- FLOOR
		["133577"] = Vector3(6475, 700, -600),	-- a001
		["133578"] = Vector3(6475, 500, -600),	-- a002
		["133579"] = Vector3(6475, 300, -600),	-- a003
		["133580"] = Vector3(6475, 100, -600),	-- a004
		["133581"] = Vector3(6475, -100, -600),	-- a005
		["133582"] = Vector3(6475, -300, -600),	-- a006
-- A --
		["133583"] = Vector3(6675, 700, -600),	-- b001		UP
		["133584"] = Vector3(6675, 500, -600),	-- b002		UP
		["133585"] = Vector3(6675, 300, -600),	-- b003		UP
		["133586"] = Vector3(6675, 100, -600),	-- b004		UP
		["133587"] = Vector3(6675, -100, -600),	-- b005		UP
		["133588"] = Vector3(6675, -300, -600),	-- b006		UP
-- B --
		-- b001 : 133631
		["133638"] = Vector3(6675, 500, -600),	-- b002		RIGHT
		["133589"] = Vector3(6875, 700, -600),	-- c001		UP
		-- b002 : 133633
		["133640"] = Vector3(6675, 300, -600),	-- b003		RIGHT
		["133590"] = Vector3(6675, 300, -600),	-- c002		UP
		["133639"] = Vector3(6675, 700, -600),	-- b001		LEFT
		-- b003 : 133634
		["133591"] = Vector3(6875, 300, -600),	-- c003		UP
		["133642"] = Vector3(6675, 100, -600),	-- b004		RIGHT
		["133641"] = Vector3(6675, 500, -600),	-- b002		LEFT
		-- b004 : 133635
		["133592"] = Vector3(6875, 100, -600),	-- c004		UP
		["133643"] = Vector3(6675, 300, -600),	-- b003		LEFT
		["133645"] = Vector3(6675, -100, -600),	-- b005		RIGHT
		-- b005 : 133636
		["133593"] = Vector3(6875, -100, -600),	-- c005		UP
		["133647"] = Vector3(6675, -300, -600),	-- b006		RIGHT
		["133644"] = Vector3(6675, 100, -600),	-- b004		LEFT
		-- b006 : 133637
		["133594"] = Vector3(6875, -300, -600),	-- c005		UP
		["133646"] = Vector3(6675, -100, -600),	-- b005		LEFT
-- C --
		-- c001 : 133650
		["133595"] = Vector3(7075, 700, -600),	-- d001		UP
		["133648"] = Vector3(6875, 500, -600),	-- c002		RIGHT
		-- c002 : 133653
		["133601"] = Vector3(7075, 500, -600),	-- d002		UP
		["133652"] = Vector3(6875, 300, -600),	-- c003		RIGHT
		["133649"] = Vector3(6875, 700, -600),	-- c001		LEFT
		-- c003 : 133656
		["133607"] = Vector3(7075, 300, -600),	-- d003		UP
		["133655"] = Vector3(6875, 100, -600),	-- c004		RIGHT
		["133651"] = Vector3(6875, 500, -600),	-- c002		LEFT
		-- c004 : 133659
		["133613"] = Vector3(7075, 100, -600),	-- d004		UP
		["133658"] = Vector3(6875, -100, -600),	-- c005		RIGHT
		["133654"] = Vector3(6875, 300, -600),	-- c003		LEFT
		-- c005 : 133662
		["133619"] = Vector3(7075, -100, -600),	-- d005		UP
		["133661"] = Vector3(6875, -300, -600),	-- c006		RIGHT
		["133657"] = Vector3(6875, 100, -600),	-- c004		LEFT
		-- c006 : 133663
		["133625"] = Vector3(7075, -300, -600),	-- d006		UP
		["133660"] = Vector3(6875, -100, -600),	-- c005		LEFT
-- D --
		-- d001 : 133666
		["133596"] = Vector3(7275, 700, -600),	-- e001		UP
		["133664"] = Vector3(7075, 500, -600),	-- d002		RIGHT
		-- d002 : 133669
		["133602"] = Vector3(7275, 500, -600),	-- e002		UP
		["133667"] = Vector3(7075, 300, -600),	-- d003		RIGHT
		["133665"] = Vector3(7075, 700, -600),	-- d001		LEFT
		-- d003 : 133672
		["133608"] = Vector3(7275, 300, -600),	-- e003		UP
		["133670"] = Vector3(7075, 100, -600),	-- d004		RIGHT
		["133668"] = Vector3(7075, 500, -600),	-- d002		LEFT
		-- d004 : 133675
		["133614"] = Vector3(7275, 100, -600),	-- e004		UP
		["133673"] = Vector3(7075, -100, -600),	-- d005		RIGHT
		["133671"] = Vector3(7075, 300, -600),	-- d003		LEFT
		-- d005 : 133678
		["133620"] = Vector3(7275, -100, -600),	-- e005		UP
		["133676"] = Vector3(7075, -300, -600),	-- d006		RIGHT
		["133674"] = Vector3(7075, 100, -600),	-- d004		LEFT
		-- d006 : 133679
		["133626"] = Vector3(7275, -300, -600),	-- e006		UP
		["133677"] = Vector3(7075, -100, -600),	-- d005		LEFT
-- E --
		-- e001 : 133680
		["133597"] = Vector3(7475, 700, -600),	-- f001		UP
		["133682"] = Vector3(7275, 500, -600),	-- e002		RIGHT
		-- e002 : 133683
		["133603"] = Vector3(7475, 500, -600),	-- f002		UP
		["133684"] = Vector3(7275, 300, -600),	-- e003		RIGHT
		["133681"] = Vector3(7275, 700, -600),	-- e001		LEFT
		-- e003 : 133686
		["133609"] = Vector3(7475, 300, -600),	-- f003		UP
		["133687"] = Vector3(7275, 100, -600),	-- e004		RIGHT
		["133685"] = Vector3(7275, 500, -600),	-- e002		LEFT
		-- e004 : 133689
		["133615"] = Vector3(7475, 100, -600),	-- f004		UP
		["133690"] = Vector3(7275, -100, -600),	-- e005		RIGHT
		["133688"] = Vector3(7275, 300, -600),	-- e003		LEFT
		-- e005 : 133692
		["133621"] = Vector3(7475, -100, -600),	-- f005		UP
		["133693"] = Vector3(7275, -300, -600),	-- e006		RIGHT
		["133691"] = Vector3(7275, 100, -600),	-- e004		LEFT
		-- e006 : 133695
		["133627"] = Vector3(7475, -300, -600),	-- f006		UP
		["133694"] = Vector3(7275, -100, -600),	-- e005		LEFT
-- F --
		-- f001 : 133696
		["133598"] = Vector3(7675, 700, -600),	-- g001		UP
		["133698"] = Vector3(7475, 500, -600),	-- f002		RIGHT
		-- f002 : 133699
		["133604"] = Vector3(7675, 500, -600),	-- g002		UP
		["133700"] = Vector3(7475, 300, -600),	-- f003		RIGHT
		["133697"] = Vector3(7475, 700, -600),	-- f001		LEFT
		-- f003 : 133702
		["133610"] = Vector3(7675, 300, -600),	-- g003		UP
		["133703"] = Vector3(7475, 100, -600),	-- f004		RIGHT
		["133701"] = Vector3(7475, 500, -600),	-- f002		LEFT
		-- f004 : 133705
		["133616"] = Vector3(7675, 100, -600),	-- g004		UP
		["133706"] = Vector3(7475, -100, -600),	-- f005		RIGHT
		["133704"] = Vector3(7475, 300, -600),	-- f003		LEFT
		-- f005 : 133708
		["133622"] = Vector3(7675, -100, -600),	-- g005		UP
		["133709"] = Vector3(7475, -300, -600),	-- f006		RIGHT
		["133707"] = Vector3(7475, 100, -600),	-- f004		LEFT
		-- f006 : 133711
		["133628"] = Vector3(7675, -300, -600),	-- g006		UP
		["133710"] = Vector3(7475, -100, -600),	-- f005		LEFT
-- G --
		-- g001 : 133712
		["133599"] = Vector3(7875, 700, -600),	-- h001		UP
		["133714"] = Vector3(7675, 500, -600),	-- g002		RIGHT
		-- g002 : 133715
		["133605"] = Vector3(7875, 500, -600),	-- h002		UP
		["133716"] = Vector3(7675, 300, -600),	-- g003		RIGHT
		["133713"] = Vector3(7675, 700, -600),	-- g001		LEFT
		-- g003 : 133718
		["133611"] = Vector3(7875, 300, -600),	-- h003		UP
		["133719"] = Vector3(7675, 100, -600),	-- g004		RIGHT
		["133717"] = Vector3(7675, 500, -600),	-- g002		LEFT
		-- g004 : 133721
		["133617"] = Vector3(7875, 100, -600),	-- h004		UP
		["133722"] = Vector3(7675, -100, -600),	-- g005		RIGHT
		["133720"] = Vector3(7675, 300, -600),	-- g003		LEFT
		-- g005 : 133724
		["133623"] = Vector3(7875, -100, -600),	-- h005		UP
		["133725"] = Vector3(7675, -300, -600),	-- g006		RIGHT
		["133723"] = Vector3(7675, 100, -600),	-- g004		LEFT
		-- g006 : 133727
		["133629"] = Vector3(7875, -300, -600),	-- h006		UP
		["133726"] = Vector3(7675, -100, -600),	-- g005		LEFT
-- H --
		-- h001 : 133728
		["133600"] = Vector3(8075, 700, -600),	-- i001		UP
		["133730"] = Vector3(7875, 500, -600),	-- h002		RIGHT
		-- h002 : 133731
		["133606"] = Vector3(8075, 500, -600),	-- i002		UP
		["133732"] = Vector3(7875, 300, -600),	-- h003		RIGHT
		["133729"] = Vector3(7875, 700, -600),	-- h001		LEFT
		-- h003 : 133734
		["133612"] = Vector3(8075, 300, -600),	-- i003		UP
		["133735"] = Vector3(7875, 100, -600),	-- h004		RIGHT
		["133733"] = Vector3(7875, 500, -600),	-- h002		LEFT
		-- h004 : 133737
		["133618"] = Vector3(8075, 100, -600),	-- i004		UP
		["133738"] = Vector3(7875, -100, -600),	-- h005		RIGHT
		["133736"] = Vector3(7875, 300, -600),	-- h003		LEFT
		-- h005 : 133740
		["133624"] = Vector3(8075, -100, -600),	-- i005		UP
		["133741"] = Vector3(7875, -300, -600),	-- h006		RIGHT
		["133739"] = Vector3(7875, 100, -600),	-- h004		LEFT
		-- h006 : 133743
		["133630"] = Vector3(8075, -300, -600),	-- i006		UP
		["133742"] = Vector3(7875, -100, -600),	-- h005		LEFT
	}
	
	local tile_nums = {
		133631,
		133633,
		133634,
		133635,
		133636,
		133637,
		133650,
		133653,
		133656,
		133659,
		133662,
		133663,
		133666,
		133669,
		133672,
		133675,
		133678,
		133679,
		133680,
		133683,
		133686,
		133689,
		133692,
		133695,
		133696,
		133699,
		133702,
		133705,
		133708,
		133711,
		133712,
		133715,
		133718,
		133721,
		133724,
		133727,
		133728,
		133731,
		133734,
		133737,
		133740,
		133743
	}
	
	if _path_terminated == false then
		if _path_ok > 1 then
			local tile_1 = managers.mission:script("default")._elements[133576]._values.on_executed[1].id
			managers.hud:add_waypoint( 'dia_path_'..'tile_1', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_1)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			if _path_ok > 2 then
				local tile_2 = managers.mission:script("default")._elements[tile_1]._values.on_executed[1].id
				managers.hud:add_waypoint( 'dia_path_'..'tile_2', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_2)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
				if _path_ok > 3 then
					local tile_3 = managers.mission:script("default")._elements[tile_2]._values.on_executed[1].id
					local tile_3b = managers.mission:script("default")._elements[tile_3]._values.on_executed[1].id
					if in_table(tile_nums, tile_3) then
						managers.hud:add_waypoint( 'dia_path_'..'tile_3', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_3b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
						_path_tile = tile_3b
					else
						managers.hud:add_waypoint( 'dia_path_'..'tile_3', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_3)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
						_path_tile = tile_3
					end
					if _path_ok > 4 then
						local tile_4_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
						local tile_4 = managers.mission:script("default")._elements[tile_4_0]._values.on_executed[1].id
						local tile_4b = managers.mission:script("default")._elements[tile_4]._values.on_executed[1].id
						if in_table(tile_nums, tile_4) then
							managers.hud:add_waypoint( 'dia_path_'..'tile_4', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_4b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
							_path_tile = tile_4b
						else
							managers.hud:add_waypoint( 'dia_path_'..'tile_4', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_4)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
							_path_tile = tile_4
						end
						if _path_ok > 5 then
							local tile_5_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
							local tile_5 = managers.mission:script("default")._elements[tile_5_0]._values.on_executed[1].id
							local tile_5b = managers.mission:script("default")._elements[tile_5]._values.on_executed[1].id
							if in_table(tile_nums, tile_5) then
								managers.hud:add_waypoint( 'dia_path_'..'tile_5', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_5b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
								_path_tile = tile_5b
							else
								managers.hud:add_waypoint( 'dia_path_'..'tile_5', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_5)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
								_path_tile = tile_5
							end
							if _path_ok > 6 then
								local tile_6_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
								local tile_6 = managers.mission:script("default")._elements[tile_6_0]._values.on_executed[1].id
								local tile_6b = managers.mission:script("default")._elements[tile_6]._values.on_executed[1].id
								if in_table(tile_nums, tile_6) then
									managers.hud:add_waypoint( 'dia_path_'..'tile_6', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_6b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
									_path_tile = tile_6b
								else
									managers.hud:add_waypoint( 'dia_path_'..'tile_6', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_6)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
									_path_tile = tile_6
								end
								if _path_ok > 7 then
									local tile_7_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
									local tile_7 = managers.mission:script("default")._elements[tile_7_0]._values.on_executed[1].id
									local tile_7b = managers.mission:script("default")._elements[tile_7]._values.on_executed[1].id
									if in_table(tile_nums, tile_7) then
										managers.hud:add_waypoint( 'dia_path_'..'tile_7', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_7b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
										_path_tile = tile_7b
									else
										managers.hud:add_waypoint( 'dia_path_'..'tile_7', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_7)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
										_path_tile = tile_7
									end
									if _path_ok > 8 then
										local tile_8_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
										local tile_8 = managers.mission:script("default")._elements[tile_8_0]._values.on_executed[1].id
										local tile_8b = managers.mission:script("default")._elements[tile_8]._values.on_executed[1].id
										if in_table(tile_nums, tile_8) then
											managers.hud:add_waypoint( 'dia_path_'..'tile_8', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_8b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
											_path_tile = tile_8b
										else
											managers.hud:add_waypoint( 'dia_path_'..'tile_8', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_8)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
											_path_tile = tile_8
										end
										if _path_ok > 9 then
											local tile_9_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
											local tile_9 = managers.mission:script("default")._elements[tile_9_0]._values.on_executed[1].id
											local tile_9b = managers.mission:script("default")._elements[tile_9]._values.on_executed[1].id
											if in_table(tile_nums, tile_9) then
												managers.hud:add_waypoint( 'dia_path_'..'tile_9', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_9b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
												_path_tile = tile_9b
											else
												managers.hud:add_waypoint( 'dia_path_'..'tile_9', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_9)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
												_path_tile = tile_9
											end
											if _path_tile == 133600	or _path_tile == 133606	or _path_tile == 133612	or _path_tile == 133618	or _path_tile == 133624	or _path_tile == 133630 then
												-- LAST TILE!
												_path_terminated = true
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if _path_ok > 10 then
		if _path_terminated == false then
			local tile_10_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
			local tile_10 = managers.mission:script("default")._elements[tile_10_0]._values.on_executed[1].id
			local tile_10b = managers.mission:script("default")._elements[tile_10]._values.on_executed[1].id
			if in_table(tile_nums, tile_10) then
				managers.hud:add_waypoint( 'dia_path_'..'tile_10', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_10b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
				_path_tile = tile_10b
			else
				managers.hud:add_waypoint( 'dia_path_'..'tile_10', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_10)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
				_path_tile = tile_10
			end
			if _path_tile == 133600	or _path_tile == 133606	or _path_tile == 133612	or _path_tile == 133618	or _path_tile == 133624	or _path_tile == 133630 then
				-- LAST TILE!
				_path_terminated = true
			end
		end
	end
	if _path_terminated == false then
		local tile_11_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
		local tile_11 = managers.mission:script("default")._elements[tile_11_0]._values.on_executed[1].id
		local tile_11b = managers.mission:script("default")._elements[tile_11]._values.on_executed[1].id
		if in_table(tile_nums, tile_11) then
			managers.hud:add_waypoint( 'dia_path_'..'tile_11', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_11b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_11b
		else
			managers.hud:add_waypoint( 'dia_path_'..'tile_11', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_11)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_11
		end
		if _path_tile == 133600	or _path_tile == 133606	or _path_tile == 133612	or _path_tile == 133618	or _path_tile == 133624	or _path_tile == 133630 then
			-- LAST TILE!
			_path_terminated = true
		end
	end
	if _path_terminated == false then
		local tile_12_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
		local tile_12 = managers.mission:script("default")._elements[tile_12_0]._values.on_executed[1].id
		local tile_12b = managers.mission:script("default")._elements[tile_12]._values.on_executed[1].id
		if in_table(tile_nums, tile_12) then
			managers.hud:add_waypoint( 'dia_path_'..'tile_12', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_12b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_12b
		else
			managers.hud:add_waypoint( 'dia_path_'..'tile_12', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_12)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_12
		end
		if _path_tile == 133600	or _path_tile == 133606	or _path_tile == 133612	or _path_tile == 133618	or _path_tile == 133624	or _path_tile == 133630 then
			-- LAST TILE!
			_path_terminated = true
		end
	end
	if _path_terminated == false then
		local tile_13_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
		local tile_13 = managers.mission:script("default")._elements[tile_13_0]._values.on_executed[1].id
		local tile_13b = managers.mission:script("default")._elements[tile_13]._values.on_executed[1].id
		if in_table(tile_nums, tile_13) then
			managers.hud:add_waypoint( 'dia_path_'..'tile_13', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_13b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_13b
		else
			managers.hud:add_waypoint( 'dia_path_'..'tile_13', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_13)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_13
		end
		if _path_tile == 133600	or _path_tile == 133606	or _path_tile == 133612	or _path_tile == 133618	or _path_tile == 133624	or _path_tile == 133630 then
			-- LAST TILE!
			_path_terminated = true
		end
	end
	if _path_terminated == false then
		local tile_14_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
		local tile_14 = managers.mission:script("default")._elements[tile_14_0]._values.on_executed[1].id
		local tile_14b = managers.mission:script("default")._elements[tile_14]._values.on_executed[1].id
		if in_table(tile_nums, tile_14) then
			managers.hud:add_waypoint( 'dia_path_'..'tile_14', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_14b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_14b
		else
			managers.hud:add_waypoint( 'dia_path_'..'tile_14', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_14)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_14
		end
		if _path_tile == 133600	or _path_tile == 133606	or _path_tile == 133612	or _path_tile == 133618	or _path_tile == 133624	or _path_tile == 133630 then
			-- LAST TILE!
			_path_terminated = true
		end
	end
	if _path_terminated == false then
		local tile_15_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
		local tile_15 = managers.mission:script("default")._elements[tile_15_0]._values.on_executed[1].id
		local tile_15b = managers.mission:script("default")._elements[tile_15]._values.on_executed[1].id
		if in_table(tile_nums, tile_15) then
			managers.hud:add_waypoint( 'dia_path_'..'tile_15', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_15b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_15b
		else
			managers.hud:add_waypoint( 'dia_path_'..'tile_15', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_15)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_15
		end
		if _path_tile == 133600	or _path_tile == 133606	or _path_tile == 133612	or _path_tile == 133618	or _path_tile == 133624	or _path_tile == 133630 then
			-- LAST TILE!
			_path_terminated = true
		end
	end
	if _path_terminated == false then
		local tile_16_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
		local tile_16 = managers.mission:script("default")._elements[tile_16_0]._values.on_executed[1].id
		local tile_16b = managers.mission:script("default")._elements[tile_16]._values.on_executed[1].id
		if in_table(tile_nums, tile_16) then
			managers.hud:add_waypoint( 'dia_path_'..'tile_16', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_16b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_16b
		else
			managers.hud:add_waypoint( 'dia_path_'..'tile_16', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_16)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_16
		end
		if _path_tile == 133600	or _path_tile == 133606	or _path_tile == 133612	or _path_tile == 133618	or _path_tile == 133624	or _path_tile == 133630 then
			-- LAST TILE!
			_path_terminated = true
		end
	end
	if _path_terminated == false then
		local tile_17_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
		local tile_17 = managers.mission:script("default")._elements[tile_17_0]._values.on_executed[1].id
		local tile_17b = managers.mission:script("default")._elements[tile_17]._values.on_executed[1].id
		if in_table(tile_nums, tile_17) then
			managers.hud:add_waypoint( 'dia_path_'..'tile_17', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_17b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_17b
		else
			managers.hud:add_waypoint( 'dia_path_'..'tile_17', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_17)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_17
		end
		if _path_tile == 133600	or _path_tile == 133606	or _path_tile == 133612	or _path_tile == 133618	or _path_tile == 133624	or _path_tile == 133630 then
			-- LAST TILE!
			_path_terminated = true
		end
	end
	if _path_terminated == false then
		local tile_18_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
		local tile_18 = managers.mission:script("default")._elements[tile_18_0]._values.on_executed[1].id
		local tile_18b = managers.mission:script("default")._elements[tile_18]._values.on_executed[1].id
		if in_table(tile_nums, tile_18) then
			managers.hud:add_waypoint( 'dia_path_'..'tile_18', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_18b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_18b
		else
			managers.hud:add_waypoint( 'dia_path_'..'tile_18', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_18)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_18
		end
		if _path_tile == 133600	or _path_tile == 133606	or _path_tile == 133612	or _path_tile == 133618	or _path_tile == 133624	or _path_tile == 133630 then
			-- LAST TILE!
			_path_terminated = true
		end
	end
	if _path_terminated == false then
		local tile_19_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
		local tile_19 = managers.mission:script("default")._elements[tile_19_0]._values.on_executed[1].id
		local tile_19b = managers.mission:script("default")._elements[tile_19]._values.on_executed[1].id
		if in_table(tile_nums, tile_19) then
			managers.hud:add_waypoint( 'dia_path_'..'tile_19', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_19b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_19b
		else
			managers.hud:add_waypoint( 'dia_path_'..'tile_19', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_19)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_19
		end
		if _path_tile == 133600	or _path_tile == 133606	or _path_tile == 133612	or _path_tile == 133618	or _path_tile == 133624	or _path_tile == 133630 then
			-- LAST TILE!
			_path_terminated = true
		end
	end
	if _path_terminated == false then
		local tile_20_0 = managers.mission:script("default")._elements[_path_tile]._values.on_executed[1].id
		local tile_20 = managers.mission:script("default")._elements[tile_20_0]._values.on_executed[1].id
		local tile_20b = managers.mission:script("default")._elements[tile_20]._values.on_executed[1].id
		if in_table(tile_nums, tile_20) then
			managers.hud:add_waypoint( 'dia_path_'..'tile_20', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_20b)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_20b
		else
			managers.hud:add_waypoint( 'dia_path_'..'tile_20', { icon = 'wp_target', distance = false, position = tiles_all[tostring(tile_20)], no_sync = true, present_timer = 0, state = "present", radius = 1500, color = mark_color_changer, blend_mode = "add" }  )
			_path_tile = tile_20
		end
		if _path_tile == 133600	or _path_tile == 133606	or _path_tile == 133612	or _path_tile == 133618	or _path_tile == 133624	or _path_tile == 133630 then
			-- LAST TILE!
			_path_terminated = true
		end
	end
	
	for id,data in pairs( managers.hud._hud.waypoints ) do
		id = tostring(id)
		if id:sub(1,9) == 'dia_path_' then 
			data.bitmap:set_color( mark_color_changer )
		end
	end
	
	if not in_table({"easy", "normal", "hard", "overkill"}, Global.game_settings.difficulty) then
		BetterDelayedCalls:Remove("diamond_path_loop")
	end
end

if Network:is_server() then
	showpath = showpath or false
	if not showpath then
		dia_path()
		managers.mission._fading_debug_output:script().log('Diamond Path ACTIVATED', Color.green)
	else
		clear_path()
		managers.mission._fading_debug_output:script().log('Diamond Path DEACTIVATED', Color.red)
	end
	showpath = not showpath
else
	if managers.chat then
		managers.chat:feed_system_message(ChatManager.GAME, "Host only!")
	end
end