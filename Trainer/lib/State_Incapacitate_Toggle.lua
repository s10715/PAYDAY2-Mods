global_incapacitate_toggle = not global_incapacitate_toggle

if global_incapacitate_toggle then
	managers.player:set_player_state("incapacitated")
	managers.mission._fading_debug_output:script().log(string.format("Incapacitate - Activated"), Color.green)
else
	managers.player:set_player_state("standard")
	managers.mission._fading_debug_output:script().log(string.format("Incapacitate - Deactivated"), Color.red)
end
