-- if the number of existing equipment exceeds the carrying limit, you will get cheater tag, using up all deployed equipment before spawn more can prevent that


local function get_crosshair_position()
	if managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) then
		local from = managers.player:player_unit():movement():m_head_pos()
		local to = from + managers.player:player_unit():movement():m_head_rot():y() * 10000
		local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
		if ray then
			local pos = ray.position
			local rot = managers.player:player_unit():rotation()
			return ray, pos, rot
		end
	end
	return nil, nil, nil
end

local ray, pos, rot = get_crosshair_position()
if not ray or not pos or not rot then
	return
end




local function spawn_trip_mine()
	local sensor_upgrade = managers.player:has_category_upgrade("trip_mine", "sensor_toggle")
	if managers.network and managers.network._session and Network:is_client() then
		managers.network:session():send_to_host("place_trip_mine", pos, ray.normal, sensor_upgrade)
	else 
		local rot = Rotation(ray.normal, math.UP)
		local unit = TripMineBase.spawn(pos, rot, sensor_upgrade, managers.network:session():local_peer():id())
		unit:base():set_active(true, managers.player:player_unit())
	end
end

local function spawn_body_bag()
	local amount_upgrade_lvl = 0
	if managers.network and managers.network._session and Network:is_client() then
		managers.network:session():send_to_host("place_deployable_bag", "BodyBagsBagBase", pos, rot, amount_upgrade_lvl)
	else 
		local unit = BodyBagsBagBase.spawn(pos, rot, amount_upgrade_lvl, managers.network:session():local_peer():id())
	end
end

local function spawn_ecm()
	local attach_sync_unit, attach_sync_unit_id = nil
	if ray.unit and ray.unit.id and ray.unit:id() ~= -1 then
		local attach_sync_unit = ray.unit
		local attach_sync_unit_id = ""
	else
		local attach_unit_key = ray.unit:key()
		local function verify_id_for_sync(id)
			local world_unit = managers.worlddefinition:get_unit(id)
			if alive(world_unit) and world_unit:key() == attach_unit_key then
				return id
			end
		end
		local attach_unit_id = ray.unit:unit_data().unit_id
		attach_sync_unit_id = attach_unit_id ~= 0 and verify_id_for_sync(attach_unit_id) or verify_id_for_sync(ray.unit:editor_id()) or nil
		if type(attach_sync_unit_id) == "number" then
			attach_sync_unit_id = tostring(attach_sync_unit_id) .. "ISNUMBER"
		end
	end

	local sync_body_index = ray.unit:get_body_index(ray.body:name())
	local world_pos = ray.position
	local world_rot = Rotation()
	mrotation.set_look_at(world_rot, ray.normal, math.UP)
	local relative_pos = mvector3.copy(world_pos)
	mvector3.subtract(relative_pos, ray.body:position())
	local relative_rot = ray.body:rotation()
	mrotation.invert(relative_rot)
	mvector3.rotate_with(relative_pos, relative_rot)
	mrotation.multiply(relative_rot, world_rot)
	relative_rot = Rotation(relative_rot:yaw(), relative_rot:pitch(), relative_rot:roll())
	local duration_multiplier = managers.player:upgrade_level("ecm_jammer", "duration_multiplier", 0) + managers.player:upgrade_level("ecm_jammer", "duration_multiplier_2", 0) + 1

	if managers.network and managers.network._session and Network:is_client() then
		-- managers.network:session():send_to_host("request_place_ecm_jammer", attach_sync_unit, attach_sync_unit_id, sync_body_index, mvector3.copy(world_pos), world_rot, relative_pos, relative_rot, duration_multiplier)
	else
		local ecm_unit = ECMJammerBase.spawn(world_pos, world_rot, duration_multiplier, managers.player:player_unit(), managers.network:session():local_peer():id())
		ecm_unit:base():set_active(true)
		ecm_unit:base():link_attachment(ray.body, relative_pos, relative_rot)
		managers.network:session():send_to_peers_synched("sync_deployable_attachment", ecm_unit, attach_sync_unit, attach_sync_unit_id, sync_body_index, relative_pos, relative_rot)
		-- DelayedCalls will unspawn that ecm after few seconds
		DelayedCalls:Add("delete_ecm_unit" .. tostring(math.random()), 60, function()
			if ecm_unit and alive(ecm_unit) then
				World:delete_unit(ecm_unit)
			end
		end)
	end
