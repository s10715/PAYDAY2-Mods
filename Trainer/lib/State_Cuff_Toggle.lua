global_cuff_toggle = not global_cuff_toggle

if global_cuff_toggle then
	managers.player:set_player_state("arrested")
	managers.mission._fading_debug_output:script().log(string.format("Cuff - Activated"), Color.green)
else
	managers.player:set_player_state("standard")
	managers.mission._fading_debug_output:script().log(string.format("Cuff - Deactivated"), Color.red)
end
