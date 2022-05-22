--https://github.com/mwSora/payday-2-luajit/blob/master/pd2-lua/lib/tweak_data/weapontweakdata.lua

if CommandManager.config["weapon_tweak_ammo_buffs"] then
	local old_pickup_chance = WeaponTweakData._pickup_chance
	function WeaponTweakData:_pickup_chance(max_ammo, selection_index)
		old_pickup_chance(self, max_ammo, selection_index)
		local PICKUP = {
			SNIPER_HIGH_DAMAGE = 6,
			SHOTGUN_HIGH_CAPACITY = 4,
			AR_HIGH_CAPACITY = 2,
			OTHER = 1,
			SNIPER_LOW_DAMAGE = 5,
			AR_MED_CAPACITY = 3
		}
		local low, high = nil
		if selection_index == PICKUP.AR_HIGH_CAPACITY then
			low = 0.3
			high = 0.55
		elseif selection_index == PICKUP.AR_MED_CAPACITY then
			low = 0.3
			high = 0.55
		elseif selection_index == PICKUP.SHOTGUN_HIGH_CAPACITY then
			low = 0.5
			high = 0.75
		elseif selection_index == PICKUP.SNIPER_LOW_DAMAGE then
			low = 0.5
			high = 0.75
		elseif selection_index == PICKUP.SNIPER_HIGH_DAMAGE then
			low = 0.05
			high = 0.15
		else
			low = 0.1
			high = 0.35
		end

		return {
			max_ammo * low,
			max_ammo * high
		}
	end
end

