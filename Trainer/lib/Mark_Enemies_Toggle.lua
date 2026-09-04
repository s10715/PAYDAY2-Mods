global_markenemies_toggle = not global_markenemies_toggle


local sync_to_teammates = false
local important_npc_sync_to_teammates = false
local draw_interactions_box = false

local important_npc_per_heist = {
	["dark"] = {}, -- Murky Station -- empty means don't highlight any important npc in this heist
	["framing_frame_2"] = {}, -- Framing Frame, day 2
	["election_day_1"] = {}, -- Election Day, day 1
	["chew"] = { -- The Biker Heist, day 2
		"units/pd2_dlc_born/characters/ene_gang_biker_boss/ene_gang_biker_boss",
	},
	["crojob3"] = {}, -- The Bomb: Forest
	["crojob2"] = {}, -- The Bomb: Dockyard
	["friend"] = { -- Scarface Mansion
		"units/pd2_dlc_friend/characters/ene_security_manager/ene_security_manager",
		"units/pd2_dlc_friend/characters/ene_drug_lord_boss_stealth/ene_drug_lord_boss_stealth",
		"units/pd2_dlc_friend/characters/ene_drug_lord_boss/ene_drug_lord_boss",
	},
	["deep"] = { -- Crude Awakening
		"units/pd2_dlc_deep/characters/ene_gabriel/ene_gabriel",
		"units/pd2_dlc_deep/characters/ene_gabriel_nomask/ene_gabriel_nomask",
	},
	["corp"] = {}, -- Hostile Takeover
	["bex"] = { -- San Martín Bank
		"units/pd2_dlc_bex/characters/civ_male_it_guy/civ_male_it_guy",
		--[[
		-- if you don't have the asset string, you can use idstring like this, but you have to find both unit's idstring and husk unit's idstring
		"Idstring(@IDd3e4a7224b974065@)", -- IT guy, server side unit
		"Idstring(@ID0e6cabc065c32c35@)", -- IT guy husk, client side unit
		]]--
	},
	["fex"] = { -- Buluc's Mansion
		"units/pd2_dlc_fex/characters/ene_guard_dog_mask/ene_guard_dog_mask",
		"units/pd2_dlc_fex/characters/ene_guard_jaguar_mask/ene_guard_jaguar_mask",
		"units/pd2_dlc_fex/characters/ene_guard_owl_mask/ene_guard_owl_mask",
		"units/pd2_dlc_fex/characters/ene_guard_serpent_mask/ene_guard_serpent_mask",
	},
	["jolly"] = { -- Aftershock
		"units/pd2_dlc_holly/characters/civ_male_hobo_1/civ_male_hobo_1",
	},
	["chca"] = { -- Black Cat
		"units/pd2_dlc_chca/characters/civ_male_boss_1/civ_male_boss_1", -- Xun Kang
		"units/pd2_dlc_chca/characters/civ_male_boss_2/civ_male_boss_2", -- Li Deng
	},
	["trai"] = { -- Lost In Transit
		"units/payday2/characters/civ_male_worker_1/civ_male_worker_1",
	},
	["pbr"] = {}, -- Beneath the Mountain
	["sah"] = { -- Shacklethorne Auction
		"units/pd2_dlc_sah/characters/civ_male_auctioneer/civ_male_auctioneer",
		"units/pd2_dlc_sah/characters/civ_male_maintenance_01/civ_male_maintenance_01",
	},
	["des"] = {}, -- Henry's Rock
	["pex"] = { -- Breakfast in Tijuana
		"units/pd2_dlc_pex/characters/npc_male_vladbroinlaw_pex/npc_male_vladbroinlaw_pex",
	},
	["wwh"] = { -- Alaskan Deal
		"units/payday2/characters/ene_cop_2/ene_cop_2",
	},
	["mex"] = {}, -- Border Crossing
	["mia_1"] = { -- Hotline Miami
		"units/payday2/characters/ene_gang_mobster_1/ene_gang_mobster_1",
		"units/payday2/characters/ene_gang_mobster_2/ene_gang_mobster_2",
		"units/payday2/characters/ene_gang_mobster_3/ene_gang_mobster_3",
		"units/payday2/characters/ene_gang_mobster_4/ene_gang_mobster_4",
	},
	["tag"] = { -- Breakin' Feds
		"units/pd2_dlc_tag/characters/ene_male_commissioner/ene_male_commissioner",
	},
	["big"] = { -- The Big Bank
		"units/payday2/characters/civ_male_bank_manager_3/civ_male_bank_manager_3",
	},
	["hox_2"] = {}, -- Hoxton Breakout, day 2
	["dah"] = { -- Diamond Heist
		"units/pd2_dlc_dah/characters/npc_male_ralph/npc_male_ralph",
		"units/pd2_dlc_dah/characters/npc_male_cfo/npc_male_cfo",
	},
	["flat"] = { -- Panic Room
		"units/pd2_dlc_flat/characters/npc_chavez/npc_chavez",
	},
	["run"] = {}, -- Heat Street
	["red2"] = { -- First World Bank
		"units/payday2/characters/civ_male_bank_manager_5/civ_male_bank_manager_5",
	},
	["roberts"] = { -- GO Bank
		--[[
		-- the one who have possibility to drop card will highlight
		"units/pd2_dlc2/characters/civ_female_bank_assistant_1/civ_female_bank_assistant_1",
		"units/pd2_dlc2/characters/civ_female_bank_assistant_2/civ_female_bank_assistant_2",
		"units/payday2/characters/civ_male_business_1/civ_male_business_1",
		"units/payday2/characters/civ_male_business_2/civ_male_business_2",
		"units/pd2_dlc2/csgo_models/props_bank/prop_bank_teller",
		]]--
		"units/pd2_dlc1/characters/civ_male_bank_manager_2/civ_male_bank_manager_2",
	},
	["kosugi"] = { -- Shadow Raid
		"units/payday2/characters/civ_male_worker_docks_2/civ_male_worker_docks_2",
	},
	["cage"] = { -- Car Shop
		"units/payday2/characters/civ_male_bank_manager_3/civ_male_bank_manager_3",
	},
	["family"] = { -- Diamond Store
		"units/payday2/characters/civ_female_bank_manager_1/civ_female_bank_manager_1",
	},
	["branchbank"] = { -- Bank Heist
		"units/payday2/characters/civ_male_bank_manager_1/civ_male_bank_manager_1",
		"units/payday2/characters/civ_male_dog_abuser_1/civ_male_dog_abuser_1",
		"units/payday2/characters/civ_male_dog_abuser_2/civ_male_dog_abuser_2",
	},
	["firestarter_3"] = { -- Firestarter, day 3
		"units/payday2/characters/civ_male_bank_manager_1/civ_male_bank_manager_1",
		"units/payday2/characters/civ_male_dog_abuser_1/civ_male_dog_abuser_1",
		"units/payday2/characters/civ_male_dog_abuser_2/civ_male_dog_abuser_2",
	},
}

local important_npc = {
	-- important civilians
	"units/payday2/characters/civ_female_bank_manager_1/civ_female_bank_manager_1",
	"units/payday2/characters/civ_female_curator_1/civ_female_curator_1",
	"units/payday2/characters/civ_female_curator_2/civ_female_curator_2",
	"units/payday2/characters/civ_male_bank_2/civ_male_bank_2",
	"units/payday2/characters/civ_male_bank_manager_1/civ_male_bank_manager_1",
	"units/payday2/characters/civ_male_bank_manager_3/civ_male_bank_manager_3",
	"units/payday2/characters/civ_male_bank_manager_4/civ_male_bank_manager_4",
	"units/payday2/characters/civ_male_bank_manager_5/civ_male_bank_manager_5",
	"units/payday2/characters/civ_male_casual_13/civ_male_casual_13",
	"units/payday2/characters/civ_male_curator_1/civ_male_curator_1",
	"units/payday2/characters/civ_male_curator_2/civ_male_curator_2",
	"units/payday2/characters/civ_male_curator_3/civ_male_curator_3",
	"units/payday2/characters/civ_male_dj_1/civ_male_dj_1",
	"units/payday2/characters/civ_male_dog_abuser_1/civ_male_dog_abuser_1",
	"units/payday2/characters/civ_male_dog_abuser_2/civ_male_dog_abuser_2",
	"units/payday2/characters/civ_male_pilot_1/civ_male_pilot_1",
	--"units/payday2/characters/civ_male_worker_docks_1/civ_male_worker_docks_1",
	--"units/payday2/characters/civ_male_worker_docks_2/civ_male_worker_docks_2",
	"units/pd2_dlc_bex/characters/civ_male_bex_bank_manager/civ_male_bex_bank_manager",
	"units/pd2_dlc_bph/characters/civ_male_locke_escort/civ_male_locke_escort",
	"units/pd2_dlc_cane/characters/civ_male_helper_1/civ_male_helper_1",
	"units/pd2_dlc_cane/characters/civ_male_helper_2/civ_male_helper_2",
	"units/pd2_dlc_cane/characters/civ_male_helper_3/civ_male_helper_3",
	"units/pd2_dlc_cane/characters/civ_male_helper_4/civ_male_helper_4",
	"units/pd2_dlc_casino/characters/civ_male_impersonator/civ_male_impersonator",
	"units/pd2_dlc_chas/characters/civ_male_auctioneer_2/civ_male_auctioneer_2",
	"units/pd2_dlc_corp/characters/civ_female_marketing_lead/civ_female_marketing_lead",
	"units/pd2_dlc_corp/characters/civ_male_researcher_lead/civ_male_researcher_lead",
	"units/pd2_dlc_dah/characters/npc_male_ralph/npc_male_ralph",
	"units/pd2_dlc_holly/characters/civ_male_hobo_1/civ_male_hobo_1",
	"units/pd2_dlc_moon/characters/civ_male_pilot_2/civ_male_pilot_2",
	"units/pd2_dlc_sah/characters/civ_male_auctioneer/civ_male_auctioneer",
	"units/pd2_dlc_sah/characters/civ_male_maintenance_01/civ_male_maintenance_01",
	"units/pd2_dlc1/characters/civ_male_bank_manager_2/civ_male_bank_manager_2",
	"units/pd2_dlc_dah/characters/npc_male_cfo/npc_male_cfo",

	-- important enemies
	"units/payday2/characters/ene_gang_mobster_boss/ene_gang_mobster_boss",
	"units/pd2_dlc_friend/characters/ene_drug_lord_boss/ene_drug_lord_boss",
	"units/pd2_dlc_friend/characters/ene_security_manager/ene_security_manager",
	"units/pd2_dlc_pent/characters/npc_male_yufuwang/npc_male_yufuwang",
	"units/pd2_dlc_pent/characters/npc_male_yufuwang_armored/npc_male_yufuwang_armored",
	"units/pd2_dlc_ranc/characters/ene_male_ranchmanager_1/ene_male_ranchmanager_1",
	"units/pd2_mcmansion/characters/ene_male_hector_1/ene_male_hector_1",
}

local function is_important_npc(unit)
	if not unit or not alive(unit) or not unit.name or not unit.character_damage then return false end
	if not unit:character_damage()._HEALTH_INIT or not (unit:character_damage()._health > 0.1) then return false end

	local is_important_npc = false
	-- only host can check if unit have special drop
	if Network and Network:is_server() then
		if unit.contour and unit:character_damage().pickup and unit:character_damage():pickup() and unit:character_damage():pickup() ~= "ammo" then
			is_important_npc = true
		end
	end

	local level_id = Global.level_data and Global.level_data.level_id
	for _, name_string in pairs(important_npc_per_heist[level_id] or important_npc or {}) do
		if unit:name() == Idstring(name_string) or unit:name() == Idstring(name_string .. "_husk") then
			is_important_npc = true
			break
		elseif string.sub(name_string, 1, string.len("Idstring(@ID")) == "Idstring(@ID" and tostring(unit:name()) == name_string then
			is_important_npc = true
			break
		end
	end

	return is_important_npc
end

local function is_hostage(unit, converted_only)
	if not unit or not alive(unit) or not unit.brain then return false end
	local brain = unit:brain()
	if brain then
		if not converted_only then
			if brain.is_hostage and brain.is_hostage(brain) then
				return true
			end
			local anim_data = unit.anim_data and unit.anim_data(unit)
			if anim_data then
				if anim_data.tied or anim_data.hands_tied then
					return true
				end
			end
		end
		if Network:is_server() and brain._logic_data then
			if (brain._logic_data.is_tied or brain._logic_data.is_converted and unit.is_converted) then
				return true
			end
		else
			if brain:surrendered() then
				return true
			end
		end
	end
	return false
end

local function check_wall(unit)
	local player_unit = managers and managers.player and managers.player:player_unit()
	if not alive(player_unit) or not player_unit.camera or not unit or not alive(unit) or not unit.key or not unit.movement then return end
	local from = player_unit:camera():position()
	local to = unit:movement():m_head_pos()
	local vis_ray = World:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("bullet_impact_targets"), "ignore_unit", {}, "thickness", 40, "thickness_mask", managers.slot:get_mask("world_geometry", "vehicles"))
	if vis_ray and vis_ray.unit and vis_ray.unit.key and vis_ray.unit:key() == unit:key() then
		return true
	end
end

-- check if already mark any unit on the map
local function is_any_unit_marked()
	local is_marked = false
	for _,u_data in pairs(managers.enemy:all_civilians() or {}) do
		if u_data.unit:contour():has_id("mark_enemy") or u_data.unit:contour():has_id("hostage_trade") or u_data.unit:contour():has_id("friendly") or u_data.unit:contour():has_id("mark_unit") or u_data.unit:contour():has_id("medic_heal") then
			is_marked = true
			return is_marked
		end
	end
	for _,u_data in pairs(managers.enemy:all_enemies() or {}) do
		if u_data.unit:contour():has_id("mark_enemy") or u_data.unit:contour():has_id("hostage_trade") or u_data.unit:contour():has_id("friendly") or u_data.unit:contour():has_id("mark_unit") or u_data.unit:contour():has_id("medic_heal") then
			is_marked = true
			return is_marked
		end
	end
	return is_marked
end

-- customize contour color, but this can not be synchronized
function add_contour_unit(unit, color)
	unit:base():swap_material_config()
	managers.occlusion:remove_occlusion(unit)

	local materials = unit:get_objects_by_type(Idstring("material"))
	for _, material in pairs(materials) do
		-- material:set_render_template(Idstring("generic:CONTOUR:DIFFUSE_TEXTURE"))
		material:set_variable(Idstring("contour_color"), color)
		material:set_variable(Idstring("contour_opacity"), 1)
	end
end

function remove_contour_unit(unit)
	unit:base():swap_material_config()
	managers.occlusion:add_occlusion(unit)
end


-- mark civilians and enemies
local function mark_all_units(important_npc_only)
	local mark_time_upgrade = nil
	if managers and managers.player and managers.player.upgrade_value then
		mark_time_upgrade = managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1) or 2
	end

	for u_key,u_data in pairs(managers.enemy:all_civilians() or {}) do
		if u_data.unit and alive(u_data.unit) and u_data.unit.contour and u_data.unit:contour() then
			if is_important_npc(u_data.unit) then
				-- highlight important npc in different contour
				u_data.unit:contour():add("hostage_trade", important_npc_sync_to_teammates)
			elseif not important_npc_only then
				u_data.unit:contour():add("medic_heal", sync_to_teammates, mark_time_upgrade)
			end
		end
	end

	for u_key,u_data in pairs(managers.enemy:all_enemies() or {}) do
		if u_data.unit and alive(u_data.unit) and u_data.unit.contour and u_data.unit:contour() then
			if is_important_npc(u_data.unit) then
				-- highlight important npc in different contour
				u_data.unit:contour():add("hostage_trade", important_npc_sync_to_teammates)
			elseif is_hostage(u_data.unit, true) and not important_npc_only then
				-- highlight hostage in different contour
				u_data.unit:contour():add("friendly", sync_to_teammates)
			elseif not important_npc_only then
				u_data.unit:contour():add("mark_enemy", sync_to_teammates, mark_time_upgrade)
			end
		end
	end

	if not important_npc_only then
		for u_key,unit in pairs(managers.groupai:state()._security_cameras or {}) do
			if unit and alive(unit) and unit.contour and unit:contour() and unit.base and unit:base() and unit:base().destroyed and not unit:base():destroyed() then
				unit:contour():add("mark_unit", sync_to_teammates, mark_time_upgrade)
			end
		end
	end

	orig_EnemyManager_on_civilian_died = orig_EnemyManager_on_civilian_died or EnemyManager.on_civilian_died
	function EnemyManager:on_civilian_died(dead_unit, damage_info)
		if dead_unit and alive(dead_unit) and dead_unit.contour and dead_unit:contour() then
			if dead_unit:contour():has_id("hostage_trade") then dead_unit:contour():remove("hostage_trade", important_npc_sync_to_teammates) end
			if dead_unit:contour():has_id("medic_heal") then dead_unit:contour():remove("medic_heal", sync_to_teammates) end
			if dead_unit:contour():has_id("mark_enemy") then dead_unit:contour():remove("mark_enemy", sync_to_teammates) end
		end
		return orig_EnemyManager_on_civilian_died(self, dead_unit, damage_info)
	end

	orig_EnemyManager_on_enemy_died = orig_EnemyManager_on_enemy_died or EnemyManager.on_enemy_died
	function EnemyManager:on_enemy_died(dead_unit, damage_info)
		if dead_unit and alive(dead_unit) and dead_unit.contour and dead_unit:contour() then
			if dead_unit:contour():has_id("hostage_trade") then dead_unit:contour():remove("hostage_trade", important_npc_sync_to_teammates) end
			if dead_unit:contour():has_id("friendly") then dead_unit:contour():remove("friendly", sync_to_teammates) end
			if dead_unit:contour():has_id("mark_enemy") then dead_unit:contour():remove("mark_enemy", sync_to_teammates) end
		end
		return orig_EnemyManager_on_enemy_died(self, dead_unit, damage_info)
	end
