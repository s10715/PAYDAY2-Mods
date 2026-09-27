global_print_triggered_elements_toggle = not global_print_triggered_elements_toggle

local scan_method = 2
local show_duplicated = false -- set true to print elements that triggered duplicated, only support method 2


local mission_id = Global.level_data and Global.level_data.level_id and tostring(Global.level_data.level_id) or nil
local save_file_name = tostring(ModPath) .. 'Triggered_Elements_' .. tostring(mission_id) .. '.txt'
triggered_elements_cache = triggered_elements_cache or {}
elements_information_cache = elements_information_cache or ""

local function print_elements_information(element)
	if not element then return end
	local str = ""
	if element._id then
		str = str .. "id=" .. tostring(element._id)
	end
	if element._editor_name then
		str = str .. ", _editor_name=" .. tostring(element._editor_name)
	end
	if element.values and element:values() and element:values().trigger_list then
		for idx, trigger in pairs(element:values().trigger_list or {}) do
			if trigger.notify_unit_sequence then
				str = str .. ", notify_unit_sequence" .. idx .. "=" .. tostring(trigger.notify_unit_sequence)
			end
		end
	end
	return str
end

-- write to file every 5 seconds to prevent too many io operation
local function write_cache_to_file(run_now)
	DelayedCalls:Add("print_triggered_elements_to_file", run_now and 0.01 or 5, function()
		if elements_information_cache ~= "" then
			local file, err_msg = io.open(save_file_name, 'a+')
			if file then
				file:write(elements_information_cache)
				file:close()
				elements_information_cache = ""
			else
				managers.mission._fading_debug_output:script().log(string.format("Error when write to file"), Color.red)
			end
		end
		if global_print_triggered_elements_toggle then
			write_cache_to_file()
		end
	end)
end
write_cache_to_file(true)


-- method 1, scan all mission elements, and print all elements that enable newly
local function print_triggered_elements1(run_now)
	DelayedCalls:Add("print_triggered_elements1", run_now and 0.01 or 5, function()
		if global_print_triggered_elements_toggle then
			if Utils:IsInHeist() then
				-- there're too many elements to print after heist initialized, only print elements that after running this script, but those elements that not print will still write to file
				local is_print = (next(triggered_elements_cache) ~= nil)
				for _, script in pairs(managers.mission and managers.mission:scripts() or {}) do
					for id, element in pairs(script:elements() or {}) do
						if element:enabled() and not triggered_elements_cache[element._id] then
							triggered_elements_cache[element._id] = true
							if global_print_triggered_elements_toggle then
								local information = print_elements_information(element)
								if is_print then managers.chat:_receive_message(1, "debug", information, Color.green) end
								elements_information_cache = elements_information_cache .. tostring(os.date("%H:%M:%S")) .. '\t' .. information .. '\n'
							end
						end
					end
				end
			end
			print_triggered_elements1()
		end
	end)
end


-- method 2, print when elements are executed
local function print_triggered_elements2()
	Hooks:PostHook(MissionScriptElement, "on_executed", "Print_Triggered_Elements", function(self, ...)
		if Utils:IsInHeist() then
			local element = self
			if show_duplicated or not triggered_elements_cache[element._id] then
				triggered_elements_cache[element._id] = true
				if global_print_triggered_elements_toggle then
					local information = print_elements_information(element)
					managers.chat:_receive_message(1, "debug", information, Color.green)
					elements_information_cache = elements_information_cache .. tostring(os.date("%H:%M:%S")) .. '\t' .. information .. '\n'
				end
			end
		end
	end)
end


if scan_method == 1 then
	print_triggered_elements1(true)
elseif scan_method == 2 then
	print_triggered_elements2()
end

if global_print_triggered_elements_toggle then
	managers.mission._fading_debug_output:script().log('Print Triggered Elements - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('Print Triggered Elements - Deactivated',  Color.red)
end
