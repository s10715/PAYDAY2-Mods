global_getinteractionname_toggle = not global_getinteractionname_toggle

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

Hooks:PostHook(BaseInteractionExt, "interact", "Get_Interaction_Name", function(self, player)
	if global_getinteractionname_toggle then
		managers.chat:_receive_message(1, "Interaction Name", "heist_id=" .. tostring(Global.level_data and Global.level_data.level_id) .. ", unit_key=" .. tostring(self._unit:name():key()) .. ", position=" .. tostring(self._unit:position()) .. ", tweak_data=" .. tostring(self.tweak_data) .. ", tweak_table=" .. tostring(print_table(self._tweak_data)), tweak_data.system_chat_color)
	end
end)

if global_getinteractionname_toggle then
	managers.mission._fading_debug_output:script().log('Get Interaction Name - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('Get Interaction Name - Deactivated',  Color.red)
end
