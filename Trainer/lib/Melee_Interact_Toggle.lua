global_meleeinteract_toggle = not global_meleeinteract_toggle

local safe_interaction_only = true
local no_consume = false
local destroy_repeat_equipment = false -- destroy bag is host only, but you can still destroy special equipment as client


local function interact(unit)
	local interaction = unit and alive(unit) and unit:interaction()
	local player_unit = managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and managers.player:player_unit() or nil
	if not interaction or not interaction._tweak_data or not player_unit or not alive(player_unit) then return end
	if interaction._owner_id and not interaction:is_owner() then return end

	if safe_interaction_only and not table.list_to_set(managers.interaction and managers.interaction._interactive_units or {})[unit] then
		return
	end

	local orig_PlayerManager_verify_carry, orig_PlayerManager_register_carry, orig_NetworkPeer_verify_bag
	local function disable_bag_check()
		if Network:is_client() then return end
		orig_PlayerManager_verify_carry = PlayerManager.verify_carry
		function PlayerManager:verify_carry(...) return true end
		orig_PlayerManager_register_carry = PlayerManager.register_carry
		function PlayerManager:register_carry(...) return true end
		--[[orig_NetworkPeer_verify_bag = NetworkPeer.verify_bag
		function NetworkPeer:verify_bag(...) return true end]]--
	end
	local function enable_bag_check()
		if orig_PlayerManager_verify_carry then
			PlayerManager.verify_carry = orig_PlayerManager_verify_carry
		end
		if orig_PlayerManager_register_carry then
			PlayerManager.register_carry = orig_PlayerManager_register_carry
		end
		--[[if orig_NetworkPeer_verify_bag then
			NetworkPeer.verify_bag = orig_NetworkPeer_verify_bag
		end]]--
	end
	if managers.player and managers.player:is_carrying() and unit.carry_data and unit:carry_data() and unit:carry_data():can_secure() and unit:carry_data():value() > 0 then
		if tweak_data.carry and tweak_data.carry.small_loot and not tweak_data.carry.small_loot[unit:carry_data():carry_id()] then
			if destroy_repeat_equipment and Network:is_server() then
				managers.player:clear_carry() -- this can remove carried bag but still get cheater tag when you grab bag
				disable_bag_check() -- anti cheat, host only
			else
				return
			end
		end
	end
	if (interaction._tweak_data.special_equipment and not managers.player:can_pickup_equipment(interaction._tweak_data.special_equipment)) or interaction:_interact_blocked(player_unit) then
		if destroy_repeat_equipment then
			if interaction._tweak_data.special_equipment_block then
				managers.player:remove_special(interaction._tweak_data.special_equipment_block)
			elseif interaction._tweak_data.special_equipment then
				managers.player:remove_special(interaction._tweak_data.special_equipment)
			end
		else
			return
		end
	end
	-- managers.mission._fading_debug_output:script().log("interact: " .. tostring(interaction.tweak_data),  Color.yellow)

	if Network:is_client() and interaction.tweak_data == "corpse_alarm_pager" and interaction._unit and interaction._unit:key() and managers.enemy:get_corpse_unit_data_from_key(interaction._unit:key()) then
		-- answer pager need send to host first
		local u_id = managers.enemy:get_corpse_unit_data_from_key(interaction._unit:key()).u_id
		managers.network:session():send_to_host("alarm_pager_interaction", u_id, interaction.tweak_data, 1)
	end


	local orig__tweak_data = interaction._tweak_data
	local orig_required_deployable = interaction._tweak_data.required_deployable
	local orig_deployable_consume = interaction._tweak_data.deployable_consume
	local orig_special_equipment = interaction._tweak_data.special_equipment
	local orig_equipment_consume = interaction._tweak_data.equipment_consume
	local orig_can_interact = interaction.can_interact
	local orig_can_select = interaction.can_select
	local orig_active_state = interaction:active()
	local orig_player_state = player_unit:movement() and player_unit:movement():current_state_name() or nil


	if interaction._tweak_data.required_deployable and (no_consume or not interaction:_has_required_deployable()) then
		-- use ECM and shaped charges without having them equipped
		interaction._tweak_data.required_deployable = nil
		interaction._tweak_data.deployable_consume = false
	end
	if interaction._tweak_data.special_equipment and (no_consume or not managers.player:has_special_equipment(interaction._tweak_data.special_equipment)) then
		-- other equipments like keycard, gas, crowbar and so on
		interaction._tweak_data.special_equipment = nil
		interaction._tweak_data.equipment_consume = false
	end
	interaction.can_interact = function() return true end
	interaction.can_select = function() return true end


	local function restore_interaction_data()
		if orig__tweak_data then
			-- all same interaction using the same _tweak_data, need to restore it even if interaction is not exist
			orig__tweak_data.required_deployable = orig_required_deployable
			orig__tweak_data.deployable_consume = orig_deployable_consume
			orig__tweak_data.special_equipment = orig_special_equipment
			orig__tweak_data.equipment_consume = orig_equipment_consume
		end
		if interaction then
			interaction.can_interact = orig_can_interact
			interaction.can_select = orig_can_select
			if not orig_active_state or (interaction.active and not interaction:active()) then interaction:set_active(false) end
		end

		-- still don't know when will set those states, it seems remove_interact event always triggering even if interaction is blocked by those abnormal state, but change state back immediately doesn't work, so using DelayedCalls
		DelayedCalls:Add("restore_player_state", 0.5, function()
			if orig_player_state and managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and managers.player:player_unit():movement() and (managers.player:player_unit():movement():current_state_name() == "tased" or managers.player:player_unit():movement():current_state_name() == "incapacitated") then
				-- prevent getting electric shock by fence (Lost In Transit), drill (Firestarter day 3), ..., or become incapacitated when taking mask (Safe House Nightmare), and so on
				managers.player:set_player_state(orig_player_state)
			end
		end)
	end

	local hook_id_1 = "restore_interaction_data_1_" .. tostring(unit:id()) .. "_" .. tostring(unit:position())
	local hook_id_2 = "restore_interaction_data_2_" .. tostring(unit:id()) .. "_" .. tostring(unit:position())
	-- need to wait for the remove equipment event callback as client to change data back, which usually before the remove interact event
	Hooks:PreHook(BaseInteractionExt, "remove_interact", hook_id_1, function(self, ...)
		Hooks:RemovePreHook(hook_id_1)
		Hooks:RemovePreHook(hook_id_2)
		restore_interaction_data()
		-- if managers.mission and managers.mission._fading_debug_output then managers.mission._fading_debug_output:script().log("remove_interact: " .. tostring(interaction and interaction.tweak_data),  Color.yellow) end
	end)
	-- grab bag interaction (from normal item to loot) don't use remove_interact, need to hook remove_unit
	-- some units need continuous interaction, and remove_unit won't be called until the last interaction (or tweak_data is already changed when remove_unit is called), therefore tweak_data might different from the original when remove_unit is called, so still need to hook remove_interact to change data back for each interaction
	Hooks:PreHook(ObjectInteractionManager, "remove_unit", hook_id_2, function(self, u, ...)
		if unit == u then
			-- need to remove hook first to prevent recursive call
			Hooks:RemovePreHook(hook_id_1)
			Hooks:RemovePreHook(hook_id_2)
			restore_interaction_data()
			-- if managers.mission and managers.mission._fading_debug_output then managers.mission._fading_debug_output:script().log("remove_unit: " .. tostring(interaction and interaction.tweak_data),  Color.yellow) end
		end
	end)


	interaction:set_tweak_data(interaction.tweak_data)
	interaction:set_active(true)
	interaction:interact(player_unit)

	enable_bag_check()
