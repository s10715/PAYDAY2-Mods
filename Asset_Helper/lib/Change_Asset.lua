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

local function reset_all_perks()
	managers.skilltree:reset_specializations()
end

local function set_infamy_rank(num)
	managers.experience:set_current_rank(type(num) == 'number' and num or 1)
end

local function set_level(num)
	managers.experience:_set_current_level(type(num) == 'number' and num or 100) -- Reputation
end

local function add_experience(num)
	managers.experience:give_experience(type(num) == 'number' and num or 23336413, true)
end

local function set_money(num)
	-- managers.money:_add_to_total(100000) -- add money
	-- managers.money:_deduct_from_total(100000) -- deduct money
	-- managers.money:_set_total(0) -- wipe money

	managers.money:_set_total(type(num) == 'number' and num or 20000000)
end

local function set_offshore_money(num)
	-- managers.money:add_to_offshore(100000) -- add offshore money
	-- managers.money:_deduct_from_offshore(100000) -- deduct offshore money
	-- managers.money:_set_offshore(0) -- wipe offshore money

	managers.money:_set_offshore(type(num) == 'number' and num or 10000000)
end

local function set_skillpoints(num)
	-- managers.skilltree:_set_points(120)
	managers.skilltree:_set_points(type(num) == 'number' and num or managers.skilltree:max_points_for_current_level())
end

local function set_continental_coins(num)
	Global.custom_safehouse_manager.total = Application:digest_value(type(num) == 'number' and num or 500, true)
	-- Global.custom_safehouse_manager.total_collected = Application:digest_value(type(num) == 'number' and num or 500, true)
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

local function unlock_all_crew_abilities()
	function BlackMarketManager:is_crew_item_unlocked(...)
		return true
	end
end

local function max_safehouse_rooms()
	for room_id, data in pairs(Global.custom_safehouse_manager.rooms) do
		local max_tier = data.tier_max or 3
		local current_tier = managers.custom_safehouse:get_room_current_tier(room_id) or 0
		while max_tier > current_tier do
			current_tier = current_tier + 1
			if managers.custom_safehouse._global and managers.custom_safehouse._global.rooms and managers.custom_safehouse._global.rooms[room_id] then
				table.insert(managers.custom_safehouse._global.rooms[room_id].unlocked_tiers, current_tier)
			end
		end
		managers.custom_safehouse:set_room_tier(room_id, max_tier)
	end
end

local function complete_safe_house_trophies()
	for _, trophy in pairs(Global.custom_safehouse_manager.trophies) do
		for index, _ in pairs (trophy.objectives or {}) do
			managers.custom_safehouse:update_progress("progress_id", trophy.objectives[index].progress_id, trophy.objectives[index].max_progress)
		end
		managers.custom_safehouse:update_progress("progress_id", "trophy_stealth", 15)
	end
	for _, challenge in pairs(Global.challenge_manager.active_challenges) do
		for obj, _ in pairs (challenge.objectives or {}) do
			managers.custom_safehouse:update_progress("progress_id", challenge.objectives[obj].progress_id, challenge.objectives[obj].max_progress)
		end
		managers.custom_safehouse:update_progress("progress_id", "trophy_stealth", 15)
	end
end

local function complete_all_side_jobs()
	local function complete_challenge_progress(challenge)
		for _, obj in pairs(challenge and challenge.objectives or {}) do
			obj.completed = true
			obj.progress = obj.max_progress
			for _, choice in pairs(obj.challenge_choices or {}) do
				choice.completed = true
				choice.progress = choice.max_progress
			end
		end
	end

	-- safehouse daily, reward will auto claim, but UI won't refresh
	managers.custom_safehouse:complete_and_reward_daily()

	-- daily/weekly/monthly challenge
	for _, challenge in pairs(managers.challenge and managers.challenge._global and managers.challenge._global.active_challenges or {}) do
		challenge.completed = true
		--challenge.rewarded = true
		complete_challenge_progress(challenge)
	end

	-- event missions in side job
	for _, challenge in ipairs(managers.event_jobs and managers.event_jobs._global and managers.event_jobs._global.challenges or {}) do
		challenge.completed = true
		complete_challenge_progress(challenge)
	end

	-- Gage spec ops missions
	for _, challenge in ipairs(managers.tango and managers.tango._global and managers.tango._global.challenges or {}) do
		challenge.completed = true
		complete_challenge_progress(challenge)
	end

	-- Aldstone's heritage jobs
	local generic_side_jobs = managers.generic_side_jobs and managers.generic_side_jobs._side_jobs
	for _, side_job in pairs(type(generic_side_jobs) == 'table' and generic_side_jobs or {}) do
		for _, challenge in ipairs(side_job and side_job.manager and side_job.manager._global and side_job.manager._global.challenges or {}) do
			challenge.completed = true
			complete_challenge_progress(challenge)
		end
	end

	-- other event missions
	for _, challenge in ipairs(managers.side_job_event and managers.side_job_event._global and managers.side_job_event._global.challenges or {}) do
		challenge.completed = true
		complete_challenge_progress(challenge)
	end
end

local function complete_career()
	for _, mission in pairs(managers.story and managers.story:missions_in_order() or {}) do
		local completed = mission.completed
		mission.completed = true
		for _, challenges in pairs(mission.objectives or {}) do
			for _, challenge in pairs(challenges or {}) do
				if type(challenge) == 'table' then
					challenge.completed = true
					challenge.progress = challenge.max_progress
				end
			end
		end
		if not completed then
			managers.story:claim_rewards(mission.id)
		end
	end
end


function call_all()
	-- unlock_all_perks()
	-- reset_all_perks()
	-- set_infamy_rank()
	-- set_level()
	-- add_experience()
	-- set_money()
	-- set_offshore_money()
	-- set_skillpoints()
	-- set_continental_coins()
	-- reset_job_heat()
	-- add_masks_to_inventory()
	-- remove_all_masks()
	-- unlock_all_mask_slot()
	-- unlock_all_weapon_slot()
	-- unlock_all_skilltree_slot()
	-- unlock_all_crew_abilities()
	-- max_safehouse_rooms()
	-- complete_safe_house_trophies()
	-- complete_all_side_jobs()
	-- complete_career()
	managers.mission._fading_debug_output:script().log('Change Asset',  Color.yellow)
end

call_all()
