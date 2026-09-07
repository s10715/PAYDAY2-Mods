local drop_bags_one_by_one = true
local drop_bags_delay_period = 0.2

local is_pack_corpse = false

local special_equipments = {"pickup_keycard","pickup_keycard_axis","take_keys","stash_planks_pickup","gen_pku_saw","gen_pku_crowbar","hold_take_gas_can","gen_pku_thermite","gen_pku_thermite_paste","gen_pku_thermite_paste_z_axis","gen_pku_thermite_paste_not_deployable","gen_pku_blow_torch","drk_pku_blow_torch","hold_born_receive_item_blow_torch","pickup_harddrive","take_confidential_folder","hold_take_blueprints","take_confidential_folder_event","pickup_asset","press_printer_ink","press_printer_paper","sfm_take_usb_key","stash_server_pickup","muriatic_acid","caustic_soda","hydrogen_chloride","hold_pku_briefcase","pku_manifest","cas_take_sleeping_gas","pickup_hotel_room_keycard","ranc_hold_take_bugging_device","take_tape","ranc_take_acid","ranc_hold_take_stock","ranc_hold_take_receiver","ranc_hold_take_barrel","hold_take_medallion","press_to_interact","sand_take_note","sand_pickup_harddrive","mex_red_room_key","mex_red_room_key_directional","pent_take_wire","chas_pickup_keychain_forklift","press_c4_pku","pex_get_unloaded_card","pex_pickup_cutter","sand_take_usb","sand_take_gas_canister","corp_key_fob","chca_hold_take_business_card","hold_take_hand","fex_take_diesel","hold_take_vault_blueprint","uno_hold_pku_gold_bar"}
local doors = {"invisible_interaction_open","invisible_interaction_open_axis","invisible_interaction_open_axis_rvd","cas_open_door","cas_security_door","cas_open_securityroom_door","open_door_with_keys","atm_interaction","key","vit_keycard_use","use_hotel_room_key","open_door","hold_open_door","open_from_inside","trai_open_from_inside_main_wagon","open_slash_close_act","hold_open_lid","zipline_mount","hold_open","hold_open_case","cas_open_guitar_case","pex_pick_lock_easy_no_skill","hold_open_window","cut_fence","cut_glass","pent_window_cutting","mcm_break_planks","pick_lock_easy","pick_lock_easy_no_skill","pick_lock_hard","pick_lock_hard_no_skill","pick_lock_hard_no_skill_deactivated","fake_pick_lock_easy_no_skill","chas_pick_lock_easy_no_skill","pick_lock_x_axis","lockpick_locker","pick_lock_deposit_transport","grenade_briefcase","money_briefcase","weapon_case","weapon_case_axis_z","ranc_audio_case","crate_loot","crate_loot_crowbar","hold_open_vault","hold_open_vault_2s","open_train_cargo_door","man_trunk_picklock","timelock_panel","timelock_numpad","test_interactive_door","hold_open_the_safe","panic_room_key","dah_panicroom_keycard","mcm_panicroom_keycard","mcm_panicroom_keycard_2","hold_open_xmas_present","vit_remove_painting","gen_pku_warhead_box","hold_open_shopping_bag","trai_hold_picklock_toolsafe","mus_hold_open_display","ranc_break_wall","sand_open_slide_gate","corp_hud_hold_use_tag_reader","uno_open_door","press_use_lrm_safe_keycard"}
local ecm_doors = {"requires_ecm_jammer","requires_ecm_jammer_atm","requires_ecm_jammer_double"} -- this interact need ECM
local small_loots = {"safe_loot_pickup","diamond_pickup","diamond_pickup_pal","diamond_pickup_axis","tiara_pickup","press_take_folder","money_wrap_single_bundle","money_wrap_single_bundle_active","money_wrap_single_chas","mus_pku_artifact","cash_register","diamond_single_pickup_axis","take_pardons","pickup_tablet","pickup_phone","cas_chips_pile","gage_assignment"}
local big_loots = {"trai_printing_plates_carry","red_diamond_pickup","diamonds_pickup_full","diamonds_pickup","shape_charge_plantable","gen_pku_cocaine_pure","gen_pku_cocaine_directional","money_small","money_small_take","money_scanner","money_luggage","money_bag","money_wrap","money_wrap_axis","money_wrap_updating","money_wrap_updating_directional","money_wrap_active","hold_pku_drk_bomb_part","hold_take_server","weapon","ammo","take_ammo","disassemble_turret","pku_safe","painting","old_wine","ordinary_wine","drk_bomb_part","evidence_bag","coke","coke_pure","diamond_necklace","diamonds","artifact_statue","prototype","bry_pku_prototype","yayo","meth_half","samurai_armor","turret","roman_armor","samurai_suit","weapons","carry_drop","painting_carry_drop","safe_carry_drop","gen_pku_jewelry","taking_meth","taking_meth_huge","gen_pku_cocaine","take_weapons","take_weapons_axis_z","gold_pile","hold_take_painting","hold_take_tablet","invisible_interaction_open","gen_pku_artifact","gen_pku_artifact_statue","gen_pku_artifact_painting","gen_pku_warhead","hold_take_expensive_wine","hold_take_shoes","hold_take_diamond_necklace","hold_take_toy","hold_take_vr_headset","gen_pku_evidence_bag","gen_pku_evidence_bag_axis","hold_take_old_wine","pku_pig","mus_take_diamond","samurai_armor","hold_take_helmet","hold_pku_present","hold_born_take_bike_part","chas_tea_set","tag_take_unknown","des_take_unknown","cas_take_unknown","gen_pku_sandwich","pku_toothbrush","chas_pku_dragon_statue","hold_grab_goat","goat_carry_drop","gen_pku_fusion_reactor","hold_take_battery","hold_take_parachute","ranc_hold_place_stock","ranc_hold_place_receiver","ranc_hold_place_barrel","ranc_hold_construct_weapon","ranc_take_weapons","roman_armor","corp_hold_pku_paperpile_bag","bex_pku_treasure","bex_prop_faberge_egg","corpse_dispose"}
local drills_safe_in_stealth = {"hold_circle_cutter","gen_pku_circle_cutter","circle_cutter_jammed","pex_door_hydraulic_opener","pex_placment_breacher"}
local hacks_safe_in_stealth = {"corpse_alarm_pager","hospital_phone","answer_call","vit_search","vit_search_clues","vit_take_usb_key","cas_open_briefcase","trai_connect_locke_walkietalkie","trai_hold_access_console","hack_electric_box","hold_disable_alarm","trai_hold_disable_alarm","hold_place_gps_tracker","drk_hold_hack_computer","place_harddrive","hold_unlock_car","hold_search_c4","uload_database","hold_call_captain","invisible_interaction_open_axis_sah","hold_place_device","hold_type_in_password","hold_search_cart","hold_search_drawer","hold_search_shower","hold_search_cigar_boxes","hold_search_fridge","hold_search_drawers","hold_search_capsule","hold_search_luggage","hold_search_bookshelf","hold_hack_server_room","hold_turn_off","push_button_secret","sfm_laptop","mcm_laptop","push_button","hold_open_coke_bag","hold_remove_bug","hold_phone_call_office","big_computer_server","big_computer_hackable","fingerprint_scanner","enter_code","hold_relay_locke","tag_laptop","hacking_barrier","hold_turn_off_light","hold_cut_wires","hold_remove_cover","press_take_elevator","cas_take_gear","computer_blueprints","use_blueprints","send_blueprints","cas_take_usb_key","cas_copy_usb","cas_take_usb_key_data","cas_use_usb","take_bottle","pour_spiked_drink","cas_vent_gas","disable_lasers","pick_lock_easy_no_skill_pent","pent_pull_lever","sand_place_note","pent_kitchen_elevator","disarm_bomb","sand_hold_blow_torch","sand_open_handcuffs","pickup_evidence_pex","hold_override_pc","chca_hold_disable_firewall","pickup_asset_zaxis","corp_hold_unlock_controlbox","corp_hold_close_curtains","corp_hack_email","corp_download_email","corp_hold_phone_play_voice_message","corp_hold_voice_recorder_play"}
local shaped_sharges = {"shaped_sharge","shape_charge_plantable"} -- this interact need shaped charges
local drills_not_safe = {"apartment_saw","apartment_saw_jammed","drill","drill_upgrade","drill_jammed","hold_pickup_lance","lance","lance_upgrade","lance_jammed","gen_pku_lance_part","huge_lance","huge_lance_jammed","gen_int_saw","gen_pku_saw","c4","c4_x10","c4_bag","c4_consume","c4_mission_door","c4_x1_bag","cas_screw_down","cas_take_hook","brb_connect_winch_hook","cas_start_winch"}
local hacks_not_safe = {"born_plug_in_powercord","circuit_breaker","hold_hlm_open_circuibreaker","rewire_electric_box","place_flare","use_flare","gasoline","hold_attach_magnet","apply_thermite_paste","apply_thermite_paste_no_consume","hold_blow_torch","gen_prop_container_a_vault_seq","start_hacking","hold_hack_comp","security_station","security_station_keyboard","are_laptop","mcm_laptop_code","numpad","timelock_hack","hack_ipad","hack_ipad_jammed","hack_suburbia","hack_suburbia_jammed","hack_suburbia_outline","hack_suburbia_jammed","hack_suburbia_jammed_axis","hack_suburbia_jammed_y","votingmachine2","votingmachine2_jammed","crane_joystick_left","crane_joystick_release","connect_hose","generator_start","hold_move_crane","hold_search_dumpster","hold_release_hatch","bus_wall_phone","hold_wwh_untie","open_lid_wwh","connect_hose_wwh","connect_hose_pump_wwh","connect_hose_ship_wwh","hold_generator_start","hold_remove_rope","detach_hose_wwh","hold_move_gangplank","hold_moon_untie","hold_born_untie","hold_born_search_tools","open_slash_close_sec_box","hold_pull_switch","hold_pull_switch_distance","iphone_answer","use_computer","hold_use_computer","use_server_device","hack_trai_outline","hack_ship_control","hold_remove_debris","hold_activate_sprinklers","hold_turn_off_sprinklers","hospital_security_cable_red","hospital_security_cable_blue","hospital_security_cable_green","hospital_security_cable_yellow","hold_cut_cable","shelf_sliding_suburbia","pent_generator_start","uno_pull_lever","uno_press_activate","uno_mayan_gold_bar"}
local achievement_collection = {"pickup_case","pickup_keys","take_jfr_briefcase","press_pick_up","pick_up_item","trai_achievement_container_key","trai_achievement_container","trai_achievement_safe","press_pay_respects","halloween_trick","hold_take_missing_animal_poster", "hold_pick_up_turtle","glc_hold_take_handcuffs","ring_band","hold_take_mask","tag_take_stapler","ranc_press_pickup_horseshoe","ranc_take_mould","ranc_take_hammer","ranc_take_silver_ingot","ranc_press_place_mould","ranc_press_place_hammer","ranc_hold_craft_sheriff_star","ranc_take_sheriff_star","mex_pickup_murky_uniforms","xm20_int_mask","pex_medal"}