end

local function mark_all_units_remove()
	for u_key, u_data in pairs(managers.enemy:all_civilians()) do
		if u_data.unit and alive(u_data.unit) and u_data.unit.contour and u_data.unit:contour() then
			if u_data.unit:contour():has_id("hostage_trade") then u_data.unit:contour():remove("hostage_trade", important_npc_sync_to_teammates) end
			if u_data.unit:contour():has_id("medic_heal") then u_data.unit:contour():remove("medic_heal", sync_to_teammates) end
			if u_data.unit:contour():has_id("mark_enemy") then u_data.unit:contour():remove("mark_enemy", sync_to_teammates) end
		end
	end
	for u_key, u_data in pairs(managers.enemy:all_enemies()) do
		if u_data.unit and alive(u_data.unit) and u_data.unit.contour and u_data.unit:contour() then
			if u_data.unit:contour():has_id("hostage_trade") then u_data.unit:contour():remove("hostage_trade", important_npc_sync_to_teammates) end
			if not u_data.unit.in_slot or (not u_data.unit:in_slot(16) and not u_data.unit:in_slot(22)) then -- don't remove joker/bots' contour
				if u_data.unit:contour():has_id("friendly") then u_data.unit:contour():remove("friendly", sync_to_teammates) end
			end
			if u_data.unit:contour():has_id("mark_enemy") then u_data.unit:contour():remove("mark_enemy", sync_to_teammates) end
		end
	end
	for u_key, unit in pairs(managers.groupai:state()._security_cameras) do
		if unit and alive(unit) and unit.contour and unit:contour() then
			if unit:contour():has_id("mark_unit") then unit:contour():remove("mark_unit", sync_to_teammates) end
		end
	end

	if orig_EnemyManager_on_civilian_died then EnemyManager.on_civilian_died = orig_EnemyManager_on_civilian_died end
	if orig_EnemyManager_on_enemy_died then EnemyManager.on_enemy_died = orig_EnemyManager_on_enemy_died end
end




-- mark special units in line of sight
local function mark_special_units_in_fov()
	-- Get the player and camera objects
	local player = managers.player:local_player()
	if not player then return end
	local camera = player:camera()
	if not camera then return end

	-- Define FOV and distance
	local fov_angle = 60 -- Field of view angle (in degrees)
	local max_distance = 5000 -- Maximum distance to search

	-- Camera position and direction
	local camera_pos = camera:camera_object():position()
	local camera_dir = camera:forward()

	-- Use a collision mask for enemies
	local mask = managers.slot:get_mask("enemies")

	-- Find units in the camera cone
	local units_in_fov = World:find_units("camera_cone", camera:camera_object(), camera_dir, fov_angle, max_distance, mask)

	local mark_time_upgrade = nil
	if managers and managers.player and managers.player.upgrade_value then
		mark_time_upgrade = managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1) or 2
	end

	for _, unit in ipairs(units_in_fov) do
		if unit and alive(unit) and unit:base() and unit:base()._tweak_table then
			local unit_type = unit:base()._tweak_table

			-- Check if the unit is a special type
			if (check_wall(unit) and (unit.brain and unit:brain().is_current_logic and not unit:brain():is_current_logic("intimidated")) and (unit_type == "taser" or unit_type == "cloaker" or unit_type == "sniper" or  unit_type == "spooc" or unit_type == "medic" or unit_type == "tank" or unit_type == "tank_mini" or unit_type == "tank_medic" or unit_type == "tank_hw" or unit_type == "marshal_marksman")) or unit_type == "phalanx_minion" or unit_type == "phalanx_vip" or unit_type == "shield" or unit_type == "marshal_shield"  then
				-- Add a contour (highlight) to the unit
				if not unit:contour():has_id("mark_enemy") then
					unit:contour():add("mark_enemy", sync_to_teammates, mark_time_upgrade)
					-- managers.mission._fading_debug_output:script().log("Marked special unit: " .. tostring(unit_type))
				end
			end
		end
	end
end