end

local function spawn_first_aid_kit()
	local upgrade_lvl = managers.player:has_category_upgrade("first_aid_kit", "damage_reduction_upgrade") and 1 or 0
	local auto_recovery = managers.player:has_category_upgrade("first_aid_kit", "first_aid_kit_auto_recovery") and 1 or 0
	local bits = Bitwise:lshift(auto_recovery, FirstAidKitBase.auto_recovery_shift) + Bitwise:lshift(upgrade_lvl, FirstAidKitBase.upgrade_lvl_shift)

	if managers.network and managers.network._session and Network:is_client() then
		managers.network:session():send_to_host("place_deployable_bag", "FirstAidKitBase", pos, rot, bits)
	else
		local unit = FirstAidKitBase.spawn(pos, rot, bits, managers.network:session():local_peer():id())
	end
end

local function spawn_doctor_bag()
	local upgrade_lvl = managers.player:upgrade_level("first_aid_kit", "damage_reduction_upgrade")
	local amount_upgrade_lvl = managers.player:upgrade_level("doctor_bag", "amount_increase")
	upgrade_lvl = math.clamp(upgrade_lvl, 0, 2)
	amount_upgrade_lvl = math.clamp(amount_upgrade_lvl, 0, 2)
	local bits = Bitwise:lshift(upgrade_lvl, DoctorBagBase.damage_reduce_lvl_shift) + Bitwise:lshift(amount_upgrade_lvl, DoctorBagBase.amount_upgrade_lvl_shift)

	if managers.network and managers.network._session and Network:is_client() then
		managers.network:session():send_to_host("place_deployable_bag", "DoctorBagBase", pos, rot, bits)
	else 
		local unit = DoctorBagBase.spawn(pos, rot, bits, managers.network:session():local_peer():id())
	end
end

local function spawn_ammo_bag()
	local ammo_upgrade_lvl = managers.player:upgrade_level("ammo_bag", "ammo_increase")
	local bullet_storm_level = managers.player:upgrade_level("player", "no_ammo_cost")

	if managers.network and managers.network._session and Network:is_client() then
		managers.network:session():send_to_host("place_ammo_bag", pos, rot, ammo_upgrade_lvl, bullet_storm_level)
	else 
		local unit = AmmoBagBase.spawn(pos, rot, ammo_upgrade_lvl, managers.network:session():local_peer():id(), bullet_storm_level)
	end
end

