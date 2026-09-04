local function element_on_executed(element)
	if element and element:id() and managers and managers.network and managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) then
		if Network:is_server() then
			element:on_executed()
		else
			managers.network:session():send_to_host("to_server_mission_element_trigger", element:id(), managers.player:player_unit())
		end
	end
end

local function trigger_mission_elements(elem_ids, sequences, editor_names)
	if not managers and managers.mission then return end
	local is_trigger = false
	for _, script in pairs(managers.mission._scripts) do
		for id, element in pairs(script:elements()) do
			-- trigger by id
			for _, elem_id in pairs(elem_ids or {}) do
				if id == elem_id then
					element_on_executed(element)
					is_trigger = true
				end
			end

			-- trigger by notify_unit_sequence
			for _, trigger in pairs(element:values().trigger_list or {}) do
				for _, sequence in pairs(sequences or {}) do
					if trigger.notify_unit_sequence == sequence then
						element_on_executed(element)
						is_trigger = true
					end
				end
			end

			for _, editor_name in pairs(editor_names or {}) do
				if element._editor_name == editor_name then
					element_on_executed(element)
					is_trigger = true
				end
			end
		end
	end
	return is_trigger
end


local function overdrill_overvault()
	-- only activate overdrill
	local function overdrill_activator()
		if Global.level_data and Global.level_data.level_id == "red2" then
			local overdrill_ids = {103974}
			local overdrill_sequences = { "light_on" }
			if trigger_mission_elements(overdrill_ids, overdrill_sequences, {}) and managers.chat then
				managers.chat:_receive_message(1, "Activated", "Overdrill", Color.green)
			end
		end
	end

	-- open overvault
	local function overdrill_open_vault()
		if Global.level_data and Global.level_data.level_id == "red2" then
			local overdrill_ids = {
				103974,		-- activate overdrill, still need to go loud to open the gate
				104136,		-- show the overvault gate and drill intercation.
				104349,		-- sound overdrill
				104180,		-- open gate
				104181,		-- 'func_sequence_trigger_088' loads the overvault itself and open the drilled gate.
				104192,		-- disable puzzle
				104193,
				104194,
				104198,		-- open vault
				104303,		-- enable gold interaction
				104189,		-- 'dasistcorrectsir' disables the floor button interactions and open the overvault door
				104326		-- 'trigger_area_110' enables the interaction for the 70 gold bars and gives the overdrill achievement to all players that have been there from start of the heist.
				}
			if trigger_mission_elements(overdrill_ids, {}, {}) and managers.chat then
				managers.chat:_receive_message(1, "Opened", "Overvault", Color.green)
			end
		end
	end

	overdrill_activator()
	overdrill_open_vault()
end


local function secret_painting_puzzle()
	local function secret_painting_activator()
		if Global.level_data and Global.level_data.level_id == "vit" then
			local secret_painting_sequences = { "glowing" }
			if trigger_mission_elements({}, secret_painting_sequences, {}) and managers.chat then

				-- remove painting
				for _,unit in ipairs(World:find_units_quick("all", 1)) do
					if unit:name().key and (unit:name():key() == "9a765e7c8117a005" or unit:name():key() == "2286ce1b2545957b") then
						unit:set_visible(false)
						-- unit:set_slot(0)
						World:delete_unit(unit)
						--[[local interaction = unit and alive(unit) and unit.interaction and unit.interaction(unit)
						if interaction then
							interaction:set_active(true)
							interaction.can_interact = function() return true end
							-- interaction:interact(managers.player:player_unit())
						end]]--
					end
				end

				managers.chat:_receive_message(1, "Activated", "Secret Painting Element", Color.green)
			end
		end
	end

	local function secret_puzzle_solver()
		if Global.level_data and Global.level_data.level_id == "vit" then
			--[[
			-- this version of the code will skip the plot and start countdown immediately
			local secret_puzzle_ids = {
				165161, -- start_puzzle
				165163, -- solved_ze_puzzle, open ring door
				165172, -- temp_solve, open ring door
				164970, -- all_riddles_solved
				164814, -- play_dnt_uno_03, play arrive uno sound
				164815, -- wp_door_open, show waypoint
				164819, -- enable_interaction_open_door
				164820, -- link_opened_puzzle_door_again, locke showup and start countdown
				164825, -- done_arrive
			}
			if trigger_mission_elements(secret_puzzle_ids, {}, {}) and managers.chat then
				managers.chat:_receive_message(1, "Solved", "Secret Puzzle", Color.green)
			end
			]]--

			-- this version of the code will not skip the plot
			local secret_puzzle_editor_names = { "start_puzzle", "all_riddles_solved" }
			if trigger_mission_elements({}, {}, secret_puzzle_editor_names) and managers.chat then
				managers.chat:_receive_message(1, "Solved", "Secret Puzzle", Color.green)
			end
		end
	end

	if managers and managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and managers.player:player_unit():movement() and managers.player:player_unit():movement():m_head_pos() then
		if managers.player:player_unit():movement():m_head_pos().z > -2100 then
			secret_painting_activator()
		else
			secret_puzzle_solver()
		end
	end
