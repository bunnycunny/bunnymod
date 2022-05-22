--tweak vehicle
local old_init = VehicleTweakData.init
function VehicleTweakData:init(tweak_data)
	old_init(self, tweak_data)
	for _,car in pairs(self) do
		car.max_rpm = 12000
		car.max_speed = 300
		local infinite_bag_space 	  = false -- dump infinite bags in vehicle trunks
		local shoot_from_inside		  = true -- every passenger able to shoot from inside a vehicle
		local infinite_vehicle_health = true -- vehicle infinite health
		if infinite_bag_space and car.max_loot_bags then car.max_loot_bags = 10000 end
		if infinite_vehicle_health and car.damage and car.damage.max_health then car.damage.max_health = 500000000 end
		if shoot_from_inside then
			for name, passenger in pairs(car.seats) do 
				if name ~= "driver" then passenger.allow_shooting = true end 
			end
		end
	end
end--]]