end

local function melee_interact()
	local player_unit = managers and managers.player and managers.player:player_unit()
	if not player_unit or not alive(player_unit) then return end

	local unit = nil
	local find_position = nil

	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local range = tweak_data.blackmarket.melee_weapons[melee_entry].stats.range or 175
	local from = player_unit:movement():m_head_pos()
	local to = from + player_unit:movement():m_head_rot():y() * range
	local raytrace = player_unit:raycast("ray", from, to, "slot_mask", InstantBulletBase:bullet_slotmask(), "ignore_unit", {}, "ray_type", "body bullet lock")
	find_position = (raytrace and raytrace.position) or to


	if raytrace and raytrace.unit and alive(raytrace.unit) and raytrace.unit.interaction and raytrace.unit:interaction() then
		unit = raytrace.unit
	end
	if not unit then
		local find_direction = Vector3(player_unit:movement():m_head_rot():x(), player_unit:movement():m_head_rot():y(), player_unit:movement():m_head_rot():z())
		local find_distance = 25
		local bodies = World:find_bodies("intersect", "sphere", find_position, find_direction, find_distance, managers.slot:get_mask("bullet_impact_targets"))
		for _, hit_body in pairs(bodies) do
			if hit_body:unit() and alive(hit_body:unit()) and hit_body:unit().interaction and hit_body:unit():interaction() then
				unit = hit_body:unit()
				break
			end
		end
	end
	if not unit then
		local best_unit = nil
		local best_distance = math.huge
		for _, found_unit in pairs(World:find_units_quick("all")) do
			if found_unit and alive(found_unit) and found_unit:position() and found_unit.interaction and found_unit:interaction() and found_unit:interaction():interact_position() then
				local distance1 = mvector3.distance(find_position, found_unit:position())
				local distance2 = mvector3.distance(find_position, found_unit:interaction():interact_position())
				local distance3 = math.huge
				if found_unit.oobb then
					local ok, oobb = pcall(found_unit.oobb, found_unit)
					if ok and oobb and oobb.center and oobb:center() then
						distance3 = mvector3.distance(find_position, oobb:center())
					end
				end
				local distance = math.min(distance1, distance2, distance3)
				if distance < best_distance then
					best_unit = found_unit
					best_distance = distance
				end
			end
		end
		if best_distance < 50 then
			unit = best_unit
		end
	end

	if unit then
		interact(unit)
	end
end


if global_meleeinteract_toggle then
	Hooks:PostHook(PlayerStandard, "_do_action_melee", "Melee_Interact", function(self, ...)
		melee_interact()
	end)
	managers.mission._fading_debug_output:script().log('Melee Interact - Activated',  Color.green)
else
	Hooks:RemovePostHook("Melee_Interact")
	managers.mission._fading_debug_output:script().log('Melee Interact - Deactivated',  Color.red)
end
