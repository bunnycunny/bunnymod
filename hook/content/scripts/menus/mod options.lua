local class_name = "hook_1712_mod"
local loc = _G["CommandManager"]

if not loc then
	return
end

local function create_mod_list()
	local mods = {}
	local BLT = rawget(_G, "BLT")
	if BLT ~= nil then
		if BLT and BLT.Mods and BLT.Mods then
			for _, mod in ipairs(BLT.Mods:Mods()) do
				local data = {
					mod:GetName(),
					mod:GetId()
				}
				table.insert(mods, data)
			end
		end
	end
	return mods
end

Hooks:Add("LocalizationManagerPostInit", class_name.."Loc", function()
	LocalizationManager:add_localized_strings({
		[class_name.."_menu_title"] = "Hook",
		[class_name.."_menu_desc"] = "Toggle mods to show public."
	})
end)

Hooks:Add("MenuManagerSetupCustomMenus", class_name.."Menu", function(menu_manager, nodes)
	MenuHelper:NewMenu(class_name)
end)

Hooks:Add("MenuManagerPopulateCustomMenus", class_name.."Menu", function(menu_manager, nodes)
	MenuCallbackHandler.hook_1712_mod_mod_list = function(self, item)
		loc.config2.mod_list[item["_priority"]].enable = not loc.config2.mod_list[item["_priority"]].enable
		loc:save_config()
	end
	
	if rawget(_G, "BLT") ~= nil then
		local mods = create_mod_list()
		for key, data2 in ipairs(loc.config2.mod_list or {}) do
			if not mods[key] or not mods[key][1] then
				loc.config2.mod_list = {}
				break
			end
		end
		
		for k, data in ipairs(mods) do
			if type(loc.config2.mod_list) ~= "table" then
				loc.config2.mod_list = {}
			end
			local mod_list = loc.config2.mod_list[k]
			if mod_list and mod_list.name == data[1] then
				loc.config2.mod_list[k] = {enable = mod_list.enable, name = mod_list.name}
			else
				loc.config2.mod_list[k] = {enable = false, name = data[1]}
			end
		end
		loc:save_config()
	end

	for k, data in ipairs(loc.config2.mod_list or {}) do
		managers.localization:add_localized_strings({
			[k.."_mod_list_title_"..class_name] = data.name,
			[k.."_mod_list_desc_"..class_name] = "When enabled, will be hidden from your mod list."
		})
		MenuHelper:AddToggle({
			id = k.."_mod_list_"..class_name,
			title = k.."_mod_list_title_"..class_name,
			desc = k.."_mod_list_desc_"..class_name,
			callback = class_name.."_mod_list",
			value = data.enable,
			menu_id = class_name,  
			priority = k
		})
	end
end)

Hooks:Add("MenuManagerBuildCustomMenus", class_name.."Menu", function(menu_manager, nodes)
	nodes[class_name] = MenuHelper:BuildMenu(class_name)
	MenuHelper:AddMenuItem(nodes["blt_options"], class_name, class_name.."_menu_title", class_name.."_menu_desc")
end)