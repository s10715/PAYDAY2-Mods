local is_hook = false
if RequiredScript == "lib/managers/dialogmanager" then
	is_hook = true
end


local function toggle_autocook()
	global_autocook_toggle = not global_autocook_toggle

	if global_autocook_toggle then
		if managers and managers.mission then managers.mission._fading_debug_output:script().log('Auto Cook - Activated',  Color.green) end
	else
		if managers and managers.mission then managers.mission._fading_debug_output:script().log('Auto Cook - Deactivated',  Color.red) end
	end
end

local function drop_bag_at_position(position)
	if not position then return end
	if managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) then
		local forward = Vector3(0, 0, 0) -- managers.player:player_unit():camera():forward()
		local rotation = Rotation(math.random(-180,180), math.random(-180,180), 0)
		local throw_force = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0)
		local carry_data = managers.player:get_my_carry_data()
		if carry_data then
			if Network:is_client() then
				managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, throw_force, nil)
			else
				managers.player:server_drop_carry(carry_data.carry_id,carry_data.multiplier, carry_data.dye_initiated,carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, throw_force, nil, managers.network:session():local_peer())
			end
			managers.player:clear_carry()
			managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
			managers.hud:temp_hide_carry_bag()
			managers.player:update_removed_synced_carry_to_peers()
		end
	end
end




if Global.game_settings and ( Global.game_settings.level_id == "rat" or Global.game_settings.level_id == "alex_1" or Global.game_settings.level_id == "mex_cooking" ) then
	if RequiredScript == "lib/managers/dialogmanager" then
		Hooks:PostHook(DialogManager, "queue_dialog", "Auto_Cook_add_chemical", function(self, id, ...)
			if not global_autocook_toggle then return end

			local needed_chem = {
				pln_rt1_20 = "methlab_bubbling", pln_rt1_22 = "methlab_caustic_cooler", pln_rt1_24 = "methlab_gas_to_salt",
				Play_loc_mex_cook_03="methlab_bubbling", Play_loc_mex_cook_04="methlab_caustic_cooler", Play_loc_mex_cook_05="methlab_gas_to_salt",
				pln_rat_stage1_20 = "methlab_bubbling", pln_rat_stage1_22="methlab_caustic_cooler", pln_rat_stage1_24="methlab_gas_to_salt",
			}

			-- auto cook
			local chemical = needed_chem[id]
			if chemical and managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) then
				for _, unit in pairs(managers.interaction._interactive_units) do
					local interaction = unit and alive(unit) and unit.interaction and unit.interaction(unit)
					if interaction and interaction.tweak_data == chemical then
						interaction.can_interact = function() return true end
						interaction:interact(managers.player:player_unit())
						interaction.can_interact = nil
						managers.mission._fading_debug_output:script().log('Add ' .. chemical ,  Color.yellow)
						return
					end
				end
			end
		end)
	end

	if is_hook then return end
	local function bag_meth_and_keep_light_and_flare()
		DelayedCalls:Add("keep_bag_light_and_flare", 2, function()
			if not global_autocook_toggle then
				return
			end
			for _, unit in pairs(managers.interaction._interactive_units) do
				local interaction = unit and alive(unit) and unit.interaction and unit.interaction(unit)
				if managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and interaction and interaction.tweak_data == "taking_meth" and not managers.player:is_carrying() then
					managers.mission._fading_debug_output:script().log('Bag Meth',  Color.yellow)
					interaction:interact(managers.player:player_unit())
					local heist = Global.level_data and Global.level_data.level_id
					local position = interaction:interact_position()
					local spawn_meth_pos = Vector3(position.x + (heist == "alex_1" and -50 or 0), position.y, position.z + 10)
					drop_bag_at_position(spawn_meth_pos)
				end
				if managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and interaction and interaction.tweak_data == "circuit_breaker" then
					interaction:interact(managers.player:player_unit())
					managers.mission._fading_debug_output:script().log('Turn Light On',  Color.yellow)
				end
				if managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and interaction and interaction.tweak_data == "place_flare" then
					interaction:interact(managers.player:player_unit())
					managers.mission._fading_debug_output:script().log('Place Flare' ,  Color.yellow)
				end
			end
			bag_meth_and_keep_light_and_flare()
		end)
	end
	toggle_autocook()
	bag_meth_and_keep_light_and_flare()

