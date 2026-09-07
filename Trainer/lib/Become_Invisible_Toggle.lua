local function update_invisible_state(state)
	local statetable = {
		"Standard",
		"Civilian",
		"MaskOff",
		"Clean",
		"BleedOut",
		"ParaChuting",
		"Incapacitated",
		"Carry",
		"Arrested",
	}
	if alive(managers.player:player_unit()) then
		for id,state_table in pairs(statetable) do
			Hooks:Add("Player" .. state_table .. "Update", "UpdateMovState" .. id , function(t, dt)
				self:_upd_attention()
			end)
		end
		managers.player:player_unit():movement():set_attention_settings({state})
	end
end

global_detection_toggle = not global_detection_toggle

if global_detection_toggle then
	if HUDManager then
		orig_HUDManager_update = orig_HUDManager_update or HUDManager.update
		function HUDManager:update(t, dt)
			orig_HUDManager_update(self, t, dt)
			update_invisible_state("pl_civilian")
		end
	end
	managers.mission._fading_debug_output:script().log('Invisible - Activated',  Color.green)
else
	update_invisible_state("pl_mask_on_foe_combatant_whisper_mode_stand")
	update_invisible_state("pl_mask_on_foe_combatant_whisper_mode_crouch")
	if orig_HUDManager_update then HUDManager.update = orig_HUDManager_update end
	managers.mission._fading_debug_output:script().log('Invisible - Deactivated',  Color.red)
end