local function get_interactive_units()
	local function clone_table(table)
		local new_table = {}
		for k, v in pairs(table or {}) do
			new_table[k] = v
		end
		return new_table
	end

	return clone_table(managers.interaction._interactive_units)
end

local function check_special_situation(interaction)
	local is_stop_taking = false
	local level_id = Global.game_settings and Global.game_settings.level_id
	local interaction_pos = interaction.interact_position and interaction:interact_position()
	local player_pos = managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and managers.player:player_unit():movement():m_head_pos()

	if level_id == "sand" and interaction.tweak_data == "fake_pick_lock_easy_no_skill" then -- The Ukrainian Prisoner
		-- this might get electricity shock
		is_stop_taking = true
	end
	if level_id == "trai" and interaction.tweak_data == "cut_fence" then -- Lost In Transit
		-- this might get electricity shock
		is_stop_taking = true
	end
	if level_id == "pbr" and player_pos and player_pos.z < 2000 then -- Beneath the Mountain
		-- this map have bug, disable all interaction till get out of the mountain
		is_stop_taking = true
	end
	if level_id == "bph" and interaction_pos and player_pos then -- Hell's Island
		-- block interaction at long distance to prevent trigger escape countdown
		local distance = mvector3.distance(interaction_pos, player_pos)
		if distance > 1000 then
			is_stop_taking = true
		end
	end
	if level_id == "friend" and interaction.tweak_data == "pick_lock_easy_no_skill" then -- Scarface Mansion
		-- don't open the boss' room too early
		is_stop_taking = true
	end
	if level_id == "tag" and interaction.tweak_data == "tag_take_unknown" or interaction.tweak_data == "dah_panicroom_keycard" then -- Breakin' Feds
		-- don't take the box too early
		is_stop_taking = true
	end
	if level_id == "help" and interaction.tweak_data == "timelock_panel" then -- Prison Nightmare
		-- don't open prison gate too early
		is_stop_taking = true
	end
	if level_id == "kenaz" then -- Golden Grin Casino
		if interaction.tweak_data == "cas_open_door" or interaction.tweak_data == "cas_security_door" or interaction.tweak_data == "cas_open_securityroom_door" then
			-- don't open security door too early
			is_stop_taking = true
		end
		if interaction.tweak_data == "cas_take_gear" and managers.player:player_unit():movement():current_state()._state_data.mask_equipped then
			-- don't put mask back
			is_stop_taking = true
		end
		if interaction.tweak_data == "cas_copy_usb" or interaction.tweak_data == "cas_use_usb" then
			-- don't use computer without usb key
			is_stop_taking = true
		end
	end

	return is_stop_taking
