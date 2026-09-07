-- if the map have secure area but none of them activated, then drop bag at the position where player use this script

local drop_bag_time = 1 -- drop bag time for each position
local maximal_bags_per_drop_bag_time = 5 -- prevent drop bags too fast
global_is_dropping_bag = not global_is_dropping_bag -- false value means stop dropping bag

local function get_real_drop_bag_time(bag_count)
	-- drop maximal_bags_per_drop_bag_time bags per drop_bag_time at maximal
	local time = drop_bag_time
	if bag_count > maximal_bags_per_drop_bag_time then
		time = drop_bag_time * bag_count / maximal_bags_per_drop_bag_time
	end
	return time
end

local function get_all_secure_area()
	local invalid = { -- bag despawn areas
		['rat'] = { [102299] = true },
		['crojob2'] = { [105173] = true },
		['welcome_to_the_jungle_2'] = { [103653] = true },
		['framing_frame_1'] = { [104285] = true, [104286] = true, [101046] = true, [101052] = true, [101820] = true, [101920] = true, [101931] = true }, -- prevent bag touch laser
		['arm_for'] = { [103924] = true },
		['firestarter_2'] = { [100777] = true },
	}
	local custom_position = {
		['trai'] = { Vector3(-3432, 6910, 446.987) },
		['framing_frame_1'] = { Vector3(1154, -4298, 222) }, -- 100667, set higher priority
		['cane'] = { Vector3(-3293, -736, -18), Vector3(7830, -980, -19.28) },
		['jolly'] = { Vector3(12862, 8834, 140) },
		['arm_for'] = { Vector3(-5341, -6825, -1044.9) },
		['help'] = {
			-- base on "_editor_name=waypoint_secure" and fine-tune
			Vector3(794+50, -2150, -243), Vector3(1791.47+50, -3475.05-50, 157), Vector3(-793.999-50, -1050, 157),
			Vector3(-793.999-50, -2150, 557), Vector3(-793.999-50, -2150, 157), Vector3(-794-50, -2150, -243),
			Vector3(600, -856+50, -243), Vector3(1844.2-50, -1230.04-50, 157), Vector3(2186.44+50, -746.422+50, 557),
			Vector3(-399.999, -3119-50, 140), Vector3(794.001+50, -1050, 157), Vector3(1225, -1356+50, -243),
			Vector3(-600, -856+50, -243), Vector3(-1800.14-50, -2454.34+50, 157), Vector3(0.000999451, -3119-50, -243),
			Vector3(-1200, -1156+50, 157), Vector3(794+50, -2150, 557), Vector3(-1225, -1356+50, -243),
			Vector3(794+50, -2150, 157), Vector3(-1200, -1156+50, 557), Vector3(400.001, -3119-50, 140),
		},
	}

	local level = managers.job:current_level_id()
	local positions = {}
	-- add custom secure area
	for _,position in pairs(custom_position[level] or {}) do
		table.insert(positions, position)
	end
	-- find secure area
	for _, script in pairs(managers.mission._scripts) do
		for _, element in pairs(script._elements) do
			local values = element._values
			if ((values.instigator == "loot") or (values.instigator == "unique_loot")) and values.position and (not (invalid[level] and invalid[level][element:id()])) then
				if element._values.enabled then
					local is_add = true
					local player_pos = managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and managers.player:player_unit():movement():m_head_pos()
					-- special situation
					if level == "framing_frame_2" and player_pos then -- Framing Frame, day 2
						if element._values.position.x > 2000 and player_pos.x < 2000 then
							is_add = false
						end
					end
					if level == "pbr" and player_pos then -- Beneath the Mountain
						if element._values.position.z > 2000 and player_pos.z < 2000 then
							is_add = false
						end
					end
					if level == "mex" and player_pos then -- Border Crossing
						if element._values.position.z < -1000 and player_pos.z > -1000 then
							is_add = false
						end
						if element._values.position.z > -1000 and player_pos.z < -1000 then
							is_add = false
						end
					end
					if level == "help" then -- Prison Nightmare
						--[[
						if element._editor_name == "bag_removal" or element._editor_name == "area_destroy_bag" or element._editor_name == "area_destroy_unique_bag" then
							is_add = false
						end
						]]--
						-- this mission can't get secure area by mission element
						is_add = false
					end
					if is_add then
						table.insert(positions, element._values.position)
						-- managers.chat:_receive_message(1, "debug", "job_id=" .. tostring(level) .. " ,element_id=" .. tostring(element:id()) .. " ,position=" .. tostring(element._values.position), Color.green)
					end
				end
			end
		end
	end
	-- drop at current position if all secure area is not available
	if managers and managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and managers.player:player_unit():movement() and managers.player:player_unit():movement():m_head_pos() then
		local head_pos = managers.player:player_unit():movement():m_head_pos()
		local pos = Vector3(head_pos.x, head_pos.y, head_pos.z) -- deep clone
		table.insert(positions, pos)
	end

	return positions
