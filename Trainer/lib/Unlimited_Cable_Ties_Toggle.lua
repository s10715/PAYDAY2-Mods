-- Unlimited Cable Ties
global_infCableTies_toggle = not global_infCableTies_toggle

orig_PlayerManager_remove_special = orig_PlayerManager_remove_special or PlayerManager.remove_special
function PlayerManager.remove_special(self, name, ...)
	if global_infCableTies_toggle and self._equipment.specials[name] and self._equipment.specials[name].is_cable_tie then
		return
	else
		return orig_PlayerManager_remove_special(self, name, ...)
	end
end


if global_infCableTies_toggle then
	-- gives you 1 cable tie on activation, so if you forget to activate it and run out of cable ties there's no problem
	if (managers.player._global.synced_cable_ties[managers.network:session():local_peer():id()].amount < 1) then
		managers.player:add_special({name = "cable_tie", silent = true, amount = 1})
	end
	managers.mission._fading_debug_output:script().log('Unlimited Cable Ties - Activated', Color.green)
else
	managers.mission._fading_debug_output:script().log('Unlimited Cable Ties - Deactivated', Color.red)
end