elseif Global.game_settings and Global.game_settings.level_id == "nail" then -- for Lab Rats
	local lab_rat_chem = {
		["pku_pills"] = {
			["bag_id"] = "nail_euphadrine_pills",
			["position"] = Vector3(1320, -52, 0),
		},
		["taking_meth_huge"] = {
			["bag_id"] = "meth_half",
			["position"] = Vector3(1320, -52, 0),
			["position2"] = Vector3(-11135, 1348, -2800),
		},
		["pln_rt1_20"] = {
			["bag_id"] = "nail_muriatic_acid",
			["position"] = Vector3(868.6, -754.2, 1578.6),
		},
		["pln_rt1_22"] = {
			["bag_id"] = "nail_caustic_soda",
			["position"] = Vector3(-4116.9, 580.7, 1456.8),
		},
		["pln_rt1_24"] = {
			["bag_id"] = "nail_hydrogen_chloride",
			["position"] = Vector3(-5638.2, -821.3, 1213),
		},
		["pln_rat_stage1_20"] = {
			["bag_id"] = "nail_muriatic_acid",
			["position"] = Vector3(868.6, -754.2, 1578.6),
		},
		["pln_rat_stage1_22"] = {
			["bag_id"] = "nail_caustic_soda",
			["position"] = Vector3(-4116.9, 580.7, 1456.8),
		},
		["pln_rat_stage1_24"] = {
			["bag_id"] = "nail_hydrogen_chloride",
			["position"] = Vector3(-5638.2, -821.3, 1213),
		},
	}

	if RequiredScript == "lib/managers/dialogmanager" then
		Hooks:PostHook(DialogManager, "queue_dialog", "Auto_Cook_add_chemical_bag", function(self, id, ...)
			if not global_autocook_toggle then return end

			-- auto cook
			local chemical_information = lab_rat_chem[id]
			if chemical_information and managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) then
				local player_carry_data = managers.player:get_my_carry_data()
				if player_carry_data and player_carry_data.carry_id == chemical_information["bag_id"] then
					drop_bag_at_position(chemical_information["position"])
					managers.mission._fading_debug_output:script().log("Add Chemical ".. chemical_information["bag_id"],  Color.yellow)
				else
					if managers.player:is_carrying() then
						managers.player:drop_carry()
					end
					for _, unit in pairs(managers.interaction._interactive_units) do
						local interaction = unit and alive(unit) and unit.interaction and unit:interaction()
						if interaction and unit:carry_data() and unit:carry_data().carry_id and unit:carry_data():carry_id() == chemical_information["bag_id"] and not managers.player:is_carrying() then
							interaction:interact(managers.player:player_unit())
							managers.mission._fading_debug_output:script().log('Get Chemical ' .. chemical_information["bag_id"] ,  Color.yellow)
							DelayedCalls:Add("add_chemical", 0.5, function()
								drop_bag_at_position(chemical_information["position"])
								managers.mission._fading_debug_output:script().log("Add Chemical ".. chemical_information["bag_id"],  Color.yellow)
							end)
							return
						end
					end
				end
			end
		end)
	end

	if is_hook then return end

	-- find bag or interaction to get bag with specific id, find zipline with specific position and then drop bag at zipline, if no zipline then drop bag at secure area with specific position
	local function find_and_drop_bag_at_zipline(interaction_tweak_data, bag_carry_id, zipline_position, secure_position)
		if not managers.player or not managers.player:player_unit() or not alive(managers.player:player_unit()) then return end

		local have_zipline = false
		for _, unit in pairs(managers.interaction._interactive_units) do
			local interaction = unit and alive(unit) and unit.interaction and unit:interaction()
			if interaction and interaction._active and unit:position() == zipline_position then
				have_zipline = true
			end
		end

		for _, unit in pairs(managers.interaction._interactive_units) do
			local interaction = unit and alive(unit) and unit.interaction and unit:interaction()
			if interaction and interaction.tweak_data == interaction_tweak_data then
				-- found interaction to get bag
				if managers.player:is_carrying() and managers.player:get_my_carry_data() and managers.player:get_my_carry_data().carry_id ~= bag_carry_id then
					managers.player:drop_carry()
				end
				if not managers.player:is_carrying() then
					interaction:interact(managers.player:player_unit())
				end
				break
			elseif interaction and unit:carry_data() and unit:carry_data().carry_id and unit:carry_data():carry_id() == bag_carry_id then
				-- found bag with specify id
				if managers.player:is_carrying() and managers.player:get_my_carry_data() and managers.player:get_my_carry_data().carry_id ~= bag_carry_id then
					managers.player:drop_carry()
				end
				if not managers.player:is_carrying() then
					interaction:interact(managers.player:player_unit())
				end
				break
			end
		end

		if managers.player:is_carrying() and managers.player:get_my_carry_data() and managers.player:get_my_carry_data().carry_id == bag_carry_id then
			if have_zipline then
				DelayedCalls:Add("interact_zipline_" .. bag_carry_id, 0.5, function()
					if managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and managers.player:get_my_carry_data() and managers.player:get_my_carry_data().carry_id == bag_carry_id then
						for _, unit in pairs(managers.interaction._interactive_units) do
							local interaction = unit and alive(unit) and unit.interaction and unit:interaction()
							if interaction and interaction._active and unit:position() == zipline_position and managers.player:get_my_carry_data() and managers.player:get_my_carry_data().carry_id == bag_carry_id then
								-- found zipline through it's position, and player is carrying bag with specify id, then drop bag at this zipline
								interaction:interact(managers.player:player_unit())
								managers.mission._fading_debug_output:script().log("Zipline " .. bag_carry_id,  Color.yellow)
								break
							end
						end
					end
				end)
				return true
			elseif not have_zipline and secure_position and managers.player:get_my_carry_data() and managers.player:get_my_carry_data().carry_id == bag_carry_id then
				drop_bag_at_position(secure_position)
			end
		end
	end

	-- smash meth
	local function smash_unit(unit, dmg, make_effect)
		if not unit or not alive(unit) then return end
		if not managers or not managers.player or not managers.player:player_unit() then return end

		for i = 0, unit:num_bodies() do
			local body = unit:body(i)
			if (body and body:enabled()) and (body:unit():id() ~= -1) then
				local player_unit = managers.player:player_unit()
				local damage = dmg or tweak_data.weapon.trip_mines.damage * managers.player:upgrade_value("trip_mine", "damage_multiplier", 1)
				local normal = body:center_of_mass()
				local body_position = body:position()
				local dir = Vector3(0, 0, 0)
				mvector3.direction(dir, body_position, normal)
				if body:extension() and body:extension().damage and body:extension().damage.damage_explosion and body:extension().damage.damage_damage then
					body:extension().damage:damage_explosion(player_unit, normal, body_position, dir, damage)
					body:extension().damage:damage_damage(player_unit, normal, body_position, dir, damage)
					if body:unit():id() ~= -1 and managers.network:session() then
						if alive(player_unit) then
							managers.network:session():send_to_peers_synched("sync_body_damage_explosion", body, player_unit, normal, body_position, dir, damage)
						else
							managers.network:session():send_to_peers_synched("sync_body_damage_explosion_no_attacker", body, normal, body_position, dir, damage)
						end
					end
					if body:unit():in_slot(managers.game_play_central._slotmask_physics_push) then
						body:unit():push(5, dir * 500)
					end
					if make_effect then
						World:effect_manager():spawn({ effect = Idstring("effects/particles/explosions/explosion_grenade"), position = body_position, normal = normal })
						local sound_source = SoundDevice:create_source("TripMineBase")
						sound_source:set_position(body_position)
						sound_source:post_event("trip_mine_explode")
					end
				end
			end
		end
	end

	local function check_pills_and_meth_interaction(delay_time)
		DelayedCalls:Add("check_pills_and_meth_interaction", delay_time or 5, function()
			if not global_autocook_toggle then
				return
			end

			-- if you need to zipline another bag, you need to wait for the last bag finish, or it will take the last bag down and always zipline the final bag
			local timer = managers.game_play_central and math.abs(managers.game_play_central:get_heist_timer()) or TimerManager:game():time()
			if timer < 15 then
				check_pills_and_meth_interaction(1) -- wait till the door open to prevent getting too many pills
				return
			elseif find_and_drop_bag_at_zipline("pku_pills", lab_rat_chem["pku_pills"]["bag_id"], lab_rat_chem["pku_pills"]["position"]) then
				check_pills_and_meth_interaction(10) -- wait for a long time to prevent getting too many pills
				return
			elseif find_and_drop_bag_at_zipline("taking_meth_huge", lab_rat_chem["taking_meth_huge"]["bag_id"], lab_rat_chem["taking_meth_huge"]["position"], lab_rat_chem["taking_meth_huge"]["position2"]) then
				check_pills_and_meth_interaction() -- zip meth
				return
			else
				check_pills_and_meth_interaction() -- didn't zip any bag, run next round normally
			end
		end)
	end

	local function check_smash_meth_block(delay_time)
		DelayedCalls:Add("check_smash_meth_block", delay_time or 5, function()
			if not global_autocook_toggle then
				return
			end

			local meth_blocks = { -- all blocks use same position, so have to set position manually
				Idstring("units/pd2_dlc_nails/props/nls_prop_methlab_meth/nls_prop_methlab_meth"),
				Idstring("units/pd2_dlc_nails/props/nls_prop_methlab_meth/nls_prop_methlab_meth_a"),
				Idstring("units/pd2_dlc_nails/props/nls_prop_methlab_meth/nls_prop_methlab_meth_b"),
				Idstring("units/pd2_dlc_nails/props/nls_prop_methlab_meth/nls_prop_methlab_meth_c"),
				Idstring("units/pd2_dlc_nails/props/nls_prop_methlab_meth/nls_prop_methlab_meth_d"),
			}
			local is_smashed = false
			for _, unit in pairs(World:find_units_quick("all", 1)) do
				for _, idstring in pairs(meth_blocks or {}) do
					if unit and alive(unit) and unit.name and unit:name() and unit:name() == idstring then
						-- check if unit really exist, there're fake units after meth block generate first time
						local is_unit_really_exist = false
						for i = 0, unit:num_bodies() do
							local body = unit:body(i)
							if (body and body:enabled()) and (body:unit():id() ~= -1) then
								is_unit_really_exist = true
								break
							end
						end
						if is_unit_really_exist then
							smash_unit(unit, 1000, false)
							is_smashed = true
						end
					end
				end
			end
			if is_smashed then
				managers.mission._fading_debug_output:script().log("Smash Meth",  Color.yellow)
			end

			check_smash_meth_block()
		end)
	end
	toggle_autocook()
	check_pills_and_meth_interaction(0.1)
	check_smash_meth_block(0.1)

