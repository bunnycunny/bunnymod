function inTable( table, value )
	if table ~= nil then 
		for i,x in pairs(table) do 
			if x == value then 
				return true 
			end 
		end 
	end
	return false
end

local function giveitems( itype, times )
    local types = {"weapon_mods", "masks", "materials", "textures", "colors"}
    local skip = { masks = {"character_locked"}, materials = {"plastic"}, colors = {"nothing"}, textures = {"no_color_full_material","no_color_no_material"} }
	
    if not itype then itype = "all" end
    if not times then times = 5 end
    if type(itype) == "table" then types = itype end
	
    if itype == "all" or type(itype) == "table" then
		for i = 1, #types do 
			giveitems(types[i], times) 
		end
		return
    elseif not inTable(types, itype) then 
		return 
	end
	for i=1, times do
		for mat_id,_ in pairs(tweak_data.blackmarket[itype]) do
			if not inTable(skip[itype], mat_id) then
				local global_value = "normal"
				if _.global_value then
					global_value = _.global_value
				elseif _.infamous then
					global_value = "infamous"
				elseif _.dlcs or _.dlc then
					local dlcs = _.dlcs or {}
					if _.dlc then 
						table.insert( dlcs, _.dlc ) 
					end
					global_value = dlcs[ math.random( #dlcs ) ]
				end
				if not _.unlocked then 
					_.unlocked = true 
				end
				managers.blackmarket:add_to_inventory(global_value, itype, mat_id, false)
			end
		end
	end
end

local function giveitem( item, times , global_value)
    local types = {"weapon_mods", "masks", "materials", "textures", "colors"}
    if not times then times = 20 end
	
    for t = 1, #types do
        local itype = types[t]
		for mat_id,_ in pairs(tweak_data.blackmarket[itype]) do
			if (type(item) == "table" and inTable(item, mat_id)) or (type(item) ~= "table" and mat_id == item) then
				if not global_value then
					local global_value = "normal"
					if _.global_value then
						global_value = _.global_value
					elseif _.infamous then
						global_value = "infamous"
					elseif _.dlcs or _.dlc then
						local dlcs = _.dlcs or {}
						if _.dlc then table.insert( dlcs, _.dlc ) end
						global_value = dlcs[ math.random( #dlcs ) ]
					end
				end
				if not _.unlocked then 
					_.unlocked = true 
				end
				for i=1, times do 
					managers.blackmarket:add_to_inventory(global_value, itype, mat_id, false) 
				end
				if type(item) ~= "table" then 
					return 
				end
			end
		end
    end
end

local function clearitems( itype , globalval )
    local types = {"weapon_mods", "masks", "materials", "textures", "colors"}
    if not itype then itype = "all" end
    if not globalval then globalval = "all" end
    if type(itype) == "table" then types = itype end
	
    if itype == "all" or type(itype) == "table" then
		for i = 1, #types do 
			clearitems(types[i], globalval) 
		end 
		return
    elseif not inTable(types, itype) then 
		return 
	end
    for global_value, categories in pairs( Global.blackmarket_manager.inventory ) do
		if (globalval == "all" or globalval == global_value) and categories[itype] then
			for id,amount in pairs( categories[itype] ) do
				Global.blackmarket_manager.inventory[global_value][itype][id] = nil
			end
        end
    end
end
 
local function clearitem( item , globalval )
    local types = {"weapon_mods", "masks", "materials", "textures", "colors"}
    if not globalval then globalval = "all" end
	
    for t = 1, #types do
        local itype = types[t]
        for global_value, categories in pairs( Global.blackmarket_manager.inventory ) do
            if (globalval == "all" or globalval == global_value) and categories[itype] then
				for id,amount in pairs( categories[itype] ) do
                    if (type(item) == "table" and inTable(item, id)) or (type(item) ~= "table" and id == item) then
                        Global.blackmarket_manager.inventory[global_value][itype][id] = 0
                    end
                end
            end
        end
    end
end

--Unlocks items specified in "types"
local function unlockitems( itype )
    local types = {"weapon_mods", "masks", "materials", "textures", "colors", "weapons"}
    if not itype then itype = "all" end
    if type(itype) == "table" then types = itype end
	
    if itype == "all" or type(itype) == "table" then
		for i = 1, #types do 
			unlockitems(types[i]) 
		end
		return
    elseif not inTable(types, itype) then 
		return 
	end
    if itype == "weapons" then
		for wep_id,_ in pairs(tweak_data.upgrades.definitions) do
			if _.category == "weapon" and not string.find(wep_id, "_primary") and not string.find(wep_id, "_secondary") then
				if not managers.upgrades:aquired(wep_id) then 
					managers.upgrades:aquire(wep_id) 
				end
			end
		end
	else
		for mat_id,_ in pairs(tweak_data.blackmarket[itype]) do
			if not _.unlocked then 
				_.unlocked = true 
			end
		end
	end
end

local function unlock_slots()
	for i = 1, 500 do
		Global.blackmarket_manager.unlocked_mask_slots[i] = true 
		Global.blackmarket_manager.unlocked_weapon_slots.primaries[i] = true
		Global.blackmarket_manager.unlocked_weapon_slots.secondaries[i] = true
	end
end

--Clears the new item flags from the given types
local function clearnewitems()
    Global.blackmarket_manager.new_drops = {}
end

managers.mission._fading_debug_output:script().log('Give All Items ACTIVATED', Color.green)
--clearitems("all")
--clearitems({"masks","textures","colors"})
--clearitems("masks", "halloween")
--clearitem({"slime","rainbow","alienware"})
unlock_slots()
unlockitems({"masks", "materials", "textures", "colors", "weapon_mods"})
giveitems({"masks", "materials", "textures", "colors", "weapon_mods"})
clearnewitems()