local important_item_idstrings = {
--[[ example:
	["heist_id"] = {
		{ idstring = Idstring("xxx"), icon = "pd2_drill", color = Color.gary, show_distance = true, loud_only = true, force = true, ignore_count = true, distance_limit = Vector3(0, 0, 100), invalid_location_list = { Vector3(0,0,0), Vector3(50,50,50) }, check_collision = { position_offset = Vector3(0, 0, 50), find_direction = Vector3(0, 0, 1), find_distance = 20, }, with_units_around = { { idstring = Idstring("id1"), find_distance = 50, force = true, }, { idstring = Idstring("id2"), find_distance = 20, force = false, }, { interaction = "interaction_name1", find_distance = 20, force = true, }, }, with_units_exist = { { idstring = Idstring("id1"), force = true, }, { interaction = "interaction_name2", force = true, }, }, check_function = function(unit) retrun true end, },
		{ interaction = "xxx", icon = "pd2_computer", color = Color.red, show_distance = true, stealth_only = true, force = true, ignore_count = true, distance_limit = Vector3(200, 200, 0), invalid_location_list = { Vector3(0,0,0), }, check_collision = { position_offset = Vector3(100, 100, 0), find_direction = Vector3(0, 0, -1), find_distance = 50, }, with_units_around = { { idstring = Idstring("id1"), find_distance = 20, force = false, }, { interaction = "interaction_name1", find_distance = 50, force = true, }, { interaction = "interaction_name2", find_distance = 20, force = true, }, }, with_units_exist = { { interaction = "interaction_name1", force = true, }, { idstring = Idstring("id2"), force = true, }, }, check_function = function(unit) retrun false end, },
		{ interaction = "xxx", idstring = idstring = "Idstring(@IDxxx@)", icon = "equipment_bank_manager_key", color = Color.yellow, show_distance = true, force = true, ignore_count = true, distance_limit = Vector3(200, 200, 0), invalid_location_list = { Vector3(0,0,0), }, check_collision = { position_offset = Vector3(0, 0, 0), find_direction = Vector3(1, 0, 0), find_distance = 1, }, with_units_around = { { idstring = Idstring("id1"), find_distance = 20, force = false, }, }, with_units_exist = { { interaction = "interaction_name1", force = true, }, }, check_function = function(unit) retrun true end, },
	},
]]--

	["sand"] = { -- The Ukrainian Prisoner
		{ interaction = "gen_pku_blow_torch", icon = "equipment_blow_torch", show_distance = true, },
		{ interaction = "drk_pku_blow_torch", icon = "equipment_blow_torch", show_distance = true, },
		{ interaction = "use_server_device", icon = "pd2_computer", show_distance = true, },
		{ interaction = "pex_armory_hack", icon = "pd2_computer", show_distance = true, },
		{ interaction = "cas_button_01", icon = "pd2_door", show_distance = true, },
		{ interaction = "sand_take_note", icon = "equipment_notepad", show_distance = true},
		{ interaction = "hack_suburbia_outline", icon = "pd2_computer", show_distance = true, force = true, invalid_location_list = { Vector3(-4100, -2000, 680), Vector3(-2450, 700, 205), Vector3(10145, -400, 280), Vector3(10845, -400, 279.52), Vector3(9520, -2150, 279.52), Vector3(9605, -2200, 279.52), }, with_units_exist = { { interaction = "cas_button_01", }, }, },
		{ interaction = "mcm_panicroom_keycard_2", icon = "pd2_door", show_distance = true, },
		{ interaction = "sand_take_laxative", icon = "equipment_cleaning_product", show_distance = true, },
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, force = true, invalid_location_list = { Vector3(0, 0, -2000) }, with_units_exist = { { interaction = "mcm_panicroom_keycard_2", }, }, },
		{ interaction = "sand_open_handcuffs", show_distance = true, force = true, distance_limit = Vector3(3000, 3000, 0), },
		{ interaction = "sand_take_usb", icon = "equipment_usb_no_data", show_distance = true, },
		{ interaction = "sand_search_for_documents", icon = "equipment_files", show_distance = true, },
		{ interaction = "hold_take_gas_can", icon = "wp_can", show_distance = true, distance_limit = Vector3(2000, 2000, 0), },
	},
	["chas"] = { -- Dragon Heist
		{ interaction = "chas_pickup_keychain_forklift", icon = "equipment_chavez_key", show_distance = true, force = true, with_units_around = { { interaction = "invisible_interaction_open", find_distance = 50, }, }, },
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "pickup_keycard_axis", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "press_to_interact", icon = "equipment_notepad", show_distance = true, force = true, with_units_exist = { { interaction = "cas_button_01", }, }, },
		{ interaction = "pickup_asset", icon = "equipment_chavez_key", show_distance = true, invalid_location_list = { Vector3(-1400, 4900, -700), Vector3(-1456, 5003, -627), }, },
		{ interaction = "gen_pku_blow_torch", icon = "equipment_blow_torch", show_distance = true, },
		{ interaction = "gen_pku_crowbar", icon = "equipment_crowbar", show_distance = true, },
		{ interaction = "invisible_interaction_open_axis_rvd", icon = "pd2_wirecutter", show_distance = true, invalid_location_list = { Vector3(-6950, 4025, -275), }, with_units_exist = { { idstring = Idstring("units/pd2_dlc_arena/props/are_prop_laser/are_prop_laser_8m"), }, }, },
		{ interaction = "hold_cut_wires", icon = "pd2_wirecutter", show_distance = true, with_units_exist = { { idstring = Idstring("units/pd2_dlc_arena/props/are_prop_laser/are_prop_laser_8m"), }, }, },
		{ interaction = "press_c4_pku", icon = "equipment_c4", show_distance = true, },
		{ interaction = "chas_pku_dragon_statue", icon = "wp_bag", show_distance = true, force = true, check_collision = {}, },
	},
	["dark"] = { -- Murky Station
		{ idstring = Idstring("units/pd2_dlc_holly/river/props/lxa_prop_hobo_plasticcrate/lxa_prop_hobo_plasticcrate"), icon = "equipment_thermite", show_distance = true, with_units_around = { { interaction="gen_pku_thermite_paste_z_axis", find_distance = 200, force = true, }, }, },
		{ idstring = Idstring("units/pd2_dlc_dark/props/drk_prop_cardboard_box/drk_cardboard_box"), icon = "equipment_blow_torch", show_distance = true, with_units_around = { { interaction="drk_pku_blow_torch", find_distance = 200, force = true, }, }, },
		{ idstring = Idstring("units/pd2_dlc_dark/props/drk_mobile_sever_rack/drk_prop_mobile_server_rack_d"), icon = "equipment_harddrive", show_distance = true, with_units_around = { { interaction="pickup_harddrive", find_distance = 200, force = true, }, }, },
		{ idstring = Idstring("units/pd2_dlc_dark/props/drk_prop_keyholder/drk_prop_keyholder"), icon = "equipment_bank_manager_key", show_distance = true, with_units_around = { { interaction="pickup_keycard", find_distance = 200, force = true, }, }, },
		{ interaction = "hold_open", icon = "pd2_computer", show_distance = true, },
		{ interaction = "drk_hold_hack_computer", icon = "pd2_computer", show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_dark/props/drk_prop_bomb_rack/drk_prop_bomb_rack_lower"), icon = "wp_bag", show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_dark/props/drk_prop_bomb_rack/drk_prop_bomb_rack_upper"), icon = "wp_bag", show_distance = true, },
	},
	["mad"] = { -- Boiling Point
		{ idstring = Idstring("units/payday2/props/gen_prop_knockout_gas_canister/gen_prop_knockout_gas_canister"), icon = "equipment_gas_canister", show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_mad/props/mad_prop_dead_scientist/mad_prop_dead_scientist"), icon = "equipment_hand", show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_mad/props/mad_prop_keycard/mad_prop_keycard"), icon = "equipment_bank_manager_key", show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_mad/props/mad_interactable_weapon_case/mad_interactable_weapon_case_1x1_closed"), icon = "equipment_briefcase", show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_mad/props/mad_prop_compound_test_subject/mad_prop_compound_test_subject_01"), show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_mad/props/mad_prop_compound_test_subject/mad_prop_compound_test_subject_02"), show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_mad/props/mad_prop_compound_test_subject/mad_prop_compound_test_subject_03"), show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_mad/props/mad_prop_compound_test_subject/mad_prop_compound_test_subject_04"), show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_mad/props/mad_prop_compound_test_subject/mad_prop_compound_test_subject_05"), show_distance = true, },
		{ interaction = "open_from_inside", icon = "wp_door", show_distance = true, },
	},
	["framing_frame_1"] = { -- Framing Frame, day 1
		{ interaction = "hold_take_painting", show_distance = true, },
	},
	["framing_frame_3"] = { -- Framing Frame, day 3
		{ idstring = Idstring("units/world/architecture/secret_stash/props/secret_stash_equipment_server_rack_pickup"), icon = "equipment_harddrive", show_distance = true, },
		{ idstring = Idstring("units/payday2/equipment/gen_interactable_laptop/gen_interactable_laptop"), icon = "laptop_objective", show_distance = true, },
		{ idstring = Idstring("units/payday2/props/gen_interactable_prop_ipad/gen_interactable_prop_ipad"), icon = "equipment_hack_ipad", show_distance = true, },
		{ idstring = Idstring("units/payday2/props/gen_interactable_prop_iphone/gen_interactable_prop_iphone"), icon = "pd2_phone", show_distance = true, },
		{ interaction = "hold_take_old_wine", icon = "equipment_bottle", show_distance = true, },
		{ interaction = "shelf_sliding_suburbia", icon = "wp_door", show_distance = true, stealth_only = true, 
			check_function = function(unit)
				-- find the vault position at stealth
				if unit and alive(unit) and unit.position and managers.groupai:state():whisper_mode() then
					local bookshelf_locations = { Vector3(-4501, 2593, 3000), Vector3(-2607, 4033, 3400), Vector3(-4731, 4819, 3003.29), }
					local wall_locations = { Vector3(-4600, 2625, 3000), Vector3(-2575, 4125, 3400), Vector3(-4825, 4850, 3000), }
					for i=1, 3 do
						if tostring(unit:position()) == tostring(bookshelf_locations[i]) then
							for _, find_unit in pairs(World:find_units_quick("all",1)) do
								-- exclude the blocking wall
								if tostring(find_unit:position()) == tostring(wall_locations[i]) and tostring(find_unit:name()) == tostring(Idstring("units/payday2/architecture/lux/lux_int_wall1d_2m_a")) then
									return false
								end
								-- exclude the wine cabinet
								if tostring(find_unit:name()) == tostring(Idstring("units/pd2_dlc_chill/props/chl_prop_livingroom_coffeetable_a/chl_prop_livingroom_coffeetable_lid")) then
									local distance = mvector3.distance(unit:position(), find_unit:position())
									if distance < 1100 then
										return false
									end
								end
							end
							return true
						end
					end
					return false
				end
			end
		},
		{ interaction = "security_station_keyboard", icon = "pd2_computer", show_distance = true, loud_only = true, force = true, 
			check_function = function(unit)
				if Network:is_client() then return false end
				-- find the correct server room at loud, host only
				if unit and alive(unit) and unit.position and managers and managers.mission and managers.mission:script("default") and managers.mission:script("default")._elements and not managers.groupai:state():whisper_mode() then
					local server_locations = { ["105507"] = Vector3(-3937.26, 5644.73, 3474.5),["105508"] = Vector3(-3169.57, 4563.03, 3074.5), ["100650"] = Vector3(-4920, 3737, 3074.5) }
					local server_id = tostring(managers.mission:script("default")._elements[105506]._values.on_executed[1].id)
					if tostring(unit:position()) == tostring(server_locations[server_id]) then
						return true
					end
				end
				return false
			end
		},
	},
	["welcome_to_the_jungle_1"] = { -- Big Oil, day 1
		{ interaction = "drill", icon = "pd2_drill", show_distance = true, },
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "hold_take_blueprints", icon = "equipment_blueprint", show_distance = true, },
		{ interaction = "take_confidential_folder", icon = "equipment_files", show_distance = true, },
		{ interaction = "pickup_asset", icon = "equipment_chavez_key", show_distance = true, },
	},
	["welcome_to_the_jungle_1_night"] = { -- Big Oil day 1, night version
		{ interaction = "drill", icon = "pd2_drill", show_distance = true, },
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "hold_take_blueprints", icon = "equipment_blueprint", show_distance = true, },
		{ interaction = "take_confidential_folder", icon = "equipment_files", show_distance = true, },
		{ interaction = "pickup_asset", icon = "equipment_chavez_key", show_distance = true, },
	},
	["welcome_to_the_jungle_2"] = { -- Big Oil, day 2
		{ idstring = Idstring("units/payday2/props/off_prop_officehigh_chair/off_prop_officehigh_chair_standard"), icon = "pd2_computer", show_distance = true, with_units_around = { { interaction = "open_from_inside", find_distance = 500, }, }, },
		-- { idstring = Idstring("units/payday2/props/gen_prop_lab_clipboards/gen_prop_lab_clipboard"), show_distance = true, },
		-- { idstring = Idstring("units/payday2/props/gen_prop_lab_notebooks/gen_prop_lab_notebooks"), show_distance = true, },
		{ interaction = "gen_pku_fusion_reactor", show_distance = true, 
			check_function = function(unit)
				if Network:is_client() then return false end
				-- find the right engine, host only
				if unit and alive(unit) and unit.position and managers and managers.mission and managers.mission:script("default") and managers.mission:script("default")._elements then
					local engine_locations = { ["103703"] = Vector3(-1830, -2182, -313.492), ["103704"] = Vector3(-1200, -2050, -313.492), ["103705"] = Vector3(-1849, -1869, -313.492), ["103706"] = Vector3(-1200, -1735, -313.492), ["103707"] = Vector3(-1849, -1429, -313.492), ["103708"] = Vector3(-1200, -1415, -313.492), ["103709"] = Vector3(-175, -2025, -313.492), ["103711"] = Vector3(24.9999, -1350, -313.492), ["103714"] = Vector3(-175, -1675, -313.492), ["103715"] = Vector3(35, -1733, -314), ["103716"] = Vector3(-175, -1350, -313.492), ["103717"] = Vector3(25, -2050, -313.492), }
					local engine_id = tostring(managers.mission:script("default")._elements[103718]._values.on_executed[1].id)
					if tostring(unit:position()) == tostring(engine_locations[engine_id]) then
						return true
					end
				end
				return false
			end
		},
	},
	["election_day_1"] = { -- Election Day, day 1
		{ interaction = "uload_database", icon = "pd2_computer", show_distance = true, },
		{ interaction = "hold_place_gps_tracker", icon = "equipment_ecm_jammer", show_distance = true, 
			check_function = function(unit)
				if Network:is_client() then return false end
				-- find the right truck, host only
				if unit and alive(unit) and unit.position and managers and managers.mission and managers.mission:script("default") and managers.mission:script("default")._elements then
					local truck_locations = { ["100636"] = Vector3(150, -3900, 0), ["100633"] = Vector3(878.392, -3360.24, 0), ["100637"] = Vector3(149.999, -2775, 0), ["100634"] = Vector3(828.07, -2222.45, 0), ["100639"] = Vector3(149.998, -1625, 0), ["100635"] = Vector3(848.961, -1084.9, 0) }
					local truck_id = tostring(managers.mission:script("default")._elements[100631]._values.on_executed[1].id)
					if tostring(unit:position()) == tostring(truck_locations[truck_id]) then
						return true
					end
				end
				return false
			end
		},
	},
	["election_day_2"] = { -- Election Day, day 2
		{ interaction = "gen_pku_crowbar", icon = "equipment_crowbar", show_distance = true, },
		{ interaction = "crate_loot", show_distance = true, },
		{ interaction = "votingmachine2", icon = "pd2_computer", show_distance = true, },
	},
	["spa"] = { -- Brooklyn 10-10
		{ interaction = "gen_pku_crowbar", icon = "equipment_crowbar", show_distance = true, },
		{ interaction = "hold_pku_briefcase", icon = "equipment_briefcase", show_distance = true, },
	},
	["crojob3"] = { -- The Bomb: Forest
		{ interaction = "pick_lock_easy_no_skill", icon = "icon_locked", show_distance = true, },
		{ interaction = "hold_remove_ladder", icon = "pd2_ladder", show_distance = true, },
		{ interaction = "gen_pku_crowbar", icon = "equipment_crowbar", show_distance = true, },
		-- { interaction = "crate_loot_crowbar", show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_cro/eus_vehicle_train_cargo_carriage_vault/eus_vehicle_train_cargo_carriage_vault"), icon = "pd2_question", show_distance = true, with_units_around = { { interaction = "open_train_cargo_door", find_distance = 1000, }, }, }, -- show all train position with question mark
		{ idstring = Idstring("units/pd2_dlc_cro/eus_vehicle_train_cargo_carriage_vault/eus_vehicle_train_cargo_carriage_vault"), icon = "pd2_door", show_distance = true, with_units_around = { { interaction = "drill", find_distance = 1000, }, { interaction = "crate_loot_crowbar", find_distance = 1000, }, }, },
	},
	["crojob2"] = { -- The Bomb: Dockyard
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", color = Color.red, show_distance = true, ignore_count = true, },
		{ interaction = "gen_pku_crowbar", icon = "equipment_crowbar", show_distance = true, },
		{ interaction = "hydrogen_chloride", icon = "pd2_methlab", show_distance = true, },
		{ interaction = "caustic_soda", icon = "pd2_methlab", show_distance = true, },
		{ interaction = "muriatic_acid", icon = "pd2_methlab", show_distance = true, },
		{ interaction = "pku_manifest", icon = "equipment_manifest", show_distance = true, force = true, with_units_around = { { interaction = "drill", find_distance = 200, }, }, },
		{ interaction = "hold_open_bomb_case", icon = "pd2_question", show_distance = true, },
		{ idstring = Idstring("units/payday2/pickups/gen_pku_methlab_caustic_cooler/gen_pku_methlab_caustic_cooler"), icon = "equipment_vial", show_distance = true, force = true, },
	},
	["friend"] = { -- Scarface Mansion
		{ interaction = "hold_open_coke_bag", show_distance = true, },
		{ interaction = "hold_remove_bug", icon = "equipment_files", show_distance = true, },
		{ interaction = "hold_take_painting", show_distance = true, },
		{ interaction = "hold_take_gas_can", icon = "wp_can", show_distance = true, loud_only = true, },
	},
	["deep"] = { -- Crude Awakening
		{ interaction = "drill", icon = "wp_door", show_distance = true, with_units_around = { { interaction = "hold_override_pc", find_distance = 500, force = true, }, }, },
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "pick_lock_easy_no_skill", icon = "equipment_usb_no_data", show_distance = true, },
		{ interaction = "sand_take_usb", icon = "equipment_usb_no_data", show_distance = true, },
		{ interaction = "pickup_oilsample", icon = "equipment_vial", show_distance = false, distance_limit = Vector3(0, 0, 400), },
		{ interaction = "deep_press_test_oil_sample", show_distance = true, },
		{ interaction = "pick_lock_hard_no_skill", icon = "wp_door", show_distance = true, distance_limit = Vector3(0, 0, 600), with_units_around = { { interaction = "access_camera", find_distance = 1000, force = true, }, }, },
		{ interaction = "chca_hold_disable_firewall", icon = "pd2_computer", show_distance = true, },
		{ interaction = "hospital_phone", icon = "pd2_phone", show_distance = true, },
		{ interaction = "sand_take_gas_canister", icon = "equipment_gas_canister", show_distance = true, distance_limit = Vector3(4000, 4000, 600), },
		{ interaction = "sand_place_gas_canister", icon = "equipment_gas_canister", show_distance = true, },
		{ interaction = "gen_pku_crowbar", icon = "equipment_crowbar", show_distance = true, distance_limit = Vector3(4000, 4000, 600), },
		{ interaction = "deep_jam_fan", icon = "equipment_electrical", show_distance = true, distance_limit = Vector3(4000, 4000, 600), },
		{ interaction = "circuit_breaker_off", icon = "wp_powersupply", show_distance = true, distance_limit = Vector3(4000, 4000, 600), with_units_around = { { interaction = "pick_lock_hard_no_skill", find_distance = 1000, }, }, },
		{ interaction = "cas_button_01", icon = "pd2_door", show_distance = true, },
	},
	["corp"] = { -- Hostile Takeover
		{ idstring = Idstring("units/pd2_dlc_corp/props/corp_prop_code_notepad/corp_prop_code_notepad"), icon = "equipment_notepad", show_distance = true, stealth_only = true, with_units_around = { { interaction = "drill", find_distance = 100, }, }, }, -- password note
		{ idstring = Idstring("units/pd2_dlc_corp/props/corp_prop_code_notepad/corp_prop_code_notepad"), icon = "equipment_notepad", show_distance = true, stealth_only = true, with_units_exist = { { interaction = "cas_button_01", }, }, }, -- password note
		{ interaction = "pickup_asset_zaxis", icon = "wp_key", show_distance = true, force = true, with_units_exist = { { interaction = "cas_button_01", }, }, },
		{ interaction = "corp_hold_unlock_controlbox", icon = "pd2_wirecutter", show_distance = true, with_units_exist = { { interaction = "cas_button_01", }, }, },
		{ interaction = "corp_hold_close_curtains", icon = "pd2_wirecutter", show_distance = true, with_units_exist = { { interaction = "cas_button_01", }, }, },
		{ interaction = "gen_pku_saw", icon = "pd2_generic_saw", show_distance = true, loud_only = true, },
		{ interaction = "gen_pku_thermite_paste_z_axis", icon = "equipment_thermite", show_distance = true, loud_only = true, },
		{ interaction = "c4_bag", icon = "equipment_c4", show_distance = true, loud_only = true, },
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "corp_key_fob", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "corp_hack_email", icon = "pd2_computer", show_distance = false, },
		{ interaction = "corp_hold_phone_play_voice_message", icon = "pd2_phone", show_distance = true, },
		{ interaction = "corp_hold_voice_recorder_play", icon = "pd2_phone", show_distance = true, force = true, with_units_around = { { interaction = "corp_hold_desk_drawer_open", find_distance = 100, }, }, },
		{ interaction = "corp_hold_voice_recorder_play", icon = "pd2_phone", show_distance = true, },
		{ interaction = "corp_hack_lead_email", icon = "pd2_computer", show_distance = true, distance_limit = Vector3(0, 0, 300), },
		{ interaction = "trai_connect_locke", icon = "pd2_computer", show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_corp/props/corp_dest_prop_lab_equipment/corp_prop_dest_lab_equipment"), icon = "wp_target", show_distance = false, distance_limit = Vector3(0, 0, 300), check_collision = {}, },
	},
	["ukrainian_job"] = { -- Ukrainian Job
		{ idstring = Idstring("units/payday2/props/com_prop_jewelry_jewels/com_prop_jewelry_tiara"), show_distance = true, force = true, },
	},
	["four_stores"] = { -- Four Stores
		{ idstring = Idstring("units/payday2/equipment/gen_interactable_sec_safe_1x1/gen_interactable_sec_safe_1x1"), icon = "equipment_saw", show_distance = true, },
		{ idstring = Idstring("units/payday2/equipment/gen_interactable_sec_safe_05x05/gen_interactable_sec_safe_05x05"), icon = "pd2_drill", show_distance = true, },
		{ interaction = "cash_register", show_distance = true, },
		{ interaction = "money_wrap_single_bundle", icon = "interaction_money_wrap", show_distance = true, },
	},
	["bex"] = { -- San Martín Bank
		{ interaction = "hold_open_door", icon = "wp_powersupply", show_distance = true, stealth_only = true, with_units_around = { { idstring = Idstring("units/world/props/suburbia_circuitbreaker/suburbia_circuitbreaker"), find_distance = 50, force = true, }, }, },
		{ interaction = "circuit_breaker_off", icon = "wp_powersupply", show_distance = true, },
		{ interaction = "take_tape", icon = "equipment_tape", show_distance = true, },
		{ interaction = "bex_take_cupprint", icon = "equipment_tape", show_distance = true, },
		{ interaction = "bex_take_cupprint_directional", icon = "equipment_tape", show_distance = true, },
		{ interaction = "bex_open_safe", icon = "wp_door", show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_bex/props/bex_prop_circuit_diagram/bex_prop_circuit_diagram"), icon = "equipment_blueprint", show_distance = true, stealth_only = true, }, -- instruction blueprint
		{ interaction = "invisible_interaction_open_axis_rvd", icon = "pd2_wirecutter", show_distance = true, invalid_location_list = { Vector3(149, -3475, 133.004), }, },
		{ interaction = "security_cable_grey", icon = "pd2_wirecutter", show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_bex/props/bex_interactable_hack_computer/bex_interactable_hack_computer"), icon = "pd2_computer", show_distance = true, loud_only = true, }, -- computer at loud
	},
	["fex"] = { -- Buluc's Mansion
		{ idstring = Idstring("units/pd2_dlc_fex/props/fex_prop_wine_cellar_note_code/fex_prop_wine_cellar_note_code"), icon = "equipment_notepad", show_distance = true, distance_limit = Vector3(0, 0, 150), with_units_exist = { { interaction = "cas_button_01", }, }, }, -- password note for boat entry door
		{ interaction = "cas_button_01", icon = "pd2_door", show_distance = true, distance_limit = Vector3(0, 0, 150), },
		{ idstring = Idstring("units/pd2_dlc_fex/props/fex_prop_guard_list/fex_prop_guard_list"), icon = "equipment_notepad", show_distance = true, with_units_exist = { { interaction = "mcm_panicroom_keycard_2", }, }, }, -- password note for who has keycard
		{ interaction = "fex_hold_accessing_mask_list", icon = "pd2_computer", show_distance = true, with_units_exist = { { interaction = "mcm_panicroom_keycard_2", }, }, },
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "mcm_panicroom_keycard_2", icon = "wp_door", show_distance = true, },
		{ interaction = "fex_take_scythe", icon = "equipment_scythe", show_distance = true, with_units_exist = { { interaction = "mcm_panicroom_keycard_2", }, }, },
		{ interaction = "fex_take_scythe_no_axis", icon = "equipment_scythe", show_distance = true, with_units_exist = { { interaction = "mcm_panicroom_keycard_2", }, }, },
		{ interaction = "fex_take_globe", icon = "equipment_globe", show_distance = true, with_units_exist = { { interaction = "mcm_panicroom_keycard_2", }, }, },
		{ interaction = "fex_take_globe_axis", icon = "equipment_globe", show_distance = true, with_units_exist = { { interaction = "mcm_panicroom_keycard_2", }, }, },
		{ interaction = "fex_place_scythe", icon = "equipment_scythe", show_distance = true, with_units_exist = { { interaction = "mcm_panicroom_keycard_2", }, }, },
		{ interaction = "fex_place_globe", icon = "equipment_globe", show_distance = true, with_units_exist = { { interaction = "mcm_panicroom_keycard_2", }, }, },
		{ interaction = "fex_take_alarm_clock", icon = "equipment_timer", show_distance = true, loud_only = true, },
		{ interaction = "fex_take_alarm_clock_axis", icon = "equipment_timer", show_distance = true, loud_only = true, },
		{ interaction = "fex_take_wire", icon = "equipment_electrical", show_distance = true, loud_only = true, },
		{ interaction = "fex_take_wire_axis", icon = "equipment_electrical", show_distance = true, loud_only = true, },
		{ interaction = "fex_take_fertilizer", icon = "equipment_fertilizer", show_distance = true, loud_only = true, },
		{ interaction = "fex_take_fertilizer_axis", icon = "equipment_fertilizer", show_distance = true, loud_only = true, },
		{ interaction = "fex_take_diesel", icon = "wp_can", show_distance = true, loud_only = true, },
		{ interaction = "fex_take_diesel_axis", icon = "wp_can", show_distance = true, loud_only = true, },
		{ interaction = "gen_pku_blow_torch", icon = "equipment_blow_torch", show_distance = true, loud_only = true, },
		{ interaction = "gen_pku_saw_axis", icon = "pd2_generic_saw", show_distance = true, loud_only = true, },
		{ interaction = "start_hacking_axis", icon = "pd2_computer", show_distance = true, loud_only = true, force = true, with_units_around = { { interaction = "pick_lock_hard_no_skill", find_distance = 650, }, }, },
		{ interaction = "fex_hold_search_for_clue", icon = "equipment_files", show_distance = true, 
			check_function = function(unit)
				local player_pos = managers and managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and managers.player:player_unit():movement():m_head_pos()
				if player_pos and (player_pos.y < 1200 or player_pos.z > 70) then
					return false
				end
				return true
			end
		},
	},
	["peta"] = { -- Goat Simulator
		{ idstring = Idstring("units/pd2_dlc_peta/characters/wld_goat_1/wld_goat_1"), icon = "wp_bag", show_distance = true, force = true, check_collision = { find_distance = 200, }, },
	},
	["shoutout_raid"] = { -- Meltdown
		{ interaction = "gen_pku_crowbar", icon = "equipment_crowbar", show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_shoutout_raid/props/gen_prop_container_a_vault_seq/gen_prop_container_a_vault_seq"), show_distance = true, force = true, with_units_around = { { interaction = "atm_interaction", find_distance = 400, }, }, },
	},
	["pines"] = { -- White Xmas
		{ interaction = "hold_open_xmas_present", icon = "interaction_christmas_present", show_distance = true, },
	},
	["jolly"] = { -- Aftershock
		{ idstring = Idstring("units/pd2_dlc_jolly/vehicles/lxa_vehicle_truck_vlad/lxa_vehicle_truck_vlad"), show_distance = true, with_units_around = { { interaction = "pku_safe", find_distance = 500, }, { interaction = "gen_int_saw", find_distance = 500, }, }, },
	},
	["chca"] = { -- Black Cat
		-- { interaction = "cas_take_gear", },
		{ interaction = "pickup_asset", icon = "equipment_chavez_key", show_distance = true, },
		{ interaction = "drill", icon = "pd2_drill", show_distance = true, force = true, with_units_around = { { interaction = "chca_hold_lower_big_painting", find_distance = 50, }, }, },
		{ idstring = Idstring("units/pd2_dlc_chca/props/chca_prop_vault_code/chca_prop_vault_code"), icon = "equipment_notepad", show_distance = true, with_units_exist = { { interaction = "cas_button_01", }, }, }, -- password note
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, ignore_count = true, },
		{ interaction = "chca_place_bug", show_distance = true, },
		{ interaction = "chca_hold_passenger_manifest", icon = "equipment_manifest", show_distance = true, stealth_only = true, with_units_exist = { { interaction = "chca_hold_take_business_card", }, }, },
		{ interaction = "chca_hold_take_business_card", icon = "equipment_businesscard", show_distance = true, stealth_only = true, },
		{ interaction = "hold_take_hand", icon = "equipment_hand", show_distance = true, },
		{ interaction = "mcm_panicroom_keycard_2", icon = "pd2_door", show_distance = true, stealth_only = true, with_units_around = { { interaction = "hack_suburbia_outline", find_distance = 1000, force = true, }, }, },
		{ interaction = "hold_cut_wires", icon = "pd2_wirecutter", show_distance = true, },
		{ interaction = "chca_hold_lower_lifeboat", show_distance = true, },
		{ interaction = "fex_take_diesel", icon = "wp_can", show_distance = true, loud_only = true, },
		{ interaction = "gen_pku_thermite_paste_z_axis", icon = "equipment_thermite", show_distance = true, loud_only = true, },
		{ interaction = "c4_bag", icon = "equipment_c4", show_distance = true, loud_only = true, },
		{ interaction = "chca_remove_hatch", show_distance = true, loud_only = true, },
	},
	["ranc"] = { -- Midland Ranch
		{ idstring = Idstring("units/pd2_dlc_fex/props/fex_prop_wine_cellar_note_code/fex_prop_wine_cellar_note_code"), icon = "equipment_notepad", show_distance = true, with_units_exist = { { interaction = "ranc_press_wake_computer", force = false, }, }, }, -- password note
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "pickup_keycard_axis", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "ranc_press_wake_computer", icon = "pd2_computer", show_distance = true, },
		{ interaction = "take_tape", icon = "equipment_tape", show_distance = true, },
		{ interaction = "bex_take_cupprint", icon = "equipment_tape", show_distance = true, },
		{ interaction = "ranc_audio_case", icon = "equipment_evidence", show_distance = true, force = true, with_units_around = { { interaction = "open_slash_close_act", find_distance = 400, }, }, },
		-- { interaction = "invisible_interaction_open_axis_rvd", icon = "wp_powersupply", show_distance = true, invalid_location_list = { Vector3(5275, -125, 525), }, },
		-- { interaction = "hold_cut_wires", icon = "wp_powersupply", show_distance = true, },
		{ interaction = "gen_pku_crowbar", icon = "equipment_crowbar", show_distance = true, },
		{ interaction = "ranc_take_acid", icon = "pd2_methlab", show_distance = true, },
		{ interaction = "ranc_hold_take_stock", icon = "ak", show_distance = true, },
		{ interaction = "ranc_hold_take_receiver", icon = "ak", show_distance = true, },
		{ interaction = "ranc_hold_take_barrel", icon = "ak", show_distance = true, },
	},
	["trai"] = { -- Lost In Transit
		{ idstring = Idstring("units/pd2_dlc_trai/props/trai_prop_electrical_box/trai_prop_electrical_box"), icon = "pd2_melee", show_distance = true, with_units_exist = { { interaction = "cut_fence", }, }, 
			check_function = function(unit)
				-- don't show electric box after getting in
				local player_pos = managers and managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and managers.player:player_unit():movement():m_head_pos()
				if player_pos and player_pos.y < 1270 then
					return true
				end
				return false
			end
		},
		{ idstring = Idstring("units/pd2_dlc_fex/props/fex_prop_wine_cellar_note_code/fex_prop_wine_cellar_note_code"), icon = "equipment_notepad", show_distance = true, stealth_only = true, with_units_around = { { idstring = Idstring("units/dev_tools/level_tools/dev_equipment_forbidden_collision/dev_equipment_forbidden_collision_1x1m"), find_distance = 100, }, }, with_units_exist = { { interaction = "open_from_inside", force = false, }, }, }, -- password note
		{ interaction = "trai_connect_locke_walkietalkie", icon = "pd2_phone", show_distance = true, },
		{ interaction = "gen_pku_thermite", icon = "equipment_thermite", show_distance = true, },
		{ interaction = "trai_hold_access_console", icon = "pd2_wirecutter", show_distance = true, },
		{ interaction = "chas_pick_lock_easy_no_skill", icon = "pd2_wirecutter", show_distance = true, },
	},
	["bph"] = { -- Hell's Island
		{ interaction = "gen_pku_thermite_paste_not_deployable", icon = "equipment_thermite", show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_sah/pickups/sah_pku_keychain/sah_pku_keychain"), icon = "wp_key", show_distance = true, distance_limit = Vector3(700, 700, 400), },
	},
	["pbr2"] = { -- Birth of Sky
		{ idstring = Idstring("units/pd2_dlc_jerry/equipment/jry_int_money_crate/jry_int_money_crate"), show_distance = true, force = true, check_collision = { position_offset = Vector3(0, 0, 0), find_distance = 111.343, }, },
		{ idstring = Idstring("units/pd2_dlc_jerry/pickups/jry_pku_money_pile/jry_pku_money_pile"), icon = "wp_bag", show_distance = true, force = true, check_collision = { position_offset = Vector3(0, 0, 0), find_distance = 29.5739, }, },
	},
	["pbr"] = { -- Beneath the Mountain
		{ idstring = Idstring("units/pd2_dlc_berry/props/bry_prop_crate_wood_murkywater/bry_prop_crate_wood_murkywater"), show_distance = true, distance_limit = Vector3(0, 0, 800), 
			check_function = function(unit)
				-- don't show crate underground
				if unit and alive(unit) and unit.position and unit:position() then
					if unit:position().z > -350 then
						return true
					end
				end
				return false
			end
		},
		{ interaction = "hold_approve_req", icon = "pd2_computer", show_distance = true, force = true, with_units_around = { { interaction = "hold_blow_torch", find_distance = 1000, }, }, },
		{ idstring = Idstring("units/pd2_indiana/props/mus_prop_bars/mus_prop_bars"), icon = "pd2_wirecutter", show_distance = true, distance_limit = Vector3(0, 0, 400), with_units_around = { { interaction = "hold_take_painting", find_distance = 200, force = true, }, }, },
		{ idstring = Idstring("units/pd2_dlc_berry/pickups/bry_pku_lost_artifact/bry_pku_lost_artifact"), icon = "wp_scrubs", show_distance = true, distance_limit = Vector3(0, 0, 400), },
		{ idstring = Idstring("units/pd2_dlc_berry/pickups/bry_pku_master_server/bry_pku_master_server"), icon = "equipment_harddrive", show_distance = true, distance_limit = Vector3(0, 0, 400), },
		{ interaction = "bry_pku_prototype", icon = "wp_bag", show_distance = true, distance_limit = Vector3(0, 0, 400), force = true, check_collision = {}, },
	},
	["brb"] = { -- Brooklyn Bank
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "c4_bag", icon = "equipment_c4", show_distance = true, },
		{ interaction = "gen_pku_thermite", icon = "equipment_thermite", show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_arena/equipment/are_interactable_objective_laptop/are_interactable_objective_laptop"), icon = "pd2_computer", show_distance = true, },
	},
	["sah"] = { -- Shacklethorne Auction
		{ interaction = "invisible_interaction_open_axis", icon = "pd2_wirecutter", show_distance = true, 
			check_function = function(unit)
				-- don't show electric box after getting in
				local player_pos = managers and managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and managers.player:player_unit():movement():m_head_pos()
				if player_pos and player_pos.y < -500 then
					return true
				end
				return false
			end
		},
		{ interaction = "hack_electric_box", icon = "pd2_wirecutter", show_distance = true, 
			check_function = function(unit)
				-- don't show electric box after getting in
				local player_pos = managers and managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and managers.player:player_unit():movement():m_head_pos()
				if player_pos and player_pos.y < -500 then
					return true
				end
				return false
			end
		},
		{ idstring = Idstring("units/pd2_dlc_sah/props/sah_ladder/sah_prop_ladder"), icon = "pd2_ladder", show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_sah/props/sah_interactable_hackbox/sah_interactable_hackbox"), icon = "pd2_computer", show_distance = true, force = true, with_units_around = { { interaction = "invisible_interaction_open_axis_sah", find_distance = 50, force = true, }, }, },
		{ idstring = Idstring("units/pd2_dlc_dark/pickups/drk_pku_blowtorch/drk_pku_blowtorch"), icon = "equipment_blow_torch", show_distance = true, force = true, },
		{ idstring = Idstring("units/pd2_dlc_sah/props/sah_prop_circuitbreaker/sah_prop_circuitbreaker"), icon = "wp_powersupply", show_distance = true, stealth_only = true, force = true, with_units_around = { { interaction = "pick_lock_hard_no_skill", find_distance = 400, }, }, },
		{ interaction = "open_door", icon = "wp_powersupply", show_distance = true, },
		{ idstring = Idstring("units/payday2/props/gen_prop_security_monitors/gen_prop_security_monitors_four_wall"), icon = "wp_door", show_distance = true, stealth_only = true, with_units_around = { { interaction = "pick_lock_hard_no_skill", find_distance = 700, }, }, },
	},
	["des"] = { -- Henry's Rock
		{ interaction = "gen_pku_crowbar", icon = "equipment_crowbar", show_distance = true, },
		{ interaction = "hold_search_documents", icon = "equipment_files", show_distance = true, distance_limit = Vector3(2000, 2000, 0), },
		{ interaction = "hold_take_battery", icon = "wp_powersupply", show_distance = true, distance_limit = Vector3(2000, 2000, 0), },
	},
	["vit"] = { -- The White House
		{ interaction = "invisible_interaction_open_axis_rvd", icon = "wp_powersupply", show_distance = true, invalid_location_list = { Vector3(-2625, 3550, 100.004), }, },
		{ interaction = "hospital_security_cable_red", icon = "wp_powersupply", show_distance = true, },
		{ interaction = "hospital_security_cable_green", icon = "wp_powersupply", show_distance = true, },
		{ interaction = "hospital_security_cable_blue", icon = "wp_powersupply", show_distance = true, },
		{ interaction = "hospital_security_cable_yellow", icon = "wp_powersupply", show_distance = true, },
		{ interaction = "gen_pku_thermite_timer_3sec", icon = "equipment_thermite", show_distance = true, },
		{ interaction = "hack_suburbia_outline", icon = "pd2_computer", show_distance = true, },
		{ interaction = "vit_search_clues", icon = "pd2_computer", show_distance = true, },
		{ interaction = "vit_insert_usb", icon = "pd2_computer", show_distance = true, },
		{ interaction = "hold_open_the_safe", icon = "equipment_bank_manager_key", show_distance = true, force = true, distance_limit = Vector3(1500, 1500, 500), with_units_around = { { interaction = "pickup_keycard", find_distance = 100, force = true, }, }, },
		{ idstring = Idstring("units/pd2_dlc_arena/props/are_prop_security_button/are_prop_security_button"), icon = "wp_powerbutton", show_distance = true, force = true, with_units_around = { { interaction = "vit_search", find_distance = 50, }, }, },
	},
	["tag"] = { -- Breakin' Feds
		{ idstring = Idstring("units/pd2_dlc_tag/equipment/tag_interactable_laptop/tag_interactable_laptop"), icon = "pd2_computer", show_distance = true, },
		{ interaction = "invisible_interaction_open_axis_rvd", icon = "pd2_wirecutter", show_distance = true, force = true, check_collision = { position_offset = Vector3(0, 0, 0), find_direction = Vector3(1, 1, -0), find_distance = 49.76, }, 
			check_function = function(unit)
				-- one side is loot, and the other side is office, only show electric box at office's side
				local loot_position = Vector3(0, 0, 0)
				for _, unit in pairs(managers.interaction._interactive_units or {}) do
					if unit and alive(unit) and unit.position and unit:position() and unit.interaction and unit:interaction() and (unit:interaction().tweak_data == "drill" or unit:interaction().tweak_data == "gen_pku_cocaine" or unit:interaction().tweak_data == "money_wrap_updating") then
						mvector3.set(loot_position, unit:position())
						break
					end
				end
				if unit.position and unit:position() and tostring(loot_position) ~= 'Vector3(0, 0, 0)' then
					if (loot_position.y > -125 and unit:position().y < -125) or (loot_position.y < -125 and unit:position().y > -125) then
						return true
					end
				end
				return false
			end
		},
		{ idstring = Idstring("units/pd2_dlc_tag/equipment/tag_interactable_sec_safe/tag_interactable_sec_safe"), show_distance = true, check_collision = {}, with_units_exist = { { interaction = "hold_remove_cover", }, }, }, -- can't find safe behind whiteboard
	},
	["pex"] = { -- Breakfast in Tijuana
		{ interaction = "hack_suburbia", icon = "pd2_computer", show_distance = true, },
		{ interaction = "pex_get_unloaded_card", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "drill", icon = "pd2_door", show_distance = true, with_units_around = { { idstring = Idstring("units/pd2_dlc_pex/props/pex_interactable_door_drill/pex_interactable_door_drill"), find_distance = 100, }, }, }, -- evidence room door
		{ idstring = Idstring("units/pd2_dlc_pex/props/pex_prop_lighter_fluid_bottle/pex_prop_lighter_fluid_bottle"), icon = "equipment_flammable", show_distance = true, },
		{ interaction = "destroy_evidence_pex", icon = "equipment_evidence", show_distance = true, },
		{ interaction = "pex_destroy_evidence_directional", icon = "equipment_evidence", show_distance = true, },
		{ interaction = "pex_destroy_evidence_directional_shredder", icon = "equipment_evidence", show_distance = true, },
		{ interaction = "pex_door_hydraulic_opener", icon = "pd2_drill", show_distance = true, force = true, distance_limit = Vector3(0, 0, 300), invalid_location_list = { Vector3(-2327, 3262, 100), }, },
		{ interaction = "pex_pickup_cutter", icon = "equipment_boltcutter", show_distance = true, },
		{ interaction = "pickup_police_uniform", icon = "wp_scrubs", show_distance = true, },
		{ interaction = "mex_red_room_key", icon = "wp_key", show_distance = true, },
	},
	["mex"] = { -- Border Crossing
		{ idstring = Idstring("units/pd2_dlc_mex/props/mex_prop_keypad_manual/mex_prop_keypad_manual"), icon = "equipment_notepad", color = Color.white, show_distance = true, distance_limit = Vector3(0, 0, 1000), with_units_exist = { { interaction = "cas_button_01", }, }, }, -- password 1, reset code, 0000 or 1111 or 1234
		{ idstring = Idstring("units/pd2_dlc_mex/props/mex_prop_clubhouse_banner/mex_prop_clubhouse_banner_01"), icon = "equipment_notepad", color = Color.red, show_distance = true, distance_limit = Vector3(0, 0, 1000), with_units_exist = { { interaction = "cas_button_01", }, }, }, -- password 2, club founded, 2008
		{ idstring = Idstring("units/pd2_dlc_mex/props/mex_prop_clubhouse_banner/mex_prop_clubhouse_banner_02"), icon = "equipment_notepad", color = Color.red, show_distance = true, distance_limit = Vector3(0, 0, 1000), with_units_exist = { { interaction = "cas_button_01", }, }, }, -- password 2, club founded, 2009
		{ idstring = Idstring("units/pd2_dlc_mex/props/mex_prop_arrest_warrant/mex_prop_arrest_warrant_01"), icon = "equipment_notepad", color = Color.yellow, show_distance = true, distance_limit = Vector3(0, 0, 1000), with_units_exist = { { interaction = "cas_button_01", }, }, }, -- password 3, arrest time, 2002
		{ idstring = Idstring("units/pd2_dlc_mex/props/mex_prop_arrest_warrant/mex_prop_arrest_warrant_02"), icon = "equipment_notepad", color = Color.yellow, show_distance = true, distance_limit = Vector3(0, 0, 1000), with_units_exist = { { interaction = "cas_button_01", }, }, }, -- password 3, arrest time, 2017
		{ idstring = Idstring("units/pd2_dlc_mex/props/mex_prop_graffiti_tags/mex_prop_graffiti_tags_03"), icon = "equipment_notepad", color = Color.blue, show_distance = true, distance_limit = Vector3(0, 0, 1000), with_units_exist = { { interaction = "cas_button_01", }, }, }, -- password 4, shitter, 4828
		{ idstring = Idstring("units/pd2_dlc_mex/props/mex_prop_graffiti_tags/mex_prop_graffiti_tags_02"), icon = "equipment_notepad", color = Color.blue, show_distance = true, distance_limit = Vector3(0, 0, 1000), with_units_exist = { { interaction = "cas_button_01", }, }, }, -- password 4, shitter, 5137
		{ idstring = Idstring("units/pd2_dlc_mex/props/mex_prop_graffiti_tags/mex_prop_graffiti_tags_01"), icon = "equipment_notepad", color = Color.blue, show_distance = true, distance_limit = Vector3(0, 0, 1000), with_units_exist = { { interaction = "cas_button_01", }, }, }, -- password 4, shitter, 0455
		{ interaction = "hold_pku_breaching_charges", icon = "equipment_c4", show_distance = true, },
		{ interaction = "mex_red_room_key", icon = "equipment_chavez_key", show_distance = true, },
		{ interaction = "gen_pku_crowbar", icon = "equipment_crowbar", show_distance = true, distance_limit = Vector3(0, 0, 1000), },
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, distance_limit = Vector3(0, 0, 1000), },
		{ interaction = "hold_take_vault_blueprint", icon = "equipment_blueprint", show_distance = true, stealth_only = true, force = true, with_units_around = { { interaction = "drill", find_distance = 100, }, }, },
		{ interaction = "hold_take_vault_blueprint", icon = "equipment_blueprint", show_distance = true, },
		{ interaction = "hold_take_gas_can", icon = "wp_can", show_distance = true, },
	},
	["mex_cooking"] = { -- Border Crystals
		{ interaction = "gen_pku_crowbar", icon = "equipment_crowbar", show_distance = true, },
		{ interaction = "hydrogen_chloride", icon = "pd2_methlab", show_distance = true, },
		{ interaction = "caustic_soda", icon = "pd2_methlab", show_distance = true, },
		{ interaction = "muriatic_acid", icon = "pd2_methlab", show_distance = true, },
	},
	["hvh"] = { -- Cursed Kill Room
		{ idstring = Idstring("units/pd2_dlc_chill/props/chl_props_trophies/chl_props_trophy_pumpkin/chl_prop_pumpkin_small"), show_distance = true, },
	},
	["big"] = { -- The Big Bank
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, invalid_location_list = { Vector3(3000, -3500, 949.99), }, },
		{ interaction = "invisible_interaction_open", icon = "equipment_chavez_key", show_distance = true, },
		{ interaction = "take_keys", icon = "equipment_chavez_key", show_distance = true, },
		{ interaction = "drill", icon = "wp_door", show_distance = true, with_units_around = { { interaction = "big_computer_server", find_distance = 300, }, }, },
		{ interaction = "big_computer_hackable", icon = "pd2_computer", show_distance = true, 
			check_function = function(unit)
				if Network:is_client() then return false end
				-- find the right computer, host only
				if unit and alive(unit) and unit.position and managers and managers.mission and managers.mission:script("default") and managers.mission:script("default")._elements then
					local computer_locations = { ["103250"] = Vector3(2754, 1420, -923), ["103229"] = Vector3(2083, 1412, -922.772), ["103569"] = Vector3(1941, 1345, -922.772), ["103604"] = Vector3(1589, 1419, -922.772), ["103647"] = Vector3(2558, 1847, -922.772), ["103709"] = Vector3(2448.08, 1849.07, -922.772), ["103749"] = Vector3(1859.2, 1832.25, -922.772), ["103788"] = Vector3(1732, 1812, -923), ["103898"] = Vector3(1090, 1220, -522.772), ["103916"] = Vector3(1293.46, 1221.04, -522.772), ["103927"] = Vector3(1909, 1389, -522.762), ["103948"] = Vector3(1917.69, 1583.79, -522.762), ["103966"] = Vector3(2318, 1608, -522.762), ["103984"] = Vector3(2319.79, 1407.8, -522.762), ["104006"] = Vector3(2716, 1220, -522.772), ["104024"] = Vector3(2895.76, 1782.56, -522.772), ["104042"] = Vector3(2922, 1218.89, -522.772), ["104080"] = nil, ["104127"] = nil, ["104315"] = nil }
					local computer_id = tostring(managers.mission:script("default")._elements[103246]._values.on_executed[1].id)
					if tostring(unit:position()) == tostring(computer_locations[computer_id]) then
						return true
					end
				end
				return false
			end
		},
	},
	["mia_1"] = { -- Hotline Miami, day 1
		{ interaction = "hold_take_gas_can", icon = "wp_can", show_distance = true, },
		{ interaction = "gen_pku_crowbar", icon = "equipment_crowbar", show_distance = true, },
		{ interaction = "crate_loot_crowbar", show_distance = true, distance_limit = Vector3(0, 0, 600), },
		{ interaction = "pku_barcode_opa_locka", show_distance = true, distance_limit = Vector3(0, 0, 500), },
		{ interaction = "pku_barcode_brickell", show_distance = true, distance_limit = Vector3(0, 0, 500), },
		{ interaction = "pku_barcode_edgewater", show_distance = true, distance_limit = Vector3(0, 0, 500), },
		{ interaction = "pku_barcode_downtown", show_distance = true, distance_limit = Vector3(0, 0, 500), },
		{ interaction = "pku_barcode_isles_beach", show_distance = true, distance_limit = Vector3(0, 0, 500), },
		{ idstring = Idstring("units/payday2/architecture/safehouse/safehouse_int_trapdoor"), icon = "wp_door", show_distance = true, distance_limit = Vector3(0, 0, 250), with_units_around = { { idstring=Idstring("units/dev_tools/level_tools/door_blocker/door_blocker"), find_distance = 200, force = true, }, }, },
		{ interaction = "hydrogen_chloride", icon = "pd2_methlab", show_distance = true, },
		{ interaction = "caustic_soda", icon = "pd2_methlab", show_distance = true, },
		{ interaction = "muriatic_acid", icon = "pd2_methlab", show_distance = true, },
	},
	["kenaz"] = { -- Golden Grin Casino
		{ interaction = "cas_open_briefcase", icon = "pd2_computer", show_distance = true, },
		{ interaction = "take_bottle", icon = "equipment_bottle", show_distance = true, },
		{ interaction = "pour_spiked_drink", icon = "equipment_bottle", show_distance = true, },
		{ interaction = "pickup_hotel_room_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "use_hotel_room_key", icon = "wp_door", show_distance = true, stealth_only = true, },
	},
	["mus"] = { -- The Diamond
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "invisible_interaction_open", icon = "pd2_wirecutter", show_distance = true, invalid_location_list = { Vector3(6150, 549, -500), }, },
		{ interaction = "rewire_electric_box", icon = "pd2_wirecutter", show_distance = true, },
	},
	["hox_3"] = { -- Hoxton Revenge
		{ interaction = "open_slash_close_sec_box", icon = "pd2_wirecutter", color = Color.red, show_distance = true, },
		{ idstring = Idstring("units/pd2_mcmansion/props/mcm_prop_panicroom/mcm_prop_panicroom_door"), icon = "wp_door", show_distance = true, },
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "pickup_keycard_axis", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "mcm_laptop", icon = "pd2_computer", show_distance = true, },
		{ interaction = "mcm_laptop_code", icon = "pd2_computer", show_distance = true, },
	},
	["hox_1"] = { -- Hoxton Breakout, day 1
		{ idstring = Idstring("units/payday2/props/gen_prop_security_monitors/gen_prop_security_monitors_four"), icon = "wp_door", show_distance = true, distance_limit = Vector3(3500, 3500, 0), with_units_around = { { interaction="security_station_keyboard", find_distance = 200, force = true, }, }, },
	},
	["hox_2"] = { -- Hoxton Breakout, day 2
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "grab_server", icon = "equipment_harddrive", show_distance = true, },
		{ interaction = "invisible_interaction_open", icon = "equipment_doctor_bag", show_distance = true, },
		{ interaction = "firstaid_box", icon = "equipment_doctor_bag", show_distance = true, },
		{ interaction = "grenade_crate", icon = "equipment_ammo_bag", show_distance = true, },
	},
	["pal"] = { -- Counterfeit
		{ interaction = "gen_pku_crowbar", icon = "equipment_crowbar", show_distance = true, },
		{ interaction = "crate_loot_crowbar", show_distance = true, },
		{ interaction = "press_printer_paper", icon = "equipment_paper_roll", show_distance = true, },
		{ interaction = "press_printer_ink", icon = "equipment_printer_ink", show_distance = true, },
	},
	["man"] = { -- Undercover
		{ interaction = "gen_pku_crowbar", icon = "equipment_crowbar", show_distance = true, },
		{ interaction = "stash_planks_pickup", icon = "equipment_planks", show_distance = true, },
	},
	["dinner"] = { -- Slaughterhouse
		{ interaction = "hold_take_gas_can", icon = "wp_can", show_distance = true, },
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
	},
	["flat"] = { -- Panic Room
		{ interaction = "panic_room_key", icon = "equipment_chavez_key", show_distance = true, },
		{ interaction = "c4_consume", icon = "equipment_c4", show_distance = true, },
	},
	["dah"] = { -- Diamond Heist
		{ idstring = Idstring("units/pd2_dlc_dah/props/dah_prop_hack_box/dah_prop_hack_ipad_unit"), icon = "pd2_wirecutter", show_distance = true, },
		{ idstring = Idstring("units/pd2_dlc_dah/dah_interactable_laptop/dah_interactable_laptop"), icon = "pd2_computer", show_distance = true, stealth_only = true, force = true, },
		{ interaction = "pickup_keycard", idstring = Idstring("units/pd2_dlc_red/pickups/gen_pku_keycard_outlined_waypoint/gen_pku_keycard_outlined_waypoint"), icon = "equipment_bank_manager_key", show_distance = true, ignore_count = true, },
	},
	["run"] = { -- Heat Street
		{ interaction = "hold_take_gas_can", icon = "wp_can", show_distance = true, },
	},
	["red2"] = { -- First World Bank
		{ idstring = Idstring("units/pd2_dlc_red/pickups/gen_pku_keycard_outlined/gen_pku_keycard_outlined"), icon = "equipment_bank_manager_key", show_distance = true, },
		{ idstring = Idstring("units/payday2/pickups/gen_pku_keycard/gen_pku_keycard_a"), icon = "equipment_bank_manager_key", show_distance = true, stealth_only = true, ignore_count = true, },
		{ idstring = Idstring("units/payday2/pickups/gen_pku_keycard/gen_pku_keycard_b"), icon = "equipment_bank_manager_key", show_distance = true, stealth_only = true, ignore_count = true, },
		{ interaction = "invisible_interaction_open", icon = "pd2_wirecutter", show_distance = true, invalid_location_list = { Vector3(1865, -2546, 575), Vector3(2213, 2660, 575), }, },
		{ interaction = "rewire_electric_box", icon = "pd2_wirecutter", show_distance = true, invalid_location_list = { Vector3(1874, -2545, 486), Vector3(2222, 2661, 486), }, },
	},
	["roberts"] = { -- GO Bank
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, invalid_location_list = { Vector3(250, 6750, -64.2354), }, },
		{ interaction = "pickup_boards", icon = "equipment_planks", show_distance = true, },
	},
	["rat"] = { -- Cook Off
		{ interaction = "hydrogen_chloride", icon = "pd2_methlab", show_distance = true, },
		{ interaction = "caustic_soda", icon = "pd2_methlab", show_distance = true, },
		{ interaction = "muriatic_acid", icon = "pd2_methlab", show_distance = true, },
		{ interaction = "stash_planks_pickup", icon = "equipment_planks", show_distance = true, },
	},
	["kosugi"] = { -- Shadow Raid
		{ interaction = "gen_pku_crowbar", icon = "equipment_crowbar", show_distance = true, },
		{ interaction = "pickup_keycard", idstring = Idstring("units/payday2/pickups/gen_pku_keycard/gen_pku_keycard"), icon = "equipment_bank_manager_key", show_distance = true, ignore_count = true, },
	},
	["arm_par"] = { -- Transport: Park
		{ idstring = Idstring("units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport_crashed"), show_distance = true, with_units_around = { { interaction = "drill", find_distance = 500, }, { interaction = "pick_lock_deposit_transport", find_distance = 500, }, }, },
		{ idstring = Idstring("units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport"), show_distance = true, with_units_around = { { interaction = "drill", find_distance = 500, }, { interaction = "pick_lock_deposit_transport", find_distance = 500, }, }, },
		{ idstring = Idstring("units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport_sniped"), show_distance = true, with_units_around = { { interaction = "drill", find_distance = 500, }, { interaction = "pick_lock_deposit_transport", find_distance = 500, }, }, },
	},
	["arm_cro"] = { -- Transport: Crossroads
		{ idstring = Idstring("units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport_crashed"), show_distance = true, with_units_around = { { interaction = "drill", find_distance = 500, }, { interaction = "pick_lock_deposit_transport", find_distance = 500, }, }, },
		{ idstring = Idstring("units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport"), show_distance = true, with_units_around = { { interaction = "drill", find_distance = 500, }, { interaction = "pick_lock_deposit_transport", find_distance = 500, }, }, },
		{ idstring = Idstring("units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport_sniped"), show_distance = true, with_units_around = { { interaction = "drill", find_distance = 500, }, { interaction = "pick_lock_deposit_transport", find_distance = 500, }, }, },
	},
	["arm_und"] = { -- Transport: Underpass
		{ idstring = Idstring("units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport_crashed"), show_distance = true, with_units_around = { { interaction = "drill", find_distance = 500, }, { interaction = "pick_lock_deposit_transport", find_distance = 500, }, }, },
		{ idstring = Idstring("units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport"), show_distance = true, with_units_around = { { interaction = "drill", find_distance = 500, }, { interaction = "pick_lock_deposit_transport", find_distance = 500, }, }, },
		{ idstring = Idstring("units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport_sniped"), show_distance = true, with_units_around = { { interaction = "drill", find_distance = 500, }, { interaction = "pick_lock_deposit_transport", find_distance = 500, }, }, },
	},
	["arm_hcm"] = { -- Transport: Downtown
		{ idstring = Idstring("units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport_crashed"), show_distance = true, with_units_around = { { interaction = "drill", find_distance = 500, }, { interaction = "pick_lock_deposit_transport", find_distance = 500, }, }, },
		{ idstring = Idstring("units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport"), show_distance = true, with_units_around = { { interaction = "drill", find_distance = 500, }, { interaction = "pick_lock_deposit_transport", find_distance = 500, }, }, },
		{ idstring = Idstring("units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport_sniped"), show_distance = true, with_units_around = { { interaction = "drill", find_distance = 500, }, { interaction = "pick_lock_deposit_transport", find_distance = 500, }, }, },
	},
	["arm_fac"] = { -- Transport: Harbor
		{ idstring = Idstring("units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport_crashed"), show_distance = true, with_units_around = { { interaction = "drill", find_distance = 500, }, { interaction = "pick_lock_deposit_transport", find_distance = 500, }, }, },
		{ idstring = Idstring("units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport"), show_distance = true, with_units_around = { { interaction = "drill", find_distance = 500, }, { interaction = "pick_lock_deposit_transport", find_distance = 500, }, }, },
		{ idstring = Idstring("units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport_sniped"), show_distance = true, with_units_around = { { interaction = "drill", find_distance = 500, }, { interaction = "pick_lock_deposit_transport", find_distance = 500, }, }, },
	},
	["arm_for"] = { -- Transport: Train Heist
		{ interaction = "disassemble_turret", icon = "equipment_sentry", show_distance = true, },
		{ interaction = "take_ammo", icon = "wp_bag", show_distance = false, },
		{ interaction = "access_camera", icon = "wp_door", show_distance = true, with_units_around = { { interaction = "take_ammo", find_distance = 1000, }, { interaction = "disassemble_turret", find_distance = 1000, }, }, 
			check_function = function(unit)
				-- show the vault door
				for _, find_unit in pairs(World:find_units_quick("all",1)) do
					-- exclude the door with blocking walls around
					if tostring(find_unit:name()) == tostring(Idstring("units/payday2/architecture/bnk/bnk_int_wall2m_backless")) and (tostring(find_unit:rotation()) == "Rotation(90, -0, -0)" or tostring(find_unit:rotation()) == "Rotation(-90, 0, -0)") then
						local distance = mvector3.distance(unit:position(), find_unit:position())
						if distance < 400 then
							return false
						end
					end
				end
				return true
			end
		},
	},
	["arena"] = { -- The Alesso Heist
		{ idstring = Idstring("units/pd2_dlc_arena/architecture/are_lobby/are_cross"), icon = "wp_door", show_distance = true, with_units_around = { { interaction = "pick_lock_hard_no_skill_deactivated", find_distance = 200, }, }, },
		{ interaction = "hold_take_fire_extinguisher", icon = "pd2_fire", show_distance = true, },
	},
	["rvd1"] = { -- Reservoir Dogs Heist, day 1
		{ interaction = "stash_planks_pickup", icon = "equipment_planks", show_distance = true, },
	},
	["cage"] = { -- Car Shop
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "security_station_keyboard", icon = "pd2_computer", show_distance = true, force = true,
			check_function = function(unit)
				if Network:is_client() then return false end
				-- find the right computer, host only
				if unit and alive(unit) and unit.position and managers and managers.mission and managers.mission:script("default") and managers.mission:script("default")._elements then
					local keyboard_locations = { ["104797"] = Vector3(2465.98, 660.75, -149.996), ["104804"] = Vector3(2615.98, 660.75, -149.996), ["104811"] = Vector3(2890.98, 660.75, -149.996), ["104818"] = Vector3(3040.98, 660.75, -149.996), ["104826"] = Vector3(3045.98, 405.75, -149.996), ["104833"] = Vector3(2887.98, 407.75, -149.996), ["104841"] = Vector3(2615.98, 410.75, -149.996), ["104848"] = Vector3(2465.98, 407.75, -149.996), ["104857"] = Vector3(1077.98, 255.751, 250.004), ["104866"] = Vector3(924.978, 255.75, 250.004), ["104873"] = Vector3(617.978, 255.75, 250.004), ["104880"] = Vector3(468.978, 255.749, 250.004), ["104887"] = Vector3(423.024, 142.249, 250.004), ["104899"] = Vector3(590.024, 142.25, 250.004), ["104907"] = Vector3(880.024, 142.25, 250.004), ["104919"] = Vector3(1049.02, 142.251, 250.004), ["104927"] = Vector3(229.75, -1490.98, 249.503) }
					local keyboard_id = tostring(managers.mission:script("default")._elements[104929]._values.on_executed[1].id)
					if tostring(unit:position()) == tostring(keyboard_locations[keyboard_id]) then
						return true
					end
				end
				return false
			end
		},
	},
	["family"] = { -- Diamond Store
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
		{ interaction = "numpad_keycard", icon = "icon_locked", show_distance = true, },
	},
	["branchbank"] = { -- Bank Heist
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
	},
	["firestarter_1"] = { -- Firestarter, day 1
		{ interaction = "drill", icon = "pd2_drill", show_distance = true, },
		{ interaction = "weapon_case", show_distance = true, },
		{ interaction = "take_weapons", icon = "wp_bag", show_distance = true, },
	},
	["firestarter_2"] = { -- Firestarter, day 2
		{ interaction = "pick_lock_hard_no_skill", icon = "wp_door", show_distance = true, },
		{ interaction = "open_slash_close_sec_box", icon = "pd2_wirecutter", show_distance = true, stealth_only = true, with_units_exist = { { interaction = "pick_lock_hard_no_skill", }, }, 
			check_function = function(unit)
				if Network:is_client() then return true end -- show all electricity box as client
				return false
			end
		},
		{ interaction = "hospital_security_cable_red", icon = "pd2_wirecutter", show_distance = true, stealth_only = true, with_units_exist = { { interaction = "pick_lock_hard_no_skill", }, }, 
			check_function = function(unit)
				if Network:is_client() then return true end -- show all electricity box as client
				return false
			end
		},
		{ interaction = "hospital_security_cable_red", icon = "pd2_wirecutter", color = Color.red, show_distance = true, stealth_only = true, force = true, with_units_exist = { { interaction = "pick_lock_hard_no_skill", }, }, 
			check_function = function(unit)
				-- find the correct electricity box without hacking computer, host only
				if Network:is_server() and unit and alive(unit) and unit.position and managers and managers.mission and managers.mission:script("default") and managers.mission:script("default")._elements then
					local box_locations = { ["105819"] = Vector3(-2710, -2830, 552), ["105794"] = Vector3(-1840, -3195, 552), ["105810"] = Vector3(-1540, -2195, 552), ["105824"] = Vector3(-1005, -3365, 552), ["105837"] = Vector3(-635, -1705, 552), ["105851"] = Vector3(-1095, -210, 152), ["106183"] = Vector3(-1230, 1510, 152), ["106529"] = Vector3(-1415, -795, 152), ["106543"] = Vector3(-1160, 395, 152), ["106556"] = Vector3(-5, 735, 152),  ["106594"] = Vector3(795, -898, 552), ["106607"] = Vector3(795, -3240, 552), ["106620"] = Vector3(1060, -2195, 552), ["106633"] = Vector3(204, 540, 578), ["106646"] = Vector3(-1085, -1205, 552), ["106659"] = Vector3(-2135, 395, 552), ["106672"] = Vector3(-2405, -840, 552), ["106685"] = Vector3(-2005, -1640, 552), ["106698"] = Vector3(-2715, -1595, 552), ["106711"] = Vector3(-500, -650, 1300), ["106724"] = Vector3(-400, -650, 1300), ["106737"] = Vector3(-300, -650, 1300), ["106750"] = Vector3(-200, -650, 1300), ["106763"] = Vector3(-100, -650, 1300), ["106776"] = Vector3(-635, -1205, 152), ["106789"] = Vector3(-1040, -89, 552), ["106802"] = Vector3(615, 395, 152), ["106815"] = Vector3(1890, -1805, 152), ["106828"] = Vector3(215, -1805, 152) }
					local box_1 = tostring(managers.mission:script("default")._elements[106836]._values.on_executed[1].id)
					local box_2 = tostring(managers.mission:script("default")._elements[106836]._values.on_executed[2].id)
					if box_1 and box_locations[box_1] then
						local found_units = World:find_units_quick("sphere", box_locations[box_1], 100, managers.slot:get_mask("all"))
						for _, found_unit in ipairs(found_units) do
							if found_unit == unit then return true end
						end
					end
					if box_2 and box_locations[box_2] then
						local found_units = World:find_units_quick("sphere", box_locations[box_2], 100, managers.slot:get_mask("all"))
						for _, found_unit in ipairs(found_units) do
							if found_unit == unit then return true end
						end
					end
				end
				return false
			end
		},
		{ interaction = "pick_lock_hard", icon = "pd2_drill", show_distance = true, },
	},
	["firestarter_3"] = { -- Firestarter, day 3
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, },
	},
	["alex_1"] = { -- Rats, day 1
		{ interaction = "hydrogen_chloride", icon = "pd2_methlab", show_distance = true, },
		{ interaction = "caustic_soda", icon = "pd2_methlab", show_distance = true, },
		{ interaction = "muriatic_acid", icon = "pd2_methlab", show_distance = true, },
		{ interaction = "stash_planks_pickup", icon = "equipment_planks", show_distance = true, },
	},
	["alex_2"] = { -- Rats, day 2
		{ interaction = "take_confidential_folder", icon = "pd2_question", show_distance = true, force = true, with_units_around = { { interaction = "drill", find_distance = 50, }, }, 
			check_function = function(unit)
				if Network:is_client() then
					-- show location of safe that can be drilled as client
					return true
				end
				if Network:is_server() and unit and alive(unit) and unit.position and managers and managers.mission and managers.mission:script("default") and managers.mission:script("default")._elements then
					-- show file location, host only
					local file_locations = { ["103805"] = Vector3(791, 1426, 50), ["103806"] = Vector3(326, 1673, 50), ["103807"] = Vector3(365, 2022, 103.2),	 ["103808"] = Vector3(560, 2175, 127.603), ["103809"] = Vector3(2220, 1273, 82.103), ["103810"] = Vector3(2079, 1013, 117.503), ["103811"] = Vector3(2502, 1015, 50), ["103812"] = Vector3(2332, 1100, 50), ["103813"] = Vector3(3162, 2742, 82.1028), ["103814"] = Vector3(2704, 2342, 114.325), ["103815"] = Vector3(3400, 2662, 117.285), ["103816"] = Vector3(2440, 2747, 50), ["103817"] = Vector3(2474, 3414, 250), ["103818"] = Vector3(3181, 3696, 250), ["103819"] = Vector3(2625, 4003, 250), ["103820"] = Vector3(2755, 3901, 250), }
					local file_id = tostring(managers.mission:script("default")._elements[103759]._values.on_executed[1].id)
					if tostring(unit:position()) == tostring(file_locations[file_id]) then
						return true
					end
				end
				return false
			end
		},
	},
	["pent"] = { -- Mountain Master
		{ interaction = "pick_lock_easy_no_skill_pent", icon = "pd2_wirecutter", show_distance = true, distance_limit = Vector3(0, 0, 4000), },
		{ interaction = "pent_pull_lever", icon = "pd2_wirecutter", show_distance = true, distance_limit = Vector3(0, 0, 4000),  },
		{ interaction = "pent_open_powerbox", icon = "wp_powersupply", show_distance = true, distance_limit = Vector3(0, 0, 4000),  },
		{ interaction = "rewire_electric_box", icon = "wp_powersupply", show_distance = true, distance_limit = Vector3(0, 0, 4000),  },
		{ interaction = "press_to_interact", icon = "equipment_crowbar", show_distance = true, force = true, distance_limit = Vector3(0, 0, 4000), 
			check_function = function(unit)
				if not managers or not managers.mission or not managers.mission:script("default") or not unit or not alive(unit) or not unit.position then return end
				if managers.mission:script("default")._elements[102260] and managers.mission:script("default")._elements[102260]._values.enabled and tostring(unit:position()) == 'Vector3(-946.63, -2845.03, -325)' then
					return true
				elseif managers.mission:script("default")._elements[102261] and managers.mission:script("default")._elements[102261]._values.enabled and tostring(unit:position()) == 'Vector3(-322.075, -2444.41, -325)' then
					return true
				elseif managers.mission:script("default")._elements[102262] and managers.mission:script("default")._elements[102262]._values.enabled and tostring(unit:position()) == 'Vector3(300, -1850, -325)' then
					return true
				end
				return false
			end,
		},
		{ interaction = "pent_generator_start", show_distance = true, },
		{ interaction = "pent_take_wire", show_distance = true, },
		{ interaction = "sand_place_note", icon = "wp_door", show_distance = true, force = true, distance_limit = Vector3(0, 0, 4000), with_units_around = { { interaction = "sand_pickup_harddrive", find_distance = 600, }, }, },
		{ interaction = "sand_take_note", icon = "equipment_notepad", show_distance = true, distance_limit = Vector3(0, 0, 4000), },
		{ interaction = "place_harddrive", icon = "equipment_harddrive", show_distance = true, force = true, distance_limit = Vector3(0, 0, 4000), with_units_around = { { interaction = "mcm_laptop", find_distance = 50, force = true, }, }, },
		{ interaction = "pent_hold_start_fire_alarm", icon = "equipment_thermite", show_distance = true, distance_limit = Vector3(0, 0, 4000), },
		{ interaction = "pickup_keycard", icon = "equipment_bank_manager_key", show_distance = true, distance_limit = Vector3(0, 0, 4000), },
		{ interaction = "timelock_panel", icon = "icon_locked", show_distance = true, force = true, distance_limit = Vector3(0, 0, 4000), with_units_around = { { interaction = "pent_hold_open", find_distance = 100, }, { interaction = "gold_pile", find_distance = 300, force = true, }, }, },
		{ interaction = "mex_red_room_key", icon = "equipment_chavez_key", show_distance = true, force = true, distance_limit = Vector3(0, 0, 600), with_units_around = { { interaction = "drill", find_distance = 100, }, }, },
	},
}

