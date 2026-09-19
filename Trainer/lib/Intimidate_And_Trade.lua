if managers.groupai:state():whisper_mode() then
	return
end


local function find_enemy_units_in_fov_for_intimidate()
	-- Get the player and camera objects
	local player = managers.player:local_player()
	if not player then return end
	local camera = player:camera()
	if not camera then return end

	-- Define FOV and distance
	local fov_angle = 60 -- Field of view angle (in degrees)
	local max_distance = 100 -- Maximum distance to search

	-- Camera position and direction
	local camera_pos = camera:camera_object():position()
	local camera_dir = camera:forward()

	-- Use a collision mask for enemies
	local mask = managers.slot:get_mask("enemies")

	-- Find units in the camera cone
	local units_in_fov = World:find_units("camera_cone", camera:camera_object(), camera_dir, fov_angle, max_distance, mask)

	local units_in_fov_new = {}
	for _, unit in pairs(units_in_fov or {}) do
		if unit and unit.brain and (unit:brain().is_current_logic and not unit:brain():is_current_logic("intimidated") or not unit:brain().is_current_logic) then
			table.insert(units_in_fov_new, unit)
		end
	end

	return units_in_fov_new
end

local function find_all_enemy_units_for_intimidate()
	local enemies_new = {} -- pairs(_,unit)
	local enemies = managers.enemy and managers.enemy.all_enemies and managers.enemy:all_enemies() -- pairs(_,ud), need to use "ud.unit" to get unit
	for _, ud in pairs(enemies or {}) do
		if ud.unit and ud.unit.brain and (ud.unit:brain().is_current_logic and not ud.unit:brain():is_current_logic("intimidated") or not ud.unit:brain().is_current_logic) then
			table.insert(enemies_new, ud.unit)
		end
	end
	return enemies_new
end

local function try_intimidate_enemy(is_in_fov)
	local enemies = is_in_fov and find_enemy_units_in_fov_for_intimidate() or find_all_enemy_units_for_intimidate()
	for _, unit in pairs(enemies or {}) do
		if not managers.groupai:state():is_enemy_special(unit) and alive(managers.player:player_unit()) and alive(unit) and unit:base() and unit:base()._tweak_table and unit:base()._tweak_table ~= "mute_security_undominatable" then

			-- host only, make you be able to intimidate unlimited enemies
			local orig_on_intimidated = CopLogicIdle.on_intimidated
			local orig__surrender = CopLogicIdle._surrender
			local function intimidate_function(data, amount, aggressor_unit, ...)
				-- crash fix for trying to intimidate shield or camptain winter or minions host
				if data.unit:base()._tweak_table == "shield" or data.unit:base()._tweak_table == "phalanx_vip" or data.unit:base()._tweak_table == "phalanx_minion" then
					return orig_on_intimidated(data, amount, aggressor_unit, ...)
				else
					local result = orig_on_intimidated(data, amount, aggressor_unit, ...)
					orig__surrender(data, amount, aggressor_unit)
					return result
				end
			end
			CopLogicIdle.on_intimidated = intimidate_function
			CopLogicAttack.on_intimidated = intimidate_function
			CopLogicArrest.on_intimidated = intimidate_function

			-- try to hurt an enemy
			local is_intimidated = false
			if alive(unit) and not unit:character_damage()._dead then
				local action_data = {damage = math.min(unit:character_damage()._health * 0.1, unit:character_damage()._HEALTH_INIT * 0.1), attacker_unit = managers.player:player_unit(), attack_dir = Vector3(0,0,0), name_id = 'cqc', armor_piercing = true, critical_hit = false, shield_knock = false, knock_down = false, stagger = false, col_ray = {position = unit:position(), body = unit:body("body")}}
				unit:character_damage():damage_melee(action_data)
			end

			-- try to intimidate an enemy 
			if alive(unit) and not unit:character_damage()._dead then
				if Network:is_client() then
					for i = 1, 10 do
						unit:network():send_to_host("long_dis_interaction", math.huge, managers.player:player_unit())
						--[[
						-- or
						if managers and managers.network and managers.network.session then
							local host = managers.network:session():server_peer()
							host:send("long_dis_interaction", unit, 1, host:unit(), false)
						end
						]]--
					end
				else
					unit:brain():on_intimidated(math.huge, managers.player:player_unit(), true)
					unit:brain():set_logic("intimidated")
					local action_data = {
						clamp_to_graph = true,
						type = "act",
						body_part = 1,
						variant = "tied_all_in_one",
						blocks = {light_hurt = -1, hurt = -1, heavy_hurt = -1, walk = -1}
					}
					if unit:brain():action_request(action_data) and unit:anim_data().hands_tied and unit:brain():is_current_logic("intimidated") then
						CopLogicIntimidated._do_tied(unit:brain()._logic_data, managers.player:player_unit())
					end
				end
				is_intimidated = true
				unit:contour():add("mark_enemy", false)
				managers.mission._fading_debug_output:script().log('Intimidate Enemy',  Color.yellow)
			end

			CopLogicIdle.on_intimidated = orig_on_intimidated
			CopLogicAttack.on_intimidated = orig_on_intimidated
			CopLogicArrest.on_intimidated = orig_on_intimidated

			if is_intimidated then
				break
			end

		end
	end
end

local function try_trade_enemy_hostage()
	-- find unit for trade: "unit:in_slot(22)" or "unit:brain():is_current_logic('trade')"
	for _, unit in ipairs(World:find_units_quick("all", 12, 22)) do
		local interaction = unit and alive(unit) and unit.interaction and unit.interaction(unit)
		if managers and managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and interaction and interaction.tweak_data == "hostage_trade" then
			local orig_interaction_can_interact = interaction.can_interact
			interaction.can_interact = function() return true end
			interaction:interact(managers.player:player_unit())
			interaction.can_interact = orig_interaction_can_interact
			managers.mission._fading_debug_output:script().log('Trade Enemy Hostage',  Color.yellow)
		end
	end
end

-- try to intimidate an enemy in fov, and then try to trade if there's any unit can be traded
try_intimidate_enemy(true)
try_trade_enemy_hostage()
managers.mission._fading_debug_output:script().log('Try Intimidate And Trade',  Color.yellow)
