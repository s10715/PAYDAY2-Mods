-- only available in inventory menu and briefing
if Utils:IsInHeist() then
	return
elseif managers.menu_component._player_inventory_gui then
elseif managers.menu_component._mission_briefing_gui and not managers.menu_component._mission_briefing_gui._ready then
else
	return
end

if not managers or not tweak_data or not Global
	or not managers.multi_profile or not managers.skilltree or not managers.skilltree._global or not managers.skilltree._global.specializations
	or not managers.blackmarket or not managers.blackmarket._global or not managers.blackmarket._global._selected_henchmen
	or not tweak_data.skilltree or not tweak_data.skilltree.specializations or not tweak_data.blackmarket or not tweak_data.blackmarket.armors
	or not tweak_data.blackmarket.projectiles or not tweak_data.blackmarket.deployables or not tweak_data.blackmarket.melee_weapons
	or not tweak_data.weapon or not tweak_data.weapon.factory or not tweak_data.weapon.factory.parts
	or not tweak_data.blackmarket.weapon_mods or not tweak_data.blackmarket.weapon_skins or not tweak_data.blackmarket.masks
	or not Global.blackmarket_manager or not Global.blackmarket_manager.crafted_items or not Global.blackmarket_manager.crafted_items["primaries"]
	or not Global.blackmarket_manager.crafted_items["secondaries"] or not Global.blackmarket_manager.crafted_items["masks"]
then
	return
end




local function get_skill_name_list()
	--[[
	local skill_name_list = {
		-- mastermind
		{{"combat_medic"}, {"tea_time","fast_learner"}, {"tea_cookies","medic_2x"}, {"inspire"}}, --medic
		{{"triathlete"}, {"cable_guy","joker"}, {"stockholm_syndrome","control_freak"}, {"black_marketeer"}}, --controller
		{{"stable_shot"}, {"rifleman","sharpshooter"}, {"spotter_teamwork","speedy_reload"}, {"single_shot_ammo_return"}}, --sharpshooter

		-- enforcer
		{{"underdog"}, {"shotgun_cqb","shotgun_impact"}, {"far_away","close_by"}, {"overkill"}}, --shotgunner
		{{"oppressor"}, {"show_of_force","pack_mule"}, {"iron_man","prison_wife"}, {"juggernaut"}}, --tank
		{{"scavenging"}, {"ammo_reservoir","portable_saw"}, {"ammo_2x","carbon_blade"}, {"bandoliers"}}, --ammo specialist

		-- technician
		{{"defense_up"}, {"sentry_targeting_package","eco_sentry"}, {"engineering","jack_of_all_trades"}, {"tower_defense"}}, --engineer
		{{"hardware_expert"}, {"combat_engineering","drill_expert"}, {"more_fire_power","kick_starter"}, {"fire_trap"}}, --breacher
		{{"steady_grip"}, {"heavy_impact","fire_control"}, {"shock_and_awe","fast_fire"}, {"body_expertise"}}, --oppressor

		-- ghost
		{{"jail_workout"}, {"cleaner","chameleon"}, {"second_chances","ecm_booster"}, {"ecm_2x"}}, --shinobi
		{{"sprinter"}, {"awareness","thick_skin"}, {"dire_need","insulation"}, {"jail_diet"}}, --artful dodger
		{{"scavenger"}, {"optic_illusions","silence_expert"}, {"backstab","hitman"}, {"unseen_strike"}}, --silent killer

		-- hoxton
		{{"equilibrium"}, {"dance_instructor","akimbo"}, {"gun_fighter","expert_handling"}, {"trigger_happy"}}, --gunslinger
		{{"nine_lives"}, {"running_from_death","up_you_go"}, {"perseverance","feign_death"}, {"messiah"}}, --revenant
		{{"martial_arts"}, {"bloodthirst","steroids"}, {"drop_soap","wolverine"}, {"frenzy"}} --brawler
	}
	]]--

	local skill_name_list = {}
	local empty_skilltree = {}
	local tree_idx = 1
	local tier_idx = 1
	for _, tree in pairs(tweak_data and tweak_data.skilltree and tweak_data.skilltree.trees or {}) do
		if not skill_name_list[tree_idx] then skill_name_list[tree_idx] = {} end
		if not empty_skilltree[tree_idx] then empty_skilltree[tree_idx] = {} end
		for _, tier in pairs(tree and tree.tiers or {}) do
			if not skill_name_list[tree_idx][tier_idx] then skill_name_list[tree_idx][tier_idx] = {} end
			if not empty_skilltree[tree_idx][tier_idx] then empty_skilltree[tree_idx][tier_idx] = {} end
			for _, skill in pairs(tier or {}) do
				table.insert(skill_name_list[tree_idx][tier_idx], skill)
				table.insert(empty_skilltree[tree_idx][tier_idx], 0)
			end
			tier_idx = tier_idx + 1
		end
		tree_idx = tree_idx + 1
		tier_idx = 1
	end
	return skill_name_list, empty_skilltree
end

local skill_point_cost_list = tweak_data and tweak_data.skilltree and tweak_data.skilltree.tier_cost or {{1,3},{2,4},{3,6},{4,8}}

local function get_current_skilltree()
	--[[
	local skilltree = {
		--[0] - skill not purchased
		--[1] - basic 
		--[2] - aced
		{{0}, {0,0}, {0,0}, {0}}, --medic
		{{0}, {0,0}, {0,0}, {0}}, --controller
		{{0}, {0,0}, {0,0}, {0}}, --sharpshooter
		{{0}, {0,0}, {0,0}, {0}}, --shotgunner
		{{0}, {0,0}, {0,0}, {0}}, --tank
		{{0}, {0,0}, {0,0}, {0}}, --ammo specialist
		{{0}, {0,0}, {0,0}, {0}}, --engineer
		{{0}, {0,0}, {0,0}, {0}}, --breacher
		{{0}, {0,0}, {0,0}, {0}}, --oppressor
		{{0}, {0,0}, {0,0}, {0}}, --shinobi
		{{0}, {0,0}, {0,0}, {0}}, --artful dodger
		{{0}, {0,0}, {0,0}, {0}}, --silent killer
		{{0}, {0,0}, {0,0}, {0}}, --gunslinger
		{{0}, {0,0}, {0,0}, {0}}, --revenant
		{{0}, {0,0}, {0,0}, {0}}, --brawler
	}
	]]--

	local skill_name_list, skilltree = get_skill_name_list()
	for tree_idx, tree in pairs(type(skilltree) == "table" and skilltree or {}) do
		for tier_idx, tier in pairs(type(tree) == "table" and tree or {}) do
			for skill_idx, skill in pairs(type(tier) == "table" and tier or {}) do
				if skill_name_list and skill_name_list[tree_idx] and skill_name_list[tree_idx][tier_idx] and skill_name_list[tree_idx][tier_idx][skill_idx] then
					local skill_name = skill_name_list[tree_idx][tier_idx][skill_idx]
					skilltree[tree_idx][tier_idx][skill_idx] = managers.skilltree:next_skill_step(skill_name) - 1
				end
			end
		end
	end
	return skilltree
end

local function get_spent_skill_point(skill_trees)
	local skill_name_list, _ = get_skill_name_list()
	local point = 0
	for tree_idx, tree in pairs(type(skill_trees) == "table" and skill_trees or {}) do
		for tier_idx, tier in pairs(type(tree) == "table" and tree or {}) do
			for skill_idx, skill in pairs(type(tier) == "table" and tier or {}) do
				skill = tonumber(skill)
				-- prevent getting invalid skill_trees, need to check if skill have corresponding name
				if skill and skill > 0 and skill <= 2 and skill_name_list and skill_name_list[tree_idx] and skill_name_list[tree_idx][tier_idx] and skill_name_list[tree_idx][tier_idx][skill_idx] then
					-- aced skill need to add twice
					for i = 1, skill do
						if skill_point_cost_list[tier_idx][i] then
							point = point + skill_point_cost_list[tier_idx][i]
						end
					end
				end
			end
		end
	end
	return point