local common_big_loot_idstrings ={
	{ interaction = "requires_ecm_jammer_atm", icon = "equipment_ecm_jammer", show_distance = false, },
	{ idstring = Idstring("units/payday2/props/gen_prop_bank_atm_standing/gen_prop_bank_atm_standing_spawn"), icon = "wp_bag", show_distance = false, },
	{ interaction = "money_small", icon = "wp_bag", show_distance = false, },
	{ interaction = "money_small_take", icon = "wp_bag", show_distance = false, },
	{ interaction = "money_wrap", icon = "wp_bag", show_distance = false, },
	{ interaction = "money_wrap_axis", icon = "wp_bag", show_distance = false, },
	{ interaction = "money_wrap_updating", icon = "wp_bag", show_distance = false, },
	{ interaction = "money_wrap_updating_directional", icon = "wp_bag", show_distance = false, },
	{ interaction = "money_wrap_active", icon = "wp_bag", show_distance = false, },
	{ interaction = "money_scanner", icon = "wp_bag", show_distance = false, },
	{ interaction = "money_luggage", icon = "wp_bag", show_distance = false, },
	{ interaction = "money_bag", icon = "wp_bag", show_distance = false, },
	{ interaction = "gold_pile", icon = "wp_bag", show_distance = false, },
	{ interaction = "coke", icon = "wp_bag", show_distance = false, },
	{ interaction = "coke_pure", icon = "wp_bag", show_distance = false, },
	{ interaction = "gen_pku_cocaine", icon = "wp_bag", show_distance = false, },
	{ interaction = "gen_pku_cocaine_pure", icon = "wp_bag", show_distance = false, },
	{ interaction = "gen_pku_cocaine_directional", icon = "wp_bag", show_distance = false, },
	{ interaction = "taking_meth", icon = "wp_bag", show_distance = false, },
	{ interaction = "meth_half", icon = "wp_bag", show_distance = false, },
	{ interaction = "painting", icon = "wp_bag", show_distance = false, },
	{ interaction = "hold_take_painting", icon = "wp_bag", show_distance = false, },
	{ interaction = "gen_pku_artifact", icon = "wp_bag", show_distance = false, },
	{ interaction = "gen_pku_artifact_statue", icon = "wp_bag", show_distance = false, },
	{ interaction = "gen_pku_artifact_painting", icon = "wp_bag", show_distance = false, },
	{ interaction = "weapon", icon = "wp_bag", show_distance = false, },
	{ interaction = "weapons", icon = "wp_bag", show_distance = false, },
	{ interaction = "take_weapons", icon = "wp_bag", show_distance = false, },
	{ interaction = "ranc_take_weapons", icon = "wp_bag", show_distance = false, },
	{ interaction = "gen_pku_warhead", icon = "wp_bag", show_distance = false, },
	{ interaction = "ammo", icon = "wp_bag", show_distance = false, },
	{ interaction = "take_ammo", icon = "wp_bag", show_distance = false, },
	{ interaction = "disassemble_turret", icon = "wp_bag", show_distance = false, },
	{ interaction = "gen_pku_jewelry", icon = "wp_bag", show_distance = false, },
	{ interaction = "diamonds_pickup", icon = "wp_bag", show_distance = false, },
	{ interaction = "red_diamond_pickup", icon = "wp_bag", show_distance = false, },
	{ interaction = "diamonds_pickup_full", icon = "wp_bag", show_distance = false, },
	{ interaction = "mus_take_diamond", icon = "wp_bag", show_distance = false, },
	{ interaction = "pku_safe", icon = "wp_bag", show_distance = false, },
	{ interaction = "roman_armor", icon = "wp_bag", show_distance = false, },
	{ interaction = "evidence_bag", icon = "wp_bag", show_distance = false, },
	{ interaction = "gen_pku_evidence_bag", icon = "wp_bag", show_distance = false, },
	{ interaction = "gen_pku_evidence_bag_axis", icon = "wp_bag", show_distance = false, },
	{ interaction = "corp_hold_pku_paperpile_bag", icon = "wp_bag", show_distance = false, },
	{ interaction = "bex_pku_treasure", icon = "wp_bag", show_distance = false, },
	{ interaction = "bex_prop_faberge_egg", icon = "wp_bag", show_distance = false, },
	{ interaction = "trai_printing_plates_carry", icon = "wp_bag", show_distance = false, },
	{ interaction = "hold_grab_goat", icon = "wp_bag", show_distance = false, },
	{ interaction = "pku_pig", icon = "wp_bag", show_distance = false, },
	{ interaction = "crate_loot", show_distance = false, },
	{ interaction = "crate_loot_crowbar", show_distance = false, },
	{ interaction = "weapon_case", show_distance = false, },
	{ interaction = "gen_pku_warhead_box", show_distance = false, },
	{ interaction = "money_briefcase", show_distance = false, },
	{ interaction = "grenade_briefcase", show_distance = false, 
		check_function = function(unit)
			if unit and alive(unit) and unit.name and (tostring(unit:name()) == tostring(Idstring("units/payday2/equipment/gen_equipment_grenade_crate/gen_equipment_grenade_crate")) or tostring(unit:name()) == tostring(Idstring("units/payday2/equipment/gen_equipment_thermal_paste_crate/gen_equipment_thermal_paste_crate"))) then
				return false
			else
				return true
			end
		end,
	},
	{ interaction = "cut_glass", show_distance = false, },

	invalid_interaction_per_heist = {
		["peta"] = { "hold_grab_goat", }, -- Goat Simulator
		["pbr2"] = { "money_wrap", }, -- Birth of Sky
		["pbr"] = { "crate_loot", "gen_pku_artifact", }, -- Beneath the Mountain
		["sah"] = { "cut_glass", }, -- Shacklethorne Auction
		["mex_cooking"] = { "roman_armor", }, -- Border Crystals
		["mia_1"] = { "crate_loot_crowbar", }, -- Hotline Miami, day 1
		["hox_2"] = { "grenade_crate", }, -- Hoxton Breakout, day 2
		["pal"] = { "crate_loot_crowbar", }, -- Counterfeit
		["arm_for"] = { "disassemble_turret", "take_ammo", }, -- Transport: Train Heist
		["watchdogs_2"] = { "gen_pku_cocaine", }, -- Watchdogs, day 2
		["firestarter_1"] = { "weapon_case", "take_weapons", }, -- Firestarter, day 1
		["pent"] = { "gen_pku_artifact", },  -- Mountain Master
	},
	invalid_location_per_heist = {
		["welcome_to_the_jungle_1"] = { Vector3(9200, -4400, 100), Vector3(9200, -4300, 100), }, -- Big Oil, day 1
		["welcome_to_the_jungle_1_night"] = { Vector3(9200, -4400, 100), Vector3(9200, -4300, 100), }, -- Big Oil, day 1 night version
		["sah"] = { Vector3(-149, 4824, -20), Vector3(328.013, 4754.27, -101) }, -- Shacklethorne Auction
		["des"] = { Vector3(4867, -2323, -117), Vector3(5093, -2716, -101.93), Vector3(4667, -2452, -33), Vector3(-4604, -908, 99), }, -- Henry's Rock
		["vit"] = { Vector3(8625, 6590, -1773), }, -- The White House
		["roberts"] = { Vector3(-1144.92, -1458.02, 78.1446), }, -- GO Bank
		["rvd2"] = { Vector3(-1225, 2025, 1345), }, -- Reservoir Dogs Heist, day 2
		["family"] = { Vector3(1400, 200, 1100), }, -- Diamond Store
		["alex_3"] = { Vector3(10404.1, 24929.4, 1590.74), Vector3(10472.1, 24921.4, 1593.01), Vector3(10554.1, 24924.4, 1595.89), Vector3(10622.5, 24927.4, 1598.46), Vector3(10748.8, 24905, 1635.16), Vector3(10760.8, 24846, 1637.31), Vector3(10823.8, 24903, 1640.07), Vector3(10826.8, 24847, 1639.6), Vector3(10897.8, 24902, 1641.44), Vector3(10898.8, 24846, 1641.09), Vector3(10942.8, 24902, 1642.23), Vector3(10943.8, 24846, 1641.88), Vector3(11014.9, 24903, 1644.89), Vector3(11013.8, 24845, 1644.5), Vector3(11084.8, 24904, 1647.59), Vector3(11078.8, 24845, 1647.2), }, -- Rats, day 3
	},
}