end


-- host only
local function big_bank_computer_host()
	if not Network:is_server() then return end
	if Global.level_data and Global.level_data.level_id == "big" then
		if managers and managers.mission and managers.mission._scripts and managers.mission._scripts["default"] and managers.mission._scripts["default"]._elements and managers.mission._scripts["default"]._elements[104494] then
			if managers.mission._scripts["default"]._elements[104494]._chance == 100 then
				-- don't need to trigger twice
				return
			end
			-- 100% chance, server room computer is correct computer
			managers.mission._scripts["default"]._elements[104494]._chance = 100
			element_on_executed(managers.mission._scripts["default"]._elements[104494])
			managers.chat:_receive_message(1, "Activated", "Server Room Computer is Correct Computer", Color.green)
		end
	end
end

local function big_bank_crane_drop()
	if Global.level_data and Global.level_data.level_id == "big" and not managers.groupai:state():whisper_mode() then
		for _, unit in pairs(managers.interaction._interactive_units or {}) do
			local interaction = alive(unit) and unit.interaction and unit:interaction()
			if interaction and interaction.can_interact and interaction:can_interact() and (interaction.tweak_data == "crane_joystick_left" or interaction.tweak_data == "crane_joystick_release") then
				local lance_editor_names = { [1]="done_lift", [2]="crane_left", [3]="crane_left", [4]="crane_drop" }
				if trigger_mission_elements({}, {}, lance_editor_names) and managers.chat then
					managers.chat:_receive_message(1, "Activated", "Big Bank Crane Drop", Color.green)
				end
			end
		end
	end
end

local function first_world_bank_computer_and_thermite()
	if Global.level_data and Global.level_data.level_id == "red2" and not managers.groupai:state():whisper_mode() then
		local first_world_bank_computer_editor_names = { "start_choosing_sec_footage_location" }
		if trigger_mission_elements({}, {}, first_world_bank_computer_editor_names) and managers.chat then
			managers.chat:_receive_message(1, "Activated", "First World Bank Start Choosing Computer", Color.green)
		end
		local first_world_bank_thermite_editor_names = { "show_thermite_hole" }
		if trigger_mission_elements({}, {}, first_world_bank_thermite_editor_names) and managers.chat then
			managers.chat:_receive_message(1, "Activated", "First World Bank Thermite Finished", Color.green)
		end
	end
end

local function goat_simulator_highlight()
	if Global.level_data and Global.level_data.level_id == "peta" then
		local show_goats_ids = { 100672, 100673 }
		if trigger_mission_elements(show_goats_ids, {}, {}) and managers.chat then
			managers.chat:_receive_message(1, "Activated", "Highlight Goats", Color.green)
		end
	end
end

local function diamond_heist_highlight()
	if Global.level_data and Global.level_data.level_id == "dah" then
		local show_control_boxs_outline_sequences = { "state_show_outline" } -- show control boxs outline
		if trigger_mission_elements({}, show_control_boxs_outline_sequences, {}) and managers.chat then
			managers.chat:_receive_message(1, "Activated", "Highlight Control Boxs", Color.green)
		end
		local show_computers_outline_editor_names = { "enable_outline" } -- show computers outline
		if managers.groupai:state():whisper_mode() and trigger_mission_elements({}, {}, show_computers_outline_editor_names) and managers.chat then
			managers.chat:_receive_message(1, "Activated", "Highlight Computer", Color.green)
		end
	end
end

