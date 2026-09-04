global_meleesaw_toggle = not global_meleesaw_toggle

-- use saw to open lock at melee hit position
local function use_saw()
	local player_unit = managers and managers.player and managers.player:player_unit()
	if not player_unit or not alive(player_unit) then return end
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local range = tweak_data.blackmarket.melee_weapons[melee_entry].stats.range or 175
	local from = player_unit:movement():m_head_pos()
	local to = from + player_unit:movement():m_head_rot():y() * range
	local raytrace = player_unit:raycast("ray", from, to, "slot_mask", InstantBulletBase:bullet_slotmask(), "ignore_unit", {}, "ray_type", "body bullet lock")
	if raytrace and raytrace.position and raytrace.body then
		local damage = 200
		local hit_unit = raytrace.unit
		if hit_unit and hit_unit:damage() and raytrace.body:extension() and raytrace.body:extension().damage then
			-- apply saw usage at melee hit position
			raytrace.body:extension().damage:damage_lock(player_unit, raytrace.normal, raytrace.position, raytrace.direction, damage)
			-- sync to peers
			if hit_unit:id() ~= -1 then
				managers.network:session():send_to_peers_synched("sync_body_damage_lock", raytrace.body, damage)
			end
			if true then
				--spawn the fancy sawing particles
				local effect = World:effect_manager():spawn({
					effect = Idstring("effects/payday2/particles/weapons/saw/sawing"),
					position = raytrace.hit_position,
					normal = math.UP
				})
				--make the fancy sawing particles sod off
				DelayedCalls:Add("ParticleKill", 0.1, function() World:effect_manager():fade_kill(effect) end)
			end

			-- cut bars near by
			local cut_bars = {
				["deeb533605a7f83b"] = true, -- units/payday2/architecture/com_int_gallery/com_int_gallery_wall_painting_bars
				["545592fb733f5bff"] = true, -- units/payday2/props/gen_prop_bank_atm_standing/gen_prop_bank_atm_standing
			}
			local bodies = World:find_bodies("intersect", "cylinder", raytrace.position, Vector3(0, 0, 1), 125, managers.slot:get_mask("bullet_impact_targets"))
			for _, hit_body in pairs(bodies) do
				if hit_body:unit() and alive(hit_body:unit()) and cut_bars[hit_body:unit():name():key()] and hit_body:extension() and hit_body:extension().damage then
					hit_body:extension().damage:damage_lock(player_unit, raytrace.normal, hit_body:unit():position(), raytrace.direction, damage)
					if hit_unit:id() ~= -1 then
						managers.network:session():send_to_peers_synched("sync_body_damage_lock", hit_body, damage)
					end
				end
			end

			-- open deposit boxes near by
			local deposit_boxes = {
			    ["79991727a2679722"] = true, -- units/payday2/architecture/bnk/bnk_int_deposit_box
			    ["e93c9b2218810d63"] = true, -- units/pd2_dlc2/props/deposit_box/csgo_deposit_box
			    ["a95e021324bc842a"] = true, -- units/payday2/architecture/bnk/bnk_deposit_box/bnk_deposit_box
			    ["d2d7c5a3aced6f0f"] = true, -- units/pd2_dlc_jfr/pickups/spawn_german_folder/spawn_german_folder
			    ["e4bc87015ed9fd46"] = true, -- units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport_deposit_box
			    ["50aac55917cba830"] = true, -- units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport_deposit_box_intel
			    ["5dcd1776e3f2f767"] = true, -- units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/spawn_deposit/spawn_gold
			    ["8d8c766828915eb9"] = true, -- units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/spawn_deposit/spawn_money
			    ["51da6d6c91d378c1"] = true, -- units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/spawn_deposit/spawn_jewelry
			    ["ea4c3c264006fd13"] = true, -- units/pd2_dlc_casino/props/cas_prop_locker/cas_prop_locker
			}
			local filter_world_units = managers.slot:get_mask("all")
			for _,unit in pairs(World:find_units_quick("all", filter_world_units) or {}) do
				local interaction = unit and alive(unit) and unit.interaction and unit:interaction()
				if interaction and deposit_boxes[unit:name():key()] then
					local dist = mvector3.distance(unit:position(), raytrace.position)
					if dist < 50 then
						interaction:interact(player_unit)
					end
				end
			end
		end
	end
end

Hooks:PostHook(PlayerStandard, "_do_action_melee", "Melee_Saw", function(self, ...)
	if global_meleesaw_toggle then
		use_saw()
	end
end)

-- make saw totally silent
Hooks:PostHook(SawWeaponBase, "start_shooting", "Silent_Saw", function(self, ...)
	self._no_hit_alert_size_bak = self._no_hit_alert_size_bak or self._no_hit_alert_size
	self._hit_alert_size_bak = self._hit_alert_size_bak or self._hit_alert_size
	if global_meleesaw_toggle then
		self._no_hit_alert_size = 0 -- eliminates alert on revving
		self._hit_alert_size = 0 -- eliminates alert on impact
	else
		self._no_hit_alert_size = self._no_hit_alert_size_bak
		self._hit_alert_size = self._hit_alert_size_bak
	end
end)

if global_meleesaw_toggle then
	managers.mission._fading_debug_output:script().log('Melee Saw - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('Melee Saw - Deactivated',  Color.red)
end