-- spawn sentry gun as client will change your deployable to sentry gun
-- sentry gun will disappear after few seconds when run as host, if you interact with that sentry gun before it disappear, this script will change your deployable to sentry gun to prevent crash
local function spawn_sentry_gun()
	local selected_index = 1
	local unit_idstring_index = nil

	local ammo_level = managers.player:upgrade_value("sentry_gun", "extra_ammo_multiplier", 1)
	local armor_multiplier = 1 + managers.player:upgrade_value("sentry_gun", "armor_multiplier", 1) - 1 + managers.player:upgrade_value("sentry_gun", "armor_multiplier2", 1) - 1
	local can_switch_fire_mode = managers.player:has_category_upgrade("sentry_gun", "ap_bullets")
	local equipment_name = managers.player:equipment_in_slot(selected_index)
	local fire_mode_index = can_switch_fire_mode and managers.player:get_equipment_setting(equipment_name, "fire_mode") or 1

	if managers.network and managers.network._session and Network:is_client() then
		-- to be able to pick up sentry gun, you must equip sentry gun deployable
		managers.player:clear_equipment()
		managers.player._equipment.selections = {}
		managers.player:add_equipment({silent = true, equipment = "sentry_gun"})
		managers.network:session():send_to_host("place_sentry_gun", pos, rot, selected_index, managers.player:player_unit(), unit_idstring_index, ammo_level, fire_mode_index)

		-- can't get that sentry gun unit just spawned, you have to pick up sentry gun manually
		--[[DelayedCalls:Add("delete_sentry_gun_unit" .. tostring(math.random()), 20, function()
			-- managers.network:session():send_to_host("picked_up_sentry_gun", unit)
		end)]]--
	else
		local shield = managers.player:has_category_upgrade("sentry_gun", "shield")
		local sentry_gun_unit, spread_level, rot_level = SentryGunBase.spawn(managers.player:player_unit(), pos, rot, managers.network:session():local_peer():id(), false, unit_idstring_index)
		if sentry_gun_unit then
			local fire_rate_reduction = managers.player:upgrade_value("sentry_gun", "fire_rate_reduction", 1)
			managers.network:session():send_to_peers_synched("from_server_sentry_gun_place_result", managers.network:session():local_peer():id(), selected_index, sentry_gun_unit, rot_level, spread_level, shield, ammo_level, fire_mode_index)
			sentry_gun_unit:event_listener():call("on_setup", true)
			sentry_gun_unit:base():post_setup(fire_mode_index)

			-- fix crash when interact with sentry gun that just spawned
			local sentry_gun_interaction = sentry_gun_unit and alive(sentry_gun_unit) and sentry_gun_unit.interaction and sentry_gun_unit:interaction()
			if sentry_gun_interaction then
				-- option one: just simply disable interaction, and let DelayedCalls to unspawn that sentry gun
				-- sentry_gun_interaction.can_interact = function() return false end

				-- option two: change deployable to sentry gun, so you can interact with that sentry gun
				local orig_sentry_gun_interaction_interact = sentry_gun_interaction.interact
				sentry_gun_interaction.interact = function(self_unit, ...)
					managers.player:clear_equipment()
					managers.player._equipment.selections = {}
					managers.player:add_equipment({silent = true, equipment = "sentry_gun"})
					return orig_sentry_gun_interaction_interact(self_unit, ...)
				end
			end

			-- DelayedCalls will unspawn that sentry gun if you didn't interact
			DelayedCalls:Add("delete_sentry_gun_unit" .. tostring(math.random()), 20, function()
				if sentry_gun_unit and alive(sentry_gun_unit) then
					World:delete_unit(sentry_gun_unit)
				end
			end)
		end
	end
end

local function spawn_grenade_case()
	local amount_upgrade_lvl = 0
	if managers.network and managers.network._session and Network:is_client() then
		managers.network:session():send_to_host("place_deployable_bag", "GrenadeCrateDeployableBase", pos, rot, amount_upgrade_lvl)
	else
		local unit = GrenadeCrateDeployableBase.spawn(pos, rot, amount_upgrade_lvl, managers.network:session():local_peer():id())
	end
end

local function spawn_ammo_box()
	if managers.network and managers.network._session and Network:is_server() then
		local ammo_box_idstring = Idstring("units/pickups/ammo/ammo_pickup")
		World:spawn_unit(ammo_box_idstring, pos, rot)
	else
		local player_unit = managers.player and managers.player:player_unit()
		local closest_unit = nil
		local closest_distance = math.huge
		for _, ud in pairs(managers.enemy:all_enemies()) do
			if ud.unit and alive(ud.unit) and ud.unit:id() ~= -1 and ud.unit:position() and player_unit and alive(player_unit) and player_unit:position() then
				local distance = mvector3.distance(ud.unit:position(), player_unit:position())
				if distance < closest_distance then
					closest_unit = ud.unit
					closest_distance = distance
				end
			end
		end
		if closest_unit then
			managers.network:session():send_to_host("sync_spawn_extra_ammo", closest_unit)
		end
	end
end

-- not working as client
local function spawn_flash_grenades()
	if managers.network and managers.network._session and managers.groupai and Network:is_server() then
		local duration = 2
		managers.network:session():send_to_peers_synched("sync_smoke_grenade", pos, pos, duration, true, false)
		managers.groupai:state():sync_smoke_grenade(pos, pos, duration, true, false)
	end
end


-- spawn_trip_mine()
-- spawn_body_bag()
-- spawn_ecm()
spawn_first_aid_kit()
-- spawn_doctor_bag()
-- spawn_ammo_bag()
-- spawn_sentry_gun() -- this will change your deployable to sentry gun
-- spawn_grenade_case()
-- spawn_ammo_box()
-- spawn_flash_grenades() -- not working as client
managers.mission._fading_debug_output:script().log('Spawn Equipment', Color.yellow)