-- host only
local function fast_cook_host()
	if not Network:is_server() then return end
	if Global.level_data and (Global.level_data.level_id == "rat" or Global.level_data.level_id == "alex_1" or Global.level_data.level_id == "mex_cooking") then
		if managers and managers.mission and managers.mission._scripts and managers.mission._scripts["default"] and managers.mission._scripts["default"]._elements then
			if managers.mission._scripts["default"]._elements[102197] and managers.mission._scripts["default"]._elements[102197]._values and managers.mission._scripts["default"]._elements[102197]._values.base_delay and managers.mission._scripts["default"]._elements[102197]._values.base_delay ~= 0 then
				managers.mission._scripts["default"]._elements[102197]._values.base_delay_rand = nil
				managers.mission._scripts["default"]._elements[102197]._values.base_delay = 1
			end
			if managers.mission._scripts["default"]._elements[100724] and managers.mission._scripts["default"]._elements[100724]._values then
				for _, execution in pairs(managers.mission._scripts["default"]._elements[100724]._values.on_executed or {}) do
					if execution and execution.delay and execution.delay ~= 0 then
						execution.delay_rand = nil
						execution.delay = 1.1
					end
				end
			end
			local fast_cook_ids = { 102164, 102166, 102177, 102178 }
			for _, id in pairs(fast_cook_ids) do
				if managers.mission._scripts["default"]._elements[id] and managers.mission._scripts["default"]._elements[id]._timer then
					managers.mission._scripts["default"]._elements[id]._timer = managers.mission._scripts["default"]._elements[id]:get_random_table_value_float(1)
					managers.mission._scripts["default"]._elements[id]:_update_digital_guis_timer()
				end
			end
			managers.chat:_receive_message(1, "Activated", "Fast Cook", Color.green)
		end
	elseif Global.level_data and (Global.level_data.level_id == "mia_1" or Global.level_data.level_id == "crojob2") then
		if managers and managers.mission and managers.mission._scripts and managers.mission._scripts["default"] and managers.mission._scripts["default"]._elements then
			for _, element in pairs(managers.mission._scripts["default"]._elements) do
				if element._editor_name == "timer_to_next" and element._values then
					for _, execution in pairs(element._values.on_executed or {}) do
						if execution and execution.delay and execution.delay ~= 0 then
							execution.delay_rand = nil
							execution.delay = 1.1
						end
					end
				end
			end
			managers.chat:_receive_message(1, "Activated", "Fast Cook", Color.green)
		end
	end
end