end


-- category: "primaries" or "secondaries"
local function get_weapon_attachments(category, slot)
	if not managers.blackmarket or not managers.blackmarket:get_crafted_category_slot(category, slot) then return nil, nil, nil, nil, nil end

	local weapon = managers.blackmarket:get_crafted_category_slot(category, slot)
	local weapon_name = weapon.weapon_id
	local weapon_skin_name = weapon.cosmetics and weapon.cosmetics.id or nil
	local weapon_skin_bonus = weapon.cosmetics and weapon.cosmetics.bonus or nil
	-- local weapon_skin_attachments = table.list_to_set(weapon_skin_name and tweak_data.blackmarket.weapon_skins[weapon_skin_name] and tweak_data.blackmarket.weapon_skins[weapon_skin_name].default_blueprint or {})
	-- get equipped attachments (including skin attachments and some internal attachments)
	local weapon_attachments = {}
	for _, attachment_name in pairs(weapon.blueprint or {}) do
		if tweak_data.blackmarket.weapon_mods[attachment_name] then
			-- remove duplicates
			local is_duplicated = false
			for _, name in pairs(weapon_attachments or {}) do
				if name == attachment_name then
					is_duplicated = true
					break
				end
			end
			if not is_duplicated then
				table.insert(weapon_attachments, attachment_name)
			end
		end
	end
	-- print attachments to string
	local attachment_string = ""
	for idx, attachment_name in pairs(weapon_attachments) do
		attachment_string = attachment_string .. tostring(attachment_name)
		if idx ~= #weapon_attachments then
			attachment_string = attachment_string .. ","
		end
	end
	return attachment_string, weapon_name, weapon_skin_name, weapon_skin_bonus, weapon_attachments
end

-- check if weapon at slot and with given category match those name, skin and attachments
local function check_weapon(category, slot, weapon_name, weapon_skin_name, weapon_skin_bonus, _weapon_attachments)
	local _, slot_weapon_name, slot_skin_name, slot_skin_bonus, slot_attachments = get_weapon_attachments(category, slot)
	-- compare weapon name
	if not weapon_name or weapon_name == "" or not slot_weapon_name or weapon_name ~= slot_weapon_name then
		return false
	end
	-- compare skin name
	local ignore_skin = false
	if weapon_skin_name and weapon_skin_name ~= "" and not tweak_data.blackmarket.weapon_skins[weapon_skin_name] then
		-- ignore invalid skin name
		weapon_skin_name = nil
	elseif weapon_skin_name and weapon_skin_name ~= "" and not tweak_data.blackmarket.weapon_skins[weapon_skin_name].is_a_color_skin and not managers.blackmarket:have_inventory_tradable_item("weapon_skins", weapon_skin_name) then
		-- if do not have that skin, then don't compare skin name, and ignore skin attachments and internal attachments that can't buy
		ignore_skin = true
	end
	if weapon_skin_name and weapon_skin_name ~= "" and not ignore_skin and weapon_skin_name ~= slot_skin_name then
		return false
	elseif (not weapon_skin_name or weapon_skin_name == "") and slot_skin_name then
		return false
	elseif weapon_skin_name and weapon_skin_name ~= "" and not ignore_skin and weapon_skin_name == slot_skin_name then
		local have_skin_with_bonus = false
		local have_skin_without_bonus = false
		for instance_id, data in pairs(managers.blackmarket._global.inventory_tradable or {}) do
			if instance_id and data and (data.entry == slot_skin_name or data.id == slot_skin_name) then
				if data.bonus then
					have_skin_with_bonus = true
				else
					have_skin_without_bonus = true
				end
			end
		end
		if weapon_skin_bonus and have_skin_with_bonus and not slot_skin_bonus then
			-- if do not have skin with bonus, then ignore skin bonus, or bonus must be the same
			return false
		elseif not weapon_skin_bonus and have_skin_without_bonus and slot_skin_bonus then
			-- if do not have skin without bonus, then ignore skin bonus, or bonus must be the same
			return false
		end
	end
	-- compare attachments
	local weapon_attachments = {} -- deep clone
	for _, attachment_name in pairs(type(_weapon_attachments) == "table" and _weapon_attachments or {}) do
		table.insert(weapon_attachments, attachment_name)
	end
	local compared_attachments = {} -- remove duplicates
	for i, weapon_attachment_name in pairs(weapon_attachments or {}) do
		for j, slot_attachment_name in pairs(slot_attachments or {}) do
			if weapon_attachment_name == slot_attachment_name then
				weapon_attachments[i] = nil
				slot_attachments[j] = nil
				compared_attachments[weapon_attachment_name] = true
			end
		end
	end
	-- some skin (like legendary skins) will replace some internal standard attachments to internal legend attachments, which are both inaccessible attachments, if don't have that skin, need to ignore all internal attachments
	for _, attachment_name in pairs(weapon_attachments or {}) do
		if attachment_name and attachment_name ~= "" and not compared_attachments[attachment_name] and tweak_data.blackmarket.weapon_mods[attachment_name] then
			if ignore_skin and tweak_data.blackmarket.weapon_mods[attachment_name].inaccessible then
			else
				return false
			end
		end
	end
	for _, attachment_name in pairs(slot_attachments or {}) do
		if attachment_name and attachment_name ~= "" and not compared_attachments[attachment_name] and tweak_data.blackmarket.weapon_mods[attachment_name] then
			if ignore_skin and tweak_data.blackmarket.weapon_mods[attachment_name].inaccessible then
			else
				return false
			end
		end
	end
	return true
end

