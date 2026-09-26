-- Infinite Stamina
global_infStamina_toggle = not global_infStamina_toggle

orig_PlayerMovement__change_stamina = orig_PlayerMovement__change_stamina or PlayerMovement._change_stamina
orig_PlayerMovement_is_stamina_drained = orig_PlayerMovement_is_stamina_drained or PlayerMovement.is_stamina_drained
orig_PlayerStandard__can_run_directional = orig_PlayerStandard__can_run_directional or PlayerStandard._can_run_directional

if global_infStamina_toggle then
	function PlayerMovement:_change_stamina(value) end
	function PlayerMovement:is_stamina_drained() return false end
	function PlayerStandard:_can_run_directional() return true end
	managers.mission._fading_debug_output:script().log('Infinite Stamina - Activated',  Color.green)
else
	PlayerMovement._change_stamina = orig_PlayerMovement__change_stamina
	PlayerMovement.is_stamina_drained = orig_PlayerMovement_is_stamina_drained
	PlayerStandard._can_run_directional = orig_PlayerStandard__can_run_directional
	managers.mission._fading_debug_output:script().log('Infinite Stamina - Deactivated',  Color.red)
end
