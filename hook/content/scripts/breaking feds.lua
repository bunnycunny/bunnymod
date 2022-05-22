local id_level = managers.job and managers.job:current_level_id()
local player = managers.player and managers.player:player_unit()
local code = {}
local laptop = {}

local function messasge(code)
	if Network:is_server() then
		managers.chat:send_message(1, managers.network.system, code)
	else
		managers.chat:send_message(ChatManager.GAME, 1, code)
	end
end

if string.lower(RequiredScript) == "core/lib/managers/mission/coremissionscriptelement" and MissionScriptElement then
	local orig_MissionScriptElement_on_executed = MissionScriptElement.on_executed
	function MissionScriptElement.on_executed(self, ...)
		orig_MissionScriptElement_on_executed(self, ...)
		if id_level and id_level == "tag" and Network:is_server() then
			if self._id == 102039 then
				table.insert(code, "1776")
			elseif self._id == 100835 then
				table.insert(code, "2015")
			elseif self._id == 100834 then
				table.insert(code, "1234")
			elseif self._id == 100830 then
				table.insert(code, "1212")
			elseif self._id == 140072 then
				table.insert(laptop, "HR")
			elseif self._id == 140073 then
				table.insert(laptop, "Server")
			elseif self._id == 140074 then
				table.insert(laptop, "Storage")
			elseif self._id == 140075 then
				table.insert(laptop, "Operation")
			elseif self._id == 140076 then
				table.insert(laptop, "Training")
			elseif self._id == 140077 then
				table.insert(laptop, "Kitchen")
			end
		end
	end
end

