local function unlock_all_perks()
	local VAL = 13700 -- For each tree
	Global.skilltree_manager.specializations.total_points = 315100 -- VAL * "amount_of_specialization" = total_needed_spec_points, 13700 * 23 = 315100
	Global.skilltree_manager.specializations.points = 315100

	for spec, _ in pairs(Global.skilltree_manager.specializations) do
		if type(spec) == 'number' then
			managers.skilltree.spend_specialization_points(managers.skilltree, VAL, spec)
		end
	end
end

local function set_infamy_level()
	managers.experience:set_current_rank(1)
end

local function set_level()
	managers.experience:_set_current_level(100) -- Reputation
end

local function add_experience()
	managers.experience:give_experience(23336413, true)
end

local function add_money()
	managers.money:_add_to_total(100000)
end

local function deduct_money()
	managers.money:_deduct_from_total(100000)
end

local function wipe_money()
	managers.money:_set_total(0)
end

local function add_offshore_money()
	managers.money:_set_offshore(100000)
end

local function deduct_offshore_money()
	managers.money:_deduct_from_offshore(100000)
end

local function wipe_offshore_money()
	managers.money:_set_offshore(0)
end

local function set_skillpoints()
	-- managers.skilltree:_set_points(120)
	managers.skilltree:_set_points(managers.skilltree:max_points_for_current_level())
end

local function set_continental_coins()
	Global.custom_safehouse_manager.total = Application:digest_value(200, true)
end

local function reset_job_heat()
	--[[
	for id, val in pairs(managers.job and managers.job._global and managers.job._global.heat or {}) do
		if managers.job._global.heat[id] < 0 then managers.job._global.heat[id] = 0 end
	end
	]]--
	managers.job:reset_job_heat()
end

-- this won't change infamy masks, but will add side job reward mask to inventory even if side job not completed
local function add_masks_to_inventory()
	for mask_id, mask_data in pairs(tweak_data.blackmarket.masks) do
		local global_value = managers.blackmarket:get_global_value("masks", mask_id)
		if global_value and not managers.blackmarket:has_item(global_value, "masks", mask_id) then
			local dlcs = {}
			if mask_data.dlc then table.insert(dlcs, mask_data.dlc) end
			if mask_data.dlcs then for _, dlc in ipairs(mask_data.dlcs or {}) do table.insert(dlcs, dlc) end end
			local dlc_locked = false
			for _, dlc in pairs(dlcs) do if not managers.dlc:is_dlc_unlocked(dlc) then dlc_locked = true end end
			local achievement_locked = managers.dlc:is_content_achievement_locked("masks", mask_id) or managers.dlc:is_content_achievement_milestone_locked("masks", mask_id)
			local skirmish_locked = managers.dlc:is_content_skirmish_locked("masks", mask_id)
			local crimespree_locked = managers.dlc:is_content_crimespree_locked("masks", mask_id)
			local infamy_locked = managers.dlc:is_content_infamy_locked("masks", mask_id)
			local unlocked = not dlc_locked
			if achievement_locked or skirmish_locked or crimespree_locked or infamy_locked then
				unlocked = unlocked and not achievement_locked
			end
			if unlocked and not mask_data.infamy_lock then
				managers.blackmarket:add_to_inventory(global_value, "masks", mask_id, false)
			end
		end
	end
end

local function remove_all_masks()
	for mask_id, mask_data in pairs(tweak_data.blackmarket.masks) do
		local global_value = managers.blackmarket:get_global_value("masks", mask_id)
		if global_value and mask_id ~= "character_locked" and not mask_data.infamy_lock then
			while managers.blackmarket:has_item(global_value, "masks", mask_id) do
				managers.blackmarket:remove_item(global_value, "masks", mask_id)
			end
		end
	end
end

local function unlock_all_mask_slot()
	function BlackMarketManager:is_mask_slot_unlocked(slot)
		return self._global.unlocked_mask_slots and self._global.unlocked_mask_slots[slot] or true
	end
	local max_mask_slots = tweak_data.gui.MAX_MASK_SLOTS or 72
	for i = 1, max_mask_slots do
		Global.blackmarket_manager.unlocked_mask_slots[i] = true
	end
end

local function unlock_all_weapon_slot()
	function BlackMarketManager:is_weapon_slot_unlocked(category, slot)
		return self._global.unlocked_weapon_slots and self._global.unlocked_weapon_slots[category] and self._global.unlocked_weapon_slots[category][slot] or true
	end
	local max_weapon_slots = tweak_data.gui.MAX_WEAPON_SLOTS or 72
	for i = 1, max_weapon_slots do
		Global.blackmarket_manager.unlocked_weapon_slots.primaries[i] = true
		Global.blackmarket_manager.unlocked_weapon_slots.secondaries[i] = true
	end
end

local function unlock_all_skilltree_slot()
	orig_SkillTreeManager_can_unlock_skill_switch = orig_SkillTreeManager_can_unlock_skill_switch or SkillTreeManager.can_unlock_skill_switch
	function SkillTreeManager:can_unlock_skill_switch(selected_skill_switch)
		for i = 1, #tweak_data.skilltree.skill_switches do
			if self._global.skill_switches[i] and not self._global.skill_switches[i].unlocked then
				self._global.skill_switches[i].unlocked = true
				self._global.skill_switches[i].specialization = self._global.specializations.current_specialization
			end
		end
		return orig_SkillTreeManager_can_unlock_skill_switch(self, selected_skill_switch)
	end
end

local function complete_safe_house_trophies()
	-- complete safe house trophies
	for i, trophy in pairs(Global.custom_safehouse_manager.trophies) do
		for index, j in pairs (trophy.objectives) do
			managers.custom_safehouse:update_progress("progress_id", trophy.objectives[index].progress_id, trophy.objectives[index].max_progress)
		end
		managers.custom_safehouse:update_progress("progress_id", "trophy_stealth", 15)
	end
	for k, v in pairs(Global.challenge_manager.active_challenges) do
		for foo, bar in pairs (v.objectives) do
			managers.custom_safehouse:update_progress("progress_id", v.objectives[foo].progress_id, v.objectives[foo].max_progress)
		end
		managers.custom_safehouse:update_progress("progress_id", "trophy_stealth", 15)
	end
end


function call_all()
	-- unlock_all_perks()
	-- set_infamy_level()
	-- set_level()
	-- add_experience()
	-- add_money()
	-- deduct_money()
	-- wipe_money()
	-- add_offshore_money()
	-- deduct_offshore_money()
	-- wipe_offshore_money()
	-- set_skillpoints()
	-- set_continental_coins()
	-- reset_job_heat()
	-- add_masks_to_inventory()
	-- remove_all_masks()
	-- unlock_all_mask_slot()
	-- unlock_all_weapon_slot()
	-- unlock_all_skilltree_slot()
	-- complete_safe_house_trophies()
	managers.mission._fading_debug_output:script().log('Change Asset',  Color.yellow)
end

call_all()