elseif Global.game_settings and ( Global.game_settings.level_id == "crojob2" or Global.game_settings.level_id == "mia_1" ) and managers.interaction then -- for The Bomb: Dockyard and Hotline Miami
	if is_hook then return end
	local function check_and_cook_next()
		DelayedCalls:Add("check_and_cook_next", 2, function()
			if not global_autocook_toggle then
				return
			end
			global_current_cooking_phase = global_current_cooking_phase or 1
			local interactions = {'methlab_bubbling', 'methlab_caustic_cooler', 'methlab_gas_to_salt', "taking_meth"}
			for _, unit in pairs(managers.interaction._interactive_units) do
				local interaction = unit and alive(unit) and unit.interaction and unit.interaction(unit)
				if managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and interaction and interaction.tweak_data == interactions[global_current_cooking_phase] then
					if global_current_cooking_phase < 4 then
						managers.mission._fading_debug_output:script().log('Add Chemical: step ' .. tostring(global_current_cooking_phase),  Color.yellow)
						interaction.can_interact = function() return true end
						interaction:interact(managers.player:player_unit())
						interaction.can_interact = nil
						global_current_cooking_phase = global_current_cooking_phase + 1
					elseif global_current_cooking_phase == 4 and not managers.player:is_carrying() then
						managers.mission._fading_debug_output:script().log('Bag Meth',  Color.yellow)
						interaction:interact(managers.player:player_unit())
						local position = interaction:interact_position()
						local spawn_meth_pos = Vector3(position.x, position.y, position.z + 10)
						drop_bag_at_position(spawn_meth_pos)
						global_current_cooking_phase = 1
					end
					break
				end
			end
			check_and_cook_next()
		end)
	end
	toggle_autocook()
	check_and_cook_next()

