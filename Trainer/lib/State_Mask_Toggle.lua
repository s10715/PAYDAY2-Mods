-- you have to wait for the animation to toggle again, or you can't mask on again through pressing G
global_mask_toggle = not global_mask_toggle

if global_mask_toggle then
	managers.player:set_player_state("standard")
	managers.mission._fading_debug_output:script().log('Mask - Activated',  Color.green)
else
	-- managers.player:set_player_state("electrified") -- same as "mask_off"
	-- managers.player:set_player_state("throwing_grenade") -- same as "mask_off"
	managers.player:set_player_state("mask_off")
	managers.player:player_unit():movement():current_state()._state_data.mask_equipped = false
	managers.player:local_player():camera():camera_unit():base():unspawn_mask()
	managers.mission._fading_debug_output:script().log('Mask - Deactivated',  Color.red)
end