end

local function interactbytweak(interaction_table)
	-- local player = managers.player._players[1]
	local player_unit = managers.player and managers.player:player_unit()
	local state = managers.player and managers.player._current_state
	if not player_unit or not alive(player_unit) or state == "bleed_out" or state == "incapacitated" or state == "fatal" or state == "arrested" then
		return
	end

	local tweaks = {}
	for _,arg in pairs(interaction_table) do
		tweaks[arg] = true
	end

	local interactive_units = get_interactive_units()
	for _,unit in pairs(interactive_units) do
		local interaction = unit and alive(unit) and unit.interaction and unit.interaction(unit)
		if interaction and tweaks[interaction.tweak_data] then

			-- use ECM and shaped charges interaction without having them equipped
			if interaction.tweak_data == "requires_ecm_jammer" or interaction.tweak_data == "requires_ecm_jammer_atm" or interaction.tweak_data == "requires_ecm_jammer_double" or interaction.tweak_data == "shaped_sharge" then
				interaction._tweak_data.required_deployable = nil
				interaction._tweak_data.deployable_consume = false
			end
			-- open door, timelock, panicroom, crate, and so on, without equipment, and not consume the equipment
			if interaction._tweak_data.special_equipment then interaction._tweak_data.special_equipment = nil end
			if interaction._tweak_data.equipment_consume then interaction._tweak_data.equipment_consume = false end
			-- TODO: hack computer without seeing them first

			-- answer pager need send to host first
			if interaction.tweak_data == "corpse_alarm_pager" and interaction._unit:key() and managers.enemy:get_corpse_unit_data_from_key(interaction._unit:key()) then
				local u_id = managers.enemy:get_corpse_unit_data_from_key(interaction._unit:key()).u_id
				managers.network:session():send_to_host("alarm_pager_interaction", u_id, interaction.tweak_data, 1) -- 1=start 2=interrupted, 3=complete
			end

			-- can't carry 2 bags at a time, need to drop first
			if managers.player:is_carrying() then
				-- managers.loot:secure(managers.player:current_carry_id(), managers.money:get_bag_value(managers.player:current_carry_id())) -- this will get money but won't remove the bag
				managers.player:drop_carry()
			end

			local is_stop_taking = false
			-- check if pack corpse 
			if not is_pack_corpse and interaction.tweak_data == "corpse_dispose" then
				is_stop_taking = true
			end
			-- can't carry 2 possessions at a time, stop taking
			if interaction._tweak_data.special_equipment_block and managers.player._equipment.specials[interaction._tweak_data.special_equipment_block] then
				is_stop_taking = true
			end
			-- those are special, they don't have special_equipment_block
			if interaction.tweak_data == "pickup_keycard" and managers.player._equipment.specials["bank_manager_key"] then
				is_stop_taking = true
			end
			if string.find(interaction.tweak_data, "c4") and managers.player._equipment.specials["c4"] then
				is_stop_taking = true
			end
			if (interaction.tweak_data == "fex_take_diesel" or interaction.tweak_data == "fex_take_diesel_axis") and managers.player._equipment.specials["diesel"] then
				is_stop_taking = true
			end
			-- take down the saw even if you have a saw in your equipment
			if interaction.tweak_data == "gen_pku_saw" then
				is_stop_taking = false
			end

			-- special situation
			if check_special_situation(interaction) == true then
				is_stop_taking = true
			end

			-- do interact
			if not is_stop_taking then
				local orig_interaction_can_interact = interaction.can_interact
				interaction.can_interact = function() return true end
				interaction:interact(player_unit)
				interaction.can_interact = orig_interaction_can_interact
			end
		end
	end
	if managers.player:is_carrying() then
		managers.player:drop_carry() -- drop the last bag
	end