elseif Global.game_settings and Global.game_settings.level_id == "pal" then -- for Counterfeit
	if is_hook then return end
	local function check_make_counterfeit()
		DelayedCalls:Add("check_and_cook_next", 2, function()
			if not global_autocook_toggle then
				return
			end
			for _, unit in pairs(managers.interaction._interactive_units) do
				local interaction = unit and alive(unit) and unit.interaction and unit:interaction()
				if managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and interaction then
					local player_unit = managers.player:player_unit()
					if interaction.tweak_data == "hold_insert_paper_roll" or interaction.tweak_data == "hold_insert_printer_ink" or interaction.tweak_data == "hold_start_printer" then
						interaction.can_interact = function() return true end
						interaction:interact(player_unit)
						interaction.can_interact = nil
						managers.mission._fading_debug_output:script().log("Print Counterfeit: step " .. tostring(interaction.tweak_data),  Color.yellow)
					elseif interaction.tweak_data == "hold_take_counterfeit_money" and not managers.player:is_carrying() then
						interaction:interact(player_unit)
						local position = interaction:interact_position()
						local spawn_counterfeit_pos = Vector3(position.x, position.y, position.z + 10)
						drop_bag_at_position(spawn_counterfeit_pos)
						managers.mission._fading_debug_output:script().log("Bag Counterfeit Money",  Color.yellow)
					elseif interaction.tweak_data == "press_plates" then
						interaction:interact(player_unit)
						managers.mission._fading_debug_output:script().log("Get Plates",  Color.yellow)
					elseif interaction.tweak_data == "hold_insert_plates" and interaction.can_interact and interaction:can_interact(player_unit) then
						interaction:interact(player_unit)
						managers.mission._fading_debug_output:script().log("Insert Plates",  Color.yellow)
					elseif interaction.tweak_data == "water_manhole" or interaction.tweak_data == "water_tap" then
						interaction:interact(player_unit)
						managers.mission._fading_debug_output:script().log("Fix Water Supply",  Color.yellow)
					elseif interaction.tweak_data == "circuit_breaker" or interaction.tweak_data == "transformer_box" then
						interaction:interact(player_unit)
						managers.mission._fading_debug_output:script().log("Fix Power",  Color.yellow)
					end
				end
			end
			check_make_counterfeit()
		end)
	end
	toggle_autocook()
	check_make_counterfeit()

