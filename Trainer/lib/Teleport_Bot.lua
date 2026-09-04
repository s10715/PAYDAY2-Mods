-- host only
if not Network:is_server() then
	return
end

for id, data in pairs(managers.criminals._characters) do
	if alive(managers.player:player_unit()) and data.data.ai and alive(data.unit) then
		data.unit:movement():set_position(managers.player:player_unit():position())
		managers.mission._fading_debug_output:script().log('Teleport Bot',  Color.yellow)
		break
	end
end