end

local function drop_bag_at_position(position)
	if not managers or not managers.player or not managers.player:player_unit() then return end

	local carry_data = managers.player:get_my_carry_data()
	local player_cam = managers.player:player_unit():camera()
	local rotation = player_cam:rotation()
	local forward = Vector3(0,0,0)
	if carry_data then
		if Network:is_server() then
			managers.player:server_drop_carry(carry_data.carry_id,carry_data.multiplier, carry_data.dye_initiated,carry_data.has_dye_pack, carry_data.dye_value_multiplier,position, rotation, forward, 1, nil,managers.network:session():local_peer())
		else
			managers.network:session():send_to_host("server_drop_carry",carry_data.carry_id, carry_data.multiplier,carry_data.dye_initiated, carry_data.has_dye_pack,carry_data.dye_value_multiplier,position, rotation, forward, 1, nil)
		end

		managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
		managers.hud:temp_hide_carry_bag()
		managers.player:update_removed_synced_carry_to_peers()
		managers.player:set_player_state("standard")

		-- if the map have despawn areas, then the last appear position is despawn areas
		-- managers.chat:_receive_message(1, "debug", "position=" .. tostring(position) .. " ,rotation=" .. tostring(rotation) .. " ,forward=" .. tostring(forward), Color.green)
	end
end

local function cancel_all_delayedcalls(delayedcalls_ids)
	for _,id in pairs(delayedcalls_ids or {}) do
		DelayedCalls:Remove(id)
		-- if you remove a id that doesn't exist, it will remove it next time when it's created
		-- this can make sure it won't remove the DelayedCalls that add next time with same id
		DelayedCalls:Add(id, 0, function() end)
	end
end

local function show_waypoint(vector)
	local waypoint_name = "default_reveal_vector_position"
	managers.hud:remove_waypoint(waypoint_name)
	if vector then
		managers.hud:add_waypoint(
			waypoint_name, {
			icon = 'equipment_vial',
			distance = true,
			position = vector,
			no_sync = true,
			present_timer = 0,
			state = "present",
			radius = 50,
			color = Color.gray,
			blend_mode = "add"
		})
	end
end