local common_small_loot_idstrings = {
	{ interaction = "safe_loot_pickup", icon = "interaction_money_wrap", show_distance = false, },
	{ interaction = "diamond_pickup", icon = "interaction_money_wrap", show_distance = false, },
	{ interaction = "diamond_pickup_pal", icon = "interaction_money_wrap", show_distance = false, },
	{ interaction = "diamond_pickup_axis", icon = "interaction_money_wrap", show_distance = false, },
	{ interaction = "tiara_pickup", icon = "interaction_money_wrap", show_distance = false, },
	{ interaction = "press_take_folder", icon = "interaction_money_wrap", show_distance = false, },
	{ interaction = "money_wrap_single_bundle", icon = "interaction_money_wrap", show_distance = false, },
	{ interaction = "money_wrap_single_bundle_active", icon = "interaction_money_wrap", show_distance = false, },
	{ interaction = "money_wrap_single_chas", icon = "interaction_money_wrap", show_distance = false, },
	{ interaction = "mus_pku_artifact", icon = "interaction_money_wrap", show_distance = false, },
	{ interaction = "cash_register", icon = "interaction_money_wrap", show_distance = false, },
	{ interaction = "diamond_single_pickup_axis", icon = "interaction_money_wrap", show_distance = false, },
	{ interaction = "take_pardons", icon = "interaction_money_wrap", show_distance = false, },
	{ interaction = "pickup_tablet", icon = "interaction_money_wrap", show_distance = false, },
	{ interaction = "pickup_phone", icon = "interaction_money_wrap", show_distance = false, },
	{ interaction = "cas_chips_pile", icon = "interaction_money_wrap", show_distance = false, },

	invalid_interaction_per_heist = {
		["four_stores"] = { "cash_register", "money_wrap_single_bundle" }, -- Four Stores
	},
	invalid_location_per_heist = {
		["welcome_to_the_jungle_1"] = { Vector3(9200, -4200, 100), Vector3(9200, -4100, 100), Vector3(9200, -4000, 100), Vector3(9200, -3900, 100), Vector3(9200, -3800, 100), }, -- Big Oil, day 1
		["welcome_to_the_jungle_1_night"] = { Vector3(9200, -4200, 100), Vector3(9200, -4100, 100), Vector3(9200, -4000, 100), Vector3(9200, -3900, 100), Vector3(9200, -3800, 100), }, -- Big Oil, day 1 night version
		["ukrainian_job"] = { Vector3(1844, 665, 117.732), Vector3(1854.04, 623.803, 123.024), Vector3(1864.37, 623.803, 123.024), }, -- Ukrainian Job
		["rvd2"] = { Vector3(-1300, 1875, 1335.26), Vector3(-1250, 1875, 1335.26), Vector3(-1200, 1875, 1335.26), Vector3(-1150, 1900, 1335.26), }, -- Reservoir Dogs Heist, day 2
		["jewelry_store"] = { Vector3(1844, 665, 117.732), Vector3(1854.04, 623.803, 123.024), Vector3(1864.37, 623.803, 123.024), }, -- Jewelry Store
		["family"] = { Vector3(1400, -100, 1100), Vector3(1400, 0, 1100), Vector3(1400, 100, 1100), }, -- Diamond Store
	},
}

