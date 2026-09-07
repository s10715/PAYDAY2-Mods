local function revive_teammates()
	local player = managers.player and managers.player:player_unit() -- managers.player._players[1]
	if not player or not alive(player) then return end

	-- for yourself
	local state = managers.player:current_state()
	if state == "arrested" or state == "bleed_out" or state == "incapacitated" or state == "fatal" then
		managers.player:set_player_state("standard")
		player:base():replenish()
		managers.mission._fading_debug_output:script().log("Revive" .. tostring(player:name()),  Color.yellow)
	elseif state == "jerry1" then
		managers.player:set_player_state('jerry2') -- end parachuting state
		player:base():replenish()
		managers.mission._fading_debug_output:script().log("Revive" .. tostring(player:name()),  Color.yellow)
	end

	-- for other teammates, you can't revive yourself when you're down
	for _,unit in pairs(managers.interaction._interactive_units) do
		if unit and alive(unit) and unit.name and player.name and tostring(unit:name()) ~= tostring(player:name())  and unit.interaction and unit:interaction() and (unit:interaction().tweak_data == "free" or unit:interaction().tweak_data == "revive" or unit:interaction().tweak_data == "hostage_trade") then
			unit:interaction():interact(player)
			if managers.network and managers.network:session() and managers.network:session():peer_by_unit(unit) then
				managers.mission._fading_debug_output:script().log("Revive" .. tostring(managers.network:session():peer_by_unit(unit):name()),  Color.yellow)
			elseif unit.base and unit:base() and unit:base().nick_name and unit:base():nick_name() then
				managers.mission._fading_debug_output:script().log("Revive" .. tostring(unit:base():nick_name()),  Color.yellow)
			else
				managers.mission._fading_debug_output:script().log("Revive" .. tostring(unit:name()),  Color.yellow)
			end
		end
	end
end

revive_teammates()
