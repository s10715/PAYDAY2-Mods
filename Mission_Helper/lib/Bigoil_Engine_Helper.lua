if not Global.level_data or Global.level_data.level_id ~= "welcome_to_the_jungle_2" then
	return
end

local is_hook = false
if RequiredScript == "lib/managers/mission/missionscriptelement" then
	is_hook = true
end


local function show_engine_waypoint(engine_num, is_send_msg)
	local engine_locations = {
		[1] = { name = "Engine 1", carry_id="engine_01", location = Vector3(-1830, -2182, -313.492) },
		[2] = { name = "Engine 2", carry_id="engine_02", location = Vector3(-1200, -2050, -313.492) },
		[3] = { name = "Engine 3", carry_id="engine_03", location = Vector3(-1849, -1869, -313.492) },
		[4] = { name = "Engine 4", carry_id="engine_04", location = Vector3(-1200, -1735, -313.492) },
		[5] = { name = "Engine 5", carry_id="engine_05", location = Vector3(-1849, -1429, -313.492) },
		[6] = { name = "Engine 6", carry_id="engine_06", location = Vector3(-1200, -1415, -313.492) },
		[7] = { name = "Engine 7", carry_id="engine_07", location = Vector3(-175, -2025, -313.492) },
		[8] = { name = "Engine 8", carry_id="engine_08", location = Vector3(24.9999, -1350, -313.492) },
		[9] = { name = "Engine 9", carry_id="engine_09", location = Vector3(-175, -1675, -313.492) },
		[10] = { name = "Engine 10", carry_id="engine_10", location = Vector3(35, -1733, -314) },
		[11] = { name = "Engine 11", carry_id="engine_11", location = Vector3(-175, -1350, -313.492) },
		[12] = { name = "Engine 12", carry_id="engine_12", location = Vector3(25, -2050, -313.492) }
	}
	if engine_locations[engine_num] then
		for _, unit in pairs(managers and managers.interaction and managers.interaction._interactive_units or {}) do
			if alive(unit) and unit:interaction() and (unit:interaction().tweak_data == "gen_pku_fusion_reactor" or unit:interaction().tweak_data == "carry_drop") and unit.carry_data and unit:carry_data() and unit:carry_data().carry_id and unit:carry_data():carry_id() == engine_locations[engine_num].carry_id then
				local wp_name = "engine_waypoint_" .. tostring(engine_num)
				local position = (unit:interaction().tweak_data == "gen_pku_fusion_reactor" and engine_locations[engine_num].location) or (unit:interaction().tweak_data == "carry_drop" and unit:position())
				managers.hud:add_waypoint(wp_name, {
					icon = "wp_target",
					position = position,
					present_timer = 0,
					state = "present",
					radius = 10,
					blend_mode = "add"
				})
				-- remove waypoint after take engine
				if not unit:interaction().hook_take_engine then
					local orig_interact = unit:interaction().interact
					unit:interaction().interact = function(...)
						managers.hud:remove_waypoint(wp_name)
						if orig_interact then orig_interact(...) end
					end
					unit:interaction().hook_take_engine = true
				end
				-- prevent waypoint not disappear when other player take the engine, which won't trigger unit:interaction().interact
				DelayedCalls:Add("remove_engine_waypoint_" .. tostring(engine_num), 20, function()
					managers.hud:remove_waypoint(wp_name)
				end)
				if is_send_msg and managers.chat then
					managers.chat:feed_system_message(ChatManager.GAME, "Correct Engine is " .. engine_locations[engine_num].name)
				end
				break
			end
		end
	end
end


-- for server
local function print_engine_host()
	local engine_elements_id_host = {
		id_103703 = 1,
		id_103704 = 2,
		id_103705 = 3,
		id_103706 = 4,
		id_103707 = 5,
		id_103708 = 6,
		id_103709 = 7,
		id_103711 = 8,
		id_103714 = 9,
		id_103715 = 10,
		id_103716 = 11,
		id_103717 = 12,
	}
	if managers and managers.mission and managers.mission:script("default") and managers.mission:script("default")._elements[103718] then
		local id = "id_" .. tostring(managers.mission:script("default")._elements[103718]._values.on_executed[1].id)
		if engine_elements_id_host[id] then
			show_engine_waypoint(engine_elements_id_host[id], true)
		end
	end