local old_init = WeaponTweakData.init
function WeaponTweakData:init(tweak_data)
    old_init(self, tweak_data)
	
	if CommandManager.config["weapon_tweak_sniper_shake_buffs"] then
		for _, v in pairs(self) do
			if type(v.categories) == "table" and table.contains(v.categories, "snp") then
				-- fire kick backwards
				if v.shake and v.shake.fire_steelsight_multiplier then
					v.shake.fire_steelsight_multiplier = 0
				end
				
				-- fire kick sideways
				if v.kick and v.kick.steelsight then 
					v.kick.steelsight = {0, 0, 0, 0}
				end
				
				-- dot moving in circle after fire
				if v.animations and v.animations.recoil_steelsight then
					v.animations.recoil_steelsight = false
				end
			end
		end
	end
	
	if CommandManager.config["weapon_tweak_buffs"] then
	-- grimm
	self.basset.stats.damage = 150
	self.basset.stats.zoom = 5
	self.basset.stats.alert_size = 50
	self.basset.FIRE_MODE = "auto"
	self.basset.auto = {fire_rate = 0.2}
	self.basset.single = {fire_rate = 0.1}
	self.basset.fire_mode_data = {fire_rate = 0.15}
	self.basset.CAN_TOGGLE_FIREMODE = true
	
	-- izma
	self.saiga.stats.damage = 170
	self.saiga.stats.zoom = 5
	self.saiga.stats.alert_size = 50
	self.saiga.FIRE_MODE = "auto"
	self.saiga.auto = {fire_rate = 0.2}
	self.saiga.single = {fire_rate = 0.1}
	self.saiga.fire_mode_data = {fire_rate = 0.15}
	self.saiga.CAN_TOGGLE_FIREMODE = true
	
	-- mini vulcan gun
	self.shuno.stats.damage = 80
	self.shuno.stats_modifiers = {damage = 1}
	self.shuno.stats.spread = 18 --accuracy higher=better
	self.shuno.stats.alert_size = 50
	self.shuno.timers.reload_not_empty = 0.7
	self.shuno.timers.reload_empty = 0.7
	
	-- baby deagle
	self.sparrow.stats.damage = 380
	self.sparrow.stats.spread = 30 --accuracy higher=better
	self.sparrow.stats.zoom = 6
	self.sparrow.stats.alert_size = 100
	self.sparrow.panic_suppression_chance = 0
	self.sparrow.suppression = 0
	
	-- grom sniper
	self.siltstone.stats.damage = 320
	self.siltstone.stats.spread = 30 --accuracy higher=better
	self.siltstone.stats.zoom = 20
	self.siltstone.panic_suppression_chance = 0
	self.siltstone.stats.alert_size = 100
	self.siltstone.stats_modifiers = {damage = 2}
	self.siltstone.FIRE_MODE = "single"
	self.siltstone.fire_mode_data = {fire_rate = 0.2}
	self.siltstone.BURST_FIRE = 4
	
	-- contractor tti
	self.tti.stats.damage = 160
	self.tti.stats.spread = 30 --accuracy higher=better
	self.tti.stats.zoom = 20
	self.tti.panic_suppression_chance = 0
	self.tti.stats.alert_size = 100
	self.tti.stats_modifiers = {damage = 2}
	self.tti.single = {fire_rate = 0.3}
	self.tti.fire_mode_data = {fire_rate = 0.1}
	self.tti.BURST_FIRE = 4
	
	-- Joceline O/U 12G b682
	self.b682.CLIP_AMMO_MAX = 28
	self.b682.NR_CLIPS_MAX = 4
	self.b682.AMMO_MAX = self.b682.CLIP_AMMO_MAX * self.b682.NR_CLIPS_MAX
	self.b682.stats.total_ammo_mod = 42
	self.b682.FIRE_MODE = "single"
	self.b682.auto = {fire_rate = 0.4}
	self.b682.single = {fire_rate = 0.1}
	self.b682.fire_mode_data = {fire_rate = 0.1}
	self.b682.CAN_TOGGLE_FIREMODE = true
	self.b682.stats.zoom = 6
	self.b682.stats.alert_size = 100
	
	-- Mosconi 12G
	self.huntsman.CLIP_AMMO_MAX = 10
	self.huntsman.NR_CLIPS_MAX = 3
	self.huntsman.FIRE_MODE = "single"
	self.huntsman.auto = {fire_rate = 0.4}
	self.huntsman.single = {fire_rate = 0.1}
	self.huntsman.fire_mode_data = {fire_rate = 0.1}
	self.huntsman.CAN_TOGGLE_FIREMODE = true
	self.huntsman.stats.zoom = 6
	
	-- Thanatos .50 cal
	self.m95.stats.damage = 5200
	self.m95.stats.spread = 30 --accuracy higher=better
	self.m95.stats.zoom = 6
	self.m95.stats.suppression = 0
	self.m95.stats.alert_size = 100
	self.m95.FIRE_MODE = "single"
	self.m95.fire_mode_data = {fire_rate = 0.2} -- single fire
	self.m95.AMMO_MAX = self.m95.CLIP_AMMO_MAX * self.m95.NR_CLIPS_MAX
	self.m95.auto = {fire_rate = 0.7}
	self.m95.BURST_FIRE = 6
	
	-- Flamethrower Mk. 17
	self.system.stats.damage = 14
	self.system.stats.spread = 100
	self.system.stats.zoom = 6
	self.system.stats.reload = 13
	self.system.stats.alert_size = 100
	self.system.FIRE_MODE = "auto"
	self.system.fire_mode_data = {fire_rate = 0.001} -- single fire
	self.system.auto = {fire_rate = 0.001}
	self.system.CAN_TOGGLE_FIREMODE = true
	self.system.flame_max_range = 8000
	self.system.fire_dot_data.dot_trigger_chance = 100 --100% turn fire on
	self.system.fire_dot_data.dot_trigger_max_distance = 8000 --distance of ft
	self.system.fire_dot_data.dot_damage = 8 --fire dmg
	self.system.fire_dot_data.dot_tick_period = 0.1 --how fast fire takes dmg
	self.system.fire_dot_data.dot_length = 30.0	--how long fire last
	self.system.timers.reload_not_empty = 5.3
	self.system.timers.reload_empty = 5.3
	
	-- Flamethrower Mk. 1
	self.flamethrower_mk2.stats.damage = 14
	self.flamethrower_mk2.stats.spread = 100
	self.flamethrower_mk2.stats.zoom = 6
	self.flamethrower_mk2.stats.reload = 13
	self.flamethrower_mk2.stats.alert_size = 100
	self.flamethrower_mk2.FIRE_MODE = "auto"
	self.flamethrower_mk2.fire_mode_data = {fire_rate = 0.001} -- single fire
	self.flamethrower_mk2.auto = {fire_rate = 0.001}
	self.flamethrower_mk2.CAN_TOGGLE_FIREMODE = true
	self.flamethrower_mk2.flame_max_range = 8000
	self.flamethrower_mk2.fire_dot_data.dot_trigger_chance = 100 --100% turn fire on
	self.flamethrower_mk2.fire_dot_data.dot_trigger_max_distance = 8000 --distance of ft
	self.flamethrower_mk2.fire_dot_data.dot_damage = 8 --fire dmg 1 is 10dmg
	self.flamethrower_mk2.fire_dot_data.dot_tick_period = 0.1 --how fast fire takes dmg
	self.flamethrower_mk2.fire_dot_data.dot_length = 30.0	--how long fire last
	self.flamethrower_mk2.timers.reload_not_empty = 6.3
	self.flamethrower_mk2.timers.reload_empty = 5.3
	
	--GSPS 12G m37
	self.m37.CLIP_AMMO_MAX = 10
	self.m37.NR_CLIPS_MAX = 4
	--self.m37.FIRE_MODE = "single"
	self.m37.single = {fire_rate = 0.25}
	self.m37.fire_mode_data = {fire_rate = 0.25}
	--self.m37.CAN_TOGGLE_FIREMODE = true
	self.m37.stats.zoom = 6
	self.m37.stats.alert_size = 1
	self.m37.BURST_FIRE = 5
	
	--claire 12g coach
	self.coach.CLIP_AMMO_MAX = 10
	self.coach.NR_CLIPS_MAX = 3
	self.coach.FIRE_MODE = "single"
	self.coach.auto = {fire_rate = 0.4}
	self.coach.single = {fire_rate = 0.1}
	self.coach.fire_mode_data = {fire_rate = 0.1}
	self.coach.CAN_TOGGLE_FIREMODE = true
	self.coach.stats.zoom = 6
	self.coach.stats.alert_size = 100
	self.coach.timers.reload_not_empty = 1.0
	self.coach.timers.reload_empty = 3.5
	
	--Pistol Crossbow hunter
	self.hunter.stats.damage = 200
	self.hunter.CLIP_AMMO_MAX = 20
	self.hunter.NR_CLIPS_MAX = 100
	self.hunter.AMMO_MAX = self.hunter.NR_CLIPS_MAX
	self.hunter.stats.spread = 50 --accuracy higher=better
	self.hunter.stats.zoom = 6
	self.hunter.stats.alert_size = 50
	self.hunter.FIRE_MODE = "auto"
	self.hunter.auto = {fire_rate = 0.2}
	self.hunter.single = {fire_rate = 0.2}
	self.hunter.fire_mode_data = {fire_rate = 0.2}
	self.hunter.CAN_TOGGLE_FIREMODE = true
	
	--heavy crossbow
	self.arblast.stats.damage = 10000
	self.arblast.stats.zoom = 6
	self.arblast.stats.alert_size = 50
	self.arblast.FIRE_MODE = "auto"
	self.arblast.single = {fire_rate = 0.2}
	self.arblast.fire_mode_data = {fire_rate = 0.2}
	
	--Airbow ecp
	self.ecp.stats.damage = 200
	self.ecp.CLIP_AMMO_MAX = 30
	self.ecp.NR_CLIPS_MAX = 60
	self.ecp.stats.spread = 50 --accuracy higher=better
	self.ecp.stats.zoom = 6
	self.ecp.stats.alert_size = 50
	self.ecp.FIRE_MODE = "auto"
	self.ecp.auto = {fire_rate = 0.2}
	self.ecp.single = {fire_rate = 0.2}
	self.ecp.fire_mode_data = {fire_rate = 0.2}
	self.ecp.CAN_TOGGLE_FIREMODE = true
	self.ecp.timers.reload_not_empty = 0.2
	self.ecp.timers.reload_empty = 0.2
	
	--plainstrider
	self.plainsrider.stats.suppression = 0
	self.plainsrider.stats.spread = 100 --accuracy higher=better
	self.plainsrider.stats.recoil = 100 --stability higher=better
	self.plainsrider.CLIP_AMMO_MAX = 30
	self.plainsrider.NR_CLIPS_MAX = 60
	self.plainsrider.charge_data = {max_t = 0.01}
	self.plainsrider.bow_reload_speed_multiplier = 3
	self.plainsrider.FIRE_MODE = "single"
	self.plainsrider.auto = {fire_rate = 0.4}
	self.plainsrider.single = {fire_rate = 0.1}
	self.plainsrider.fire_mode_data = {fire_rate = 0.1}
	self.plainsrider.CAN_TOGGLE_FIREMODE = false
	self.plainsrider.timers.reload_not_empty = 0.2
	self.plainsrider.timers.reload_empty = 0.2
	self.plainsrider.stats.zoom = 7
	
	--deca
	self.elastic.stats.suppression = 0
	self.elastic.stats.spread = 100 --accuracy higher=better
	self.elastic.stats.recoil = 100 --stability higher=better
	self.elastic.CLIP_AMMO_MAX = 30
	self.elastic.NR_CLIPS_MAX = 60
	self.elastic.charge_data = {max_t = 0.01}
	self.elastic.bow_reload_speed_multiplier = 3
	self.elastic.FIRE_MODE = "single"
	self.elastic.auto = {fire_rate = 0.4}
	self.elastic.single = {fire_rate = 0.1}
	self.elastic.fire_mode_data = {fire_rate = 0.1}
	self.elastic.CAN_TOGGLE_FIREMODE = false
	self.elastic.timers.reload_not_empty = 0.2
	self.elastic.timers.reload_empty = 0.2
	self.elastic.stats.zoom = 7
	
	--interceptor
	self.usp.stats.damage = 80
	self.usp.stats.spread = 100
	self.usp.stats.zoom = 6
	self.usp.stats.alert_size = 100
	self.usp.FIRE_MODE = "single" -- start with using single/auto depends if the gun is auto/single
	self.usp.auto = {fire_rate = 0.2}
	self.usp.single = {fire_rate = 0.1}
	self.usp.fire_mode_data = {fire_rate = 0.1}
	self.usp.CAN_TOGGLE_FIREMODE = true
	
	--stryke pistol glock_18c
	self.glock_18c.stats.damage = 50
	self.glock_18c.stats.spread = 100 --accuracy higher=better
	self.glock_18c.stats.zoom = 6
	self.glock_18c.suppression = 0
	self.glock_18c.stats.alert_size = 100
	self.glock_18c.CLIP_AMMO_MAX = 30
	self.glock_18c.NR_CLIPS_MAX = 8
	self.glock_18c.FIRE_MODE = "auto"
	self.glock_18c.auto = {fire_rate = 0.4}
	self.glock_18c.single = {fire_rate = 0.1}
	self.glock_18c.fire_mode_data = {fire_rate = 0.1}
	self.glock_18c.CAN_TOGGLE_FIREMODE = true
	self.glock_18c.panic_suppression_chance = 0
	
	-- akimbo STRYKE x_g18c 
	self.x_g18c.CLIP_AMMO_MAX = 60
	self.x_g18c.NR_CLIPS_MAX = 5
	self.x_g18c.stats.damage = 50
	self.x_g18c.stats.spread = 100 --accuracy higher=better
	self.x_g18c.stats.zoom = 6
	self.x_g18c.stats.suppression = 0
	self.x_g18c.stats.alert_size = 100
	self.x_g18c.FIRE_MODE = "auto"
	self.x_g18c.auto = {fire_rate = 0.4}
	self.x_g18c.single = {fire_rate = 0.1}
	self.x_g18c.fire_mode_data = {fire_rate = 0.1}
	self.x_g18c.CAN_TOGGLE_FIREMODE = true
	
	-- shotgun12g boot
	self.boot.CLIP_AMMO_MAX = 28
	self.boot.NR_CLIPS_MAX = 3
	self.boot.stats.damage = 200
	self.boot.FIRE_MODE = "single"
	self.boot.auto = {fire_rate = 0.4}
	self.boot.single = {fire_rate = 0.1}
	self.boot.fire_mode_data = {fire_rate = 0.1}
	self.boot.CAN_TOGGLE_FIREMODE = true
	self.boot.stats.zoom = 6
	self.boot.stats.alert_size = 1
	
	--bronco 44 revolver new_raging_bull
	self.new_raging_bull.CLIP_AMMO_MAX = 12
	self.new_raging_bull.NR_CLIPS_MAX = 3
	self.new_raging_bull.stats.damage = 225
	self.new_raging_bull.stats_modifiers = {damage = 1.4}
	self.new_raging_bull.stats.spread = 100 --accuracy higher=better
	self.new_raging_bull.stats.recoil = 4
	self.new_raging_bull.stats.suppression = 0
	self.new_raging_bull.panic_suppression_chance = 1.0
	self.new_raging_bull.stats.alert_size = 100
	self.new_raging_bull.FIRE_MODE = "single"
	self.new_raging_bull.single = {fire_rate = 0.3}
	self.new_raging_bull.fire_mode_data = {fire_rate = 0.1}
	self.new_raging_bull.stats.zoom = 6
	self.new_raging_bull.timers = {
		reload_not_empty = 1.25,
		reload_empty = 1.25,
		unequip = 0.5,
		equip = 0.45
	}
	self.new_raging_bull.BURST_FIRE = 4
	
	--akimbo bronco x_rage
	self.x_rage.CLIP_AMMO_MAX = 24
	self.x_rage.NR_CLIPS_MAX = 6
	self.x_rage.stats.damage = 250
	self.x_rage.stats_modifiers = {damage = 1.4}
	self.x_rage.stats.spread = 100 --accuracy higher=better
	self.x_rage.stats.recoil = 4
	self.x_rage.stats.suppression = 0
	self.x_rage.panic_suppression_chance = 1.0
	self.x_rage.stats.alert_size = 100
	self.x_rage.FIRE_MODE = "single"
	self.x_rage.single = {fire_rate = 0.3}
	self.x_rage.fire_mode_data = {fire_rate = 0.1}
	self.x_rage.stats.zoom = 6
	self.x_rage.timers = {
		reload_not_empty = 1.585,
		reload_empty = 2,
		unequip = 0.5,
		equip = 0.5
	}
	
	--peacemaker 45 peacemaker
	self.peacemaker.CLIP_AMMO_MAX = 18
	self.peacemaker.NR_CLIPS_MAX = 2
	self.peacemaker.stats.damage = 350
	self.peacemaker.stats.spread = 100 --accuracy higher=better
	self.peacemaker.stats.recoil = 7
	self.peacemaker.stats.suppression = 0
	self.peacemaker.panic_suppression_chance = 1.0
	self.peacemaker.stats.alert_size = 100
	self.peacemaker.single = {fire_rate = 0.3}
	self.peacemaker.fire_mode_data = {fire_rate = 0.2}
	self.peacemaker.stats.zoom = 6
	self.peacemaker.stats.reload = 21
	self.peacemaker.timers = {
		shotgun_reload_enter = 1.0333333333333333,
		shotgun_reload_exit_empty = 0.2333333333333333,
		shotgun_reload_exit_not_empty = 0.2333333333333333,
		shotgun_reload_shell = 0.7,
		shotgun_reload_first_shell_offset = 0,
		unequip = 0.65,
		equip = 0.65
	}
	self.peacemaker.stats_modifiers = {damage = 9}
	self.peacemaker.BURST_FIRE = 8
	
	--broomstick c96
	self.c96.CLIP_AMMO_MAX = 20
	self.c96.NR_CLIPS_MAX = 5
	self.c96.stats.damage = 70
	self.c96.single = {fire_rate = 0.12}
	self.c96.fire_mode_data = {fire_rate = 0.12}
	self.c96.stats.spread = 100 --accuracy higher=better
	self.c96.stats.zoom = 6
	self.c96.panic_suppression_chance = 0
	self.c96.stats.alert_size = 100
	self.c96.timers = {
		reload_not_empty = 1.7,
		reload_empty = 2.17,
		unequip = 0.5,
		equip = 0.35
	}
	self.c96.BURST_FIRE = 6
	
	--broomstick x_c96
	self.x_c96.CLIP_AMMO_MAX = 20
	self.x_c96.NR_CLIPS_MAX = 10
	self.x_c96.stats.damage = 70
	self.x_c96.single = {fire_rate = 0.12}
	self.x_c96.fire_mode_data = {fire_rate = 0.12}
	self.x_c96.stats.spread = 100 --accuracy higher=better
	self.x_c96.stats.recoil = 20
	self.x_c96.stats.zoom = 6
	self.x_c96.stats.alert_size = 100
	self.x_c96.panic_suppression_chance = 0
	self.x_c96.timers = {
		reload_not_empty = 2.23,
		reload_empty = 2.8,
		unequip = 0.5,
		equip = 0.5
	}
	
	--parabellum breech
	self.breech.CLIP_AMMO_MAX = 16
	self.breech.NR_CLIPS_MAX = 6
	self.breech.stats.suppression = 0
	self.breech.panic_suppression_chance = 1.0
	self.breech.stats.alert_size = 100
	self.breech.single = {fire_rate = 0.12}
	self.breech.fire_mode_data = {fire_rate = 0.12}
	self.breech.stats.spread = 100 --accuracy higher=better
	self.breech.stats.zoom = 6
	self.breech.timers = {
		reload_not_empty = 1.33,
		reload_empty = 2.1,
		unequip = 0.5,
		equip = 0.35
	}
	self.breech.BURST_FIRE = 6
	
	--akimbo parabellum x_breech
	self.x_breech.CLIP_AMMO_MAX = 20
	self.x_breech.NR_CLIPS_MAX = 12
	self.x_breech.stats.suppression = 0
	self.x_breech.panic_suppression_chance = 1.0
	self.x_breech.stats.alert_size = 100
	self.x_breech.single = {fire_rate = 0.12}
	self.x_breech.fire_mode_data = {fire_rate = 0.12}
	self.x_breech.stats.spread = 100 --accuracy higher=better
	self.x_breech.stats.recoil = 10
	self.x_breech.stats.zoom = 6
	self.x_breech.timers = {
		reload_not_empty = 2.13,
		reload_empty = 2.7,
		unequip = 0.5,
		equip = 0.5
	}
	
	--matever mateba
	self.mateba.CLIP_AMMO_MAX = 12
	self.mateba.NR_CLIPS_MAX = 3
	self.mateba.stats.spread = 100 --accuracy higher=better
	self.mateba.stats.recoil = 7
	self.mateba.stats.zoom = 6
	self.mateba.stats.suppression = 0
	self.mateba.panic_suppression_chance = 1.0
	self.mateba.stats.alert_size = 100
	self.mateba.BURST_FIRE = 4
	
	--matever mateba
	self.x_2006m.CLIP_AMMO_MAX = 12
	self.x_2006m.NR_CLIPS_MAX = 6
	self.x_2006m.stats.spread = 100 --accuracy higher=better
	self.x_2006m.stats.recoil = 7
	self.x_2006m.stats.zoom = 6
	self.x_2006m.stats.suppression = 0
	self.x_2006m.panic_suppression_chance = 1.0
	self.x_2006m.stats.alert_size = 100
	
	--castigo chinchilla
	self.chinchilla.CLIP_AMMO_MAX = 12
	self.chinchilla.NR_CLIPS_MAX = 6
	self.chinchilla.stats.damage = 200
	self.chinchilla.stats.spread = 30 --accuracy higher=better
	self.chinchilla.stats.recoil = 5
	self.chinchilla.single = {fire_rate = 0.3}
	self.chinchilla.fire_mode_data = {fire_rate = 0.1}
	self.chinchilla.CAN_TOGGLE_FIREMODE = true
	self.chinchilla.stats.zoom = 6
	self.chinchilla.stats.suppression = 0
	self.chinchilla.panic_suppression_chance = 1.0
	self.chinchilla.stats.alert_size = 100
	self.chinchilla.timers = {
		reload_not_empty = 1.17,
		reload_empty = 1.17,
		unequip = 0.5,
		equip = 0.45
	}
	self.chinchilla.BURST_FIRE = 4
	
	--akimbo castigo x_chinchilla
	self.x_chinchilla.CLIP_AMMO_MAX = 24
	self.x_chinchilla.NR_CLIPS_MAX = 6
	self.x_chinchilla.stats.damage = 200
	self.x_chinchilla.stats.spread = 40 --accuracy higher=better
	self.x_chinchilla.stats.recoil = 5
	self.x_chinchilla.single = {fire_rate = 0.1}
	self.x_chinchilla.fire_mode_data = {fire_rate = 0.1}
	self.x_chinchilla.stats.zoom = 6
	self.x_chinchilla.stats.suppression = 0
	self.x_chinchilla.panic_suppression_chance = 1.0
	self.x_chinchilla.stats.alert_size = 100
	self.x_chinchilla.timers = {
		reload_not_empty = 1.87,
		reload_empty = 1.87,
		unequip = 0.5,
		equip = 0.5
	}
	
	-- akimbo deagle x_deagle
	self.x_deagle.stats.damage = 190
	self.x_deagle.stats.spread = 100 --accuracy higher=better
	self.x_deagle.stats.zoom = 6
	self.x_deagle.stats.alert_size = 100
	self.x_deagle.FIRE_MODE = "single"
	self.x_deagle.auto = {fire_rate = 0.4}
	self.x_deagle.single = {fire_rate = 0.1}
	self.x_deagle.fire_mode_data = {fire_rate = 0.1}
	self.x_deagle.CAN_TOGGLE_FIREMODE = true
	
	--china piglet granade
	self.china.CLIP_AMMO_MAX = 40
	self.china.NR_CLIPS_MAX = 1
	self.china.stats.damage = 192
	self.china.stats.spread = 100 --accuracy higher=better
	self.china.stats.zoom = 6
	self.china.stats.alert_size = 100
	self.china.FIRE_MODE = "single"
	self.china.auto = {fire_rate = 0.4}
	self.china.single = {fire_rate = 0.1}
	self.china.fire_mode_data = {fire_rate = 0.1}
	self.china.CAN_TOGGLE_FIREMODE = true
	
	--gre_m79 granade
	self.gre_m79.CLIP_AMMO_MAX = 20
	self.gre_m79.NR_CLIPS_MAX = 2
	self.gre_m79.stats.damage = 192
	self.gre_m79.stats.spread = 100 --accuracy higher=better
	self.gre_m79.stats.zoom = 6
	self.gre_m79.stats.alert_size = 100
	self.gre_m79.FIRE_MODE = "single"
	self.gre_m79.auto = {fire_rate = 0.4}
	self.gre_m79.single = {fire_rate = 0.1}
	self.gre_m79.fire_mode_data = {fire_rate = 0.1}
	self.gre_m79.CAN_TOGGLE_FIREMODE = true

	--arbiter granade
	self.arbiter.CLIP_AMMO_MAX = 20
	self.arbiter.NR_CLIPS_MAX = 2
	self.arbiter.stats.damage = 686
	self.arbiter.DAMAGE = 686
	self.arbiter.stats.spread = 100 --accuracy higher=better
	self.arbiter.stats.zoom = 6
	self.arbiter.stats.alert_size = 100
	self.arbiter.FIRE_MODE = "single"
	self.arbiter.auto = {fire_rate = 0.4}
	self.arbiter.single = {fire_rate = 0.1}
	self.arbiter.fire_mode_data = {fire_rate = 0.1}
	self.arbiter.CAN_TOGGLE_FIREMODE = true
	
	--slap compact granade
	self.slap.CLIP_AMMO_MAX = 20
	self.slap.NR_CLIPS_MAX = 3
	self.slap.stats.damage = 192
	self.slap.stats.spread = 100 --accuracy higher=better
	self.slap.stats.zoom = 6
	self.slap.stats.alert_size = 100
	self.slap.FIRE_MODE = "single"
	self.slap.auto = {fire_rate = 0.4}
	self.slap.single = {fire_rate = 0.1}
	self.slap.fire_mode_data = {fire_rate = 0.1}
	self.slap.CAN_TOGGLE_FIREMODE = true
	
	--piglet granade lanucher m32 
	self.m32.damage = 692
	self.m32.CLIP_AMMO_MAX = 12
	self.m32.NR_CLIPS_MAX = 3
	self.m32.stats.spread = 100 --accuracy higher=better
	self.m32.stats.zoom = 6
	self.m32.stats.reload = 14
	self.m32.stats.alert_size = 100
	self.m32.FIRE_MODE = "single"
	self.m32.fire_mode_data = {fire_rate = 0.001} -- single fire
	self.m32.auto = {fire_rate = 0.1}
	self.m32.CAN_TOGGLE_FIREMODE = true
	self.m32.timers.shotgun_reload_enter = 0.96
	self.m32.timers.shotgun_reload_exit_empty = 0.33
	self.m32.timers.shotgun_reload_exit_not_empty = 0.33
	self.m32.timers.shotgun_reload_shell = 1
	self.m32.timers.shotgun_reload_first_shell_offset = 0
	
	--little friend
	self.contraband.stats.damage = 180
	self.contraband.CLIP_AMMO_MAX = 30
	self.contraband.NR_CLIPS_MAX = 3
	self.contraband.stats.spread = 100 --accuracy higher=better
	self.contraband.stats.zoom = 5
	self.contraband.stats.alert_size = 100
	self.contraband.FIRE_MODE = "auto"
	self.contraband.single = {fire_rate = 0.1}
	self.contraband.CAN_TOGGLE_FIREMODE = true
	--granade launcher for contraband
	self.contraband_m203.stats.damage = 100000
	self.contraband_m203.CLIP_AMMO_MAX = 5
	self.contraband_m203.NR_CLIPS_MAX = 3
	self.contraband_m203.stats.zoom = 5
	self.contraband_m203.single = {fire_rate = 0.1}
	self.contraband_m203.CAN_TOGGLE_FIREMODE = true
	
	--cavity
	self.sub2000.CLIP_AMMO_MAX = 66
	self.sub2000.NR_CLIPS_MAX = 4
	self.sub2000.stats.zoom = 5
	self.sub2000.FIRE_MODE = "auto"
	self.sub2000.single = {fire_rate = 0.1}
	self.sub2000.CAN_TOGGLE_FIREMODE = true
	
	--steakout
	self.aa12.stats.damage = 170
	self.aa12.CLIP_AMMO_MAX = 32
	self.aa12.NR_CLIPS_MAX = 4
	self.aa12.stats.zoom = 5
	self.aa12.FIRE_MODE = "auto"
	self.aa12.single = {fire_rate = 0.1}
	self.aa12.CAN_TOGGLE_FIREMODE = true
	
	--golden ak
	self.akm_gold.stats.damage = 115
	self.akm_gold.CLIP_AMMO_MAX = 32
	self.akm_gold.NR_CLIPS_MAX = 4
	self.akm_gold.stats.spread = 100 --accuracy higher=better
	self.akm_gold.stats.zoom = 5
	self.akm_gold.stats.alert_size = 100
	self.akm_gold.FIRE_MODE = "auto"
	self.akm_gold.single = {fire_rate = 0.1}
	self.akm_gold.CAN_TOGGLE_FIREMODE = true
	
	--m308
	self.new_m14.stats.damage = 180
	self.new_m14.CLIP_AMMO_MAX = 20
	self.new_m14.NR_CLIPS_MAX = 6
	self.new_m14.stats.zoom = 5
	self.new_m14.FIRE_MODE = "auto"
	self.new_m14.single = {fire_rate = 0.1}
	self.new_m14.CAN_TOGGLE_FIREMODE = true
	
	--valkyria
	self.asval.CLIP_AMMO_MAX = 100
	self.asval.NR_CLIPS_MAX = 4
	self.asval.stats.zoom = 5
	self.asval.FIRE_MODE = "auto"
	self.asval.single = {fire_rate = 0.1}
	self.asval.CAN_TOGGLE_FIREMODE = true
	
	--ak17
	self.flint.stats.damage = 115
	self.flint.CLIP_AMMO_MAX = 40
	self.flint.stats.spread = 100 --accuracy higher=better
	self.flint.stats.recoil = 17
	self.flint.stats.zoom = 5
	self.flint.stats.alert_size = 100
	self.flint.FIRE_MODE = "auto"
	self.flint.single = {fire_rate = 0.1}
	self.flint.CAN_TOGGLE_FIREMODE = true
	
	--bootleg rifle
	self.tecci.stats.zoom = 5
	self.tecci.FIRE_MODE = "auto"
	self.tecci.single = {fire_rate = 0.1}
	self.tecci.CAN_TOGGLE_FIREMODE = true
	
	--jackal
	self.schakal.CLIP_AMMO_MAX = 30
	self.schakal.NR_CLIPS_MAX = 4
	self.schakal.stats.zoom = 5
	self.schakal.FIRE_MODE = "auto"
	self.schakal.auto = {fire_rate = 0.07}
	self.schakal.single = {fire_rate = 0.1}
	self.schakal.fire_mode_data = {fire_rate = 0.1}
	self.schakal.CAN_TOGGLE_FIREMODE = true
	
	--akimbo jackal
	self.x_schakal.stats.damage = 150
	self.x_schakal.CLIP_AMMO_MAX = 60
	self.x_schakal.NR_CLIPS_MAX = 8
	self.x_schakal.stats.spread = 100 --accuracy higher=better
	self.x_schakal.stats.recoil = 18
	self.x_schakal.stats.zoom = 5
	self.x_schakal.stats.alert_size = 100
	self.x_schakal.FIRE_MODE = "auto"
	self.x_schakal.single = {fire_rate = 0.1}
	self.x_schakal.CAN_TOGGLE_FIREMODE = true
	self.x_schakal.shake.fire_multiplier = 0
	self.x_schakal.kick.standing = {0.3,0.3,-0.1,0}
	
	--kross vertex
	self.polymer.stats.damage = 85
	self.polymer.CLIP_AMMO_MAX = 60
	self.polymer.NR_CLIPS_MAX = 3
	self.polymer.stats.zoom = 5
	self.polymer.FIRE_MODE = "auto"
	self.polymer.single = {fire_rate = 0.1}
	self.polymer.CAN_TOGGLE_FIREMODE = true
	self.polymer.shake.fire_multiplier = 0
	
	--akimbo goliath
	self.x_rota.stats.damage = 150
	self.x_rota.CLIP_AMMO_MAX = 30
	self.x_rota.NR_CLIPS_MAX = 4
	self.x_rota.stats.spread = 5
	self.x_rota.stats.zoom = 5
	self.x_rota.stats.alert_size = 100
	self.x_rota.FIRE_MODE = "single"
	self.x_rota.auto = {fire_rate = 0.8}
	self.x_rota.single = {fire_rate = 0.1}
	self.x_rota.fire_mode_data = {fire_rate = 0.15}
	self.x_rota.CAN_TOGGLE_FIREMODE = true
	
	--chicago typewriter
	self.x_m1928.stats.damage = 80
	self.x_m1928.CLIP_AMMO_MAX = 180
	self.x_m1928.NR_CLIPS_MAX = 4
	self.x_m1928.stats.zoom = 5
	self.x_m1928.stats.alert_size = 100
	self.x_m1928.FIRE_MODE = "auto"
	self.x_m1928.single = {fire_rate = 0.1}
	self.x_m1928.CAN_TOGGLE_FIREMODE = true
	--self.x_m1928.shake.fire_multiplier = 0
	self.x_m1928.kick.standing = {0.2,0.2,-0.1,0}
	
	--saw ove9000
	self.saw.stats.damage = 5000
	self.saw.CLIP_AMMO_MAX = 500
	self.saw.NR_CLIPS_MAX = 4
	self.saw.stats.zoom = 5
	self.saw.stats.alert_size = 100
	self.saw.stats.suppression = 0
	
	for _, weap in pairs(self) do
		if weap.CAN_TOGGLE_FIREMODE and not weap.BURST_FIRE then
			weap.BURST_FIRE = false
		end
	end
	
	--bipod deploy time
	self.hk21.timers.deploy_bipod = 0
	self.m249.timers.deploy_bipod = 0
	self.rpk.timers.deploy_bipod = 0
	self.mg42.timers.deploy_bipod = 0
	self.par.timers.deploy_bipod = 0
	end
	
	if CommandManager.config["sentry_buffs"] then
	--sentry
	self.sentry_gun.DAMAGE = 15 --host side
	self.sentry_gun.SHIELD_DMG_MUL = 0.001 --client side
	self.sentry_gun.SUPPRESSION = 1
	self.sentry_gun.SPREAD = 0 --client side
	self.sentry_gun.FIRE_RANGE = 20000 --client side
	--self.sentry_gun.auto.fire_rate = 0.01 --host side
	self.sentry_gun.alert_size = 20000 --client side
	self.sentry_gun.MAX_VEL_SPIN = 360 --client side
	end
end