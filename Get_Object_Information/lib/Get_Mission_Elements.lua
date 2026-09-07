local function print_table(table)
	local str = ""
	if type(table) == 'table' then
		str = '{ '
		for key,value in pairs(table) do
			str = str .. tostring(key) .. '=' .. tostring(value) .. ', '
		end
		str = str .. ' }'
	else
		str = tostring(table)
	end
	return str
end

local function get_mission_elements(save_file_name)
	local save_file_name = save_file_name
	local mission_id = ""
	if Global.level_data and Global.level_data.level_id then
		mission_id = tostring(Global.level_data.level_id) .. "-"
	end
	if not save_file_name then
		save_file_name = "MissionElements-" .. mission_id .. os.date("%Y%m%d-%H%M%S") .. '.txt'
	end
	save_file_name = tostring(ModPath) .. tostring(save_file_name)
	local file, err_msg = io.open(save_file_name, 'w')
	if file then
		local all__editor_name = {}
		local all_instigator = {}
		local all_instance_name = {}
		local all_notify_unit_sequence = {}
		for data_name, data in pairs(managers.mission._scripts) do
			for id, element in pairs(data:elements()) do
				local str = 'data_name=' .. tostring(data_name) .. ', '
				for k,v in pairs(element) do
					str = str .. k .. '=' .. print_table(v) .. ', '
				end
				if element._editor_name then all__editor_name[element._editor_name] = true end
				if element._values and element._values.instance_name then all_instance_name[element._values.instance_name] = true end
				if element._values and element._values.instigator then all_instigator[element._values.instigator] = true end

				if element:values().trigger_list and type(element:values().trigger_list) == 'table' and next(element:values().trigger_list) then
					str = str .. '_values.trigger_list={'
					for k, trigger in pairs(element:values().trigger_list or {}) do
						str = str .. k .. '=' .. print_table(trigger)
						all_notify_unit_sequence[trigger.notify_unit_sequence] = true
					end
					str = str .. '},'
				end
				if element:values().on_executed and type(element:values().on_executed) == 'table' and next(element:values().on_executed) then
					str = str .. '_values.on_executed={'
					for k, execute_id in pairs(element:values().on_executed or {}) do
						str = str .. k .. '=' .. print_table(execute_id) .. ', '
					end
					str = str .. '},'
				end
				file:write(str .. '\n\n')
			end
		end

		local str = ""
		-- print all _editor_name at the end
		str = "_editor_name:" .. '\n'
		for k, _ in pairs(all__editor_name) do
			str = str .. k .. ', '
		end
		file:write(str .. '\n\n')

		-- print all instance_name at the end
		str = "instance_name:" .. '\n'
		for k, _ in pairs(all_instance_name) do
			str = str .. k .. ', '
		end
		file:write(str .. '\n\n')

		-- print all instigator at the end
		str = "instigator:" .. '\n'
		for k, _ in pairs(all_instigator) do
			str = str .. k .. ', '
		end
		file:write(str .. '\n\n')

		-- print all notify_unit_sequence at the end
		str = "notify_unit_sequence:" .. '\n'
		for k, _ in pairs(all_notify_unit_sequence) do
			str = str .. k .. ', '
		end
		file:write(str .. '\n\n')
		file:close()
		managers.chat:_receive_message(1, "File save to", tostring(save_file_name), Color.green)
	else
		managers.chat:_receive_message(1, "File save error", tostring(err_msg), Color.green)
	end
end

get_mission_elements()
