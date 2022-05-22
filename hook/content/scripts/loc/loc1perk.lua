Hooks:Add("LocalizationManagerPostInit", "ManiacBuff_Localization", function(loc)
	LocalizationManager:add_localized_strings({
        ["menu_deck14_1_desc"] = "100% of damage you deal is converted into Hysteria Stacks, up to ##300## every ##1## seconds. Max amount of stacks is ##900## \n\nHysteria Stacks\nYou gain ##3## damage absorption for every 20 stacks of Hysteria. Hysteria Stacks decays ##60% + 40## every ##12## seconds.",
        ["menu_deck14_3_desc"] = "Members of your crew also gains the effect of your Hysteria Stacks.\n\nHysteria Stacks from multiple crew members do not stack and only the stacks that gives the highest damage absorption will have an effect.",
        ["menu_deck14_5_desc"] = "Change the decay of your Hysteria Stacks to ##60% + 40## every ##12## seconds.",
        ["menu_deck14_7_desc"] = "Change the damage absorption of your Hysteria Stacks on you and your crew to ##3## damage absorption for every ##15## stacks of Hysteria.",
        ["menu_deck14_9_desc"] = "Damage absorption from Hysteria Stacks on you is increased by ##100%##.\n\nDeck Completion Bonus: Your chance of getting a higher quality item during a PAYDAY is increased by ##10%##."
    })
end)

local text_original = LocalizationManager.text
function LocalizationManager:text(string_id, ...)

return string_id == "stels" and "Hacker"
or string_id == "stels_desc" and "Shinobis are one of the most dangerous criminals. There's nothing they can't do."
or string_id == "stels_1" and "Binsho"
or string_id == "stels_1_desc" and "You gain the ##Stoic Perk##."
or string_id == "stels_2" and "Dorobo"
or string_id == "stels_2_desc" and "You gain the ##Tag Team Perk##."
or string_id == "stels_3" and "Kurina"
or string_id == "stels_3_desc" and "You gain the ##Hacker Perk##."
or string_id == "stels_4" and "Shado"
or string_id == "stels_4_desc" and "You gain the ##Burglar Perk##."
or string_id == "stels_5" and "Satsujin-sha"
or string_id == "stels_5_desc" and "Your health is increased by ##20%## and you gain ability to regenerate ##10%## of health by melee kills (1 second cooldown).\n\nYou deal ##200%## more damage with blade melee weapons and have chance to spread panic among enemies.\n\nDodging will replenish your armor. You gain ##+2## passive concealment and your movement speed is increased by additional ##20%##.\n\nThe time between swapping weapons is reduced for you by ##80%##. You bag corpses ##20%## faster and you answer pagers ##10%## faster. You gain a ##16%## boost in your movement speed.\n\nYou and your crew's stamina is increased by ##100##. You and your crew will gain ##12%## stamina for every hostage up to 4 times and increases your intimidate range by ##25%##.\n\nYou pick locks ##30%## faster.\n\nDeck Completion Bonus: Your chance of getting a higher quality item during a PAYDAY is increased by ##10%##."
or string_id == "menu_deckall_2_stels" and "Helmet Popping"
or string_id == "menu_deckall_2_desc_stels" and "You gain the ##Kingpin Perk##.\n\nIncreases your headshot damage by ##25%##."
or string_id == "menu_deckall_4_stels" and "Blending In"
or string_id == "menu_deckall_4_desc_stels" and "You gain the ##Sicario Perk##.\n\nYou gain ##+1## increased concealment.\n\nWhen wearing armor, your movement speed is ##15%## less affected.\n\nYou gain ##45%## more experience when you complete days and jobs."
or string_id == "menu_deckall_6_stels" and "Walk-in Closet"
or string_id == "menu_deckall_6_desc_stels" and "You gain the ##Crew Chief Perk##.\n\nUnlocks an armor bag equipment for you to use. The armor bag can be used to change your armor during a heist.\n\nIncreases your ammo pickup to ##135%## of the normal rate."
or string_id == "menu_deckall_8_stels" and "Fast and Furious"
or string_id == "menu_deckall_8_desc_stels" and "You gain the ##Maniac Perk##.\n\nYou deal ##5%## more damage. Does not apply to melee damage, throwables, grenade launchers, crossbows, and the HRL-7 Rocket Launcher.Increases your doctor bag interaction speed by ##20%##."
or text_original(self, string_id, ...)
end