end

-- because of lag, bag and drop too many loots in short time might detect as cheater, this can add some delay
local function drop_bags_one_by_one(tweaks_table)

	local function drop_one_by_one(interactive_units, tweaks, last_key)
		DelayedCalls:Add("drop_bag_one_by_one", drop_bags_delay_period, function()
			local local_player = managers.player and managers.player:local_player()
			if not local_player or not alive(local_player) then return end

			local is_do_next = false
			if last_key == nil then
				is_do_next = true
			end

			for key,unit in pairs(interactive_units or {}) do
				local interaction = unit and alive(unit) and unit.interaction and unit.interaction(unit)
				if is_do_next and interaction and interaction.tweak_data and tweaks[interaction.tweak_data] then
					if managers and managers.player and alive(managers.player:local_player()) and managers.player:is_carrying() then
						managers.player:drop_carry()
					end

					local is_stop_taking = false
					if not is_pack_corpse and interaction.tweak_data == "corpse_dispose" then
						is_stop_taking = true
					end

					-- special situation
					if check_special_situation(interaction) == true then
						is_stop_taking = true
					end

					if not is_stop_taking then
						interaction:interact(local_player)
					end

					if managers and managers.player and alive(managers.player:local_player()) and managers.player:is_carrying() then
						managers.player:drop_carry()
					end
					DelayedCalls:Add("drop_bag_again", drop_bags_delay_period / 2, function()
						if managers and managers.player and alive(managers.player:local_player()) and managers.player:is_carrying() then
							managers.player:drop_carry()
						end
					end)
					drop_one_by_one(interactive_units, tweaks, key)
					break
				end
				if key == last_key then
					is_do_next = true
				end
			end
		end)
	end


	local interactive_units = get_interactive_units()
	local tweaks = {}
	if tweaks_table and next(tweaks_table) then
		for _,tweak_name in pairs(tweaks_table) do
			tweaks[tweak_name] = true
		end
	else
		tweaks["carry_drop"] = true
		tweaks["painting_carry_drop"] = true
	end
	drop_one_by_one(interactive_units, tweaks)
