-- Unlimited Body Bags
global_infBodybags_toggle = not global_infBodybags_toggle

orig_PlayerManager_on_used_body_bag = orig_PlayerManager_on_used_body_bag or PlayerManager.on_used_body_bag
function PlayerManager:on_used_body_bag()
	if global_infBodybags_toggle then
		self:_set_body_bags_amount(self._local_player_body_bags)
	else
		orig_PlayerManager_on_used_body_bag(self)
	end
end


if global_infBodybags_toggle then
	if managers.player._local_player_body_bags < 1 then
		-- gives you 1 bag on activation, so if you forget to activate it and run out of bags there's no problem
		managers.player:add_body_bags_amount(1)
	end
	managers.mission._fading_debug_output:script().log('Unlimited Body Bags - Activated', Color.green)
	-- managers.hud:show_hint( { text = "Unlimited Body Bags - Activated" } )
	-- managers.chat:_receive_message(1, "Unlimited Body Bags ", "Activated", Color.green)
else
	managers.mission._fading_debug_output:script().log('Unlimited Body Bags - Deactivated', Color.red)
	-- managers.hud:show_hint( { text = "Unlimited Body Bags - Deactivated" } )
	-- managers.chat:_receive_message(1, "Unlimited Body Bags ", "Deactivated", Color.red)
end
