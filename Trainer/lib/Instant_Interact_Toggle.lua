global_instantinteract_toggle = not global_instantinteract_toggle

-- instant deploy
orig_PlayerManager_selected_equipment_deploy_timer = orig_PlayerManager_selected_equipment_deploy_timer or PlayerManager.selected_equipment_deploy_timer
function PlayerManager:selected_equipment_deploy_timer(...)
	if global_instantinteract_toggle then
		return 0
	else
		return orig_PlayerManager_selected_equipment_deploy_timer(self, ...)
	end
end

-- instant interaction
orig_BaseInteractionExt__get_timer = orig_BaseInteractionExt__get_timer or BaseInteractionExt._get_timer
function BaseInteractionExt:_get_timer(...)
	if global_instantinteract_toggle then
		if self.tweak_data == "corpse_alarm_pager" then -- can not change pager timer as client
			if Network:is_server() then
				return 0
			else
				return orig_BaseInteractionExt__get_timer(self, ...)
			end
		elseif self.tweak_data == "driving_drive" then -- can't get in vehicle if timer is 0
			return 0.01
		else
			return 0
		end
	else
		return orig_BaseInteractionExt__get_timer(self, ...)
	end
end

-- instant pager, as client
orig_BaseInteractionExt_interact_start = orig_BaseInteractionExt_interact_start or BaseInteractionExt.interact_start
function BaseInteractionExt:interact_start(player, ...)
	if global_instantinteract_toggle then
		if self.tweak_data == "corpse_alarm_pager" and self._unit:key() and managers.enemy:get_corpse_unit_data_from_key(self._unit:key()) and managers.enemy:get_corpse_unit_data_from_key(self._unit:key()).u_id and Network:is_client() and player and alive(player) then
			local u_id = managers.enemy:get_corpse_unit_data_from_key(self._unit:key()).u_id
			managers.network:session():send_to_host("alarm_pager_interaction", u_id, self.tweak_data, 1)
			self:interact(player)
			return false
		else
			return orig_BaseInteractionExt_interact_start(self, player, data)
		end
	else
		return orig_BaseInteractionExt_interact_start(self, player, ...)
	end
end

-- no drop bag cooldown
orig_PlayerStandard__check_use_item = orig_PlayerStandard__check_use_item or PlayerStandard._check_use_item
function PlayerStandard:_check_use_item(t, input)
	if global_instantinteract_toggle then
		if input.btn_use_item_release and self._throw_time and t and t < self._throw_time then
			managers.player:drop_carry()
			self._throw_time = nil
			return true
		else
			return orig_PlayerStandard__check_use_item(self, t, input) 
		end
	else
		return orig_PlayerStandard__check_use_item(self, t, input)
	end
end

orig_PlayerStandard__action_interact_forbidden = orig_PlayerStandard__action_interact_forbidden or PlayerStandard._action_interact_forbidden
function PlayerStandard:_action_interact_forbidden(...)
	if global_instantinteract_toggle then
		return false
	else
		return orig_PlayerStandard__action_interact_forbidden(self, ...)
	end
end

orig_PlayerManager_carry_blocked_by_cooldown = orig_PlayerManager_carry_blocked_by_cooldown or PlayerManager.carry_blocked_by_cooldown
function PlayerManager:carry_blocked_by_cooldown(...)
	if global_instantinteract_toggle then
		return false
	else
		return orig_PlayerManager_carry_blocked_by_cooldown(self, ...)
	end
end




global_player_put_on_mask_time = global_player_put_on_mask_time or tweak_data.player.put_on_mask_time
local function change_mask_time(modify)
	if modify then
		tweak_data.player.put_on_mask_time = 0 -- instant mask
	else
		tweak_data.player.put_on_mask_time = global_player_put_on_mask_time
	end
end

orig_carry_tweak_data = orig_carry_tweak_data or {}
local function change_carry_tweak_data(modify)
	if modify then
		for name, _ in pairs(tweak_data.carry.types) do
			if tweak_data.carry.types[name].throw_distance_multiplier or tweak_data.carry.types[name].move_speed_modifier or tweak_data.carry.types[name].jump_modifier or tweak_data.carry.types[name].can_run then
				-- backup origin tweak_data
				if not orig_carry_tweak_data[name] then
					orig_carry_tweak_data[name] = {}
					orig_carry_tweak_data[name].move_speed_modifier = tweak_data.carry.types[name].move_speed_modifier
					orig_carry_tweak_data[name].jump_modifier = tweak_data.carry.types[name].jump_modifier
					orig_carry_tweak_data[name].can_run = tweak_data.carry.types[name].can_run
					orig_carry_tweak_data[name].throw_distance_multiplier = tweak_data.carry.types[name].throw_distance_multiplier
				end
				-- modify tweak_data
				tweak_data.carry.types[name].move_speed_modifier = 1
				tweak_data.carry.types[name].jump_modifier = 1
				tweak_data.carry.types[name].can_run = true
				if Network:is_server() then -- can not sync bag position if not host
					tweak_data.carry.types[name].throw_distance_multiplier = 1
				end
			end
		end
	else
		for name, data in pairs(orig_carry_tweak_data) do
			tweak_data.carry.types[name].move_speed_modifier = data.move_speed_modifier
			tweak_data.carry.types[name].jump_modifier = data.jump_modifier
			tweak_data.carry.types[name].can_run = data.can_run
			tweak_data.carry.types[name].throw_distance_multiplier = data.throw_distance_multiplier
		end
	end
end


if global_instantinteract_toggle then
	change_mask_time(true)
	change_carry_tweak_data(true)
	managers.mission._fading_debug_output:script().log('Instant Interact - Activated',  Color.green)
else
	change_mask_time(false)
	change_carry_tweak_data(false)
	managers.mission._fading_debug_output:script().log('Instant Interact - Deactivated',  Color.red)
end
