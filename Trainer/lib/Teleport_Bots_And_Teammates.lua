-- host only
if not Network:is_server() then
	return
end

if managers.player and alive(managers.player:player_unit()) then
	for id, data in pairs(managers.criminals._characters or {}) do
		if data.data.ai and alive(data.unit) then
			data.unit:movement():set_position(managers.player:player_unit():position() + Vector3(0, 0, 5))
			-- break
		end
	end

	for _, peer in pairs(managers.network and managers.network:session() and managers.network:session():peers() or {}) do
		local unit = peer:unit() or (managers.criminals and managers.criminals:character_unit_by_name(peer:character()))
		unit:movement():set_position(managers.player:player_unit():position() + Vector3(0, 0, 5))
		unit:set_position(managers.player:player_unit():position() + Vector3(0, 0, 5))
	end

	managers.mission._fading_debug_output:script().log('Teleport Bots And Teammates',  Color.yellow)
end
