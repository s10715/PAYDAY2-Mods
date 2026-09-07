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

local str = ""
local save_file_name = tostring(ModPath) .. "Units_Around-" .. tostring(Global.level_data.level_id) .. os.date("%Y%m%d-%H%M%S") .. '.txt'
local player_pos = managers.player:player_unit():movement():m_head_pos()
local file, err_msg = io.open(save_file_name, 'w')
if file then
	for id, unit in pairs(World:find_units_quick("all")) do
		if unit and alive(unit) then
			local dist = mvector3.distance(unit:position(), player_pos)
			if dist < 200 then
				str = str .. print_table(unit) .. '\n'
			end
		end
	end
	file:write(str .. '\n\n')
	file:close()
	managers.chat:_receive_message(1, "File save to", tostring(save_file_name), Color.green)
end