local collection_idstrings ={
	["common"] = {
		{ interaction = "gage_assignment", idstring = Idstring("units/pd2_dlc_gage_jobs/pickups/gen_pku_gage_yellow/gen_pku_gage_yellow"), icon = "interaction_christmas_present", color = Color.yellow, show_distance = false, },
		{ interaction = "gage_assignment", idstring = Idstring("units/pd2_dlc_gage_jobs/pickups/gen_pku_gage_blue/gen_pku_gage_blue"), icon = "interaction_christmas_present", color = Color.blue, show_distance = false, },
		{ interaction = "gage_assignment", idstring = Idstring("units/pd2_dlc_gage_jobs/pickups/gen_pku_gage_purple/gen_pku_gage_purple"), icon = "interaction_christmas_present", color = Color.purple, show_distance = false, },
		{ interaction = "gage_assignment", idstring = Idstring("units/pd2_dlc_gage_jobs/pickups/gen_pku_gage_red/gen_pku_gage_red"), icon = "interaction_christmas_present", color = Color.red, show_distance = false, },
		{ interaction = "gage_assignment", idstring = Idstring("units/pd2_dlc_gage_jobs/pickups/gen_pku_gage_green/gen_pku_gage_green"), icon = "interaction_christmas_present", color = Color.green, show_distance = false, },

		{ interaction = "press_pick_up", icon = "wp_scrubs", show_distance = false, },
		{ interaction = "pick_up_item", icon = "wp_scrubs", show_distance = false, },
		{ interaction = "pickup_keys", icon = "wp_scrubs", show_distance = false, },
		{ interaction = "pickup_case", icon = "wp_scrubs", show_distance = false, },
		{ interaction = "take_jfr_briefcase", idstring = Idstring("units/pd2_dlc_jfr/equipment/equip_jfr_briefcase/equip_jfr_briefcase"), icon = "wp_scrubs", show_distance = false, },

		{ idstring = Idstring("units/pd2_dlc_lrm/props/lrm_prop_safe/lrm_prop_safe"), icon = "equipment_rfid_tag_01", color = Color.red, show_distance = false, with_units_around = { { interaction="press_use_lrm_safe_keycard", find_distance=200, }, }, }, -- lost safe
		{ idstring = Idstring("units/pd2_dlc_lrm/props/lrm_pku_keycard/lrm_pku_keycard"), icon = "equipment_rfid_tag_01", show_distance = false, }, -- lost safe keycard

		{ interaction = "gen_pku_sandwich", icon = "wp_bag", show_distance = false, },
		{ interaction = "pku_toothbrush", icon = "wp_bag", color = Color.red, show_distance = false, },
		{ interaction = "chas_tea_set", icon = "wp_bag", show_distance = false, },
	},

	["sand"] = { -- The Ukrainian Prisoner
		{ idstring = Idstring("units/pd2_dlc_sand/props/sand_prop_int_vase_a/sand_prop_int_vase_a"), icon = "wp_target", show_distance = false, check_collision = { position_offset = Vector3(0, 0, 93.2), find_distance = 1, }, }, 
		{ interaction = "push_button", icon = "wp_powerbutton", show_distance = false, },
		{ interaction = "atm_interaction", icon = "pd2_door", show_distance = false, 
			check_function = function(unit)
				if unit and alive(unit) and unit.position and tostring(unit:position()) == 'Vector3(17405, -2185, -9)' then
					return true
				end
				return false
			end
		},
	},
	["friend"] = { -- Scarface Mansion
		{ idstring = Idstring("units/pd2_dlc_friend/props/sfm_prop_ext_flamingo/sfm_prop_ext_flamingo_a"), icon = "wp_target", show_distance = false, check_collision = { position_offset = Vector3(0, 0, 60), find_distance = 1, }, },
		{ idstring = Idstring("units/pd2_dlc_friend/props/sfm_prop_ext_flamingo/sfm_prop_ext_flamingo_b"), icon = "wp_target", show_distance = false, check_collision = { position_offset = Vector3(0, 0, 60), find_distance = 1, }, },
	},
	["deep"] = { -- Crude Awakening
		{ idstring = Idstring("units/pd2_dlc_deep/props/deep_prop_seagull/deep_prop_seagull"), icon = "wp_target", show_distance = false, check_collision = { position_offset = Vector3(0, 0, 8), find_distance = 1, }, },
	},
	["wwh"] = { -- Alaskan Deal
		{ idstring = Idstring("units/pd2_dlc_mad/architecture/mad_sawmill/mad_snow_man"), icon = "wp_target", show_distance = false, check_collision = { position_offset = Vector3(0, 0, 48), find_distance = 1, }, },
	},

	["moon"] = { -- Stealing Xmas
		{ interaction = "hold_take_mask", icon = "wp_scrubs", show_distance = false, },
	},
	["bex"] = { -- San Martín Bank
		{ interaction = "invisible_interaction_open", icon = "equipment_chrome_mask", show_distance = false, }, -- xm20_int_mask box
		{ interaction = "xm20_int_mask", icon = "equipment_chrome_mask", show_distance = false, },
	},
	["fex"] = { -- Buluc's Mansion
		{ interaction = "invisible_interaction_open", icon = "equipment_chrome_mask", show_distance = false, }, -- xm20_int_mask box
		{ interaction = "xm20_int_mask", icon = "equipment_chrome_mask", show_distance = false, },
		{ interaction = "drill", icon = "pd2_drill", show_distance = false, }, -- achievement for getting all loots, including loot in the safe
	},
	["jolly"] = { -- Aftershock
		{ interaction = "hold_pku_knife", show_distance = false, },
	},
	["ranc"] = { -- Midland Ranch
		{ interaction = "ranc_press_pickup_horseshoe", icon = "wp_scrubs", show_distance = false, },
		{ interaction = "ranc_take_mould", icon = "equipment_mould", show_distance = false, },
		{ interaction = "ranc_take_hammer", icon = "equipment_hammer", show_distance = false, },
		{ interaction = "ranc_break_wall", icon = "wp_target", show_distance = false, },
		{ interaction = "ranc_take_silver_ingot", icon = "equipment_silver_ingot", show_distance = false, },
		{ interaction = "ranc_take_sheriff_star", icon = "equipment_sheriff_star", show_distance = false, },
	},
	["pbr2"] = { -- Birth of Sky
		{ interaction = "ring_band", icon = "wp_scrubs", show_distance = false, },
	},
	["sah"] = { -- Shacklethorne Auction
		{ idstring = Idstring("units/pd2_dlc_sah/props/sah_prop_mummy/sah_prop_mummy"), icon = "wp_scrubs", show_distance = false, with_units_around = { { interaction = "cut_glass", find_distance = 50, }, }, },
		{ interaction = "press_pay_respects", icon = "wp_scrubs", show_distance = false, },
	},
	["pex"] = { -- Breakfast in Tijuana
		{ interaction = "invisible_interaction_open", icon = "equipment_chrome_mask", show_distance = false, }, -- xm20_int_mask box
		{ interaction = "xm20_int_mask", icon = "equipment_chrome_mask", show_distance = false, },
		{ interaction = "pex_medal", icon = "wp_scrubs", show_distance = false, },
	},
	["tag"] = { -- Breakin' Feds
		{ interaction = "tag_take_stapler", icon = "equipment_stapler", show_distance = false, },
		{ interaction = "press_place_stapler", icon = "equipment_stapler", show_distance = false, },
	},
	["mex"] = { -- Border Crossing
		{ interaction = "invisible_interaction_open", icon = "equipment_chrome_mask", show_distance = false, invalid_location_list = { Vector3(1200, -9200, -2100), }, }, -- xm20_int_mask box
		{ interaction = "xm20_int_mask", icon = "equipment_chrome_mask", show_distance = false, },
		{ interaction = "mex_pickup_murky_uniforms", icon = "wp_scrubs", show_distance = false, },
	},
	["mex_cooking"] = { -- Border Crystals
		{ interaction = "invisible_interaction_open", icon = "equipment_chrome_mask", show_distance = false, invalid_location_list = { Vector3(1200, -9200, -2100), Vector3(-237.78, -6171.95, -3446), }, }, -- xm20_int_mask box
		{ interaction = "xm20_int_mask", icon = "equipment_chrome_mask", show_distance = false, },
	},
	["haunted"] = { -- Safe House Nightmare
		{ interaction = "halloween_trick", icon = "wp_scrubs", show_distance = false, },
	},
	["help"] = { -- Prison Nightmare
		{ idstring = Idstring("units/pd2_dlc_chill/props/chl_props_trophies/chl_props_trophy_pumpkin/chl_prop_pumpkin_small"), show_distance = false, check_collision = {}, },
	},
	["glace"] = { -- Green Bridge
		{ interaction = "glc_hold_take_handcuffs", icon = "wp_scrubs", show_distance = false, },
	},
	["run"] = { -- Heat Street
		{ interaction = "hold_take_missing_animal_poster", icon = "wp_scrubs", show_distance = false, },
		{ interaction = "hold_pick_up_turtle", icon = "wp_scrubs", show_distance = false, },
	},
	["red2"] = { -- First World Bank
		{ interaction = "red_take_envelope", show_distance = false, },
	},
}