local dialog_ids = {
	["Play_loc_tag_38"] = {
		["code"] = "1234"
	},
	["Play_loc_tag_39"] = {
		["code"] = "1234"
	},
	["Play_loc_tag_37"] = {
		["code"] = "2015"
	},
	["Play_loc_tag_36"] = {
		["code"] = "2015"
	},
	["Play_loc_tag_83"] = {
		["code"] = "2015"
	},
	["Play_loc_tag_34"] = {
		["code"] = "1212"
	},
	["Play_loc_tag_35"] = {
		["code"] = "1212"
	},
	["Play_loc_tag_32"] = {
		["code"] = "1776"
	},
	["Play_loc_tag_33"] = {
		["code"] = "1776"
	},
	["Play_loc_tag_30"] = {
		["safe_found"] = true
	},
	["Play_loc_tag_04"] = {
		["find_laptop"] = true
	},
	["Play_loc_tag_22"] = {
		["garret_out"] = {
			136863, --1
			137063, --2
			137263, --3
			137463, --4
			137663, --5
			137863, --6
			138063, --7
			131363, --8
			131563, --9
			131763, --10
			131963, --11
			132163, --12
			132363, --13
			132563 --14
		}
	},
	["Play_loc_tag_51"] = {
		["find_computer"] = {
			132770, --1
			134470, --2
			136770, --3
			138470, --4
			138570, --5
			142220, --6
			142420, --7
			148270, --8
			148370, --9
			152870, --10
			153070, --12
			153170, --13
			153270, --14
			135370, --15
			155870, --16
			155970, --17
			156070, --18
			156170, --19
			156270, --20
			156370, --21
			156470 --22
		}
	},
	["Play_loc_tag_52"] = {
		["find_computer"] = {
			132770, --1
			134470, --2
			136770, --3
			138470, --4
			138570, --5
			142220, --6
			142420, --7
			148270, --8
			148370, --9
			152870, --10
			153070, --12
			153170, --13
			153270, --14
			135370, --15
			155870, --16
			155970, --17
			156070, --18
			156170, --19
			156270, --20
			156370, --21
			156470 --22
		}
	},
	["Play_loc_tag_53"] = {
		["find_computer"] = {
			132770, --1
			134470, --2
			136770, --3
			138470, --4
			138570, --5
			142220, --6
			142420, --7
			148270, --8
			148370, --9
			152870, --10
			153070, --12
			153170, --13
			153270, --14
			135370, --15
			155870, --16
			155970, --17
			156070, --18
			156170, --19
			156270, --20
			156370, --21
			156470 --22
		}
	},
	["Play_loc_tag_54"] = {
		["find_computer"] = {
			132770, --1
			134470, --2
			136770, --3
			138470, --4
			138570, --5
			142220, --6
			142420, --7
			148270, --8
			148370, --9
			152870, --10
			153070, --12
			153170, --13
			153270, --14
			135370, --15
			155870, --16
			155970, --17
			156070, --18
			156170, --19
			156270, --20
			156370, --21
			156470 --22
		}
	},
	["Play_loc_tag_55"] = {
		["find_computer"] = {
			132770, --1
			134470, --2
			136770, --3
			138470, --4
			138570, --5
			142220, --6
			142420, --7
			148270, --8
			148370, --9
			152870, --10
			153070, --12
			153170, --13
			153270, --14
			135370, --15
			155870, --16
			155970, --17
			156070, --18
			156170, --19
			156270, --20
			156370, --21
			156470 --22
		}
	},
	["Play_loc_tag_56"] = {
		["find_computer"] = {
			132770, --1
			134470, --2
			136770, --3
			138470, --4
			138570, --5
			142220, --6
			142420, --7
			148270, --8
			148370, --9
			152870, --10
			153070, --12
			153170, --13
			153270, --14
			135370, --15
			155870, --16
			155970, --17
			156070, --18
			156170, --19
			156270, --20
			156370, --21
			156470 --22
		}
	},
	["Play_loc_tag_57"] = {
		["find_computer"] = {
			132770, --1
			134470, --2
			136770, --3
			138470, --4
			138570, --5
			142220, --6
			142420, --7
			148270, --8
			148370, --9
			152870, --10
			153070, --12
			153170, --13
			153270, --14
			135370, --15
			155870, --16
			155970, --17
			156070, --18
			156170, --19
			156270, --20
			156370, --21
			156470 --22
		}
	},
	["Play_loc_tag_58"] = {
		["find_computer"] = {
			132770, --1
			134470, --2
			136770, --3
			138470, --4
			138570, --5
			142220, --6
			142420, --7
			148270, --8
			148370, --9
			152870, --10
			153070, --12
			153170, --13
			153270, --14
			135370, --15
			155870, --16
			155970, --17
			156070, --18
			156170, --19
			156270, --20
			156370, --21
			156470 --22
		}
	},
	["Play_loc_tag_59"] = {
		["find_computer"] = {
			132770, --1
			134470, --2
			136770, --3
			138470, --4
			138570, --5
			142220, --6
			142420, --7
			148270, --8
			148370, --9
			152870, --10
			153070, --12
			153170, --13
			153270, --14
			135370, --15
			155870, --16
			155970, --17
			156070, --18
			156170, --19
			156270, --20
			156370, --21
			156470 --22
		}
	}
}
if DialogManager then
local queue_dialog_original = DialogManager.queue_dialog
function DialogManager:queue_dialog(id, ...)
	if id_level and id_level == "tag" and not self.tag_code and dialog_ids[id] then
		if Network:is_server() then
			if dialog_ids[id].safe_found then
				messasge("Code is: "..(code[1] or ""))
			elseif dialog_ids[id].garret_out then
				for k, v in pairs(dialog_ids[id].garret_out) do
					 managers.mission._scripts["default"]._elements[v]:on_executed(player)
				end
			elseif dialog_ids[id].find_laptop then
				if laptop[1] then
					messasge("Laptop is in: "..(laptop[1] or "").." Room")
				end
			elseif dialog_ids[id].find_computer then
				for k, v in pairs(dialog_ids[id].find_computer) do
					 managers.mission._scripts["default"]._elements[v]:on_executed(player)
				end
			end
			DelayedCalls:Add("breaking_feds_anti_spam_delay_id", 10, function()
				self.tag_code = false
			end)
			self.tag_code = true
		else
			if dialog_ids[id].code then
				messasge("Code is: "..dialog_ids[id].code)
				self.tag_code = true
			end
		end
	end
	return queue_dialog_original(self, id, ...)
end
end