end


-- for client, need to join the heist from the beginning, or can not receive that element event, this also work as server
global_BigoilEngineHelper_correctengine = global_BigoilEngineHelper_correctengine or nil
if RequiredScript == "lib/managers/mission/missionscriptelement" then
	Hooks:PostHook(MissionScriptElement, "on_executed", "Bigoil_Engine_Helper_client", function(self, ...)
		local engine_list = {
			["on001"] = 1,
			["on002"] = 2,
			["on003"] = 3,
			["on004"] = 4,
			["on005"] = 5,
			["on006"] = 6,
			["on007"] = 7,
			["on008"] = 8,
			["on009"] = 9,
			["on010"] = 10,
			["on011"] = 11,
			["on012"] = 12
		}
		if self and engine_list[tostring(self._editor_name)] then
			global_BigoilEngineHelper_correctengine = engine_list[tostring(self._editor_name)]
		end
	end)
end
local function print_engine_client()
	if global_BigoilEngineHelper_correctengine then
		show_engine_waypoint(global_BigoilEngineHelper_correctengine, true)
		return true
	end
end


-- only show the clue menu
local function show_engine_menu()
	local dialog_data = {    
		title = "Engine Clue Menu",
		text = "Choose the clue",
		button_list = {}
	}

	local all_engine_clues = {
		{ id = '1', cluetext = "Nitrogen is yellow, Deterium is blue, Helium is green" },
		{ id = '2', cluetext = "1H - Nitrogen - <5812: Engine 1", engine_nums = { 1 } },
		{ id = '3', cluetext = "1H - Deterium - >5783: Engine 2", engine_nums = { 2 } },
		{ id = '1', cluetext = ""},
		{ id = '4', cluetext = "2H - Nitrogen - <5812: Engine 4", engine_nums = { 4 } },
		{ id = '5', cluetext = "2H - Deterium - <5812: Engine 5", engine_nums = { 5 } },
		{ id = '6', cluetext = "2H - Helium - <5812: Engine 3", engine_nums = { 3 } },
		{ id = '7', cluetext = "2H - Helium - >5783: Engine 6", engine_nums = { 6 } },
		{ id = '1', cluetext = ""},
		{ id = '8', cluetext = "3H - Nitrogen - <5812: Engine 8", engine_nums = { 8 } },
		{ id = '9', cluetext = "3H - Nitrogen - >5783: Engine 11", engine_nums = { 11 } },
		{ id = '10', cluetext = "3H - Deterium - <5812: Engine 9", engine_nums = { 9 } },
		{ id = '11', cluetext = "3H - Deterium - >5783: Engine 12", engine_nums = { 12 } },
		{ id = '12', cluetext = "3H - Helium - <5812: Engine 7", engine_nums = { 7 } },
		{ id = '13', cluetext = "3H - Helium - <=5812: Engine 10", engine_nums = { 10 } },
		{ id = '14', cluetext = "3H - Helium - ?: Engine 7 or 10", engine_nums = { 7, 10 } },
	}

	for _, data in pairs(all_engine_clues) do
		table.insert(dialog_data.button_list, {
			text = data.cluetext,
			callback_func = function()
				for _, num in pairs(data.engine_nums) do
					show_engine_waypoint(num, false)
				end
			end,
		})
	end

	table.insert(dialog_data.button_list, {})
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}
	table.insert(dialog_data.button_list, no_button)
	managers.system_menu:force_close_all()
	managers.system_menu:show_buttons(dialog_data)
end




if is_hook then
	return
end

if Network:is_server() then
	print_engine_host()
else
	if not print_engine_client() then
		show_engine_menu()
	end
end