local function buy_weapon(category, slot, weapon_name, weapon_skin_name, weapon_skin_bonus, _weapon_attachments)
	if not category or not slot or type(slot) ~= "number" or not weapon_name or weapon_name == "" then return end
	if managers.blackmarket:get_crafted_category_slot(category, slot) then -- if that solt already have weapon
		return
		-- managers.blackmarket:on_sell_weapon(category, slot)
	end
	-- check if weapon belongs to category
	local is_weapon_belonging_to_category = false
	local category_weapons = managers.blackmarket:get_weapon_category(category)
	for _, category_weapon in pairs(category_weapons or {}) do
		if category_weapon and category_weapon.weapon_id == weapon_name then
			is_weapon_belonging_to_category = true
		end
	end
	if not is_weapon_belonging_to_category then
		return
	end
	-- buy weapon
	managers.blackmarket:on_buy_weapon_platform(category, weapon_name, slot)
	managers.mission:call_global_event(Message.OnWeaponBought)
	local weapon = managers.blackmarket:get_crafted_category_slot(category, slot)
	if not weapon then return end
	-- equip weapon skin
	if weapon_skin_name and weapon_skin_name ~= "" and tweak_data.blackmarket.weapon_skins[weapon_skin_name] then
		if tweak_data.blackmarket.weapon_skins[weapon_skin_name].is_a_color_skin then
			local cosmetics = {
				id = weapon_skin_name,
				instance_id = weapon_skin_name,
				quality = "mint",
				pattern_scale = 1,
				color_index = 1,
			}
			local update_weapon_unit = false
			managers.blackmarket:on_equip_weapon_color(category, slot, cosmetics, update_weapon_unit)
		elseif managers.blackmarket:have_inventory_tradable_item("weapon_skins", weapon_skin_name) and tweak_data.blackmarket.weapon_skins[weapon_skin_name].weapon_id == weapon_name then
			local target_instance_id = nil
			for instance_id, data in pairs(managers.blackmarket._global.inventory_tradable or {}) do
				if instance_id and data and (data.entry == weapon_skin_name or data.id == weapon_skin_name) then
					if weapon_skin_bonus and data.bonus then -- if assigned skin with bonus and find skin with bonus
						target_instance_id = instance_id
						break
					elseif not weapon_skin_bonus and not data.bonus then -- if do not assign skin with bonus and find skin without bonus
						target_instance_id = instance_id
						break
					elseif ((weapon_skin_bonus and not data.bonus) or (not weapon_skin_bonus and data.bonus)) and not target_instance_id then -- cache the first skin that is found if didn't find full match yet
						target_instance_id = instance_id
					end
				end
			end
			if target_instance_id then
				managers.blackmarket:on_equip_weapon_cosmetics(category, slot, target_instance_id)
			end
		end
	end
	local weapon_attachments = {} -- deep clone
	-- check if attachment belongs to weapon
	for _, attachment_name in pairs(type(_weapon_attachments) == "table" and _weapon_attachments or {}) do
		if attachment_name and attachment_name ~= "" and tweak_data.blackmarket.weapon_mods[attachment_name] then
			local uses_part_weapons = table.list_to_set(managers.weapon_factory:get_weapons_uses_part(attachment_name))
			if weapon and weapon.factory_id and uses_part_weapons[weapon.factory_id] then
				if not table.list_to_set(weapon_attachments or {})[attachment_name] then -- remove duplicates
					table.insert(weapon_attachments, attachment_name)
				end
			end
		end
	end
	-- check missing attachments
	local attachments_need_to_buy = {}
	for _, attachment_name in pairs(weapon_attachments or {}) do
		local global_value = managers.blackmarket:get_global_value("weapon_mods", attachment_name)
		if global_value and not managers.blackmarket:has_item(global_value, "weapon_mods", attachment_name) then
			table.insert(attachments_need_to_buy, attachment_name)
		end
	end
	-- remove normal skin attachments, because need to keep that slot empty if didn't use any attachment
	local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(weapon.factory_id)
	for idx, attachment_name in pairs(weapon.blueprint or {}) do
		if attachment_name and attachment_name ~= "" and tweak_data.blackmarket.weapon_mods[attachment_name] and not tweak_data.blackmarket.weapon_mods[attachment_name].inaccessible then
			weapon.blueprint[idx] = nil
			-- some standard/internal attachments might be replaced to normal attachments by the skin, need to restore to default one after removing attachments
			local default_attachment_replacement = nil
			for _, default_attachment_name in pairs(default_blueprint or {}) do
				if tweak_data.weapon.factory.parts[attachment_name] and tweak_data.weapon.factory.parts[default_attachment_name] and tweak_data.weapon.factory.parts[attachment_name].type == tweak_data.weapon.factory.parts[default_attachment_name].type then
					default_attachment_replacement = default_attachment_name
					break
				end
			end
			if default_attachment_replacement then
				table.insert(weapon.blueprint, default_attachment_replacement)
			end
		end
	end
	local new_blueprint = {}
	for _, attachment_name in pairs(weapon.blueprint or {}) do
		table.insert(new_blueprint, attachment_name)
	end
	weapon.blueprint = new_blueprint
	-- get attachments that already equip at the weapon we just bought (internal attachments and internal skin attachments)
	local exclude_attachments = {}
	for _, attachment_name in pairs(weapon.blueprint or {}) do
		if attachment_name and attachment_name ~= "" then
			exclude_attachments[attachment_name] = true
		end
	end
	-- buy missing attachments
	for _, attachment_name in pairs(attachments_need_to_buy) do
		if not exclude_attachments[attachment_name] and not tweak_data.blackmarket.weapon_mods[attachment_name].inaccessible and not tweak_data.blackmarket.weapon_mods[attachment_name].is_a_unlockable then
			local global_value = managers.blackmarket:get_global_value("weapon_mods", attachment_name)
			local not_new = true
			managers.blackmarket:add_to_inventory(global_value, "weapon_mods", attachment_name, not_new)
			local coin_cost = BlackMarketGui:get_weapon_mod_coin_cost(attachment_name)
			if coin_cost <= managers.custom_safehouse:coins() then
				local prefix = TelemetryConst.economy_origin.purchase_weapon_mod
				managers.custom_safehouse:deduct_coins(coin_cost, prefix .. attachment_name)
			end
		end
	end
	-- equip attachments
	local modify_fail_attachments = {}
	for _, attachment_name in pairs(weapon_attachments or {}) do
		if not exclude_attachments[attachment_name] and not tweak_data.blackmarket.weapon_mods[attachment_name].inaccessible then
			local global_value = managers.blackmarket:get_global_value("weapon_mods", attachment_name)
			local free = false
			local no_consume = tweak_data.blackmarket.weapon_mods[attachment_name].is_a_unlockable
			local money_cost = managers.money:get_weapon_modify_price(weapon_name, weapon_attachments, global_value)
			if money_cost >= managers.money:total() then
				free = true
			end
			managers.blackmarket:buy_and_modify_weapon(category, slot, global_value, attachment_name, free, no_consume)
			local is_modify_fail = true
			for _, equipped_attachment_name in pairs(weapon.blueprint or {}) do
				if equipped_attachment_name == attachment_name then
					is_modify_fail = false
				end
			end
			if is_modify_fail then
				table.insert(modify_fail_attachments, attachment_name)
			end
		end
	end
	-- there are dependencies between certain attachments, for example, you need to equip primary sights first, and then you can equip secondary sight, or you will fail modifying
	-- attachments that fail modifying will be consumed and won't give them back, so need to buy those attachments again, and buy with no cost
	-- there may be conflicts between certain attachments, such as dragon's breath bullet conflict with suppressor, so there're some attachments that can't bought no matter how hard you try, so try modify_fail_attachments_count times at top
	local modify_fail_attachments_count = #modify_fail_attachments
	for i = 1, modify_fail_attachments_count do
		for idx, attachment_name in pairs(modify_fail_attachments) do
			local global_value = managers.blackmarket:get_global_value("weapon_mods", attachment_name)
			if global_value then
				if not exclude_attachments[attachment_name] and not tweak_data.blackmarket.weapon_mods[attachment_name].inaccessible and not tweak_data.blackmarket.weapon_mods[attachment_name].is_a_unlockable then
					local not_new = true
					managers.blackmarket:add_to_inventory(global_value, "weapon_mods", attachment_name, not_new)
				end
				local free = true
				local no_consume = tweak_data.blackmarket.weapon_mods[attachment_name].is_a_unlockable
				managers.blackmarket:buy_and_modify_weapon(category, slot, global_value, attachment_name, free, no_consume)
				for _, equipped_attachment_name in pairs(weapon.blueprint or {}) do
					if equipped_attachment_name == attachment_name then
						modify_fail_attachments[idx] = nil
					end
				end
			end
		end
	end
	managers.menu_component:post_event("item_buy")
	managers.menu_component:reload_blackmarket_gui()
end

