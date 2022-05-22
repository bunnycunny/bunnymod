local original_init_masks = BlackMarketTweakData._init_masks
function BlackMarketTweakData:_init_masks(tweak_data)
	original_init_masks(self, tweak_data)

	for _, v in pairs(self.masks) do
		v.night_vision = {
			effect = "color_night_vision_blue", --"color_night_vision" green color
			light = not _G.IS_VR and 1
		}
	end
end