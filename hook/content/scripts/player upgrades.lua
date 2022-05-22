local inspire_distance = 200000		-- Distance to revive player default 8100m or false
local boost_cooldown = 1			-- Moral boost cooldown in sec or false
local inspire_chance = 1			-- Chance to inspire, default is 1 (100%), can be between 0-1 or false
local new_upgrades = {				-- Add any upgrade you want
	["player"] = {
		--Basic Inspire
		["morale_boost"] = {
			upgrade = "morale_boost",
			value = 1,
			enable = true
		},
		
		-- Dire Need
		["armor_depleted_stagger_shot"] = {
			upgrade = "armor_depleted_stagger_shot",
			value = 1,
			enable = true
		},
		
		--Basic Inspire
		["revive_interaction_speed_multiplier"] = {
			upgrade = "revive_interaction_speed_multiplier",
			value = 1,
			enable = true
		}
	},
	["weapon"] = {
		--Heavy Impact
		["knock_down"] = {
			upgrade = "knock_down",
			value = 1,
			enable = true
		}
	},
	["cooldown"] = {
		--Aced Inspire
		["long_dis_revive"] = {
			upgrade = "long_dis_revive",
			value = 1,
			enable = true
		}
	}
}

 
if _G["PlayerManager"] ~= nil then
	local orig_check_skills = PlayerManager.check_skills
	function PlayerManager:check_skills(...)
		orig_check_skills(self, ...)
		for k, v in pairs(new_upgrades) do
			local loop = tweak_data.upgrades.values[k] or {}
			for key, value in pairs(loop) do
				if new_upgrades[k] ~= nil and new_upgrades[k][key] ~= nil and new_upgrades[k][key].enable and not managers.player:has_category_upgrade(k, new_upgrades[k][key].upgrade) then
					local new_upgrade = {
						category = k,
						upgrade = new_upgrades[k][key].upgrade,
						value = new_upgrades[k][key].value
					}
					if k == "cooldown" then
						managers.player:aquire_cooldown_upgrade(new_upgrade)
					else
						managers.player:aquire_upgrade(new_upgrade)
					end
				end
			end
		end
	end
end
 
if _G["PlayerMovement"] ~= nil then
	local orig_check_init = PlayerMovement.init
	function PlayerMovement:init(...)
		orig_check_init(self, ...)
		if new_upgrades["player"]["morale_boost"] ~= nil and new_upgrades["cooldown"]["long_dis_revive"] ~= nil and new_upgrades["player"]["morale_boost"].enable and new_upgrades["cooldown"]["long_dis_revive"].enable then
			local data = managers.player:upgrade_value("cooldown", "long_dis_revive", nil)
			self._rally_skill_data = {
				range_sq = (inspire_distance and inspire_distance * 100) or 810000,
				morale_boost_delay_t = managers.player:has_category_upgrade("player", "morale_boost") and 0 or nil,
				long_dis_revive = managers.player:has_category_upgrade("cooldown", "long_dis_revive"),
				revive_chance = inspire_chance or type(data) == "table" and data[1] or 0,
				morale_boost_cooldown_t = boost_cooldown or tweak_data.upgrades.morale_boost_base_cooldown * managers.player:upgrade_value("player", "morale_boost_cooldown_multiplier", 1)
			}
		end
	end
end