local function get_build()
	local build_string = ""

	-- Profile Name
	local profile_name = managers.multi_profile:current_profile_name()
	local default_profile_name = "Profile " .. tostring(managers.multi_profile._global._current_profile)
	if profile_name and profile_name ~= default_profile_name then
		build_string = build_string .. "profile_name=" .. tostring(profile_name) .. "\n"
	end
	-- Skill Switch Name
	local skill_switch_name = managers.skilltree:get_skill_switch_name(managers.skilltree:get_selected_skill_switch(), false)
	local default_skill_switch_name = managers.skilltree:get_default_skill_switch_name(managers.skilltree:get_selected_skill_switch())
	if skill_switch_name and skill_switch_name ~= default_skill_switch_name then
		build_string = build_string .. "skill_switch_name=" .. tostring(skill_switch_name) .. "\n"
	end
	-- Skill Trees
	local skill_trees = get_current_skilltree()
	if get_spent_skill_point(skill_trees) <= managers.skilltree:max_points_for_current_level() then
		build_string = build_string .. "skill_trees={"
		for tree_idx, tree in pairs(type(skill_trees) == "table" and skill_trees or {}) do
			build_string = build_string .. "{"
			for tier_idx, tier in pairs(type(tree) == "table" and tree or {}) do
				build_string = build_string .. "{"
				for skill_idx, skill in pairs(type(tier) == "table" and tier or {}) do
					build_string = build_string .. tostring(skill)
					if skill_idx ~= #tier then
						build_string = build_string .. ","
					end
				end
				build_string = build_string .. "}"
				if tier_idx ~= #tree then
					build_string = build_string .. ","
				end
			end
			build_string = build_string .. "}"
			if tree_idx ~= #skill_trees then
				build_string = build_string .. ","
			end
		end
		build_string = build_string .. "}\n"
	end
	-- Perk deck
	local perk_deck = tonumber(managers.skilltree:get_specialization_value("current_specialization"))
	if perk_deck and tweak_data.skilltree.specializations[perk_deck] then
		build_string = build_string .. "perk_deck=" .. tostring(perk_deck)
		-- get choice for each card
		local tree_data = managers.skilltree._global.specializations and managers.skilltree._global.specializations[perk_deck]
		if tree_data and tree_data.choices then
			for idx, specialization_data in pairs(tweak_data.skilltree.specializations[perk_deck] or {}) do
				if specialization_data then
					local multi_choice = specialization_data.multi_choice
					local choice_index = tree_data.choices[idx] and managers.skilltree:digest_value(tree_data.choices[idx], false)
					if multi_choice and choice_index then
						build_string = build_string .. ",card_" .. tostring(idx) .. "=" .. tostring(choice_index)
					end
				end
			end
		end
		build_string = build_string .. "\n"
	end
	-- Armor
	local armor_name = managers.blackmarket:equipped_armor()
	if tweak_data.blackmarket.armors[armor_name] then
		build_string = build_string .. "armor=" .. tostring(armor_name) .. "\n"
	end
	-- Projectile
	if (managers.blackmarket:equipped_grenade() ~= "none") then
		local projectile_name = managers.blackmarket:equipped_grenade()
		if tweak_data.blackmarket.projectiles[projectile_name] then
			build_string = build_string .. "projectile=" .. tostring(projectile_name) .. "\n"
		end
	end
	-- Deployable
	for slot = 1, 2 do
		if (managers.blackmarket:equipped_deployable(slot) ~= "none") then
			local deployable_name = managers.blackmarket:equipped_deployable(slot)
			if tweak_data.blackmarket.deployables[deployable_name] then
				build_string = build_string .. "deployable_" .. tostring(slot) .. "=" .. tostring(deployable_name) .. "\n"
			end
		end
	end
	-- Primary Weapon and Secondary Weapon
	local weapon_categories = { ["primary_weapon"]="primaries", ["secondary_weapon"]="secondaries" }
	for weapon_flag, weapon_category in pairs(weapon_categories) do
		local weapon_slot = managers.blackmarket:equipped_weapon_slot(weapon_category)
		local weapon_name = Global.blackmarket_manager.crafted_items[weapon_category][weapon_slot] and Global.blackmarket_manager.crafted_items[weapon_category][weapon_slot].weapon_id
		if tweak_data.weapon[weapon_name] then
			build_string = build_string .. weapon_flag .. "=" .. weapon_name
			local attachment_string, _, weapon_skin_name, weapon_skin_bonus, _ = get_weapon_attachments(weapon_category, weapon_slot)
			if weapon_skin_name and weapon_skin_name ~= "" then
				build_string = build_string .. ",skin=" .. weapon_skin_name
			end
			if weapon_skin_bonus and weapon_skin_bonus ~= "" then
				build_string = build_string .. ",skin_bonus=" .. tostring(weapon_skin_bonus)
			end
			if attachment_string and attachment_string ~= "" then
				build_string = build_string .. "," .. attachment_string
			end
			build_string = build_string .. "\n"
		end
	end
	-- Melee Weapon
	-- local melee_weapons = managers.blackmarket:get_sorted_melee_weapons(true, true)
	local melee_weapon_name = managers.blackmarket:equipped_melee_weapon()
	if tweak_data.blackmarket.melee_weapons[melee_weapon_name] then
		build_string = build_string .. "melee_weapon=" .. tostring(melee_weapon_name) .. "\n"
	end
	-- Mask
	local mask_slot = managers.blackmarket:equipped_mask_slot()
	local mask_name = Global.blackmarket_manager.crafted_items["masks"][mask_slot] and Global.blackmarket_manager.crafted_items["masks"][mask_slot].mask_id
	if tweak_data.blackmarket.masks[mask_name] then
		build_string = build_string .. "mask=" .. tostring(mask_name) .. "\n"
	end
	-- Crew data
	for idx, henchmen_data in pairs(managers.blackmarket._global._selected_henchmen or {}) do
		local crew_skill = managers.blackmarket:verify_has_crew_skill(henchmen_data.skill) and henchmen_data.skill
		local crew_ability = managers.blackmarket:verify_has_crew_ability(henchmen_data.ability) and henchmen_data.ability
		local valid = managers.blackmarket:_verify_crew_weapon("primaries", henchmen_data.primary, henchmen_data.primary_slot)
		local crew_weapon_slot = valid and henchmen_data.primary_slot or nil
		local crew_weapon_name = valid and henchmen_data.primary or nil
		if crew_skill then
			build_string = build_string .. "crew_" .. tostring(idx) .. "_skill=" .. crew_skill .. ","
		end
		if crew_ability then
			build_string = build_string .. "crew_" .. tostring(idx) .. "_ability=" .. crew_ability .. ","
		end
		if Global.blackmarket_manager.crafted_items["primaries"][crew_weapon_slot] then
			build_string = build_string .. "crew_" .. tostring(idx) .. "_weapon=" .. crew_weapon_name .. ","
			build_string = build_string .. "crew_" .. tostring(idx) .. "_weapon_real_name=" .. Global.blackmarket_manager.crafted_items["primaries"][crew_weapon_slot].weapon_id .. ","
			local crew_attachment_string, _, crew_weapon_skin_name, crew_weapon_skin_bonus, _ = get_weapon_attachments("primaries", crew_weapon_slot)
			if crew_weapon_skin_name and crew_weapon_skin_name ~= "" then
				build_string = build_string .. "crew_weapon_skin=" .. crew_weapon_skin_name .. ","
			end
			if crew_weapon_skin_bonus and crew_weapon_skin_bonus ~= "" then
				build_string = build_string .. "crew_weapon_skin_bonus=" .. tostring(crew_weapon_skin_bonus) .. ","
			end
			if crew_attachment_string and crew_attachment_string ~= "" then
				build_string = build_string .. crew_attachment_string .. ","
			end
		end
		if crew_skill or crew_ability or Global.blackmarket_manager.crafted_items["primaries"][crew_weapon_slot] then
			build_string = build_string .. "\n"
		end
	end

	return build_string
end