local function add_waypoint(position, waypoint_name, icon, color, show_distance)
	if position and waypoint_name and managers and managers.hud and managers.hud.add_waypoint then
		managers.hud:add_waypoint(
			waypoint_name, {
			icon = icon or "wp_target",
			distance = show_distance and true or false,
			position = position,
			no_sync = true,
			present_timer = 0,
			state = "present",
			radius = 50,
			color = color or Color.gray,
			blend_mode = "add"
		})

		local waypoint = managers.hud._hud and managers.hud._hud.waypoints and managers.hud._hud.waypoints[waypoint_name]
		if color and waypoint and waypoint.bitmap and waypoint.bitmap.set_color then
			 waypoint.bitmap:set_color(color)
		end
	end
end

local function remove_waypoint(waypoint_name)
	if managers and managers.hud and managers.hud.remove_waypoint then
		managers.hud:remove_waypoint(waypoint_name)
	end
end

local function check_and_add_waypoint(unit_list, check_list)
	local waypoint_name_list = {}
	local level_id = Global.level_data and Global.level_data.level_id
	for _, unit in pairs( (type(unit_list) == "table" and unit_list) or {} ) do
		for _, data in pairs( (type(check_list) == "table" and check_list) or {} ) do
			if data and type(data) == "table" and unit and alive(unit) and unit.position and unit:position() and (
			  (unit.name and tostring(unit:name()) == tostring(data.idstring) and not data.interaction) or 
			  (unit.interaction and unit:interaction() and unit:interaction().tweak_data == data.interaction and not data.idstring) or
			  (unit.name and tostring(unit:name()) == tostring(data.idstring) and unit.interaction and unit:interaction() and unit:interaction().tweak_data == data.interaction)
			  ) then
				local is_add_waypoint = true

				if data.loud_only and managers and managers.groupai and managers.groupai:state() and managers.groupai:state():whisper_mode() then
					is_add_waypoint = false
				end
				if data.stealth_only and managers and managers.groupai and managers.groupai:state() and not managers.groupai:state():whisper_mode() then
					is_add_waypoint = false
				end

				-- if unit have interaction, then only add waypoint for unit which interaction is available
				-- force means ignore it's interaction state
				if is_add_waypoint and data.force then
					is_add_waypoint = true
				elseif is_add_waypoint and not data.force and unit.interaction and unit:interaction() then
					is_add_waypoint = false
					for _, interactive_unit in pairs(managers.interaction._interactive_units or {}) do
						if unit == interactive_unit then
							is_add_waypoint = true
							break
						end
					end
				end

				-- if already have that special equipment, won't highlight others anymore
				if is_add_waypoint and not data.ignore_count and unit.interaction and unit:interaction() then
					if unit:interaction()._tweak_data.special_equipment_block and managers and managers.player and managers.player._equipment.specials[unit:interaction()._tweak_data.special_equipment_block] then
						is_add_waypoint = false
					end
					if unit:interaction().tweak_data == "pickup_keycard" and managers.player and managers.player._equipment.specials["bank_manager_key"] then
						is_add_waypoint = false
					end
					if (unit:interaction().tweak_data == "fex_take_diesel" or unit:interaction().tweak_data == "fex_take_diesel_axis") and managers.player and managers.player._equipment.specials["diesel"] then
						is_add_waypoint = false
					end
					if string.find(unit:interaction().tweak_data, "c4") and managers.player._equipment.specials["c4"] then
						is_add_waypoint = false
					end
				end

				-- compare player position with unit position, if distance exceeds given limit then won't highlight
				if is_add_waypoint and data.distance_limit and managers and managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) then
					local unit_pos = unit:position()
					local player_pos = managers.player:player_unit():movement():m_head_pos()
					local limit = data.distance_limit
					if (limit.x ~= 0 and math.abs(unit_pos.x - player_pos.x) > limit.x) or (limit.y ~= 0 and math.abs(unit_pos.y - player_pos.y) > limit.y) or (limit.z ~= 0 and math.abs(unit_pos.z - player_pos.z) > limit.z) then
						is_add_waypoint = false
					end
				end

				-- check invalid location, if find unit at those position with given idstring or interaction then won't highlight
				if is_add_waypoint and data.invalid_location_list and type(data.invalid_location_list) == "table" then
					for _, invalid_pos in pairs(data.invalid_location_list) do
						if tostring(unit:position()) == tostring(invalid_pos) then
							is_add_waypoint = false
							break
						end
					end
				end

				-- check if unit have collision size, or check if unit is in its proper position (for example, set find_position.z to top of the unit, and set find_distance to a small number, if unit get shorter, then won't add waypoint)
				if is_add_waypoint and data.check_collision and type(data.check_collision) == "table" then
					is_add_waypoint = false
					local find_position = unit:position()
					if data.check_collision.position_offset and data.check_collision.position_offset.x and data.check_collision.position_offset.y and data.check_collision.position_offset.z then
						find_position = Vector3(unit:position().x + data.check_collision.position_offset.x, unit:position().y + data.check_collision.position_offset.y, unit:position().z + data.check_collision.position_offset.z)
					end
					local find_direction = data.check_collision.find_direction or Vector3(0, 0, 1)
					local find_distance = data.check_collision.find_distance or 1
					local bodies = World:find_bodies("intersect", "cylinder", find_position, find_direction, find_distance, managers.slot:get_mask("bullet_impact_targets"))
					for _, hit_body in pairs(bodies) do
						if hit_body:unit() and alive(hit_body:unit()) and hit_body:unit() == unit then
							is_add_waypoint = true
							break
						end
					end
				end

				-- check if there's any unit with given idstring or interaction around that unit
				if is_add_waypoint and data.with_units_around and type(data.with_units_around) == "table" then
					is_add_waypoint = false
					for _, find_data in pairs(data.with_units_around) do
						local found_units = World:find_units_quick("sphere", unit:position(), find_data.find_distance or 1, managers.slot:get_mask("all"))
						for _, found_unit in ipairs(found_units) do
							if found_unit and alive(found_unit) and (found_unit.name and tostring(found_unit:name()) == tostring(find_data.idstring)) or (found_unit.interaction and found_unit:interaction() and found_unit:interaction().tweak_data == find_data.interaction) then
								if find_data.force then
									is_add_waypoint = true
									break
								elseif not find_data.force and found_unit.interaction and found_unit:interaction() then
									for _, interactive_unit in pairs(managers.interaction._interactive_units or {}) do
										if found_unit == interactive_unit then
											is_add_waypoint = true
											break
										end
									end
									if is_add_waypoint then
										break
									end
								elseif not found_unit.interaction or not found_unit:interaction() then
									is_add_waypoint = true
								end
							end
						end
					end
				end

				-- check if there's any unit with given idstring or interaction exist in the map
				if is_add_waypoint and data.with_units_exist and type(data.with_units_exist) == "table" then
					is_add_waypoint = false
					for _, find_data in pairs(data.with_units_exist) do
						local filter_world_units = managers.slot:get_mask("all")
						for _, found_unit in pairs(World:find_units_quick("all", filter_world_units) or {}) do
							if found_unit and alive(found_unit) and (found_unit.name and tostring(found_unit:name()) == tostring(find_data.idstring)) or (found_unit.interaction and found_unit:interaction() and found_unit:interaction().tweak_data == find_data.interaction) then
								if find_data.force then
									is_add_waypoint = true
									break
								elseif not find_data.force and found_unit.interaction and found_unit:interaction() then
									for _, interactive_unit in pairs(managers.interaction._interactive_units or {}) do
										if found_unit == interactive_unit then
											is_add_waypoint = true
											break
										end
									end
									if is_add_waypoint then
										break
									end
								elseif not found_unit.interaction or not found_unit:interaction() then
									is_add_waypoint = true
								end
							end
						end
					end
				end

				-- check if there's check_function for this unit, this normally use mission elements, and basically host only
				if is_add_waypoint and data.check_function then
					is_add_waypoint = data.check_function(unit)
				end

				if is_add_waypoint and unit.id and unit:id() then
					local waypoint_name = tostring(unit:id())
					if unit:id() == -1 then waypoint_name = tostring(unit:position()) end
					waypoint_name_list[waypoint_name] = true
					add_waypoint(unit:position(), waypoint_name, data.icon, data.color, data.show_distance)
				end
			end
		end
	end

	return waypoint_name_list
end

local function add_waypoint_to_important_items(unit_list)
	local level_id = Global.level_data and Global.level_data.level_id
	return check_and_add_waypoint((type(unit_list) == 'table' and next(unit_list) and unit_list) or World:find_units_quick("all", 1), important_item_idstrings and important_item_idstrings[level_id])
end

local function add_waypoint_to_big_loots(unit_list)
	-- change format
	local big_loot_list = {}
	local level_id = Global.level_data and Global.level_data.level_id
	for data_id, data in pairs(common_big_loot_idstrings or {}) do
		if data and type(data) == "table" and data_id ~= "invalid_location_per_heist" and data_id ~= "invalid_interaction_per_heist" then
			local is_interaction_allowed = true
			if common_big_loot_idstrings.invalid_interaction_per_heist and common_big_loot_idstrings.invalid_interaction_per_heist[level_id] then
				for _, invalid_interaction in pairs(common_big_loot_idstrings.invalid_interaction_per_heist[level_id]) do
					if data.interaction == invalid_interaction then
						is_interaction_allowed = false
						break
					end
				end
			end
			if common_big_loot_idstrings.invalid_location_per_heist and common_big_loot_idstrings.invalid_location_per_heist[level_id] then
				local invalid_location_list = {}
				for _, invalid_location in pairs(common_big_loot_idstrings.invalid_location_per_heist[level_id]) do
					table.insert(invalid_location_list, invalid_location)
				end
				data.invalid_location_list = invalid_location_list
			end
			if is_interaction_allowed then
				table.insert(big_loot_list, data)
			end
		end
	end
	return check_and_add_waypoint((type(unit_list) == 'table' and next(unit_list) and unit_list) or managers and managers.interaction and managers.interaction._interactive_units, big_loot_list)
end

local function add_waypoint_to_small_loots(unit_list)
	-- change format
	local small_loot_list = {}
	local level_id = Global.level_data and Global.level_data.level_id
	for data_id, data in pairs(common_small_loot_idstrings or {}) do
		if data and type(data) == "table" and data_id ~= "invalid_location_per_heist" and data_id ~= "invalid_interaction_per_heist" then
			local is_interaction_allowed = true
			if common_small_loot_idstrings.invalid_interaction_per_heist and common_small_loot_idstrings.invalid_interaction_per_heist[level_id] then
				for _, invalid_interaction in pairs(common_small_loot_idstrings.invalid_interaction_per_heist[level_id]) do
					if data.interaction == invalid_interaction then
						is_interaction_allowed = false
						break
					end
				end
			end
			if common_small_loot_idstrings.invalid_location_per_heist and common_small_loot_idstrings.invalid_location_per_heist[level_id] then
				local invalid_location_list = {}
				for _, invalid_location in pairs(common_small_loot_idstrings.invalid_location_per_heist[level_id]) do
					table.insert(invalid_location_list, invalid_location)
				end
				data.invalid_location_list = invalid_location_list
			end
			if is_interaction_allowed then
				table.insert(small_loot_list, data)
			end
		end
	end
	return check_and_add_waypoint((type(unit_list) == 'table' and next(unit_list) and unit_list) or managers and managers.interaction and managers.interaction._interactive_units, small_loot_list)
end

local function add_waypoint_to_collections(unit_list)
	-- change format
	local level_id = Global.level_data and Global.level_data.level_id
	local collection_list = {}
	for _, data in pairs(collection_idstrings and collection_idstrings["common"] or {}) do table.insert(collection_list, data) end
	for _, data in pairs(collection_idstrings and collection_idstrings[level_id] or {}) do table.insert(collection_list, data) end
	return check_and_add_waypoint((type(unit_list) == 'table' and next(unit_list) and unit_list) or World:find_units_quick("all",1 ,20), collection_list)
end


global_waypoint_cache = global_waypoint_cache or {}
global_markenemies_nextlist_idx = global_markenemies_nextlist_idx or nil

local function items_waypoint_remove()
	for waypoint_name, _ in pairs(global_waypoint_cache or {}) do
		remove_waypoint(waypoint_name)
	end
	global_waypoint_cache = {}
end

local function show_next_items_waypoint(list_idx)
	if global_markenemies_nextlist_idx == nil or global_markenemies_nextlist_idx >= 5 then
		global_markenemies_nextlist_idx = 1
	end
	if list_idx then
		global_markenemies_nextlist_idx = list_idx
	end

	if global_markenemies_nextlist_idx == 1 then
		items_waypoint_remove(global_waypoint_cache)
		global_waypoint_cache = add_waypoint_to_important_items()
		if next(global_waypoint_cache) == nil then -- no mission items, show next list instead
			global_markenemies_nextlist_idx = global_markenemies_nextlist_idx + 1
		else
			managers.mission._fading_debug_output:script().log("Show Mission Items Waypoint",  Color.green)
		end
	end

	if global_markenemies_nextlist_idx == 2 then
		items_waypoint_remove(global_waypoint_cache)
		global_waypoint_cache = add_waypoint_to_big_loots()
		if next(global_waypoint_cache) == nil then -- no big loots, show next list instead
			global_markenemies_nextlist_idx = global_markenemies_nextlist_idx + 1
		else
			managers.mission._fading_debug_output:script().log("Show Big Loots Waypoint",  Color.green)
		end
	end

	if global_markenemies_nextlist_idx == 3 then
		items_waypoint_remove(global_waypoint_cache)
		global_waypoint_cache = add_waypoint_to_small_loots()
		if next(global_waypoint_cache) == nil then -- no small loots, show next list instead
			global_markenemies_nextlist_idx = global_markenemies_nextlist_idx + 1
		else
			managers.mission._fading_debug_output:script().log("Show Small Loots Waypoint",  Color.green)
		end
	end

	if not list_idx and global_markenemies_nextlist_idx == 4 then
		items_waypoint_remove(global_waypoint_cache)
		global_waypoint_cache = add_waypoint_to_collections()
		if next(global_waypoint_cache) == nil then -- no collections, show next list instead
			if not list_idx then
				show_next_items_waypoint(1) -- the last list don't have next list, so try to start from the beginning
			end
		else
			managers.mission._fading_debug_output:script().log("Show Collections Waypoint",  Color.green)
		end
	end

	if not list_idx then
		global_markenemies_nextlist_idx = global_markenemies_nextlist_idx +1
	end
end

local function determine_waypoint(unit_list)
	local new_waypoint = {}
	if (global_markenemies_nextlist_idx - 1) == 1 then
		if unit_list then
			new_waypoint = add_waypoint_to_important_items(unit_list)
		else
			items_waypoint_remove(global_waypoint_cache)
			global_waypoint_cache = add_waypoint_to_important_items()
		end
	elseif (global_markenemies_nextlist_idx - 1) == 2 then
		if unit_list then
			new_waypoint = add_waypoint_to_big_loots(unit_list)
		else
			items_waypoint_remove(global_waypoint_cache)
			global_waypoint_cache = add_waypoint_to_big_loots()
		end
	elseif (global_markenemies_nextlist_idx - 1) == 3 then
		if unit_list then
			new_waypoint = add_waypoint_to_small_loots(unit_list)
		else
			items_waypoint_remove(global_waypoint_cache)
			global_waypoint_cache = add_waypoint_to_small_loots()
		end
	elseif (global_markenemies_nextlist_idx - 1) == 4 then
		if unit_list then
			new_waypoint = add_waypoint_to_collections(unit_list)
		else
			items_waypoint_remove(global_waypoint_cache)
			global_waypoint_cache = add_waypoint_to_collections()
		end
	end

	for key, value in pairs(new_waypoint) do
		if global_waypoint_cache[key] then
			remove_waypoint(key)
		end
		global_waypoint_cache[key] = value
	end
end

if ObjectInteractionManager then
	-- add waypoint after creating new interactive unit, such as unit spawn after deposit opened
	Hooks:PostHook(ObjectInteractionManager, "add_unit", "add_waypoint", function(self, unit, ...)
		if global_markenemies_toggle then
			local unit_list = { unit }
			determine_waypoint(unit_list)
		end
	end)

	-- remove waypoint after interact
	Hooks:PreHook(ObjectInteractionManager, "remove_unit", "remove_waypoint", function(self, unit, ...)
		if global_markenemies_toggle then
			if unit and alive(unit) and unit.id and global_waypoint_cache[tostring(unit:id())] then
				remove_waypoint(tostring(unit:id()))
			end
		end
	end)
end




-- draw box for all interactive units
local interactive_units_not_draw_list = {"corpse_dispose","intimidate","requires_cable_ties","hostage_convert","hostage_move","hostage_stay","hostage_trade"}
local function auto_draw_interactions_box()
	if not draw_interactions_box then return end
	DelayedCalls:Add("auto_draw_interactions_box", 0.02, function()
		if global_markenemies_toggle then
			local player_unit = managers and managers.player and managers.player:player_unit()
			for _, unit in pairs(managers.interaction._interactive_units or {}) do
				local interaction = unit and alive(unit) and unit.interaction and unit:interaction()
				if player_unit and alive(player_unit) and interaction and interaction.can_interact and interaction:can_interact(player_unit) and interaction.tweak_data then
					local is_draw = true
					for _, tweak in pairs(interactive_units_not_draw_list or {}) do
						if interaction.tweak_data == tweak then
							is_draw = false
						end
					end
					if is_draw then
						Application:draw(unit, 1,1,1)
					end
				end
			end
			auto_draw_interactions_box()
		end
	end)
end




-- refresh units' mark every 2 seconds
local function auto_mark_units(run_now) -- run_now: begin first execution immediately
	DelayedCalls:Add("auto_mark_units", run_now and 0.01 or 2, function()
		if global_markenemies_toggle then
			if managers.groupai:state():whisper_mode() then
				mark_all_units_remove()
				mark_all_units(false)
			else
				mark_all_units_remove()
				mark_all_units(true)
				mark_special_units_in_fov()
			end
			auto_mark_units()
		end
	end)
end

local function auto_mark_all()
	if global_markenemies_toggle then
		auto_mark_units(true)
		auto_draw_interactions_box()
		show_next_items_waypoint()
		managers.mission._fading_debug_output:script().log("Auto Mark All",  Color.green)
	else
		mark_all_units_remove()
		items_waypoint_remove()
		managers.mission._fading_debug_output:script().log("Stop Auto Mark",  Color.red)
	end
end




auto_mark_all()