end

local function grabspecialequipments()
	interactbytweak(special_equipments)
end
local function openalldoors()
	interactbytweak(doors)
	interactbytweak(ecm_doors) 
end
local function grabsmallloots()
	interactbytweak(small_loots)
end
local function graballbigloots()
	if drop_bags_one_by_one then
		drop_bags_one_by_one(big_loots)
	else
		interactbytweak(big_loots)
	end
end
local function drillandhack_safe_in_stealth()
	interactbytweak(drills_safe_in_stealth)
	interactbytweak(hacks_safe_in_stealth)
end
local function drillandhack_not_safe()
	interactbytweak(shaped_sharges)
	interactbytweak(drills_not_safe)
	interactbytweak(hacks_not_safe)
end
local function grabachievementcollection()
	interactbytweak(achievement_collection)
end
local function grabeverything()
	drillandhack_safe_in_stealth()
	if not managers.groupai:state():whisper_mode() then
		-- drill and shaped sharge are not safe in stealth
		-- be careful of, this might hack the wrong thing
		drillandhack_not_safe()
	end
	grabspecialequipments()
	openalldoors()
	grabsmallloots()
	graballbigloots() -- bags will drop in front of you
	--grabachievementcollection()
	managers.mission._fading_debug_output:script().log('Interact With Everything',  Color.yellow)
end
grabeverything()