-- check_only: don't set build but only check if data is valid, like if dlcs are unlocked, and if user has enough skill point, and so on
local function set_build(build_string, check_only)
	local function starts_with(str, start)
		if str == nil or str == "" or start == nil or start == "" or string.len(start) > string.len(str) then
			return false
		end
		return string.sub(str, 1, string.len(start)) == start
	end
	local function remove_start(str, start)
		if not starts_with(str, start) then
			return nil
		end
		return string.sub(str, string.len(start) + 1, string.len(str))
	end
	local function trim(str)
		return (string.gsub(str, "^%s*(.-)%s*$", "%1"))
	end
	local function parse_string_to_array(str)
		-- strings must be wrapped in double quotes, numbers must be in decimal. Do not contain function, brace or other special characters
		local exps, result = {}, {}
		local function save(value)
			exps[#exps + 1] = value
			return ('\0'):rep(#exps)
		end
		str = str:gsub('%b{}', function(s) return save({ parse_string_to_array(s:sub(2, -2)) }) end) -- arrays
		str = str:gsub('"(.-)"', save) -- strings
		str = str:gsub('%-?%d+', function(s) return save(tonumber(s)) end) -- integer numbers
		for k in string.gmatch(str, '%z+') do
			result[#result + 1] = exps[#k]
		end
		return (table.unpack or unpack)(result)
	end

	local check_error = {
		missing_dlcs={},
		skill_trees_error=false, perk_deck_error=false, armor_error=false, projectile_error=false, deployable_error=fasle,
		primary_weapon_error=false, primary_weapon_attachment_error=false, secondary_weapon_error=false, secondary_weapon_attachment_error=false,
		weapon_empty_slot_error=false, melee_weapon_error=false, mask_error=false,
		crew_skill_error=false, crew_ability_error=false,
		crew_weapon_error=false, crew_weapon_attachment_error=false, crew_weapon_empty_slot_error=false
	}
	local function check_dlc(dlc_name, missing_dlcs_cache)
		if dlc_name and not managers.dlc:is_dlc_unlocked(dlc_name) then
			missing_dlcs_cache[dlc_name] = true
			return false
		end
		return true
	end

	local build_string_list = {}
	string.gsub(build_string, '[^'.. '\n' ..']+', function(str) table.insert(build_string_list, str) end)

	local has_reset_crew_data = false
	for _, line in pairs(build_string_list) do
		line = trim(line)
		if starts_with(line, "profile_name=") then -- Profile Name
			local profile_name = remove_start(line, "profile_name=")
			if not check_only and profile_name and profile_name ~= "" then
				managers.multi_profile:current_profile().name = profile_name
			end
		elseif starts_with(line, "skill_switch_name=") then -- Skill Switch Name
			local skill_switch_name = remove_start(line, "skill_switch_name=")
			if not check_only and skill_switch_name and skill_switch_name ~= "" then
				managers.skilltree:set_skill_switch_name(managers.skilltree:get_selected_skill_switch(), skill_switch_name)
			end
		elseif starts_with(line, "skill_trees=") then -- Skill Trees
			local skill_trees = parse_string_to_array(remove_start(line, "skill_trees="))
			if check_only then
				check_error.skill_trees_error = (get_spent_skill_point(skill_trees) > managers.skilltree:max_points_for_current_level())
			elseif get_spent_skill_point(skill_trees) <= managers.skilltree:max_points_for_current_level() then
				local skill_name_list, _ = get_skill_name_list()
				-- to set new trees, you need to refund current skills first, and need to refund from the top of each tree
				local current_skill_trees = get_current_skilltree()
				for tree_idx, tree in pairs(type(current_skill_trees) == "table" and current_skill_trees or {}) do
					for j = #tree, 1, -1 do
						local tier_idx = j
						local tier = tree[j]
						for skill_idx, _ in pairs(type(tier) == "table" and tier or {}) do
							if skill_name_list and skill_name_list[tree_idx] and skill_name_list[tree_idx][tier_idx] and skill_name_list[tree_idx][tier_idx][skill_idx] then
								local skill_name = skill_name_list[tree_idx][tier_idx][skill_idx]
								local skill_level = managers.skilltree:skill_step(skill_name)
								while skill_level > 0 and skill_level <= 2 do
									if managers.skilltree:refund_skill(tree_idx, tier_idx, skill_name) then
										local skill_point_cost = skill_point_cost_list[tier_idx][skill_level]
										managers.skilltree:refund_points(skill_point_cost)
										managers.skilltree:_set_points_spent(tree_idx, managers.skilltree:points_spent(tree_idx) - skill_point_cost)
									end
									skill_level = managers.skilltree:skill_step(skill_name)
								end
							end
						end
					end
				end
				-- setting skill, aced skill need to set twice
				for tree_idx, tree in pairs(type(skill_trees) == "table" and skill_trees or {}) do
					for tier_idx, tier in pairs(type(tree) == "table" and tree or {}) do
						for skill_idx, skill in pairs(type(tier) == "table" and tier or {}) do
							skill = tonumber(skill)
							if skill and skill > 0 and skill <= 2 and skill_name_list and skill_name_list[tree_idx] and skill_name_list[tree_idx][tier_idx] and skill_name_list[tree_idx][tier_idx][skill_idx] then
								local skill_name = skill_name_list[tree_idx][tier_idx][skill_idx]
								for i = 1, skill do
									if managers.skilltree:has_enough_skill_points(skill_name) and managers.skilltree:unlock(skill_name) then
										local skill_level = managers.skilltree:skill_step(skill_name)
										local points = managers.skilltree:skill_cost(tier_idx, skill_level)
										local skill_points = managers.skilltree:spend_points(points)
										managers.skilltree:_set_points_spent(tree_idx, managers.skilltree:points_spent(tree_idx) + points)
									end
								end
							end
						end
					end
				end
			end
		elseif starts_with(line, "perk_deck=") then -- Perk deck
			local perk_deck = nil
			local card_data = {}
			-- load perk_deck
			string.gsub(line, '[^'.. ',' ..']+', function(str)
				if starts_with(str, "perk_deck=") then
					perk_deck = tonumber(remove_start(str, "perk_deck="))
				end
			end)
			if check_only then
				if not perk_deck or not tweak_data.skilltree.specializations[perk_deck] then
					check_error.perk_deck_error = true
				else
					check_error.perk_deck_error = not check_dlc(tweak_data.skilltree.specializations[perk_deck].dlc, check_error.missing_dlcs)
				end
			elseif perk_deck and tweak_data.skilltree.specializations[perk_deck] then
				-- set perk_deck
				managers.skilltree:set_current_specialization(managers.skilltree:digest_value(perk_deck, false), 1)
				-- load card_data
				local tree_data = managers.skilltree._global.specializations and managers.skilltree._global.specializations[perk_deck]
				if tree_data and not tree_data.choices then tree_data.choices = {} end
				for idx, specialization_data in pairs(tweak_data.skilltree.specializations[perk_deck] or {}) do
					if specialization_data.multi_choice then
						string.gsub(line, '[^'.. ',' ..']+', function(str)
							if starts_with(str, "card_" .. tostring(idx) .. "=") then
								card_data[idx] = tonumber(remove_start(str, "card_" .. tostring(idx) .. "="))
							end
						end)
						if tree_data then -- reset card_data
							tree_data.choices[idx] = 1
						end
					end
				end
				-- set card_data
				for idx, choice in pairs(card_data or {}) do
					if choice and tree_data then
						tree_data.choices[idx] = managers.skilltree:digest_value(choice, true)
					end
				end
			end
		elseif starts_with(line, "armor=") then -- Armor
			local armor_name = remove_start(line, "armor=")
			if check_only then
				if not armor_name or not tweak_data.blackmarket.armors[armor_name] then
					check_error.armor_error = true
				end
			elseif armor_name and armor_name ~= "" and tweak_data.blackmarket.armors[armor_name] then
				managers.blackmarket:equip_armor(armor_name)
			end
		elseif starts_with(line, "projectile=") then -- Projectile
			local projectile_name = remove_start(line, "projectile=")
			if check_only then
				if not projectile_name or not tweak_data.blackmarket.projectiles[projectile_name] then
					check_error.projectile_error = true
				else
					check_error.projectile_error = not check_dlc(tweak_data.blackmarket.projectiles[projectile_name].dlc, check_error.missing_dlcs)
				end
			elseif projectile_name and projectile_name ~= "" and tweak_data.blackmarket.projectiles[projectile_name] then
				managers.blackmarket:equip_grenade(projectile_name)
			end
		elseif starts_with(line, "deployable_") then -- Deployable
			for slot = 1, 2 do
				local deployable_name = remove_start(line, "deployable_" .. tostring(slot) .. "=")
				if check_only then
					-- deployable can be empty
					if deployable_name and not tweak_data.blackmarket.deployables[deployable_name] then
						check_error.deployable_error = true
					end
					check_error.deployable_error = not check_dlc(deployable_name and tweak_data.blackmarket.deployables[deployable_name] and tweak_data.blackmarket.deployables[deployable_name].dlc, check_error.missing_dlcs) or check_error.deployable_error
				elseif deployable_name and deployable_name ~= "" and tweak_data.blackmarket.deployables[deployable_name] then
					managers.blackmarket:equip_deployable({ name=deployable_name, target_slot=slot })
				end
			end
		elseif starts_with(line, "primary_weapon=") or starts_with(line, "secondary_weapon=") then -- Primary Weapon and Secondary Weapon
			local weapon_category = nil
			local weapon_name = nil
			local weapon_skin_name = nil
			local weapon_skin_bonus = nil
			local weapon_attachments = {}
			string.gsub(line, '[^'.. ',' ..']+', function(str)
				if starts_with(str, "primary_weapon=") then
					weapon_category = "primaries"
					weapon_name = remove_start(str, "primary_weapon=")
				elseif starts_with(str, "secondary_weapon=") then
					weapon_category = "secondaries"
					weapon_name = remove_start(str, "secondary_weapon=")
				elseif starts_with(str, "skin=") then
					weapon_skin_name = remove_start(str, "skin=")
				elseif starts_with(str, "skin_bonus=") then
					weapon_skin_bonus = remove_start(str, "skin_bonus=")
				elseif str and str ~= "" then
					table.insert(weapon_attachments, str)
				end
			end)
			if check_only then
				if not weapon_name or not tweak_data.weapon[weapon_name] then
					if weapon_category == "primaries" then
						check_error.primary_weapon_error = true
					elseif weapon_category == "secondaries" then
						check_error.secondary_weapon_error = true
					end
				else
					if weapon_category == "primaries" then
						check_error.primary_weapon_error = not check_dlc(tweak_data.weapon[weapon_name].global_value, check_error.missing_dlcs)
					elseif weapon_category == "secondaries" then
						check_error.secondary_weapon_error = not check_dlc(tweak_data.weapon[weapon_name].global_value, check_error.missing_dlcs)
					end
				end
				for _, weapon_attachment in pairs(weapon_attachments) do
					if not weapon_attachment or not tweak_data.weapon.factory.parts[weapon_attachment] then
						if weapon_category == "primaries" then
							check_error.primary_weapon_attachment_error = true
						elseif weapon_category == "secondaries" then
							check_error.secondary_weapon_attachment_error = true
						end
					else
						if weapon_category == "primaries" then
							check_error.primary_weapon_attachment_error = not check_dlc(tweak_data.weapon.factory.parts[weapon_attachment].dlc, check_error.missing_dlcs)
						elseif weapon_category == "secondaries" then
							check_error.secondary_weapon_attachment_error = not check_dlc(tweak_data.weapon.factory.parts[weapon_attachment].dlc, check_error.missing_dlcs)
						end
					end
				end
				if not managers.blackmarket:_get_free_weapon_slot(weapon_category) then
					check_error.weapon_empty_slot_error = true
				end
			else
				local already_equipped = false
				local current_weapon_slot = managers.blackmarket:equipped_weapon_slot(weapon_category)
				if check_weapon(weapon_category, current_weapon_slot, weapon_name, weapon_skin_name, weapon_skin_bonus, weapon_attachments) then
					already_equipped = true
				end
				if not already_equipped then
					for slot, weapon in pairs(Global.blackmarket_manager.crafted_items[weapon_category] or {}) do
						if weapon and weapon.weapon_id == weapon_name and check_weapon(weapon_category, slot, weapon_name, weapon_skin_name, weapon_skin_bonus, weapon_attachments) then
							managers.blackmarket:equip_weapon(weapon_category, slot)
							already_equipped = true
							break
						end
					end
				end
				if not already_equipped then
					local empty_slot = managers.blackmarket:_get_free_weapon_slot(weapon_category)
					if empty_slot then
						buy_weapon(weapon_category, empty_slot, weapon_name, weapon_skin_name, weapon_skin_bonus, weapon_attachments)
						if managers.blackmarket:get_crafted_category_slot(weapon_category, empty_slot) then
							managers.blackmarket:equip_weapon(weapon_category, empty_slot)
						end
					end
				end
			end
		elseif starts_with(line, "melee_weapon=") then -- Melee Weapon
			local melee_weapon_name = remove_start(line, "melee_weapon=")
			if check_only then
				if not melee_weapon_name or not tweak_data.blackmarket.melee_weapons[melee_weapon_name] then
					check_error.melee_weapon_error = true
				else
					check_error.melee_weapon_error = not check_dlc(tweak_data.blackmarket.melee_weapons[melee_weapon_name].dlc, check_error.missing_dlcs)
				end
			elseif melee_weapon_name and melee_weapon_name ~= "" and tweak_data.blackmarket.melee_weapons[melee_weapon_name] then
				managers.blackmarket:equip_melee_weapon(melee_weapon_name)
			end
		elseif starts_with(line, "mask=") then -- Mask
			local mask_name = remove_start(line, "mask=")
			if check_only then
				if not mask_name or not tweak_data.blackmarket.masks[mask_name] then
					check_error.mask_error = true
				else
					check_error.mask_error = not check_dlc(tweak_data.blackmarket.masks[mask_name].dlc, check_error.missing_dlcs)
				end
			elseif mask_name and mask_name ~= "" and tweak_data.blackmarket.masks[mask_name] then
				local already_equipped = false
				local current_mask_slot = managers.blackmarket:equipped_mask_slot()
				if Global.blackmarket_manager.crafted_items["masks"][current_mask_slot] and Global.blackmarket_manager.crafted_items["masks"][current_mask_slot].mask_id == mask_name then
					already_equipped = true
				end
				if not already_equipped then
					for slot, mask in pairs(Global.blackmarket_manager.crafted_items["masks"] or {}) do
						if mask and mask.mask_id == mask_name then
							managers.blackmarket:equip_mask(slot)
							already_equipped = true
							break
						end
					end
				end
				if not already_equipped then
					local global_value = managers.blackmarket:get_global_value("masks", mask_name)
					local empty_slot = nil
					local max_slots = tweak_data.gui.MAX_MASK_SLOTS or 72
					for slot = 1, max_slots do
						if managers.blackmarket:is_mask_slot_unlocked(slot) and not Global.blackmarket_manager.crafted_items["masks"][slot] then
							empty_slot = slot
							break
						end 
					end
					if global_value and managers.blackmarket:has_item(global_value, "masks", mask_name) and empty_slot then
						managers.blackmarket:on_buy_mask_to_inventory(mask_name, global_value, empty_slot, nil)
						if Global.blackmarket_manager.crafted_items["masks"][empty_slot] then
							managers.blackmarket:equip_mask(empty_slot)
						end
					end
				end
			end
		elseif starts_with(line, "crew_") then -- Crew data
			if not check_only and not has_reset_crew_data then
				-- crew data can be none, if get any crew data, then clear all current crew data first
				for idx, henchmen_data in pairs(managers.blackmarket._global._selected_henchmen or {}) do
					if henchmen_data then
						henchmen_data.skill = nil
						henchmen_data.ability = nil
						henchmen_data.primary = nil
						henchmen_data.primary_slot = nil
					end
				end
				has_reset_crew_data = true
			end
			for idx, henchmen_data in pairs(managers.blackmarket._global._selected_henchmen or {}) do
				if starts_with(line, "crew_" .. tostring(idx)) then
					if not henchmen_data then henchmen_data = {} end
					local crew_skill = nil
					local crew_ability = nil
					local crew_weapon_name = nil
					local crew_weapon_real_name = nil
					local crew_weapon_skin_name = nil
					local crew_weapon_skin_bonus = nil
					local crew_weapon_attachments = {}
					string.gsub(line, '[^'.. ',' ..']+', function(str)
						if starts_with(str,  "crew_" .. tostring(idx) .. "_skill=") then
							crew_skill = remove_start(str, "crew_" .. tostring(idx) .. "_skill=")
						elseif starts_with(str, "crew_" .. tostring(idx) .. "_ability=") then
							crew_ability = remove_start(str, "crew_" .. tostring(idx) .. "_ability=")
						elseif starts_with(str, "crew_" .. tostring(idx) .. "_weapon=") then
							crew_weapon_name = remove_start(str, "crew_" .. tostring(idx) .. "_weapon=")
						elseif starts_with(str, "crew_" .. tostring(idx) .. "_weapon_real_name=") then
							crew_weapon_real_name = remove_start(str, "crew_" .. tostring(idx) .. "_weapon_real_name=")
						elseif starts_with(str, "crew_weapon_skin=") then
							crew_weapon_skin_name = remove_start(str, "crew_weapon_skin=")
						elseif starts_with(str, "crew_weapon_skin_bonus=") then
							crew_weapon_skin_bonus = remove_start(str, "crew_weapon_skin_bonus=")
						elseif str and str ~= "" then
							table.insert(crew_weapon_attachments, str)
						end
					end)
					if check_only then
						-- crew's skill, ability, weapon can be empty
						if crew_skill and not managers.blackmarket:verify_has_crew_skill(crew_skill) then
							check_error.crew_skill_error = true
						end
						if crew_ability and not managers.blackmarket:verify_has_crew_ability(crew_ability) then
							check_error.crew_ability_error = true
						end
						if crew_weapon_real_name and not tweak_data.weapon[crew_weapon_real_name] then
							check_error.crew_weapon_error = true
						end
						check_error.crew_weapon_error = not check_dlc(crew_weapon_real_name and tweak_data.weapon[crew_weapon_real_name] and tweak_data.weapon[crew_weapon_real_name].global_value, check_error.missing_dlcs) or check_error.crew_weapon_error
						for _, crew_weapon_attachment in pairs(crew_weapon_attachments) do
							if not crew_weapon_attachment or not tweak_data.weapon.factory.parts[crew_weapon_attachment] then
								check_error.crew_weapon_attachment_error = true
							else
								check_error.crew_weapon_attachment_error = not check_dlc(tweak_data.weapon.factory.parts[crew_weapon_attachment].dlc, check_error.missing_dlcs)
							end
						end
						if not managers.blackmarket:_get_free_weapon_slot("primaries") then
							check_error.crew_weapon_empty_slot_error = true
						end
					else
						if crew_skill and crew_skill ~= "" and managers.blackmarket:verify_has_crew_skill(crew_skill) then
							henchmen_data.skill = crew_skill
						end
						if crew_ability and crew_ability ~= "" and managers.blackmarket:verify_has_crew_ability(crew_ability) then
							henchmen_data.ability = crew_ability
						end
						if crew_weapon_name and crew_weapon_name ~= "" and crew_weapon_real_name and crew_weapon_real_name ~= "" then
							local already_equipped = false
							local current_crew_weapon_slot = managers.blackmarket:_verify_crew_weapon("primaries", henchmen_data.primary, henchmen_data.primary_slot) and henchmen_data.primary_slot or nil
							if check_weapon("primaries", current_crew_weapon_slot, crew_weapon_real_name, crew_weapon_skin_name, crew_weapon_skin_bonus, crew_weapon_attachments) then
								already_equipped = true
							end
							if not already_equipped then
								for slot, weapon in pairs(Global.blackmarket_manager.crafted_items["primaries"] or {}) do
									if weapon and weapon.weapon_id == crew_weapon_real_name and check_weapon("primaries", slot, crew_weapon_real_name, crew_weapon_skin_name, crew_weapon_skin_bonus, crew_weapon_attachments) then
										-- treat as equipped even if this weapon not available for crew as long as weapon information match
										already_equipped = true
										if managers.blackmarket:_verify_crew_weapon("primaries", crew_weapon_name, slot) then
											henchmen_data.primary = crew_weapon_name
											henchmen_data.primary_slot = slot
											break
										end
									end
								end
							end
							if not already_equipped then
								local empty_slot = managers.blackmarket:_get_free_weapon_slot("primaries")
								if empty_slot then
									buy_weapon("primaries", empty_slot, crew_weapon_real_name, crew_weapon_skin_name, crew_weapon_skin_bonus, crew_weapon_attachments)
									if managers.blackmarket:get_crafted_category_slot("primaries", empty_slot) then
										henchmen_data.primary = crew_weapon_name
										henchmen_data.primary_slot = empty_slot
									end
								end
							end
						end
					end
				end
			end
		end
	end

	if not check_only then
		-- refresh gui
		managers.menu_component:reload_inventory_gui()
		if managers.menu_component._mission_briefing_gui then
			managers.menu_component._mission_briefing_gui:reload()
		end
	else
		return check_error
	end
end

local function show_diag(title, text)
	local dialog_data = {
		focus_button = 1,
		title = title,
		text = text,
		use_text_formating = true,
		text_formating_color_table = {},
		type = "",
		font_size = tweak_data.menu.pd2_medium_font_size,
		button_list = {
			{ text = managers.localization:text("dialog_ok"), cancel_button = true, callback_func = function() managers.system_menu:force_close_all() end, },
		},
	}
	managers.system_menu:show(dialog_data)
end

local function check_and_set_build(build_string)
	local no_error = true
	local check_error = set_build(build_string, true)
	local error_msgs = {}
	for error_name, flag in pairs(check_error or {}) do
		if error_name == "missing_dlcs" and next(flag) then
			no_error = false
			local error_msg = "Missing DLCs: "
			for missing_dlc, _ in pairs(flag) do
				error_msg = error_msg .. tostring(missing_dlc) .. ", "
			end
			table.insert(error_msgs, 1, string.sub(error_msg, 1, -3))
		elseif flag == true then
			no_error = false
			if error_name == "skill_trees_error" then
				table.insert(error_msgs, "Not enough skill points.")
			elseif error_name == "perk_deck_error" then
				table.insert(error_msgs, "Invalid perk deck.")
			elseif error_name == "armor_error" then
				table.insert(error_msgs, "Invalid armor.")
			elseif error_name == "projectile_error" then
				table.insert(error_msgs, "Invalid projectile.")
			elseif error_name == "deployable_error" then
				table.insert(error_msgs, "Invalid deployable.")
			elseif error_name == "primary_weapon_error" then
				table.insert(error_msgs, "Invalid primary weapon data.")
			elseif error_name == "primary_weapon_attachment_error" then
				table.insert(error_msgs, "Invalid primary weapon attachment data.")
			elseif error_name == "secondary_weapon_error" then
				table.insert(error_msgs, "Invalid secondary weapon data.")
			elseif error_name == "secondary_weapon_attachment_error" then
				table.insert(error_msgs, "Invalid secondary weapon attachment data.")
			elseif error_name == "weapon_empty_slot_error" then
				table.insert(error_msgs, "Please ensure you have enough empty weapon slot to buy new weapon.")
			elseif error_name == "crew_weapon_empty_slot_error" then
				-- same with weapon_empty_slot_error, no need to repeat
			elseif error_name == "melee_weapon_error" then
				table.insert(error_msgs, "Invalid melee weapon.")
			elseif error_name == "mask_error" then
				table.insert(error_msgs, "Invalid mask name.")
			elseif error_name == "crew_skill_error" then
				table.insert(error_msgs, "Invalid crew skill.")
			elseif error_name == "crew_ability_error" then
				table.insert(error_msgs, "Invalid crew ability.")
			elseif error_name == "crew_weapon_error" then
				table.insert(error_msgs, "Invalid crew weapon data.")
			elseif error_name == "crew_weapon_attachment_error" then
				table.insert(error_msgs, "Invalid crew weapon attachment data.")
			end
		end
	end
	if no_error then
		set_build(build_string)
	else
		local msg_str = ""
		for idx, msg in pairs(error_msgs) do
			msg_str = msg_str .. "  " .. tostring(idx) .. ". " .. msg .. "\n"
		end
		local error_dialog = {
			focus_button = 1,
			title = "Warning",
			text = "Find error(s) below, still want to apply build? (error parts won't be applied, but weapons will still be bought even if missing dlcs)\n\n" .. msg_str,
			font_size = tweak_data.menu.pd2_medium_font_size,
			button_list = {
				{ text = managers.localization:text("dialog_yes"), callback_func = function()
					set_build(build_string)
					managers.system_menu:force_close_all()
				end, },
				{ text = managers.localization:text("dialog_no"), cancel_button = true, callback_func = function()
					managers.system_menu:force_close_all()
				end, },
			},
		}
		managers.system_menu:show(error_dialog)
	end
end


local function save_to_clipboard()
	local build_string = get_build()
	if build_string then
		Application:set_clipboard(build_string)
		show_diag("Success", "build save to clipboard")
	end
end

local function load_from_clipboard()
	check_and_set_build(Application:get_clipboard())
	--show_diag("Success", "load from clipboard success")
end


local file_suffix = ".profile"
local function save_to_file()
	local build_string = get_build()
	if build_string then
		local file_name = tostring(managers.multi_profile._global._current_profile)
		if managers.multi_profile:current_profile_name() and managers.multi_profile:current_profile_name() ~= "" then
			file_name = file_name .. "-" .. tostring(managers.multi_profile:current_profile_name())
		end
		if SystemFS:exists(tostring(ModPath) .. tostring(file_name) .. tostring(file_suffix)) then
			file_name = file_name .. "-" .. tostring(os.date("%Y%m%d-%H%M%S"))
		end
		local file = SystemFS:open(tostring(ModPath) .. tostring(file_name) .. tostring(file_suffix), "w")
		if file then
			file:write(build_string)
			file:close()
			show_diag("Success", "build save to: " .. tostring(file_name) .. tostring(file_suffix))
		end
	end
end

local function load_from_file()
	-- SystemFS can convert file name to UTF 8, so that non UTF-8 file name can be displayed in menu
	local files = SystemFS:list(tostring(ModPath))
	local profile_files = {}
	for _, file_name in pairs(files) do
		if string.sub(file_name, -string.len(tostring(file_suffix))) == tostring(file_suffix) then
			table.insert(profile_files, string.sub(file_name, 1, -string.len(tostring(file_suffix)) - 1))
		end
	end

	if next(profile_files) == nil then
		show_diag("Error", "build file not found")
		return
	end

	local dialog_data = {    
		title = "Load And Save Build",
		text = "select the build you want to load",
		button_list = {}
	}
	for _, file_name in pairs(profile_files) do
		table.insert(dialog_data.button_list, {
			text = file_name,
			callback_func = function()
				local file_path = tostring(ModPath) .. tostring(file_name) .. tostring(file_suffix)
				local file = SystemFS:open(file_path, "r")
				if file and not file:at_end() then
					local build_string = file:read()
					if build_string then
						check_and_set_build(build_string)
						--show_diag("Success", "load from file success")
					end
					SystemFS:close(file)
				end
			end,
		})
	end
	table.insert(dialog_data.button_list, { text = managers.localization:text("dialog_cancel"), cancel_button = true, callback_func = function() managers.system_menu:force_close_all() end, } )
	managers.system_menu:show_buttons(dialog_data)
end

local function show_main_menu()
	managers.system_menu:show({
		focus_button = 1,
		title = "Load And Save Build",
		text = "",
		use_text_formating = true,
		text_formating_color_table = {},
		type = "",
		font_size = tweak_data.menu.pd2_medium_font_size,
		button_list = {
			{ text = "save current build to clipboard", callback_func = function()
				managers.system_menu:force_close_all()
				save_to_clipboard()
			end, },
			{ text = "load build from clipboard", callback_func = function()
				managers.system_menu:force_close_all()
				load_from_clipboard()
			end, },
			{ text = "save current build to file", callback_func = function()
				managers.system_menu:force_close_all()
				save_to_file()
			end, },
			{ text = "load build from file", callback_func = function()
				managers.system_menu:force_close_all()
				load_from_file()
			end, },
			{ text = managers.localization:text("dialog_ok"), cancel_button = true, callback_func = function() managers.system_menu:force_close_all() end, },
		},
	})
end




local function change_profile(profile_idx)
	if not profile_idx then
		local current_profile_idx = managers.multi_profile._global._current_profile
		managers.multi_profile:set_current_profile(current_profile_idx)
	else
		managers.multi_profile:set_current_profile(profile_idx)
	end
end

local function change_skill_switch(skill_switch_idx)
	if not skill_switch_idx then
		local current_skill_switch_idx = managers.skilltree:get_selected_skill_switch()
		managers.skilltree:switch_skills(current_skill_switch_idx)
	else
		managers.skilltree:switch_skills(skill_switch_idx)
	end
end

local function assign_skill_switch_for_each_profile()
	local current_profile_idx = managers.multi_profile._global._current_profile
	local max_profile_count = managers.multi_profile:profile_count()
	local max_skill_switch_count = #managers.skilltree._global.skill_switches
	for i = 1, math.min(max_profile_count, max_skill_switch_count) do
		change_profile(i)
		change_skill_switch(i)
	end
	change_profile(current_profile_idx)
end

-- be careful, this might damage your save files if game code change
local function full_reset_current_skill_switch()
	local switch_data = managers.skilltree._global.skill_switches[managers.skilltree:get_selected_skill_switch()]
	switch_data.trees = {}
	for tree, data in pairs(tweak_data.skilltree.trees) do
		switch_data.trees[tree] = {
			unlocked = true,
			points_spent = Application:digest_value(0, true)
		}
	end
	switch_data.skills = {}
	for skill_id, data in pairs(tweak_data.skilltree.skills) do
		switch_data.skills[skill_id] = {
			unlocked = 0,
			total = #data
		}
	end
	managers.skilltree:_set_points(managers.skilltree:max_points_for_current_level())
end




-- assign_skill_switch_for_each_profile()

-- save_to_clipboard()
-- load_from_clipboard()
-- save_to_file()
-- load_from_file()

show_main_menu()