-- partly host only
local function finish_timer_partly_host()
	-- for dirll and timer ui, work as both server and client
	local function finish_drill()
		if managers.job and managers.job:current_level_id() == "help" then -- this script won't work in Prison Nightmare
			return
		end
		local is_success = false
		for unit_idx, unit in pairs(World:find_units_quick("all") or {}) do
			if alive(unit) then
				local timer_gui = (type(unit.timer_gui) == "function") and unit:timer_gui()
				local digital_gui = ((type(unit.digital_gui) == "function") and unit:digital_gui()) or ((type(unit.digital_gui_upper) == "function") and unit:digital_gui_upper())
				if timer_gui then
					if timer_gui._started and timer_gui._update_enabled and not timer_gui._done then
						if timer_gui._jammed then
							timer_gui:set_jammed(false)
						end
						if not timer_gui._powered then
							timer_gui:set_powered(true)
						end
						timer_gui._current_jam_timer = nil
						timer_gui._current_timer = 0
						timer_gui._time_left = 0
						timer_gui._update_enabled = false
						unit:set_extension_update_enabled(Idstring("timer_gui"), false)
						timer_gui:done()
						if managers.network:session() then
							managers.network:session():send_to_peers_synched("start_timer_gui", unit:timer_gui()._unit, 0)
						end
						for i = 1, 4 do
							DelayedCalls:Add("anti_jam_" .. tostring(unit_idx) .. "_" .. tostring(i), 0.5 * i, function()
								if alive(unit) and alive(managers.player:player_unit()) and timer_gui._jammed and timer_gui._powered and unit:interaction() then
									local special_equipment = unit:interaction()._tweak_data and unit:interaction()._tweak_data.special_equipment or nil
									unit:interaction()._tweak_data.special_equipment = nil
									unit:interaction():interact(managers.player:player_unit())
									unit:interaction()._tweak_data.special_equipment = special_equipment
								end
							end)
						end
						is_success = true
					end
				elseif digital_gui then
					if digital_gui and digital_gui:is_timer() and digital_gui._timer_count_down and digital_gui._timer and digital_gui._timer > 0 then
						digital_gui._floored_last_timer = -1
						digital_gui:timer_set(0, true)
					end
				end
			end
		end
		return is_success
	end

	-- some drill or timelock can be finished by trigger mission element, so that can work as both server and client
	local function finish_timelock_by_mission_element()
		local is_success = false
		if Global.level_data and Global.level_data.level_id == "big" then
			-- Big Bank timelock, only finish timelock when timelock is started
			for _, unit in pairs(World:find_units_quick("all") or {}) do
				if alive(unit) and unit:name() == Idstring("units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock") then
					if type(unit.digital_gui) == "function" and unit:digital_gui() and type(unit:digital_gui()._timer) == "number" and unit:digital_gui()._timer > 0 then
						local big_bank_timelock_editor_names = { "timelock_timer", "disable_laser", "disable" }
						if trigger_mission_elements({}, {}, big_bank_timelock_editor_names) then
							is_success = true
							break
						end
					end
				end
			end
		elseif Global.level_data and Global.level_data.level_id == "kenaz" and not managers.groupai:state():whisper_mode() then
			-- Golden Grin Casino drill
			for _, unit in pairs(World:find_units_quick("all") or {}) do
				if alive(unit) and unit:name() == Idstring("units/pd2_dlc_casino/props/cas_prop_drill/cas_prop_drill") then
					-- only finish timelock when drill is in position, can't check position simply using unit:position(), which will return a fake position
					local is_in_position = false
					local find_positions = { Vector3(425, -2800, -149), Vector3(425, -1800, -149) }
					for _, position in pairs(find_positions) do
						local bodies = World:find_bodies("intersect", "cylinder", position, Vector3(0, 0, 1), 40, managers.slot:get_mask("bullet_impact_targets"))
						for _, hit_body in pairs(bodies) do
							if alive(hit_body:unit()) and hit_body:unit() == unit then
								is_in_position = true
								break
							end
						end
					end
					-- trigger element and change time attribute, to prevent trigger twice
					if is_in_position and type(unit.digital_gui) == "function" and unit:digital_gui() and type(unit:digital_gui()._timer) == "number" and unit:digital_gui()._timer > 0 then
						local golden_grin_casino_drill_sequences = { "C4_planted_counter_4", "drilling done" }
						if trigger_mission_elements({}, {}, golden_grin_casino_drill_sequences) then
							is_success = true
							unit:digital_gui()._floored_last_timer = -1
							if type(unit:digital_gui().timer_set) == "function" then unit:digital_gui():timer_set(0, true) end
							break
						end
					end
				end
			end
		elseif Global.level_data and Global.level_data.level_id == "roberts" and managers.groupai:state():whisper_mode() then
			-- Go Bank timelock, only open vault in stealth, because you will use drill in loud
			local go_bank_timelock_sequences = { "open_door" }
			if trigger_mission_elements({}, go_bank_timelock_sequences, {}) then
				is_success = true
			end
		elseif Global.level_data and Global.level_data.level_id == "arm_for" then
			-- Transport: Train Heist vault timelock
			local transport_train_heist_open_vault_sequences = { "open_door_no_attention" }
			if trigger_mission_elements({}, transport_train_heist_open_vault_sequences, {}) then
				is_success = true
			end
		elseif Global.level_data and Global.level_data.level_id == "help" then
			-- Prison Nightmare drill
			local prison_nightmare_drill_timer_editor_names = { "wheel_finished" }
			if trigger_mission_elements({}, {}, prison_nightmare_drill_timer_editor_names) then
				is_success = true
			end
		end
		return is_success
	end

	-- for timelock, host only
	local function finish_timelock_host()
		if not Network:is_server() then return end
		if managers.job and managers.job:current_level_id() == "help" then -- this script won't work in Prison Nightmare
			return
		end
		local is_success = false
		local function is_active_mission_timer(element)
			if not element or type(element._digital_gui_units) ~= "table" or not next(element._digital_gui_units) or type(element._timer) ~= "number" or element._timer <= 0 or type(element.timer_operation_set_time) ~= "function" or type(element.update_timer) ~= "function" then
				return false
			end
			if element._updator then
				return true
			end
			-- a paused ElementTimer has no updater, but its linked display retains the count-down flag, treat that as an active, pending job timer too.
			for _, digital_gui_unit in pairs(element._digital_gui_units) do
				local digital_gui = alive(digital_gui_unit) and (type(digital_gui_unit.digital_gui) == "function") and digital_gui_unit:digital_gui()
				if digital_gui and digital_gui._timer_count_down and (digital_gui._timer or 0) > 0 then
					return true
				end
			end
			return false
		end
		for _, mission_script in pairs(managers and managers.mission and managers.mission:scripts() or {}) do
			for id, element in pairs((type(mission_script.elements) == "function") and mission_script:elements() or {}) do
				if is_active_mission_timer(element) then
					element:timer_operation_set_time(0)
					element:update_timer(0, 0)
					is_success = true
				end
			end
		end
		return is_success
	end

	local is_success = false
	is_success = finish_drill() or is_success
	is_success = finish_timelock_by_mission_element() or is_success
	is_success = finish_timelock_host() or is_success
	if is_success and managers.mission then
		managers.mission._fading_debug_output:script().log('Finish Timer',  Color.yellow)
	end
end




overdrill_overvault()
secret_painting_puzzle()
big_bank_computer_host()
big_bank_crane_drop()
first_world_bank_computer_and_thermite()
goat_simulator_highlight()
diamond_heist_highlight()
fast_cook_host()
--finish_timer_partly_host()