elseif Global.game_settings and ( Global.game_settings.level_id == "cane" or Global.game_settings.level_id == "glace" or Global.game_settings.level_id == "run" or Global.game_settings.level_id == "pines" or Global.game_settings.level_id == "rvd1" or Global.game_settings.level_id == "dah" or Global.game_settings.level_id == "man" or Global.game_settings.level_id == "born" ) then
	if is_hook then return end
	local npcs = {
		["cane"] = { -- Santa's Workshop
			["4b02693553a926c3"] = true, -- units/pd2_dlc_cane/characters/civ_male_helper_1/civ_male_helper_1
			["28f247256e821a74"] = true, -- units/pd2_dlc_cane/characters/civ_male_helper_2/civ_male_helper_2
			["23bb5d4857a1a16c"] = true, -- units/pd2_dlc_cane/characters/civ_male_helper_3/civ_male_helper_3
			["871dae12e3cddbd8"] = true, -- units/pd2_dlc_cane/characters/civ_male_helper_4/civ_male_helper_4
			["28ce9fc472f7c95b"] = true, -- units/pd2_dlc_cane/characters/civ_male_helper_1/civ_male_helper_1_husk
			["412db7e5db4b10f4"] = true, -- units/pd2_dlc_cane/characters/civ_male_helper_2/civ_male_helper_2_husk
			["a23a20a2098c4d3a"] = true, -- units/pd2_dlc_cane/characters/civ_male_helper_3/civ_male_helper_3_husk
			["478875e0fc7f7018"] = true, -- units/pd2_dlc_cane/characters/civ_male_helper_4/civ_male_helper_4_husk
		},
		["glace"] = { -- Green Bridge
			["05319df4b6ad1952"] = true,  -- Green Bridge, Kazuo, server side unit -- units/pd2_dlc_glace/characters/npc_yakuza_prisoner/npc_yakuza_prisoner
			["2310138d66c9e0ee"] = true,  -- Green Bridge, Kazuo, client side unit -- units/pd2_dlc_glace/characters/npc_yakuza_prisoner/npc_yakuza_prisoner_husk
		},
		["run"] = { -- Heat Street
			["78964c9af5f85f95"] = true,  -- Heat Street, Matt, server side unit -- units/pd2_dlc_run/characters/npc_matt/npc_matt
			["02b8586ee6123a7c"] = true,  -- Heat Street, Matt, client side unit -- units/pd2_dlc_run/characters/npc_matt/npc_matt_husk
		},
		["pines"] = { -- White Xmas
			["69f8defd593bd56e"] = true, -- units/payday2/characters/civ_male_pilot_1/civ_male_pilot_1
			["2b8ffd738c10f23b"] = true, -- units/payday2/characters/civ_male_pilot_1/civ_male_pilot_1_husk
		},
		["rvd1"] = { -- Reservoir Dogs Heist, day 1
			["2694ba851e9d4490"] = true, -- units/pd2_dlc_rvd/characters/npc_mr_pink/npc_mr_pink
			["2aa4d47b959e4222"] = true, -- units/pd2_dlc_rvd/characters/npc_mr_pink/npc_mr_pink_husk
		},
		["dah"] = { -- Diamond Heist
			["2a50feaaf7cea171"] = true, -- units/pd2_dlc_dah/characters/npc_male_cfo/npc_male_cfo
			["6ff42a39a4cc1529"] = true, -- units/pd2_dlc_dah/characters/npc_male_cfo/npc_male_cfo_husk
		},
		["man"] = { -- Undercover
			["7ffb4d20c548a661"] = true, -- units/payday2/characters/civ_male_taxman/civ_male_taxman
			["790604edbce23e14"] = true, -- units/payday2/characters/civ_male_taxman/civ_male_taxman_husk
		},
		["born"] = { -- The Biker Heist, day 1
			["0bc5d8fea12e0c88"] = true, -- units/pd2_dlc_born/characters/npc_male_mechanic/npc_male_mechanic
			["38b1229d31403ced"] = true, -- units/pd2_dlc_born/characters/npc_male_mechanic/npc_male_mechanic_husk
		},
	}

	local function check_shout_and_bag()
		DelayedCalls:Add("check_shout_and_bag", 3, function()
			if not global_autocook_toggle then
				return
			end

			local local_player = managers.player and managers.player:local_player()
			local level_id = Global.game_settings.level_id
			if not local_player or not level_id then return end

			-- kill enemies around the elves or npcs, and shout elves or npcs
			for _,unit in pairs(World:find_units_quick("all", 21)) do
				if unit and alive(unit) and unit.name and unit:name().key and npcs[level_id][unit:name():key()] and unit.character_damage and unit:character_damage() and unit.anim_data and not unit:anim_data().unintimidateable then
					-- kill enemies around
					local is_kill_enemies = false
					local is_burn_enemies = false
					for _,enemy_data in pairs(managers.enemy:all_enemies()) do
						if enemy_data and enemy_data.unit and enemy_data.unit:character_damage() then
							local dist = mvector3.distance(enemy_data.unit:position(), unit:position())
							if dist <= 500 then
								enemy_data.unit:character_damage():damage_melee({
									damage = math.huge,
									damage_effect = enemy_data.unit:character_damage()._HEALTH_INIT * 2,
									attacker_unit = local_player,
									attack_dir = Vector3(0,0,0),
									name_id = 'rambo',
									col_ray = {
										position = enemy_data.unit:position(),
										body = enemy_data.unit:body( "body" ),
									}
								})
								is_kill_enemies = true
							end
							if dist < 1000 then
								local weapon_unit = local_player:inventory():equipped_unit()
								local weapon_id = nil
								if weapon_unit then
									local base_ext = weapon_unit:base()
									weapon_id = base_ext and base_ext.get_name_id and base_ext:get_name_id()
								end
								local fire_data = {
									unit = enemy_data.unit,
									dot_data = tweak_data.dot:get_dot_data("ammo_flamethrower_mk2_rare"),
									weapon_id = weapon_id,
									weapon_unit = weapon_unit,
									attacker_unit = local_player
								}
								managers.fire:add_doted_enemy(fire_data)
								is_burn_enemies = true
							end
						end
					end
					if is_kill_enemies then
						managers.mission._fading_debug_output:script().log('Kill enemies',  Color.yellow)
					end
					if is_burn_enemies then
						managers.mission._fading_debug_output:script().log('Burn enemies',  Color.yellow)
					end

					-- shout
					if local_player and alive(local_player) then
						if Network:is_client() then
							unit:character_damage():damage_melee({
								damage = 0.1,
								attacker_unit = local_player,
								attack_dir = Vector3(0,0,0),
								variant = "melee",
								name_id = 'cqc',
								col_ray = {position = unit:position(), body = unit:body("body")}
							})
						else
							unit:brain():on_intimidated(tweak_data.player.long_dis_interaction.intimidate_strength or 0.5, local_player, true)
						end
						managers.mission._fading_debug_output:script().log('Shout',  Color.yellow)
					end
				end
			end

			if Global.game_settings and Global.game_settings.level_id == "cane" then
				-- auto bag presents, bag one by one, carry too many bags in short time might detect as cheater cause of lag
				for _,unit in pairs(managers.interaction._interactive_units) do
					local interaction = unit and alive(unit) and unit.interaction and unit.interaction(unit)
					if interaction and interaction.tweak_data == "hold_pku_present" and interaction._active and managers.player and not managers.player:is_carrying() then
						if local_player and alive(local_player) then
							managers.mission._fading_debug_output:script().log('Bag Meth',  Color.yellow)
							interaction:interact(local_player)
							local position = interaction:interact_position()
							local spawn_meth_pos = Vector3(position.x, position.y, position.z + 10)
							drop_bag_at_position(spawn_meth_pos)
							break
						end
					end
				end
			end
			check_shout_and_bag()
		end)
	end
	toggle_autocook()
	check_shout_and_bag()
end
