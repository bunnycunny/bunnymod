if CommandManager.config["weapon_skins"] then
	local custom_quality = "mint"			--can be: "poor", "fair", "good", "fine" or "mint"
	
	if _G["MenuCallbackHandler"] ~= nil then
		local i = 1 --instance_id begins with 1

		local function skins_unlocked(tradable, category, entry)
			for instance_id, data in pairs(tradable) do
				if instance_id and data and data.category == category and data.entry == entry then
					return true
				end
			end
			return false
		end
		
		local orig_func_update_outfit_information = MenuCallbackHandler._update_outfit_information
		function MenuCallbackHandler:_update_outfit_information()
			orig_func_update_outfit_information(self)
			local tradable = managers.blackmarket._global.inventory_tradable or {}
			for id, data in pairs(tweak_data.blackmarket.weapon_skins) do
				local unlocked = skins_unlocked(tradable, "weapon_skins", id)
				local custom_color = (data.color_skin_data or data.is_a_color_skin)
				if not unlocked and not custom_color and data.bonus then
					tradable[i] = {
						category = "weapon_skins",
						entry = id,
						quality = custom_quality,
						bonus = data.bonus,
						amount = 1
					}
				end
				if custom_color and not data.bonus then
					tradable[i] = nil
				end
				i = i + 1
			end
		end
	end

	if _G["BlackMarketManager"] ~= nil then
		local orig_func_get_weapon_stats = BlackMarketManager._get_weapon_stats
		function BlackMarketManager:_get_weapon_stats(weapon_id, blueprint, ...)
			local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
			local weapon_stats = managers.weapon_factory:get_stats(factory_id, blueprint)
			if #weapon_stats > 0 then
				return orig_func_get_weapon_stats(self, weapon_id, blueprint, ...)
			end
			return weapon_stats
		end
		function BlackMarketManager:tradable_update() end
	end
	
	if _G["GuiTweakData"] ~= nil then
		function GuiTweakData:tradable_inventory_sort_func() return nil end
	end
end