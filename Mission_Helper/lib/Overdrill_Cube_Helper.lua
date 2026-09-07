if not Global.level_data or Global.level_data.level_id ~= "red2" then
	return
end

local puzzle_ints = {
	["7832.71 1325 -25"] = 6,		-- 1 closest from drilled door
	["7868.07 1360.36 -25"] = 5,	-- 2 closest from drilled door
	["7902.71 1325.71 -25"] = 4,	-- 3 closest from drilled door
	["7902.71 1255 -25"] = 3,		-- 4 closest from drilled door
	["7938.78 1218.93 -25"] = 2,	-- 5 closest from drilled door
	["7974.13 1254.29 -25"] = 1	-- 6 closest from drilled door
}
units = {}

local function truncate(dec, t)
	for key,number in pairs(type(dec) == "number" and t or {}) do
		local strnum = tostring(number)
		local i = strnum:find("%.")

		if i and dec < (#strnum - i) then
			t[key] = tonumber(string.sub(strnum, 1, i+dec))
		end
	end
	return t
end

if RequiredScript == "lib/managers/objectinteractionmanager" then
	local orig_ObjectInteractionManager_add_unit = ObjectInteractionManager.add_unit
	function ObjectInteractionManager:add_unit(unit, ...)
		orig_ObjectInteractionManager_add_unit(self, unit, ...)

		local interaction = alive(unit) and unit.interaction ~= nil and unit:interaction().tweak_data

		if interaction and interaction == "s_cube" then
			local tweak = tweak_data.interaction[interaction]
			local pos = unit:position()
			local result = truncate(2, {x = pos.x, y = pos.y, z = pos.z})
			local unique_id = unit:id()

			if puzzle_ints[result.x .. " " .. result.y .. " " .. result.z] then
				managers.hud:add_waypoint("right_tile_" .. unique_id, {
					icon = "wp_target", 
					position = Vector3((pos.x - 25), pos.y, pos.z), 
					present_timer = 0, 
					state = "present", 
					radius = 10,
					blend_mode = "add" 
				})
				managers.hud:get_waypoint_data("right_tile_" .. unique_id).bitmap:set_color(Color.green)
				units[unique_id] = "right_tile_"
			end
		end
	end

	local total_tile_count, right_tile_count = 0, 0
	local orig_ObjectInteractionManager_remove_unit = ObjectInteractionManager.remove_unit
	function ObjectInteractionManager:remove_unit(unit, ...)
		local interaction = alive(unit) and unit.interaction and unit:interaction().tweak_data

		if interaction and interaction == "s_cube" then
			local pos = unit:position()
			local result = truncate(2, {x = pos.x, y = pos.y, z = pos.z})
			local right_index = puzzle_ints[result.x .. " " .. result.y .. " " .. result.z]
			total_tile_count = total_tile_count + 1

			if right_index and right_index == total_tile_count then
				right_tile_count = right_tile_count + 1
				managers.hud:remove_waypoint("right_tile_" .. unit:id())
			end

			if total_tile_count ~= right_tile_count or right_tile_count == 6 then
				total_tile_count, right_tile_count = 0, 0

				for unit, tile in pairs(units) do
					managers.hud:remove_waypoint(tile .. unit)
				end
			end
		end

		orig_ObjectInteractionManager_remove_unit(self, unit, ...)
	end
end