local function secure_loots()
	if not BaseNetworkHandler or not managers or not managers.player then return end

	local player_unit = managers.player and managers.player:player_unit()
	local state = managers.player and managers.player._current_state
	if not player_unit or not alive(player_unit) or state == "bleed_out" or state == "incapacitated" or state == "fatal" or state == "arrested" then
		return
	end

	-- use this script second time when dropping, means stop dropping, stop dropping process in DelayedCalls, no need to run script again
	if not global_is_dropping_bag then
		return
	end

	if managers.player:is_carrying() then
		managers.player:drop_carry()
	end

	local temp_delayedcalls_ids = {}

	local positions = get_all_secure_area()
	if #positions == 0 then
		managers.mission._fading_debug_output:script().log('Secure Loots: no secure area',  Color.yellow)
		global_is_dropping_bag = false
		return
	end

	-- preliminary estimate drop_bag_time multiplier
	local temp_bag_count = 0
	for _,unit in pairs(managers.interaction._interactive_units or {}) do
		local interaction = unit and alive(unit) and unit.interaction and unit.interaction(unit)
		if interaction and (interaction.tweak_data == "carry_drop" or interaction.tweak_data == "painting_carry_drop" or interaction.tweak_data == "safe_carry_drop" or interaction.tweak_data == "goat_carry_drop") then
			temp_bag_count = temp_bag_count + 1
		end
	end
	if temp_bag_count == 0 then
		managers.mission._fading_debug_output:script().log('Secure Loots: no bag',  Color.yellow)
		global_is_dropping_bag = false
		return
	end
	drop_bag_time = get_real_drop_bag_time(temp_bag_count)

	local delay1 = drop_bag_time
	local temp_idx1 = 0
	for position_id,position in pairs(positions) do
		local temp_delayedcalls_id_1 = "drop_bag_at_position_" .. tostring(position_id)
		table.insert(temp_delayedcalls_ids, temp_delayedcalls_id_1)
		DelayedCalls:Add(temp_delayedcalls_id_1, (delay1 * temp_idx1 + 0.1), function()
			-- managers.chat:_receive_message(1, "debug", "position_id=" .. tostring(position_id) .. ", position=" .. tostring(position), Color.green)
			-- once interacted, unit will change, need to find again
			local interactive_units = {}
			for _,unit in pairs(managers.interaction._interactive_units or {}) do
				local interaction = unit and alive(unit) and unit.interaction and unit.interaction(unit)
				if interaction and (interaction.tweak_data == "carry_drop" or interaction.tweak_data == "painting_carry_drop" or interaction.tweak_data == "safe_carry_drop" or interaction.tweak_data == "goat_carry_drop") then
					table.insert(interactive_units, unit)
				end
			end
			if #interactive_units == 0 then
				managers.mission._fading_debug_output:script().log('Secure Loots: all bag secured',  Color.yellow)
				-- show_waypoint()
				global_is_dropping_bag = false
				cancel_all_delayedcalls(temp_delayedcalls_ids)
				temp_delayedcalls_ids = {}
				return
			end

			local delay2 = ( drop_bag_time / (#interactive_units + 1) )
			local temp_idx2 = 0
			for unit_id,unit in pairs(interactive_units) do
				local temp_delayedcalls_id_2 = "drop_bag_".. tostring(position_id) .. "-" .. tostring(unit_id)
				table.insert(temp_delayedcalls_ids, temp_delayedcalls_id_2)
				-- drop bag have delay, need to wait for the animation
				DelayedCalls:Add(temp_delayedcalls_id_2, delay2 * (temp_idx2+1) , function()
					-- managers.chat:_receive_message(1, "debug", "bag_id=" .. tostring(unit_id) .. ", bag=" .. tostring(unit) .. ", position_id=" .. tostring(position_id) .. ", position=" .. tostring(position), Color.green)
					if global_is_dropping_bag then -- false value means stop dropping bag
						local interaction = unit and alive(unit) and unit.interaction and unit.interaction(unit)
						if interaction and managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) then
							if managers.player:is_carrying() then
								drop_bag_at_position(position)
								-- show_waypoint(position)
							end
							if not managers.player:is_carrying() then
								interaction:interact(managers.player:player_unit())
							end
							if managers.player:is_carrying() then
								drop_bag_at_position(position)
								-- show_waypoint(position)
							end
						end
						if position_id == #positions and unit_id == #interactive_units then
							managers.mission._fading_debug_output:script().log('Secure Loots: tried all secure area',  Color.yellow)
							-- show_waypoint()
							global_is_dropping_bag = false
							temp_delayedcalls_ids = {}
						end
					else
						managers.mission._fading_debug_output:script().log('Secure Loots: cancelled',  Color.yellow)
						-- show_waypoint()
						cancel_all_delayedcalls(temp_delayedcalls_ids)
						temp_delayedcalls_ids = {}
					end
				end)
				temp_idx2 = temp_idx2 +1
			end
		end)
		temp_idx1 = temp_idx1 +1
	end

	if global_is_dropping_bag then
		managers.mission._fading_debug_output:script().log('Secure Loots: start',  Color.yellow)
	end
end


secure_loots()
